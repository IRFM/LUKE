function [XAstr_ipjp] = stream_dke_jd(ZSp0,XxRR_ref_fsav,dmhu,pnp,rdke,ir_display,nb);
%
%Stream function calculation for graphical flux analysis
%
%by Joan Decker (MIT/RLE, jodecker@mit.edu, 12/04/03)
%modified by Yves Peysson (CEA/DRFC, yves.peysson@cea.fr, 05/08/03)
%
if nargin < 7,
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
for j=1:nmhu,
	XAstr_ipjp(:,j) = XxRR_ref_fsav(np-1,rdke(ir_display)) - 2*pi*pnp(:).*pnp(:).*integral_dke_jd(dmhu(1:j),XSp0_tot_ipj(:,1:j),2);%Stream function with runaway
end
