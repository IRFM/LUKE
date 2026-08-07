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
% script iluke_updateoldsimul
%
% This script updates older simulations
%
if isfield(lukeobj,'r5x2'),% before sdiag
    lukeobj = rmfield(lukeobj,'r5x2');
    %
    status = rmfield(status,'hxr');
    %
end
%
if ~isfield(load([pathname,filename],'sdiags'),'sdiags'),
    sdiags = cell(2,size(outputs,2));
    sdiags(:) = {{}};
    %
    status.sdiag = zeros(2,size(status.output,2));
    status.sdiag(:,status.output == 1) = 1;% synthetic diagnostics need distribution
    %
end
%
if isempty(hxr.param),
    hxr.param = load_structures_yp('hxrparam','STANDARD','');
end
%
ntimes = length(shotimes);
%
if ~isfield(load([pathname,filename],'dkeparams'),'dkeparams'),% old wavestructss
    %
    load([pathname,filename],'dkeparam');
    dkeparams = cell(1,ntimes);
    %
    for it = 1:ntimes,
        %
        dkeparams{it} = dkeparam;
        %
    end
    %
    clear dkeparam
    %
end    
%
if ~isfield(load([pathname,filename],'wavestructids'),'wavestructids'),% old wavestructss
    %
    newwavestructids = cell(0,1);
    newwavestructsstatus = zeros(0,ntimes);
    newwavestructss = cell(0,ntimes);
    %
    for it = 1:ntimes,
        for iw = 1:length(wavestructss{it});
            %
            wavestruct = wavestructss{it}{iw};
            %
            isel = find(strcmp(wavestruct.id,newwavestructids));% compare with existing wavestructids
            %
            if isempty(isel),% wavestruct id is not listed in newwavestructids
                %
                newwavestructids{end+1,1} = wavestruct.id;
                %
                newwavestructsstatus(end+1,:) = zeros(1,ntimes);
                newwavestructss(end+1,:) = cell(1,ntimes);
                %
                newwavestructsstatus(end,it) = 1;
                newwavestructss{end,it} = wavestruct;
                %
            else% wavestruct id is listed in newwavestructids
                %
                newwavestructsstatus(isel,it) = 1;
                newwavestructss{isel,it} = wavestruct;
                %
            end
        end
    end
    %
    wavestructids = newwavestructids;
    status.wavestructs = newwavestructsstatus;
    wavestructss = newwavestructss;
    %
    clear newwavestructids newwavestructsstatus newwavestructss it iw isel wavestruct
end    
%
if ~isfield(status,'fluct'),
    status.fluct = zeros(1,ntimes);
    fluctparams = cell(1,ntimes);
end
    