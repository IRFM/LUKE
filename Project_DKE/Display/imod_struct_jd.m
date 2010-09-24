function [s,mod] = imod_struct_jd(s,sname,d_opt,opt_gui)
    %
    % This function interactively modifies the fields of structure s
    %
    if nargin < 4,
        opt_gui = 0;
    end
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
    fexcept = {'info','expert','values'};
    %
    for ifield = 1:length(fexcept),
        if isfield(s,fexcept{ifield}),
            s = rmfield(s,fexcept{ifield});
        end
    end
    %
    numlim = 10;%maximum number of elements for horizontal vectors
    ftsize = 10;%font size
    scsz = get(0,'screensize');
    margin = 40;%marge
    nspaces = 1.5;%number of spaces between fields and pushbuttons
    lfactor = 1.0;%factor between fontsize and width
    lmaxmin = 18;%
    %
    fnames_all = fieldnames(s);
    nf_all = length(fnames_all);
    %
    s = putinfo_yp(s,sname,fexcept);
    %
    expert = zeros(1,nf_all);
    for iname = 1:nf_all,
        expert(iname) = s.expert.(fnames_all{iname});
    end
    %
    nexplist = find(~expert);
    fnames_nexp = fnames_all(nexplist);
    %
    isel = NaN;
    mod = zeros(1,nf_all);
    expmode = 0;
    %
    sinit = s;
    sinitvalues = '';
    sinitstrings = '';
    %
    while isel ~= 0,
        %
        if expmode == 0,
            fnames = fnames_nexp;
            switchstr = 'Enter expert mode (more parameters).';
            guistr = 'expert fields';
        else
            fnames = fnames_all;
            switchstr = 'Leave expert mode (main parameters).';
            guistr = 'main fields';
        end
        %
        buttonstr = {guistr,['reset ',sname],['return ',sname]};
        isellist = [-2,-4,0];
        %
        nf = length(fnames);
        %
        lmax = lmaxmin;
        %
        for iname = 1:nf,
            lmax = max([lmax,length(fnames{iname})]);
        end  
        emptstr = repmat(' ',[1,lmax]);
        %
        nmax = length(num2str(nf))+1;
        emptnstr = repmat(' ',[1,nmax]);
        %
        if ~opt_gui,
            %
            disp(' ');
            disp(['====> Fields of the structure ',sname]);
            disp(' ')
            %
        else
            %
            cwidth = 5*margin + 2*lfactor*lmax*ftsize;% column width
            nfh = fix((scsz(4) - 2*margin)/(3*ftsize) - nspaces);% maximum number of fields per column
            ncl = ceil(max([nf,1])/nfh);% number of columns
            width = cwidth*ncl;%figure width
            %
            if width > (scsz(3) - 2*margin),
                error('Too many fields... improve GUI!')
            end
            %
            nfh = ceil(nf/ncl);% number of fields per column
            height = (nfh+nspaces)*3*ftsize;
            %
            cgui = figure('visible','on','name',sname,'Position',[(scsz(3) - width)/2,(scsz(4) - height)/2,width,height],...
                'menubar','none','numbertitle','off','resize','off');
            %
            cguis = zeros(1,nf);
            cguic = zeros(1,nf);
            cguir = zeros(1,nf+3);
            %
        end
        %
        stype = zeros(1,nf);
        rev = zeros(1,nf);
        %
        for iname = 1:nf,
            fname = fnames{iname};
            fval = s.(fname);
            values = s.values.(fname);
            %
            if islogical(fval) || (iscell(values) && length(values) == 2 && islogical(values{1})),
                stype(iname) = 0;
                if fval,
                    sval = 'true';
                else
                    sval = 'false';
                end
                if isempty(values),
                    values = {true,false};
                end
            elseif ischar(fval),
                stype(iname) = 1;
                sval = fval;
            elseif isnumeric(fval),
                %
                valsize = size(fval);
                stype(iname) = 6;
                %
                if length(valsize) > 2 || min(valsize) > 1,
                    sval = ['< ',num2str(length(valsize)),'-D array >'];
                elseif numel(fval) > numlim
                    sval = ['< ',num2str(numel(fval)),' elements vector>'];  
                else
                    if valsize(1) > 1,
                        rev(iname) = 1;
                        fval = fval(:).';
                    end
                    stype(iname) = 2;                
                    sval = num2str(fval);
                    if isempty(values),
                        values = [-Inf;Inf];
                    end
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
            if ~opt_gui,
                %
                disp(['[',istr,']',emptnstr(1:nmax-length(istr)),' : ',fname,emptstr(1:lmax - length(fname)),' : ',sval]);
                %
            else
                %
                lref = cwidth*fix((iname - 1)/nfh);%left reference position for column
                bref = (((nfh - rem(iname - 1,nfh) - 1)+nspaces)*3 + 0.5)*ftsize;%bottom reference position
                %
                sposition = [lref + margin,bref,cwidth/2  - 2.5*margin,2*ftsize];
                cposition = [lref + cwidth/2  - 0.5*margin,bref,cwidth/2  - 2.5*margin,2*ftsize];
                rposition = [lref + cwidth - 2*margin,bref,margin,2*ftsize];
                %
                cguis(iname) = uicontrol(cgui,'style','text','string',fname,'position',sposition,'tooltipstring',s.info.(fname));
                %
                if stype(iname) == 0,%logical
                    cguic(iname) = uicontrol(cgui,'style','checkbox','string','','value',fval,'position',cposition,'callback',@field_cbf);
                elseif stype(iname) == 1,%string
                    cguic(iname) = uicontrol(cgui,'style','edit','string',sval,'position',cposition,'callback',@field_cbf);
                elseif stype(iname) == 2,%scalar or small vector    
                    if iscell(values) || size(values,1) == 1,
                        if iscell(values),
                            for ielem = 1:length(values),
                                if fval == values(ielem),
                                    break
                                end
                            end
                        else
                            ielem = find(fval == values,1,'first');
                        end
                        % 
                        cguic(iname) = uicontrol(cgui,'style','popupmenu','string',values,'value',ielem,'position',cposition,'callback',@field_cbf);
                    elseif size(values,1) == 2,
                        cguic(iname) = uicontrol(cgui,'style','edit','string',sval,'position',cposition,'callback',@field_cbf);
                    else
                        error('GUI error');
                    end                
                elseif any(stype(iname) == [3:6]),%structure, cell, or large vector or 2D+ array 
                    cguic(iname) = uicontrol(cgui,'style','pushbutton','string',sval,'position',cposition,'callback',@field_cbf);
                    if d_opt == 0,
                        set(cguic(iname),'enable','off');
                    end
                else                       
                    error('GUI error');
                end
                %
                if ~isfield(sinitvalues,fname),
                    sinitvalues.(fname) = get(cguic(iname),'value');
                end
                if ~isfield(sinitstrings,fname),
                    sinitstrings.(fname) = get(cguic(iname),'string');
                end
                %
                cguir(iname) = uicontrol(cgui,'style','pushbutton','string','reset','position',rposition,'tooltipstring','Reset field to original value','callback',@pushbutton_cbf);
                %
            end
            %
        end
        %
        if ~opt_gui,
            %
            disp(' ')
            %
            disp(['[-4]',emptnstr(1:nmax-2),' : Reset structure'])
            disp(['[-3]',emptnstr(1:nmax-2),' : Reset one field'])
            disp(['[-2]',emptnstr(1:nmax-2),' : ',switchstr])
            disp(['[-1]',emptnstr(1:nmax-2),' : Get fields info'])
            disp(['[0]',emptnstr(1:nmax-1),' : Return structure'])
            disp(' ')
            %
            isel = input_dke_yp('',0,-6:nf);
            disp(' ');
            %
        else
            %
            pwidth = min([lfactor*ftsize*(7 + length(sname)),width/3]); 
            %
            rposition1 = [width/6 - pwidth/2,0.5*ftsize,pwidth,2*ftsize];
            rposition2 = [width/2 - pwidth/2,0.5*ftsize,pwidth,2*ftsize];
            rposition3 = [5*width/6 - pwidth/2,0.5*ftsize,pwidth,2*ftsize];
            %
            cguir(nf+1) = uicontrol(cgui,'style','pushbutton','string',buttonstr{1},'position',rposition1,'callback',@pushbutton_cbf);
            cguir(nf+2) = uicontrol(cgui,'style','pushbutton','string',buttonstr{2},'position',rposition2,'tooltipstring','Reset all fields to original value','callback',@pushbutton_cbf);
            cguir(nf+3) = uicontrol(cgui,'style','pushbutton','string',buttonstr{3},'position',rposition3,'tooltipstring','Press to continue when done modifying the structure','callback',@pushbutton_cbf);
            %
        end
        %
        if opt_gui,
            uiwait(cgui);
            delete(cgui);
        end
        %
        if isel == -4,
            s = sinit;
            mod = zeros(1,nf_all);
        end
        %
        if isel == -3,
            locisel = input_dke_yp('Number of the field to reset (enter 0 to cancel)',0,0:nf);
            if locisel > 0,
                s.(fnames{locisel}) = sinit.(fnames{locisel});
                if expmode,
                    mod(locisel) = 0;
                else
                    mod(nexplist(locisel)) = 0;
                end
            end
        end
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
            values = s.values.(fname);
            locmod = 0;
            %
            if stype(isel) <= 2,
                %
                disp(['Field : ',fname,' : ',getfieldinfo_jd(s,fname)]);
                [fval,locmod] = input_dke_yp(['New value for field : ',fname,' '],fval,values);
                %
                if stype(isel) == 0,
                    %
                    s.(fname) = logical(fval);
                    %
                elseif stype(isel) == 1 || rev(isel) == 0,
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
                    [fval,locmod] = imod_struct_jd(fval,fname,1,opt_gui);
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
                    [fval,locmod] = imod_cell_jd(fval,fname,1,opt_gui);
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
            if locmod == 1,
                if expmode,
                    mod(isel) = 1;
                else
                    mod(nexplist(isel)) = 1;
                end
            end
            %
        end
        %
    end
    %
    mod = any(mod);
    s = rminfo(s,fexcept);
    %
    function pushbutton_cbf(hObject,eventdata)
        %
        iname = find(hObject == cguir);
        %
        if iname > nf,
            %
            isel = isellist(iname - nf);
            uiresume
            %
        else
            %
            fname = fnames{iname};
            s.(fname) = sinit.(fname);
            set(cguic(iname),'value',sinitvalues.(fname));
            set(cguic(iname),'string',sinitstrings.(fname));
            if expmode,
                mod(iname) = 0;
            else
                mod(nexplist(iname)) = 0;
            end
            %
        end
        %
    end
    %
    function field_cbf(hObject,eventdata)
        %
        iname = find(hObject == cguic);
        fname = fnames{iname};
        values = s.values.(fname);
        if expmode,
            imod = iname;
        else
            imod = (nexplist(iname));
        end
        %
        if stype(iname) == 0,%logical
            s.(fname) = get(hObject,'value');
            %
            if s.(fname) ~= sinit.(fname),
                mod(imod) = 1;
            end
        elseif stype(iname) == 1,%string
            s.(fname) = get(hObject,'string');
            %
            if ~strcmp(s.(fname),sinit.(fname)),
                mod(imod) = 1;
            end
        elseif stype(iname) == 2,%scalar or small vector    
            % 
            if iscell(values),
                s.(fname) = values{get(hObject,'value')};
            elseif size(values,1) == 1,
                s.(fname) = values(get(hObject,'value'));
            else
                eval(['s.(fname) = ',get(hObject,'string'),';']);
            end
            %
            if rev(iname) == 1,
                s.(fname) = s.(fname).';
            end
            %
            if any(size(s.(fname)) ~= size(sinit.(fname))) || any(s.(fname) ~= sinit.(fname)),
                mod(imod) = 1;
            end            
            %
        elseif stype(iname) == 3,%structure
            [s.(fname),mod(imod)] = imod_struct_jd(s.(fname),fname,d_opt,opt_gui);
        elseif stype(iname) == 4,%cell
            [s.(fname),mod(imod)] = imod_cell_jd(s.(fname),fname,d_opt,opt_gui);
        elseif stype(iname) == 5,%unidentified type 
            disp(['   ---> you can change the field ',fname,' manually. It is stored in the variable ''field''. Press ''return'' to validate.'])
            field = s.(fname);
            keyboard
            s.(fname) = field;
            mod(imod) = 1;
        elseif stype(iname) == 6,%large vector or 2D+ array 
            disp(['   ---> you can change the array ',fname,' manually. It is stored in the variable ''field''. Press ''return'' to validate.'])
            field = s.(fname);
            keyboard
            s.(fname) = field;
            if any(size(s.(fname)) ~= size(sinit.(fname))) || any(s.(fname)(:) ~= sinit.(fname)(:)),
                mod(imod) = 1;
            end                        
        else
            error('GUI error');
        end
        %
    end
    %
end
%
function s = rminfo(s,fexcept)   
    for ifield = 1:length(fexcept),
        if isfield(s,fexcept{ifield}),
            s = rmfield(s,fexcept{ifield});
        end
    end    
    %s = rmfield(s,fexcept);
    fnames = fieldnames(s);
    for iname = 1:length(fnames);
        if isstruct(s.(fnames{iname})),
            s.(fnames{iname}) = rminfo(s.(fnames{iname}),fexcept);
        end
    end
end