function [equil_magnetic,prho_out,pspsin_out,pspsinT_out,pp_out] = make_helmex77(shotnum,shotime,t1,t2,basestr,savename)
%
%   Create a magnetic equilibrium structure for C3PO/LUKE using HELENA code
%   (mex file version)
%
%   by Y. Peysson (CEA/DSM/IRFM,yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM,joan.decker@cea.fr)
%
npsi = 101;%ONLY 101 radial profile grid points for HELMEX77
ntheta = 65;%ONLY 65 poloidal grid points for HELMEX77
%
if strcmp(basestr,'TS'),
    %
    xpoint(1) = 1;%Vertical position of the top X point
    xpoint(2) = 0;%Horizontal position of the top X point
    xpoint(3) = 0;%Angle between the separatrix and the horizontal plane for the top X point (degree)
    xpoint(4) = 0;%Angle between the separatrix and the horizontal plane for the top X point (degree)
    xpoint(5) = 1;%Vertical position of the bottom X point (always positive value)
    xpoint(6) = 0;%Horizontal position of the bottom X point
    xpoint(7) = 0;%Angle between the separatrix and the horizontal plane for the bottom X point (degree)
    xpoint(8) = 0;%Angle between the separatrix and the horizontal plane for the bottom X point (degree)
    %
    while 1,
    	certif = input_dke_yp('Enter a certification: (-1) exit, 0 (no certification), 1, 2, 3, 4',0,{-1,0,1,2,3,4},'Invalid selection');
    	if certif == -1,
			return
    	end
		%
    	[ap,Rp,Zp,Bt,Ip,qmin,eq,qopt,Zi,mi,fi,Te0,Tea,eTe1,eTe2,ne0,nea,ene1,ene2,Ti0,Tia,eTi1,eTi2,Zeff0,Zeffa,eZeff,xZeff,vloop,LH,EC] = load_tprof_tsbase_yp(shotnum,certif,str2num(shotime),t1,t2,basestr);
        if isempty(ap),%tprof data are not documented for this shot and this certification
			disp(['WARNING: No tprof data do not exist for shot #',shotnum,' and certification ',int2str(certif),'. Please try another certification or exit.']);
            disp('WARNING: Contact T. Aniel or the CDIV for creating missing tprof data');
		else
			break
		end
	end		
else
    disp('The use of HELENA (helmex77) is not yet implemented for this machine.');
    return
end
%    
% Create guess magnetic equilibrium
%
[prho,pTe,pne,pzTi,pzni,zZi,zmi,fi,pkin] = idealprof_yp(Zi,mi,fi,Te0,Tea,eTe1,eTe2,ne0,nea,ene1,ene2,Ti0,Tia,eTi1,eTi2,Zeff0,Zeffa,eZeff,xZeff,npsi);%Profiles
%
[ppsin,ppsi_apRp,theta,x,y,Bx,By,BPHI,pBpp,pq_Rpap,pj,pmag,Ip_test] = idealequilcyl_yp(ap,Rp,Zp,Bt,Ip,qmin*Rp/ap,eq,qopt,npsi,ntheta);%Cylindrical magnetic equilibrium
%
pj_min = min(pj); 
if pj_min < 0,pj = pj - pj_min;end,%pj must be non-negative. Only the shape is considered and Ip for the total plasma current
[equil_magnetic,prho_out,pspsin_out,pspsinT_out,pp_out] = equil_magnetic_helmex77_yp(ap,Rp,Zp,xpoint,Bt,Ip,ppsi_apRp*Rp/ap,pj,pkin,ntheta,1);
%
% Data saving for imake_equil_jd and the consistency with other machines
%
prho = prho_out;
save(savename,'prho','pne','pTe','pzTi','pzni','zZi','zmi','fi','vloop','LH','EC');
%
