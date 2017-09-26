function [equil_new,rho_LUKE_ts_sr,rho_psi_ts_sr,T_ts_fit,N_ts_fit,T_ts_sr,N_ts_sr] = EAST_thomson_scattering_Tene_fit(equil,R_ts,Z_ts,T_ts,N_ts,display_mode,nefit_mode)
%
% Calculates Te and ne profiles for C3PO/LUKE from Thomson scattering for EAST from raw data, using EQDSK equilibrium 
%
%   INPUTS: 
%
%       - equil: LUKE format magnetic equilibrium (struct)
%       - R_ts: Major radius of the vertical chord of the diagnostic (m)
%       - Z_ts: Vertical positions of the (ne,Te) raw measurements (m)
%       - T_ts: Raw Te measurements (eV)
%       - N_ts: Raw ne measurements (m-3)
%       - display_mode: display data and fits (1: yes, 0: no)
%           (default: 0)
%       - nefit_mode: (1) bell-shaped curve guess function for the fit, (2) Fermi-like curve guess function for the fit
%           (default: 2)
%
%   OUTPUTS:
%
%       - equil_new: LUKE magnetic equilibrium with new (ne,Te) profiles from Thomson scattering
%       - rho_LUKE_ts_sr: LUKE normalized radial coordinates (WARNING : not sqrt(poloidal_psin)) (a.u.)
%       - rho_psi_ts_sr: rho as square root of normalized poloidal psi (a.u.)
%       - T_ts_fit: Electron temperature profile from fit (keV)
%       - N_ts_fit: Electron density profile from fit (m-3)
%       - T_ts_sr: Electron temperature profile from Thomson scattering (keV)
%       - N_ts_sr: Electron density profile from Thomson scattering (m-3)
%
%   by Y. Peysson <yves.peysson@cea.fr> (CEA/IRFM)
%
if nargin == 5,
    display_mode = 0;
    nefit_mode = 2;
end
%
if nargin == 6,
    nefit_mode = 2;
end
%
rho_LUKE = equil.ptx(:,1)./equil.ptx(end,1);
psin_LUKE = equil.psi_apRp./equil.psi_apRp(end);
%
equil_RZ = pt2rz_jd(equil);
%
T = @(x,a,b)a*exp(-x.^2/b^2);%Gaussian curve fit 
%
if nefit_mode == 1,       
    N = @(x,a,b)a*(1-x.*x).^b;%Bell shaped curvefit 
elseif nefit_mode == 2,     
    N = @(x,a,b,c)a./(1+exp((x-b)/c));%Fermi function curve fit 
end
%
% Sort data
%
[Z_ts_s,is] = sort(Z_ts,'descend');%Reorder vertical position
T_ts_s = T_ts(is);
N_ts_s = N_ts(is)/1e19;
N_ts_s(find(N_ts_s>100)) = NaN;% remove possible wrong points
%
X_ts_s = (R_ts - equil.Rp)*ones(size(Z_ts_s));
Y_ts_s = Z_ts_s - equil.Zp;
%
rho_LUKE_ts_s = psi2rho_jd(equil,abs(interp2(equil_RZ.x,equil_RZ.y,equil_RZ.xypsi_apRp,X_ts_s,Y_ts_s)./max(abs(equil_RZ.psi_apRp))));
%
[rho_LUKE_ts_sr,isr] = sort(rho_LUKE_ts_s,'descend');
T_ts_sr = T_ts_s(isr);
N_ts_sr = N_ts_s(isr);
%
opts = statset('nlinfit');
opts.RobustWgtFun = 'talwar';
%
nonLinMdl_T_ts_sr = fitnlm(rho_LUKE_ts_sr,T_ts_sr,@(p,x)T(x,p(1),p(2)),[max(T_ts_sr),1],'Options',opts);
%
if nefit_mode == 1,         
    nonLinMdl_N_ts_sr = fitnlm(rho_LUKE_ts_sr,N_ts_sr,@(p,x)N(x,p(1),p(2)),[max(N_ts_sr),0.5],'Options',opts);
elseif nefit_mode == 2,
    nonLinMdl_N_ts_sr = fitnlm(rho_LUKE_ts_sr,N_ts_sr,@(p,x)N(x,p(1),p(2),p(3)),[max(N_ts_sr),0.5,0.5],'Options',opts);
end
%
T_ts_fit = T(rho_LUKE,nonLinMdl_T_ts_sr.Coefficients.Estimate('p1'),nonLinMdl_T_ts_sr.Coefficients.Estimate('p2'));
%
if nefit_mode == 1, 
    N_ts_fit = N(rho_LUKE,nonLinMdl_N_ts_sr.Coefficients.Estimate('p1'),nonLinMdl_N_ts_sr.Coefficients.Estimate('p2'));
elseif nefit_mode == 2, 
    N_ts_fit = N(rho_LUKE,nonLinMdl_N_ts_sr.Coefficients.Estimate('p1'),nonLinMdl_N_ts_sr.Coefficients.Estimate('p2'),nonLinMdl_N_ts_sr.Coefficients.Estimate('p3'));
end    
%    
if display_mode == 1  
    %
    figure,plot(Z_ts_s,T_ts_s,'ro');grid on
    title([strrep(equil.id,'_','-'),', raw Te profile (Thomson scattering)']),xlabel(['Z@R=',num2str(R_ts),' (m)']),ylabel('T_e (eV)')
    %
    figure,plot(Z_ts_s,N_ts_sr,'ro');grid on
    title([strrep(equil.id,'_','-'),', raw Ne profile (Thomson scattering)']),xlabel(['Z@R=',num2str(R_ts),' (m)']),ylabel('N_e (10^{+19} m^{-3})')
    %
    figure,plot(rho_LUKE_ts_sr,T_ts_sr,'ro',rho_LUKE,T_ts_fit);grid on
    title([strrep(equil.id,'_','-'),', Te profile for LUKE']),xlabel('\rho_{LUKE}'),ylabel('T_e (eV)')
    legend('Exp.','Fit')
    %
    figure,plot(rho_LUKE_ts_sr,N_ts_sr,'ro',rho_LUKE,N_ts_fit);grid on
    title([strrep(equil.id,'_','-'),', Ne profile for LUKE']),xlabel('\rho_{LUKE}'),ylabel('N_e (10^{+19} m^{-3})')
    legend('Exp.','Fit')
    %
    figure,plot(sqrt(rho2psi_jd(equil,rho_LUKE_ts_sr)),T_ts_sr,'ro',sqrt(psin_LUKE),T_ts_fit);grid on
    title([strrep(equil.id,'_','-'),', Te profile for LUKE']),xlabel('\rho = sqrt(\psi_{n})'),ylabel('T_e (eV)')
    legend('Exp.','Fit')
    %
    figure,plot(sqrt(rho2psi_jd(equil,rho_LUKE_ts_sr)),N_ts_sr,'ro',sqrt(psin_LUKE),N_ts_fit);grid on
    title([strrep(equil.id,'_','-'),', Ne profile for LUKE']),xlabel('\rho = sqrt(\psi_{n})'),ylabel('N_e (10^{+19} m^{-3})')
    legend('Exp.','Fit')
    %   
end
%
rho_psi_ts_sr = sqrt(rho2psi_jd(equil,rho_LUKE_ts_sr));%rho as square root of normalized poloidal psi
%
T_ts_sr = T_ts_sr/1000;%keV
N_ts_sr = N_ts_sr*1e19;%m-3
T_ts_fit = T_ts_fit/1000;%keV
N_ts_fit = N_ts_fit*1e19;%m-3
%
equil_new = equil;
%
equil_new.pTe = T_ts_fit;
equil_new.pne = N_ts_fit;
%








