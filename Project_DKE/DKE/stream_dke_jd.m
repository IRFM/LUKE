function [XAstr_ipjp] = stream_dke_jd(ZSp0,XxRR_ref_fsav,mhu,dmhu,pnp,xmhubounce2,bounce_mode,xia,rdke,ir_display,nb);
%
%Stream function calculation for graphical flux analysis
%
%by Joan Decker (MIT/RLE, jodecker@mit.edu, 12/04/03)
%modified by Yves Peysson (CEA/DRFC, yves.peysson@cea.fr, 05/08/03)
%
if nargin < 11,
	info_dke_yp(2,'Wrong number of input arguments for stream_dke_jd');
	return;
end
%
XXSp0_c_ipj = ZSp0{1,4};%Collisions
XXSp0_tp_c_ipj = ZSp0{1,5};
XXSp0_g_c_ipj = ZSp0{1,6};
%
XXSp0_e_ipj = ZSp0{2,4};%Ohmic electric field
XXSp0_tp_e_ipj = ZSp0{2,5};
XXSp0_g_e_ipj = ZSp0{2,6};
%
[np,nmhu,nr] = size(XXSp0_c_ipj);
%
if nb > 0,
    YXXSp0_rf_ipj = ZSp0{3,4};%RF waves
    YXXSp0_tp_rf_ipj = ZSp0{3,5};
    YXXSp0_g_rf_ipj = ZSp0{3,6};
%
    XXSp0_rf_ipj = integral_dke_jd(ones(1,nb),YXXSp0_rf_ipj,4);
    XXSp0_tp_rf_ipj = integral_dke_jd(ones(1,nb),YXXSp0_tp_rf_ipj,4);
    XXSp0_g_rf_ipj = integral_dke_jd(ones(1,nb),YXXSp0_g_rf_ipj,4);
else
    XXSp0_rf_ipj = zeros(np,nmhu,nr);
    XXSp0_tp_rf_ipj = zeros(np,nmhu,nr);
    XXSp0_g_rf_ipj = zeros(np,nmhu,nr);
end
%
XXSp0_tot_ipj = XXSp0_c_ipj + XXSp0_e_ipj + XXSp0_rf_ipj;
XSp0_tot_ipj = XXSp0_tot_ipj(:,:,rdke(ir_display));
%
if bounce_mode > 0,%Case with bounce averaging
    lambda = bounce_dke_jd(xmhubounce2(ir_display),mhu,30);
    Xlambda = ones(np,1)*lambda;
%    lambdap = bounce_dke_jd(xmhubounce2(ir_display),mhup,30);
%
%    for i=1:np,   
%        XAstr_ipjm_fsav(i,:) = XxRR_ref_fsav(np-1,rdke(ir_display)) - 2*pi*(1+xia(rdke(ir_display)))*lambdam.*sqrt(1 - mhum.*mhum).*integral_dke_jd(dpn(1:i),Xpn(1:i,:).*XSm0_tot_ijm(1:i,:),1)';
%        XAstr_ipjp_fsav(i,:) = XxRR_ref_fsav(np-1,rdke(ir_display)) - 2*pi*(1+xia(rdke(ir_display)))*lambdap.*sqrt(1 - mhup.*mhup).*integral_dke_jd(dpn(1:i),Xpn(1:i,:).*XSm0_tot_ijp(1:i,:),1)';
%    end
%    
%    XAstr_S_ip_fsav = zeros(np,nmhu+1);
%    XAstr_S_ip_fsav(:,2:nmhu) = (XAstr_ipjm_fsav(:,2:nmhu) + XAstr_ipjp_fsav(:,1:nmhu-1))/2; 
%    XAstr_S_ip_fsav(:,1) = XAstr_ipjm_fsav(:,1);
%    XAstr_S_ip_fsav(:,nmhu+1) = XAstr_ipjp_fsav(:,nmhu); 
%    XAstr_S_im_fsav = zeros(np,nmhu+1);
%    XAstr_S_im_fsav(2:np,:) = XAstr_S_ip_fsav(1:np-1,:);
%    
%    XAstr_imj_out = XAstr_S_ip_fsav;%Stream finction with runaway (see Karney's paper)
%  
	for j=1:nmhu,%********************Verifier le calcul*********************
		XAstr_ipjp(:,j) = XxRR_ref_fsav(np-1,rdke(ir_display)) - 2*pi*(1 + xia(rdke(ir_display)))*pnp(:).*pnp(:).*integral_dke_jd(dmhu(1:j),XSp0_tot_ipj(:,1:j).*Xlambda(:,1:j),2);%Stream function with runaway
	end
	info_dke_yp(2,'WARNING: Bounce averaged stream function not yet implemented !');
else	
	for j=1:nmhu,
		XAstr_ipjp(:,j) = XxRR_ref_fsav(np-1,rdke(ir_display)) - 2*pi*pnp(:).*pnp(:).*integral_dke_jd(dmhu(1:j),XSp0_tot_ipj(:,1:j),2);%Stream function with runaway
	end
%
end
