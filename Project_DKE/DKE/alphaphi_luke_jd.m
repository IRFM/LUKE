function waves = alphaphi_luke_jd(waves,dke_out,ZP0,equilDKE,mksa)
%
% This function uses the LUKE power deposition output to calculate the power deposited along the rays
%%%%
nw = length(waves);
if isempty(waves),
    return
end
% 
if ~isfield(dke_out,'zS'),
    waves = {};;
    return;
end
%
zS = dke_out.zS;
residue_rf = dke_out.residue_rf;
xyprop_dke = dke_out.xyprop_dke;
yb = dke_out.yb;
nit = size(dke_out.zP_0_2piRp_mod,2);
ny = size(xyprop_dke,2);
nb = length(yb);

%
xydV_2piRp_dke = equilDKE.xdV_2piRp_dke.'*ones(1,ny);
%
for itn = 1:nit,
    %
    xyPabs_rf_dke_fsav_mksa = ZP0(itn).xy_rf_fsav*mksa.P_ref*1e6;% absorbed power density in W/m3 (RLA)
    xyPrf_2piRp = xyPabs_rf_dke_fsav_mksa.*xydV_2piRp_dke;%power absorbed from each ray within each FS (RLA)
    xyPrf_2piRp(xyPrf_2piRp < 0) = 0;% RLA   
    %
    if iscell(residue_rf),
        nit_rf = length(residue_rf{itn});
    else
        nit_rf  = length(residue_rf);% old simulation
    end
    %
    if size(dke_out.zP_0_2piRp_mod,1) >= nit_rf,% all RF states kept in zP_0_2piRp_mod (RLA)
        zP_0_2piRp_mod = dke_out.zP_0_2piRp_mod{nit_rf,itn};% (RLA)
        if isfield(dke_out,'zP_0_2piRp_mod_coll'),
        	zP_0_2piRp_mod_coll = dke_out.zP_0_2piRp_mod_coll{nit_rf,itn};% (RLA + NRCA)
        end
    else
        zP_0_2piRp_mod = dke_out.zP_0_2piRp_mod{1,itn};% old case where only last  RF state kept in zP_0_2piRp_mod (RLA)
        if isfield(dke_out,'zP_0_2piRp_mod_coll'),
            zP_0_2piRp_mod_coll = dke_out.zP_0_2piRp_mod_coll{1,itn};% old case where only last  RF state kept in zP_0_2piRp_mod (RLA + NRCA)
        end
    end
    %
    ibb = 0;
    %
    for iw = 1:nw,
        for ib = 1:length(waves{iw}.rays),
            ibb = ibb + 1;
            ray = waves{iw}.rays{ib};
            ns = length(ray.ss);
            %
            if ibb < nb,
                iy_end = yb(ibb + 1) - 1;
            else
                iy_end = ny;
            end
            %
            if any(xyprop_dke(:,iy_end) == 1)%outward propagating ray fragment (RLA)
                Prf_end_2piRp = xyPrf_2piRp(find(xyprop_dke(:,iy_end) == 1,1,'last'),iy_end); 
            else%inward propagating ray fragment (RLA)
                Prf_end_2piRp = xyPrf_2piRp(find(xyprop_dke(:,iy_end) == -1,1,'first'),iy_end);
            end
            %
            zP_end_2piRp = max([0,zP_0_2piRp_mod{ibb}(end) - Prf_end_2piRp/2]);%to account for all QL absorbed power (RLA)
            %
            zS_fit = [ray.ss(1),zS{ibb},ray.ss(end)];
            zP_0_2piRp_fit = [ray.P0_2piRp,zP_0_2piRp_mod{ibb},zP_end_2piRp];% RLA
            %
            % power along the ray
            %
            sP_2piRp = interp1(zS_fit,zP_0_2piRp_fit,waves{iw}.rays{ib}.ss,'pchip');% RLA
            %
            % optical depth
            %
            mask_ninf = sP_2piRp > 0;
            stau = Inf(1,ns);
            stau(mask_ninf) = log(ray.P0_2piRp./sP_2piRp(mask_ninf));% RLA
            %
            % power absorption rate
            %
            sP_2piRp_h = [sP_2piRp(1),(sP_2piRp(1:end-1) + sP_2piRp(2:end))/2,sP_2piRp(end)];% RLA
            ss_h = [ray.ss(1),(ray.ss(1:end-1) + ray.ss(2:end))/2,ray.ss(end)];
            sdP_2piRp_ds = -diff(sP_2piRp_h)./diff(ss_h);% RLA
            %
            % absorption coefficient
            %
            salpha = sdP_2piRp_ds./sP_2piRp;% RLA
            sphi_norm = sqrt(abs(ray.sphi_xyz(1,:)).^2 + abs(ray.sphi_xyz(2,:)).^2 + abs(ray.sphi_xyz(3,:)).^2);
            salphaphi = salpha.*sphi_norm;% RLA            
            %
            waves{iw}.rays{ib}.sP_2piRp{itn} = sP_2piRp;% RLA
            waves{iw}.rays{ib}.stau{itn} = stau;% RLA
            waves{iw}.rays{ib}.sdP_2piRp_ds{itn} = sdP_2piRp_ds;% RLA
            waves{iw}.rays{ib}.salphaphi{itn} = salphaphi;% RLA
            %
            if isfield(dke_out,'zP_0_2piRp_mod_coll'),
                %
                zP_end_2piRp_coll = max([0,zP_0_2piRp_mod_coll{ibb}(end) - Prf_end_2piRp/2]);%to account for all QL absorbed power (RLA + NRCA)
                %
                zS_fit = [ray.ss(1),zS{ibb},ray.ss(end)];
                zP_0_2piRp_coll_fit = [ray.P0_2piRp,zP_0_2piRp_mod_coll{ibb},zP_end_2piRp_coll];% RLA + NRCA
                %
                % power along the ray
                %
                sP_2piRp_coll = interp1(zS_fit,zP_0_2piRp_coll_fit,waves{iw}.rays{ib}.ss,'pchip');% RLA + NRCA
                %
                % optical depth
                %
                mask_ninf = sP_2piRp_coll > 0;
                stau_coll = Inf(1,ns);
                stau_coll(mask_ninf) = log(ray.P0_2piRp./sP_2piRp_coll(mask_ninf));%RLA + NRCA
                %
                % power absorption rate
                %
                sP_2piRp_coll_h = [sP_2piRp(1),(sP_2piRp_coll(1:end-1) + sP_2piRp_coll(2:end))/2,sP_2piRp_coll(end)];% RLA + NRCA
                ss_h = [ray.ss(1),(ray.ss(1:end-1) + ray.ss(2:end))/2,ray.ss(end)];
                sdP_2piRp_coll_ds = -diff(sP_2piRp_coll_h)./diff(ss_h);% RLA + NRCA
                %
                % absorption coefficient
                %
                salpha_coll = sdP_2piRp_coll_ds./sP_2piRp_coll;% RLA + NRCA
                sphi_norm = sqrt(abs(ray.sphi_xyz(1,:)).^2 + abs(ray.sphi_xyz(2,:)).^2 + abs(ray.sphi_xyz(3,:)).^2);
                salphaphi_coll = salpha_coll.*sphi_norm;% RLA + NRCA          
                %
                waves{iw}.rays{ib}.sP_2piRp_coll_luke{itn} = sP_2piRp_coll;% RLA + NRCA
                waves{iw}.rays{ib}.stau_coll_luke{itn} = stau_coll;% RLA + NRCA
                waves{iw}.rays{ib}.sdP_2piRp_coll_luke_ds{itn} = sdP_2piRp_coll_ds;% RLA + NRCA
                waves{iw}.rays{ib}.salphaphi_coll_luke{itn} = salphaphi_coll;% RLA + NRCA
                %
            end 
        end
    end
end
%
for iw = 1:nw,
    waves{iw}.simul = dke_out.simul;
end
%
