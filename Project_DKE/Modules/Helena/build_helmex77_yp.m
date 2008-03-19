function [s,mess,messid] = build_helmex77_yp(sourcepath,binpath,argmex)
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
if nargin == 0,
    sourcepath = 'MEX/Source/';,
    binpath = 'MEX/Bin';
    argmex = '';
elseif nargin == 1,
    binpath = 'MEX/Bin';
    argmex = '';
elseif nargin < 3,
    argmex = '';
end
%
machine = computer;
%
warning1 = 'The computer on which LUKE is supposed to run is not recognized by MatLab: the mexfiles of separatrice.f and helmex77.f are not build !';
warning2 = 'Move to ~/LUKE/Project_DKE/Modules/Helena/MEX/Bin/ directory for building manually the mexfiles of separatrice.f and helmex77.f';
warning3 = 'The compilation of the mexfiles of separatrice.f or helmex77.f failed for an unknown reason !';
%
if strcmp(machine,'MAC') | strcmp(machine,'MACI') | strcmp(machine,'GLNX86') | strcmp(machine,'PCWIN'),%32 bits machines
    [s,mess,messid] = copyfile([sourcepath,'separatrice_32b.f'],[binpath,'/separatrice.f']);
    [s,mess,messid] = copyfile([sourcepath,'helmex77_32b.f'],[binpath,'/helmex77.f']);
elseif strcmp(machine,'GLNXA64') | strcmp(machine,'PCWIN64') | strcmp(machine,'SOL64'),%64 bits machines
    [s,mess,messid] = copyfile([sourcepath,'separatrice_64b.f'],[binpath,'/separatrice.f']);
    [s,mess,messid] = copyfile([sourcepath,'helmex77_64b.f'],[binpath,'/helmex77.f']);
else
    s = 0;mess = warning1;messid = '';
    warning(warning1);warning(warning2);
    return
end
%
if s == 1,
    eval(['mex separatrice.f ',argmex]);
    eval(['mex helmex77.f ',argmex]);
%
    if exist(['separatrice.',mexext]) & exist(['helmex77.',mexext]),
        disp('The compilations of the mexfiles of separatrice.f and helmex77.f are both successfull !');
        s = 1;mess = '';messid = '';   
    else
        warning(warning3);warning(warning2);
        s = 0;mess = warning3;messid = '';
    end
% 
    delete('separatrice.f');
    delete('helmex77.f');  
else
    warning(warning1);warning(warning2);  
end


