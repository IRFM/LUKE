clear
for j = 1:3,
    %
    load(['WAVE_TCV_18532_1.5000_C3PO_L',int2str(j),'.mat'],'wave');
    %
    for iray = 1:length(wave.rays);
        %
        wave.rays{iray}.stau = wave.rays{iray}.stau_lin;
        wave.rays{iray}.sP_2piRp = wave.rays{iray}.sP_2piRp_lin;
        wave.rays{iray}.sdP_2piRp_ds = wave.rays{iray}.sdP_2piRp_ds_lin;
        wave.rays{iray} = rmfield(wave.rays{iray},{'stau_lin','sP_2piRp_lin','sdP_2piRp_ds_lin'});
        %
    end
    %
    save(['WAVE_TCV_18532_1.5000_C3PO_L',int2str(j),'_mod.mat'],'wave');
    %
end
