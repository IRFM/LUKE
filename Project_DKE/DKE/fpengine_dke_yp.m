function 	 [Xa,Xb,Xc,Xd,Xe,Xf,Xg,Xh,Xi] = ...
    	        fpengine_dke_yp(ftp_mode,...
    	        Xdeltap_imj,Xdeltap_ipj,Xdeltam_ijm,Xdeltam_ijp,...
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
%By Joan Decker (MIT-RLE) and Yves Peysson (CEA-DRFC,yves.peysson@cea.fr)
%
if nargin < 46,
	error('Wrong number of input arguments in fpengine_dke_yp')
end
%		
if ftp_mode == 0,% for f0 (zero order Fokker-Planck term)
%	
	Xa = - Xpnp.*XDpm_ipj.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./Xdpn;%f0(i+1/2,j-1/2)
	Xa = Xa + Xpnm.*XDpm_imj.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./Xdpn;
	Xa = Xa - Xpn.*XDmm_ijm.*X1mmhu2m.*XRlambdam./Xdmhu./Xdmhum;
	Xa = Xa - Xpn.*sqrt(X1mmhu2m).*XFm_ijm.*Xdeltam_ijm.*XRlambdam./Xdmhu;
%	
	Xb = -Xpn2m.*XDpp_imj./Xdpn./Xdpnm;%f0(i-1/2,j+1/2)	
	Xb = Xb - Xpn.*sqrt(X1mmhu2p).*XDmp_ijp.*XRlambdap./Xdmhu./(Xdpnm + Xdpnp);
	Xb = Xb + Xpn.*sqrt(X1mmhu2m).*XDmp_ijm.*XRlambdam./Xdmhu./(Xdpnm + Xdpnp);
	Xb = Xb - Xpn2m.*XFp_imj.*Xdeltap_imj./Xdpn;	
%
	Xc = Xpn2p.*XDpp_ipj./Xdpn./Xdpnp;%f0(i+1/2,j+1/2)
	Xc = Xc + Xpn2p.*XFp_ipj.*Xdeltap_ipj./Xdpn;
	Xc = Xc + Xpn2m.*XDpp_imj./Xdpn./Xdpnm;
	Xc = Xc - Xpn2m.*XFp_imj.*(1 - Xdeltap_imj)./Xdpn;
	Xc = Xc + Xpn.*XDmm_ijp.*X1mmhu2p.*XRlambdap./Xdmhu./Xdmhup;	
	Xc = Xc + Xpn.*sqrt(X1mmhu2p).*XFm_ijp.*XRlambdap.*Xdeltam_ijp./Xdmhu;	
	Xc = Xc + Xpn.*XDmm_ijm.*X1mmhu2m.*XRlambdam./Xdmhu./Xdmhum;
	Xc = Xc + Xpn.*sqrt(X1mmhu2m).*XFm_ijm.*(1 - Xdeltam_ijm).*XRlambdam./Xdmhu;
%
	Xd = - Xpn2p.*XDpp_ipj./Xdpn./Xdpnp;%f0(i+3/2,j+1/2)
	Xd = Xd + Xpn.*sqrt(X1mmhu2p).*XDmp_ijp.*XRlambdap./Xdmhu./(Xdpnm + Xdpnp);
	Xd = Xd - Xpn.*sqrt(X1mmhu2m).*XDmp_ijm.*XRlambdam./Xdmhu./(Xdpnm + Xdpnp);
	Xd = Xd + Xpn2p.*XFp_ipj.*(1 - Xdeltap_ipj)./Xdpn;	
%
	Xe = Xpnp.*XDpm_ipj.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./Xdpn;%f0(i+1/2,j+3/2)
	Xe = Xe - Xpnm.*XDpm_imj.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./Xdpn;
	Xe = Xe - Xpn.*XDmm_ijp.*X1mmhu2p.*XRlambdap./Xdmhu./Xdmhup;
	Xe = Xe - Xpn.*sqrt(X1mmhu2p).*XFm_ijp.*(1 - Xdeltam_ijp).*XRlambdap./Xdmhu;	
%
	Xf = XDpm_ij.*Xpn.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./(Xdpnm + Xdpnp);%f0(i-1/2,j-1/2)
	Xf = Xf + XDmp_ij.*Xpn.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./(Xdpnm + Xdpnp);
%
	Xg = XDpm_ij.*Xpn.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./(Xdpnm + Xdpnp);%f0(i+3/2,j+3/2)
	Xg = Xg + XDmp_ij.*Xpn.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./(Xdpnm + Xdpnp);	
%	
	Xh = -XDpm_ij.*Xpn.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./(Xdpnm + Xdpnp);%f0(i-1/2,j+3/2)
	Xh = Xh - XDmp_ij.*Xpn.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./(Xdpnm + Xdpnp);	
%
	Xi = -XDpm_ij.*Xpn.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./(Xdpnm + Xdpnp);%f0(i+3/2,j-1/2)
	Xi = Xi - XDmp_ij.*Xpn.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./(Xdpnm + Xdpnp);
else,%for ftp, first order Drift Kinetic equation
	Xa = - Xpnp.*XDpm_ipj.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./Xdpn;%ftp(i+1/2,j-1/2)
	Xa = Xa + Xpnm.*XDpm_imj.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./Xdpn;
	Xa = Xa - Xpn.*XDmm_ijm.*X1mmhu2m.*XRlambdam./Xdmhu./Xdmhum;
	Xa = Xa - Xpn.*sqrt(X1mmhu2m).*XFm_ijm.*Xdeltam_ijm.*(Xmhum./Xmhumm).*XRlambdam./Xdmhu;
%	
	Xb = -Xpn2m.*XDpp_imj./Xdpn./Xdpnm;%ftp(i-1/2,j+1/2)	
	Xb = Xb - Xpn.*sqrt(X1mmhu2p).*XDmp_ijp.*XRlambdap./Xdmhu./(Xdpnm + Xdpnp);
	Xb = Xb + Xpn.*sqrt(X1mmhu2m).*XDmp_ijm.*XRlambdam./Xdmhu./(Xdpnm + Xdpnp);
	Xb = Xb - Xpn2m.*XFp_imj.*Xdeltap_imj.*(Xpnm./Xpn)./Xdpn;	
%
	Xc = Xpn2p.*XDpp_ipj./Xdpn./Xdpnp;%ftp(i+1/2,j+1/2)
	Xc = Xc + Xpn2p.*XFp_ipj.*Xdeltap_ipj.*(Xpnp./Xpnpp)./Xdpn;
	Xc = Xc + Xpn2m.*XDpp_imj./Xdpn./Xdpnm;
	Xc = Xc - Xpn2m.*XFp_imj.*(1 - Xdeltap_imj).*(Xpnm./Xpn)./Xdpn;
	Xc = Xc + Xpn.*XDmm_ijp.*X1mmhu2p.*XRlambdap./Xdmhu./Xdmhup;	
	Xc = Xc + Xpn.*sqrt(X1mmhu2p).*XFm_ijp.*XRlambdap.*Xdeltam_ijp.*(Xmhup./Xmhu)./Xdmhu;
	Xc = Xc + Xpn.*XDmm_ijm.*X1mmhu2m.*XRlambdam./Xdmhu./Xdmhum;
	Xc = Xc + Xpn.*sqrt(X1mmhu2m).*XFm_ijm.*(1 - Xdeltam_ijm).*(Xmhum./Xmhu).*XRlambdam./Xdmhu;
%
	Xd = - Xpn2p.*XDpp_ipj./Xdpn./Xdpnp;%ftp(i+3/2,j+1/2)
	Xd = Xd + Xpn.*sqrt(X1mmhu2p).*XDmp_ijp.*XRlambdap./Xdmhu./(Xdpnm + Xdpnp);
	Xd = Xd - Xpn.*sqrt(X1mmhu2m).*XDmp_ijm.*XRlambdam./Xdmhu./(Xdpnm + Xdpnp);
	Xd = Xd + Xpn2p.*XFp_ipj.*(1 - Xdeltap_ipj).*(Xpnp./Xpnpp)./Xdpn;	
%
	Xe = Xpnp.*XDpm_ipj.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./Xdpn;%ftp(i+1/2,j+3/2)
	Xe = Xe - Xpnm.*XDpm_imj.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./Xdpn;
	Xe = Xe - Xpn.*XDmm_ijp.*X1mmhu2p.*XRlambdap./Xdmhu./Xdmhup;
	Xe = Xe - Xpn.*sqrt(X1mmhu2p).*XFm_ijp.*(1 - Xdeltam_ijp).*(Xmhup./Xmhupp).*XRlambdap./Xdmhu;	
%
	Xf = XDpm_ij.*Xpn.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./(Xdpnm + Xdpnp);%ftp(i-1/2,j-1/2)
	Xf = Xf + XDmp_ij.*Xpn.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./(Xdpnm + Xdpnp);
%
	Xg = XDpm_ij.*Xpn.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./(Xdpnm + Xdpnp);%ftp(i+3/2,j+3/2)
	Xg = Xg + XDmp_ij.*Xpn.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./(Xdpnm + Xdpnp);	
%	
	Xh = -XDpm_ij.*Xpn.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./(Xdpnm + Xdpnp);%ftp(i-1/2,j+3/2)
	Xh = Xh - XDmp_ij.*Xpn.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./(Xdpnm + Xdpnp);	
%
	Xi = -XDpm_ij.*Xpn.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./(Xdpnm + Xdpnp);%ftp(i+3/2,j-1/2)
	Xi = Xi - XDmp_ij.*Xpn.*sqrt(X1mmhu2)./(Xdmhum + Xdmhup)./(Xdpnm + Xdpnp);
end