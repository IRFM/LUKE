function job = runlukesave(sinput,job)
%
% This function saves the structure sinput in a mat file tagged by logname and timeid 
%
simul_in = sinput.simul_in;
dkeparam = sinput.dkeparam;
dkedisplay = sinput.dkedisplay;
equil = sinput.equil;
wavestructs = sinput.wavestructs;
waves = sinput.waves;
ohm = sinput.ohm;
transpfaste = sinput.transpfaste;
ripple = sinput.ripple;
%
if isfield(sinput,'dkepath'),
    dkepath = sinput.dkepath;
else
    dkepath  ='';
end
%
if isfield(sinput,'Zf0_interp')
    Zf0_interp = sinput.Zf0_interp;
else
    Zf0_interp = '';
end
if isfield(sinput,'XXsinksource')
    XXsinksource = sinput.XXsinksource;
else
    XXsinksource = '';
end
%
if isfield(sinput,'opt_save')
    opt_save = sinput.opt_save;
else
    opt_save = 0;
end
%
if isfield(job,'localdatapath') && ~isempty(job.localdatapath),% remote data location
    localdatapath = [job.localdatapath,filesep];
else
    localdatapath = '';
end
%
job.load_id = ['LUKE_OUT_',job.remotelogname,'_',job.timeid,'.mat'];
job.save_id = ['LUKE_RUN_',job.remotelogname,'_',job.timeid,'.mat'];
%
if strcmp(luke_job.remotedatapath,'condor'),
    %
    localdatapath = [localdatapath,'/condor'];
    %
    mkdir();
    %
    job.condor_id = condor_batchscript_yp(localdatapath,timeid,luke_job.remotedatapath,luke_job.env.LUKE_path,luke_job.env.LUKE_matlabroot,'',1);
    %
end
%
save([localdatapath,save_id],'simul_in','wavestructs','waves','dkeparam','dkepath','equil','dkedisplay','ohm','transpfaste','ripple','Zf0_interp','XXsinksource','opt_save');
%
%
if strcmp(luke_job.remotedatapath,'condor'),
    %
    save_id = localdatapath;
    %
end

    
    
