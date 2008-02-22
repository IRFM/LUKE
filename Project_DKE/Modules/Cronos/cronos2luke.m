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
% fonction ecrite par Y. Peyssson, J. Decker et V. Basiuk, poste 6290 ou
% 6126
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
	valeur.invproc = -2;%Iterative matrix inversion method: (1) cgs iterative method, (2) bicg iterative method, (3) qmr iterative method
	type.invproc = 'list';%Iterative matrix inversion method: (1) cgs iterative method, (2) bicg iterative method, (3) qmr iterative method
	borne.invproc = {-30,-3,-2,-1,0,1,1,2,3};%Iterative matrix inversion method: (1) cgs iterative method, (2) bicg iterative method, (3) qmr iterative method
	defaut.invproc = 1;%Iterative matrix inversion method: (1) cgs iterative method, (2) bicg iterative method, (3) qmr iterative method
	info.invproc = 'Iterative matrix inversion method: (-30) PETSc interface (see data structure below) (-3): SUPERLUMEX sequential direct matrix inversion (LU matrix factorization done for each time a matrix inversion is called) (-2): MUMPSMEX sequential fortran 95 inversion using MUMPS LU matrix factorization (-1): MUMPS parallel (or sequential) fortran 95 direct inversion (LU matrix factorization done for each time a matrix inversion is called) (0) Matlab built-in direct inversion without any LU factorization (NOT RECOMMANDED !) (1) cgs iterative method, (2) bicg iterative method, (3) qmr iterative method';
%
	valeur.eco   = 'No';
	type.eco = 'list';
	borne.eco = {'No','Yes'};
	defaut.eco = 'No';
	info.eco = 'economic mode (to gain memory), nmhu=101, pnmax=20, np=121, nrho=15';
%
% DISPLAY PARAMETERS
%
	valeur.rho_display = 0.3;%Approximate radial position at which results are displayed if type.display_mode >= 1 [1,1]. Not used if NaN
	type.rho_display = 'float';%Approximate radial position at which results are displayed if type.display_mode >= 1 [1,1]. Not used if NaN
	borne.rho_display = [0,1];%Approximate radial position at which results are displayed if borne.display_mode >= 1 [1,1]. Not used if NaN
	defaut.rho_display = 0.3;%Approximate radial position at which results are displayed if defaut.display_mode >= 1 [1,1]. Not used if NaN
	info.rho_display = 'Approximate radial position at which results are displayed if info.display_mode >= 1 [1,1]. Not used if NaN';
% 
	valeur.display_mode = 0;%Display mode: (0): no, (1): partial, (2): full
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
	borne.Dr_model = {0,1,2};%Radial diffusion type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth),
	defaut.Dr_model = 1;%Radial diffusion type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth),
	info.Dr_model = 'Radial diffusion type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth), (2) simple';
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
	valeur.ray_tfinal = 100000;%Normalized time when ray-tracing is stopped (usually, tfinal is less than 10000)
	type.ray_tfinal = 'float';%Normalized time when ray-tracing is stopped (usually, tfinal is less than 10000)
	borne.ray_tfinal = [1000,100000];%Normalized time when ray-tracing is stopped (usually, tfinal is less than 10000)
	defaut.ray_tfinal = 100000;%Normalized time when ray-tracing is stopped (usually, tfinal is less than 10000)
	info.ray_tfinal = 'Normalized time when ray-tracing is stopped (usually, tfinal is less than 10000)';
	
	
	valeur.oneray   = 'Yes';%Normalized time when ray-tracing is stopped (usually, tfinal is less than 10000)
	type.oneray = 'list';%Normalized time when ray-tracing is stopped (usually, tfinal is less than 10000)
	borne.oneray = {'Yes','No'};%Normalized time when ray-tracing is stopped (usually, tfinal is less than 10000)
	defaut.oneray = 'Yes';%Normalized time when ray-tracing is stopped (usually, tfinal is less than 10000)
	info.oneray = 'If Yes, sends only one ray per antenna';
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
	valeur.rho_S = [0:0.05:1];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
	type.rho_S = 'float';%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
	borne.rho_S = [0,1];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
	defaut.rho_S = 0;%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
	info.rho_S = 'Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)';
%
% LH PARAMETERS
%
    valeur.conf = 'MIXTE';% configuration antennes / machine
    type.conf = 'string';% configuration antennes / machine
    borne.conf = {'TS','MIXTE','CIEL','CMOD','SST1','COMPASS','JET','FTU','ITER3.7GHz','ITER5GHz','DEMO3.7GHz','DEMO5.0GHz','ASDEX','Ohmic'};% configuration antennes / machine
    defaut.conf = 'MIXTE';% configuration antennes / machine
    info.conf = 'Configuration antennas / tokamak';
    
    valeur.lob = 'No';% configuration antennes / machine
    type.lob = 'string';% configuration antennes / machine
    borne.lob = {'Yes','No'};% configuration antennes / machine
    defaut.lob = 'No';% configuration antennes / machine
    info.lob = 'if yes, the negative lob is taken into account (n// = -6)';
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
	type.modpolar       = 'list';% type de la donnnee
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
	valeur.n_ec_max     = 2;% frequence en  Ghz [TS = 118]
	type.n_ec_max       = 'integer';% type de la donnnee
	borne.n_ec_max      = [0,10];
	defaut.n_ec_max     = 2;
	info.n_ec_max       = 'Maximum harmonic number';
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
    if isstruct(cons)
      	nolh  = 1;
      	nofce = 1;
      	if (all(abs(cons.lh_cons)< 2e5) | all(angle(cons.lh_cons)<=1)),% test sur la puissance. Calcul si P > 200 kW seulement
        	disp('no LH')
			nolh = 0;
      	end
      	if (all(abs(cons.ecrh_cons)< 2e5)),% test sur la puissance. Calcul si P > 200 kW seulement
        	disp('no ECRH')
			nofce = 0;
      	end
      	if nolh+nofce == 0
			disp('no LH/ECRH injected power')
        	sortie = proto;
			if ~strcmp(par.conf,'Ohmic')
				return
			end
			disp('zstarwars in ohmic mode')		
      	end
    else
      	if (all(abs(cons)< 2e5) | all(angle(cons)<=1)),% test sur la puissance. Calcul si P > 200 kW seulement
			sortie = proto;
			disp('no LH/ECRH injected power')
			if ~strcmp(par.conf,'Ohmic')
				return
			end
			disp('zstarwars in ohmic mode')		
       	end
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
%from = evalin('base','param.from');
if isfield(varargin{1},'machine_nom')
  machine = varargin{1}.machine_nom;
else
  machine = varargin{1}.conf;
end
shot    = 0;
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
if isfield(par,'lob')
  lob = par.lob;
else
  lob = 'No';
end
switch par.luke_mode
  %    
  case 'mixte'
    %
    % Mixed LH and EC waves case
    %
    [launchs_lh] = make_wavelaunchs_cronos_lh(equil,gene.signe,par.conf,cons.lh_cons,cons_spec,lob);%for the LH waves
    [launchs_ec] = make_wavelaunchs_cronos_ec(equil,par.ecrh_param,cons.ecrh_cons);%for the EC waves
    %    
    launchs = [launchs_lh,launchs_ec];
    par.launchtype = 'LH';
    %
  case 'lh'
    %
    % LH waves only
    %
    if isstruct(cons)

      disp('mode lh alone forced')
      cons = cons.lh_cons;

    end
    %
    if strcmp(par.conf,'Ohmic')
      [launchs] = make_wavelaunchs_cronos_lh(equil,gene.signe,'MIXTE',cons,cons_spec,lob);%for the LH waves
    else
      [launchs] = make_wavelaunchs_cronos_lh(equil,gene.signe,par.conf,cons,cons_spec,lob);%for the LH waves
    end
    par.launchtype = 'LH';
    %    
  case 'ecrh'
    %
    % EC waves only
    %
    if isstruct(cons)
      cons = cons.ecrh_cons;
    end
    [launchs] = make_wavelaunchs_cronos_ec(equil,par,cons);%for the EC waves    
    par.launchtype = 'EC';
    %
  otherwise
    %
    error('luke mode could not be determined')
    %      
end
%
mask = [];
for iw = 1:length(launchs),
    if strcmp(launchs{iw}.type,'LH') & sum(launchs{iw}.bPlhtot) > 0,
        mask = [mask,iw];
    elseif strcmp(launchs{iw}.type,'EC') & launchs{iw}.yP_L > 0,
        mask = [mask,iw];
    end
end
launchs = launchs(mask);        
%
% --------- Load first all parameters that are in files ------------
%
dkeparam         = make_dkeparam_cronos(par.launchtype);
%
if ~isfield(par,'eco')
  par.eco='No';
end
if strcmp(par.eco,'Yes')
  disp('memory economic mode on')
  dkeparam.nmhu_S  = 101;%Number of angular values for the flux grid (WARNING: odd number) (>100 recommended for accurate run)
  dkeparam.np_S    = 121;%Number of momentum values for the flux grid (pnmax/np < 0.1 highly recommended for accurate run) WARNING: must be adjusted so that effective momentum point number is larger than thepitch-angle one.
  dkeparam.pnmax_S = 20;%Maximum value of the flux momentum grid (pth_ref)
  par.rho_S = linspace(0,1,15);
end
%
dkedisplay       = make_display_cronos(par.make_display);
dkepath          = getappdata(0,'DKEPATH');
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
dkeparam.n_rf_list = [0:par.n_ec_max];
%
% PARAMETRES DISPLAY
%
dkedisplay.rho_display  = par.rho_display;%Approximate radial position at which results are displayed if display.display_mode >= 1 [1,1]. Not used if NaN
dkedisplay.display_mode = par.display_mode;%Display mode: (0): no, (1): partial, (2): full
%
% PARAMETRES OHMIC, transformation en flux poloidal puis en coordonnees radials de LUKE
%
signe = varargin{13}.signe;%Toroidal Bfield and plasma current sign (CRONOS convention: > 0 when counter-clockwise from top view)
%
% psipncronos    : coordonnee radiale normalisee de CRONOS en flux poloidal
% psipncronoshel : coordonnee radiale normalisee en flux poloidal associee a HELENA pour BR BZ et BPHI
% psitncronoshel : coordonnee radiale normalisee en flux toroidal associee a HELENA pour BR BZ et BPHI 
% psipn_jd       : coordonnee radiale normalisee en flux poloidal associee a LUKE
%
ohm.rho        = par.rho_S;
psipncronos    = abs(equi.psi-equi.psi(1))/max(abs(equi.psi-equi.psi(1)));
psipncronoshel = abs(equi.psiRZ-equi.psiRZ(1))/max(abs(equi.psiRZ-equi.psiRZ(1)));
psitncronoshel = equi.rhoRZ/equi.rhomax;
psipn_ohm       = rho2psi_jd(equil,par.rho_S);
%---------------------------------------------------------
% calcul du champ // pour LUKE (avec gestion des signes)
% passage de prof.epar de la grille en x sur la grille HELENA
% puis passage sur la grille LUKE en faisant correspondre rhohel et psihel
% puis multiplication par le facteur geometrique (pour s'assurer que l'integrale redonne le courant)
% ohm.epsi : V/m
% Here Efield sign is always co-current by definition, in order to retrieve both amplitude and sign of Ip without any RF wave
%----------------------------------------------------------
ohm.epsi     = -sign(signe.ip)*sign(signe.b0)*abs(interp1(gene.x,prof.epar,psitncronoshel));
ohm.epsi     = complex(interp1(psipncronoshel,ohm.epsi,psipn_ohm));%Imaginary for considering the definition of the flux surface averaging of CRONOS in LUKE
%
% PARAMETRES RIPPLE 
%
ripple.ripple = par.ripple;
%
% PARAMETRES FAST ELECTRON TRANSPORT 
%
transpfaste.vparmin  = par.vparmin_r;%Lower limit of the parallel velocity dependence of the radial diffusion and pinch (vth_ref or vth)
transpfaste.norm_ref = par.norm_ref;%Normalization procedure for the lower limit of radial transport parallel velocity dependence: (0) from local values Te and ne, (1) from reference values Te_ref and ne_ref
if par.Dr_model == 2
    transpfaste.Dr0 = 0;
else
    transpfaste.Dr0      = par.Dr0;%Core radial diffusion coefficient (m^2/s)
end
transpfaste.pDr      = par.pDr;%Coefficient for the Dr radial profile
transpfaste.Vr0      = par.Vr0;%Core radial pinch coefficient (m/s)
transpfaste.pVr      = par.pVr;%Coefficient for the Vr radial profile
if par.Dr_model == 2
    transpfaste.Dr_model = 0;%Radial diffusion type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth),
else
	transpfaste.Dr_model = par.Dr_model;%Radial diffusion type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth),
end
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
    wavestructs{iw}.waveparam.mmode = launchs{iw}.mmode;% cold mode (+1 for m; -1 for p)
    wavestructs{iw}.waveparam.kmode = par.kmode;%Dielectric tensor (0:cold,1:warm,2:hot;3:weak relativistic,4:full relativistic)
    wavestructs{iw}.rayparam.tensortype = wavestructs{iw}.waveparam.kmode;%(0:cold,1:warm,2:hot;3:weak relativistic,4:full relativistic)
    wavestructs{iw}.rayparam.tfinal = par.ray_tfinal;
    %
    if strcmp(par.oneray,'Yes') & strcmp(wavestructs{iw}.launch.type,'LH'),
    	wavestructs{iw}.launch.rZ0 = mean(wavestructs{iw}.launch.rZ0);
    end
    %
end
%
opt_save = 1;%For debugging or scan only.
%
% Reload waves if the script has been used at least once
%
waves = [];
iww = 0;
iw_list = [];
%
opt_save=0
if opt_save == 1,
    for iw = 1:length(wavestructs),
        wavestr = ['WAVE/C3PO/WAVE_',equil.id,'_',wavestructs{iw}.id,'.mat'];
        if exist(wavestr),
            load(wavestr);
            iww = iww+1;
            waves{iww} = wave;
            iw_list = [iw_list,iw];
        end
    end	
    wavestructs(iw_list) = [];
end
%
%--------------------------- Execution du trace de rayon C3PO et du code cinetique LUKE --------------------------- 
%
ik = 1;
warning off
%
if sum(abs(ohm.epsi)) ~= 0,%Calculate the Ohmic electric field contribution to the plasma current
   [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource,dke_warnings] = main_dke_yp('cronos',[],par.rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,'',transpfaste,ripple,[],[]);
end
%
%while 1,
   [Znorm_RF,Zcurr_RF,ZP0_RF,dke_out_RF,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource,dke_warnings] = run_lukert('cronos',wavestructs,waves,[],par.rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,[],[],opt_save);
%   if isempty(dke_warnings),
%      break;
%   else
%      info_dke_yp(2,'The RF power is not absorbed at an acceptable level for the quasilinear solution. The ray-tracing is relaunched with extended ray lengths');
%
%      for iw = 1:length(launchs),
%         wavestructs{iw}.rayparam.tfinal = wavestructs{iw}.rayparam.tfinal*1.5^ik;
%         wavestructs{iw}.rayparam.kmax = wavestructs{iw}.rayparam.kmax*1.5^ik;
%         ik = ik + 1;
%         if ik > 10;
%            error('The RF power cannot absorbed at an acceptable level for the quasilinear solution even is ray lengths have been extended. Something is going wrong !!!');
%         end
%      end
%   end
%end
clear raytracing_yp alphaphimex_jd trapz_dke_yp dmumpsmex
warning on
%
signe_out = -signe.ip;
%
j_OHM_c = signe_out*Zcurr.x_0_vfsav*mksa.j_ref;
j_TOT_c = signe_out*Zcurr_RF.x_0_vfsav*mksa.j_ref;
j_LH_c = j_TOT_c - j_OHM_c;
%
I_OHM_c = sum(signe_out*Zcurr.x_0_fsav.*equilDKE.xdA_dke*mksa.j_ref);
I_TOT_c = sum(signe_out*Zcurr_RF.x_0_fsav.*equilDKE.xdA_dke*mksa.j_ref);
I_LH_c = I_TOT_c - I_OHM_c;
%
p_OHM_c = ZP0.x_e_fsav*mksa.P_ref;
p_TOT_c = (ZP0_RF.x_rf_fsav' + ZP0_RF.x_e_fsav)*mksa.P_ref;
p_LH_c = p_TOT_c - p_OHM_c;
%
P_OHM_c = sum(ZP0.x_e_fsav.*equilDKE.xdV_2piRp_dke*mksa.P_ref*2*pi*equilDKE.Rp);
P_TOT_c = sum((ZP0_RF.x_rf_fsav' + ZP0_RF.x_e_fsav).*equilDKE.xdV_2piRp_dke*mksa.P_ref*2*pi*equilDKE.Rp);
P_LH_c = P_TOT_c - P_OHM_c;
%
if strcmp(dkedisplay.display_mode,'PARTIAL_VISUAL') | strcmp(dkedisplay.display_mode,'VISUAL'),
   if sum(abs(real(ohm.epsi))) > 0 | sum(abs(imag(ohm.epsi))) > 0,		  
	  figure('Name','Ohmic current profile'),
	  graph1D_jd(equilDKE.xrho,j_OHM_c,0,0,'\rho','J_{tot} (MA/m^2)',[par.machine_nom,',I_{tot} = ',num2str(I_OHM_c*1000),' (kA)'],NaN,'','','-','none','b',2);hold off,drawnow
%
	  
	  figure('Name','Ohmic Power'),
	  graph1D_jd(equilDKE.xrho,p_OHM_c,0,0,'\rho','P_{OHM} (MW/m^3)',[par.machine_nom,',P_{OHM} = ',num2str(P_OHM_c*1000),' (kW)'],NaN,'','','-','none','r',2);drawnow
   end		
%
	figure('Name','LH Current profile (consistent with E-field)'),
	graph1D_jd(equilDKE.xrho,j_LH_c,0,0,'\rho','J_{LH} (MA/m^2)',[par.machine_nom,',I_{LH} = ',num2str(I_LH_c*1000),' (kA)'],NaN,'','','-','none','b',2);hold off,drawnow
%
	figure('Name','LH Power'),
	graph1D_jd(equilDKE.xrho,p_LH_c,0,0,'\rho','P_{LH} (MW/m^3)',[par.machine_nom,',P_{LH} = ',num2str(P_LH_c*1000),' (kW)'],NaN,'','','-','none','r',2);drawnow
%
end
%
%--------------------------- REMPLISSAGE DE LA STRUCTURE DE SORTIE POUR CRONOS --------------------------- 
%
% calcul du flux toroidal normalise associé a la grille de LUKE 
%
equilDKE.xcron = interp1(psipncronos,gene.x,equilDKE.xpsin);
%
% preparation des variables de sortie (sortie.j, sortie.el) pour CRONOS sur la bonne grille
% et avec les bonnes unites
%
sortie.j  = interp1(equilDKE.xcron,j_LH_c,gene.x,'pchip','extrap') * 1e6;
sortie.el = interp1(equilDKE.xcron,p_LH_c,gene.x,'pchip','extrap') * 1e6;
if par.Dr_model == 2
    sortie.j=diffJ(sortie.j,equi.rhomax*gene.x,par.D);  % diffusion phenomenologique du courant
end

%
% blindage : 0 au bord, au centre on recopie la premiere valeur non nulle
%
%  indnan = find(isnan(sortie.j));
%  indmax = max(indnan(gene.x(indnan) < 0.5))+1;
%  sortie.j(indnan(gene.x(indnan) > 0.5))=0;
%  sortie.j(indnan(gene.x(indnan) < 0.5))=sortie.j(indmax);

%
%  sortie.el(indnan(gene.x(indnan) > 0.5))=0;
%  sortie.el(indnan(gene.x(indnan) < 0.5))=sortie.el(indmax);
%  sortie.el(sortie.el<0)=0;
%
% renormalisation du courant (VB, 4 février 2008, pour avoir la meme intégrale dans CRONOS et LUKE)
%
%  x       = gene.x;
%  spr     = equi.spr;
%  rhomax  = equi.rhomax;
%  Icrotot = trapz(x,sortie.j.*spr)*rhomax;
%  rap     = Icrotot ./ I_LH_c / 1e6
%  sortie.j = sortie.j / rap;
%
% renormalisation de la puissance
%
%  vpr     = equi.vpr;
%  Pcrotot = trapz(x,sortie.el.*vpr)*rhomax;
%  rap     = Pcrotot ./ P_LH_c
%  sortie.el = sortie.el / rap * 1e6;
%
% distribution function for use in CRONOS
%
memoire.data.edistribution.f0 = dke_out_RF.XXf0;
memoire.data.edistribution.p = momentumDKE.pn*mksa.betath_ref;
memoire.data.edistribution.mhu0 = momentumDKE.mhu;
memoire.data.edistribution.psin = equilDKE.xpsin;
%
%if par.save,
%   [chemin,void] = fileparts(gene.rapsauve);
%   save(fullfile(chemin,sprintf('last_luke@%s',int2str(fix(gene.t*1000)))));
%end
%



