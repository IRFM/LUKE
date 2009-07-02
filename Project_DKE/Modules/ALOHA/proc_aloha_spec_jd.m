function [yN,ydN,yP,zyfac] = proc_aloha_spec_jd(zN,zdN,zdP,zredfac,param,display_mode)
	%
	if nargin < 6,
    	display_mode = 0;
	end
	if nargin < 5,
    	param = 2;
	end
	%
	zdP = zdP(:)'*zredfac;
	zdN = zdN(:)';
	zN = zN(:)';
	%
	if min(zdP) < 0,
	    disp('warning: min(zdP) < 0, correcting')
	    zdP = zdP - min(zdP);
	end
	%
	global zx zf
	%
	if length(zdN) == 1 && isnan(zdN),
	    zN_S = [zN(1) - (zN(2)-zN(1))/2, (zN(1:end-1) + zN(2:end))/2, zN(end) + (zN(end)-zN(end-1))/2];
	    zdN = diff(zN_S);
	end
	%
	Ptot = sum(zdP.*zdN);
	%
	nz = length(zdP);
	%
	zppdP = [0,zdP,0];
	%
	zptrend = sign(diff(zppdP));
	%
	if any(zptrend == 0),
    error('case of successive points with equal power density not yet treated.')
	end
	%
	zvar = diff(zptrend);
	%
	ilim = [1,find(zvar == 2),nz]; 
%ipeak = find(zvar == -2);
%
% 
% ilim = 1;
% ipeak = [];
%
% Prefm = zP(1);
% evol = 1;
% %
% for iz = 1:nz,
%     %
%     Rrefp = zP(iz+1);
%     %
%     if (Rrefp - Prefm)*evol < 0,% inversing trend
%         %
%         if evol == 1,% peak is passed
%             %
%             ipeak = [ipeak,iz];
%             %
%         else% low is passed
%             %
%             ilim = [ilim,iz];
%             %
%         end
%         %
%         evol = -evol;
%         %
%     end
%     %
%     Prefm = Prefp;  
%     %
% end
%
% clear Prefm Prefp iz evol
%
	ny = length(ilim) - 1;
	%
	zydP = repmat(zdP.',[1,ny]);
	zydN = repmat(zdN.',[1,ny]);
	zyN = repmat(zN.',[1,ny]);
	%
	zyind = (1:nz).'*ones(1,ny);
	zyilimm = repmat(ilim(1:end-1),[nz,1]);
	zyilimp = repmat(ilim(2:end),[nz,1]);
	%
	zyfac = zeros(nz,ny);
	zyfac(zyind > zyilimm & zyind < zyilimp) = 1;
	zyfac(zyind == zyilimm | zyind == zyilimp) = 1/2;%half power belongs to lobe at separation points
	zyfac(zyind == 1 | zyind == nz) = 2*zyfac(zyind == 1 | zyind == nz);%full power belongs to lobe at end points
	%
	yP = sum(zydP.*zydN.*zyfac);
	yN = sum(zydP.*zydN.*zyfac.*zyN)./yP;
	ydN = sqrt(2*sum(zydP.*zydN.*zyfac.*(zyN - repmat(yN,[nz,1])).^2)./yP);
	for iy = 1:ny,
	    zx = zN - yN(iy);
	    zf = zdP.*zyfac(:,iy).'/yP(iy);
	    ydN(iy) = lsqnonlin(@gauss_squares_jd,ydN(iy));
	end
	%
	if abs(sum(yP) - Ptot)/Ptot > eps('double')*nz,
	    error('Power was not conserved')
	end
	%
	if param < 1,
	    Pfacmin = param;
	    nlobesmax = ny;
	else
	    Pfacmin = 0;
	    nlobesmax = param;
	end
	%
	while ny > nlobesmax || min(yP)/Ptot < Pfacmin,
	    %
	    iy = find(yP == min(yP),1,'first');
	    %
	    if iy == 1,
	        %
	        iyp = 2;
	        zyfac(:,iyp) = zyfac(:,iyp) + zyfac(:,iy);
	        yP(iyp) = sum(zdP.*zdN.*zyfac(:,iyp).');
	        yN(iyp) = sum(zdP.*zdN.*zyfac(:,iyp).'.*zN)./yP(iyp);
	        ydN(iyp) = sqrt(2*sum(zdP.*zdN.*zyfac(:,iyp).'.*(zN - yN(iyp)).^2)/yP(iyp));
	        zx = zN - yN(iyp);
	        zf = zdP.*zyfac(:,iyp).'/yP(iyp);
	        ydN(iyp) = lsqnonlin(@gauss_squares_jd,ydN(iyp));
	        %
	    elseif iy == ny,
	        %
	        iym = ny - 1;
	        zyfac(:,iym) = zyfac(:,iym) + zyfac(:,iy);
	        yP(iym) = sum(zdP.*zdN.*zyfac(:,iym).');
	        yN(iym) = sum(zdP.*zdN.*zyfac(:,iym).'.*zN)./yP(iym);
	        ydN(iym) = sqrt(2*sum(zdP.*zdN.*zyfac(:,iym).'.*(zN - yN(iym)).^2)/yP(iym));
	        zx = zN - yN(iym);
	        zf = zdP.*zyfac(:,iym).'/yP(iym);
	        ydN(iym) = lsqnonlin(@gauss_squares_jd,ydN(iym));
	        %
	    else
	        %
	        iym = iy - 1;
	        iyp = iy + 1;
	        %
	        Nlim = (yN(iym) + yN(iyp))/2;
	        izlimm = find(zN_S < Nlim,1,'last');
	        %
	        zyfac(1:izlimm-1,iym) = zyfac(1:izlimm-1,iym) + zyfac(1:izlimm-1,iy);
	        zyfac(izlimm+1:end,iyp) = zyfac(izlimm+1:end,iyp) + zyfac(izlimm+1:end,iy);
	        %
	        zyfac(izlimm,iym) = zyfac(izlimm,iym) + zyfac(izlimm,iy)*(Nlim - zN_S(izlimm))/zdN(izlimm);
	        zyfac(izlimm,iyp) = zyfac(izlimm,iyp) + zyfac(izlimm,iy)*(zN_S(izlimm + 1) - Nlim)/zdN(izlimm);
	        %
	        yP(iym) = sum(zdP.*zdN.*zyfac(:,iym).');
	        yN(iym) = sum(zdP.*zdN.*zyfac(:,iym).'.*zN)./yP(iym);
	        ydN(iym) = sqrt(2*sum(zdP.*zdN.*zyfac(:,iym).'.*(zN - yN(iym)).^2)/yP(iym));
	        zx = zN - yN(iym);
	        zf = zdP.*zyfac(:,iym).'/yP(iym);
	        ydN(iym) = lsqnonlin(@gauss_squares_jd,ydN(iym));
	        %
	        yP(iyp) = sum(zdP.*zdN.*zyfac(:,iyp).');
	        yN(iyp) = sum(zdP.*zdN.*zyfac(:,iyp).'.*zN)./yP(iyp);
	        ydN(iyp) = sqrt(2*sum(zdP.*zdN.*zyfac(:,iyp).'.*(zN - yN(iyp)).^2)/yP(iyp));
	        zx = zN - yN(iyp);
	        zf = zdP.*zyfac(:,iyp).'/yP(iyp);
	        ydN(iyp) = lsqnonlin(@gauss_squares_jd,ydN(iyp));
	        %
	    end
	    %
	    yP(iy) = [];
	    yN(iy) = [];
	    ydN(iy) = [];
	    zyfac(:,iy) = [];
	    %
	    ny = ny - 1;    
	    %
	end
	%
	if display_mode >= 2,
	    %
	    dx = min(ydN)/10;
	    x = (min(yN) - max(ydN)):dx:(max(yN) + max(ydN));
	    nx = length(x);
	    %
	    xyN = repmat(yN,[nx,1]);
	    xyP = repmat(yP,[nx,1]);
	    xydN = repmat(ydN,[nx,1]);
	    xy = repmat(x.',[1,ny]);
	    %
	    xyf = xyP.*exp(-(xy - xyN).^2./xydN.^2)./sqrt(pi)./xydN;
	    xf = sum(xyf,2);
	    %
		figure('Name','Gaussian fit calculation'),
		leg = {'Gaussian','Fit'};
		graph1D_jd(xy(:),xyf(:)/1e6,0,0,'n_z','dP/dn_z (MW)','Gaussian fit of the LH power spectrum',NaN,'','','-','none','b',2);hold on
		graph1D_jd(x,xf/1e6,0,0,'n_z','dP/dn_z (MW)','Gaussian fit of the LH power spectrum',leg,'','','--','none','r',2);
	    %
	    figure('Name','Gaussian fit vs. ALOHA'),
	    leg = {'ALOHA','Gaussian fit'};
		graph1D_jd(zN,zdP/1e6,0,0,'n_z','dP/dn_z (MW)','Gaussian fit vs. ALOHA for the LH power spectrum',NaN,'','','-','none','b',2);hold on
		graph1D_jd(x,xf/1e6,0,0,'n_z','dP/dn_z (MW)','Gaussian fit vs. ALOHA for the LH power spectrum',leg,'','','--','none','r',2);
	    %    
	end
end       


function [zdf] = gauss_squares_jd(dN)
	% 
	global zx zf
	%
	zdf = zf - exp(-zx.^2/dN^2)/sqrt(pi)/dN;
	%
end






    