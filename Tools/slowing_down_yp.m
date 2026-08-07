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
function [tau_sd,tau_ei_sd,tau_ee_sd] = slowing_down_yp(equil,E0,disp_mode)
%
% Slowing-down time of fast test electrons with a thermal plasma bulk. Ref. : NRL plasma formulary 2016 
%    
%    Input:
%
%	  - equil: equilibrium structure
%	  - E0: electron kinetic energy (keV) [1,nE]
%           (default E0 = [10:10:200])
%     - disp_mode: display results [1,1]
%           (default disp_mode = 0)
%
%    Output:
%
%         - tau_sd: fast electron slowing-down time (ms) [nE,npsi]
%         - tau_ee_sd: fast electron slowing-down time by electrons (ms) [nE,npsi]
%         - tau_ei_sd: fast electron slowing-down time by ions (ms) [nE,npsi]
%
if nargin == 1,
    E0 = [10:10:200];%keV
    disp_mode = 0;
end
%
if nargin == 2,
    disp_mode = 0;
end
if isempty(E0) | isnan(E0),
	E0 = [10:10:200];%keV
end
%
lambda_ee = 23.5 - log((equil.pne(:)/1e6).^(1/2).*(equil.pTe(:)*1000).^(-5/4)) - (1e-5 + log((equil.pTe(:)*1000)-2).^2/16).^(1/2);
lambda_ei = 24 - log((equil.pne(:)/1e6).^(1/2).*(equil.pTe(:)*1000).^(-1));
%
E0 = E0(:)';
%
pnhu_ee = 7.7e-6*(equil.pne(:)/1e6).*lambda_ee*(E0*1000).^(-3/2);
pnhu_ei = 3.9e-6*sum(((equil.pzni/1e6).*(ones(length(equil.pne),1)*equil.zZi.^2)')',2).*lambda_ei*(E0*1000).^(-3/2);
pnhu_sd = pnhu_ee + pnhu_ei;
%
tau_sd = 1000./pnhu_sd;%ms
tau_ee_sd = 1000./pnhu_ee;%ms
tau_ei_sd = 1000./pnhu_ei;%ms
%
xE0 = ones(length(equil.pne),1)*E0;
%
if disp_mode & length(E0) > 10,
        figure('name',[strrep(equil.id,'_','-'),' [NRL plasma formulary 2016]'])
        graph1D_jd(E0,tau_sd(1,:),0,1,'E_c (keV)','\tau_{sd} (ms)',[strrep(equil.id,'_','-'),' [NRL plasma formulary 2016]'],NaN,NaN,NaN,'-','none','r',2);
        graph1D_jd(E0,tau_sd(round(length(equil.pne)/2),:),0,1,'E_c (keV)','\tau_{sd} (ms)',[strrep(equil.id,'_','-'),' [NRL plasma formulary 2016]'],NaN,NaN,NaN,'--','none','b',2);
        graph1D_jd(E0,tau_sd(end,:),0,1,'E_c (keV)','\tau_{sd} (ms)',[strrep(equil.id,'_','-'),' [NRL plasma formulary 2016]'],NaN,NaN,NaN,'-.','none','k',2);
        legend(['Center : n_e = ',num2str(round(10*equil.pne(1)/1e19)/10),'x10^{+19} m^{-3}, T_e = ',num2str(round(10*equil.pTe(1))/10),' keV'],['Mid-radius : n_e = ',num2str(round(10*equil.pne(round(length(equil.pne)/2))/1e19)/10),'x10^{+19} m^{-3}, T_e = ',num2str(round(10*equil.pTe(round(length(equil.pne)/2)))/10),' keV'],['Edge : n_e = ',num2str(round(10*equil.pne(end)/1e18)/10),'x10^{+18} m^{-3}, T_e = ',num2str(round(100*equil.pTe(end))/100),' keV']);
end



