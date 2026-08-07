% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function [soutputs]= remote_mtsbase(sinputs,signals)
%
%LUKE -  Function which load multiple signals from Tore Supra database (work for WEST shot date only). May be used within CEA network or outside by SSH bridge
%
%   Input:
%
%		sinputs : shot number (real number for waiting results or imaginary number for giving hand after launching function and getting back data later) or data structure (with or without job for remote calculations)
%		signals : structure of signal types (ex: {'gphyb','gphase'})
%
%   Output:
%
%       soutputs : signals structure
%
%NOTE : data are save in a file place in a folder whose path is defined by the environment variable 'EXPERIMENTAL_TOKAMAK_DATA'. This variable must
%be defined in the startup file startup.m -> setenv('EXPERIMENTAL_TOKAMAK_DATA','**************')
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
soutputs = [];
%
if nargin < 2
     error('Not enough input argument in remote_mtsbase.m');
end
%
if ~isreal(sinputs)
    %
    shotnumber = imag(sinputs);
    %
else
    %
    shotnumber = sinputs;
    %
end    
%
datapath = getenv('EXPERIMENTAL_TOKAMAK_DATA');%folder path
%
if isempty(datapath)
    %
    warning('The environment variable EXPERIMENTAL_TOKAMAK_DATA must be set in the startup.m file. Otherwise, data are stored locally')
    %
end
%
if ~exist(datapath)
    %
    mkdir(datapath);
    %
end
%
signals = lower(signals);%enforce lower case
%
signals_list = '';
%
for ii = 1:length(signals)
    %
    signals_list = [signals_list,signals{ii},'_'];
    %
end
%
signals_list = signals_list(1:end-1);
%
if exist([datapath,'mtsbase_data_',int2str(shotnumber),'_',signals_list,'.mat'])
    %
    load([datapath,'mtsbase_data_',int2str(shotnumber),'_',signals_list,'.mat'],'data');
    %
    soutputs = data.soutputs;
    %
    return
    %
end
%
if ~isstruct(sinputs)% new job
    %
    remote = remote_cea;
    %
    if isstruct(remote)
        %
        [err,txt] = unix('hostname');
        txt = deblank(txt);
        %
        if ~isempty(strfind(txt,'partenaires')) || ~isempty(strfind(txt,'intra'))
            %
            [soutputs] = mtsbase(shotnumber,signals);
            %
        else
            %
            cprintf([1,0.5,0],'---> WARNING: data load may be long if ethernet connection is poor');disp(' ');
            %
            remote.matver.matdef = remote.matver.mat913;%enforce Matlab R2013b for tsbase only
            %                      
            job = matstandardjob_jd;
            job.env.remotematfnc = 'runmat';
            %
            job.funcopy = true;
            job.localdatapath = [pwd,filesep];
            %
            job.displaymode = 0;
            job.debugmode = 1;
            %
            job.nodes = 1;%number of nodes required
            job.ppn = 1;%number of cores required
            job.memory = 2000;% memory required (in mb) - leave empty if no requirement
            job.walltime = 5;%[];% time required (integers - in hours) - leave empty if no requirement
            job.rempause = 1/60;% in minutes
            %
            if ~isreal(sinputs)
                job.wait = 0;% (0) return hand (1) wait for result
                job.remtimout = 0;% in minutes
                remote.timeout = 0;%Don't wait until job is done
            else
                job.wait = 1;%1;% (0) return hand (1) wait for result
                job.remtimout = 10;% in minutes
            end    
            %
            [err,job,soutputs] = matremote_jd('mtsbase',{shotnumber,signals},remote,job);
            %
            if ~isempty(err)
                soutputs.err = err;
            elseif ~isempty(soutputs) % job completed
                soutputs = soutputs;
            else
                soutputs.job = job;
            end
            %
        end
        %
    else
        %
         if isempty(remote)
            %
            cprintf('red*','---> CEA computers are unreachable for access to TSBase. Check the connection parameters (ssh).');disp(' ')
            %
        else
            %
            [soutputs] = mtsbase(shotnumber,signals);
            %
        end
        %
        cprintf('red*','---> CEA computers are unreachable for access to TSBase. Check the connection parameters (ssh).');disp(' ')
        %
    end 
    %
else %previously running job
    %
    if isfield(sinputs,'job') 
        %
        [err,job,soutputs] = matremote_jd(sinputs.job);
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
%
data.soutputs = soutputs;
%
if length(['mtsbase_data_',int2str(shotnumber),'_',signals_list,'.mat']) > 255
    %
    filename_long = [datapath,'mtsbase_data_',int2str(shotnumber),'_',signals_list,'.mat'];
    filename = [filename_long(1:254),'~'];%truncated name
    %
else
    %
    filename = [datapath,'mtsbase_data_',int2str(shotnumber),'_',signals_list,'.mat'];
    %
end
%
save(filename,'data');
%
if isempty(soutputs)
    %
    disp(['WARNING : mtsbase signals ''',signals_list,''' for discharge #',int2str(shotnumber),' are empty.'])
    %
end




























