function [s,spath,sfileid,newstruct] = imake_struct_jd(s,sname,spath,sfileid,equil,basestr,smakecmd,external,status,sbase,workdir,sdefault,opt_gui,opt_multi,opt_id,d_opt,e_opt)
%
% This function is the general interactive function for the structure s.
%
%
if nargin < 17,
    e_opt = 1;
end
if nargin < 16,
    d_opt = 1;
end
if nargin < 15,
    opt_id = 1;
end
if nargin < 14,
    opt_multi = 0;
end
if nargin < 13,
    opt_gui = 1;
end
if nargin < 12,
    sdefault = '';
end
if nargin < 11,
    workdir = pwd;
end
if nargin < 10,
    sbase = '';
end
if nargin < 9,
    status = 0;
end
if nargin < 8,
    external = '';
end
if nargin < 7,
    smakecmd = '';
end
if nargin < 6,
    error('Not enough arguments.');
end
%
newstruct = 0;
%
if e_opt && isempty(equil),
    disp(['-----> An equilibrium structure must exist to create a ''',sname,''' structure.']);
    return
end
%
ns = length(s);
%
if e_opt,
    sbase_eq = [sbase,'_',equil.id];
else
    sbase_eq = sbase;
end
%
%
% Case of a single structure
%
if opt_multi == 0,
    if status == 1,
        %
        if isempty(sfileid),
            disp(['The current structure ''',sname,''' is not saved separately in a file.'])
        else
            disp(['The current structure ''',sname,''' is saved in the file: ',spath,sbase_eq,'_',sfileid,'.mat']);
        end
        %
        m_opt = input_dke_yp(['Do you want to: \n(-1) clear the existing ''',sname,''' structure \n(0) see/modify/save the ''',sname,''' structure \n(1) load an existing ''',sname,''' structure \n(2) build a new ''',sname,''' structure\n(3) return to the main menu\n'],0,[-1,0,1,2,3]);
        %
    else
        %
        m_opt = input_dke_yp(['Do you want to: \n(1) load an existing ''',sname,''' structure \n(2) build a new ''',sname,''' structure\n(3) return to the main menu\n'],1,[1,2,3]);
        %
    end
%
% Case of multiple structures
%
else
    if status == 1,
        %
        for is = 1:length(s),
            sstr = ['--> ',sname,' # ',num2str(is),'; id : ',s{is}.id,'; '];
            if isempty(sfileid{is}),
                disp([sstr,'This structure is not saved separately in a file.'])
            else
                disp([sstr,'This structure is saved in the file: ',spath{is},sbase_eq,'_',sfileid{is},'.mat']);
            end
        end
        %
        m_opt = input_dke_yp(['Do you want to: \n(-1) clear existing ''',sname,''' structures \n(0) see/modify/save a ''',sname,''' structure \n(1) load existing ''',sname,''' structures \n(2) build a new ''',sname,''' structure\n(3) return to the main menu\n'],0,[-1,0,1,2,3]);
        %
    else
        %
        m_opt = input_dke_yp(['Do you want to: \n(1) load existing ''',sname,''' structures \n(2) build a new ''',sname,''' structure\n(3) return to the main menu\n'],1,[1,2,3]);
        %
    end
end
%
if m_opt == -1,
    %
    if opt_multi == 0,
        %
        s = '';
        spath = '';
        sfileid = '';
        newstruct = 1;
        %
        disp(['-----> The structure ''',sname,''' is cleared.'])
        %
    else
        %
        c_list = input_dke_yp(['Provide the vector of structure ''',sname,''' numbers to be cleared '],1:ns,[1;ns]);
        %
        s(c_list) = [];
        spath(c_list) = [];
        sfileid(c_list) = [];
        %
        if length(c_list) >= 1,
            newstruct = 1;
            %
            disp(['-----> The structures ''',sname,''' # ',num2str(c_list),' are cleared.'])
            %
        end
        %
    end
    %
    return
end
%
if m_opt == 1,
    %
    %if isempty(sdefault),
    %    sdefault = [workdir,sbase_eq,'*.mat'];
    %end
    %
    [s_new,path_new,file_new] = iload_struct_jd(sname,sbase,sdefault,opt_gui,opt_multi,opt_id);
    %
    if ~isempty(s_new),
        %
        if opt_multi == 0,
            %
            s = s_new;
            %
            istr = strfind(file_new,sbase_eq);
            if ~isempty(istr),
                spath = path_new;
                sfileid = file_new(length(sbase_eq)+istr+1:end-4);
            else% no file id specified because the format is not compatible with rundke
                spath = '';
                sfileid = '';
            end
            %
            newstruct = 1;
            %
            c_opt = input_dke_yp(['Do you want to see/modify/save the ''',sname,''' structure (y/n)'],'n',{'y','n'});
            %
            if strcmp(c_opt,'y'),
                m_opt = 0;
            end
            %
        else
            %
            ns_new = length(s_new);
            %
            s = [s,s_new];
            spath = [spath,repmat({''},[1,ns_new])];
            sfileid = [sfileid,repmat({''},[1,ns_new])];
            %
            for is = 1:ns_new,
                istr = strfind(file_new{is},sbase_eq);
                if ~isempty(istr),
                    spath{end - ns_new + is} = path_new{is};
                    sfileid{end - ns_new + is} = file_new{is}(length(sbase_eq)+istr+1:end-4);
                end
            end
            %
            newstruct = 1;
            %
        end
        %
    end
    %
elseif m_opt == 2,
    %
    if isempty(smakecmd)
        disp('No make command is available for this structure');
        s_new = '';
    else
        if ~isstruct(external) && any(isnan(external)),
            s_new = feval(smakecmd,basestr,workdir,opt_gui);
        elseif isfield(external,sname),
            s_new = feval(smakecmd,basestr,equil,external.(sname),workdir,opt_gui);
        else
            s_new = feval(smakecmd,basestr,equil,'',workdir,opt_gui);
        end
    end
    %
    if ~isempty(s_new),
        %
        disp(['-----> The structure ''',sname,''' has been created']);
        %
        if opt_multi == 0,
            %
            s = s_new;
            %
        else
            %
            s = [s,{s_new}];
            %
        end
        %
        newstruct = 1;
        m_opt = i;
        %
    end
    %
end
%
if real(m_opt) == 0,
    %
    if opt_multi == 0,
        %
        [s,mod] = imod_struct_jd(s,sname,d_opt);
        %
        if mod == 1,
            %
            if ~isfield(s,'id'),
                s.id = '';
            end
            %
            s.id = input_dke_yp(['Please provide a new id for the ''',sname,''' structure'],s.id);
            newstruct = 1;
            %
        end
        %
        if e_opt && isfield(equil,'id'),
            id_s = [equil.id,'_',s.id];
        else
            id_s = s.id;
        end
        %
        [path_new,file_new] = isave_struct_jd(s,sname,sbase,id_s,workdir,opt_gui);
        %
		istr = strfind(file_new,sbase_eq);
		%
		if ~isempty(istr),
			spath = path_new;
			sfileid = file_new(length(sbase_eq)+istr+1:end-4);
		else% no file id specified because the format is not compatible with rundke
			spath = '';
			sfileid = '';
		end
        %
    else
        %
        if imag(m_opt) == 0,
            is = input_dke_yp(['Provide the number of the structure ''',sname,''' to be seen/modified/saved '],1,[1;ns]);            
        else
            is = ns + 1;
        end
        %
        [s{is},mod] = imod_struct_jd(s{is},sname,d_opt);
        %
        if mod == 1,
            %
            s{is}.id = input_dke_yp(['Please provide a new id for the ''',sname,''' structure'],s{is}.id);
            newstruct = 1;
            %
        end
        %
        if e_opt && isfield(equil,'id'),
            id_s = [equil.id,'_',s{is}.id];
        else
            id_s = s.id;
        end
        %
        [path_new,file_new] = isave_struct_jd(s{is},sname,sbase,id_s,workdir,opt_gui);
        %
		istr = strfind(file_new,sbase_eq);
		%
        if ~isempty(istr),
			spath{is} = path_new;
			sfileid{is} = file_new(length(sbase_eq)+istr+1:end-4);
		else% no file id specified because the format is not compatible with rundke
			spath{is} = '';
			sfileid{is} = '';
		end
        %
    end
    %
end
%