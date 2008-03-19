function uninstall_LUKE(pathforstartup)
%
%Uninstall LUKE path in existing default MatLab startup.m, and remove all
%*.mat and *.mex files
%
%By Joan Decker (CEA-DRFC, joan.decker@cea.fr) and Yves Peysson (CEA-DRFC, yves.peysson@cea.fr)
%
%
if nargin == 0,
    pathforstartup = which('startup.m');%The default directory for startup.m is the same as the always existing matlabrc.m file
    pathforstartup = pathforstartup([1:findstr(pathforstartup,'startup.m')-1]);
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
        sf1 = strfind(char(sfile'),'%%%%%%%%%%%%%%%%%%%%BEGIN-LUKE-PATH%%%%%%%%%%%%%%%%%%%%');
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
path_LUKE = pwd;
%
% Remove *.mat and *.mex files if possible
%
cd([path_LUKE,'/Project_DKE/MEX/Bin']);
if exist(['trapz_dke_yp.',mexext]),
    delete(['trapz_dke_yp.',mexext])
    disp(['The trapz_dke_yp.',mexext,' mexfile has been removed.'])
end
cd([path_LUKE,'/Project_DKE/Modules/RT/MEX/Bin']);
if exist(['raytracing_yp.',mexext]),
    delete(['raytracing_yp.',mexext])
    delete(['raytracing_dieltensor_yp.o']) 
    delete(['raytracing_load_yp.o'])
    delete(['raytracing_interp_yp.o'])
    disp(['The raytracing_yp.',mexext,' mexfile has been removed.'])
end
%
cd([path_LUKE,'/Project_DKE/Database']);
remove_all(0);
%
% Remove paths
%
setpath_luke_jd
%
disp(['The LUKE paths have been removed.']);
cd(path_LUKE);






