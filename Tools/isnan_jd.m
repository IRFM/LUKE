function test = isnan_jd(var,svar,display_mode,ntab)
    %
    if nargin < 4,
        ntab = 0;
    end
    %
    if nargin < 3,
        display_mode = 0;
    end
    %
    if nargin < 2 || isempty(svar),
        svar = inputname(1);
    end
    %
    test = false;
    %
    if isnumeric(var),
        %
        nannum = sum(isnan(var(:)));
        if nannum > 0,
            disp_jd(display_mode,ntab + 2,['- Field ',svar,' : #NaN = ',num2str(nannum)]);
            test = true;
        end
        %
    elseif isstruct(var),
        %
        disp_jd(display_mode,ntab,['  o recursively checking the structure ',svar])
        %
        fnames = fieldnames(var);
        %
        for ifield = 1:length(fnames),
            %
            fname = fnames{ifield};
            test = isnan_jd(var.(fname),fname,display_mode,ntab + 2) || test;
            %
        end
        %
    elseif iscell(var),
        %
        disp_jd(display_mode,ntab,['  o checking the cell array ',svar,' as structure ',svar])
        %
        var = var(:);
        ncell = length(var);
        fnames = cell(ncell,1);
        %
        for icell = 1:ncell,
            %
            fnames{icell} = ['cell_',num2str(icell)];
            %
        end
        %
        var = cell2struct(var,fnames,1);
        %
        test = isnan_jd(var,svar,display_mode,ntab + 2);
        %
    elseif ~ischar(var),
        %
        disp_jd(display_mode,ntab,['Warning : variable ',inputname(1),' could not be tested : format not recognized']);
        %
    end
    %
end
%
function disp_jd(display_mode,ntab,s)
    %
    if display_mode >= 1,
        disp([repmat(' ',[1,ntab]),s]);
    end
    %
end
