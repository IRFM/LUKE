function saveinputs_jd(lukestruct)
%
equil = lukestruct.equil;
%
equilstr = ['EQUIL_',equil.id,'.mat'];
save(equilstr,'equil');
disp(['Equilibrium saved in file ',equilstr]);
%
if isfield(lukestruct,'wavestructs'),
    for iw = 1:length(lukestruct.wavestructs),
        wavestruct = lukestruct.wavestructs{iw};
        wavestr = ['WAVESTRUCT_',equil.id,'_',wavestruct.id,'.mat'];
        save(wavestr,'wavestruct');
        disp(['Wavestruct # ',num2str(iw),' saved in file ',wavestr]);
    end
end
%
if isfield(lukestruct,'waves'),
    for iw = 1:length(lukestruct.waves),
        wave = lukestruct.waves{iw};
        wavestr = ['WAVE_',equil.id,'_',wave.id,'.mat'];
        save(wavestr,'wave');
        disp(['Wave # ',num2str(iw),' saved in file ',wavestr]);
    end
end
%
if isfield(lukestruct,'ohm') && isstruct(lukestruct.ohm) && ~isempty(fieldnames(lukestruct.ohm))
    ohm = lukestruct.ohm;
    ohmstr = ['OHM_',equil.id,'_',ohm.id,'.mat'];
    save(ohmstr,'ohm');
    disp(['Ohmic field structure saved in file ',ohmstr]);
end
%
if isfield(lukestruct,'transpfaste') && isstruct(lukestruct.transpfaste) && ~isempty(fieldnames(lukestruct.transpfaste))
    transpfaste = lukestruct.transpfaste;
    transpfastestr = ['TRANSP_',equil.id,'_',transpfaste.id,'.mat'];
    save(transpfastestr,'transpfaste');
    disp(['Fast electron transport structure saved in file ',transpfastestr]);
end
%
if isfield(lukestruct,'ripple') && isstruct(lukestruct.ripple) && ~isempty(fieldnames(lukestruct.ripple))
    ripple = lukestruct.ripple;
    ripplestr = ['RIPPLE_',equil.id,'_',ripple.id,'.mat'];
    save(ripplestr,'ripple');
    disp(['Ripple structure saved in file ',ripplestr]);
end
%
        
