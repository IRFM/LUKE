function [prho,pTe,pne,pzTi,pzni,zZi,zmi,fi,pkin] = idealprof_yp(Zi,mi,fi,Te0,Tea,eTe1,eTe2,ne0,nea,ene1,ene2,Ti0,Tia,eTi1,eTi2,Zeff0,Zeffa,eZeff,xZeff,prho)
%
% Create profiles from parametric description
%
% by Y.Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
if nargin < 20,
    prho = 101;
end
if nargin < 19,
    error('Not enough input arguments in idealprof_yp');
end
%
if length(prho) == 1,
    prho = linspace(0,1,prho);%Uniform rho grid
end
%
zZi = Zi;%[1,ni]
zmi = mi;%[1,ni]
%
%
% Plasma parameters
%
if ~isnan(eTe2) && ~isempty (eTe2),
    if imag(Tea) > 0,
        pTe = Te0*((1 - imag(Tea))*(1 - prho.^eTe1).^eTe2 + imag(Tea));%Electron temperature (keV)
    else
        pTe = (Te0 - Tea)*(1 - prho.^eTe1).^eTe2 + Tea;%Electron temperature (keV)
    end
    %
    if imag(nea) > 0,
        pne = ne0*((1 - imag(nea))*(1 - prho.^ene1).^ene2 + imag(nea));%Electron density (m-3)
    else
        pne = (ne0 - nea)*(1 - prho.^ene1).^ene2 + nea;%Electron density (m-3)
    end
    %
    if imag(Tia) > 0,
        pTi = Ti0*((1 - imag(Tia))*(1 - prho.^eTi1).^eTi2 + imag(Tia));%Ion temperatures (keV)
    else
        pTi = (Ti0 - Tia)*(1 - prho.^eTi1).^eTi2 + Tia;%Ion temperatures (keV)    
    end
else,% Bonoli's paper notation, IEEE Transactions on plasma science Vol. PS-12, No 2, june 1984, p100
    pTe = (Te0 - Tea)*(exp(-eTe1*prho.^2) - exp(-eTe1))/(1 - exp(-eTe1)) + Tea;% Electron temperature (keV)
    pne = (ne0 - nea)*(exp(ene1) - exp(ene1*prho.^2))/(exp(ene1) - 1) + nea;% Electron density (m-3)
    pTi = (Ti0 - Tia)*(exp(-eTi1*prho.^2) - exp(-eTi1))/(1 - exp(-eTi1)) + Tia;% Ion temperatures (keV)
end
%
if isnan(xZeff) || isempty(xZeff),
    pZeff = (Zeff0 - Zeffa)*(1 - prho.^2).^eZeff + Zeffa;% Effective charge (a.u.)
else
    pZeff = 0.5*(Zeffa - Zeff0)*tanh(eZeff*(prho - xZeff)) + 0.5*(Zeffa + Zeff0);% Effective charge (a.u.)
end
%
% Ion parameters
%
nz = length(zZi);
pzTi = repmat(pTi,[nz,1]);% Same temperature for all ion species
pzni = species_dke_yp(pne,pZeff,zZi,fi);
%
pkin = pTe.*pne + sum(pzni.*pzTi);%Total plasma pressure profile (special units for helmex77 in keV.m-3)
%


