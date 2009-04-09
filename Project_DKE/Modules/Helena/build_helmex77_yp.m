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
if force_compile == 0,
    %
    filetime.separatrice.mex = gettime_jd(['separatrice.F'],binpath,0); 
    filetime.separatrice.source = gettime_jd(['separatrice.F'],sourcepath,1);
    %
    filetime.helmex77.mex = gettime_jd(['helmex77.F'],binpath,0); 
    filetime.helmex77.source = gettime_jd(['helmex77.F'],sourcepath,1); 
end
%
if force_compile || any(filetime.separatrice.source > filetime.separatrice.mex), 
    %
    [s,mess,messid] = copyfile([sourcepath,'separatrice.F'],[binpath,'/separatrice.F']);
    %
    if s == 1,
        %
        initpath = pwd;
        cd(binpath);
        %
        try
            %
            eval(['mex ',fopts,' separatrice.F ',argmex]);
            disp(['The separatrice.F mexfile has been compiled.']);
        catch
            disp(['The compilation of separatrice.F mexfile has failed.']);
        end
        % 
        delete('separatrice.F');        
        %
        cd(initpath);
    else
        warning(mess);warning(messid);  
    end
end
%
if force_compile || any(filetime.helmex77.source > filetime.helmex77.mex), 
    %
    [s,mess,messid] = copyfile([sourcepath,'helmex77.F'],[binpath,'/helmex77.F']);
    %
    if s == 1,
        %
        initpath = pwd;
        cd(binpath);
        %
        try
            %
            eval(['mex ',fopts,' helmex77.F ',argmex]);
            disp(['The helmex77.F mexfile has been compiled.']);
        catch
            disp(['The compilation of helmex77.F mexfile has failed.']);
        end
        % 
        delete('helmex77.F');
        %
        cd(initpath);
    else
        warning(mess);warning(messid);  
    end
end
%


