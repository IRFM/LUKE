function [equil_magnetic,prho,pspsin,pspsinT,pp,li] = build_helmex_equil_yp(ppsi_in,ptot_in,pj_in,Rp_in,Zp_in,Bt_in,Ip_in,ap_in,R_in,Z_in,ntheta,display_opt)
%
%   Create a magnetic equilibrium structure using HELENA code (mex file version)
%
%   INPUTS
%
%       - psipin : flux poloidal (V*s, doit etre nul au centre) [Xpts,1]
%       - ptot : ne Te + ni Ti (keV * m-3) [Xpts,1] 
%       - jin : densite de courant (A/m2) [Xpts,1]
%       - R0 : grand rayon (m) [1,1]
%       - B0 : champ magnetique (T) [1,1]
%       - Ip : courant plasma (A) [1,1], Ip < 0 -> utilisation de psip pour le calcul du courant
%       - lsc : type d'input pour la derniere surface magnetique fermee, 0 = plasma sym,1 = plasma asymetrique, donnee de a, elong, triangh,triangb, 2 = plasma asymetrique, donnee de la LSC en (R,Z) [1,1]
%       - a  : petit rayon (m) [1,1]
%       - elong : ellipticite de la derniere surface magnetique fermee (1 pour TS) (-) [1,1]
%       - triangh : triangularite haute de la derniere surface magnetique fermee (0 pour TS) (-) [1,1]
%       - triangb : triangularite basse de la derniere surface magnetique fermee (0 pour TS) (-) [1,1]
%       - init : si =1, alors on part de l'equilibre initial specifie par df2,b,kkbig [1,1] si =0, alors on part d'un equilibre initial quelconque
%       - b : parametre b de l'equilibre initial (-) [1,1]
%       - df2 : vecteur df2 de l'equilibre initial (-) [101,1]
%       - kkbig : matrice kkbig deja calculee (-) [KKLDA,4*MAXNODE]
%       - ecrit : matrice kkbig deja calculee (-) [KKLDA,4*MAXNODE]
%       - Rext  : grand rayon de la derniere surface de flux [250,1]
%       - Zext  : altitude de la derniere surface de flux [250,1]
%       - xrsig = [XR1,SIG1] -> defini la position et la largeur de la gaussienne pour un maillage plus fin autour de XR1
%       - dpr : vecteur dpr de l'equilibre initial (-) [101,1] (P')
%       - FR     : Fourier coefficient of LCMS transform
%
%   OUTPUTS
%


%   by Y. Peysson (CEA/DSM/IRFM,yves.peysson@cea.fr) and J. Decker (EPFL/CRPP,joan.decker@epfl.ch)
%
%Note: the toroidal magnetic field must be always positive for helmex77
%and the plasma current must be positive for helmex77 so that the current
%output is correctly normalized
%
init = [0,1e-3,1e-7];%Second argument is the accuracy on the current, the third on the global equilibrium
%
if exist(['helmex77.',mexext]) == 3,
 	[C2,C3,rho2m,R,Zout,rho,Vp,drhoor,qpsi,ppsi,ftra,Fdia,psiT,B2,invB2,Sp, ...
			rav,oor,drhoav,xshift,xrad,xell,xtriapos,xtrianeg,jout,ipout,pout, ...
			r2,oor2,r2tau2,drho2ob2,r3otau3,r3otau,BR,BZ,b,df2,dpr,kkbig,li, ...
			dimerc,drmerc,balcrit,frmode,ifail,nchi,cpsurf,radius,gem11,gem12,gem33,rspot,zspot,brspot,bzspot]= ...
			helmex77(abs(ppsi_in),ptot_in,pj_in,Rp_in,abs(Bt_in),abs(Ip_in),2,ap_in,0,0,0,R_in,Z_in,init,0,0*ppsi_in,[],2);
%
	[qe,me,mp,mn,e0,mu0] = pc_dke_yp;
	Ip_helmex = ipout.* max(xrad).*abs(Bt_in)/mu0*sign(Ip_in);%For test only (MA)
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
    if display_opt >= 1,
        disp('------------------------------------------------------');
        disp(['Minor radius from guess (m) : ',num2str(ap_in),', from HELMEX77 (kept): ',num2str(ap_helmex)])
        disp(['Major radius from guess (m) : ',num2str(Rp_in),', from HELMEX77 (kept): ',num2str(Rp_helmex)])
        disp(['Magnetic field on axis guess (T) : ',num2str(Bt_in),', from HELMEX77 (kept): ',num2str(Bt_helmex)])
        disp(['Plasma current guess (MA) : ',num2str(Ip_in/1e6),', from HELMEX77 (kept): ',num2str(Ip_helmex/1e6)])
        disp('------------------------------------------------------');
    end
%
	ppsi = ppsi/2/pi;%In order to match the defintion of ppsi in DKE
	ppsin = ppsi'/ppsi(end);%Normalized flux grid
	theta = linspace(0,2*pi,ntheta);% uniform theta grid
%
    Zp_helmex = Zout(1,1);%Vertical position of the plasma at theta = 0
    Y_helmex = Zout - Zp_helmex;%HELMEX77 calculate magnetic equilibrium at Zp = 0 but small vertical shift must be corrected. The vertical shift of the magnetic flux surfaces must be added after HELENA calculations  
%		
%		Transfer to the equil_magnetic structure
%
    if display_opt  >= 2,
        %
        R_sep0 = R_in;
        Z_sep0 = Z_in + Zp_in;
        %
        Rp = Rp_in;
        Zp = Zp_in;
        %
        figure('name','HELENA separatrix'),
        [ax] = graph1D_jd(R_sep0 - Rp,Z_sep0 - Zp,0,0,'R - R_{p} (m)','Z - Z_{p} (m)','HELENA separatrix',NaN,'','','-','none','b',2);        
        [ax] = graph1D_jd(R(end,:) - Rp_helmex,Y_helmex(end,:),0,0,'R - R_{p} (m)','Z - Z_{p} (m)','HELENA separatrix',NaN,'','','--','none','r',2);
        legend('Guess','HELENA');
        [ax] = graph1D_jd(R_sep0(1,1) - Rp,Z_sep0(1,1) - Zp,0,0,'R - R_{p} (m)','Z - Z_{p} (m)','HELENA separatrix',NaN,'','','none','+','b',2);
        [ax] = graph1D_jd(R(end,1) - Rp_helmex,Y_helmex(end,1),0,0,'R - R_{p} (m)','Z - Z_{p} (m)','HELENA separatrix',NaN,'','','none','*','r',2);
        axis('equal')
        %
        figure('name','HELENA magnetic equilibrium')
        [ax] = graph1D_jd(R(end,:),Zout(end,:),0,0,'R (m)','Z (m)','HELENA separatrix',NaN,'','','--','none','r',2);
        [ax] = graph1D_jd(R(end,1),Zout(end,1),0,0,'R (m)','Z (m)','HELENA separatrix',NaN,'','','none','*','r',2);
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
else
    equil_magnetic = [];
    prho = [];
    pspsin = [];
    pspsinT = [];
    pp = [];
    li = [];
	disp([' ---> WARNING: The mexfile helmex77.',mexext,' does not exists ! Compile it for the computer you are using...']);
end