function rundke_AMR(basestr,id_simul,shotnum,shotime,iAnt,iConf,np,nt,dsmin,kmode,opt_save)
%
if nargin < 11,
    opt_save = 0;% save equil and wave structures separately
end
if nargin < 10,
    kmode = 4;% save equil and wave structures separately
end
if nargin < 9,
    dsmin = 0;% save equil and wave structures separately
end
if nargin < 8,
    nt = 65;% Number of equilibrium poloidal points
end
if nargin < 7,
    np = 101;% Number of equilibrium radial points
end
%
% Function for running LUKE after reading AMR equil and wave files
%
% by J. Decker (joan.decker@cea.fr) and J. Urban (jakub.urban@ipp.cas.cz)
%
warning off
%
%%%%%%%%%%%%%%%%%%%BEGIN-LUKE-PATH%%%%%%%%%%%%%%%%%%%
luke_root = [getenv('LUKE'),'/'];
addpath([luke_root,'Project_DKE/DKE']);
addpath(['/home/luke/Tools/DISP/EBW']);
setpath_luke_jd(luke_root);
%%%%%%%%%%%%%%%%%%%%END-LUKE-PATH%%%%%%%%%%%%%%%%%%%%
%
shotnum = num2str(shotnum,'%6d');
shotnum = [repmat('0',[1,6-length(shotnum)]),shotnum];
shotime = num2str(shotime,'%6.3f');
%
% ****************** SIMULATION PARAMETERS ********************************
%
AMR_output_path = [pwd,'/output/luke/'];
%
% *********************** WAVE PARAMETERS *********************************
%
wave_id = '';% Specific wave id
%
wavestruct.dNpar = NaN;% Spectral width (NaN if calculated from beam size)
wavestruct.dsmin = dsmin;% Spectral width (NaN if calculated from beam size)
wavestruct.kmode = kmode;% Plasma model for wave propagation : 0:cold, 1:kinetic, 2:R2D2 (requires IMSL)
wavestruct.opt_rf = 0;% FLR effects : 0:all, 1:small
%
wavestruct.nd = 1;% Number of transverse distance positions for beamlets (for one ray only)
wavestruct.nchi = 1;% Number of angular positions for beamlets (for one ray only)
%
% *********************** OUTPUT PARAMETERS *******************************
%
output_display = 0;% display output
%
ir_display = 0;% Index of flux-surface for distribution (0 to skip)
pnmax = 0;% Maximum value of p/pT for display : (-1) auto, (0) grid, or specify
p_opt = -1;% Option for output figures : -1 (nothing), 0 (print), 1 (print and save), 2 (save)
dp_cyl = 0.1;% precision of plots in cyclindrical momentum geometry
%
% ************************ RUN PARAMETERS *********************************
%
id_dkepath = 'LOCAL';%For all paths used by DKE solver
path_dkepath = '/home/luke/LUKE/Project_DKE/Database/PATH_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'EC_RT';%For DKE code parameters
path_dkeparam = '/home/luke/LUKE/Project_DKE/Database/DKEPARAM_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkedisplay = 'NO_DISPLAY';%For output code display
path_dkedisplay = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
% *************************************************************************
% *************************************************************************
%
antnumbase = num2str(iAnt);
antnum = ['0'*ones(1,2-length(antnumbase)),antnumbase];
%
antconfbase = num2str(iConf);
antconf = ['0'*ones(1,4-length(antconfbase)),antconfbase];
%
wavestruct.wavesolver = 'AMR';
wavestruct.id = [wavestruct.wavesolver,'_',antnum,'_',antconf,wave_id];
%
wavestruct.AMR_output_path = AMR_output_path;
wavestruct.filestr = [antnum,'_',antconf,'_',shotnum,'_',shotime];
%
wavestruct.iAnt = iAnt;
wavestruct.iConf = iConf;
%
wavestructs{1} = wavestruct;
%
id_simul = [wavestruct.id,id_simul];
%
[dkepath,dkeparam,dkedisplay] = load_structures_yp('dkepath',id_dkepath,path_dkepath,'dkeparam',id_dkeparam,path_dkeparam,'dkedisplay',id_dkedisplay,path_dkedisplay);
%
%**************************************************************************
%
amr_psi_files = dir(AMR_output_path);
%
for ifile = 1:length(amr_psi_files),
    %
    amr_psi_file = amr_psi_files(ifile).name;
    %
    if length(amr_psi_file) > 8 && strcmp(amr_psi_file(1:8),'m_profs_'),
        it1 = 8 + strfind(amr_psi_file(9:end),'_');
        shotnum = amr_psi_file(9:it1(1)-1);
        it2 = it1(1) + strfind(amr_psi_file(it1+1:end),'_');
        shotime = amr_psi_file(it1(1)+1:it2(1)-1);
        %
        break
        %
    end
    %
end
%
if ~exist('shotnum','var'),
    error('Equilibrium files not found. aborted.')
end
%  
id_equil = [basestr,'_',shotnum,'_',shotime];
%
dispname = '';
savename = id_equil;
%
[equil_magnetic,equil_prof] = make_equil_AMR_jd(AMR_output_path,shotnum,shotime,dkedisplay.display_mode,p_opt,dispname,savename,np,nt);
equil = conc_struct_jd(equil_magnetic,equil_prof);
%
equil.id = id_equil;
equil.info.gen = 'Built from AMR rundke';
equil.info.shotnum = shotnum;
equil.info.shotime = shotime;
%
equil.info.datapath = AMR_output_path;
%
disp('Equilibrium converted to LUKE format')
%
[Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = run_lukert(id_simul,wavestructs,[],[],dkeparam.rho_S,dkepath,equil,dkeparam,dkedisplay,'','','',[],[],opt_save);
%
%************************************************************************************************************************************
%
filename = ['LUKE_RESULTS_',equil.id,'_',id_simul,'.mat'];
save(filename);
info_dke_yp(2,['LUKE Results saved in ',filename]);
%
output = load(filename);
%
if output_display == 1,
    %
    proc_luke_jd(output,ir_display,p_opt,dp_cyl,pnmax);
    %
end
%
exit


