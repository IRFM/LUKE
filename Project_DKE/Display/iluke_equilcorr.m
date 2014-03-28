function equil = iluke_equilcorr(equil)
%
if ~isfield(equil,'tokamak') || ~isfield(equil,'shotnum') || ~isfield(equil,'shotime'),
    %
    % default parameters
    %
    equil.tokamak = 'UNKNOWN';
    equil.shotnum = '0';
    equil.shotime = 0;
    %
    isep = [0,find(equil.id == '_'),length(equil.id)+1];
    nstrs = length(isep) - 1;
    strs = cell(1,nstrs);
    %
    for iisep = 1:nstrs,
        strs{iisep} = equil.id(isep(iisep)+1:isep(iisep+1)-1);
    end
    %
    inum = find(~isnan(str2double(strs)));
    nnum = length(inum);% number of numerical ids
    %
    if nnum > 0,
        %
        equil.shotnum = strs{inum(1)};% shotnum
        %
        if inum(1) > 1,
            equil.tokamak = strs{1};
            for iisep = 2:inum(1)-1,
                equil.tokamak = [equil.tokamak,'_',strs{iisep}];% equil
            end
        end
        %
    end
    %
    if nnum > 1,
        %
        equil.shotime = str2double(strs{inum(2)});% shotnum
        %
    end
end
%
if ~isfield(equil,'ip'),
    equil.ip = NaN;
end