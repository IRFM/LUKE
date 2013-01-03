function startup_project(project_root,pmode_in,smode_in)
%LUKE -  Function which allows to swap between different LUKE branches or
%versions (interative mode if no arguments). This function must be placed at the
% of the startup.m file. All projects should be placed in the same
% directory
%
% This function allows to swap between different LUKE branches or versions
% (interative mode if no arguments). This function must be placed at the
% of the startup.m file. All projects should be placed in the same
% directory
%
%   INPUT :
%
%       - project_root: project directory [1,1])
%           (default = pwd)
%       - pmode_in: project name [1,1])
%       - smode_in: working directory number [1,1]
%
%   OUTPUT : none
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr> and J. Decker (CEA/DSM/IRFM) <joan.decker@cea.fr>
%
%
clc
close all
%
startup;%load already existing startup file.
%
flag = 0;
%
if nargin == 0,
    project_root = pwd;%where the LUKE projects are located
end
%
project_list = dir(project_root);%list all projects (including LUKE ones)
%
ipmode_menu = 1;
%
for ilist = 1:length(project_list),
    if strfind(project_list(ilist).name,'LUKE') & project_list(ilist).isdir,
        if ~strcmp(project_list(ilist).name,'LUKE_SIMULATIONS'),%LUKE_SIMULATIONS is not a LUKE project
            pmode_menu_item{ipmode_menu} = project_list(ilist).name;
            ipmode_menu = ipmode_menu + 1;
        end
    end
end
%
pmode_menu0 = ['Choose a project:',char(10)];
%
for ilist = 1:ipmode_menu-1,
    pmode_menu0 = [pmode_menu0,' (',int2str(ilist),') ',pmode_menu_item{ilist},char(10)];
end
pmode_menu = [pmode_menu0,' (',int2str(ipmode_menu),') NO PROJECT',char(10)];
%
if nargin == 1,
    pmode = 0;
    %
    pmode_menu = [pmode_menu,' ? '];
    %
    while pmode == 0,
        pmode = input(pmode_menu);
        if pmode == ipmode_menu,%NO PROJECT case
            clc;
            close all;
            clear all;
            disp('The Matlab path has been cleaned any LUKE project !');
            luke_paths_clean;
            return;
        elseif pmode > ipmode_menu | pmode < 1,
            clc
            disp('WARNING: Unknown project !');
            pmode = 0;
        else
            break;
        end
    end
else 
    pmode_in = find(strcmp(pmode_menu_item,pmode_in)>0);
    %
    if pmode_in <= ipmode_menu-1 & pmode_in >= 1
        pmode = pmode_in;
        %
        disp(['Path set-up for ',pmode_menu_item{pmode},' project.'])
    else
        clc
        disp('WARNING: the requested project is not existing !');
        disp(pmode_menu0);      
        return;
    end
end
%
% Set-up LUKE environment
%
lukebranch = pmode_menu_item{pmode};
%
luke_paths_clean;
%
% Set new path (specific LUKE branch)
%
cd(fullfile(project_root,lukebranch));
luke_root = [pwd,'/'];
addpath(fullfile(luke_root,'Project_DKE','DKE'));
addpath(fullfile(luke_root,'Project_DKE','Database','PATH_files'));
setpath_luke_jd(luke_root);
%
[lukeversion,matver] = LUKEversion_jd;
[status,message_net] = unix('uname -n');%Network name of the machine
%
addpath(fullfile(luke_root,'Project_DKE','MEX','Bin',message_net(1:end-1),['MATLAB',matver],'/'));
%
clc
%
startuppath = which('startup.m');%The default directory for startup.m is the same as the always existing startup.m file
%
if exist(startuppath),%startup.m file already exist
    flag = 0;
	%
	fid = fopen(startuppath,'r+');  
	if fid == -1,
		disp(['Cannot write to startup.m, no permission.']);
		disp(['A new startup.m file will be created in the home or pathdef directory.']);
		disp(['This startup.m file will also call the original startup.m file']);
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
fprintf(fid,'%s\n','if ~isdeployed,');
fprintf(fid,'%s\n',['   luke_root = ''',localpath,''';']);
fprintf(fid,'%s\n','   addpath([luke_root,''Project_DKE/DKE'']);');
fprintf(fid,'%s\n','   addpath([luke_root,''Project_DKE/Database/PATH_files'']);');
fprintf(fid,'%s\n','   setpath_luke_jd(luke_root);');
fprintf(fid,'%s\n','end');
fprintf(fid,'%s\n','%%%%%%%%%%%%%%%%%%%%END-LUKE-PATH%%%%%%%%%%%%%%%%%%%%');
fclose(fid);
%
% menu for the working directory
%
smode_menu0 = ['Choose a working directory:',char(10)];
smode_menu0 = [smode_menu0,'  (1) PACKAGES',char(10)];
smode_menu0 = [smode_menu0,'  (2) PROJECT_DKE',char(10)];
smode_menu0 = [smode_menu0,'  (3) PROJECT_DKE/DATABASE',char(10)];
smode_menu0 = [smode_menu0,'  (4) PROJECT_DKE/DISPLAY',char(10)];
smode_menu0 = [smode_menu0,'  (5) PROJECT_DKE/DKE',char(10)];
smode_menu0 = [smode_menu0,'  (6) PROJECT_DKE/MEX',char(10)];
smode_menu0 = [smode_menu0,'  (7) PROJECT_DKE/MODULES',char(10)];
smode_menu0 = [smode_menu0,'  (8) PROJECT_DKE/PACKAGES',char(10)];
smode_menu0 = [smode_menu0,'  (9) SIMULATIONS/BENCHMARKS',char(10)];
smode_menu0 = [smode_menu0,' (10) SIMULATIONS/EXAMPLES',char(10)];
smode_menu0 = [smode_menu0,' (11) TOOLS',char(10)];
smode_menu0 = [smode_menu0,' (12) LUKE_SIMULATIONS',char(10)];
smode_menu0 = [smode_menu0,' (13) ',lukebranch,char(10),' ? '];
%
if nargin == 2,
    smode = 0;
    while smode == 0,
        smode = input(smode_menu0);
        if smode >=1 & smode <= 13,
            break;
        else
            clc
            disp('WARNING: Non existing option !');
            smode = 0;
        end
    end
    %
    if smode == 1,cd(fullfile(project_root,lukebranch,'Packages'));end
    if smode == 2,cd(fullfile(project_root,lukebranch,'Project_DKE'));end
    if smode == 3,cd(fullfile(project_root,lukebranch,'Project_DKE/Database'));end
    if smode == 4,cd(fullfile(project_root,lukebranch,'Project_DKE/Display'));end
    if smode == 5,cd(fullfile(project_root,lukebranch,'Project_DKE/DKE'));end
    if smode == 6,cd(fullfile(project_root,lukebranch,'Project_DKE/MEX'));end
    if smode == 7,cd(fullfile(project_root,lukebranch,'Project_DKE/Modules'));end
    if smode == 8,cd(fullfile(project_root,lukebranch,'Project_DKE/Packages'));end
    if smode == 9,cd(fullfile(project_root,lukebranch,'Simulations/Benchmarks'));end
    if smode == 10,cd(fullfile(project_root,lukebranch,'Simulations/Examples'));end
    if smode == 11,cd(fullfile(project_root,lukebranch,'ToolS'));end
    if smode == 12,cd(fullfile(project_root,'LUKE_SIMULATIONS'));end
    %
    clc
    %
    if strcmp(lukebranch,'LUKE')
        disp(['>> ',lukeversion,' is now in operation (CVS: main trunk)']);
    else
        disp(['>> ',lukeversion,' is now in operation (CVS: ',lukebranch,')']);
    end
    %
    if flag,
        disp(['>> A startup.m file has been created in the directory ',pathforstartup,', and the LUKE path has been written in it.']);
    else
        disp(['>> The ',lukebranch,' path has been written in ',startuppath,'.']);
        disp([]);
    end
    %
    % Check the path consistency
    %
    if exist([luke_root,'Project_DKE/Database/PATH_files/PATH_LOCAL.mat']) == 0,
        disp(['WARNING: ',lukebranch,' has not been installed.']);
    else
        load([luke_root,'Project_DKE/Database/PATH_files/PATH_LOCAL.mat']);
        %
        if isfield(dkepath.(message_net(1:end-1)),'luke_root'),%old dkepath description until CVS branch 19
            if strfind(dkepath.(message_net(1:end-1)).luke_root,['/',lukebranch,'/'])
                disp(['>> The dkepath structure in PATH_LOCAL.mat is consistent with ',lukebranch])
            else
                disp(['WARNING: The dkepath structure in PATH_LOCAL.mat is not consistent with ',lukebranch]);
                disp(['--> Please set-up and run the file make_path_LOCAL.m of ',lukebranch,' first !']);
            end 
        else
            [s,user] = unix('Users');user = user(1:end-1);
            %
            if strfind(dkepath.(message_net(1:end-1)).(user).luke_root,['/',lukebranch,'/']),
                disp(['>> The dkepath structure in PATH_LOCAL.mat is consistent with ',lukebranch])
            else
                disp(['WARNING: The dkepath structure in PATH_LOCAL.mat is not consistent with ',lukebranch]);
                disp(['--> Please set-up and run the file make_path_LOCAL.m of ',lukebranch,' first !']);
            end           
         end
    end
    %
    disp(' ');
else
    cd(smode_in);
end





