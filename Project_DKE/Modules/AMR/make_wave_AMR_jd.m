function wave = make_wave_AMR_jd(wavestruct,equil)
%
% This function makes the WAVE file from AMR ray-tracing output
%
AMR_output_path = wavestruct.AMR_output_path;
%
if length(istru) >= 2 && strcmp(equil.id(1:istru(1)-1),basestr),
	shotnum = equil.id(istru(1)+1:istru(2)-1);
	if length(istru) >= 3,
		shotime = equil.id(istru(2)+1:istru(3)-1);
	else
		shotime = equil.id(istru(2)+1:end);
	end
else           
	disp('-----> Shot number information missing');
	return
end
%
wavedatafile = [AMR_output_path,'luke_rays_',wavestruct.filestr,'.dat'];
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
waveparam.AMR_output_path = AMR_output_path;
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
    
