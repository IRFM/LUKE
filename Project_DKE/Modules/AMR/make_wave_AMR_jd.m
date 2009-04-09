function wave = make_wave_AMR_jd(wavestruct,equil)
%
% This function makes the WAVE file from AMR ray-tracing output
%
AMR_path = wavestruct.AMR_path;
%
shotime = equil.info.shotime;
%
wavedatafile = [AMR_path,'luke_rays_',wavestruct.filestr,'.dat'];
%
if ~exist(wavedatafile,'file'),
    error('AMR output files not found, aborted');
else
    wavedata = load(wavedatafile,'-ascii');
end
%
ny = size(wavedata,1);
%
if str2double(shotime) ~= wavedata(1,1),
    error('The shot time is not compatible with equilibrium')
end
%
if ny == 1,
    %
    nd = wavestruct.nd;
    nchi = wavestruct.nchi;
    %
else
    nd = 1;
    nchi = 1;
end
%
waveparam.filestr = wavestruct.filestr;
waveparam.id = wavestruct.id;
waveparam.AMR_path = AMR_path;
%
waveparam.dNpar = wavestruct.dNpar;
waveparam.dsmin = wavestruct.dsmin;
waveparam.kmode = wavestruct.kmode;
waveparam.opt_rf = wavestruct.opt_rf;
%
waveparam.nd = nd;
waveparam.nchi = nchi;
%
wave = proc_rays_AMR_jd(wavedata,waveparam,equil);
%
if isempty(wave),
    error('AMR ray processing failed');
end
    
