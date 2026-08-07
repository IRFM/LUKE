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
function external = load_externaldata_ITM(workdir,shotnum,runnum,shotime,time_interp,opt_gui,select)
%
% This function loads data from ITM MDS+ database (one time slice)
%
if nargin < 7,
    select = struct;
elseif ~isstruct(select) && isempty(select),% no user prompt - default options
    %
end
%
external = '';
basestr = 'ITM';
%
if ~isfield(select,'m_opt'),
    select.m_opt = input_dke_yp('Do you want to: (0) load data from database, (1) load data from files',0,[0,1],'',[1,1]);
end
%
data_path = [workdir,'/'];
%
data_str = ['data_',basestr,'_',shotnum,'_',num2str(t1),'_',num2str(t2)];
%
if select.m_opt == 0,
    %
    data_path = [workdir,'/'];
    %data_file = [data_str,launstr,'.mat'];
    %
    [machine,username,ver] = which_MDSdatabase;%test if the ITM database is correct
    %
    external.mdsdatabase.machine = machine;
    external.mdsdatabase.username = username;
    external.mdsdatabase.ver = ver;
    %
    if  ~isempty(machine) && ~isempty(user) && ~isempty(ver)
        %
%		info_dke_yp(4,['ITM database well connected -> machine: ',machine,', user: ',user,', datastructure version: ',ver]);
		%
        [external.equil.status,external.equil.equil_euitm,external.equil.coreprof_euitm] = read_equil_ITM(numshot,numrun_in,timeslice_equil,time_interp,{'equilibrium','coreprof'},display_mode,save_mode);%Create magnetic equilibrium structure
        %
	else
		external.equil = [];
    end
    %
    
    
    
    
    
    %
else

end
%
% return structure 
%
external.id = ['ITM_',shotnum,'_',runnum,'_',shotime,'_',time_interp];
%
if select.m_opt == 0,
    %
    if ~isfield(select,'s_opt'),
        select.s_opt = input_dke_yp('Do you want to generate an equivalent make_external_ITM script? [y/n]','n',{'y','n'},'',[1,1]);
    end
    %
    if select.s_opt == 'y',
        % 
        %imake_makeexternal_ITM_jd(workdir,external,opt_gui);
        %
    end
end    
%
if isnan_jd(external,0),
    disp('Warning : NaNs were found in the structure ''external'' : ')
    isnan_jd(external,1),
end
%


