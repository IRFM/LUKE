function [ZXXD_c_tp_pp_ippj,ZXXD_c_tp_pp_ipj,ZXXD_c_tp_pp_ij,ZXXD_c_tp_pp_imj,ZXXD_c_tp_pp_immj,ZXXD_c_tp_mm_ijp,ZXXD_c_tp_mm_ijm,ZXXF_c_tp_p_ippj,ZXXF_c_tp_p_ipj,ZXXF_c_tp_p_ij,ZXXF_c_tp_p_im,ZXXF_c_tp_p_immj,ZXXF_c_tp_m_ijp,ZXXF_c_tp_m_ijm] = loop_coll_dke_jd2(ir,gridDKE,Zbouncecoef,ZXXD_c,dkepath,dkeparam)
%LUKE - Collision operator for first order correction (loop function for distributed computing environment)
%
%Collision operator for first order correction (loop function for distributed computing environment)
%
%by Yves Peysson (CEA-IRFM,yves.peysson@cea.fr) and Joan Decker (CEA-IRFM,joan.decker@cea.fr) 
%
%Relativistic Maxwellian distribution function normalized to the local density
	%
	% Collisions flux coefficients calculations for ftp 
	%
    ir_dke = find(ir == gridDKE.rdke);
    if ~isempty(ir_dke)
		%        
    	ZXXD_c_tp_pp_ippj = ZXXD_c.pp_ippj.*Zbouncecoef.XXRlambda_b_p1m1(:,:,ir);
    	ZXXD_c_tp_pp_ipj = ZXXD_c.pp_ipj.*Zbouncecoef.XXRlambda_b_p1m1(:,:,ir);
    	ZXXD_c_tp_pp_ij = ZXXD_c.pp_ij.*Zbouncecoef.XXRlambda_b_p1m1(:,:,ir);
    	ZXXD_c_tp_pp_imj = ZXXD_c.pp_imj.*Zbouncecoef.XXRlambda_b_p1m1(:,:,ir);
    	ZXXD_c_tp_pp_immj = ZXXD_c.pp_immj.*Zbouncecoef.XXRlambda_b_p1m1(:,:,ir);
    	ZXXD_c_tp_mm_ijp = ZXXD_c.mm_ijp.*Zbouncecoef.XXRlambda_b_p3m2_p(:,:,ir)./Zbouncecoef.XXRlambda_p2m1_p(:,:,ir);
    	ZXXD_c_tp_mm_ijm = ZXXD_c.mm_ijm.*Zbouncecoef.XXRlambda_b_p3m2_m(:,:,ir)./Zbouncecoef.XXRlambda_p2m1_m(:,:,ir);
		%
    	ZXXF_c_tp_p_ippj = ZXXF_c.p_ippj.*Zbouncecoef.XXRlambda_b_p1m1(:,:,ir);
    	ZXXF_c_tp_p_ipj = ZXXF_c.p_ipj.*Zbouncecoef.XXRlambda_b_p1m1(:,:,ir);
    	ZXXF_c_tp_p_ij = ZXXF_c.p_ij.*Zbouncecoef.XXRlambda_b_p1m1(:,:,ir);
    	ZXXF_c_tp_p_im = ZXXF_c.p_imj.*Zbouncecoef.XXRlambda_b_p1m1(:,:,ir);
    	ZXXF_c_tp_p_immj = ZXXF_c.p_immj.*Zbouncecoef.XXRlambda_b_p1m1(:,:,ir);  
    	ZXXF_c_tp_m_ijp = (ZXXD_c.mm_ijp./Zbouncecoef.XXRlambda_p2m1_p(:,:,ir)).*(Zbouncecoef.XXRlambda_b_p1m1_p(:,:,ir) - Zbouncecoef.XXRlambda_b_p1m2_p(:,:,ir)).*sqrt(gridDKE.X1mmhu2p)./gridDKE.Xpn./gridDKE.Xmhu2p./gridDKE.Xmhup;
    	ZXXF_c_tp_m_ijm = (ZXXD_c.mm_ijm./Zbouncecoef.XXRlambda_p2m1_m(:,:,ir)).*(Zbouncecoef.XXRlambda_b_p1m1_m(:,:,ir) - Zbouncecoef.XXRlambda_b_p1m2_m(:,:,ir)).*sqrt(gridDKE.X1mmhu2m)./gridDKE.Xpn./gridDKE.Xmhu2m./gridDKE.Xmhum;
		%    
	end
end
