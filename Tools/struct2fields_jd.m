%
% this script dismantle a structure into its fields in separate variables
%
sname = input('name of the structure to dismantle (leave empty to iteratively dismantle all structures in the workspace) : ','s');% input variable name
%
if ~isempty(sname),
    if ~exist(sname,'var'),%
        error(['The variable ',sname,' is not in the current workspace']);
    else
        eval(['s = ',sname]);
        if ~isstruct(s),
            error(['The variable ',sname,' is not in a structure']);
        else
            clear s
        end
    end
end
%
flag = true;
is2fjd = 0;
%
while flag,
    %
    if isempty(sname),
        %
        swhos = whos;
        %
        locsname = '';
        %
        for ivar = 1:length(swhos),
            %
            if strcmp(swhos(ivar).class,'struct'),
                %
                locsname = swhos(ivar).name;
                %
                break
                %
            end
            %
        end
        %
        clear swhos ivar
        %
    else
        %
        locsname = sname;
        %
        flag = false;
        %
    end
    %
    if isempty(locsname)
        %
        flag = false;
        %
    else
        %
        eval(['fnames = fieldnames(',locsname,');'])
        %
        for iname = 1:length(fnames),
            %
            fname = fnames{iname};% field name
            %
            if isempty(sname),
                if length(locsname) > 6 && strcmp(locsname(1:6),'s2fjd_'),
                    locfname = [s2fjd{str2double(locsname(7:end))},'_',fname];
                else
                    locfname = [locsname,'_',fname];
                end
            else
                locfname = fname;
            end
            %
            if length(locfname) > 63,
                %
                is2fjd = is2fjd + 1;
                s2fjd{is2fjd} = locfname;
                locfname = ['s2fjd_',num2str(is2fjd)];
                %
            end
            %
            eval([locfname,' = ',locsname,'.',fname,';'])
            %
            disp(['The variable ',locfname,' has been created .']);
            %
        end
        %    
        clear(locsname)
        %
        clear locfname locsname fname iname fnames
        %
    end
end
%
clear flag sname
%
swhos = whos;
nvar = length(swhos);
varsize = NaN(1,nvar);
varlength = NaN(1,nvar);
%
for ivar = 1:nvar,
    %
    varsize(ivar) = swhos(ivar).bytes;
    %
    swhoname = swhos(ivar).name;
    %
    if length(swhoname) > 6 && strcmp(swhoname(1:6),'s2fjd_'),
        varlength(ivar) = length(s2fjd{str2double(swhoname(7:end))});
    else
        varlength(ivar) = length(swhoname);
    end
    %
end
%
[varsize,isort] = sort(varsize);%,2,'descend'
displength = max(varlength);
%
disp(' ')
disp('List of variables : ')
disp('--------------------')
disp(' ')
%
for ivar = 1:nvar,
    %
    swho = swhos(isort(ivar));
    %
    if length(swho.name) > 6 && strcmp(swho.name(1:6),'s2fjd_'),
        swhoname = s2fjd{str2double(swho.name(7:end))};
    else
        swhoname = swho.name;
    end
    %
    disp([' - ',swhoname,repmat(' ',[1,displength - varlength(isort(ivar))]),': ',num2str(swho.bytes)])
    %
end







