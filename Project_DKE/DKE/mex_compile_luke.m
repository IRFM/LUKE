function mex_compile_luke(luke_root,mexpath)
%
if nargin < 2,
    Binpath_DKE = [luke_root,'Project_DKE/MEX/Bin'];
    Binpath_C3PO = [luke_root,'Project_DKE/Modules/RT/MEX/Bin'];
else
    mkdir(mexpath);
    Binpath_DKE = mexpath;
    Binpath_C3PO = mexpath;
end
%
if strfind(computer,'PCWIN'),
    objext = 'obj';
else
    objext = 'o';
end
%
Sourcepath_DKE = [luke_root,'Project_DKE/MEX/Source/'];
Sourcepath_C3PO = [luke_root,'Project_DKE/Modules/RT/MEX/Source/'];
%
initdir = pwd;
cd(Binpath_DKE);
eval(['mex ',Sourcepath_DKE,'trapz_dke_yp.c']);
disp(['The trapz_dke_yp.',mexext,' mexfile has been compiled.'])
%
eval(['mex -c -I',Sourcepath_DKE,' ',Sourcepath_DKE,'alphaphi_jd.c']);
%
eval(['mex ',Sourcepath_DKE,'alphaphimex_jd.c alphaphi_jd.',objext]);
disp(['The alphaphimex_jd.',mexext,' mexfile has been compiled.'])
%
cd(Binpath_C3PO);
eval(['mex -c ',Sourcepath_C3PO,'raytracing_interp_yp.c']);
eval(['mex -c ',Sourcepath_C3PO,'raytracing_dieltensor_yp.c']);
eval(['mex -c ',Sourcepath_C3PO,'raytracing_load_yp.c']);
eval(['mex ',Sourcepath_C3PO,'raytracing_yp.c raytracing_dieltensor_yp.',objext,' raytracing_interp_yp.',objext,' raytracing_load_yp.',objext,' ',Binpath_DKE,'/alphaphi_jd.',objext]);
disp(['The raytracing_yp.',mexext,' mexfile has been compiled.'])
%
cd(initdir);
