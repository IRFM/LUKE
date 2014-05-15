% script iluke_updateoldsimul
%
% This script updates older simulations
%
if isfield(lukeobj,'r5x2'),% before sdiag
    lukeobj = rmfield(lukeobj,'r5x2');
    %
    status = rmfield(status,'hxr');
    %
    status.sdiag = zeros(2,size(status.output,2));
    status.sdiag(:,status.output == 1) = 1;% synthetic diagnostics need distribution
    %
    sdiags = cell(2,size(outputs,2));
    sdiags(:) = {{}};
    %
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
    