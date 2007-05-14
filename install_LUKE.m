function install_LUKE(pathforstartup)
%
%Install LUKE path in existing default MatLab startup.m and build all *.mat
%and *.mex files
%
%By Joan Decker (CEA-DRFC, joan.decker@cea.fr) and Yves Peysson (CEA-DRFC, yves.peysson@cea.fr)
%
if nargin == 0,
    pathforstartup = which('startup.m');%The default directory for startup.m is the same as the always existing startup.m file
    if isempty(pathforstartup),
        pathforstartup = which('pathdef.m');%The default directory for startup.m is the same as the always existing startup.m file
        pathforstartup = pathforstartup([1:findstr(pathforstartup,'pathdef.m')-1]);
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
    fid = fopen(startuppath,'r');  
    sfile = fread(fid);
    sf1 = strfind(char(sfile'),'%%%%%%%%%%%%%%%%%%%BEGIN-LUKE-PATH%%%%%%%%%%%%%%%%%%%');
    sf2 = strfind(char(sfile'),'%%%%%%%%%%%%%%%%%%%%END-LUKE-PATH%%%%%%%%%%%%%%%%%%%%');
    while length(sf1)>0
        sfile = sfile([1:max(1,sf1(1)-1),sf2(1)+53:length(sfile)]);
        sf1 = strfind(char(sfile'),'%%%%%%%%%%%%%%%%%%%%END-LUKE-PATH%%%%%%%%%%%%%%%%%%%%');
        sf2 = strfind(char(sfile'),'%%%%%%%%%%%%%%%%%%%%END-LUKE-PATH%%%%%%%%%%%%%%%%%%%%');
    end
    fclose(fid);
    fid = fopen(startuppath,'w');  
    fwrite(fid,sfile);
    fclose(fid); 
else,%startup.m file does not exist. It will be created
    flag = 1;
end
%
fid = fopen(startuppath,'a+');%Create or open startup.m file and append LUKE path at the end of the existing startup file
%
fprintf(fid,'\n%s\n','%%%%%%%%%%%%%%%%%%%BEGIN-LUKE-PATH%%%%%%%%%%%%%%%%%%%');
localpath = [pwd,'/'];
eval(['fprintf(fid,''%s\n'',''luke_root = ''''',localpath,''''';'');']);
fprintf(fid,'%s\n','addpath([luke_root,''Project_DKE/DKE'']);');
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
% Run startup.m and add paths
%
startup;
%
disp(['The LUKE paths have been installed.']);
%
% Build *.mat and *.mex files if possible
%
cd([luke_root,'/Project_DKE/MEX/Bin']);
if exist(['trapz_dke_yp.',mexext]) == 0,
    mex ../Source/trapz_dke_yp.c
    disp(['The trapz_dke_yp.',mexext,' mexfile has been done.'])
end
cd([luke_root,'/Project_DKE/Modules/RT/MEX/Bin']);
if exist(['raytracing_yp.',mexext]) == 0,
    mex -c ../Source/raytracing_interp_yp.c 
    mex -c ../Source/raytracing_dieltensor_yp.c 
    mex -c ../Source/raytracing_load_yp.c 
    mex ../Source/raytracing_yp.c raytracing_dieltensor_yp.o raytracing_interp_yp.o raytracing_load_yp.o 
    disp(['The raytracing_yp.',mexext,' mexfile has been done.'])
end
%
cd([luke_root,'/Project_DKE/Database']);
make_all(0);
cd(luke_root);
%





