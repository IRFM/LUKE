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
function [ZXXD_s,ZXXF_s,ZXXD_s_tp,ZXXF_s_tp] = synchrotron_dke_jd(dkeparam,display,equilDKE,mksa,gridDKE,Zmomcoef,Zbouncecoef)
%
% Calculate matrix coefficient for the synchrotron reaction force in LUKE
%
% by J. DECKER (joan.decke@cea.fr) and Y. PEYSSON (yves.peysson@cea.fr)
%
display_mode = display.display_mode;
dke_mode = dkeparam.dke_mode;
synchro_mode = dkeparam.synchro_mode;
%
etime_synchro = 0;
time0 = clock;
%
xB0 = equilDKE.xB0;
Xmhup = gridDKE.Xmhup;
Xmhum = gridDKE.Xmhum;
X1mmhu2 = gridDKE.X1mmhu2;
X1mmhu2p = gridDKE.X1mmhu2p;
X1mmhu2m = gridDKE.X1mmhu2m;
Xpn = gridDKE.Xpn;
Xpnp = gridDKE.Xpnp;
Xpnm = gridDKE.Xpnm;
%
rdke =gridDKE.rdke;
npn = gridDKE.npn;%Size of the momentum grids for the distribution function (half grid)
nmhu = gridDKE.nmhu;
nr = gridDKE.nr;%Size of the radial grid for the distribution function (half grid)
nr_dke =gridDKE.nr_dke;%Size of the effective radial grid for the drift kinetic equation (nr_dke = nr for FPE equation only)
%
Xgamma = Zmomcoef.Xgamma;
Xgammap = Zmomcoef.Xgammap;
Xgammam = Zmomcoef.Xgammam;
%
taur_ref = mksa.taur_ref;
%
XXRlambda_p0p3 = Zbouncecoef.XXRlambda_p0p3;
XXRlambda_p2p2_m = Zbouncecoef.XXRlambda_p2p2_m;
XXRlambda_p2p2_p = Zbouncecoef.XXRlambda_p2p2_p;
%
% Output files initialization
%
% Terms from Sp at l+1/2 (Notations: _imj -> (i,j+1+2);_ipj -> (i+1,j+1/2)
%
ZXXD_s.pp_ipj = zeros(npn,nmhu,nr);%momentum dynamics only
ZXXD_s.pp_imj = zeros(npn,nmhu,nr);%momentum dynamics only
ZXXD_s.pm_ipj = zeros(npn,nmhu,nr);%momentum dynamics only
ZXXD_s.pm_imj = zeros(npn,nmhu,nr);%momentum dynamics only
ZXXD_s.pr_ipj = zeros(npn,nmhu,nr);
ZXXD_s.pr_imj = zeros(npn,nmhu,nr);
%   
ZXXF_s.p_ipj = zeros(npn,nmhu,nr);%momentum dynamics only
ZXXF_s.p_imj = zeros(npn,nmhu,nr);%momentum dynamics only
%
% Terms from Sksi at l+1/2 (Notations: _ijp -> (i+1/2,j+1);_ijm -> (i+1/2,j)
%
ZXXD_s.mm_ijp = zeros(npn,nmhu,nr);%momentum dynamics only
ZXXD_s.mm_ijm = zeros(npn,nmhu,nr);%momentum dynamics only
ZXXD_s.mp_ijp = zeros(npn,nmhu,nr);%momentum dynamics only
ZXXD_s.mp_ijm = zeros(npn,nmhu,nr);%momentum dynamics only
ZXXD_s.mr_ijp = zeros(npn,nmhu,nr);
ZXXD_s.mr_ijm = zeros(npn,nmhu,nr);
%
ZXXF_s.m_ijp = zeros(npn,nmhu,nr);%momentum dynamics only
ZXXF_s.m_ijm = zeros(npn,nmhu,nr);%momentum dynamics only
%
% Terms from Spsi at (i+1/2,j+1/2) (Notations: _lm -> (l);_lp -> (l+1);
%
ZXXD_s.rr_lm = zeros(npn,nmhu,nr);%radial dynamics only
ZXXD_s.rr_lp = zeros(npn,nmhu,nr);%radial dynamics only
ZXXD_s.rp_lm = zeros(npn,nmhu,nr);
ZXXD_s.rp_lp = zeros(npn,nmhu,nr);
ZXXD_s.rm_lm = zeros(npn,nmhu,nr);
ZXXD_s.rm_lp = zeros(npn,nmhu,nr);
%
ZXXF_s.r_lm = zeros(npn,nmhu,nr);%radial dynamics only
ZXXF_s.r_lp = zeros(npn,nmhu,nr);%radial dynamics only
%
% Terms used by the old scheme only for momentum cross-derivatives (M.
% Shoucri and I. Shkarofsky,Comp. Phys. Comm., 82 (1994) 287)
%
ZXXD_s.pp_ij = zeros(npn,nmhu,nr);
ZXXD_s.pm_ij = zeros(npn,nmhu,nr);
ZXXD_s.mp_ij = zeros(npn,nmhu,nr);
ZXXF_s.p_ij = zeros(npn,nmhu,nr);
%
if dke_mode == 1
    %
    ZXXD_s_tp.pp_ippj = zeros(npn,nmhu,nr_dke);
    ZXXD_s_tp.pp_ipj = zeros(npn,nmhu,nr_dke);
    ZXXD_s_tp.pp_ij = zeros(npn,nmhu,nr_dke);
    ZXXD_s_tp.pp_imj = zeros(npn,nmhu,nr_dke);
    ZXXD_s_tp.pp_immj = zeros(npn,nmhu,nr_dke);
    ZXXD_s_tp.pm_ipj = zeros(npn,nmhu,nr_dke);
    ZXXD_s_tp.pm_ij = zeros(npn,nmhu,nr_dke);
    ZXXD_s_tp.pm_imj = zeros(npn,nmhu,nr_dke);
    ZXXD_s_tp.mp_ijp = zeros(npn,nmhu,nr_dke);
    ZXXD_s_tp.mp_ij = zeros(npn,nmhu,nr_dke);
    ZXXD_s_tp.mp_ijm = zeros(npn,nmhu,nr_dke);
    ZXXD_s_tp.mm_ijp = zeros(npn,nmhu,nr_dke);
    ZXXD_s_tp.mm_ijm = zeros(npn,nmhu,nr_dke);
    %
	ZXXF_s_tp.p_ippj = zeros(npn,nmhu,nr_dke);
	ZXXF_s_tp.p_ipj = zeros(npn,nmhu,nr_dke);
	ZXXF_s_tp.p_ij = zeros(npn,nmhu,nr_dke);
	ZXXF_s_tp.p_imj = zeros(npn,nmhu,nr_dke);
	ZXXF_s_tp.p_immj = zeros(npn,nmhu,nr_dke);
	ZXXF_s_tp.m_ijp = zeros(npn,nmhu,nr_dke);
	ZXXF_s_tp.m_ijm = zeros(npn,nmhu,nr_dke);
    %    
else
    %    
	ZXXD_s_tp = NaN;
	ZXXF_s_tp = NaN;
    %
end
%
if synchro_mode == 1,
    %
    for ir = 1:nr,
        %   
        % Synchrotron reaction flux coefficients calculations for f0 and g
        %   
        ZXXF_s.p_ipj(:,:,ir) = -Xgammap.*Xpnp.*X1mmhu2.*XXRlambda_p0p3(:,:,ir)*(xB0(ir)/xB0(1))^2/taur_ref;
        ZXXF_s.p_ij(:,:,ir) = -Xgamma.*Xpn.*X1mmhu2.*XXRlambda_p0p3(:,:,ir)*(xB0(ir)/xB0(1))^2/taur_ref;
        ZXXF_s.p_imj(:,:,ir) = -Xgammam.*Xpnm.*X1mmhu2.*XXRlambda_p0p3(:,:,ir)*(xB0(ir)/xB0(1))^2/taur_ref;
        ZXXF_s.m_ijp(:,:,ir) = -(Xpn.*Xmhup.*sqrt(X1mmhu2p).*XXRlambda_p2p2_p(:,:,ir)./Xgamma)*(xB0(ir)/xB0(1))^2/taur_ref;
        ZXXF_s.m_ijm(:,:,ir) = -(Xpn.*Xmhum.*sqrt(X1mmhu2m).*XXRlambda_p2p2_m(:,:,ir)./Xgamma)*(xB0(ir)/xB0(1))^2/taur_ref;
        %
        % Synchrotron reaction flux coefficients calculations for ftp
        %   
        if dke_mode == 1
            %
            ir_dke = find(ir == rdke);
            if isempty(ir_dke)
                continue
            end
            %
            %%TODO
            %
        end
    end
    %
end
%
etime_synchro = etime_synchro + etime(clock,time0);
if display_mode >= 1,
    info_dke_yp(2,['Synchrotron reaction flux coefficients calculations done in ',num2str(etime_synchro),' (s)']);
end	
%
