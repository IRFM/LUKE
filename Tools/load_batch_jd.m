function completed_jobs = load_batch_jd(filename,completed_jobs,savepath)
%
data = load(filename,'lukestructs','dkepath');
%
lukestructs_in = data.lukestructs(:);
%
nruns = length(lukestructs_in);
%
if nargin < 2,
    completed_jobs = zeros(1,nruns);
end
%
for irun = 1:nruns,% load runs in a loop to avoid memory excess
    %
    if completed_jobs(irun) == 0,
        %
        lukestructs = run_lukert(lukestructs_in(irun),data.dkepath);
        lukestructs = lukestructs{1};
        %
        if nargin >= 3,
            path_simul = savepath;
        elseif isfield(lukestructs,'simul') && isfield(lukestructs.simul,'path'),
            path_simul = lukestructs.simul.path;
        else
            path_simul = './';
        end
        %
        if isfield(lukestructs,'job')
            disp(['Remote LUKE still running for case : ',num2str(irun),'/',num2str(nruns)])
        elseif isfield(lukestructs,'err'),
            disp(['Remote LUKE run failed for case : ',num2str(irun),'/',num2str(nruns),' for the following reason :'])
            if iscell(lukestructs.err),
                for ierr = 1:length(lukestructs.err),
                    disp(lukestructs.err{ierr});
                end
            else 
                disp(lukestructs.err);
            end
            completed_jobs(irun) = -1;
        elseif isfield(lukestructs,'output'),
            disp(['Remote LUKE completed for case : ',num2str(irun),'/',num2str(nruns)])
            %
            if isfield(lukestructs.output,'dke_out') && isfield(lukestructs.output.dke_out,'simul') && isfield(lukestructs.output.dke_out.simul,'id'),
                saveid = lukestructs.output.dke_out.simul.id;
            elseif isfield(lukestructs.simul,'id')
                saveid = lukestructs.simul.id;
            else
                saveid = num2str(irun);
            end
            %
            if ~strcmp(path_simul(end),filesep),
                path_simul = [path_simul,filesep];
            end
            savename = [path_simul,'LUKE_RESULTS_',saveid,'.mat'];
            %
            if exist(savename,'file'),
                disp(['Warning : file ',savename,' already exists.'])
                keyboard
            end
            %
            save(savename,'lukestructs','-v7.3');
            info_dke_yp(2,['LUKE Results saved in ',savename]);
            %
            completed_jobs(irun) = 1;
        else
            disp('Remote LUKE status unknown')
            keyboard
        end
        %
    end
end
%
if ~any(completed_jobs == 0),
    delete(filename)
end

