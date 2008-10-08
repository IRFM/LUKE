function install_LUKE(pathforstartup)
%LUKE - Installation package script
%
%Install LUKE path in existing default MatLab startup.m and build all *.mat and *.mex files
%
%By Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr) and Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr)
%
if nargin == 0,
    pathforstartup = which('startup.m');%The default directory for startup.m is the same as the always existing startup.m file
    if isempty(pathforstartup),
		%
		% home directory is more appropriate for linux and unix platforms because of accessibility rights
		%
		if strcmp(computer,'PCWIN'),
			pathforstartup = which('pathdef.m');%The default directory for startup.m is the same as the always existing startup.m file
        	pathforstartup = pathforstartup([1:findstr(pathforstartup,'pathdef.m')-1]);
		else
			pathforstartup = '~/';%The default directory for startup.m is the same as the always existing startup.m file
		end
    else
        pathforstartup = pathforstartup([1:findstr(pathforstartup,'startup.m')-1]);
    end
end
%
if strcmp(pathforstartup(end),'/');
    startuppath = [pathforstartup,'startup.m'];
else
    startuppath = [pathforstartup,'/startup.m'];
end
%
if exist(startuppath),%startup.m file already exist
    flag = 0;
	%
	fid = fopen(startuppath,'r+');  
	if fid == -1,
		disp(['Cannot write to startup.m, no permission.']);
		disp(['A new startup.m file will be created in the home or pathdef directory.']);
		disp(['This startup.m file will also call the original statup.m file']);
		%
		origstartuppath = pathforstartup;
		%
		if strcmp(computer,'PCWIN'),
			pathforstartup = which('pathdef.m');%The default directory for startup.m is the same as the always existing startup.m file
        	pathforstartup = pathforstartup([1:findstr(pathforstartup,'pathdef.m')-1]);
		else
			pathforstartup = '~/';%The default directory for startup.m is the same as the always existing startup.m file
		end
		%
		startuppath = [pathforstartup,'startup.m'];
		%
		flag = 2;
		%
	else
		fclose(fid);
	end	
	%
	if exist(startuppath), 
    	fid = fopen(startuppath,'r');  
    	sfile = fread(fid);
		%
    	sf1 = strfind(char(sfile'),'%%%%%%%%%%%%%%%%BEGIN-CALL-OLD-STARTUP%%%%%%%%%%%%%%%');
    	sf2 = strfind(char(sfile'),'%%%%%%%%%%%%%%%%%END-CALL-OLD-STARTUP%%%%%%%%%%%%%%%%');
    	while length(sf1)>0
        	sfile = sfile([1:sf1(1)-1,sf2(1)+53:length(sfile)]);
        	sf1 = strfind(char(sfile'),'%%%%%%%%%%%%%%%%BEGIN-CALL-OLD-STARTUP%%%%%%%%%%%%%%%');
        	sf2 = strfind(char(sfile'),'%%%%%%%%%%%%%%%%%END-CALL-OLD-STARTUP%%%%%%%%%%%%%%%%');
    	end
		%
    	sf1 = strfind(char(sfile'),'%%%%%%%%%%%%%%%%%%%BEGIN-LUKE-PATH%%%%%%%%%%%%%%%%%%%');
    	sf2 = strfind(char(sfile'),'%%%%%%%%%%%%%%%%%%%%END-LUKE-PATH%%%%%%%%%%%%%%%%%%%%');
    	while length(sf1)>0
        	sfile = sfile([1:sf1(1)-1,sf2(1)+53:length(sfile)]);
        	sf1 = strfind(char(sfile'),'%%%%%%%%%%%%%%%%%%%BEGIN-LUKE-PATH%%%%%%%%%%%%%%%%%%%');
        	sf2 = strfind(char(sfile'),'%%%%%%%%%%%%%%%%%%%%END-LUKE-PATH%%%%%%%%%%%%%%%%%%%%');
    	end
		%
    	fclose(fid);
    	fid = fopen(startuppath,'w');  
		fwrite(fid,sfile);
		fclose(fid); 
	end
else,%startup.m file does not exist. It will be created
    flag = 1;
end
%
fid = fopen(startuppath,'a+');%Create or open startup.m file and append LUKE path at the end of the existing startup file
%
if flag == 2,
	fprintf(fid,'%s\n','%%%%%%%%%%%%%%%%BEGIN-CALL-OLD-STARTUP%%%%%%%%%%%%%%%');
	fprintf(fid,'%s\n','initdir = pwd;');
	fprintf(fid,'%s\n',['cd ',origstartuppath]);
	fprintf(fid,'%s\n','startup');
	fprintf(fid,'%s\n','cd(initdir)');
	fprintf(fid,'%s\n','%%%%%%%%%%%%%%%%%END-CALL-OLD-STARTUP%%%%%%%%%%%%%%%%');
end
%
fprintf(fid,'%s\n','%%%%%%%%%%%%%%%%%%%BEGIN-LUKE-PATH%%%%%%%%%%%%%%%%%%%');
localpath = [pwd,'/'];
fprintf(fid,'%s\n',['luke_root = ''',localpath,''';']);
fprintf(fid,'%s\n','addpath([luke_root,''Project_DKE/DKE'']);');
fprintf(fid,'%s\n','addpath([luke_root,''Project_DKE/Database/PATH_files'']);');
fprintf(fid,'%s\n','setpath_luke_jd(luke_root);');
fprintf(fid,'%s\n','%%%%%%%%%%%%%%%%%%%%END-LUKE-PATH%%%%%%%%%%%%%%%%%%%%');
fclose(fid);
%
if flag,
    disp(['A startup.m file has been created in the directory ',pathforstartup,', and the LUKE path has been written in it.']);
else
    disp(['The LUKE path has been written in ',startuppath,'.']);
end
%
% add paths
%
addpath([localpath,'Project_DKE/DKE']);
setpath_luke_jd(localpath,'',1);
addpath([localpath,'Project_DKE/Database/PATH_files']);
%
disp(['The LUKE paths have been installed.']);
%
% Creates and loads the PATH_LOCAL.mat structure 
%
make_path_LOCAL;
dkepath = load_structures_yp('dkepath','','');
luke_root = dkepath.luke_root;
%
% Build *.mat and *.mex files if possible
%
mex_compile_luke(dkepath)
%
cd([luke_root,'Project_DKE/Database']);
make_all;
cd(luke_root);
%
disp(['WARNING: automatic generation of the documentation can be a rather long process !']);
%
opt = input_dke_yp('Do you want to automatically generate the documentation','n',{'y','n'});
%
if opt == 'y',install_doc_LUKE;end
%
opt = input_dke_yp('Do you want to run a simple test case','n',{'y','n'});
%
if opt == 'y',
    %
    cd([luke_root,'Simulations/Benchmarks/TScyl/LH_Karney']);
    rundke;
    cd(dkepath.luke_root);
end



