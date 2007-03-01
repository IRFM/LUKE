function waves = alphaphi_luke_jd(waves,ZP0,mksa,dke_out,gridDKE,dkeparam)
%
% This function uses the LUKE power deposition output to calculate the power deposited along the rays
% 

% 
% density of power absorbed (normalized) 
%
if dkeparam.dke_mode >= 1,
    xyPabs_rf_dke_fsav = ZP0.xy_rf_fsav + ZP0.xy_rf_tp_fsav + ZP0.xy_rf_g_fsav; % flux-surface averaged density of absorbed power.
else
    xyPabs_rf_dke_fsav = ZP0.xy_rf_fsav; % flux-surface averaged density of absorbed power.
end	    
% 
% density of power absorbed (MKSA) 
%
xyPabs_rf_dke_fsav_mksa = xyPabs_rf_dke_fsav*mksa.P_ref*1e6;%RF power (W)
%
% absorption coefficient (1/m)
%
xyD0_rf = dke_out.waveparam(:,:,4).*dke_out.xyP0_2piRp_mod./dke_out.xyP0_2piRp_in;
%
xyD0_rf(xyD0_rf == 0) = eps;
%
xyalphaphi = xyPabs_rf_dke_fsav_mksa./xyD0_rf./dke_out.waveparam(:,:,1)/mksa.wmabs2;%absorption coefficient
%
% absorption coefficient along the rays
%
zs = raypath_jd(dke_out.xys,dke_out.xyprop_dke,dke_out.yb,gridDKE.rdke);
zalphaphi = raypath_jd(xyalphaphi,dke_out.xyprop_dke,dke_out.yb,gridDKE.rdke);
%
ibb = 0;
%
nw = length(waves);
%
for iw = 1:nw,
    for ib = 1:length(waves{iw}.rays),
        ibb = ibb + 1;
        zind = find(diff(zs{ibb}) == 0);
        zs{ibb}(zind + 1) = zs{ibb}(zind + 1)+1000*eps;
        %
        waves{iw}.rays{ib}.salphaphi_lin = interp1(zs{ibb},zalphaphi{ibb},waves{iw}.rays{ib}.ss,'linear',0);   
    end
end
