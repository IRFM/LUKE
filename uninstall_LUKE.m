function uninstall_LUKE(pathforstartup)
%
%Uninstall LUKE path in existing default MatLab startup.m, and remove all
%*.mat and *.mex files
%
%By Joan Decker (CEA-DRFC, joan.decker@cea.fr) and Yves Peysson (CEA-DRFC, yves.peysson@cea.fr)
%
%
if nargin == 0,
    pathforstartup = which('startup.m');%The default directory for startup.m is the same as the always existing startup.m file
	%
	if isempty(pathforstartup),
		fid = -2;
	else
		fid = fopen(pathforstartup,'w');  
	end
	%	
	if fid <= -1,
		if fid == -2,
			disp(['No startup.m found in path']);
		else
			disp(['Cannot write to startup.m, no permission.']);
		end
		disp(['Looking for a startup.m file in home or pathdef.m directory.']);
		%
		if strcmp(computer,'PCWIN'),
			pathforstartup = which('pathdef.m');%The default directory for startup.m is the same as the always existing startup.m file
			pathforstartup = pathforstartup([1:findstr(pathforstartup,'pathdef.m')-1]);
		else
			pathforstartup = '~/';%The default directory for startup.m is the same as the always existing startup.m file
		end
		%
	else
		pathforstartup = pathforstartup([1:findstr(pathforstartup,'startup.m')-1]);
		fclose(fid);
	end	
	%
end
%
if strcmp(pathforstartup(end),'/');
    startuppath = [pathforstartup,'startup.m'];
else
    startuppath = [pathforstartup,'/startup.m'];
end
%
if exist(startuppath),%startup.m file exists
    flag = 0;
    fid = fopen(startuppath,'r');  
    sfile = fread(fid);
	%
    sf1 = strfind(char(sfile'),'%%%%%%%%%%%%%%%%%%%BEGIN-LUKE-PATH%%%%%%%%%%%%%%%%%%%');
    sf2 = strfind(char(sfile'),'%%%%%%%%%%%%%%%%%%%%END-LUKE-PATH%%%%%%%%%%%%%%%%%%%%');
    while length(sf1)>0
        sfile = sfile([1:max(1,sf1(1)-1),sf2(1)+53:length(sfile)]);
        sf1 = strfind(char(sfile'),'%%%%%%%%%%%%%%%%%%%BEGIN-LUKE-PATH%%%%%%%%%%%%%%%%%%%');
        sf2 = strfind(char(sfile'),'%%%%%%%%%%%%%%%%%%%%END-LUKE-PATH%%%%%%%%%%%%%%%%%%%%');
    end
    fclose(fid);
    fid = fopen(startuppath,'w');  
    fwrite(fid,sfile);
    fclose(fid); 
end
%
disp(['The startup.m file has been cleaned from LUKE path']);
%
path_LUKE = [pwd,'/'];
%
% Remove *.mat and *.mex files if possible
%
mex_clean_luke(path_LUKE)
%
cd([path_LUKE,'Project_DKE/Database']);
remove_all(0);
cd(path_LUKE);
%
% Remove html documentation
%
rmdir('Documentation');
%
% Remove paths
%
setpath_luke_jd
%
disp(['The LUKE paths have been removed.']);






