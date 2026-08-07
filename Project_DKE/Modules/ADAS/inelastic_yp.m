% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function factor = inelastic_yp(equilDKE,mksa,xzni_norm,xbetath,gamma,pn)
%
if nargin < 6
    error('Wrong number of input arguments in inelastic_yp');
end
%
%
[~,~,~,~,~,~,~,mc2,~,~,~,~] = pc_dke_yp;%Universal physics constants
%
factor = zeros(length(xbetath),length(pn));
%
prel = pn*mksa.betath_ref;%conversion to relativistic units
%
izero = find(equilDKE.zZi == 0);% find neutrals
%
for ir = 1:length(xbetath)
    %
    for iZimp = 1:length(equilDKE.Znucleus)-3 % loop on all species other than hydrogen
        %
        Z = equilDKE.Znucleus(iZimp+3);
        %
        symbol = elements('atomic_number', Z, 'symbol');
        name = elements('atomic_number', Z, 'name');
        %
        load([equilDKE.screening.dftpath,'dft_',int2str(Z),'_',symbol,'_',name,'.mat'],'dft');
        %
        ni_norm = ones(length(pn(:)),1)*xzni_norm(izero(iZimp):izero(iZimp)+length(dft.Z0)-1,ir)';% all states without fully stripped atom
        %
        Z0 = ones(length(pn(:)),1)*dft.Z0;
        N = Z - ones(length(pn(:)),1)*dft.Z0;
        %
        %TODO: implement other models for meanexcitation energy
        %
        if isempty(find(isnan(dft.I_meanexcitationenergy)~=0))
            %
            I_meanexcitationenergy =  ones(length(pn(:)),1)*dft.I_meanexcitationenergy/1000;%keV units
            %
        else
            %
            I_meanexcitationenergy =  ones(length(pn(:)),1)*dft.I_meanexcitationenergy_s/1000;%keV units
            %
        end
        pprel = pn(:)*ones(1,length(dft.Z0));
        ggamma = gamma(:)*ones(1,length(dft.Z0));
        bbeta2 = 1 - 1.0./ggamma./ggamma;% spin correction
        ppn = pn(:)*ones(1,length(dft.Z0));
        %
        B = mc2*sqrt(2)*pprel.*sqrt(ggamma-1)./I_meanexcitationenergy;
        C = sum(ggamma.*ggamma.*ni_norm.*N.*(log(1+B.^5)/5 - bbeta2)./ppn./ppn,2)';
        C(C<0) = 0;%remove non physical negative values
        factor(ir,:) = C;
        %
    end
    %
end
%