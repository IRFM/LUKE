function waves = alphaphi_luke_jd(waves,dke_out,gridDKE)
%
% This function uses the LUKE power deposition output to calculate the power deposited along the rays
% 

%
% power flowing along the rays along the rays
%
zs = raypath_jd(dke_out.xys,dke_out.xyprop_dke,dke_out.yb,gridDKE.rdke);
zP_0_2piRp = raypath_jd(dke_out.xyP0_2piRp_mod,dke_out.xyprop_dke,dke_out.yb,gridDKE.rdke);
%
ibb = 0;
%
nw = length(waves);
%
for iw = 1:nw,
    for ib = 1:length(waves{iw}.rays),
        ibb = ibb + 1;
        %
        % Should not be needed in new DQL calculations where zs should be
        % distinct
        %
        %zind = find(diff(zs{ibb}) == 0);
        %zs{ibb}(zind + 1) = zs{ibb}(zind + 1)+1000*eps;
        %
        s_luke = [0,zs{ibb}];
        P_0_2piRp_luke = [waves{iw}.rays{ib}.P0_2piRp,zP_0_2piRp{ibb}];
        %
        waves{iw}.rays{ib}.sP_2piRp = interp1(s_luke,P_0_2piRp_luke,waves{iw}.rays{ib}.ss,'linear',0);   
    end
end
