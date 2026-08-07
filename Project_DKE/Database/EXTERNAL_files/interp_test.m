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
% Testing script for interpolation functions
%
shotnum = 36194;
shotime = 28;
%
[tprof.ap,tprof.t] = tsbase(shotnum,'SPROFAMIN');%Plasma minor radius (m)
[tprof.qpsi,tprof.t] = tsbase(shotnum,'GPROFQ');%safety factor qpsi profile
[tprof.Te,tprof.t,tprof.rho] = tsbase(shotnum,'GPROFTEFIT');%Electron temperature (keV)
%
figure('name','Profils');
subplot(2,1,1);
plot(tprof.t,tprof.ap,'r-')
subplot(2,1,2);
plot(tprof.rho,tprof.Te(shotime,:),'b--')
%
i_refm = max(find(tprof.t <= 28));
i_refp = min(find(tprof.t > 28));
Te = interp_tprof_time_fxdrg(tprof.t,tprof.Te,28,'pchip')
figure('name','Interp');plot(tprof.rho,Te,'r-',tprof.rho,tprof.Te(i_refm,:),'b--',tprof.rho,tprof.Te(i_refp,:),'g-.');
%
ap = interp_tprof_time_fxdrg(tprof.t,tprof.ap,28,'pchip');
%
qpsi = interp_tprof_time_fxdrg(tprof.t,tprof.qpsi,28,'pchip');
[qmin,qmax,eq,qopt,chi2] = fit_qprofile_fxdrg(tprof.rho,qpsi);
qpsi_fit = (qmax - qmin).*tprof.rho.^eq + qmin;
figure('name','Fit-q');plot(tprof.rho,qpsi,'r-',tprof.rho,tprof.qpsi(i_refm,:),'b--',tprof.rho,tprof.qpsi(i_refp,:),'g-.',tprof.rho,qpsi_fit,'k*');
%
figure('name','Fit-Te');plot(tprof.rho,Te,'r-',tprof.rho,tprof.Te(i_refm,:),'b--',tprof.rho,tprof.Te(i_refp,:),'g-.');hold on
[Te0,Tea,eTe1,eTe2,chi2_Te] = fit_profile_fxdrg(tprof.rho,Te,1,[2,1]);
Te_fit = (Te0 - Tea)*(1 - tprof.rho.^eTe1).^eTe2 + Tea;
plot(tprof.rho,Te_fit,'k-');
%
[Te0,Tea,eTe1,eTe2,chi2_Te] = fit_profile_fxdrg(tprof.rho,Te,2,-1);
Te_fit = (Te0 - Tea)*(exp(eTe1) - exp(eTe1*tprof.rho.*tprof.rho))/(exp(eTe1)-1) + Tea;
plot(tprof.rho,Te_fit,'c-');
hold off

%


