function [wave_out] = change_directivity_yp(wave_in,equil,module_directivity_ref)
%
% This function changes the antenna module directivity (module directivity (RC = 0), J. Hillairet et al. Nucl. Fusion 50 (2010) 125010) by balancing power
% fractions that drive co- and counter- LH current without recalculating ray trajectories. It makes all quantities (wave.rays, wave.rayinit, wave.rayinit.launch) consistent 
% with the new reference directivity. It does not change the relative weights between group of lobes corresponding to Npar > 0 and Npar < 0.
%
% The module directivity ranges between 0 and 1. The value 0.5 corresponds
% to equals power in lobes of Npar > 0 and Npar < 0. Enforcing a module
% directivity lower than 0.5 leads to revert module directivity and Npeak
% position
%
%	Input:
%
%       - wave_in: input wave structure (structure)
%       - equil: toroidal MHD equilibrium (structure)
%       - module_directivity_ref : module directivity [1,1]
%         (default: initial wave directivity)
%       
%	Output:
%
%       - wave_out: modified output wave structure (structure)
%
% by Y.Peysson (CEA/IRFM, yves.peysson@cea.fr)
%
if nargin < 2
    error('Error in change_directivity_yp.m, not enough input arguments')
end
%
wave_out = wave_in;
%
if isreal(wave_out.rayinit.yNpar0)
    bNpar0 = wave_out.rayinit.yNpar0;
else
    bNpar0 = imag(wave_out.rayinit.yNpar0);
end
%
bPlhtot = wave_out.rayinit.yP0_2piRp*2*pi*equil.Rp;
%
Npeak = bNpar0(find(bPlhtot == max(bPlhtot),1,'first'));
Ptot = sum(bPlhtot);
%
maskp = bNpar0 > 0;
maskm = bNpar0 < 0;
%
frac_initial_Ptotm = sum(bPlhtot(maskm))/Ptot;
frac_initial_Ptotp = sum(bPlhtot(maskp))/Ptot;
%
frac_Ptotm = sum(bPlhtot(maskm))/Ptot;
frac_Ptotp = sum(bPlhtot(maskp))/Ptot;
%
module_directivity = max(frac_Ptotm,frac_Ptotp);
%
if nargin < 3,
    module_directivity_ref = module_directivity;
    disp('WARNING: Module directivity unchanged.');
else
    if module_directivity_ref < 0 || module_directivity_ref > 1,
        error('ERROR: module directivity must range between 0 and 1');
    end
    %
    if module_directivity_ref < 0.5,
        disp('WARNING: Module directivity < 0.5 corresponds to a change in the LH driven current direction.');
        disp(['WARNING: The new module directivity will be : ',num2str(1-module_directivity_ref),'.']);
    end
end
%
if Npeak > 0,
    wave_out.initial_Npeak = Npeak;
    wave_out.initial_module_directivity = sum(bPlhtot(maskp))/Ptot; % Module directivity (RC = 0), J. Hillairet et al. Nucl. Fusion 50 (2010) 125010 
    wave_out.initial_ideal_weighted_directivity = Npeak^2*(sum(bPlhtot(maskp)./bNpar0(maskp).^2) - sum(bPlhtot(maskm)./bNpar0(maskm).^2))/Ptot;% Ideal weighted directivity (RC = 0), X. Litaudon and D. Moreau 1990 Nucl. Fusion 30 471
    %
    wave_out.rayinit.yP0_2piRp(maskm) = wave_out.rayinit.yP0_2piRp(maskm)*(1-module_directivity_ref)/frac_Ptotm;%
    wave_out.rayinit.yP0_2piRp(maskp) = wave_out.rayinit.yP0_2piRp(maskp)*module_directivity_ref/frac_Ptotp;%
    %
    wave_out.rayinit.launch.bPlhtot(wave_out.rayinit.launch.bNpar0 < 0) = wave_out.rayinit.launch.bPlhtot(wave_out.rayinit.launch.bNpar0 < 0)*(1-module_directivity_ref)/frac_Ptotm;%
    wave_out.rayinit.launch.bPlhtot(wave_out.rayinit.launch.bNpar0 > 0) = wave_out.rayinit.launch.bPlhtot(wave_out.rayinit.launch.bNpar0 > 0)*module_directivity_ref/frac_Ptotp;%
    %
    for iray = 1:length(wave_out.rays)
        if wave_out.rays{iray}.sNpar < 0
            wave_out.rays{iray}.P0_2piRp = wave_out.rays{iray}.P0_2piRp*(1-module_directivity_ref)/frac_Ptotm;
            wave_out.rays{iray}.sP_2piRp_lin = wave_out.rays{iray}.sP_2piRp_lin*(1-module_directivity_ref)/frac_Ptotm;
            wave_out.rays{iray}.sdP_2piRp_ds_lin = wave_out.rays{iray}.sdP_2piRp_ds_lin*(1-module_directivity_ref)/frac_Ptotm;
            wave_out.rays{iray}.sP_2piRp_coll = wave_out.rays{iray}.sP_2piRp_coll*(1-module_directivity_ref)/frac_Ptotm;
            wave_out.rays{iray}.sdP_2piRp_ds_coll = wave_out.rays{iray}.sdP_2piRp_ds_coll*(1-module_directivity_ref)/frac_Ptotm;
            wave_out.rays{iray}.sP_2piRp_lin_coll = wave_out.rays{iray}.sP_2piRp_lin_coll*(1-module_directivity_ref)/frac_Ptotm;
            wave_out.rays{iray}.sdP_2piRp_ds_lin_coll = wave_out.rays{iray}.sdP_2piRp_ds_lin_coll*(1-module_directivity_ref)/frac_Ptotm;
        else     
            wave_out.rays{iray}.P0_2piRp = wave_out.rays{iray}.P0_2piRp*module_directivity_ref/frac_Ptotp;
            wave_out.rays{iray}.sP_2piRp_lin = wave_out.rays{iray}.sP_2piRp_lin*module_directivity_ref/frac_Ptotp;
            wave_out.rays{iray}.sdP_2piRp_ds_lin = wave_out.rays{iray}.sdP_2piRp_ds_lin*module_directivity_ref/frac_Ptotp;
            wave_out.rays{iray}.sP_2piRp_coll = wave_out.rays{iray}.sP_2piRp_coll*module_directivity_ref/frac_Ptotp;
            wave_out.rays{iray}.sdP_2piRp_ds_coll = wave_out.rays{iray}.sdP_2piRp_ds_coll*module_directivity_ref/frac_Ptotp;
            wave_out.rays{iray}.sP_2piRp_lin_coll = wave_out.rays{iray}.sP_2piRp_lin_coll*module_directivity_ref/frac_Ptotp;
            wave_out.rays{iray}.sdP_2piRp_ds_lin_coll = wave_out.rays{iray}.sdP_2piRp_ds_lin_coll*module_directivity_ref/frac_Ptotp;        
        end
    end
else
    wave_out.initial_Npeak = Npeak;
    wave_out.module_initial_directivity = sum(bPlhtot(maskm))/Ptot; % Module directivity (RC = 0), J. Hillairet et al. Nucl. Fusion 50 (2010) 125010 
    wave_out.ideal_initial_weighted_directivity = Npeak^2*(-sum(bPlhtot(maskp)./bNpar0(maskp).^2) + sum(bPlhtot(maskm)./bNpar0(maskm).^2))/Ptot;% Ideal weighted directivity (RC = 0), X. Litaudon and D. Moreau 1990 Nucl. Fusion 30 471
    %
    wave_out.rayinit.yP0_2piRp(maskm) = wave_out.rayinit.yP0_2piRp(maskm)*module_directivity_ref/frac_Ptotm;%
    wave_out.rayinit.yP0_2piRp(maskp) = wave_out.rayinit.yP0_2piRp(maskp)*(1-module_directivity_ref)/frac_Ptotp;%
    %
    wave_out.rayinit.launch.bPlhtot(wave_out.rayinit.launch.bNpar0 < 0) = wave_out.rayinit.launch.bPlhtot(wave_out.rayinit.launch.bNpar0 < 0)*module_directivity_ref/frac_Ptotm;%
    wave_out.rayinit.launch.bPlhtot(wave_out.rayinit.launch.bNpar0 > 0) = wave_out.rayinit.launch.bPlhtot(wave_out.rayinit.launch.bNpar0 > 0)*(1-module_directivity_ref)/frac_Ptotp;%
    %
    for iray = 1:length(wave_out.rays)
        if wave_out.rays{iray}.sNpar < 0
            wave_out.rays{iray}.P0_2piRp = wave_out.rays{iray}.P0_2piRp*module_directivity_ref/frac_Ptotm;
            wave_out.rays{iray}.sP_2piRp_lin = wave_out.rays{iray}.sP_2piRp_lin*module_directivity_ref/frac_Ptotm;
            wave_out.rays{iray}.sdP_2piRp_ds_lin = wave_out.rays{iray}.sdP_2piRp_ds_lin*module_directivity_ref/frac_Ptotm;
            wave_out.rays{iray}.sP_2piRp_coll = wave_out.rays{iray}.sP_2piRp_coll*module_directivity_ref/frac_Ptotm;
            wave_out.rays{iray}.sdP_2piRp_ds_coll = wave_out.rays{iray}.sdP_2piRp_ds_coll*module_directivity_ref/frac_Ptotm;
            wave_out.rays{iray}.sP_2piRp_lin_coll = wave_out.rays{iray}.sP_2piRp_lin_coll*module_directivity_ref/frac_Ptotm;
            wave_out.rays{iray}.sdP_2piRp_ds_lin_coll = wave_out.rays{iray}.sdP_2piRp_ds_lin_coll*module_directivity_ref/frac_Ptotm;
        else     
            wave_out.rays{iray}.P0_2piRp = wave_out.rays{iray}.P0_2piRp*(1-module_directivity_ref)/frac_Ptotp;
            wave_out.rays{iray}.sP_2piRp_lin = wave_out.rays{iray}.sP_2piRp_lin*(1-module_directivity_ref)/frac_Ptotp;
            wave_out.rays{iray}.sdP_2piRp_ds_lin = wave_out.rays{iray}.sdP_2piRp_ds_lin*(1-module_directivity_ref)/frac_Ptotp;
            wave_out.rays{iray}.sP_2piRp_coll = wave_out.rays{iray}.sP_2piRp_coll*(1-module_directivity_ref)/frac_Ptotp;
            wave_out.rays{iray}.sdP_2piRp_ds_coll = wave_out.rays{iray}.sdP_2piRp_ds_coll*(1-module_directivity_ref)/frac_Ptotp;
            wave_out.rays{iray}.sP_2piRp_lin_coll = wave_out.rays{iray}.sP_2piRp_lin_coll*(1-module_directivity_ref)/frac_Ptotp;
            wave_out.rays{iray}.sdP_2piRp_ds_lin_coll = wave_out.rays{iray}.sdP_2piRp_ds_lin_coll*(1-module_directivity_ref)/frac_Ptotp;        
        end
    end
end
%
wave_out.id = [wave_out.id,'_module_directivy_enforced_',strrep(num2str(module_directivity_ref),'.','p')]
%
bPlhtot_mod = wave_out.rayinit.yP0_2piRp*2*pi*equil.Rp;
%
Npeak_mod = bNpar0(find(bPlhtot_mod == max(bPlhtot_mod),1,'first'));
%
if Npeak_mod > 0,
    wave_out.modified_Npeak = Npeak_mod;
    wave_out.modified_module_directivity = sum(bPlhtot_mod(maskp))/Ptot; % Module directivity (RC = 0), J. Hillairet et al. Nucl. Fusion 50 (2010) 125010 
    wave_out.ideal_modified_weighted_directivity = Npeak_mod^2*(sum(bPlhtot_mod(maskp)./bNpar0(maskp).^2) - sum(bPlhtot_mod(maskm)./bNpar0(maskm).^2))/Ptot;% Ideal weighted directivity (RC = 0), X. Litaudon and D. Moreau 1990 Nucl. Fusion 30 471
else
    wave_out.modified_Npeak = Npeak_mod;
    wave_out.module_modified_directivity = sum(bPlhtot_mod(maskm))/Ptot; % Module directivity (RC = 0), J. Hillairet et al. Nucl. Fusion 50 (2010) 125010 
    wave_out.ideal_modified_weighted_directivity = Npeak_mod^2*(-sum(bPlhtot_mod(maskp)./bNpar0(maskp).^2) + sum(bPlhtot_mod(maskm)./bNpar0(maskm).^2))/Ptot;% Ideal weighted directivity (RC = 0), X. Litaudon and D. Moreau 1990 Nucl. Fusion 30 471
end
%
wave = wave_out;
savename = ['WAVE_',wave.equil_id,'_',wave.id,'.mat'];
save (savename,'wave');
%
disp(['Modified wave structure saved in file :',savename]);
%

