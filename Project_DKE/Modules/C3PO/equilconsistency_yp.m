function [gradpkin,gradpmag,jpar,jparz] = equilconsistency_yp(equil,equil_fit,prho)
%
% Test the consistency of the interpolated magnetic equilibrium
%
% INPUT
%
%    - equil_in: numerical magnetic equilibrium structure
%    - equil_fit: interpolated magnetic equilibrium structure
%    - prho: radial grid
%
%
% OUTPUT: 
%
%    - gradpkin: module of the kinetic pressure gradient (from density and temperature profiles) 
%    - gradpmag: module of the magnetic pressure gradient (from B-field) 
%    - jpar: parallel current density 
%    - jparz: axial component of the parallel current density 
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
mtheta = 0;
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha,kB] = pc_dke_yp;
%
for ip = 1:length(prho),
  for im = 1:length(mtheta),
    %
    [Te,dTedrho,d2Tedrho2,ne,dnedrho,d2nedrho2,zTi,dzTidrho,d2zTidrho2,zni,dznidrho,d2znidrho2,...
        x,dxdtheta,d2xdtheta2,dxdrho,d2xdthetadrho,y,dydtheta,d2ydtheta2,dydrho,d2ydthetadrho,...
        r,drdtheta,drdrho,salpha,dsalphadtheta,dsalphadrho,calpha,dcalphadtheta,dcalphadrho,...
        Bx,dBxdtheta,d2Bxdtheta2,dBxdrho,d2Bxdthetadrho,...
        By,dBydtheta,d2Bydtheta2,dBydrho,d2Bydthetadrho,...
        Bz,dBzdtheta,d2Bzdtheta2,dBzdrho,d2Bzdthetadrho,...
        BP,dBPdtheta,dBPdrho,B,dBdtheta,dBdrho,...
        gradrhon,dgradrhondtheta,dgradrhondrho,...
	Upsilon,dUpsilondrho,dUpsilondtheta] = equilval_yp(equil_fit,prho(ip),mtheta(im),1);
    %
    B = sqrt(BP*BP + Bz*Bz);
    %
    gradpkin(ip,im) = (Te.*dnedrho + dTedrho.*ne + sum(zTi.*dznidrho + dzTidrho.*zni,2))*kB*1e3;
    gradpmag(ip,im) = (-BP*calpha*(gradrhon*(drdrho*BP + r*dBPdrho - (dsalphadtheta/Upsilon/calpha - salpha*dcalphadtheta/Upsilon/calpha/calpha - salpha*dUpsilondtheta/calpha/Upsilon/Upsilon))/r - Bz*(dUpsilondrho*Bz + Upsilon*dBzdrho))*(gradrhon/Upsilon/BP))/mu0;
    %
    jpar(ip,im) = -(BP*BP*calpha*calpha*(dUpsilondrho*Bz + Upsilon*dBzdrho) + BP*Bz*calpha*((drdrho*BP + r*dBPdrho - (dsalphadtheta/Upsilon/calpha - salpha*dcalphadtheta/Upsilon/calpha/calpha - salpha*dUpsilondtheta/calpha/Upsilon/Upsilon))))/B/mu0;
    jparz(ip,im) = jpar(ip,im)*Bz/B;
    %
  end
end
%
figure('Name','Pressure gradient'),clf
[ax] = graph1D_jd(prho,gradpkin,0,0,'\rho','\nablap','',NaN,NaN,NaN,'-','none','r',2);drawnow
[ax] = graph1D_jd(prho,gradpmag,0,0,'\rho','\nablap','',NaN,NaN,NaN,'--','none','b',2);drawnow
leg = {'Kinetic','Magnetic','Location','NorthEast'}
%


%


