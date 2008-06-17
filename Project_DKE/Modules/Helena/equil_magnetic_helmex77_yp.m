function [equil_magnetic,prho,pspsin,pspsinT,pp] = equil_magnetic_helmex77_yp(ap,Rp,Zp,xpoint,Bt,Ip,ppsi,pj,ptot,ntheta,display_opt,id_path,path_path)
%
%   Create a magnetic equilibrium structure for C3PO/LUKE using HELENA code
%   (mex file version)
%
%   by Y. Peysson (CEA/DSM/IRFM,yves.peysson@cea.fr) and J. Decker
%   (CEA/DSM/IRFM,joan.decker@cea.fr)
%
if nargin < 10,
   error('Not enough input arguments in equil_magnetic_helmex77_yp.')
elseif nargin == 10,
   display_opt = 0;
   id_path = '';
   path_path = '';
elseif nargin == 11,
   id_path = '';
   path_path = '';
elseif nargin == 11,
   path_path = '';
end 
%
dkepath = load_structures_yp('dkepath',id_path,path_path);
%
if exist(['helmex77',mexext]) == 3,
%
    lim_top = atan(0.5*xpoint(1)/(1-xpoint(2)))*180/pi;%In order to avoid convergence problem in separatrix MEX file
	if xpoint(4) > lim_top,xpoint(4) = lim_top - 0.1;end
	lim_bottom = atan(0.5*xpoint(5)/(1-xpoint(6)))*180/pi;%In order to avoid convergence problem in separatrix MEX file
	if xpoint(8) > lim_bottom,xpoint(8) = lim_bottom - 0.1;end
%
	[x1,y1] = separatrice(xpoint,1);%The LCS is approximated by four ellipses (mode = 1)

	rr = x1*ap;
	zz = y1*ap;
	alpha  = unwrap(angle(rr+ i .* zz));%poloidal angle
	if alpha(end) < -5
		alpha = alpha - alpha(end);
	end
%
	theta_sep  = linspace(0,2*pi,ntheta);% poloidal points
	ind = find(diff(alpha) == 0);
	alpha(ind) = [];
	rr(ind) = [];
	zz(ind) = [];
%    
	R_sep0 = spline(alpha',rr',theta_sep) + Rp;%resampling 
	Z_sep0 = spline(alpha',zz',theta_sep) + Zp;%resampling 
%
% For the input to HELENA
%
    ap_in = ap;
    Rp_in = Rp;
    Zp_in = Zp;
    R_in = R_sep0;
    Z_in = Z_sep0 - Zp_in;%because HELENA work only at Zp = 0.
%
    Bt_in = Bt;
    Ip_in = Ip;
%
	ppsi_in = ppsi;
	ptot_in = ptot;
	pj_in = pj; 
%
    init = [0,1e-3,1e-7];%Second argument is the accuracy on the current, the third on the global equilibrium
%
%Note: the toroidal magnetic field must be always positive for helmex77
%and the plasma current must be positive for helmex77 so that the current
%output is correctly normalized
%
 	[C2,C3,rho2m,R,Zout,rho,Vp,drhoor,qpsi,ppsi,ftra,Fdia,psiT,B2,invB2,Sp, ...
			rav,oor,drhoav,xshift,xrad,xell,xtriapos,xtrianeg,jout,ipout,pout, ...
			r2,oor2,r2tau2,drho2ob2,r3otau3,r3otau,BR,BZ,b,df2,dpr,kkbig,li, ...
			dimerc,drmerc,balcrit,frmode,ifail,nchi,cpsurf,radius,gem11,gem12,gem33,rspot,zspot,brspot,bzspot]= ...
			helmex77(ppsi_in,ptot_in,pj_in,Rp_in,abs(Bt_in),abs(Ip_in)*1e6,2,ap_in,0,0,0,R_in,Z_in,init,0,0*ppsi_in,[],2);
%
	[qe,me,mp,mn,e0,mu0] = pc_dke_yp;
	Ip_helmex = ipout.* max(xrad).*abs(Bt_in)/mu0*1e-6*sign(Ip_in);%For test only (MA)
%	  
	BPHI = (Fdia*ones(1,ntheta))./R*sign(Bt_in);%Recover also the correct sign
    BR(1,:) = 0;%avoid problems at the plasma center. BR must be zero exactly (sometimes spurious values)
    BZ(1,:) = 0;%avoid problems at the plasma center. BZ must be zero exactly (sometimes spurious values)
	BR = BR*sign(Ip_in);%Recover also the correct sign
	BZ = BZ*sign(Ip_in);%Recover also the correct sign
	ppsi = ppsi*sign(Ip_in);%Recover also the correct sign  
%    
	ap_helmex = R(end,1) - R(1,1);
	Rp_helmex = R(1,1);
	Bt_helmex = BPHI(1,1);
%
    if display_opt ~= 0,
        disp('------------------------------------------------------');
        disp(['Minor radius from guess (m) : ',num2str(ap_in),', from HELMEX77 (kept): ',num2str(ap_helmex)])
        disp(['Major radius from guess (m) : ',num2str(Rp_in),', from HELMEX77 (kept): ',num2str(Rp_helmex)])
        disp(['Magnetic field on axis guess (T) : ',num2str(Bt_in),', from HELMEX77 (kept): ',num2str(Bt_helmex)])
        disp(['Plasma current guess (MA) : ',num2str(Ip_in),', from HELMEX77 (kept): ',num2str(Ip_helmex)])
        disp('------------------------------------------------------');
    end
%
	ppsi = ppsi/2/pi;%In order to match the defintion of ppsi in DKE
	ppsin = ppsi'/max(ppsi);%Normalized flux grid
	theta = linspace(0,2*pi,ntheta);% uniform theta grid
%
    Zp_helmex = Zout(1,1);%Vertical position of the plasma at theta = 0
    Y_helmex = Zout - Zp_helmex;%HELMEX77 calculate magnetic equilibrium at Zp = 0 but small vertical shift must be corrected. The vertical shift of the magnetic flux surfaces must be added after HELENA calculations  
%		
%		Transfer to the equil_magnetic structure
%
    if display_opt ~= 0,
        figure('name','JETh77 separatrix'),
        [ax] = graph1D_jd(R_sep0 - Rp,Z_sep0 - Zp,0,0,'R - R_{p} (m)','Z - Z_{p} (m)','JETh77 separatrix',NaN,'','','-','none','b',2);        
        [ax] = graph1D_jd(R(end,:) - Rp_helmex,Y_helmex(end,:),0,0,'R - R_{p} (m)','Z - Z_{p} (m)','JETh77 separatrix',NaN,'','','--','none','r',2);
        legend('Guess','HELENA');
        [ax] = graph1D_jd(R_sep0(1,1) - Rp,Z_sep0(1,1) - Zp,0,0,'R - R_{p} (m)','Z - Z_{p} (m)','JETh77 separatrix',NaN,'','','none','+','b',2);
        [ax] = graph1D_jd(R(end,1) - Rp_helmex,Y_helmex(end,1),0,0,'R - R_{p} (m)','Z - Z_{p} (m)','JETh77 separatrix',NaN,'','','none','*','r',2);
        axis('equal')
%
        figure('name','JETh77 magnetic equilibrium')
        [ax] = graph1D_jd(R(end,:),Zout(end,:),0,0,'R (m)','Z (m)','JETh77 separatrix',NaN,'','','--','none','r',2);
        [ax] = graph1D_jd(R(end,1),Zout(end,1),0,0,'R (m)','Z (m)','JETh77 separatrix',NaN,'','','none','*','r',2);
        axis('equal')
    end
%
	equil_magnetic.psi_apRp = ppsi*ap_helmex/Rp_helmex;%psi_apRp = psi(poloidal usual)*ap/Rp for the cylindrical limit
	equil_magnetic.theta = theta;
	equil_magnetic.ptx = R - Rp_helmex;
	equil_magnetic.pty = Y_helmex;
	equil_magnetic.ptBx = BR;
	equil_magnetic.ptBy = BZ;
	equil_magnetic.ptBPHI = BPHI;
	equil_magnetic.Rp = Rp_helmex;
    equil_magnetic.Zp = Zp_helmex;
%   
% Other output
%
    prho = equil_magnetic.ptx(:,1).'/equil_magnetic.ptx(end,1);
%
    pq_h = (qpsi(1:end-1) + qpsi(2:end))/2;
    pdpsin = diff(ppsin);
    ppsiT = [0,cumsum(pq_h'.*pdpsin)];
    pspsinT = sqrt(ppsiT/ppsiT(end));
%
    pspsin = sqrt(ppsin);
%
    pp = pout;%pressure given by HELENA
%
else
	error(['The mexfile helmex77',mexext,' does not exists ! Compile it for the computer you are using...']);
end



