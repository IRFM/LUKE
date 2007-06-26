function mex_compile_luke(luke_root,mexpath)
%
if nargin < 2,
    Binpath_trapz_dke_yp = [luke_root,'Project_DKE/MEX/Bin'];
    Binpath_C3PO = [luke_root,'Project_DKE/Modules/RT/MEX/Bin'];
else
    mkdir(mexpath);
    Binpath_trapz_dke_yp = mexpath;
    Binpath_C3PO = mexpath;
end
%
Sourcepath_trapz_dke_yp = [luke_root,'Project_DKE/MEX/Source/'];
Sourcepath_C3PO = [luke_root,'Project_DKE/Modules/RT/MEX/Source/'];
%
initdir = pwd;
cd(Binpath_trapz_dke_yp);
eval(['mex ',Sourcepath_trapz_dke_yp,'trapz_dke_yp.c']);
disp(['The trapz_dke_yp.',mexext,' mexfile has been compiled.'])
%
cd(Binpath_C3PO);
eval(['mex -c ',Sourcepath_C3PO,'raytracing_interp_yp.c']);
eval(['mex -c ',Sourcepath_C3PO,'raytracing_dieltensor_yp.c']);
eval(['mex -c ',Sourcepath_C3PO,'raytracing_load_yp.c']);
if strfind(computer,'PCWIN'),
    eval(['mex ',Sourcepath_C3PO,'raytracing_yp.c raytracing_dieltensor_yp.obj raytracing_interp_yp.obj raytracing_load_yp.obj']);
else
    eval(['mex ',Sourcepath_C3PO,'raytracing_yp.c raytracing_dieltensor_yp.o raytracing_interp_yp.o raytracing_load_yp.o']);
end
disp(['The raytracing_yp.',mexext,' mexfile has been compiled.'])
%
cd(initdir);
