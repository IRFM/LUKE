function mex_compile_luke(dkepath)
%
luke_root = dkepath.luke_root;
%
if ~isfield(dkepath,'mex'),
    Binpath_DKE = [luke_root,'Project_DKE/MEX/Bin'];
    Binpath_C3PO = [luke_root,'Project_DKE/Modules/RT/MEX/Bin'];
    Binpath_helmex = [luke_root,'Project_DKE/Modules/Helena/MEX/Bin'];
else
	mexpath = dkepath.mex;
    mkdir(mexpath);
	%
    Binpath_DKE = mexpath;
    Binpath_C3PO = mexpath;
    Binpath_helmex = mexpath;
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
Sourcepath_helmex = [luke_root,'Project_DKE/Modules/Helena/MEX/Source/'];
%
initdir = pwd;
%
cd(Binpath_DKE);
%
eval(['mex ',Sourcepath_DKE,'trapz_dke_yp.c']);
disp(['The trapz_dke_yp.',mexext,' mexfile has been compiled.'])
%
eval(['mex -c -I',Sourcepath_DKE,' ',Sourcepath_DKE,'alphaphi_jd.c']);
eval(['mex ',Sourcepath_DKE,'alphaphimex_jd.c alphaphi_jd.',objext]);
disp(['The alphaphimex_jd.',mexext,' mexfile has been compiled.'])
%
cd(Binpath_C3PO);
%
eval(['mex -c ',Sourcepath_C3PO,'raytracing_interp_yp.c']);
eval(['mex -c ',Sourcepath_C3PO,'raytracing_dieltensor_yp.c']);
eval(['mex -c ',Sourcepath_C3PO,'raytracing_load_yp.c']);
eval(['mex ',Sourcepath_C3PO,'raytracing_yp.c raytracing_dieltensor_yp.',objext,' raytracing_interp_yp.',objext,' raytracing_load_yp.',objext,' ',Binpath_DKE,'/alphaphi_jd.',objext]);
disp(['The raytracing_yp.',mexext,' mexfile has been compiled.'])
%
cd(Binpath_helmex);
%
if isfield(dkepath,'compiler_opt') & isfield(dkepath.compiler_opt,'helmex'),
	[s_helmex,mess_helmex,messid_helmex] = build_helmex77_yp(Sourcepath_helmex,Binpath_helmex,dkepath.compiler_opt.helmex);
end
%
cd(initdir);
