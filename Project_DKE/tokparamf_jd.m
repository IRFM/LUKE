function tokparamf_jd(tokamak,nr)
% function tokparamf_jd
%
% creates a database of the tokamak parameters using the data from ptok_dke_yp
% 
%	INPUTS:
%
%		- tokamak : name of the tokamak, must be an entry in ptok_dke_yp
%		- nr : number of points in the radial dimension
%
% by J. Decker 11/20/03
%
% last modification 11/20/03
%
prho = 0:1/(nr-1):1;
%
[ap,Rp,Ip,Bt,Ncoils,Zi,mi,fi,BeLi,...
	qmin,eq,Te0,Tea,eTe,eTe_ref,...
	ne0,nea,ene,ene_ref,Ti0,Tia,eTi,Zeff0,Zeffa,eZeff] = ...
		ptok_dke_1yp(tokamak);
%
Bpa = (4*pi*1e-7)*Ip*1e6/(2*pi*ap); %Poloidal Field at the edge, Ampere's theorem (circular plasma cross-section)
qmax = ap/Rp*Bt/Bpa;
%
pTe = (Te0 - Tea)*(1 - prho.^2).^eTe + Tea;%Electron temperature (keV)
pne = (ne0 - nea)*(1 - prho.^2).^ene + nea;%Electron density (m-3)
pTi = (Ti0 - Tia)*(1 - prho.^2).^eTi + Tia;%Ion and impurity temperatures (usually, Ti = Te/2) (keV)
%
pZeff = (Zeff0 - Zeffa)*(1 - prho.^2).^eZeff + Zeffa;%Effective charge (a.u.)
%
pq = (qmax - qmin)*prho.^eq + qmin;
%
%
%Ion parameters
%
nz = length(Zi);
pzTi = repmat(pTi,[nz,1]); %same temperature for all ion species
pzni = zeros(nz,nr);
%
if sum(Zi>1) > 1 %More than one impurity species
    % need each species density
elseif sum(Zi>1) == 1 % One impurity species
    Zimp = max(Zi);
    pnhyd = pne.*(Zimp - pZeff)/(Zimp - 1);
    pnimp = pne.*(pZeff - 1)/(Zimp - 1)/Zimp;
    pzni(nz,:) = pnimp;
else % No Impurity
    pnhyd = pne;
	pnimp = 0*pne;
end
if sum(fi) == 1
    pzni(1:3,:) = fi'*pnhyd;
else
    error('Hydrogen isotopic fractions do not add to 1')
end    

savestr = ['PARAM_',tokamak];
eval(['save ',savestr,' ap Rp Ip Bt Ncoils BeLi prho ',...
        'qmin qmax eq pq ',...
        'Te0 Tea eTe pTe ',...
        'ne0 nea ene pne ',...
        'Ti0  Tia eTi pzTi ',...
        'Zeff0 Zeffa eZeff ',...
        'Zi mi fi pzni']);

figure(1),clf
plot(prho,pTe,prho,pTi,'linewidth',2)
xl = xlabel('Normalized Radius r/a');set(xl,'fontsize',18);
tl = title(['Temperature Profiles in ',tokamak,' (on midplane)']);set(tl,'fontsize',21);
set(gca,'fontsize',18);
ylim = get(gca,'ylim');
set(gca,'ylim',[0,ylim(2)]);
grid on;box on;

figure(2),clf
plot(prho,pne,prho,pnhyd,prho,pnimp,'linewidth',2)
xl = xlabel('Normalized Radius r/a');set(xl,'fontsize',18);
tl = title(['Density Profiles in ',tokamak,' (on midplane)']);set(tl,'fontsize',21);
set(gca,'fontsize',18);
ylim = get(gca,'ylim');
set(gca,'ylim',[0,ylim(2)]);
grid on;box on;

figure(3),clf
plot(prho,pZeff,'linewidth',2)
xl = xlabel('Normalized Radius r/a');set(xl,'fontsize',18);
tl = title(['Zeff Profile in ',tokamak,' (on midplane)']);set(tl,'fontsize',21);
set(gca,'fontsize',18);
ylim = get(gca,'ylim');
set(gca,'ylim',[0,ylim(2)]);
grid on;box on;

figure(4),clf
plot(prho,pq,'linewidth',2)
xl = xlabel('Normalized Radius r/a');set(xl,'fontsize',18);
tl = title(['q Profile in ',tokamak,' (on midplane)']);set(tl,'fontsize',21);
set(gca,'fontsize',18);
ylim = get(gca,'ylim');
set(gca,'ylim',[0,ylim(2)]);
grid on;box on;

