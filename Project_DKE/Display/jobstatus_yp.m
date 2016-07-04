function [joblist,C3PO_status,LUKE_status,orphan_batch_dir,dirsearch] = jobstatus_yp(dirsearch,displaymode)
%LUKE -  Function which scan the simulations in a given folder and analyze their status
%
% Function which scan the simulations in a given folder and analyze their status
%
% INPUT
%
%   - dirsearch: search folder
%     (default : pwd)
%   - displaymode: display results in the command window (1: yes, 0: no)
%     (default : no display)
%
% OUTPUT
%
%   - joblist: job list structure
%   - C3PO_status: C3PO list status structure (wave by wave)
%   - LUKE_status: LUKE list status structure
%   - dirsearch: search folder
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr> and J. Decker (CRPP/EPFL) <joan.decker@epfl.ch>
%
warning off
%
if nargin < 1,
    dirsearch = pwd;
    displaymode = 0;
end
if nargin == 1,
    displaymode = 0;
end
%
if isempty(dirsearch) | isnan(dirsearch), 
    dirsearch = pwd;
end
%
dirinit = pwd;
cd(dirsearch);
%
filelist = what;
filename = filelist.mat;
%
jj = 1;
joblist = '';
max_waves = 0;
%
for ii = 1:length(filename),
    if strfind(filename{ii},'LUKE_DATA_')> 0 & strcmp(filename{ii}(1),'L') == 1,
        filedata = load(filename{ii},'id_simul','id_simul_o','output','waves','luke_job');
        joblist(jj).filename = filename{ii};
        joblist(jj).id_simul = filedata.id_simul_o;
        %
        if isfield(filedata,'waves')
            %
            max_waves = max(max_waves,length(filedata.waves));
            %
            for iw = 1:length(filedata.waves),
                %
                status(jj).C3PO(iw).notdone = 0;
                status(jj).C3PO(iw).completed = 0;
                status(jj).C3PO(iw).running = 0;
                %
                if isempty(filedata.waves{iw}),
                    joblist(jj).C3PO(iw).status = 'C3PO ray tracing calculations not done';
                    joblist(jj).C3PO(iw).host = '';
                    joblist(jj).C3PO(iw).jobid = NaN;
                    joblist(jj).C3PO(iw).batch_dir = '';
                    status(jj).C3PO(iw).notdone = 1;
                elseif isfield(filedata.waves{iw},'rays')
                    joblist(jj).C3PO(iw).status = 'C3PO ray tracing calculations completed';
                    joblist(jj).C3PO(iw).host = '';
                    joblist(jj).C3PO(iw).jobid = NaN;
                    joblist(jj).C3PO(iw).batch_dir = '';
                    status(jj).C3PO(iw).completed = 1;
                elseif isfield(filedata.waves{iw},'job')
                    joblist(jj).C3PO(iw).status = 'C3PO ray tracing calculations running';
                    if isempty(filedata.waves{iw}.job.remote.host),
                        joblist(jj).C3PO(iw).host = 'local';
                    else
                        joblist(jj).C3PO(iw).host = filedata.waves{iw}.job.remote.host;
                    end
                    %
                    joblist(jj).C3PO(iw).jobid = filedata.waves{iw}.job.id;
                    joblist(jj).C3PO(iw).batch_dir = filedata.waves{iw}.job.batch_dir;
                    status(jj).C3PO(iw).running = 1;
                end
            end
        end
        %
        status(jj).LUKE.notdone = 0;
        status(jj).LUKE.completed = 0;
        status(jj).LUKE.running = 0;
        %
        if isempty(filedata.output)
            if isfield(filedata,'luke_job') & ~isempty(filedata.luke_job),
                joblist(jj).LUKE.status = 'LUKE Fokker-Planck calculations running';
                if isempty(filedata.luke_job.remote.host),
                    joblist(jj).LUKE.host = 'local';
                else
                    joblist(jj).LUKE.host = filedata.luke_job.remote.host;
                end
                %
                joblist(jj).LUKE.jobid = filedata.luke_job.id;
                joblist(jj).LUKE.batch_dir = filedata.luke_job.batch_dir;
                status(jj).LUKE.running = 1;
            else
                joblist(jj).LUKE.status = 'LUKE Fokker-Planck calculations not done';
                joblist(jj).LUKE.host = '';
                joblist(jj).LUKE.jobid = NaN;
                joblist(jj).LUKE.batch_dir = '';
                status(jj).LUKE.notdone = 1;
            end
        elseif isfield(filedata.output,'Znorm'),
            joblist(jj).LUKE.status = 'LUKE Fokker-Planck calculations completed';
             joblist(jj).LUKE.host = '';
            joblist(jj).LUKE.jobid = NaN;
            joblist(jj).LUKE.batch_dir = '';
            status(jj).LUKE.completed = 1;
        end
        %  
        jj = jj + 1;
    end
end
%
LUKE_status.notdone = 0;
LUKE_status.completed = 0;
LUKE_status.running = 0;
%
for iw = 1:max_waves,
    C3PO_status(iw).notdone = 0;
    C3PO_status(iw).completed = 0;
    C3PO_status(iw).running = 0;
end
%
for jj = 1:length(joblist),
    LUKE_status.notdone = LUKE_status.notdone + status(jj).LUKE.notdone;
    LUKE_status.completed = LUKE_status.completed + status(jj).LUKE.completed;
    LUKE_status.running = LUKE_status.running + status(jj).LUKE.running;
    %
    for iw = 1:length(status(jj).C3PO),
        C3PO_status(iw).notdone = C3PO_status(iw).notdone + status(jj).C3PO(iw).notdone;
        C3PO_status(iw).completed = C3PO_status(iw).completed + status(jj).C3PO(iw).completed;
        C3PO_status(iw).running = C3PO_status(iw).running + status(jj).C3PO(iw).running;
    end
end
%
if displaymode,
    disp(['-------------------------------------------------------------------------------------'])
    disp(['-------------------------------------------------------------------------------------'])
    disp(['Simulations status in folder : ',dirsearch]);
    disp(['-------------------------------------------------------------------------------------'])
    disp(['-------------------------------------------------------------------------------------'])
    disp(['Total number of simulations : ',int2str(length(joblist))]);
    for iw = 1:length(C3PO_status)
        disp(['Total number of simulations for wave #',int2str(iw),' not done (C3PO): ',int2str(C3PO_status(iw).notdone)]);
        disp(['Total number of simulations for wave #',int2str(iw),' completed (C3PO): ',int2str(C3PO_status(iw).completed)]);
        disp(['Total number of simulations for wave #',int2str(iw),' running (C3PO) : ',int2str(C3PO_status(iw).running)]);
    end
    disp(['Total number of simulations not done (LUKE): ',int2str(LUKE_status.notdone)]);
    disp(['Total number of simulations completed (LUKE): ',int2str(LUKE_status.completed)]);
    disp(['Total number of simulations running (LUKE) : ',int2str(LUKE_status.running)]);
    disp(['-------------------------------------------------------------------------------------'])
    disp(['-------------------------------------------------------------------------------------'])
    %
    for ii = 1:length(joblist),
        disp([' - id_simul : ',joblist(ii).id_simul]);
        %
        for iw = 1:length(joblist(ii).C3PO)
            if strcmp(joblist(ii).C3PO(iw).status,'C3PO ray tracing calculations not done'),
                disp([' - C3PO (wave #',int2str(iw),') status: **** ',joblist(ii).C3PO(iw).status,' ****']);
            else
                disp([' - C3PO (wave #',int2str(iw),') status: ',joblist(ii).C3PO(iw).status]);
            end
            if strcmp(joblist(ii).C3PO(iw).status,'C3PO ray tracing calculations running'),
                disp([' - C3PO (wave #',int2str(iw),') remote host address : ',joblist(ii).C3PO(iw).host]);
                disp([' - C3PO (wave #',int2str(iw),') remote jobid : ',joblist(ii).C3PO(iw).jobid]);
                disp([' - C3PO (wave #',int2str(iw),') batch directory : ',joblist(ii).C3PO(iw).batch_dir]);
            end
        end
        %
        if strcmp(joblist(ii).LUKE.status,'LUKE Fokker-Planck calculations not done'),
            disp([' - LUKE status: **** ',joblist(ii).LUKE.status, ' ****']);
        else
            disp([' - LUKE status: ',joblist(ii).LUKE.status]);
        end
        if strcmp(joblist(ii).LUKE.status,'LUKE Fokker-Planck calculations running'),
            disp([' - LUKE remote host address : ',joblist(ii).LUKE.host]);
            disp([' - LUKE remote jobid : ',joblist(ii).LUKE.jobid]);
            disp([' - LUKE batch directory : ',joblist(ii).LUKE.batch_dir]);
        end
        %
        disp(['-------------------------------------------------------------------------------------'])
        disp(['-------------------------------------------------------------------------------------'])
    end
end
%
if displaymode
    disp(['Orphan batch directories']);
    disp(['-------------------------------------------------------------------------------------'])
    disp(['-------------------------------------------------------------------------------------'])
end
%
allfileslist = dir;
io = 1;
orphan_batch_dir = '';
%
for ii = 1:length(allfileslist),
    if allfileslist(ii).isdir & strfind(allfileslist(ii).name,'batch_'),
        %
        orphan_batch_dir(io).name = allfileslist(ii).name;
        orphan_batch_dir(io).simul = '';
        orphan_batch_dir(io).code = '';
        orphan_batch_dir(io).status = 1;
        %
        for jj = 1:length(joblist),
            %   
            if strcmp(joblist(jj).LUKE.status,'LUKE Fokker-Planck calculations running'),%LUKE job
                if strcmp(allfileslist(ii).name,joblist(jj).LUKE.batch_dir(1:end-1)),
                    orphan_batch_dir(io).simul = joblist(jj).id_simul;
                    orphan_batch_dir(io).code = 'LUKE';
                    orphan_batch_dir(io).status = 0;
                end
            end
            %
            for iw = 1:length(joblist(jj).C3PO),
                if strcmp(joblist(jj).C3PO(iw).status,'C3PO ray tracing calculations running'),%C3PO job
                    if strcmp(allfileslist(ii).name,joblist(jj).C3PO(iw).batch_dir),
                        orphan_batch_dir(io).simul = joblist(jj).id_simul;
                        orphan_batch_dir(io).code = ['C3PO, wave #',int2str(iw)];
                        orphan_batch_dir(io).status = 0;
                        %
                    end
                end            
            end  
        end
        %
        if displaymode,
            if orphan_batch_dir(io).status == 1,
                disp([' - batch directory : ',orphan_batch_dir(io).name,' is orphan. You can delete it.']);
            end
        end
        %
        io = io + 1;
    end
end
%
cd(dirinit);
%
warning on
%

