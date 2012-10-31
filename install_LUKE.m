function install_LUKE(pathforstartup)
%LUKE - Installation package script
%
%Install LUKE path in existing default MatLab startup.m, build all *.mat and *.mex files
%build documentation and launch some tests procedure.
%
%By Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr) and Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr)
%
if nargin < 1,
    pathforstartup = '';
end
%
localpath = [pwd,'/'];
%
startuppath = fileparts(which('startup.m'));
%
if isempty(startuppath),
    startup;%create a startup.m file as it does not exist
    startuppath = fileparts(which('startup.m'));
    disp(['WARNING: an empty ''startup.m'' file has been created in the local directory: ',startuppath])
end
%
spath{1} = sprintf('%s\n','%%%%%%%%%%%%%%%%%%%BEGIN-LUKE-PATH%%%%%%%%%%%%%%%%%%%');
spath{2} = sprintf('%s\n','if ~isdeployed,');
spath{3} = sprintf('%s\n',['   luke_root = ''',localpath,''';']);
spath{4} = sprintf('%s\n','   addpath([luke_root,''Project_DKE/DKE'']);');
spath{5} = sprintf('%s\n','   setpath_luke_jd(luke_root);');
spath{6} = sprintf('%s\n','end');
spath{7} = sprintf('%s\n','%%%%%%%%%%%%%%%%%%%%END-LUKE-PATH%%%%%%%%%%%%%%%%%%%%');
%
opt = input('Do you want to setup your startup file automatically (y/n) [y] ? ','s');
if isempty(opt),
    opt='y';
end
%
if strcmp(opt,'y')
    flag = LUKE_startup_jd(spath,pathforstartup);
else
    flag = 2;
end
%
if flag == 2,
    disp('Warning : LUKE paths were not written in a startup file.');
    disp('          Please verify or include manually the following lines in matlab startup :');
    disp(' ');
    %
    cfile = '';
    for ispath = 1:length(spath),
        cfile = [cfile,spath{ispath}];
    end
    %
    disp(cfile)
end
%
% add paths
%
addpath([localpath,'Project_DKE/DKE']);
setpath_luke_jd(localpath);
%
disp('The LUKE paths have been installed.');
%
% Creates and loads the PATH_LOCAL.mat structure, build *.mex files  
%
make_path_LOCAL;
luke_root = dkepath.luke_root;
%
% Build *.mat files
%
%
opt = input_dke_yp('Do you want to rebuild the database (necessary for new installs and upgrades)','y',{'y','n'});
%
if opt == 'y',
    cd([luke_root,'Project_DKE/Database']);
    make_all;
    cd(luke_root);
end
%
% Warning for the external mexfiles
%
dkepathfields1 = fieldnames(dkepath);
%
for ifields1 = 1:length(dkepathfields1)
    if isstruct(dkepath.(dkepathfields1{ifields1})),
        dkepathfields2 = fieldnames(dkepath.(dkepathfields1{ifields1}));
        for ifields2 = 1:length(dkepathfields2)
            if ~isempty(strfind(dkepathfields2{ifields2},'mex')) && ~strcmp(dkepathfields2{ifields2},'helmex'),
                info_dke_yp(6,['Check that all external MEXfiles in ''',dkepath.(dkepathfields1{ifields1}).(dkepathfields2{ifields2}),''' folder have been been well compiled.'],0,'blue');
            end
        end
    end
end
%
disp(['WARNING: automatic generation of the documentation can be a rather long process !']);
%
opt = input_dke_yp('Do you want to automatically generate the documentation','n',{'y','n'});
%
if opt == 'y',
    install_doc_LUKE;
end
%
opt = input_dke_yp('Do you want to test MDCE capabilities','n',{'y','n'});
%
if opt == 'y',
    if isfield(dkepath,'remote'),
        test_mdce(3,1,1);
    else
        disp('No cluster information found.')
    end
end
%
opt = input_dke_yp('Do you want to run a simple test case','y',{'y','n'});
%
if opt == 'y',
    %
    cd([luke_root,'Simulations/Benchmarks/TScyl/LH_Karney']);
    disp('---------------------------------------------------------------------------')
    disp('---------------------------SEQUENTIAL COMPUTING----------------------------')
    disp('---------------------------------------------------------------------------')
    rundke;
    cd(dkepath.luke_root);
end
%
opt = input_dke_yp('Do you want to run the test case with distributed calculation of collision integrals','n',{'y','n'});
%
if opt == 'y' && isfield(dkepath,'remote'),
	cd([dkepath.luke_root,'Simulations/Benchmarks/TScyl/LH_Karney']);
	disp('---------------------------------------------------------------------------')
	disp('---------------------------DISTRIBUTED COMPUTING---------------------------')
    disp('---------------------------------------------------------------------------')
    rundke_cluster;
    cd(dkepath.luke_root);
elseif opt == 'y' && ~isfield(dkepath,'remote'),
	warning('The field ''remote'' must exist in the dkepath structure !')
end
%
[machine,user,ver] = which_MDSdatabase(dkepath,1);%Check access to database (Environment variable must be set-up before launching MatLab)
if ~isempty(machine) && ~isempty(user) && ~isempty(ver),
	%
	opt = input_dke_yp('Do you want to run the test case with a magnetic equilibrium downloaded from the ITM database','n',{'y','n'});
	%
	if opt == 'y',
		cd([luke_root,'Simulations/Benchmarks/TScyl/LH_Karney']);
    	disp('---------------------------------------------------------------------------')
    	disp('--------------------------ACCESS FROM ITM DATABASE-------------------------')
    	disp('---------------------------------------------------------------------------')
   		rundke_ITM;
   		cd(dkepath.luke_root);
   	end
end
%
opt = input_dke_yp('Do you want to run all tests and examples (long process, several hours)','n',{'y','n'});
if opt == 'y',
	alltests_LUKE
end
%
info_dke_yp(1,'The installation of LUKE is successfully done',1,'green');





