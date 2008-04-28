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
fnames = fieldnames(s);
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
isel = NaN;
mod = 0;
%
nmax = length(num2str(nf));
emptnstr = repmat(' ',[1,nmax]);
%
while isel ~= 0,
    %
    disp(' ');
    disp(['====> Fields of the structure ',sname]);
    disp(' ')
    %
    stype = zeros(1,nf);
    %
    for iname = 1:nf,
        fname = fnames{iname};
        fval = getfield(s,fname);
        %
        if ischar(fval),
            stype(iname) = 1;
            sval = fval;
        elseif isnumeric(fval),
            stype(iname) = 2;
            sval = num2str(fval);
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
    disp(['[-1]',emptnstr(1:nmax-2),' : get fields info'])
    disp(['[0]',emptnstr(1:nmax-1),' : return structure'])
    disp(' ')
    %
    isel = input_dke_yp('',0,-1:nf);
    disp(' ');
    %
    if isel == -1,
        %
        s = putinfo_yp(s);
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
        fval = getfield(s,fname);
        %
        if stype(isel) <= 2,
            %
            [fval,mod] = input_dke_yp(['New value for field : ',fname,' '],fval);
            %
            s = setfield(s,fname,fval);
            %
        elseif stype(isel) == 3,
            %
            if d_opt == 1
                %
                [fval,mod] = imod_struct_jd(fval,fname,1);
                s = setfield(s,fname,fval);
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
                s = setfield(s,fname,fval);
                %
            else
                %
                disp(['The subcell ',fname,' cannot be modified.'])
                %
            end
            %
        else
            %
            disp(['The type of field ',fname,' cannot be identified.'])
            %
        end
        %
    end
    %
end
%
    
    
    




