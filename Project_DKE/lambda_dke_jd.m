clear, warning off

memax = 128*1e6; % Available memory
filename = 'equihelena';
method = 'linear';
super = 10;
nmhu = 41;
ymhu0 = linspace(0,1,nmhu); % Pitch-angle cosine at minimum of B-field


eval(['load ',filename,'.mat'])

XR = R;
XZ = Z;
XBR = BR;
XBZ = BZ;
XBphi = BPHI;

xpsi = psi;
xq = q;

clear R Z BR BZ BPHI psi q

[np,nti] = size(XR);
thetai = linspace(0,2*pi,nti); % Angulqr grid

super = round(super);
nt = nti*super;
theta = linspace(0,2*pi,nt); % Angulqr grid

if super > 1
	XR = interp1(thetai,XR',theta,method)';		
	XZ = interp1(thetai,XZ',theta,method)';		
	XBR = interp1(thetai,XBR',theta,method)';		
	XBZ = interp1(thetai,XBZ',theta,method)';		
	XBphi = interp1(thetai,XBphi',theta,method)';		
end	
	
dt = theta(2) - theta(1);
tdt = [dt/2, dt*ones(1,nt - 2), dt/2];

psimin = min(xpsi);
psimax = max(xpsi);

R0 = XR(1,1); % R of Magnetic Axix
Z0 = XZ(1,1); % Z of Magnetic Axix

xr = XR(:,1)' - R0; % Radial distance on LFS horizontal midplane
a = max(xr); 

XBT = abs(XBphi); % Toroidal B-field
XBP = sqrt(XBR.^2 + XBZ.^2); % Poloidal B-field
XB = sqrt(XBT.^2 + XBP.^2); % Total B-field

xBmin = min(XB'); % Minimum of B on FS
xBmax = max(XB'); % Maximum of B on FS

xmhu0T = sqrt(1 - xBmin./xBmax); % Pitch-angle at the trapped-passing boundary

if np*nt*nmhu <= memax/8/14

	YB = repmat(XB,[1,1,nmhu]);
	YBmin = repmat(xBmin',[1,nt,nmhu]);
	Ymhu0 = shiftdim(repmat(ymhu0',[1,np,nt]),1);

	YPSIB = YB./YBmin; % Ratio of B-field to its minimum on FS
	YBb = YBmin./(1 - Ymhu0.^2); % B-field at turning point

	clear YBmin

	Ymhu = sign(Ymhu0).*sqrt(1 - YPSIB.*(1 - Ymhu0.^2)); % Pitch-angle cosine of (psi,theta,mhu)

	clear YPSIB

	Ymask = YB <= YBb; % mask on the intergration over theta

	clear YBb

	Ymhu(~Ymask) = eps;


	YBR = repmat(XBR,[1,1,nmhu]);	
	YBZ = repmat(XBZ,[1,1,nmhu]);
	YR = repmat(XR,[1,1,nmhu]);
	YZ = repmat(XZ,[1,1,nmhu]);


	xyInt = integral_dke_jd( tdt/(2*pi), Ymask.*YB.*((YR - R0).^2 + (YZ - Z0).^2).*Ymhu0./abs(YBR.*(YZ - Z0) - YBZ.*(YR - R0))./Ymhu, 2);
	
else
	xyInt = zeros(np,nmhu);
	for ip=1:np
		
		disp(['ip = ',num2str(ip),'/',num2str(np)]);

		tyB = repmat(XB(ip,:)',[1,nmhu]);
		tymhu0 = repmat(ymhu0,[nt,1]);
		
		tyPSIB = tyB/xBmin(ip); % Ratio of B-field to its minimum on FS
		tyBb = xBmin(ip)./(1 - tymhu0.^2); % B-field at turning point

		clear tyBmin
	
		tymhu = sign(tymhu0).*sqrt(1 - tyPSIB.*(1 - tymhu0.^2)); % Pitch-angle cosine of (psi,theta,mhu)
	
		clear tyPSIB
	
		tymask = tyB <= tyBb; % mask on the intergration over theta
	
		clear tyBb
	
		tymhu(~tymask) = eps;


		tyBR = repmat(XBR(ip,:)',[1,nmhu]);	
		tyBZ = repmat(XBZ(ip,:)',[1,nmhu]);
		tyR = repmat(XR(ip,:)',[1,nmhu]);
		tyZ = repmat(XZ(ip,:)',[1,nmhu]);


		xyInt(ip,:) = integral_dke_jd( tdt/(2*pi), tymask.*tyB.*((tyR - R0).^2 + (tyZ - Z0).^2).*tymhu0./abs(tyBR.*(tyZ - Z0) - tyBZ.*(tyR - R0))./tymhu, 1)';
	end
end

ymask = find(ymhu0 == 0);
if ~isempty(ymask)
	xyInt(:,ymask) = 0;
end

xyr = repmat(xr',[1,nmhu]);
xyq = repmat(xq',[1,nmhu]);

xylambda = xyInt./xyr./sqrt(1 + (R0*xyq./xyr).^2);

figure(1),clf

[ax] = graph2Djd(xr,ymhu0,xylambda,'','','',[0,a],[min(ymhu0),max(ymhu0)],0,NaN,[0:0.2:2],1,'-','r',2,0.9,NaN);
hold on
[ax] = graph1Djd(xr,xmhu0T,'r','\xi','\lambda',[0,a],[min(ymhu0),max(ymhu0)],'--','none','b',2,gca,1,0.7,0.5);
hold off

figure(2),clf

xmask = [2,round(np/4),round(np/2),round(np*3/4),np]

[ax] = graph1Djd(ymhu0,xylambda(xmask,:),'\xi','\lambda','',[min(ymhu0),max(ymhu0)],[0,3],'-','none','r',2,gca,0.9,0.7,0.7);



