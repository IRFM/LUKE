function [XAstr_S_Pm,XAstr_S_Pp,XAstr_S_T] = stream_dke_jd(ZSp0,XxRR_ref_fsav,mhu,xmhubounce2,dmhu,pnp,ir_display_dke,nb);
%
%Stream function calculation for graphical flux analysis
%
%by Joan Decker (MIT/RLE, jodecker@mit.edu, 12/04/03)
%modified by Yves Peysson (CEA/DRFC, yves.peysson@cea.fr, 05/08/03)
%
if nargin < 6,
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
[np,nmhu,nr_dke] = size(XXSp0_c_ipj);
%
np_S = np + 1;
nmhu_S = nmhu + 1;
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
    XXSp0_rf_ipj = zeros(np,nmhu,nr_dke);
    XXSp0_tp_rf_ipj = zeros(np,nmhu,nr_dke);
    XXSp0_g_rf_ipj = zeros(np,nmhu,nr_dke);
end
%
XXSp0_tot_ipj = XXSp0_c_ipj + XXSp0_e_ipj + XXSp0_rf_ipj;
XSp0_tot_ipj = XXSp0_tot_ipj(:,:,ir_display_dke);
%
nPp = sum(mhu > sqrt(xmhubounce2(ir_display_dke)));
nPm = sum(mhu < -sqrt(xmhubounce2(ir_display_dke)));
nT = sum(abs(mhu) <= sqrt(xmhubounce2(ir_display_dke)));
%
XAstr_S_Pp = zeros(np_S,nmhu_S);
XAstr_S_Pm = zeros(np_S,nmhu_S);
XAstr_S_T = zeros(np_S,nmhu_S);
%
for j=1:nPm,
	XAstr_S_Pm(2:np_S,j+1) = XxRR_ref_fsav(np-1,ir_display_dke) - 2*pi*pnp(:).*pnp(:).*integral_dke_jd(dmhu(1:j),XSp0_tot_ipj(:,1:j),2);%Stream function with runaway
end
for j=1:nPp,
	XAstr_S_Pp(2:np_S,nmhu-j+1) = XxRR_ref_fsav(np-1,ir_display_dke) + 2*pi*pnp(:).*pnp(:).*integral_dke_jd(dmhu(nmhu-j+1:nmhu),XSp0_tot_ipj(:,nmhu-j+1:nmhu),2);%Stream function with runaway
end
for j=1:nT/2
	XAstr_S_T(2:np_S,nmhu/2+j+1) = XxRR_ref_fsav(np-1,ir_display_dke) - 2*pi*pnp(:).*pnp(:).*integral_dke_jd(dmhu(nmhu/2+1:nmhu/2+j),XSp0_tot_ipj(:,nmhu/2+1:nmhu/2+j),2);%Stream function with runaway
	XAstr_S_T(2:np_S,nmhu/2-j+1) = XxRR_ref_fsav(np-1,ir_display_dke) + 2*pi*pnp(:).*pnp(:).*integral_dke_jd(dmhu(nmhu/2+1-j:nmhu/2),XSp0_tot_ipj(:,nmhu/2+1-j:nmhu/2),2);%Stream function with runaway
end
%
XAstr_S_Pm(2:np_S,nPm+2:nmhu_S) = XAstr_S_Pm(2:np_S,nPm+1)*ones(1,nmhu_S-nPm-1);
XAstr_S_Pp(2:np_S,1:nmhu-nPp) = XAstr_S_Pp(2:np_S,nmhu-nPp+1)*ones(1,nmhu_S-nPp-1);
XAstr_S_T(2:np_S,nmhu/2+nT/2+2:nmhu_S) = XAstr_S_T(2:np_S,nmhu/2+nT/2+1)*ones(1,nPp);
XAstr_S_T(2:np_S,1:nmhu/2-nT/2) = XAstr_S_T(2:np_S,nmhu/2-nT/2+1)*ones(1,nPm);