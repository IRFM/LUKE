function install_LUKE(pathforstartup)
%LUKE - Installation package script
%
%Install LUKE path in existing default MatLab startup.m and build all *.mat and *.mex files
%
%By Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr) and Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr)
%
if nargin < 1,
    pathforstartup = '';
end
%
localpath = [pwd,'/'];
%
spath{1} = sprintf('%s\n','%%%%%%%%%%%%%%%%%%%BEGIN-LUKE-PATH%%%%%%%%%%%%%%%%%%%');
spath{2} = sprintf('%s\n',['luke_root = ''',localpath,''';']);
spath{3} = sprintf('%s\n','addpath([luke_root,''Project_DKE/DKE'']);');
spath{4} = sprintf('%s\n','setpath_luke_jd(luke_root);');
spath{5} = sprintf('%s\n','%%%%%%%%%%%%%%%%%%%%END-LUKE-PATH%%%%%%%%%%%%%%%%%%%%');
%
opt = input('Do you want to setup your startup file automatically (y/n)? ','s');
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
    disp([spath{1},spath{2},spath{3},spath{4},spath{5}])
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
dkepath = load_structures_yp('dkepath','','');
luke_root = dkepath.luke_root;
%
% Build *.mat files
%
cd([luke_root,'Project_DKE/Database']);
make_all;
cd(luke_root);
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
        cd([luke_root,'Project_DKE/Packages/MDCE']);
        test_mdce(2,dkepath);
        cd(dkepath.luke_root); 
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
    %
    opt = input_dke_yp('Do you want to run the test case with distributed calculation of collision integrals','n',{'y','n'});
    %
    if opt == 'y' && isfield(dkepath,'remote'),
    	disp('---------------------------------------------------------------------------')
    	disp('---------------------------DISTRIBUTED COMPUTING---------------------------')
    	disp('---------------------------------------------------------------------------')
    	rundke_cluster;     
    end
	%    
    [machine,user,ver] = which_MDSdatabase(dkepath,1);%Check access to database (Environment variable must be set-up before launching MatLab)
	if ~isempty(machine) && ~isempty(user) && ~isempty(ver),
    	disp('---------------------------------------------------------------------------')
    	disp('--------------------------ACCESS FROM ITM DATABASE-------------------------')
    	disp('---------------------------------------------------------------------------')
   		rundke_ITM;  
    end
    cd(dkepath.luke_root);
end
%
opt = input_dke_yp('Do you want to run all tests and examples (long process, several hours)','n',{'y','n'});
if opt == 'y',
	alltests_LUKE
end
%






