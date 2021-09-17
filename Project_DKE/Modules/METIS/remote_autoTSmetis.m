function [soutputs]= remote_autoTSmetis(sinputs,gas,time,filename,tprofonoff,remote_enforce,cluster)
%function [post,tprofok]= remote_autoTSmetis(sinputs,gas,time,filename,tprofonoff,remote_enforce,cluster)
%
%LUKE -  Function which load signals from Tore Supra database using METIS as interface (shot number < 30000, CEA intranet only, shot number >= 30000, CEA intranet or extranet) 
%
%   Input:
%
%		sinputs : shot number (real number for waiting results or imaginary number for giving hand after launching function and getting back data later) or data structure (with or without job for remote calculations)
%		gas : 1 = D & 2 = He, if isempty or missing switch to automatic selection.
%		time : time slices for calculation. If isempty or missing, use default time slices vector of METIS. If is scalar, compute steady state solution for this selected time.
%		filename : optionnal file name in which METIS data are saved (without extension .mat)
%		tprofonoff : optional control of TPROF use. If = 0, METIS will run without TPROF profiles even if some TPROF run exist.
%		remote_enforce : enforce remote calculation
%           (default = 0)
%       cluster : CEA cluster (SIRRAH) or CEA cluster (ANDROMEDE)
%
%   Output:
%
%       soutputs : output structure
%
%   Output of autoTSmetis:
%
%		post: standard METIS data structure
%       tprofok: flag set to 1 if TPROF data are used
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
if nargin < 1,
     error('Not enough input argument in remote_autoTSmetis.m');
end
%
if ~isstruct(sinputs)% new job
    %
    if nargin < 2
        gas = '';
    end
    if nargin < 3
        time = '';
    end
    if nargin < 4
        filename = '';
    end
    %
    if nargin < 5
        tprofonoff = '';
    end
    if nargin < 6    
        remote_enforce = 1;
    end
    if nargin < 7
        cluster = 'ALTAIR';
    end
    %
    if isreal(sinputs) % shot number
        shot = sinputs;%
    else
        shot = imag(sinputs);%
    end
    %
    if shot < 20000 %30000 to be tested
        cluster = 'SIRRAH';%experimental data are in files only
    end
    %
    remote_profile_ANDROMEDE = remote_CEA_ANDROMEDE;
    remote_profile_ALTAIR = remote_CEA_ALTAIR;
    remote_profile_SIRRAH = remote_CEA_SIRRAH;
    %
    if remote_enforce == 0
        %
        [err_ALTAIR,txt_ALTAIR] = unix(['ssh -Y ',remote_profile_ALTAIR.remoteuser,'@',remote_profile_ALTAIR.host,' "hostname"']);%Zone partenaire
        [err_ANDROMEDE,txt_ANDROMEDE] = unix(['ssh -Y ',remote_profile_ANDROMEDE.remoteuser,'@',remote_profile_ANDROMEDE.host,' "hostname"']);%Zone partenaire
        [err_SIRRAH,txt_SIRRAH] = unix(['ssh -Y ',remote_profile_SIRRAH.remoteuser,'@',remote_profile_SIRRAH.host,' "hostname"']);%Zone intra
        err = err_ALTAIR + err_ANDROMEDE + err_SIRRAH;
        %
        if err == 0, 
            txt = txt_SIRRAH;%the client is connected to CEA intranet
        else
            if shot >= 20000 %30000 (to be checked)
                if err_ANDROMEDE == 0 || err_ALTAIR == 0,
                    txt = txt_ALTAIR;%the client computer can connect directly to CEA extranet.
                else
                    txt = '';%the client computer cannot connected directly to CEA extranet. May be by a SSH bridge.
                end
            else
                error(['Shot number : ',num2str(shot),' is not accessible from CEA extranet (CEA intranet only for discharge numbers < 30000)'])
            end
        end
    else
        err = 0;
        err_ALTAIR = '';
        err_ANDROMEDE = '';
        err_SIRRAH = '';
        txt = '';
    end
    %
    soutputs = [];
    %
    [err_local,txt_local] = unix('hostname');%local client machine
    %
    if strcmp(txt_local,txt),%client on the server machine. Direct connection possible
        remote_enforce = 0;
    end
    %
    if err==0,
        %
        if ~isempty(txt) && remote_enforce == 0,%when connected directly from the CEA network
                [soutputs.post,soutputs.tprofok] = autoTSmetis(shot,gas,time,filename,tprofonoff);%
                err = '';
                job = '';
        else
            %
            disp('WARNING: data load may be long if ethernet connection is poor');
            %
            dkepath = load_structures_yp('dkepath','','');
            %
            if isreal(sinputs)
                remote_mode = 'direct';%
            else
                remote_mode = 'pbs';
            end
            %
            for iprof = 1: length(dkepath.profilestr)
                if strcmp(cluster,'ALTAIR'),
                    if strfind(dkepath.profilestr{iprof},['CEA_ALTAIR : ',remote_mode]),%connect to ALTAIR
                        break
                    end
                elseif strcmp(cluster,'ANDROMEDE'),
                    if strfind(dkepath.profilestr{iprof},['CEA_ANDROMEDE : ',remote_mode]),%connect to ANDROMEDE
                        break
                    end
                elseif strcmp(cluster,'SIRRAH'),
                    if strfind(dkepath.profilestr{iprof},['CEA_SIRRAH : ',remote_mode]),%connect to SIRRAH
                        break
                    end
                end
            end
            %
            scheduler.remnum = iprof;
            %
            remote = dkepath.remote(scheduler.remnum);
            if remote_enforce == 0
                remote.link_mode='';
            else
                remote.link_mode=1;
            end
            %
            %
            remote.matver.matdef = remote.matver.mat802;%enforce Matlab R2013b for tsbase only
            remote.matver.matdef = remote.matver.mat802;%enforce Matlab R2013b for tsbase only
            %
            job = matstandardjob_jd('runmat');
            job.funcopy = false;%since binary is machine specific only local version is used
            %
            if ~isreal(sinputs)
                %
                shotnumber = imag(sinputs);
                %
                job.wait = 0;% (0) return hand (1) wait for result
                job.nodes = 1;%number of nodes required
                job.ppn = 1;%number of cores required
                job.memory = 2000;% memory required (in mb) - leave empty if no requirement
                job.walltime = 5;%[];% time required (integers - in hours) - leave empty if no requirement
                job.rempause = 1/60;% in minutes
                job.remtimout = 0;% in minutes
            else
                %
                shotnumber = sinputs;
                %
            end    
            %
            [err,job,soutputs.post,soutputs.tprofok] = matremote_jd('autoTSmetis',{shot,gas,time,filename,tprofonoff},remote,job);
            %
            if ~isempty(err)
                soutputs.err = err;
            elseif ~isempty(soutputs.post) && ~isempty(soutputs.tprofok) % job completed
                soutputs = soutputs;
            else
                soutputs.job = job;
            end
            %
        end    
    end
else %previously running job
    %
    if isfield(sinputs,'job') 
        %
        [err,job,soutputs.post,soutputs.tprofok] = matremote_jd(sinputs.job);
        %
        if ~isempty(err) 
            soutputs.err = err;
        elseif ~isempty(soutputs) % job completed
            soutputs = soutputs;
        else
            soutputs.job = job;
        end
        %
   else% previously completed jobs
        %
        soutputs = sinputs;
        %
    end
    %
end
