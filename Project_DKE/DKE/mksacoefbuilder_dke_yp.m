function [mksa] = mksacoefbuilder_dke_yp(dkeparam,display,equilDKE,radialDKE)
%
% LUKE - Calculation of mksa coefficients for the 3D electron relativistic drift kinetic solver
%
%   by Y. Peysson (CEA/DSM/IRFM) (yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM) (joan.decker@cea.fr)
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;%Universal physics constants
%
%Reference plasma parameters (for the normalization: pth_ref, nhuth_ref)
%
if length(radialDKE.r_dke) > 1 | dkeparam.ref_mode == 0,
    Te_ref = max(equilDKE.xTe);%Core temperature
    ne_ref = max(equilDKE.xne);%Core density
    if display.display_mode >= 1
        info_dke_yp(2,'Core reference temperature and density');
        disp('-------------------------------------------------------------------------------------------------------------------');
    end 
else
    if dkeparam.dke_mode == 0,
        Te_ref = equilDKE.xTe(1);%Local temperature
        ne_ref = equilDKE.xne(1);%Local density
        if display.display_mode >= 1
            info_dke_yp(2,'Local reference temperature and density');
            disp('-------------------------------------------------------------------------------------------------------------------');
        end     
    else
        Te_ref = equilDKE.xTe(2);%Local temperature
        ne_ref = equilDKE.xne(2);%Local density
        if display.display_mode >= 1
            info_dke_yp(2,'Local reference temperature and density');
            disp('-------------------------------------------------------------------------------------------------------------------');
        end     
    end
end
%
mksa.betath_ref = sqrt(Te_ref/mc2);%Normalized pth_ref/mc as prescribed by Karney
mksa.Te_ref = Te_ref;%Temperature (keV)
mksa.ne_ref = ne_ref;%Density (m-3)
mksa.lnc_e_ref = 31.3 - 0.5*log(ne_ref) + log(Te_ref*1000);%Reference Coulomb logarithm (Sauter et al. Phys. Plasmas, 6 (1999) 2834)
mksa.nhu_ref = qe^4*ne_ref*mksa.lnc_e_ref/(4*pi*e0^2*me^2*(clum*mksa.betath_ref)^3);%Reference electron collision frequency (s-1)
mksa.xftp_norm_ref = me*clum*mksa.betath_ref*equilDKE.ap*(1 + equilDKE.xx0/equilDKE.Rp).*equilDKE.xBT0./equilDKE.xB0/qe/equilDKE.psia_apRp;%Normalization factor for drift kinetic equation (ftilde)
mksa.j_ref = -qe*clum*mksa.betath_ref*mksa.ne_ref/1e6;%MKSA current unit (MA)  (with respect to the parallel direction fo B, the negative charge of the electron is fully considered)
mksa.P_ref = me*(clum*mksa.betath_ref)^2*mksa.nhu_ref*mksa.ne_ref/1e6; %power normalization constant (MW)
mksa.Edreicer_ref = me*clum*mksa.betath_ref*mksa.nhu_ref/qe;%MKSA Dreicer field unit
mksa.wpe_ref = sqrt(ne_ref*qe^2/me/e0);%MKSA plasma frequency (s-1)
mksa.wmabs2 = me*mksa.lnc_e_ref*mksa.wpe_ref^2/(4*pi^2);%coefficient relating the squared electric field amplitude to the diffusion coefficient
%
mksa.vde_ref = mksa.betath_ref*mksa.betath_ref*me*clum*clum/2/pi/abs(qe)/equilDKE.xB0(1,1)/equilDKE.Rp;%Electron drift velocity (m.s-1)
mksa.taude_ref = equilDKE.ap/mksa.vde_ref;%Electron drift time scale (s)