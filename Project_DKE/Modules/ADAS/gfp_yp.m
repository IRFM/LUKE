function [g,gn] = gfp_yp(p,Z,model,dftpath)
%
%	Atomic screening function for pitch-angle enhancement due to partially ionized high-Z impurities in the plasma. Following L.Hesslow et al. (2018). 
%
%	Input:
%
%		- p: electron momentum in relativistic units [1,m] 
%		- Z : atomic number [1,1]
%       - model : atomic model [1,1]
%       - dftpath : absolute path to ADAS module if out from LUKE path
%
%	Output: 
%
%		- g: screening function for pitch-angle scattering by ion type of atomique number Z (all ioniztion states are considered simultaneously) [m,Z+1]
%		- gn: normalized to (Z^2-Z0^2) screening function for pitch-angle scattering by ion type of atomique number Z (all ionization states are considered simultaneously) [m,Z+1]
%
% by Y.Peysson CEA-DRFC <yves.peysson@cea.fr>, K.Krol PAN-IFJ <krzysztof.krol@ifj.edu.pl> and  A.Jardin PAN-IFJ <axel.jardin@ifj.edu.pl>
%
if nargin < 3
    %
    error('Wrong number of input arguments in gfp_yp');
    %
elseif nargin < 4
    %
    dftpath = 'DFT/';
    %
end
%
symbol = elements('atomic_number', Z, 'symbol');
name = elements('atomic_number', Z, 'name');
%
if exist([dftpath,'dft_',int2str(Z),'_',symbol,'_',name,'.mat'],'file')
    %
    load([dftpath,'dft_',int2str(Z),'_',symbol,'_',name,'.mat'],'dft');
    %
else
    %
    g = [zeros(length(p(:)),1)];% + fully stripped atom
    gn = [zeros(length(p(:)),1)];% + fully stripped atom
    %
    return
    %
end
%
Z0 = ones(length(p(:)),1)*dft.Z0;
N = Z - ones(length(p(:)),1)*dft.Z0;
Z2mZ02 = (Z^2 - Z0.^2);
%
[~,~,~,~,~,~,~,~,~,alpha,~,~,~,~,~,a0] = pc_dke_yp;
%
if strcmp(model,'DFT') %exact calculation of g from DFT results
    %
    gammaE = 0.5772156649;%Euler-Mascheroni constant
    %
    %
    I1 = ones(length(p(:)),1)*dft.I1;
    I2 = ones(length(p(:)),1)*dft.I2;
    %
    pp = p(:)*ones(size(dft.I1));
    %
    g = Z2mZ02.*(log(2*pp/alpha) - 1 + gammaE) + 2*Z.*N.*I1 + N.^2.*(0.5 - I2);
    %
elseif strfind(model,'salvat')
    %
    if isfield(dft,'salvat') & isfield(dft.salvat,'gaussian') % Salvat up to 3 exponentials modeling
        %
        if str2num(model(end)) >= 1 && str2num(model(end)) <= 3 
            %
            salvat = dft.salvat.gaussian{str2num(model(end))};
            %
        else
            %
            error('Wrong type of model. For ''salvat model'', it should be ''salvat1'', ''salvat2'', ''salvat2''')
            %
        end
        %
        a = 2./salvat.alpha/alpha;
        a(isinf(a)) = 0;
        %
        for ii = 1:size(a,2)
            %
            y{ii} = ((p(:)*ones(1,size(a,1))).*(ones(length(p(:)),1)*a(:,ii)')).^2;
            A{ii} = ones(length(p),size(salvat.A,1)).*(ones(length(p(:)),1)*salvat.A(:,ii)');
            %
        end
        %
        g = zeros(length(p),size(a,1));
        %
        for ii = 1:size(a,2)
            %
            g = g + Z*(Z - Z0).*A{ii}.*log(1 + y{ii}) - (Z - Z0).^2.*A{ii}.^2.*(y{ii}./(1 + y{ii}) + log(1 + y{ii}))./2;
            %
            for jj = ii+1:size(a,2)
                %
                gtilde1 = (y{ii} + y{jj})./(y{jj} - y{ii}).*log(abs((1 + y{jj})./(1 + y{ii})))/2;
                gtilde2 = log(abs(1 + y{ii} + y{jj} + y{ii}.*y{jj}))/4;
                gtilde3 = (y{ii} + y{jj})./(abs(y{ii} - y{jj})).*log(abs((2*y{ii}.*y{jj} + (y{ii} + y{jj}) - abs(y{ii} - y{jj}))./(2*y{ii}.*y{jj} + (y{ii} + y{jj}) + abs(y{ii} - y{jj}))))/4;
                gtilde4 = (y{ii} + y{jj})./(abs(y{ii} - y{jj})).*log(abs(((y{ii} + y{jj}) - abs(y{ii} - y{jj}))./((y{ii} + y{jj}) - abs(y{ii} + y{jj}))))/4;
                %
                gtilde1(isinf(gtilde1)) = 0;
                gtilde3(isinf(gtilde3)) = 0;
                gtilde4(isinf(gtilde4)) = 0;
                gtilde1(isnan(gtilde1)) = 0;
                gtilde3(isnan(gtilde3)) = 0;
                gtilde4(isnan(gtilde4)) = 0;
                %
                g = g + 2*(Z - Z0).^2.*A{ii}.*A{jj}.*(-gtilde1 - gtilde2 + gtilde3 - gtilde4);
                %
            end
            %
        end
        %
    else
        %
        error(['dft.salvat.gaussian is not existing. Check the dft structure and generate the substructure with test_salvat.m script.'])
        %
    end
    %
else %approximate calculation of g (Thomas-Fermi-Kirillov or Tseng-Pratt + different characteristics lengths)
    %
    imodel = find(ismember(dft.models,model));
    %
    ionradius = dft.ionradius{imodel};
    %
    a = ones(length(p(:)),1)*ionradius.a(1:end-1);% no fully stripped atom
    %
    x = (p(:)*ones(1,size(a,2))).*a;
    %
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
