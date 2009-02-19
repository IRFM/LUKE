function 	 [Xa,Xb,Xc,Xd,Xe,Xf,Xg,Xh,Xi] = ...
    	        fpengine_dke_yp(dkeparam,ftp_mode,...
    	        Xdeltap_imj,Xdeltap_ipj,Xdeltam_ijm,Xdeltam_ijp,...
                Xdeltap_imjmm,Xdeltap_imjpp,Xdeltap_ipjmm,Xdeltap_ipjpp,...
                Xdeltam_immjm,Xdeltam_ippjm,Xdeltam_immjp,Xdeltam_ippjp,...
    	        XRlambdam,XRlambdap,...
				Xpnmm,Xpnm,Xpn,Xpnp,Xpnpp,Xpn2m,Xpn2p,Xdpnmm,Xdpnm,Xdpn,Xdpnp,Xdpnpp,...
        	    Xmhumm,Xmhum,Xmhu,Xmhup,Xmhupp,X1mmhu2,X1mmhu2m,X1mmhu2p,Xdmhumm,Xdmhum,Xdmhu,Xdmhup,Xdmhupp,...
        	    XDpp_ippj,XDpp_ipj,XDpp_ij,XDpp_imj,XDpp_immj,...
		        XDpm_ipj,XDpm_ij,XDpm_imj,...
			    XDmp_ijp,XDmp_ij,XDmp_ijm,...
			    XDmm_ijp,XDmm_ijm,...
        	    XFp_ippj,XFp_ipj,XFp_ij,XFp_imj,XFp_immj,...
			    XFm_ijp,XFm_ijm);
%
%Fokker-Planck engine for zero (usual FP code) or first order (neoclassical corrections for bootstrap current).
%It calculates the matrix coefficients starting from diffusion and convection in momentum space. Full conservative
%form. All processes are therefore considered in the same way
%
%	Input:
%
%	Output:
%
%	- Xa: Matrix coefficient for f0(i+1/2,j-1/2)
%	- Xb: Matrix coefficient for f0(i-1/2,j+1/2)
%	- Xc: Matrix coefficient for f0(i+1/2,j+1/2)
%	- Xd: Matrix coefficient for f0(i+3/2,j+1/2)
%	- Xe: Matrix coefficient for f0(i+1/2,j+3/2)
%	- Xf: Matrix coefficient for f0(i-1/2,j-1/2)
%	- Xg: Matrix coefficient for f0(i+3/2,j+3/2)
%	- Xh: Matrix coefficient for f0(i-1/2,j+3/2)
%	- Xi: Matrix coefficient for f0(i+3/2,j-1/2)
%	  (Notations: _imjp -> (i,j+1);_imjm -> (i,j);_ijp -> (i+1/2,j+1);_ijm -> (i+1/2,j);_immjp -> (i-1/2,j+1);_immjm -> (i-1/2,j)
%
%By Joan Decker (MIT-RLE, jodecker@mit.edu) and Yves Peysson (CEA-DRFC, yves.peysson@cea.fr)
%
if nargin < 47,
	error('Wrong number of input arguments in fpengine_dke_yp')
end
%		
if ftp_mode >= 1, ftp_mode = 1;end%Force ftp_mode to be 0 (FP) or 1 (DKE)
%
if ~isfield(dkeparam,'oldcross_mode'),dkeparam.oldcross_mode = 0;end
%
%Center cross-derivatives 
%
%(as done by Karney, Comp. Phys. Rep. (1986). Same
%results for LHCD but not very accurate for particle conservation, and
%unstable solution when D// > 1). It is therefore only given for a link
%with the past ! WARNING: IT MUST BE NEVER USED EXCEPT TESTS
%
if dkeparam.oldcross_mode == 1,%************ Must never be used **************
   Xa = - Xpnp.*XDpm_ipj.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./Xdpn;%grid point (i+1/2,j-1/2)
   Xa = Xa + Xpnm.*XDpm_imj.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./Xdpn;
   Xa = Xa - XDmm_ijm.*X1mmhu2m.*XRlambdam./Xdmhu./Xdmhum;
   Xa = Xa + Xpn.*sqrt(X1mmhu2m).*XFm_ijm.*Xdeltam_ijm.*(Xmhum./Xmhumm).^ftp_mode.*XRlambdam./Xdmhu;
%	
   Xb = -Xpn2m.*XDpp_imj./Xdpn./Xdpnm;%grid point (i-1/2,j+1/2)	
   Xb = Xb - Xpn.*sqrt(X1mmhu2p).*XDmp_ijp.*XRlambdap./Xdmhu./(Xdpnm + Xdpnp);
   Xb = Xb + Xpn.*sqrt(X1mmhu2m).*XDmp_ijm.*XRlambdam./Xdmhu./(Xdpnm + Xdpnp);
   Xb = Xb - Xpn2m.*XFp_imj.*Xdeltap_imj.*(Xpnm./Xpnmm).^ftp_mode./Xdpn;	
%
   Xc = Xpn2p.*XDpp_ipj./Xdpn./Xdpnp;%grid point (i+1/2,j+1/2)
   Xc = Xc + Xpn2p.*XFp_ipj.*Xdeltap_ipj.*(Xpnp./Xpn).^ftp_mode./Xdpn;
   Xc = Xc + Xpn2m.*XDpp_imj./Xdpn./Xdpnm;
   Xc = Xc - Xpn2m.*XFp_imj.*(1 - Xdeltap_imj).*(Xpnm./Xpn).^ftp_mode./Xdpn;
   Xc = Xc + XDmm_ijp.*X1mmhu2p.*XRlambdap./Xdmhu./Xdmhup;	
   Xc = Xc - Xpn.*sqrt(X1mmhu2p).*XFm_ijp.*XRlambdap.*Xdeltam_ijp.*(Xmhup./Xmhu).^ftp_mode./Xdmhu;
   Xc = Xc + XDmm_ijm.*X1mmhu2m.*XRlambdam./Xdmhu./Xdmhum;
   Xc = Xc + Xpn.*sqrt(X1mmhu2m).*XFm_ijm.*(1 - Xdeltam_ijm).*(Xmhum./Xmhu).^ftp_mode.*XRlambdam./Xdmhu;
%
   Xd = - Xpn2p.*XDpp_ipj./Xdpn./Xdpnp;%grid point (i+3/2,j+1/2)
   Xd = Xd + Xpn.*sqrt(X1mmhu2p).*XDmp_ijp.*XRlambdap./Xdmhu./(Xdpnm + Xdpnp);
   Xd = Xd - Xpn.*sqrt(X1mmhu2m).*XDmp_ijm.*XRlambdam./Xdmhu./(Xdpnm + Xdpnp);
   Xd = Xd + Xpn2p.*XFp_ipj.*(1 - Xdeltap_ipj).*(Xpnp./Xpnpp).^ftp_mode./Xdpn;	
%
   Xe = Xpnp.*XDpm_ipj.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./Xdpn;%grid point (i+1/2,j+3/2)
   Xe = Xe - Xpnm.*XDpm_imj.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./Xdpn;
   Xe = Xe - XDmm_ijp.*X1mmhu2p.*XRlambdap./Xdmhu./Xdmhup;
   Xe = Xe - Xpn.*sqrt(X1mmhu2p).*XFm_ijp.*(1 - Xdeltam_ijp).*(Xmhup./Xmhupp).^ftp_mode.*XRlambdap./Xdmhu;	
%
   Xf = XDpm_ij.*Xpn.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./(Xdpnm + Xdpnp);%grid point (i-1/2,j-1/2)
   Xf = Xf + XDmp_ij.*Xpn.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./(Xdpnm + Xdpnp);
%
   Xg = Xf;%grid point (i+3/2,j+3/2)
%	
   Xh = -XDpm_ij.*Xpn.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./(Xdpnm + Xdpnp);%grid point (i-1/2,j+3/2)
   Xh = Xh - XDmp_ij.*Xpn.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./(Xdpnm + Xdpnp);	
%
   Xi = Xh;%grid point (i+3/2,j-1/2)
elseif dkeparam.oldcross_mode == 0,%************ Must be always used **************
%
%Cross derivatives with exact boundary conditions (WARNING: MUST BE ALWAYS USED)
%
   Xa = - Xpnp.*XDpm_ipj.*sqrt(X1mmhu2).*Xdeltap_ipjmm./(Xdmhum + Xdmhup)./Xdpn;%grid point (i+1/2,j-1/2)
   Xa = Xa + Xpnm.*XDpm_imj.*sqrt(X1mmhu2).*(1 - Xdeltap_imjmm)./(Xdmhum + Xdmhup)./Xdpn;
   Xa = Xa - XDmm_ijm.*X1mmhu2m.*XRlambdam./Xdmhu./Xdmhum;
   Xa = Xa + Xpn.*sqrt(X1mmhu2m).*XFm_ijm.*Xdeltam_ijm.*(Xmhum./Xmhumm).^ftp_mode.*XRlambdam./Xdmhu;
%	
   Xb = -Xpn2m.*XDpp_imj./Xdpn./Xdpnm;%grid point (i-1/2,j+1/2) OK
   Xb = Xb - Xpn.*sqrt(X1mmhu2p).*XDmp_ijp.*XRlambdap.*Xdeltam_immjp./Xdmhu./(Xdpnm + Xdpnp);
   Xb = Xb + Xpn.*sqrt(X1mmhu2m).*XDmp_ijm.*XRlambdam.*(1 - Xdeltam_immjm)./Xdmhu./(Xdpnm + Xdpnp);
   Xb = Xb - Xpn2m.*XFp_imj.*Xdeltap_imj.*(Xpnm./Xpnmm).^ftp_mode./Xdpn;	
%
   Xc = Xpn2p.*XDpp_ipj./Xdpn./Xdpnp;%grid point (i+1/2,j+1/2)
   Xc = Xc + Xpn2p.*XFp_ipj.*Xdeltap_ipj.*(Xpnp./Xpn).^ftp_mode./Xdpn;
   Xc = Xc + Xpn2m.*XDpp_imj./Xdpn./Xdpnm;
   Xc = Xc - Xpn2m.*XFp_imj.*(1 - Xdeltap_imj).*(Xpnm./Xpn).^ftp_mode./Xdpn;
   Xc = Xc + XDmm_ijp.*X1mmhu2p.*XRlambdap./Xdmhu./Xdmhup;	
   Xc = Xc - Xpn.*sqrt(X1mmhu2p).*XFm_ijp.*XRlambdap.*Xdeltam_ijp.*(Xmhup./Xmhu).^ftp_mode./Xdmhu;
   Xc = Xc + XDmm_ijm.*X1mmhu2m.*XRlambdam./Xdmhu./Xdmhum;
   Xc = Xc + Xpn.*sqrt(X1mmhu2m).*XFm_ijm.*(1 - Xdeltam_ijm).*(Xmhum./Xmhu).^ftp_mode.*XRlambdam./Xdmhu;
%
   Xd = - Xpn2p.*XDpp_ipj./Xdpn./Xdpnp;%grid point (i+3/2,j+1/2) OK
   Xd = Xd + Xpn.*sqrt(X1mmhu2p).*XDmp_ijp.*XRlambdap.*Xdeltam_ippjp./Xdmhu./(Xdpnm + Xdpnp);
   Xd = Xd - Xpn.*sqrt(X1mmhu2m).*XDmp_ijm.*XRlambdam.*(1 - Xdeltam_ippjm)./Xdmhu./(Xdpnm + Xdpnp);
   Xd = Xd + Xpn2p.*XFp_ipj.*(1 - Xdeltap_ipj).*(Xpnp./Xpnpp).^ftp_mode./Xdpn;	
%
   Xe = Xpnp.*XDpm_ipj.*sqrt(X1mmhu2).*Xdeltap_ipjpp./(Xdmhum + Xdmhup)./Xdpn;%grid point (i+1/2,j+3/2) OK
   Xe = Xe - Xpnm.*XDpm_imj.*sqrt(X1mmhu2).*(1 - Xdeltap_imjpp)./(Xdmhum + Xdmhup)./Xdpn;
   Xe = Xe - XDmm_ijp.*X1mmhu2p.*XRlambdap./Xdmhu./Xdmhup;
   Xe = Xe - Xpn.*sqrt(X1mmhu2p).*XFm_ijp.*(1 - Xdeltam_ijp).*(Xmhup./Xmhupp).^ftp_mode.*XRlambdap./Xdmhu;	
%
   Xf = XDpm_imj.*Xpnm.*sqrt(X1mmhu2).*Xdeltap_imjmm./(Xdmhum + Xdmhup)./Xdpn;%grid point (i-1/2,j-1/2) OK
   Xf = Xf + XDmp_ijm.*Xpn.*sqrt(X1mmhu2m).*XRlambdam.*Xdeltam_immjm./Xdmhu./(Xdpnm + Xdpnp);
%
   Xg = XDpm_ipj.*Xpnp.*sqrt(X1mmhu2).*(1 - Xdeltap_ipjpp)./(Xdmhum + Xdmhup)./Xdpn;%grid point (i+3/2,j+3/2) OK
   Xg = Xg + XDmp_ijp.*Xpn.*sqrt(X1mmhu2p).*XRlambdap.*(1 - Xdeltam_ippjp)./Xdmhu./(Xdpnm + Xdpnp);
%	
   Xh = -XDpm_imj.*Xpnm.*sqrt(X1mmhu2).*Xdeltap_imjpp./(Xdmhum + Xdmhup)./Xdpn;%grid point (i-1/2,j+3/2) OK
   Xh = Xh - XDmp_ijp.*Xpn.*sqrt(X1mmhu2p).*XRlambdap.*(1 - Xdeltam_immjp)./Xdmhu./(Xdpnm + Xdpnp);	
%
   Xi = -XDpm_ipj.*Xpnp.*sqrt(X1mmhu2).*(1 - Xdeltap_ipjmm)./(Xdmhum + Xdmhup)./Xdpn;%grid point (i+3/2,j-1/2) OK
   Xi = Xi - XDmp_ijm.*Xpn.*sqrt(X1mmhu2m).*XRlambdam.*Xdeltam_ippjm./Xdmhu./(Xdpnm + Xdpnp);
end
