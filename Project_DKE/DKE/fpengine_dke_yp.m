function [ZMX,ZMT] = fpengine_dke_yp(ftp_mode,dkeparam,gridDKE,equilDKE,Zdelta,Zbouncecoef,Zcoeffs,Zmripple)
%LUKE - Momentum Fokker-Planck engine for zero (usual FP code) or first order (neoclassical corrections for bootstrap current in ZBW limit).        	   
%
%Momentum Fokker-Planck engine for zero (usual FP code) or first order (neoclassical corrections for bootstrap current in ZBW limit).
%
%	Input:
%
%	Output:
%
%	- ZMX.XX_lijmm   : Matrix coefficient for f0(l+1/2,i+1/2,j-1/2) (was XXa in LUKE 1)
%	- ZMX.XX_limmj   : Matrix coefficient for f0(l+1/2,i-1/2,j+1/2) (was XXb in LUKE 1)
%	- ZMX.XX_lij     : Matrix coefficient for f0(l+1/2,i+1/2,j+1/2) (was XXc in LUKE 1)
%	- ZMX.XX_lippj   : Matrix coefficient for f0(l+1/2,i+3/2,j+1/2) (was XXd in LUKE 1)
%	- ZMX.XX_lijpp   : Matrix coefficient for f0(l+1/2,i+1/2,j+3/2) (was XXe in LUKE 1)
%	- ZMX.XX_limmjmm : Matrix coefficient for f0(l+1/2,i-1/2,j-1/2) (was XXf in LUKE 1)
%	- ZMX.XX_lippjpp : Matrix coefficient for f0(l+1/2,i+3/2,j+3/2) (was XXg in LUKE 1)
%	- ZMX.XX_limmjpp : Matrix coefficient for f0(l+1/2,i-1/2,j+3/2) (was XXh in LUKE 1)
%	- ZMX.XX_lippjmm : Matrix coefficient for f0(l+1/2,i+3/2,j-1/2) (was XXi in LUKE 1)
%
%	- ZMX.XX_lmmijmm : Matrix coefficient for f0(l-1/2,i+1/2,j-1/2) (LUKE 2)
%	- ZMX.XX_lmmij   : Matrix coefficient for f0(l-1/2,i+1/2,j+1/2) (LUKE 2)
%	- ZMX.XX_lppijmm : Matrix coefficient for f0(l+3/2,i+1/2,j-1/2) (LUKE 2)
%	- ZMX.XX_lppij   : Matrix coefficient for f0(l+3/2,i+1/2,j+1/2) (LUKE 2)
%	- ZMX.XX_lmmijpp : Matrix coefficient for f0(l-1/2,i+1/2,j+3/2) (LUKE 2)
%	- ZMX.XX_lppijpp : Matrix coefficient for f0(l+3/2,i+1/2,j+3/2) (LUKE 2)
%	- ZMX.XX_lmmimmj : Matrix coefficient for f0(l-1/2,i-1/2,j+1/2) (LUKE 2)
%	- ZMX.XX_lmmippj : Matrix coefficient for f0(l-1/2,i+3/2,j+1/2) (LUKE 2)
%	- ZMX.XX_lppippj : Matrix coefficient for f0(l+3/2,i+3/2,j+1/2) (LUKE 2)
%	- ZMX.XX_lppimmj : Matrix coefficient for f0(l+3/2,i-1/2,j+1/2) (LUKE 2)
%
%	 Notations: 
%
%       _lmippj    -> (l,i+3/2,j+1/2) or (l,i+++,j+)              (LUKE 2)
%       _lmimmj    -> (l,i-1/2,j+1/2) or (l,i-,j+)                (LUKE 2)
%       _lmijpp    -> (l,i+1/2,j+3/2) or (l,i+,j+++)              (LUKE 2)
%       _lmijmm    -> (l,i+1/2,j-1/2) or (l,i+,j-)                (LUKE 2)
%       _lmij      -> (l,i+1/2,j+1/2) or (l,i+,j+)                (LUKE 2)
%
%       _lpippj    -> (l+1,i+3/2,j+1/2) or (l++,i+++,j+)          (LUKE 2)
%       _lpimmj    -> (l+1,i-1/2,j+1/2) or (l++,i-,j+)            (LUKE 2)
%       _lpijpp    -> (l+1,i+1/2,j+3/2) or (l++,i+,j+++)          (LUKE 2)
%       _lpijmm    -> (l+1,i+1/2,j-1/2) or (l++,i+,j-)            (LUKE 2)
%       _lpij      -> (l+1,i+1/2,j+1/2) or (l++,i+,j+)            (LUKE 2)
%
%       _lppimj    -> (l+3/2,i,j+1/2) or (l+++,i,j+)              (LUKE 2)
%       _lmmimj    -> (l-1/2,i,j+1/2) or (l-,i,j+)                (LUKE 2)
%       _limjpp    -> (l+1/2,i,j+3/2) or (l+,i,j+++)              (LUKE 1+2)
%       _limjmm    -> (l+1/2,i,j-1/2) or (l+,i,j-)                (LUKE 1+2)
%       _limj      -> (l+1/2,i,j+1/2) or (l+,i,j+)                (LUKE 1+2)
%
%       _lppipj    -> (l+3/2,i+1,j+1/2) or (l+++,i++,j+)          (LUKE 2)
%       _lmmipj    -> (l-1/2,i+1,j+1/2) or (l-,i++,j+)            (LUKE 2)
%       _lipjpp    -> (l+1/2,i+1,j+3/2) or (l+,i++,j+++)          (LUKE 1+2)
%       _lipjmm    -> (l+1/2,i+1,j-1/2) or (l+,i++,j-)            (LUKE 1+2)
%       _lipj      -> (l+1/2,i+1,j+1/2) or (l+,i++,j+)            (LUKE 1+2)
%
%       _lppijm    -> (l+3/2,i+1/2,j) or (l+++,i+,j)              (LUKE 2)
%       _lmmijm    -> (l-1/2,i+1/2,j) or (l-,i+,j)                (LUKE 2)
%       _lippjm    -> (l+1/2,i+3/2,j) or (l+,i+++,j)              (LUKE 1+2)
%       _limmjm    -> (l+1/2,i-1/2,j) or (l+,i-,j)                (LUKE 1+2)
%       _lijm      -> (l+1/2,i+1/2,j) or (l+,i+,j)                (LUKE 1+2)
%
%       _lppijp    -> (l+3/2,i+1/2,j+1) or (l+++,i+,j++)          (LUKE 2)
%       _lmmijp    -> (l-1/2,i+1/2,j+1) or (l-,i+,j++)            (LUKE 2)
%       _lippjp    -> (l+1/2,i+3/2,j+1) or (l+,i+++,j++)          (LUKE 1+2)
%       _limmjp    -> (l+1/2,i-1/2,j+1) or (l+,i-,j++)            (LUKE 1+2)
%       _lijp      -> (l+1/2,i+1/2,j+1) or (l+,i+,j++)            (LUKE 1+2)
%
%by Yves Peysson (CEA-IRFM,yves.peysson@cea.fr) and Joan Decker (CEA-IRFM,joan.decker@cea.fr)
%
if nargin < 8,
	error('Wrong number of input arguments in fpengine_dke_yp');
end
%		
if ftp_mode >= 1, ftp_mode = 1;end%Force ftp_mode to be 0 (FP) or 1 (DKE)
%
[XXalphar_lm,XXalphar_lp,XXgradpsin] = alphagradpsi_dke_yp(gridDKE,equilDKE,Zdelta,Zbouncecoef);
%
if ~isfield(dkeparam,'oldcross_mode'),dkeparam.oldcross_mode = 0;end
%
%Centered cross-derivatives 
%
%(as done by M. Shoucri and I. Shkarofsky,Comp. Phys. Comm., 82 (1994) 287
%Same results for LHCD but not very accurate for particle conservation, and
%unstable solution when D// > 1). It is therefore only given for a link
%with the past ! WARNING: IT MUST BE NEVER USED EXCEPT TESTS AND THE
%REFERENCE PUBLICATION OF LUKE
%
ZMX.nodelist = {'lijmm','limmj','lij','lippj','lijpp','limmjmm','lippjpp','limmjpp','lippjmm','lmmijmm','lmmij','lppijmm','lppij','lmmijpp','lppijpp','lmmimmj','lmmippj','lppippj','lppimmj'};%Row denominations
ZMX.node_l = {0,0,0,0,0,0,0,0,0,-1,-1,+1,+1,-1,+1,-1,-1,+1,+1};%Radial dynamics
ZMX.node_i = {0,-1,0,+1,0,-1,+1,-1,+1,0,0,0,0,0,0,-1,+1,+1,-1};%Momentum dynamics
ZMX.node_j = {-1,0,0,0,+1,-1,+1,+1,-1,-1,0,-1,0,+1,+1,0,0,0,0};%Pitch-angle dynamics
%
if dkeparam.oldcross_mode == 1,
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%% MUST BE NEVER USED EXCEPT FOR TESTS THE REFERENCE PUBLICATION OF LUKE %%%%%%%%%%%%%%%%%%%%%%%%%%
    %    
    ZMX.XX_lijmm = - gridDKE.XXpnp.*Zcoeffs.XXDpm_ipj.*sqrt(gridDKE.XX1mmhu2)./(gridDKE.XXdmhum + gridDKE.XXdmhup)./gridDKE.XXdpn;%grid point (l+1/2,i+1/2,j-1/2)
    ZMX.XX_lijmm = ZMX.XX_lijmm + gridDKE.XXpnm.*Zcoeffs.XXDpm_imj.*sqrt(gridDKE.XX1mmhu2)./(gridDKE.XXdmhum + gridDKE.XXdmhup)./gridDKE.XXdpn;
    ZMX.XX_lijmm = ZMX.XX_lijmm - Zcoeffs.XXDmm_ijm.*gridDKE.XX1mmhu2m.*Zbouncecoef.XXRlambda_m./gridDKE.XXdmhu./gridDKE.XXdmhum;
    ZMX.XX_lijmm = ZMX.XX_lijmm + gridDKE.XXpn.*sqrt(gridDKE.XX1mmhu2m).*Zcoeffs.XXFm_ijm.*Zdelta.XXdeltam_lijm.*(gridDKE.XXmhum./gridDKE.XXmhumm).^ftp_mode.*Zbouncecoef.XXRlambda_m./gridDKE.XXdmhu;
    %	
    ZMX.XX_limmj = -gridDKE.XXpn2m.*Zcoeffs.XXDpp_imj./gridDKE.XXdpn./gridDKE.XXdpnm;%grid point (l+1/2,i-1/2,j+1/2)	
    ZMX.XX_limmj = ZMX.XX_limmj - gridDKE.XXpn.*sqrt(gridDKE.XX1mmhu2p).*Zcoeffs.XXDmp_ijp.*Zbouncecoef.XXRlambda_p./gridDKE.XXdmhu./(gridDKE.XXdpnm + gridDKE.XXdpnp);
    ZMX.XX_limmj = ZMX.XX_limmj + gridDKE.XXpn.*sqrt(gridDKE.XX1mmhu2m).*Zcoeffs.XXDmp_ijm.*Zbouncecoef.XXRlambda_m./gridDKE.XXdmhu./(gridDKE.XXdpnm + gridDKE.XXdpnp);
    ZMX.XX_limmj = ZMX.XX_limmj - gridDKE.XXpn2m.*Zcoeffs.XXFp_imj.*Zdelta.XXdeltap_limj.*(gridDKE.XXpnm./gridDKE.XXpnmm).^ftp_mode./gridDKE.XXdpn;	
    %
    ZMX.XX_lij = gridDKE.XXpn2p.*Zcoeffs.XXDpp_ipj./gridDKE.XXdpn./gridDKE.XXdpnp;%grid point (l+1/2,i+1/2,j+1/2)
    ZMX.XX_lij = ZMX.XX_lij + gridDKE.XXpn2p.*Zcoeffs.XXFp_ipj.*Zdelta.XXdeltap_lipj.*(gridDKE.XXpnp./gridDKE.XXpn).^ftp_mode./gridDKE.XXdpn;
    ZMX.XX_lij = ZMX.XX_lij + gridDKE.XXpn2m.*Zcoeffs.XXDpp_imj./gridDKE.XXdpn./gridDKE.XXdpnm;
    ZMX.XX_lij = ZMX.XX_lij - gridDKE.XXpn2m.*Zcoeffs.XXFp_imj.*(1 - Zdelta.XXdeltap_limj).*(gridDKE.XXpnm./gridDKE.XXpn).^ftp_mode./gridDKE.XXdpn;
    ZMX.XX_lij = ZMX.XX_lij + Zcoeffs.XXDmm_ijp.*gridDKE.XX1mmhu2p.*Zbouncecoef.XXRlambda_p./gridDKE.XXdmhu./gridDKE.XXdmhup;	
    ZMX.XX_lij = ZMX.XX_lij - gridDKE.XXpn.*sqrt(gridDKE.XX1mmhu2p).*Zcoeffs.XXFm_ijp.*Zbouncecoef.XXRlambda_p.*Zdelta.XXdeltam_lijp.*(Xmhup./Xmhu).^ftp_mode./gridDKE.XXdmhu;
    ZMX.XX_lij = ZMX.XX_lij + Zcoeffs.XXDmm_ijm.*gridDKE.XX1mmhu2m.*Zbouncecoef.XXRlambda_m./gridDKE.XXdmhu./gridDKE.XXdmhum;
    ZMX.XX_lij = ZMX.XX_lij + gridDKE.XXpn.*sqrt(gridDKE.XX1mmhu2m).*Zcoeffs.XXFm_ijm.*(1 - Zdelta.XXdeltam_lijm).*(Xmhum./Xmhu).^ftp_mode.*Zbouncecoef.XXRlambda_m./gridDKE.XXdmhu;
    %
    ZMX.XX_lippj = - gridDKE.XXpn2p.*Zcoeffs.XXDpp_ipj./gridDKE.XXdpn./gridDKE.XXdpnp;%grid point (l+1/2,i+3/2,j+1/2)
    ZMX.XX_lippj = ZMX.XX_lippj + gridDKE.XXpn.*sqrt(gridDKE.XX1mmhu2p).*Zcoeffs.XXDmp_ijp.*Zbouncecoef.XXRlambda_p./gridDKE.XXdmhu./(gridDKE.XXdpnm + gridDKE.XXdpnp);
    ZMX.XX_lippj = ZMX.XX_lippj - gridDKE.XXpn.*sqrt(gridDKE.XX1mmhu2m).*Zcoeffs.XXDmp_ijm.*Zbouncecoef.XXRlambda_m./gridDKE.XXdmhu./(gridDKE.XXdpnm + gridDKE.XXdpnp);
    ZMX.XX_lippj = ZMX.XX_lippj + gridDKE.XXpn2p.*Zcoeffs.XXFp_ipj.*(1 - Zdelta.XXdeltap_lipj).*(gridDKE.XXpnp./gridDKE.XXpnpp).^ftp_mode./gridDKE.XXdpn;	
    %
    ZMX.XX_lijpp = gridDKE.XXpnp.*Zcoeffs.XXDpm_ipj.*sqrt(gridDKE.XX1mmhu2)./(gridDKE.XXdmhum + gridDKE.XXdmhup)./gridDKE.XXdpn;%grid point (l+1/2,i+1/2,j+3/2)
    ZMX.XX_lijpp = ZMX.XX_lijpp - gridDKE.XXpnm.*Zcoeffs.XXDpm_imj.*sqrt(gridDKE.XX1mmhu2)./(gridDKE.XXdmhum + gridDKE.XXdmhup)./gridDKE.XXdpn;
    ZMX.XX_lijpp = ZMX.XX_lijpp - Zcoeffs.XXDmm_ijp.*gridDKE.XX1mmhu2p.*Zbouncecoef.XXRlambda_p./gridDKE.XXdmhu./gridDKE.XXdmhup;
    ZMX.XX_lijpp = ZMX.XX_lijpp - gridDKE.XXpn.*sqrt(gridDKE.XX1mmhu2p).*Zcoeffs.XXFm_ijp.*(1 - Zdelta.XXdeltam_lijp).*(Xmhup./Xmhupp).^ftp_mode.*Zbouncecoef.XXRlambda_p./gridDKE.XXdmhu;	
    %
    ZMX.XX_limmjmm = Zcoeffs.XXDpm_ij.*gridDKE.XXpn.*sqrt(gridDKE.XX1mmhu2)./(gridDKE.XXdmhum + gridDKE.XXdmhup)./(gridDKE.XXdpnm + gridDKE.XXdpnp);%grid point (l+1/2,i-1/2,j-1/2)
    ZMX.XX_limmjmm = ZMX.XX_limmjmm + Zcoeffs.XXDmp_ij.*gridDKE.XXpn.*sqrt(gridDKE.XX1mmhu2)./(gridDKE.XXdmhum + gridDKE.XXdmhup)./(gridDKE.XXdpnm + gridDKE.XXdpnp);
    %
    ZMX.XX_lippjpp = ZMX.XX_limmjmm;%grid point (l+1/2,i+3/2,j+3/2)
    %	
    ZMX.XX_limmjpp = -Zcoeffs.XXDpm_ij.*gridDKE.XXpn.*sqrt(gridDKE.XX1mmhu2)./(gridDKE.XXdmhum + gridDKE.XXdmhup)./(gridDKE.XXdpnm + gridDKE.XXdpnp);%grid point (l+1/2,i-1/2,j+3/2)
    ZMX.XX_limmjpp = ZMX.XX_limmjpp - Zcoeffs.XXDmp_ij.*gridDKE.XXpn.*sqrt(gridDKE.XX1mmhu2)./(gridDKE.XXdmhum + gridDKE.XXdmhup)./(gridDKE.XXdpnm + gridDKE.XXdpnp);	
    %
    ZMX.XX_lippjmm = ZMX.XX_limmjpp;%grid point (l+1/2,i+3/2,j-1/2)
    %
elseif dkeparam.oldcross_mode == 0,%************ Must be always used **************
    %
    % Cross derivatives with exact boundary conditions (WARNING: MUST BE
    % ALWAYS USED)
    %
    ZMX.XX_lijmm = - gridDKE.XXpnp.*Zcoeffs.XXDpm_ipj.*sqrt(gridDKE.XX1mmhu2).*Zdelta.XXdeltap_lipjmm./(gridDKE.XXdmhum + gridDKE.XXdmhup)./gridDKE.XXdpn;%grid point (l+1/2,i+1/2,j-1/2)
    ZMX.XX_lijmm = ZMX.XX_lijmm + gridDKE.XXpnm.*Zcoeffs.XXDpm_imj.*sqrt(gridDKE.XX1mmhu2).*(1 - Zdelta.XXdeltap_limjmm)./(gridDKE.XXdmhum + gridDKE.XXdmhup)./gridDKE.XXdpn;
    ZMX.XX_lijmm = ZMX.XX_lijmm - Zcoeffs.XXDmm_ijm.*gridDKE.XX1mmhu2m.*Zbouncecoef.XXRlambda_m./gridDKE.XXdmhu./gridDKE.XXdmhum;
    ZMX.XX_lijmm = ZMX.XX_lijmm + gridDKE.XXpn.*sqrt(gridDKE.XX1mmhu2m).*Zcoeffs.XXFm_ijm.*Zdelta.XXdeltam_lijm.*(gridDKE.XXmhum./gridDKE.XXmhumm).^ftp_mode.*Zbouncecoef.XXRlambda_m./gridDKE.XXdmhu;
    ZMX.XX_lijmm = ZMX.XX_lijmm - gridDKE.XXpn.*XXalphar_lp.*XXgradpsin.*sqrt(gridDKE.XX1mmhu2).*Zdelta.XXdeltar_lpijmm.*Zcoeffs.XXDrm_lp./(gridDKE.XXdmhum + gridDKE.XXdmhup)./gridDKE.XXdpsin_dke;
    ZMX.XX_lijmm = ZMX.XX_lijmm + gridDKE.XXpn.*XXalphar_lm.*XXgradpsin.*sqrt(gridDKE.XX1mmhu2).*(1 - Zdelta.XXdeltar_lmijmm).*Zcoeffs.XXDrm_lm./(gridDKE.XXdmhum + gridDKE.XXdmhup)./gridDKE.XXdpsin_dke;
    %	
    ZMX.XX_limmj = -gridDKE.XXpn2m.*Zcoeffs.XXDpp_imj./gridDKE.XXdpn./gridDKE.XXdpnm;%grid point (l+1/2,i-1/2,j+1/2)
    ZMX.XX_limmj = ZMX.XX_limmj - gridDKE.XXpn.*sqrt(gridDKE.XX1mmhu2p).*Zcoeffs.XXDmp_ijp.*Zbouncecoef.XXRlambda_p.*Zdelta.XXdeltam_limmjp./gridDKE.XXdmhu./(gridDKE.XXdpnm + gridDKE.XXdpnp);
    ZMX.XX_limmj = ZMX.XX_limmj + gridDKE.XXpn.*sqrt(gridDKE.XX1mmhu2m).*Zcoeffs.XXDmp_ijm.*Zbouncecoef.XXRlambda_m.*(1 - Zdelta.XXdeltam_limmjm)./gridDKE.XXdmhu./(gridDKE.XXdpnm + gridDKE.XXdpnp);
    ZMX.XX_limmj = ZMX.XX_limmj - gridDKE.XXpn2m.*Zcoeffs.XXFp_imj.*Zdelta.XXdeltap_limj.*(gridDKE.XXpnm./gridDKE.XXpnmm).^ftp_mode./gridDKE.XXdpn;	
    ZMX.XX_limmj = ZMX.XX_limmj + gridDKE.XXpn2.*XXalphar_lp.*XXgradpsin.*Zdelta.XXdeltar_lpimmj.*Zcoeffs.XXDrp_lp./gridDKE.XXdpsin_dke./(gridDKE.XXdpnm + gridDKE.XXdpnp);
    ZMX.XX_limmj = ZMX.XX_limmj - gridDKE.XXpn2.*XXalphar_lm.*XXgradpsin.*(1 - Zdelta.XXdeltar_lmimmj).*Zcoeffs.XXDrp_lm./gridDKE.XXdpsin_dke./(gridDKE.XXdpnm + gridDKE.XXdpnp);
    %
    ZMX.XX_lij = gridDKE.XXpn2p.*Zcoeffs.XXDpp_ipj./gridDKE.XXdpn./gridDKE.XXdpnp;%grid point (l+1/2,i+1/2,j+1/2)
    ZMX.XX_lij = ZMX.XX_lij + gridDKE.XXpn2p.*Zcoeffs.XXFp_ipj.*Zdelta.XXdeltap_lipj.*(gridDKE.XXpnp./gridDKE.XXpn).^ftp_mode./gridDKE.XXdpn;
    ZMX.XX_lij = ZMX.XX_lij + gridDKE.XXpn2m.*Zcoeffs.XXDpp_imj./gridDKE.XXdpn./gridDKE.XXdpnm;
    ZMX.XX_lij = ZMX.XX_lij - gridDKE.XXpn2m.*Zcoeffs.XXFp_imj.*(1 - Zdelta.XXdeltap_limj).*(gridDKE.XXpnm./gridDKE.XXpn).^ftp_mode./gridDKE.XXdpn;
    ZMX.XX_lij = ZMX.XX_lij + Zcoeffs.XXDmm_ijp.*gridDKE.XX1mmhu2p.*Zbouncecoef.XXRlambda_p./gridDKE.XXdmhu./gridDKE.XXdmhup;	
    ZMX.XX_lij = ZMX.XX_lij - gridDKE.XXpn.*sqrt(gridDKE.XX1mmhu2p).*Zcoeffs.XXFm_ijp.*Zbouncecoef.XXRlambda_p.*Zdelta.XXdeltam_lijp.*(gridDKE.XXmhup./gridDKE.XXmhu).^ftp_mode./gridDKE.XXdmhu;
    ZMX.XX_lij = ZMX.XX_lij + Zcoeffs.XXDmm_ijm.*gridDKE.XX1mmhu2m.*Zbouncecoef.XXRlambda_m./gridDKE.XXdmhu./gridDKE.XXdmhum;
    ZMX.XX_lij = ZMX.XX_lij + gridDKE.XXpn.*sqrt(gridDKE.XX1mmhu2m).*Zcoeffs.XXFm_ijm.*(1 - Zdelta.XXdeltam_lijm).*(gridDKE.XXmhum./gridDKE.XXmhu).^ftp_mode.*Zbouncecoef.XXRlambda_m./gridDKE.XXdmhu;
    ZMX.XX_lij = ZMX.XX_lij + gridDKE.XXpn2.*XXalphar_lp.*XXgradpsin.*Zdelta.XXdeltar_lpij.*Zcoeffs.XXFr_lp./gridDKE.XXdpsin_dke;
    ZMX.XX_lij = ZMX.XX_lij + gridDKE.XXpn2.*XXalphar_lp.*XXgradpsin.*Zcoeffs.XXDrr_lp./gridDKE.XXdpsin_dke./gridDKE.XXdpsinp_dke;
    ZMX.XX_lij = ZMX.XX_lij - gridDKE.XXpn2.*XXalphar_lm.*XXgradpsin.*(1 - Zdelta.XXdeltar_lmij).*Zcoeffs.XXFr_lm./gridDKE.XXdpsin_dke;
    ZMX.XX_lij = ZMX.XX_lij + gridDKE.XXpn2.*XXalphar_lm.*XXgradpsin.*Zcoeffs.XXDrr_lm./gridDKE.XXdpsin_dke./gridDKE.XXdpsinm_dke;    
    %
    ZMX.XX_lippj = - gridDKE.XXpn2p.*Zcoeffs.XXDpp_ipj./gridDKE.XXdpn./gridDKE.XXdpnp;%grid point (l+1/2,i+3/2,j+1/2)
    ZMX.XX_lippj = ZMX.XX_lippj + gridDKE.XXpn.*sqrt(gridDKE.XX1mmhu2p).*Zcoeffs.XXDmp_ijp.*Zbouncecoef.XXRlambda_p.*Zdelta.XXdeltam_lippjp./gridDKE.XXdmhu./(gridDKE.XXdpnm + gridDKE.XXdpnp);
    ZMX.XX_lippj = ZMX.XX_lippj - gridDKE.XXpn.*sqrt(gridDKE.XX1mmhu2m).*Zcoeffs.XXDmp_ijm.*Zbouncecoef.XXRlambda_m.*(1 - Zdelta.XXdeltam_lippjm)./gridDKE.XXdmhu./(gridDKE.XXdpnm + gridDKE.XXdpnp);
    ZMX.XX_lippj = ZMX.XX_lippj + gridDKE.XXpn2p.*Zcoeffs.XXFp_ipj.*(1 - Zdelta.XXdeltap_lipj).*(gridDKE.XXpnp./gridDKE.XXpnpp).^ftp_mode./gridDKE.XXdpn;	
    ZMX.XX_lippj = ZMX.XX_lippj - gridDKE.XXpn2.*XXalphar_lp.*XXgradpsin.*Zdelta.XXdeltar_lpippj.*Zcoeffs.XXDrp_lp./gridDKE.XXdpsin_dke./(gridDKE.XXdpnm + gridDKE.XXdpnp);
    ZMX.XX_lippj = ZMX.XX_lippj + gridDKE.XXpn2.*XXalphar_lm.*XXgradpsin.*(1 - Zdelta.XXdeltar_lmippj).*Zcoeffs.XXDrp_lm./gridDKE.XXdpsin_dke./(gridDKE.XXdpnm + gridDKE.XXdpnp);
    %
    ZMX.XX_lijpp = gridDKE.XXpnp.*Zcoeffs.XXDpm_ipj.*sqrt(gridDKE.XX1mmhu2).*Zdelta.XXdeltap_lipjpp./(gridDKE.XXdmhum + gridDKE.XXdmhup)./gridDKE.XXdpn;%grid point (l+1/2,i+1/2,j+3/2)
    ZMX.XX_lijpp = ZMX.XX_lijpp - gridDKE.XXpnm.*Zcoeffs.XXDpm_imj.*sqrt(gridDKE.XX1mmhu2).*(1 - Zdelta.XXdeltap_limjpp)./(gridDKE.XXdmhum + gridDKE.XXdmhup)./gridDKE.XXdpn;
    ZMX.XX_lijpp = ZMX.XX_lijpp - Zcoeffs.XXDmm_ijp.*gridDKE.XX1mmhu2p.*Zbouncecoef.XXRlambda_p./gridDKE.XXdmhu./gridDKE.XXdmhup;
    ZMX.XX_lijpp = ZMX.XX_lijpp - gridDKE.XXpn.*sqrt(gridDKE.XX1mmhu2p).*Zcoeffs.XXFm_ijp.*(1 - Zdelta.XXdeltam_lijp).*(gridDKE.XXmhup./gridDKE.XXmhupp).^ftp_mode.*Zbouncecoef.XXRlambda_p./gridDKE.XXdmhu;	
    ZMX.XX_lijpp = ZMX.XX_lijpp + gridDKE.XXpn.*XXalphar_lp.*XXgradpsin.*sqrt(gridDKE.XX1mmhu2).*Zdelta.XXdeltar_lpijpp.*Zcoeffs.XXDrm_lp./(gridDKE.XXdmhum + gridDKE.XXdmhup)./gridDKE.XXdpsin_dke;
    ZMX.XX_lijpp = ZMX.XX_lijpp - gridDKE.XXpn.*XXalphar_lm.*XXgradpsin.*sqrt(gridDKE.XX1mmhu2).*(1 - Zdelta.XXdeltar_lmijpp).*Zcoeffs.XXDrm_lm./(gridDKE.XXdmhum + gridDKE.XXdmhup)./gridDKE.XXdpsin_dke;
    %
    ZMX.XX_limmjmm = Zcoeffs.XXDpm_imj.*gridDKE.XXpnm.*sqrt(gridDKE.XX1mmhu2).*Zdelta.XXdeltap_limjmm./(gridDKE.XXdmhum + gridDKE.XXdmhup)./gridDKE.XXdpn;%grid point (l+1/2,i-1/2,j-1/2)
    ZMX.XX_limmjmm = ZMX.XX_limmjmm + Zcoeffs.XXDmp_ijm.*gridDKE.XXpn.*sqrt(gridDKE.XX1mmhu2m).*Zbouncecoef.XXRlambda_m.*Zdelta.XXdeltam_limmjm./gridDKE.XXdmhu./(gridDKE.XXdpnm + gridDKE.XXdpnp);
    %
    ZMX.XX_lippjpp = Zcoeffs.XXDpm_ipj.*gridDKE.XXpnp.*sqrt(gridDKE.XX1mmhu2).*(1 - Zdelta.XXdeltap_lipjpp)./(gridDKE.XXdmhum + gridDKE.XXdmhup)./gridDKE.XXdpn;%grid point (l+1/2,i+3/2,j+3/2)
    ZMX.XX_lippjpp = ZMX.XX_lippjpp + Zcoeffs.XXDmp_ijp.*gridDKE.XXpn.*sqrt(gridDKE.XX1mmhu2p).*Zbouncecoef.XXRlambda_p.*(1 - Zdelta.XXdeltam_lippjp)./gridDKE.XXdmhu./(gridDKE.XXdpnm + gridDKE.XXdpnp);
    %	
    ZMX.XX_limmjpp = -Zcoeffs.XXDpm_imj.*gridDKE.XXpnm.*sqrt(gridDKE.XX1mmhu2).*Zdelta.XXdeltap_limjpp./(gridDKE.XXdmhum + gridDKE.XXdmhup)./gridDKE.XXdpn;%grid point (l+1/2,i-1/2,j+3/2) OK
    ZMX.XX_limmjpp = ZMX.XX_limmjpp - Zcoeffs.XXDmp_ijp.*gridDKE.XXpn.*sqrt(gridDKE.XX1mmhu2p).*Zbouncecoef.XXRlambda_p.*(1 - Zdelta.XXdeltam_limmjp)./gridDKE.XXdmhu./(gridDKE.XXdpnm + gridDKE.XXdpnp);	
    %
    ZMX.XX_lippjmm = -Zcoeffs.XXDpm_ipj.*gridDKE.XXpnp.*sqrt(gridDKE.XX1mmhu2).*(1 - Zdelta.XXdeltap_lipjmm)./(gridDKE.XXdmhum + gridDKE.XXdmhup)./gridDKE.XXdpn;%grid point (l+1/2,i+3/2,j-1/2)
    ZMX.XX_lippjmm = ZMX.XX_lippjmm - Zcoeffs.XXDmp_ijm.*gridDKE.XXpn.*sqrt(gridDKE.XX1mmhu2m).*Zbouncecoef.XXRlambda_m.*Zdelta.XXdeltam_lippjm./gridDKE.XXdmhu./(gridDKE.XXdpnm + gridDKE.XXdpnp);
end
%
ZMX.XX_lmmijmm = gridDKE.XXpn.*XXgradpsin.*Zbouncecoef.XXRlambda_m.*sqrt(gridDKE.XX1mmhu2m).*Zdelta.XXdeltam_lmmijp.*Zcoeffs.XXDmr_ijm./gridDKE.XXdmhu./(gridDKE.XXdpsinm_dke + gridDKE.XXdpsinp_dke);
ZMX.XX_lmmijmm = ZMX.XX_lmmijmm + gridDKE.XXpn.*XXalphar_lm.*XXgradpsin.*sqrt(gridDKE.XX1mmhu2).*Zdelta.XXdeltar_lmijmm.*Zcoeffs.XXDrm_lm./(gridDKE.XXdmhum + gridDKE.XXdmhup)./gridDKE.XXdpsin_dke; 
%
ZMX.XX_lmmij   = -gridDKE.XXpn2.*XXalphar_lm.*XXgradpsin.*Zdelta.XXdeltar_lmij.*Zcoeffs.XXFr_lm./gridDKE.XXdpsin_dke;
ZMX.XX_lmmij   = ZMX.XX_lmmij - gridDKE.XXpn2.*XXalphar_lm.*XXgradpsin.*Zcoeffs.XXDrr_lm./gridDKE.XXdpsin_dke./gridDKE.XXdpsinm_dke;
ZMX.XX_lmmij   = ZMX.XX_lmmij + gridDKE.XXpn.*XXgradpsin.*Zbouncecoef.XXRlambda_m.*sqrt(gridDKE.XX1mmhu2m).*(1 - Zdelta.XXdeltam_lmmijm).*Zcoeffs.XXDmr_ijm./gridDKE.XXdmhu./(gridDKE.XXdpsinm_dke + gridDKE.XXdpsinp_dke);
ZMX.XX_lmmij   = ZMX.XX_lmmij - gridDKE.XXpn.*XXgradpsin.*Zbouncecoef.XXRlambda_p.*sqrt(gridDKE.XX1mmhu2p).*Zdelta.XXdeltam_lmmijp.*Zcoeffs.XXDmr_ijp./gridDKE.XXdmhu./(gridDKE.XXdpsinm_dke + gridDKE.XXdpsinp_dke);
ZMX.XX_lmmij   = ZMX.XX_lmmij - gridDKE.XXpn2.*XXgradpsin.*(1 - Zdelta.XXdeltap_lmmimj).*Zcoeffs.XXDpr_imj./gridDKE.XXdpn./(gridDKE.XXdpsinm_dke + gridDKE.XXdpsinp_dke);
ZMX.XX_lmmij   = ZMX.XX_lmmij + gridDKE.XXpn2.*XXgradpsin.*Zdelta.XXdeltap_lmmipj.*Zcoeffs.XXDpr_ipj./gridDKE.XXdpn./(gridDKE.XXdpsinm_dke + gridDKE.XXdpsinp_dke);
%
ZMX.XX_lppijmm = -gridDKE.XXpn.*XXalphar_lp.*XXgradpsin.*sqrt(gridDKE.XX1mmhu2).*(1 - Zdelta.XXdeltar_lpijmm).*Zcoeffs.XXDrm_lp./(gridDKE.XXdmhum + gridDKE.XXdmhup)./gridDKE.XXdpsin_dke;
ZMX.XX_lppijmm = ZMX.XX_lppijmm - gridDKE.XXpn.*XXgradpsin.*Zbouncecoef.XXRlambda_m.*sqrt(gridDKE.XX1mmhu2m).*Zdelta.XXdeltam_lppijm.*Zcoeffs.XXDmr_ijm./gridDKE.XXdmhu./(gridDKE.XXdpsinm_dke + gridDKE.XXdpsinp_dke);
%
ZMX.XX_lppij   = gridDKE.XXpn2.*XXalphar_lp.*XXgradpsin.*(1 - Zdelta.XXdeltar_lpij).*Zcoeffs.XXFr_lp./gridDKE.XXdpsin_dke;
ZMX.XX_lppij   = ZMX.XX_lppij - gridDKE.XXpn2.*XXalphar_lm.*XXgradpsin.*Zcoeffs.XXDrr_lp./gridDKE.XXdpsin_dke./gridDKE.XXdpsinp_dke;
ZMX.XX_lppij   = ZMX.XX_lppij - gridDKE.XXpn2p.*XXgradpsin.*Zdelta.XXdeltap_lppipj.*Zcoeffs.XXDpr_ipj./gridDKE.XXdpnp./(gridDKE.XXdpsinm_dke + gridDKE.XXdpsinp_dke);
ZMX.XX_lppij   = ZMX.XX_lppij + gridDKE.XXpn2.*XXgradpsin.*(1 - Zdelta.XXdeltap_lppimj).*Zcoeffs.XXDpr_imj./gridDKE.XXdpn./(gridDKE.XXdpsinm_dke + gridDKE.XXdpsinp_dke);
ZMX.XX_lppij   = ZMX.XX_lppij + gridDKE.XXpn.*XXgradpsin.*Zbouncecoef.XXRlambda_p.*sqrt(gridDKE.XX1mmhu2p).*Zdelta.XXdeltam_lppijp.*Zcoeffs.XXDmr_ijp./gridDKE.XXdmhu./(gridDKE.XXdpsinm_dke + gridDKE.XXdpsinp_dke);
ZMX.XX_lppij   = ZMX.XX_lppij - gridDKE.XXpn.*XXgradpsin.*Zbouncecoef.XXRlambda_m.*sqrt(gridDKE.XX1mmhu2m).*(1 - Zdelta.XXdeltam_lppijm).*Zcoeffs.XXDmr_ijm./gridDKE.XXdmhu./(gridDKE.XXdpsinm_dke + gridDKE.XXdpsinp_dke); 
%
ZMX.XX_lmmijpp = gridDKE.XXpn.*XXalphar_lm.*XXgradpsin.*sqrt(gridDKE.XX1mmhu2).*Zdelta.XXdeltar_lmijpp.*Zcoeffs.XXDrm_lm./(gridDKE.XXdmhum + gridDKE.XXdmhup)./gridDKE.XXdpsin_dke;
ZMX.XX_lmmijpp = ZMX.XX_lmmijpp + gridDKE.XXpn.*XXgradpsin.*Zbouncecoef.XXRlambda_p.*sqrt(gridDKE.XX1mmhu2p).*(1 - Zdelta.XXdeltam_lmmijp).*Zcoeffs.XXDmr_ijp./gridDKE.XXdmhu./(gridDKE.XXdpsinm_dke + gridDKE.XXdpsinp_dke); 
%
ZMX.XX_lppijpp = -gridDKE.XXpn.*XXalphar_lp.*XXgradpsin.*sqrt(gridDKE.XX1mmhu2).*(1 - Zdelta.XXdeltar_lpijpp).*Zcoeffs.XXDrm_lp./(gridDKE.XXdmhum + gridDKE.XXdmhup)./gridDKE.XXdpsin_dke;
ZMX.XX_lppijpp = ZMX.XX_lppijpp - gridDKE.XXpn.*XXgradpsin.*Zbouncecoef.XXRlambda_p.*sqrt(gridDKE.XX1mmhu2p).*(1 - Zdelta.XXdeltam_lppijp).*Zcoeffs.XXDmr_ijp./gridDKE.XXdmhu./(gridDKE.XXdpsinm_dke + gridDKE.XXdpsinp_dke); 
%
ZMX.XX_lmmimmj = -gridDKE.XXpn2.*XXalphar_lm.*XXgradpsin.*Zdelta.XXdeltar_lmimmj.*Zcoeffs.XXDrp_lm./gridDKE.XXdpsin_dke./(gridDKE.XXdpnm + gridDKE.XXdpnp);
ZMX.XX_lmmimmj = ZMX.XX_lmmimmj - gridDKE.XXpn2.*XXgradpsin.*Zdelta.XXdeltap_lmmimj.*Zcoeffs.XXDpr_imj./gridDKE.XXdpn./(gridDKE.XXdpsinm_dke + gridDKE.XXdpsinp_dke);
%
ZMX.XX_lmmippj = gridDKE.XXpn2.*XXalphar_lm.*XXgradpsin.*Zdelta.XXdeltar_lmippj.*Zcoeffs.XXDrp_lm./gridDKE.XXdpsin_dke./(gridDKE.XXdpnm + gridDKE.XXdpnp);
ZMX.XX_lmmippj = ZMX.XX_lmmippj + gridDKE.XXpn2.*XXgradpsin.*(1 - Zdelta.XXdeltap_lmmipj).*Zcoeffs.XXDpr_ipj./gridDKE.XXdpn./(gridDKE.XXdpsinm_dke + gridDKE.XXdpsinp_dke); 
%
ZMX.XX_lppippj = -gridDKE.XXpn2.*XXalphar_lp.*XXgradpsin.*(1 - Zdelta.XXdeltar_lpippj).*Zcoeffs.XXDrp_lp./gridDKE.XXdpsin_dke./(gridDKE.XXdpnm + gridDKE.XXdpnp);
ZMX.XX_lppippj = ZMX.XX_lppippj - gridDKE.XXpn2.*XXgradpsin.*(1 - Zdelta.XXdeltap_lppipj).*Zcoeffs.XXDpr_ipj./gridDKE.XXdpn./(gridDKE.XXdpsinm_dke + gridDKE.XXdpsinp_dke);
%
ZMX.XX_lppimmj = gridDKE.XXpn2.*XXalphar_lp.*XXgradpsin.*(1 - Zdelta.XXdeltar_lpimmj).*Zcoeffs.XXDrp_lp./gridDKE.XXdpsin_dke./(gridDKE.XXdpnm + gridDKE.XXdpnp);
ZMX.XX_lppimmj = ZMX.XX_lppimmj + gridDKE.XXpn2.*XXgradpsin.*Zdelta.XXdeltap_lppimj.*Zcoeffs.XXDpr_imj./gridDKE.XXdpn./(gridDKE.XXdpsinm_dke + gridDKE.XXdpsinp_dke);
%
%Sink and source coefficients like magnetic ripple losses,described by a Krook term
%
ZMX.XX_lppij = ZMX.XX_lppij +  Zmripple.XXlossripple.*gridDKE.XXpn2;
%
%Time coefficients
%
ZMT = 0;


