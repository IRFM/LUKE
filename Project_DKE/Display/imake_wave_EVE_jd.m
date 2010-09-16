function wave = imake_wave_EVE_jd(basestr,equil,workdir,opt_gui)
%
% this function reads the EVE output data and creates the wave structure
% for LUKE FW diffusion coefficient
%
wave = '';
%
if isfield(equil,'prof_src') && exist(equil.prof_src,'file'),
    %
    filename = equil.prof_src;
    %
else
    %
    [data_file,data_path] = igetfile_jd(opt_gui,'*.*','Please select the EVE output file :',workdir);
    %
    if data_file == 0,
        return
    else
        filename = [data_path,data_file];
    end
    %
end
%
load(filename,'eve');
%
disp(['EVE output data for ',basestr,' equilibrium loaded from file : ',filename])
%
% The coefficients are defined such that the diffusion coefficient in energy is :
%
% Dql = D_EE + uperp^2 D_EB + uperp^4 D_BB
%
% where uperp is normalized to sqrt(2T/m) (local temperature)
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum] = pc_dke_yp;
%
xupar_S = eve.upar;%parallel velocity normalized to sqrt(2T/m) 
yrho_S = eve.sg;%radial grid, SR of normalized toroidal flux
%
xupar = (xupar_S(1:end-1) + xupar_S(2:end))/2;
yrho = (yrho_S(1:end-1) + yrho_S(2:end))/2;
%
xyD_EE = (eve.D_EE(1:end-1,1:end-1) + eve.D_EE(1:end-1,2:end) + eve.D_EE(2:end,1:end-1) + eve.D_EE(2:end,2:end))/4;% EE diffusion coefficient (not normalized)
xyD_EB = (eve.D_EB(1:end-1,1:end-1) + eve.D_EB(1:end-1,2:end) + eve.D_EB(2:end,1:end-1) + eve.D_EB(2:end,2:end))/4;% EE diffusion coefficient (not normalized)
xyD_BB = (eve.D_BB(1:end-1,1:end-1) + eve.D_BB(1:end-1,2:end) + eve.D_BB(2:end,1:end-1) + eve.D_BB(2:end,2:end))/4;% EE diffusion coefficient (not normalized)
yTe = eve.Te;% electron temperature (keV);
%
% universal normalization
%
nx = length(xupar);
%
ybetath_eve = sqrt(2*yTe/mc2).';
xybetath_eve = repmat(ybetath_eve,[nx,1]);
%
xyuparc = xupar*ybetath_eve;% parallel velocity normalized to c
xyuparc_S = xupar_S*ybetath_eve;% parallel velocity normalized to c
%
xyD_EE = xyD_EE/(me*clum^2)^2;% normalized to (mc2)^2
xyD_EB = xyD_EB/(me*clum^2)^2./xybetath_eve.^2;
xyD_BB = xyD_BB/(me*clum^2)^2./xybetath_eve.^4;
%
% D// and D_EE are related by : D_EE = upar^2 D//.
%
% Thus D// will be normalized to (mc)^2
%
wave.id = 'EVE';
wave.equil_id = equil.id;
wave.model = 'FW';
%
wave.Xvpar = xyuparc;
wave.Xvpar_S = xyuparc_S;
%
xyuparc(xyuparc == 0) = eps;
wave.XDql_LD = xyD_EE./xyuparc.^2;
wave.XDql_MX = xyD_EB./xyuparc.^2;
wave.XDql_TT = xyD_BB./xyuparc.^2;
%
wave.rho = yrho;
wave.rho_S = yrho_S;
%
wave.rhotype = 't';%square root of normalized toroidal flux
%
wave.pe_eve = eve.pe_eve;
wave.pe_dql = eve.pe_dql;
%



