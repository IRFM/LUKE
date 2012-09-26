%
clear all
opt = 0;
%
load('data_for_testremote.mat','luke_input');
%
luke_input.simul_in = luke_input.id_simul;
luke_input = rmfield(luke_input,'id_simul');
%
time_step = 1;
nit = 60;
%
displaymode = 1;
%
if  opt == 0,
    remote(1).host = '';
    remote(1).cmd = 'qsub -l inter=false,ncpus=2';
    remote(1).get_jobid = {'','.cephee'};
    remote(1).set_jobid = {'qstat ','.cephee','Unknown Job Id'};
    remote(1).mem = {',mem=','mb'};
    %remote(1).JD211098 = [];
    %
    luke_job.script = 'mrunluke_batch';
    luke_job.savefcn = 'runlukesave';%'matstandardsave';
    luke_job.loadfcn = 'runlukeload';%'matstandardload';
    luke_job.root = '/home/sccp/gsem/decker/LUKE_merge/';
    luke_job.memory = 7000;%mb
    luke_job.localdatapath = '~/tmp';
    luke_job.remotedatapath = '/local';
    luke_job.env.LUKE_matlabroot = '';
    luke_job.env.LUKE_path = luke_job.root;
    %
    luke_job = remoterunbatch(remote,luke_job,luke_input,displaymode);
    %
    for it = 1:nit,
        %
        pause(time_step)
        %
        luke_output = remotegetbatch(remote,luke_job,displaymode);
        %
        if ~isempty(luke_output),
            break
        end
    end
    %
else
    %
    dkepath = load_structures_yp('dkepath','','');
    remote = dkepath.remote(1);
    %
    luke_job = runluke_remote_jd(luke_input,remote,displaymode);
    %
    for it = 1:nit,
        %
        pause(time_step)
        %
        luke_output = getluke_remote_jd(luke_job,remote,displaymode);
        %
        if ~isempty(luke_output),
            break
        end
    end
end
%
j_r_k = '0.003732';
p_r_k = '0.0001256';
eta_r_k = '29.72';
%
%************************************************************************************************************************************
%
format
%
delete res_testremote
%
diary res_testremote
%
disp('----------------------')
disp('Comparison LUKE/Karney')
disp('----------------------')
%
if isfield(luke_output,'Zcurr'),
    disp(['Relativistic case (4,7,1) : j = ',num2str(luke_output.Zcurr.x_0),'/',j_r_k,' ; P = ',num2str(luke_output.ZP0.x_rf_fsav),'/',p_r_k,' ; j/P = ',num2str(luke_output.Zcurr.x_0./luke_output.ZP0.x_rf_fsav),'/',eta_r_k])
else
    disp('Run failed')
end
%
diary off
%


