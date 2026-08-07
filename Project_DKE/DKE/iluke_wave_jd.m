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
function [waves,it_flag,itn_flag] = iluke_wave_jd(dkepath,equils,wavestructss,calc_mask,wavesolverparam)
%
% Calculate the waves possibly including fluctuations effects 
% May use distributed processing for reducing the overall computational time
%
% INPUT
%    - dkepath structure
%    - equil structures
%    - wavestruct structures
%    - calculation mask
%    - wavesolverparam structure
%
% OUTPUT:
%    - wave structures
%
% By Joan Decker (CEA-DRFC, joan.decker@cea.fr) and Yves Peysson (CEA-DRFC, yves.peysson@cea.fr)
%
if nargin < 5,
    wavesolverparam.clustermode = 0;
end
%
if nargin < 4,
    error('Wrong number of input arguments in iluke_wave_jd.m.');
end
%
it_calc = find(any(calc_mask,1));
%
wavestructs = {};
it_flag = [];
itn_flag = [];
%
for it = it_calc,
    %
    equil = equils{it};
    %
    iw_calc = find(calc_mask(:,it)).';
    %
    if isempty(iw_calc),
        continue
    end
    %
    equil_fit = fitequil_yp(equil);
    %
    if isfield(equil,'fluct') && isfield(equil.fluct,'itnmax'),
        %
        equil_fit.fluct_fit = fitfluct_yp(equil.fluct);
        %
        for itn = 1:equil.fluct.itnmax,
            equil_fit.fluct_fit = fluctphase_yp(equil_fit.fluct_fit);
            %
            for iw = iw_calc,
                wavestructs{end+1} = wavestructss{iw,it};
                wavestructs{end}.equil = equil;
                wavestructs{end}.equil_fit = equil_fit;
                wavestructs{end}.id = [wavestructs{end}.id,'_itn_',num2str(itn)];
                wavestructs{end}.savedir = [pwd,filesep,'WAVE_files'];% use localdatadir?
                %
                it_flag(end+1) = it;
                itn_flag(end+1) = itn;
            end                
        end
    else
        for iw = iw_calc,
            wavestructs{end+1} = wavestructss{iw,it};
            wavestructs{end}.equil = equil;
            wavestructs{end}.equil_fit = equil_fit;
            %
            it_flag(end+1) = it;
            itn_flag(end+1) = 0;
        end                
    end
end
%
dkecluster = clustermode_luke(wavesolverparam.clustermode,'wave_solver_yp',dkepath);%MatLab distributed computing environment
%
if dkecluster.scheduler.mode <= 2,
    [flag,waves] = mdce_run(@wave_solver_yp,{dkepath,'',''},2,wavestructs(:),dkecluster);
else% remote computing
    [flag,waves] = mdce_run(@wave_solver_yp,{'','',''},2,wavestructs(:),dkecluster);
end    
%    

