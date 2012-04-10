function mex_compile_luke(sourcepath,mexpath,compiler_opt,force_compile)
%
if nargin < 3,
    force_compile = 1;%force compilation
end
%
if nargin < 2,
    compiler_opt = '';%no compilation (options copts, fopts and helmex must be setup in the path_XXX_YYY.m. They may be empty but defined)
end
%
[dummy,matver] = LUKEversion_jd;
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
    filetime.twister.mex = gettime_jd(['twister.',mexext],mexpath,0); 
    filetime.twister.source = gettime_jd('twister.cpp',sourcepath.DKE,1);
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
    filetime.erfcc.source(1) = gettime_jd('erfcc_mex_jd.F',sourcepath.C3PO,1); 
    filetime.erfcc.source(2) = gettime_jd('erfcc.f',sourcepath.C3PO,1); 
    %
    filetime.separatrice.mex = gettime_jd(['separatrice.',mexext],mexpath,0); 
    filetime.separatrice.source = gettime_jd('separatrice.F',sourcepath.helmex,1);     
    %
    filetime.helmex77.mex = gettime_jd(['helmex77.',mexext],mexpath,0); 
    filetime.helmex77.source = gettime_jd('helmex77.F',sourcepath.helmex,1);     
end 
%
if isstruct(compiler_opt) && isfield(compiler_opt,'copts'),% C mex compiling options
	if isstruct(compiler_opt.copts),
		if isfield(compiler_opt.copts,['mex',matver]),
			copts = compiler_opt.copts.(['mex',matver]);
		else
			copts = '';
		end
	else
    	copts = compiler_opt.copts;
	end
else
    copts = '';
end
%
if isstruct(compiler_opt) && isfield(compiler_opt,'fopts'),% Fortran mex compiling option
	if isstruct(compiler_opt.fopts),
		if isfield(compiler_opt.fopts,['mex',matver]),
			fopts = compiler_opt.fopts.(['mex',matver]);
		else
			fopts = '';
		end
	else
    	fopts = compiler_opt.fopts;
	end
else
    fopts = '';
end
%
if isstruct(compiler_opt) && isfield(compiler_opt,'helmex'),% Fortran mex compiling option
	if isstruct(compiler_opt.helmex),
		if isfield(compiler_opt.helmex,['mex',matver]),
			helmex = compiler_opt.helmex.(['mex',matver]);
		else
			helmex = '';
		end
	else
    	helmex = compiler_opt.helmex;
	end
else
    helmex = '';
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
% Compilation of C programs
%
if ~any(isnan(copts)) && (force_compile || any(filetime.trapz_dke_yp.source > filetime.trapz_dke_yp.mex)) && isfield(compiler_opt,'copts'),
    eval(['mex ',copts,' ',sourcepath.DKE,'trapz_dke_yp.c']);
    disp(['The trapz_dke_yp.',mexext,' mexfile has been compiled.'])
end
%
if ~any(isnan(copts)) && (force_compile || any(filetime.twister.source > filetime.twister.mex)) && isfield(compiler_opt,'copts')
    eval(['mex ',copts,' ',sourcepath.DKE,'twister.cpp']);
    disp(['The twister.',mexext,' mexfile has been compiled.'])
end
%
if ~any(isnan(copts)) && (force_compile || any(filetime.alphaphimex_jd.source > filetime.alphaphimex_jd.mex)) && isfield(compiler_opt,'copts'),
    eval(['mex -c ',copts,' -I',sourcepath.DKE,' ',sourcepath.DKE,'alphaphi_jd.c']);
    eval(['mex ',copts,' ',sourcepath.DKE,'alphaphimex_jd.c alphaphi_jd.',objext]);
    disp(['The alphaphimex_jd.',mexext,' mexfile has been compiled.'])
end
%
if ~any(isnan(copts)) && (force_compile || any(filetime.raytracing_yp.source > filetime.raytracing_yp.mex)) && isfield(compiler_opt,'copts'),
    eval(['mex -c ',copts,' ',sourcepath.C3PO,'raytracing_interp_yp.c']);
    eval(['mex -c ',copts,' ',sourcepath.C3PO,'raytracing_dieltensor_yp.c']);
    eval(['mex -c ',copts,' ',sourcepath.C3PO,'raytracing_load_yp.c']);
    eval(['mex -c ',copts,' -I',sourcepath.DKE,' ',sourcepath.DKE,'alphaphi_jd.c']);
    eval(['mex ',copts,' ',sourcepath.C3PO,'raytracing_yp.c raytracing_dieltensor_yp.',objext,' raytracing_interp_yp.',objext,' raytracing_load_yp.',objext,' alphaphi_jd.',objext]);
    disp(['The raytracing_yp.',mexext,' mexfile has been compiled.'])
end
%
% Compilation of FORTRAN programs
%
if ~any(isnan(fopts)) && (force_compile || any(filetime.erfcc.source > filetime.erfcc.mex)) && isfield(compiler_opt,'fopts'),
    lfield = fieldnames(compiler_opt.fopts);
    for ifield = 1:length(lfield),
		if strcmp(lfield(ifield),['mex',matver]),
    		eval(['mex -c ',fopts,' ',sourcepath.C3PO,'erfcc.f']);
    		eval(['mex ',fopts,' ',sourcepath.C3PO,'erfcc_mex_jd.F erfcc.',objext]);
    		disp(['The erfcc_mex_jd.',mexext,' mexfile has been compiled.'])
    	end
    end
end
%
if ~any(isnan(fopts)) && ~any(isnan(helmex)) && (force_compile || any(filetime.separatrice.source > filetime.separatrice.mex)) && isfield(compiler_opt,'helmex'),
    lfield = fieldnames(compiler_opt.helmex);
    for ifield = 1:length(lfield),
		if strcmp(lfield(ifield),['mex',matver]),
    		eval(['mex ',fopts,' ',sourcepath.helmex,'separatrice.F ']);
    		disp(['The separatrice.',mexext,' mexfile has been compiled.'])
        end
	end
end
%
if ~any(isnan(fopts)) && ~any(isnan(helmex)) && (force_compile || any(filetime.separatrice.source > filetime.separatrice.mex)),
    eval(['mex ',fopts,' ',sourcepath.helmex,'separatrice.F ']);
    disp(['The separatrice.',mexext,' mexfile has been compiled.'])
end
%
if ~any(isnan(fopts)) && ~any(isnan(helmex)) && (force_compile || any(filetime.helmex77.source > filetime.helmex77.mex)) && isfield(compiler_opt,'helmex'),
    lfield = fieldnames(compiler_opt.helmex);
    for ifield = 1:length(lfield),
		if strcmp(lfield(ifield),['mex',matver]),
    		eval(['mex ',fopts,' ',sourcepath.helmex,'helmex77.F ',helmex]);
    		disp(['The helmex77.',mexext,' mexfile has been compiled.'])
    	end
    end
end
%
cd(initdir);
%



