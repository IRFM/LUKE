function [s,mod] = imod_struct_jd(s,sname,d_opt)
%
% This function interactively modifies the fields of structure s
%
if nargin < 3,
    d_opt = 1;
end
if nargin < 2,
    sname = '';
end
%
if length(s) ~= 1,
    error('This function applies only to (1,1) structures')
end
%
numlim = 40;%maximum number of elements for horizontal vectors
%
fnames_all = fieldnames(s);
nf_all = length(fnames_all);
%
s = putinfo_yp(s,sname);
%
expert = zeros(1,nf_all);
for iname = 1:nf_all,
    expert(iname) = s.expert.(fnames_all{iname});
end
%
fnames_nexp = fnames_all(~expert);
%
isel = NaN;
mod = 0;
expmode = 0;
%
while isel ~= 0,
    %
    if expmode == 0,
        fnames = fnames_nexp;
        switchstr = 'Enter expert mode (more parameters).';
    else
        fnames = fnames_all;
        switchstr = 'Leave expert mode (main parameters).';
    end
    %
    nf = length(fnames);
    %
    lmax = 0;
    %
    for iname = 1:nf,
        lmax = max([lmax,length(fnames{iname})]);
    end  
    emptstr = repmat(' ',[1,lmax]);
    %
    nmax = length(num2str(nf));
    emptnstr = repmat(' ',[1,nmax]);
    %
    disp(' ');
    disp(['====> Fields of the structure ',sname]);
    disp(' ')
    %
    stype = zeros(1,nf);
    %
    for iname = 1:nf,
        fname = fnames{iname};
        fval = s.(fname);
        %
        if ischar(fval),
            stype(iname) = 1;
            sval = fval;
        elseif isnumeric(fval),
            %
            valsize = size(fval);
            stype(iname) = 6;
            %
            if length(valsize) > 2 | min(valsize) > 1,
                sval = ['< ',num2str(length(valsize)),'-D array >'];
            elseif numel(fval) > numlim
                sval = ['< ',num2str(numel(fval)),' elements vector>'];  
            else
                if valsize(1) > 1,
                    rev = 1;
                    fval = fval(:).';
                else
                    rev = 0;
                end
                stype(iname) = 2;                
                sval = num2str(fval);
            end
            %
        elseif isstruct(fval),
            stype(iname) = 3;
            sval = '< fields structure >';
        elseif iscell(fval),
            stype(iname) = 4;
            sval = '< cell array >';
        else
            stype(iname) = 5;
            sval = '< unidentified type >';
        end
        %
        istr = num2str(iname);
        %
        disp(['[',istr,']',emptnstr(1:nmax-length(istr)),' : ',fname,emptstr(1:lmax - length(fname)),' : ',sval]);
        %
    end
    %
    disp(' ')
    disp(['[-2]',emptnstr(1:nmax-2),' : ',switchstr])
    disp(['[-1]',emptnstr(1:nmax-2),' : get fields info'])
    disp(['[0]',emptnstr(1:nmax-1),' : return structure'])
    disp(' ')
    %
    isel = input_dke_yp('',0,-2:nf);
    disp(' ');
    %
    if isel == -2,
        expmode = ~expmode;
    end
    %
    if isel == -1,
        %
        for iname = 1:nf,
            %
            fname = fnames{iname};
            disp(['- ',fname,emptstr(1:lmax - length(fname)),' : ',getfieldinfo_jd(s,fname)]);
            %
        end
    end
    %
    if isel > 0,
        %
        fname = fnames{isel};
        fval = s.(fname);
        %
        if stype(isel) <= 2,
            %
            disp(['Field : ',fname,' : ',getfieldinfo_jd(s,fname)]);
            [fval,mod] = input_dke_yp(['New value for field : ',fname,' '],fval);
            %
            if stype(isel) == 1 | rev == 0,
                %
                s.(fname) = fval;
                %
            else % rev = 1
                s.(fname) = fval(:);
            end
            %
        elseif stype(isel) == 3,
            %
            if d_opt == 1
                %
                [fval,mod] = imod_struct_jd(fval,fname,1);
                s.(fname) = fval;
                %
            else
                %
                disp(['The substructure ',fname,' cannot be modified.'])
                %
            end
            %
        elseif stype(isel) == 4,
            %
            if d_opt == 1
                %
                [fval,mod] = imod_cell_jd(fval,fname,1);
                s.(fname) = fval;
                %
            else
                %
                disp(['The subcell ',fname,' cannot be modified.'])
                %
            end
            %
        elseif stype(isel) == 5,
            %
            disp(['The type of field ',fname,' cannot be identified.'])
            %
        elseif stype(isel) == 6,
            %
            disp(['Field ',fname,' can be changed on command line only.'])
            %
        end
        %
    end
    %
end
%
    
    
    




