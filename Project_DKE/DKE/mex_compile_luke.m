function mex_compile_luke(sourcepath,mexpath,compiler_opt,force_compile)
%
if nargin < 3,
    force_compile = 1;%force compilation
end
%
if nargin < 2,
    compiler_opt = '';%no options
end
%
if ~exist(mexpath,'dir'),
    %
    mkdir(mexpath);
    force_compile = 1;
    %
end
%
if force_compile == 0,
    %
    filetime.trapz_dke_yp.mex = gettime_jd(['trapz_dke_yp.',mexext],mexpath,0); 
    filetime.trapz_dke_yp.source = gettime_jd('trapz_dke_yp.c',sourcepath.DKE,1);     
    %
    filetime.alphaphimex_jd.mex = gettime_jd(['alphaphimex_jd.',mexext],mexpath,0); 
    filetime.alphaphimex_jd.source(1) = gettime_jd('alphaphimex_jd.c',sourcepath.DKE,1); 
    filetime.alphaphimex_jd.source(2) = gettime_jd('alphaphi_jd.c',sourcepath.DKE,1); 
    filetime.alphaphimex_jd.source(3) = gettime_jd('bessel_IJK_jd.h',sourcepath.DKE,1); 
    %
    filetime.raytracing_yp.mex = gettime_jd(['raytracing_yp.',mexext],mexpath,0); 
    filetime.raytracing_yp.source(1) = gettime_jd('raytracing_yp.c',sourcepath.C3PO,1); 
    filetime.raytracing_yp.source(2) = gettime_jd('raytracing_interp_yp.c',sourcepath.C3PO,1); 
    filetime.raytracing_yp.source(3) = gettime_jd('raytracing_load_yp.c',sourcepath.C3PO,1); 
    filetime.raytracing_yp.source(4) = gettime_jd('raytracing_dieltensor_yp.c',sourcepath.C3PO,1); 
    filetime.raytracing_yp.source(5) = gettime_jd('alphaphi_jd.c',sourcepath.DKE,1); 
    filetime.raytracing_yp.source(6) = gettime_jd('bessel_IJK_jd.h',sourcepath.DKE,1); 
    %
    filetime.erfcc.mex = gettime_jd(['erfcc_mex_jd.',mexext],mexpath,0); 
    filetime.erfcc.source(1) = gettime_jd('erfcc_mex_jd.f',sourcepath.C3PO,1); 
    filetime.erfcc.source(2) = gettime_jd('erfcc.f',sourcepath.C3PO,1); 
    %
end 
%
if isstruct(compiler_opt) & isfield(compiler_opt,'copts'),% C mex compiling options
    copts = compiler_opt.copts;
else
    copts = '';
end
%
if isstruct(compiler_opt) & isfield(compiler_opt,'fopts'),% Fortran mex compiling option
    fopts = compiler_opt.fopts;
else
    fopts = '';
end
%
if strfind(computer,'PCWIN'),
    objext = 'obj';
else
    objext = 'o';
end
%
initdir = pwd;
%
cd(mexpath);
%
if force_compile || any(filetime.trapz_dke_yp.source > filetime.trapz_dke_yp.mex),
    eval(['mex ',copts,' ',sourcepath.DKE,'trapz_dke_yp.c']);
    disp(['The trapz_dke_yp.',mexext,' mexfile has been compiled.'])
end
%
if force_compile || any(filetime.alphaphimex_jd.source > filetime.alphaphimex_jd.mex),
    eval(['mex -c ',copts,' -I',sourcepath.DKE,' ',sourcepath.DKE,'alphaphi_jd.c']);
    eval(['mex ',copts,' ',sourcepath.DKE,'alphaphimex_jd.c alphaphi_jd.',objext]);
    disp(['The alphaphimex_jd.',mexext,' mexfile has been compiled.'])
end
%
if force_compile || any(filetime.raytracing_yp.source > filetime.raytracing_yp.mex),
    eval(['mex -c ',copts,' ',sourcepath.C3PO,'raytracing_interp_yp.c']);
    eval(['mex -c ',copts,' ',sourcepath.C3PO,'raytracing_dieltensor_yp.c']);
    eval(['mex -c ',copts,' ',sourcepath.C3PO,'raytracing_load_yp.c']);
    eval(['mex -c ',copts,' -I',sourcepath.DKE,' ',sourcepath.DKE,'alphaphi_jd.c']);
    eval(['mex ',copts,' ',sourcepath.C3PO,'raytracing_yp.c raytracing_dieltensor_yp.',objext,' raytracing_interp_yp.',objext,' raytracing_load_yp.',objext,' alphaphi_jd.',objext]);
    disp(['The raytracing_yp.',mexext,' mexfile has been compiled.'])
end
%
if force_compile || any(filetime.erfcc.source > filetime.erfcc.mex),
    eval(['mex -c ',fopts,' ',sourcepath.C3PO,'erfcc.f']);
    eval(['mex ',fopts,' ',sourcepath.C3PO,'erfcc_mex_jd.f erfcc.',objext]);
    disp(['The erfcc_mex_jd.',mexext,' mexfile has been compiled.'])
end
%
if isstruct(compiler_opt) && isfield(compiler_opt,'helmex'),
	build_helmex77_yp(sourcepath.helmex,mexpath,compiler_opt.helmex,fopts,force_compile);
end
%
cd(initdir);
%



