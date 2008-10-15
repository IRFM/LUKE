function [s,mess,messid] = build_helmex77_yp(sourcepath,binpath,argmex,fopts,force_compile)
%
% Compile separatrice.f or helmex77.f mexfiles with fortran compilers.
%
% Input:
%
%   - argmex: argument for the mex compilation (see the mex documentation)
%
% Output:
%
%   - s: 1 if compilation successful, 0 otherwise [1,1]
%   - mess: message 
%   - messid: message id (in case of failure)
%
%by Y. Peysson (CEA-DRFC, yves.peysson@cea.fr) and J. Decker (CEA-DRFC,joan.decker@cea.fr)
%
if nargin < 5,
    force_compile = 1;
end
%
if nargin < 4,
    fopts = '';
end
%
if nargin < 3,
    argmex = '';
end
%
if nargin < 2,
    binpath = 'MEX/Bin/';
end
%
if nargin < 1,
    sourcepath = 'MEX/Source/';
end
%
machine = computer;
%
warning1 = 'Computer not recognized: the mexfiles of separatrice.f and helmex77.f are not built !';
warning2 = 'Move to ~/LUKE/Project_DKE/Modules/Helena/MEX/Bin/ directory to build manually the mexfiles of separatrice.f and helmex77.f';
%
if strcmp(machine,'MAC') | strcmp(machine,'MACI') | strcmp(machine,'GLNX86') | strcmp(machine,'PCWIN'),%32 bits machines
    arch = '32b';
elseif strcmp(machine,'GLNXA64') | strcmp(machine,'PCWIN64') | strcmp(machine,'SOL64'),%64 bits machines
    arch = '64b';
else
    s = 0;mess = warning1;messid = '';
    warning(warning1);warning(warning2);
    return
end
%
if force_compile == 0,
    %
    filetime.separatrice.mex = gettime_jd(['separatrice.',mexext],binpath,0); 
    filetime.separatrice.source = gettime_jd(['separatrice_',arch,'.f'],sourcepath,1);
    %
    filetime.helmex77.mex = gettime_jd(['helmex77.',mexext],binpath,0); 
    filetime.helmex77.source = gettime_jd(['helmex77_',arch,'.f'],sourcepath,1); 
end
%
if force_compile || any(filetime.separatrice.source > filetime.separatrice.mex), 
    %
    [s,mess,messid] = copyfile([sourcepath,'separatrice_',arch,'.f'],[binpath,'/separatrice.f']);
    %
    if s == 1,
        %
        initpath = pwd;
        cd(binpath);
        %
        try
            %
            eval(['mex ',fopts,' separatrice.f ',argmex]);
            disp(['The separatrice.',mexext,' mexfile has been compiled.']);
            s = 1;mess = '';messid = '';
        catch
            disp(['The complation of separatrice.',mexext,' mexfile has failed.']);
            s = 0;mess = warning3;messid = '';
            warning(warning2);
        end
        % 
        delete('separatrice.f');
        %
        cd(initpath);
    else
        warning(warning1);warning(warning2);  
    end
end
%
if force_compile || any(filetime.helmex77.source > filetime.helmex77.mex), 
    %
    [s,mess,messid] = copyfile([sourcepath,'helmex77_',arch,'.f'],[binpath,'/helmex77.f']);
    %
    if s == 1,
        %
        initpath = pwd;
        cd(binpath);
        %
        try
            %
            eval(['mex ',fopts,' helmex77.f ',argmex]);
            disp(['The helmex77.',mexext,' mexfile has been compiled.']);
            s = 1;mess = '';messid = '';
        catch
            disp(['The complation of separatrice.',mexext,' mexfile has failed.']);
            s = 0;mess = warning3;messid = '';
            warning(warning2);
        end
        % 
        delete('helmex77.f');
        %
        cd(initpath);
    else
        warning(warning1);warning(warning2);  
    end
end
%


