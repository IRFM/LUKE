function [g,gn] = gfp_yp(p,Z,model,dftpath)
%
%	Atomic screening function for pitch-angle enhancement due to partially ionized high-Z impurities in the plasma. Following L.Hesslow et al. (2018). 
%
%	Input:
%
%		- p: electron momentum in relativistic units [1,m] 
%		- Z : atomic number [1,1]
%       - model : atomic model [1,1]
%       - ADASpath : absolute path to ADAS module
%
%	Output: 
%
%		- g: screening function for pitch-angle scattering by ion type of atomique number Z (all ioniztion states are considered simultaneously) [m,Z+1]
%		- gn: normalized to (Z^2-Z0^2) screening function for pitch-angle scattering by ion type of atomique number Z (all ioniztion states are considered simultaneously) [m,Z+1]
%
% by Y.Peysson CEA-DRFC <yves.peysson@cea.fr>, K.Krol PAN-IFJ <krzysztof.krol@ifj.edu.pl> and  A.Jardin PAN-IFJ <axel.jardin@ifj.edu.pl>
%
if nargin < 3
    error('Wrong number of input arguments in gfp_yp');
end
%
symbol = elements('atomic_number', Z, 'symbol');
name = elements('atomic_number', Z, 'name');
%
load([dftpath,'/DFT/dft_',int2str(Z),'_',symbol,'_',name,'.mat'],'dft');
%
Z0 = ones(length(p(:)),1)*dft.Z0;
N = Z - ones(length(p(:)),1)*dft.Z0;
Z2mZ02 = (Z^2 - Z0.^2);
%
if strcmp(model,'DFT') %exact calculation of g from DFT results
    %
    gammaE = 0.5772156649;%Euler-Mascheroni constant
    %
    [~,~,~,~,~,~,~,~,~,alpha,~,~,~,~,~,a0] = pc_dke_yp;
    %
    I1 = ones(length(p(:)),1)*dft.I1;
    I2 = ones(length(p(:)),1)*dft.I2;
    %
    pp = p(:)*ones(size(dft.I1));
    %
    g = Z2mZ02.*(log(2*pp/alpha) - 1 + gammaE) + 2*Z.*N.*I1 + N.^2.*(0.5 - I2);
    %
else %approximate calculation of g (Thomas-Fermi-Kirillov or Tseng-Pratt + different characteristics lengths)
    %
    imodel = find(ismember(dft.models,model));
    %
    ionradius = dft.ionradius{imodel};
    %
    a = ones(length(p(:)),1)*ionradius.a(1:end-1);% no fully stripped atom
    %
    x = p(:).*a;
    n = ones(length(p(:)),1)*ionradius.nff(1:end-1);% no fully stripped atom
    %
    y = x.^n;
    %
    g = ((Z^2 - Z0.^2).*log(1 + y) - (Z - Z0).^2.*y./(1 + y))./n;
    % 
end
%
gn = g./Z2mZ02;
%
g = [g,zeros(length(p(:)),1)];% + fully stripped atom
gn = [gn,zeros(length(p(:)),1)];% + fully stripped atom
%
