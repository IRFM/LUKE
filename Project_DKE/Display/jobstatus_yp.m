function [joblist,C3PO_status,LUKE_status,dirsearch] = jobstatus_yp(dirsearch,displaymode)
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
        filedata = load(filename{ii},'id_simul','id_simul_o','output','waves','job');
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
                    status(jj).C3PO(iw).notdone = 1;
                elseif isfield(filedata.waves{iw},'rays')
                    joblist(jj).C3PO(iw).status = 'C3PO ray tracing calculations completed';
                    joblist(jj).C3PO(iw).host = '';
                    joblist(jj).C3PO(iw).jobid = NaN;
                    status(jj).C3PO(iw).completed = 1;
                elseif isfield(filedata.waves{iw},'job')
                    joblist(jj).C3PO(iw).status = 'C3PO ray tracing calculations running';
                    if isempty(filedata.waves{iw}.job.remote.host),
                        joblist(jj).C3PO(iw).host = 'local';
                        joblist(jj).C3PO(iw).jobid = filedata.waves{iw}.job.id;
                        status(jj).C3PO(iw).running = 1;
                    else
                        joblist(jj).C3PO(iw).host = filedata.waves{iw}.job.remote.host;
                        joblist(jj).C3PO(iw).jobid = filedata.waves{iw}.job.id;
                        status(jj).C3PO(iw).running = 1;
                    end
                end
            end
        end
        %
        status(jj).LUKE.notdone = 0;
        status(jj).LUKE.completed = 0;
        status(jj).LUKE.running = 0;
        %
        if isempty(filedata.output)
            if isfield(filedata,'job'),
                joblist(jj).LUKE.status = 'LUKE Fokker-Planck calculations running';
                if isempty(filedata.job.remote.host),
                    joblist(jj).LUKE.host = 'local';
                    joblist(jj).LUKE.jobid = filedata.job.id;
                    status(jj).LUKE.running = 1;
                else
                    joblist(jj).LUKE.host = filedata.job.remote.host;
                    joblist(jj).LUKE.jobid = filedata.job.id;
                    status(jj).LUKE.running = 1;
                end
            else
                joblist(jj).LUKE.status = 'LUKE Fokker-Planck calculations not done';
                joblist(jj).LUKE.host = '';
                joblist(jj).LUKE.jobid = NaN;
                status(jj).LUKE.notdone = 1;
            end
        elseif isfield(filedata.output,'Znorm'),
            joblist(jj).LUKE.status = 'LUKE Fokker-Planck calculations completed';
             joblist(jj).LUKE.host = '';
            joblist(jj).LUKE.jobid = NaN;
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
    disp(['-------------------------------------------------------------------------------------'])
    disp(['Simulations status in folder : ',dirsearch]);
    disp(['-------------------------------------------------------------------------------------'])
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
        end
        %
        disp(['-------------------------------------------------------------------------------------'])
        disp(['-------------------------------------------------------------------------------------'])
    end
end
%
cd(dirinit);
%
warning on
%

