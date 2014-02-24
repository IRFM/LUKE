function equil_prof = equil_prof_jd(filename,type,prho,pspsin,pspsinT,display_mode,p_opt,dispname,savename,Zeff)
%
% This function reads the equilibrium profile data from the 
% file "filename". 
%
%	INPUTS:
%
%		- filename: equilibrium data and save name
%		- type: profile data type:(0) for ascii; (1) for .mat
%		- display_mode: option for figure display
%		- p_opt: option for printing
%
% by J. Decker (jodecke@alum.mit.edu) 11/01/04
%
if nargin < 10,% & type == 3
    Zeff = NaN;
end
if nargin < 9,
    savename = filename;
end
if nargin < 8,
    dispname = filename;
end
%
if nargin < 7,
    p_opt = -1;
end
%
if nargin < 6,
    display_mode = 0;
end
%
method = 'spline';%'linear';
%
% Reads profile T and n data
%
[yrho,yspsin,yspsinT,yTe,yne,yzTi,yzni,zZi,zmi] = Teneprof_jd(filename,type,display_mode,p_opt,Zeff,dispname,savename);
%
if ~isempty(yrho),% profiles given on rho grid
    pTe = interp1(yrho,yTe,prho,method);
    pne = interp1(yrho,yne,prho,method);
    pzTi = interp1(yrho,yzTi.',prho,method).';
    pzni = interp1(yrho,yzni.',prho,method).';
    %
elseif ~isempty(yspsin),% profiles given on poloidal flux based grid
    if isstruct(yspsin),% different rho grid for each parameter
        pTe = interp1(yspsin.pTe,yTe,pspsin,method);
        pne = interp1(yspsin.pne,yne,pspsin,method);
        pzTi = interp1(yspsin.pzTi,yzTi.',pspsin,method).';
        pzni = interp1(yspsin.pzni,yzni.',pspsin,method).'; 
    else
        pTe = interp1(yspsin,yTe,pspsin,method);
        pne = interp1(yspsin,yne,pspsin,method);
        pzTi = interp1(yspsin,yzTi.',pspsin,method).';
        pzni = interp1(yspsin,yzni.',pspsin,method).'; 
    end
    %
elseif ~isempty(yspsinT),% profiles given on toroidal flux based grid
    pTe = interp1(yspsinT,yTe,pspsinT,method);
    pne = interp1(yspsinT,yne,pspsinT,method);
    pzTi = interp1(yspsinT,yzTi.',pspsinT,method).';
    pzni = interp1(yspsinT,yzni.',pspsinT,method).';    
    %
end
%
% equil structure
%
equil_prof.zZi = zZi;
equil_prof.zmi = zmi;
equil_prof.pTe = pTe;
equil_prof.pne = pne;
equil_prof.pzTi = pzTi;
equil_prof.pzni = pzni;
equil_prof.prof_src = filename;
%