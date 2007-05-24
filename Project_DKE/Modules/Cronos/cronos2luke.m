% zstarwars profil de depot hybride + EC calcule par C3PO + LUKE
%--------------------------------------------------------------
% fichier zstarwars.m -> fichiers source dans repertoire ~/Project_DKE/Modules/Cronos/
%
% Cette fonction calcule le depot pour l'onde hybride et de l'onde EC avec le code cinetique LUKE
% et le trace de rayon C3PO.
% 
% syntaxe  :
%  
%      [sortie,memoire] = zstarwars(par,proto,cons,cons_spec,geo,equi,injection,prof,neo,impur,phy,compo,gene,memoire);
%
% entree :
%
%      par             =    parametre propre a la fonction (param.cons.hyb)
%      proto           =    prototype de la structure pour les sources, valeurs a zeros (proto = zsourceproto;)
%      cons            =    consigne de puissance par coupleur (data.cons.hyb)
%      cons_spec       =    spectre en puissance par coupleur (data.cons.hybspec)
%      geo             =    geometrie du plasma (data.geo)
%      equi            =    donnees de l'equilibre plasma (data.equi)
%      injection       =    consigne d'injection de gaz (data.cons.c)
%      prof            =    profils des donnees calculees par le code (data.prof) 
%      neo             =    donnees neoclassiques (data.neo)
%      impur           =    sous strcuture des impurtes (data.impur)
%      phy             =    constantes physiques (param.phys)
%      compo           =    composition du plasma: charge et masse des atomes (param.compo)
%      gene            =    parametres generaux (param.gene)
%      memoire         =    structure des dernieres valeurs calculees
% 
% sortie :
% 
%     sortie           =  structure de type source remplie par le module (sortie === proto)
%     memoire          =  datak.memoire.hyb (valeur de reference pour le dernier calcul complet, 
%                         pas utiliser dans cette fonction, reserve pour d'autres modules)
% 
%
% fonction ecrite par Y. Peyssson, J. Decker et V. Basiuk, poste 6290 ou 6126
% version 3.0, du 28/11/2006.
% 
% 
% liste des modifications : 
%-------------------------------------------------------------


%-------------------------------------------------------------
%
function [sortie,memoire] = zstarwars(varargin);
%                             
if nargin <= 1 
	if nargin == 0
		nbfce = 1;
	else
		nbfce = varargin{1};   
	end
	langue = getappdata(0,'langue_cronos');
%
%--------------------------- EQUATION DE DERIVE CINETIQUE ------------------
%
%
% LUKE PARAMETERS
%
    valeur.abs_lim = 0.95;%Relative level of RF power absorption that is accpeted for in the quasilinear convergence loop (0: no threshold, 1: full absorption)
	type.abs_lim = 'float';%Relative level of RF power absorption that is accpeted for in the quasilinear convergence loop (0: no threshold, 1: full absorption)
	borne.abs_lim = [0,1];%Relative level of RF power absorption that is accpeted for in the quasilinear convergence loop (0: no threshold, 1: full absorption)
	defaut.abs_lim = 0.95;%Relative level of RF power absorption that is accpeted for in the quasilinear convergence loop (0: no threshold, 1: full absorption)
	info.abs_lim = 'Relative level of RF power absorption that is accpeted for in the quasilinear convergence loop (0: no threshold, 1: full absorption)';
%
    valeur.rt_mode = 4;%RT-FP quasilinear selfconsistency method: (1) -> fixed dNpar given at the antenna, (2) -> dNpar proportional to Npar, (3) dNpar proportional to Npar but its value is chosen automatiicaly to maximize j/p, (4) -> dNpar proportional to s
	type.rt_mode = 'list';%RT-FP quasilinear selfconsistency method: (1) -> fixed dNpar given at the antenna, (2) -> dNpar proportional to Npar, (3) dNpar proportional to Npar but its value is chosen automatiicaly to maximize j/p, (4) -> dNpar proportional to s
	borne.rt_mode = {1,2,3,4};%RT-FP quasilinear selfconsistency method: (1) -> fixed dNpar given at the antenna, (2) -> dNpar proportional to Npar, (3) dNpar proportional to Npar but its value is chosen automatiicaly to maximize j/p, (4) -> dNpar proportional to s
	defaut.rt_mode = 4;%RT-FP quasilinear selfconsistency method: (1) -> fixed dNpar given at the antenna, (2) -> dNpar proportional to Npar, (3) dNpar proportional to Npar but its value is chosen automatiicaly to maximize j/p, (4) -> dNpar proportional to s
	info.rt_mode = 'RT-FP quasilinear selfconsistency method: (1) -> fixed dNpar given at the antenna, (2) -> dNpar proportional to Npar, (3) dNpar proportional to Npar but its value is chosen automatiicaly to maximize j/p, (4) -> dNpar proportional to s';
%
	valeur.nit_rf = 40;%Maximum number of iteration in ray-tracing. 
	type.nit_rf = 'integer';%Maximum number of iteration in ray-tracing. 
	borne.nit_rf = [1,100];%Maximum number of iteration in ray-tracing. 
	defaut.nit_rf = 40;%Maximum number of iteration in ray-tracing. 
	info.nit_rf = 'Maximum number of iteration in ray-tracing';
%
	valeur.dke_mode = 0;%Fokker-Planck equation (0), Drift Kinetic equation (1)
	type.dke_mode = 'list';%Fokker-Planck equation (0), Drift Kinetic equation (1)
	borne.dke_mode = {0,1};%Fokker-Planck equation (0), Drift Kinetic equation (1)
	defaut.dke_mode = 0;%Fokker-Planck equation (0), Drift Kinetic equation (1)
	info.dke_mode = 'Fokker-Planck equation (0), Drift Kinetic equation (1)';
%
	valeur.dtn = 10000;%Integration time step (1/nhuth_ref) (dtn > 0: fully implicit time differencing scheme , dtn < 0: Crank-Nicholson time differencing scheme) (WARNING: dtn less than 1 when fast electron radial transport is considered)
	type.dtn = 'integer';%Integration time step (1/nhuth_ref) (dtn > 0: fully implicit time differencing scheme , dtn < 0: Crank-Nicholson time differencing scheme) (WARNING: dtn less than 1 when fast electron radial transport is considered)
	borne.dtn = [0.01,100000];%Integration time step (1/nhuth_ref) (dtn > 0: fully implicit time differencing scheme , dtn < 0: Crank-Nicholson time differencing scheme) (WARNING: dtn less than 1 when fast electron radial transport is considered)
	defaut.dtn = 10000;%Integration time step (1/nhuth_ref) (dtn > 0: fully implicit time differencing scheme , dtn < 0: Crank-Nicholson time differencing scheme) (WARNING: dtn less than 1 when fast electron radial transport is considered)
	info.dtn = 'Integration time step (1/nhuth_ref) (dtn > 0: fully implicit time differencing scheme , dtn < 0: Crank-Nicholson time differencing scheme) (WARNING: dtn less than 1 when fast electron radial transport is considered)';
%
	valeur.invproc = 1;%Iterative matrix inversion method: (1) cgs iterative method, (2) bicg iterative method, (3) qmr iterative method
	type.invproc = 'list';%Iterative matrix inversion method: (1) cgs iterative method, (2) bicg iterative method, (3) qmr iterative method
	borne.invproc = {-1,1,2,3};%Iterative matrix inversion method: (1) cgs iterative method, (2) bicg iterative method, (3) qmr iterative method
	defaut.invproc = 1;%Iterative matrix inversion method: (1) cgs iterative method, (2) bicg iterative method, (3) qmr iterative method
	info.invproc = 'Iterative matrix inversion method: (1) cgs iterative method, (2) bicg iterative method, (3) qmr iterative method';
%
% DISPLAY PARAMETERS
%
	valeur.rho_display = 0.3;%Approximate radial position at which results are displayed if type.display_mode >= 1 [1,1]. Not used if NaN
	type.rho_display = 'float';%Approximate radial position at which results are displayed if type.display_mode >= 1 [1,1]. Not used if NaN
	borne.rho_display = [0,1];%Approximate radial position at which results are displayed if borne.display_mode >= 1 [1,1]. Not used if NaN
	defaut.rho_display = 0.3;%Approximate radial position at which results are displayed if defaut.display_mode >= 1 [1,1]. Not used if NaN
	info.rho_display = 'Approximate radial position at which results are displayed if info.display_mode >= 1 [1,1]. Not used if NaN';
% 
	valeur.display_mode = 1;%Display mode: (0): no, (1): partial, (2): full
	type.display_mode = 'list';%Display mode: (0): no, (1): partial, (2): full
 	borne.display_mode = {0,1,2};%Display mode: (0): no, (1): partial, (2): full
	defaut.display_mode = 0;%Display mode: (0): no, (1): partial, (2): full
	info.display_mode = 'Display mode: (0): no, (1): partial, (2): full';
%
% MAGNETIC RIPPLE PARAMETERS
%
	valeur.ripple = 0;%Magnetic ripple (WARNING: only valid for TORE SUPRA magnetic equilibrium), no magnetic ripple if empty
	type.ripple = 'integer';%Magnetic ripple (WARNING: only valid for TORE SUPRA magnetic equilibrium), no magnetic ripple if empty
	borne.ripple = {0,1};%Magnetic ripple (WARNING: only valid for TORE SUPRA magnetic equilibrium), no magnetic ripple if empty
	defaut.ripple = 0;%Magnetic ripple (WARNING: only valid for TORE SUPRA magnetic equilibrium), no magnetic ripple if empty
	info.ripple = 'Magnetic ripple (WARNING: only valid for TORE SUPRA magnetic equilibrium), no magnetic ripple if empty';		  
%
% FAST ELECTRON RADIAL TRANSPORT PARAMETERS
%
	valeur.vparmin_r = 3.5;%Lower limit of the parallel velocity dependence of the radial diffusion and pinch (vth_ref or vth)
	type.vparmin_r = 'float';%Lower limit of the parallel velocity dependence of the radial diffusion and pinch (vth_ref or vth)
	borne.vparmin_r = [2.0,6];%Lower limit of the parallel velocity dependence of the radial diffusion and pinch (vth_ref or vth)
	defaut.vparmin_r = 3.5;%Lower limit of the parallel velocity dependence of the radial diffusion and pinch (vth_ref or vth)
	info.vparmin_r = 'Lower limit of the parallel velocity dependence of the radial diffusion and pinch (vth_ref or vth)';
%
	valeur.norm_ref = 1;%Normalization procedure for the lower limit of radial transport parallel velocity dependence: (0) from local values Te and ne, (1) from reference values Te_ref and ne_ref
	type.norm_ref = 'list';%Normalization procedure for the lower limit of radial transport parallel velocity dependence: (0) from local values Te and ne, (1) from reference values Te_ref and ne_ref
    borne.norm_ref = {0,1};%Normalization procedure for the lower limit of radial transport parallel velocity dependence: (0) from local values Te and ne, (1) from reference values Te_ref and ne_ref
	defaut.norm_ref = 1;%Normalization procedure for the lower limit of radial transport parallel velocity dependence: (0) from local values Te and ne, (1) from reference values Te_ref and ne_ref
	info.norm_ref = 'Normalization procedure for the lower limit of radial transport parallel velocity dependence: (0) from local values Te and ne, (1) from reference values Te_ref and ne_ref ';
%
	valeur.Dr0 = 0;%Core radial diffusion coefficient (m^2/s)
	type.Dr0 = 'float';%Core radial diffusion coefficient (m^2/s)
	borne.Dr0 = [0,100];%Core radial diffusion coefficient (m^2/s)
	defaut.Dr0 = 0;%Core radial diffusion coefficient (m^2/s)
	info.Dr0 = 'Core radial diffusion coefficient (m^2/s)';
% 
	valeur.pDr = 0;%Coefficient for the Dr radial profile
	type.pDr = 'float';%Coefficient for the Dr radial profile
	borne.pDr = [0,50];%Coefficient for the Dr radial profile
	defaut.pDr = 0;%Coefficient for the Dr radial profile
	info.pDr = 'Coefficient for the Dr radial profile';
%
	valeur.Vr0 = 0;%Core radial pinch coefficient (m/s)
	type.Vr0 = 'float';%Core radial pinch coefficient (m/s)
	borne.Vr0 = [0,100];%Core radial pinch coefficient (m/s)
	defaut.Vr0 = 0;%Core radial pinch coefficient (m/s)
	info.Vr0 = 'Core radial pinch coefficient (m/s)';
%		 
	valeur.pVr = 0;%Coefficient for the Vr radial profile
	type.pVr = 'float';%Coefficient for the Vr radial profile
	borne.pVr = [0,50];%Coefficient for the Vr radial profile
	defaut.pVr = 0;%Coefficient for the Vr radial profile
	info.pVr = 'Coefficient for the Vr radial profile';
%
	valeur.Dr_model = 1;%Radial diffusion type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth),
	type.Dr_model = 'list';%Radial diffusion type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth),
	borne.Dr_model = {0,1};%Radial diffusion type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth),
	defaut.Dr_model = 1;%Radial diffusion type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth),
	info.Dr_model = 'Radial diffusion type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth)';
%
	valeur.Vr_model = 0;%Radial pinch type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth),
	type.Vr_model = 'list';%Radial pinch type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth),
	borne.Vr_model = {0,1};%Radial pinch type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth),
	defaut.Vr_model = 0;%Radial pinch type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth),
	info.Vr_model = 'Radial pinch type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth)';
%
% RAY-TRACING PARAMETERS (C3PO)
%
	valeur.kmode = 0;%Dielectric tensor (0:cold,1:warm,2:hot;3:weak realtivistic,4:full relativistic)
	type.kmode = 'list';%Dielectric tensor (0:cold,1:warm,2:hot;3:weak realtivistic,4:full relativistic)
	borne.kmode = {0,1,2,3,4};%Dielectric tensor (0:cold,1:warm,2:hot;3:weak realtivistic,4:full relativistic)
	defaut.kmode = 0;%Dielectric tensor (0:cold,1:warm,2:hot;3:weak realtivistic,4:full relativistic)
	info.kmode = 'Dielectric tensor (0:cold,1:warm,2:hot;3:weak realtivistic,4:full relativistic)';
%	
	valeur.ray_tfinal = 20000;%Normalized time when ray-tracing is stopped (usually, tfinal is less than 10000)
	type.ray_tfinal = 'float';%Normalized time when ray-tracing is stopped (usually, tfinal is less than 10000)
	borne.ray_tfinal = [1000,40000];%Normalized time when ray-tracing is stopped (usually, tfinal is less than 10000)
	defaut.ray_tfinal = 20000;%Normalized time when ray-tracing is stopped (usually, tfinal is less than 10000)
	info.ray_tfinal = 'Normalized time when ray-tracing is stopped (usually, tfinal is less than 10000)';
%
%  INPUT FILE PARAMETERS
%
	valeur.make_display = 'NO_DISPLAY';%Advanced display parameters for LUKE and quasilinear selfconsistency
	type.make_display = 'list';%Advanced display parameters for LUKE and quasilinear selfconsistency
	borne.make_display = {'NO_DISPLAY','PARTIAL_VISUAL','VISUAL'};%Advanced display parameters for LUKE and quasilinear selfconsistency
	defaut.make_display = 'NO_DISPLAY';%Advanced display parameters for LUKE and quasilinear selfconsistency
	info.make_display = 'Advanced display parameters for LUKE and quasilinear selfconsistency';
%
%  RUN PARAMETERS
%
	valeur.rho_S = [0.05:0.06:0.95];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
	type.rho_S = 'float';%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
	borne.rho_S = [0,1];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
	defaut.rho_S = 0;%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
	info.rho_S = 'Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)';
%
% LH PARAMETERS
%
    valeur.conf = 'MIXTE';% configuration antennes / machine
    type.conf = 'string';% configuration antennes / machine
    borne.conf = {'TS','MIXTE','CIEL','CMOD','SST1','COMPASS','JET','FTU','ITER3.7GHz','ITER5GHz','DEMO3.7GHz','DEMO5.0GHz'};% configuration antennes / machine
    defaut.conf = 'MIXTE';% configuration antennes / machine
    info.conf = 'Configuration antennas / tokamak';
%
% OTHER PARAMETERS (NOT USED)
%  
%    valeur.effmult  = 1;% ****************facteur phenomenologique qui multiplie l'efficacite de generation de courant
%    type.effmult = 'float';% facteur phenomenologique qui multiplie l'efficacite de generation de courant
%    borne.effmult = [0,100];% facteur phenomenologique qui multiplie l'efficacite de generation de courant
%    defaut.effmult = 1;% facteur phenomenologique qui multiplie l'efficacite de generation de courant
%    info.effmult = 'multiplier of the current drive efficiency';
% %
%    valeur.alpha = 0;% si 1, calcule l'absorption sur les particules alpha
%    type.alpha = 'integer';% si 1, calcule l'absorption sur les particules alpha
%    borne.alpha = {0,1};% si 1, calcule l'absorption sur les particules alpha
%    defaut.alpha = 0;% si 1, calcule l'absorption sur les particules alpha
%    info.alpha = 'if 1, calculates absorption by alpha particles';
% %
%    valeur.save  = 0;%sauvegarde du contexte
%    type.save = 'list';%sauvegarde du contexte
%    borne.save = {0,1};%sauvegarde du contexte
%    defaut.save = 0;%sauvegarde du contexte
%    info.save = 'Temporary data saved.';
%

%
% EC PARAMETERS
%
%
% Note : parameters nd and nchi to replace nbcouronne and nbray to be implemented
%
	valeur.modpolar     = 2.*ones(1,nbfce);% mode polarisation : 1 -> X, 2 -> O [2]
	type.modpolar       = 'integer';% type de la donnnee
    borne.modpolar      = {1,2};
	defaut.modpolar     = 2;
	info.modpolar       = 'polarisation mode : 1 -> X, 2 -> O [2]';
%
	valeur.freq_ghz     = 118.*ones(1,nbfce);% frequence en  Ghz [TS = 118]
    type.freq_ghz       = 'float';% type de la donnnee
	borne.freq_ghz      = [1,1000];
	defaut.freq_ghz     = 118;
	info.freq_ghz       = 'frequency [Ghz, TS = 118]';
%
	valeur.rant         = 3.53.*ones(1,nbfce);% position en R du dernier miroir (m) [TS = 3.53]
    type.rant           = 'float';% type de la donnnee
	borne.rant          = [0,30];
	defaut.rant         = 3.53; 
	info.rant           = 'last mirror major radius (m) [TS = 3.53]';
%
	if nbfce == 3
        valeur.zant = [0,0.2,-0.2];% position en Z du dernier miroir (m) [valeurs par defaut antenne TS]
	else
        valeur.zant = zeros(1,nbfce);
	end
    type.zant           = 'float';% type de la donnnee
	borne.zant          = [-20,20];
	defaut.zant         = 0;
	info.zant           = 'last mirror altitude  (m) [0]' ;            
%
	valeur.angle_pol    = 0.*ones(1,nbfce);% angle d'injection dans le plan poloidal par rapport a l'horizontal, en degres (Ts = -20 a 20, >0 vers le haut) [0]
    type.angle_pol      = 'float';% type de la donnnee
	borne.angle_pol     = [-90,90];
	defaut.angle_pol    = 0;
	info.angle_pol      = 'poloidal injection angle [degree]  (Ts = -20 a 20, >0 vers le haut) [0]';
%
	valeur.angle_tor    = 0.*ones(1,nbfce);% angle d'injection dans le plan toroidal par rapport a la normal a Btor en degres (Ts = -30 a 30, >0 dans le sens de ip) [10]
    type.angle_tor      = 'float';% type de la donnnee
	borne.angle_tor     = [-90,90];
	defaut.angle_tor    = 10;
	info.angle_tor      = 'toroidal injection angle [degree]  (Ts = -30 a 30, >0 dans le sens de ip) [10]';
%
    valeur.angle_var    = 0 .* ones(1,nbfce);% angle des miroirs passes en consigne si =1
    type.angle_var      = 'integer';% type de la donnnee
	borne.angle_var     = {0,1};
	defaut.angle_var    = 0;
	info.angle_var      = 'if set at  1, antena mirrors angles are given as reference in input';
%	     
% CRONOS PARAMETERS
%
   interface.ts = '';                    % nom de la fonction d'interfacage avec les donnees TS
   interface.jet = '';                   % nom de la fonction d'interfacage avec les donnees Jet 
%
   sortie.valeur = valeur;
   sortie.type = type;
   sortie.borne = borne;
   sortie.defaut = defaut;
   sortie.info = info;
   sortie.interface = interface;
   sortie.description = 'Calcul du depot de puissance Hybride et/ou FCE avec LUKE';   % description (une ligne) de la fonction
   sortie.help = '';                            % nom du fichier d'aide s'il existe, sinon aide de la fonction
   sortie.gui  ='';                             % nom de l'interface graphique specifique si elle existe
   sortie.controle = '';                        % nom de la fonction de controle des valeurs si elle existe
%
   return
end
%
% --------------------------- RUN STARWARS ------------------------
%
if nargin == 14,% LH case
    par = varargin{1};
    proto = varargin{2};
    cons = varargin{3};
    cons_spec = varargin{4};
    geo = varargin{5};
    equi = varargin{6};
    injection = varargin{7};
    prof = varargin{8};
    neo = varargin{9};
    impur = varargin{10};
    phy = varargin{11};
    compo = varargin{12};
    gene = varargin{13};
    memoire = varargin{14};
    %
    if (all(abs(cons)< 2e5) | all(angle(cons)<=1)),% test sur la puissance. Calcul si P > 200 kW seulement
        sortie = proto;
        return
    end
elseif nargin == 13,% FCE case
    par = varargin{1};
    proto = varargin{2};
    cons = varargin{3};
    geo = varargin{4};
    equi = varargin{5};
    injection = varargin{6};
    prof = varargin{7};
    neo = varargin{8};
    impur = varargin{9};
    phy = varargin{10};
    compo = varargin{11};
    gene = varargin{12};
    memoire = varargin{13};
else
    error('Wrong number of inputs in zstarwars')
end
%
%
% info machine
%
from = evalin('base','param.from');
machine = from.machine;
shot    = from.shot.num;
sortie = proto;
sortie.err = 0;% on definit le flag d'erreur a 0 par defaut (pas d'erreur)
%
%--------------------------- LIEN AVEC C3PO + LUKE ------------------
%
% PARAMETRES EQUILIBRE
%
equil = make_equil_cronos(shot,equi,gene,prof,compo,impur);
%
% Determines run type
%
switch par.luke_mode
  %    
  case 'mixte'
    %
    % Mixed LH and EC waves case
    %
    [launchs_lh] = make_wavelaunchs_cronos_lh(equil,gene.signe,par.lh_param.conf,cons.lh_cons,cons_spec);%for the LH waves
    [launchs_ec] = make_wavelaunchs_cronos_ec(equil,par.ecrh_param,cons.ecrh_cons);%for the EC waves
    %    
    launchs = [launchs_lh,launchs_ec];
    par.launchtype = 'LH';
    %
  case 'lh'
    %
    % LH waves only
    %
    [launchs] = make_wavelaunchs_cronos_lh(equil,gene.signe,par.conf,cons,cons_spec);%for the LH waves
    par.launchtype = 'LH';
    %    
  case 'ecrh'
    %
    % EC waves only
    %
    [launchs] = make_wavelaunchs_cronos_ec(equil,par,cons);%for the EC waves    
    par.launchtype = 'EC';
    %
  otherwise
    %
    error('luke mode could not be determined')
    %      
end
%
% --------- Load first all parameters that are in files ------------
%
[dkeparam] = make_dkeparam_cronos(par.launchtype);
[dkedisplay] = make_display_cronos(par.make_display);
dkepath=getappdata(0,'DKEPATH');
dkepath.temppath = [dkepath.temppathroot,filesep,'CRONOS',filesep,timeid_jd(clock)];%Temporary subdirectory in scratch folder
%
% --------- Override parameters that are in files ------------
%
% PARAMETRES LUKE
%
dkeparam.rt_mode = par.rt_mode;%RT-DKE power consistency
dkeparam.abs_lim = par.abs_lim;%Relative level of RF power absorption that is accpeted for in the quasilinear convergence loop (0: no threshold, 1: full absorption)
dkeparam.nit_rf = par.nit_rf;%Maximum number of iteration in ray-tracing. Works only if rt_mode = 1 and more than one radial point (default = 1)
dkeparam.dke_mode = par.dke_mode;%Fokker-Planck equation (0), Drift Kinetic equation (1)
dkeparam.dtn = par.dtn;%Integration time step (1/nhuth_ref) (dtn > 0: fully implicit time differencing scheme , dtn < 0: Crank-Nicholson time differencing scheme) (WARNING: dtn less than 1 when fast electron radial transport is considered)
dkeparam.invproc = par.invproc;%Iterative matrix inversion method: (1) cgs iterative method, (2) bicg iterative method, (3) qmr iterative method
dkeparam.n_rf_list = 0:3;
%
% PARAMETRES DISPLAY
%
dkedisplay.rho_display  = par.rho_display;%Approximate radial position at which results are displayed if display.display_mode >= 1 [1,1]. Not used if NaN
dkedisplay.display_mode = par.display_mode;%Display mode: (0): no, (1): partial, (2): full
%dkedisplay.display_mode = 'PARTIAL_VISUAL',%%%%%%%%%%%%%%%%%%
%
% PARAMETRES OHMIC 
%
ohm.rho = gene.x;%Arbitrary normalized minor radius
ohm.epsi = prof.epar;%(V/m)
%
% PARAMETRES RIPPLE 
%
ripple.ripple = par.ripple;
%
% PARAMETRES FAST ELECTRON TRANSPORT 
%
transpfaste.vparmin = par.vparmin_r;%Lower limit of the parallel velocity dependence of the radial diffusion and pinch (vth_ref or vth)
transpfaste.norm_ref = par.norm_ref;%Normalization procedure for the lower limit of radial transport parallel velocity dependence: (0) from local values Te and ne, (1) from reference values Te_ref and ne_ref
transpfaste.Dr0 = par.Dr0;%Core radial diffusion coefficient (m^2/s)
transpfaste.pDr = par.pDr;%Coefficient for the Dr radial profile
transpfaste.Vr0 = par.Vr0;%Core radial pinch coefficient (m/s)
transpfaste.pVr = par.pVr;%Coefficient for the Vr radial profile
transpfaste.Dr_model = par.Dr_model;%Radial diffusion type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth),
transpfaste.Vr_model = par.Vr_model;%Radial pinch type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth),
%
% PARAMETRES WAVE LH + EC (C3PO) 
%

for iw = 1:length(launchs),
    [waveparam,fitequilparam,rayparam,raydisplay] = make_wavert_cronos(launchs{iw}.type);%parameter for ray-tracing are adapted to the selected wave
    %   	
    wavestructs{iw}.id = [par.conf,'_',launchs{iw}.id];
    wavestructs{iw}.equil_id = equil.id;
    wavestructs{iw}.launch = launchs{iw};
    wavestructs{iw}.waveparam = waveparam;
    wavestructs{iw}.fitequilparam = fitequilparam;
    wavestructs{iw}.rayparam = rayparam;
    wavestructs{iw}.raydisplay = raydisplay;
    %
    wavestructs{iw}.wavesolver = 'C3PO';
    wavestructs{iw}.waveparam.kmode = par.kmode;%Dielectric tensor (0:cold,1:warm,2:hot;3:weak relativistic,4:full relativistic)
    wavestructs{iw}.rayparam.tensortype = wavestructs{iw}.waveparam.kmode;%(0:cold,1:warm,2:hot;3:weak relativistic,4:full relativistic)
    wavestructs{iw}.rayparam.tfinal = par.ray_tfinal;
end
%
opt_save = 0;%For debugging or scan only.
%
%--------------------------- Execution du trace de rayon C3PO et du code cinetique LUKE --------------------------- 
%
ik = 1;
%
% gestion des signes
%
% co courant ohm.epsi < 0 et N// < 0 dans LUKE
%
signe = evalin('base','param.gene.signe');
%
% pour CRONOS N// > 0 co courant
%
if sign(angle(cons)) > 0
   ohm.epsi=-abs(ohm.epsi)*sign(signe.ip)*sign(signe.b0); 
   for k=1:length(wavestructs)
       eval(['wavestructs{',int2str(k),'}.launch.bNpar0 = abs(wavestructs{',int2str(k),'}.launch.bNpar0) * (-1);'])
   end    
else
   ohm.epsi=abs(ohm.epsi)*sign(signe.ip)*sign(signe.b0); 
   for k=1:length(wavestruct)
       eval(['wavestructs{',int2str(k),'}.launch.bNpar0 = abs(wavestructs{',int2str(k),'}.launch.bNpar0);'])
   end    
end
if sum(abs(ohm.epsi)) > 0,%Calculate the Ohmic electric field contribution to the plasma current
   [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp('cronos',[],par.rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,'',transpfaste,ripple,[],[]);
end
%
while 1,
   [Znorm_RF,Zcurr_RF,ZP0_RF,dke_out_RF,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource,dke_warnings] = run_lukert('cronos',wavestructs,[],[],par.rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,[],[],opt_save);
   if isempty(dke_warnings),
      break;
   else
      info_dke_yp(2,'The RF power is not absorbed at an acceptable level for the quasilinear solution. The ray-tracing is relaunched with extended ray lengths');
%
      for iw = 1:length(launchs),
         wavestructs{iw}.rayparam.tfinal = wavestructs{iw}.rayparam.tfinal*1.5^ik;
         wavestructs{iw}.rayparam.kmax = wavestructs{iw}.rayparam.kmax*1.5^ik;
         ik = ik + 1;
         if ik > 10;
            error('The RF power cannot absorbed at an acceptable level for the quasilinear solution even is ray lengths have been extended. Something is going wrong !!!');
         end
      end
   end
end
%
if strcmp(dkedisplay.display_mode,'PARTIAL_VISUAL') | strcmp(dkedisplay.display_mode,'VISUAL'),
   if sum(abs(ohm.epsi)) > 0,	
	  I_ohm = sum(Zcurr.x_0_fsav.*equilDKE.xdA_dke*mksa.j_ref);
	  figure('Name','Ohmic current profile'),
	  graph1D_jd(equilDKE.xrho,Zcurr.x_0_fsav*mksa.j_ref,0,0,'\rho','J_{tot} (MA/m^2)',[par.machine_nom,',I_{tot} = ',num2str(I_ohm*1000),' (kA)'],NaN,'','','-','none','r',2);drawnow
%	  print_jd(p_opt,[filename,'_Curr']);
%
	  POHM_ohm = sum(ZP0.x_e_fsav.*equilDKE.xdV_2piRp_dke*mksa.P_ref*2*pi*equilDKE.Rp);
	  figure('Name','Ohmic Power'),
	  graph1D_jd(equilDKE.xrho,ZP0_RF.x_e_fsav*mksa.P_ref,0,0,'\rho','P_{OHM} (MW/m^3)',[par.machine_nom,',P_{OHM} = ',num2str(POHM_ohm*1000),' (kW)'],NaN,'','','-','none','r',2);drawnow
%	  print_jd(p_opt,[filename,'_Ohm']);
   end		
%
	I_tot = sum(Zcurr_RF.x_0_fsav.*equilDKE.xdA_dke*mksa.j_ref);
	figure('Name','Current profile'),
	graph1D_jd(equilDKE.xrho,Zcurr_RF.x_0_fsav*mksa.j_ref,0,0,'\rho','J_{tot} (MA/m^2)',[par.machine_nom,',I_{tot} = ',num2str(I_tot*1000),' (kA)'],NaN,'','','-','none','r',2);drawnow
%	print_jd(p_opt,[filename,'_Curr']);
%
	PLH_tot = sum(ZP0_RF.x_rf_fsav.*equilDKE.xdV_2piRp_dke(:)*mksa.P_ref*2*pi*equilDKE.Rp);
	figure('Name','LH Power'),
	graph1D_jd(equilDKE.xrho,ZP0_RF.x_rf_fsav*mksa.P_ref,0,0,'\rho','P_{LH} (MW/m^3)',[par.machine_nom,',P_{LH} = ',num2str(PLH_tot*1000),' (kW)'],NaN,'','','-','none','r',2);drawnow
%	print_jd(p_opt,[filename,'_RF_Power']);
%
	POHM_tot = sum(ZP0_RF.x_e_fsav.*equilDKE.xdV_2piRp_dke*mksa.P_ref*2*pi*equilDKE.Rp);
	figure('Name','Ohmic Power'),
	graph1D_jd(equilDKE.xrho,ZP0_RF.x_e_fsav*mksa.P_ref,0,0,'\rho','P_{OHM} (MW/m^3)',[par.machine_nom,',P_{OHM} = ',num2str(POHM_tot*1000),' (kW)'],NaN,'','','-','none','r',2);drawnow
%	print_jd(p_opt,[filename,'_Ohm']);
end
%
%--------------------------- REMPLISSAGE DE LA STRUCTURE DE SORTIE POUR CRONOS --------------------------- 
%
equilDKE.xcron = interp1(abs(equi.psi-equi.psi(1))/max(abs(equi.psi-equi.psi(1))),gene.x,equilDKE.xpsin);
%
if sum(abs(ohm.epsi)) > 0,%Only the RF current + the synergistic Ohmic/RF current contribution is kept
   sortie.j = interp1(equilDKE.xcron,(Zcurr_RF.x_tot_fsav - Zcurr.x_tot_fsav)*mksa.j_ref,gene.x);
   sortie.el = interp1(equilDKE.xcron,(ZP0_RF.x_rf_fsav + ZP0_RF.x_e_fsav' - ZP0.x_e_fsav')*mksa.P_ref,gene.x);
else
   sortie.j = interp1(equilDKE.xcron,Zcurr.x_tot_fsav*mksa.j_ref,gene.x);
   sortie.el = interp1(equilDKE.xcron,(ZP0.x_rf_fsav + ZP0.x_e_fsav')*mksa.P_ref,gene.x);
end
%
if par.save,
   [chemin,void] = fileparts(gene.rapsauve);
	save(fullfile(chemin,sprintf('last_luke@%s',int2str(fix(gene.t*1000)))));
end
%



