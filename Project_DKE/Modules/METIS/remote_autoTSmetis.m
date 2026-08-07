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
function [soutputs]= remote_autoTSmetis(sinputs,gas,time,filename,tprofonoff)
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
    shot = sinputs;
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
            [soutputs.post,soutputs.tprofok] = autoTSmetis(shot,gas,time,filename,tprofonoff);%
            err = '';
            job = '';
            %
        else
            %
            cprintf([1,0.5,0],'---> WARNING: data load may be long if ethernet connection is poor');disp(' ');
            %
            remote.matver.matdef = remote.matver.mat903;%enforce Matlab R2013b for tsbase only
            %
            job = matstandardjob_jd('runmat');
            job.funcopy = false;%since binary is machine specific only local version is used
            %
            [err,job,soutputs.post,soutputs.tprofok] = matremote_jd('autoTSmetis',{shot,gas,time,filename,tprofonoff},remote,job);
            %
            if ~isempty(err)
                %
                soutputs.err = err;
                %
            elseif ~isempty(soutputs.post) && ~isempty(soutputs.tprofok) % job completed
                %
                soutputs = soutputs;
                %
            else
                %
                soutputs.job = job;
                %
            end
            %
        end
        %
    else
        %
         if isempty(remote)
            %
            cprintf('red*','---> CEA computers are unreachable for access to remote_autoTSmetis. Check the connection parameters (ssh).');disp(' ')
            %
        else
            %
            [soutputs.post,soutputs.tprofok] = autoTSmetis(shot,gas,time,filename,tprofonoff);%
            err = '';
            job = '';
            %
        end
        %
    end 
    %
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





