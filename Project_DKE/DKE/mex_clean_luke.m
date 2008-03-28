function mex_clean_luke(luke_root)
%
Binpath_DKE = [luke_root,'Project_DKE/MEX/Bin'];
Binpath_C3PO = [luke_root,'Project_DKE/Modules/RT/MEX/Bin'];
Binpath_helmex = [luke_root,'Project_DKE/Modules/Helena/MEX/Bin'];
%
if strfind(computer,'PCWIN'),
    objext = 'obj';
else
    objext = 'o';
end
%
initdir = pwd;
%
cd(Binpath_DKE);
%
if exist(['trapz_dke_yp.',mexext]),
    delete(['trapz_dke_yp.',mexext])
    disp(['The trapz_dke_yp.',mexext,' mexfile has been removed.'])
end
%
if exist(['alphaphimex_jd.',mexext]),
    delete(['alphaphi_jd.',objext])
    delete(['alphaphimex_jd.',mexext])
    disp(['The alphaphimex_jd.',mexext,' mexfile has been removed.'])
end
%
cd(Binpath_C3PO);
%
if exist(['raytracing_yp.',mexext]),
    delete(['raytracing_yp.',mexext])
    delete(['raytracing_dieltensor_yp.',objext]) 
    delete(['raytracing_load_yp.',objext])
    delete(['raytracing_interp_yp.',objext])
    disp(['The raytracing_yp.',mexext,' mexfile has been removed.'])
end
%
cd(Binpath_helmex);
%
if exist(['separatrice.',mexext]),
    delete(['separatrice.',mexext])
    delete(['helmex77.',mexext])
    disp(['The separatrice.',mexext,' mexfile has been removed.'])
    disp(['The helmex77.',mexext,' mexfile has been removed.'])
end
%
cd(initdir);
