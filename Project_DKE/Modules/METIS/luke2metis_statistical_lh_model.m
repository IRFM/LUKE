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
% script which interface LUKE data to 
%
% Y. Peysson, CEA/IRFM (yves.peysson@cea.fr) and J.-F. Artaud CEA/IRFM (jean-francois.artaud@cea.fr)
%
load('LUKE_DATA_EAST_054439_005100_C3PO_antenna_4p60Ghz_ne7e17_TAIL_st_ct_Nmax_0_n_5_P_0.5_opt_1+1i_VLOOP_0p19V.mat');
%
mksa = output.mksa;
equil = equilconsistency_yp(equil,'');%for calculating missing quantities
%
%profil.xli = ; % Lao coordinate (r/a) [1 * n_rho]  
%profil.Raxe = ; % magnetic axis of each flux surface (m) [n_time * n_rho] 
%profil.epsi = ; % inverse aspect ratio (a(x) / Raxe(x)) of each flux surface (m) [n_time * n_rho] 
%profil.fdia = ; % diamagnetic function (R*B_T in T.m)   [n_time * n_rho] 
profil.qjli = equil.consistency.q; % safety factor  [n_time * n_rho]
profil.nep = equil.pne; % electron density (m^-3) [n_time * n_rho]
profil.tep = equil.pTe;% electron temperature (eV) [n_time * n_rho]
%profil.rmx = ;% toroidal flux coordinate (sqrt(phi_tor/pi/B0) in m) [n_time * 21]
%profil.spr = ;% dS/dxli surface element (m^2) [n_time * 21]
%profil.vpr = ;% dV/dxli surface element (m^3) [n_time * 21]
profil.zeff = (equil.zZi.^2*equil.pzni)./equil.pne;% effective charge [n_time * 21]
profil.epar = ohm.epsi*mksa.Edreicer_ref;% parallel electrique field (V/m) [n_time * 21]
%
cons.temps = equil.id;% time slices vector [n_time * 1] (just a reference here)
cons.ip = equil.ip*1e6;% plasma current (A) [n_time * 1]
%
option.gaz = find(equil.pzni(:,1) == max(equil.pzni(:,1)));% 1 -> H, 2 -> D , 3 -> DT & 4 -> He
option.fupshift = 1;% factor applied to kinetic resonance position: n_par_Landau = fupshift * 6.5 / sqrt(Te); default = 1
%
jj = 1;
%
for iw = 1:length(waves)
    %
    if strcmp(waves{iw}.rayinit.type,'LH'),
        %
        for ir = 1:length(waves{iw}.rays)
            cons.plh = waves{iw}.rays{ir}.P0_2piRp(1)*2*pi*equil.Rp;% LH input power (W) [n_time * 1]
            option.freqlh = waves{iw}.rayinit.omega_rf/2/pi/1e9;% Lower Hybrid frequency (GHz)
            option.etalh = 1;% launcher directivity defined as the fraction of total LH power in the co-current peak
            option.npar0 = real(waves{iw}.rays{ir}.sNpar(1));% launched parallel refractive index of LH at antennafind(
            option.wlh = waves{iw}.rays{ir}.sdNpar(1);% wlh is the width of LH antenna active part (m)
            option.npar_neg = 0;% parallel refractive index of negative peak in the spectrum at the launcher; if = 0, used npar_neg = -npar0
            %
            [res(jj).time,res(jj).plh_tot,res(jj).ilh,res(jj).x,res(jj).plh,res(jj).jlh,res(jj).efficiency] = external_call_metis_lh_model(cons,profil,option);
            %
            jj = jj + 1;
        end
    end
%
end
%
% display results 
%
