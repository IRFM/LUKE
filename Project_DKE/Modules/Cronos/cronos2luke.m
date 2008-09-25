%  ZSTARWARS profil de depot hybride + EC calcule par C3PO + LUKE
%-------------------------------------------------------------
% fichier zstarwars.m -> fichiers source dans repertoire
% ~/Project_DKE/Modules/Cronos/
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
%
%
%
mode = [];
natfunc = [];
natrac  = [];
natpar = [];
natder  = 0;
natfce = [];

if length(varargin) == 0
  app     = dbstack;
  if length(app) > 1
    %
    % recherche du mode d'appel de zstarwars (module fce ou lh)
    %
    if strcmp(app(2).name,'zuidownloadform')
        infname = 'var';      
        natpar  = evalin('caller',infname);
        if ~isempty(strfind(natpar,'hyb'))
          natfunc = 'hyb';
        else
          natfunc = 'fce'; 
        end
    end
     if strcmp(app(2).name,'zuidata')
        infname = 'string';      
        natfunc  = evalin('caller',infname);
    end
   
    if isempty(natfunc)
     try
       natfunc = evalin('caller','fonction');
       natrac = evalin('caller','racine');
     catch
     end  
    end
  
    if isempty(natfunc)
      try
        natfunc = evalin('caller','module');
        natder  = 1;
      catch
      end  
    end
  else
    % appel direct 
     %  natfunc = evalin('base','param.fonction.hyb')
       natfunc = 'zstarwars';
       natrac  = 'hyb';
       natfce  = 'zecrhinlh';
  end
else
   app     = dbstack;
   if length(app) > 1 & strcmp(app(2).name,'zineb1test')
      natrac = evalin('caller','module'); 
      natfunc = evalin('caller',['param.fonction.',natrac]);
   end
   if length(app) > 1 & strcmp(app(2).name,'zmajmodext')
      natfunc = evalin('caller','module'); 
      natrac  = evalin('caller','fonction');
   end
   if length(app) > 1 & strcmp(app(2).name,'zmergeparam')
      natrac = evalin('caller','module'); 
      natfunc  = evalin('caller','nomf');
   end
   if length(app) > 1 & strcmp(app(2).name,'zuicreefunform')
      natrac = evalin('caller','racine');      
      if ~isempty(strfind(natrac,'hyb'))
          natrac = 'hyb';
      else
          natrac = 'fce';
      end
      natfunc  = evalin('caller','fonction');
   end
end
if length(varargin) <= 1   
  if isempty(natfce)   
      app     = dbstack;
      if length(app) > 1 & strcmp(app(2).name,'zineb1test') 
         natfce = evalin('caller','param.fonction.fce');
      else
         natfce = evalin('base','param.fonction.fce');          
      end
  end
  if strcmp(natfce,'zecrhinlh') & strcmp(natfunc ,'zstarwars')
	   disp(['zstarwars in LH+ECRH mode'])
  elseif strcmp(natfunc,'zstarwars') & strcmp(natrac,'fce')
	   disp(['zstarwars in ECRH mode'])    
  elseif strcmp(natfunc,'zstarwars') & strcmp(natrac,'hyb')
	   disp(['zstarwars in LH mode'])    
  end
  if length(varargin) == 0
        nbfce = 1;
  else
      nbfce = varargin{1};
  end
  langue = getappdata(0,'langue_cronos');
  tokamak = evalin('base','param.from.machine');
%
% merge ECRH if zstarwars in ECRH mode
%
  if ~isempty(natrac) | ~isempty(strfind(natpar,'fce'))
    if ~isempty(strfind(natrac,'fce')) | ~isempty(strfind(natpar,'fce'))
      val    = zecrhinlh(nbfce);  
      valeur = val.valeur;
      type   = val.type;
      borne  = val.borne;
      defaut = val.valeur;
      info   = val.info;
      valeur = rmfield(valeur,'nbcouronne');
      valeur = rmfield(valeur,'nbray');
      valeur = rmfield(valeur,'equi');
      type   = rmfield(type,'nbcouronne');
      type   = rmfield(type,'nbray');
      type   = rmfield(type,'equi');
      borne  = rmfield(borne,'nbcouronne');
      borne  = rmfield(borne,'nbray');
      borne  = rmfield(borne,'equi');
      defaut = rmfield(defaut,'nbcouronne');
      defaut = rmfield(defaut,'nbray');
      defaut = rmfield(defaut,'equi');
      info   = rmfield(info,'nbcouronne');
      info   = rmfield(info,'nbray');
      info   = rmfield(info,'equi');
     
    else
      if strcmp(natfce,'zecrhinlh')
        disp(['ECRH parameters should be read in the module zecrhinlh'])
      end
    end
  end
%
%--------------------------- EQUATION DE DERIVE CINETIQUE ------------------
%
  luke_parameters;
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
   sortie.mode = mode;
   sortie.interface = interface;
   sortie.description = 'LH power deposition computation with/wo ECRH using LUKE';   % description (une ligne) de la fonction
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
    %
    % cas zinebupdatetest
    %
    if ~isfield(par,'rt_mode') & strcmp(app(2).name,'zineb1test') 
        tokamak = evalin('caller','param.from.machine');
        luke_parameters;
        par = valeur;
    end
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
        plh = abs(cons.lh_cons);
        nlh = angle(cons.lh_cons);
      	if sum(plh(nlh>1)) < 2e5,% test sur la puissance. Calcul si P > 200 kW seulement
        	disp('no LH')
			nolh = 0;
        elseif any(nlh(plh>2e5) < 1)
            disp(['LH problem, parallel index < 1'])
            return
        end
        pec = abs(cons.ecrh_cons);
      	if  sum(pec) < 2e5,% test sur la puissance. Calcul si P > 200 kW seulement
        	disp('no ECRH')
			nofce = 0;
      	end
      	if nolh+nofce == 0
			disp('no LH')
        	sortie = proto;
			if ~strcmp(par.conf,'Ohmic')
				return
			end
			disp('zstarwars in ohmic mode')		
      	end
    else
        plh = abs(cons);
        nlh = angle(cons);
      	if sum(plh(nlh>1))< 2e5 ,% test sur la puissance. Calcul si P > 200 kW seulement
			sortie = proto;
			disp('no LH injected power')
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
sortie.err = 0;
% on definit le flag d'erreur a 0 par defaut (pas d'erreur)
%
%--------------------------- LIEN AVEC C3PO + LUKE ------------------
%
% PARAMETRES EQUILIBRE
%
if ~isfield(par,'eco')
  par.eco='No';
end
if strcmp(par.eco,'Yes')
  disp('memory economic mode on, nrho = 15')
  par.rho_S = '15';
end
if ~isfield(par,'rho_S')
   par.rho_S = '20';   
end
if ischar(par.rho_S)
  eval(['par.rho_S = ',par.rho_S,';']);
end

equil = make_equil_cronos(shot,equi,gene,prof,compo,impur);
if sum(equil.ptBy(:,end)-equil.ptBy(:,1)) ~= 0
    disp('equilibrium warning, By(:,theta=0) ~= By(:,theta=pi)')
    equil.ptBy(:,end) = equil.ptBy(:,1);
end
if sum(equil.ptBx(:,end)-equil.ptBx(:,1)) ~= 0
    disp('equilibrium warning, Bx(:,theta=0) ~= Bx(:,theta=pi)')
    equil.ptBx(:,end) = equil.ptBx(:,1);
end
if sum(equil.ptBPHI(:,end)-equil.ptBPHI(:,1)) ~= 0
    disp('equilibrium warning, Bphi(:,theta=0) ~= Bphi(:,theta=pi)')
    equil.ptBPHI(:,end) = equil.ptBPHI(:,1);
end
%
% Determines run type
%
if isfield(par,'lob')
  lob = par.lob;
else
  lob = 'No';
end
if isfield(par,'freqlh')
  freqlh = par.freqlh;
else
  freqlh = 3.7;
end
if ~isfield(par,'conf')
 par.conf = machine;
end 
if strcmp(par.conf,'AUG')
   par.conf = 'ASDEX';
 end
if ~isfield(par,'luke_mode')
  par.luke_mode='lh';
end
if ~isempty(strfind(par.conf,' (TS)'))
   
    par.conf = par.conf(1:(strfind(par.conf,' (TS)')-1));
    
end
switch par.luke_mode
  %    
  case 'mixte'
    %
    % Mixed LH and EC waves case
    %
    [launchs_lh] = make_wavelaunchs_cronos_lh(equil,gene.signe,par.conf,cons.lh_cons,cons_spec,lob,freqlh);%for the LH waves
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
      [launchs] = make_wavelaunchs_cronos_lh(equil,gene.signe,'MIXTE',cons,cons_spec,lob,freqlh);%for the LH waves
    else
      [launchs] = make_wavelaunchs_cronos_lh(equil,gene.signe,par.conf,cons,cons_spec,lob,freqlh);%for the LH waves
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
if strcmp(par.eco,'Yes')
  disp('memory economic mode on')
  dkeparam.nmhu_S  = 101;%Number of angular values for the flux grid (WARNING: odd number) (>100 recommended for accurate run)
  dkeparam.np_S    = 121;%Number of momentum values for the flux grid (pnmax/np < 0.1 highly recommended for accurate run) WARNING: must be adjusted so that effective momentum point number is larger than thepitch-angle one.
  dkeparam.pnmax_S = 20;%Maximum value of the flux momentum grid (pth_ref)
end
%
if ~isfield(par,'make_display');
    par.make_display='NO_DISPLAY';
end
dkedisplay       = make_display_cronos(par.make_display);
dkepath          = getappdata(0,'DKEPATH');
dkepath.temppath = [dkepath.temppathroot,filesep,'CRONOS',filesep,timeid_jd(clock)];%Temporary subdirectory in scratch folder
%
% --------- Override parameters that are in files ------------
%
% PARAMETRES LUKE
%
dkeparam.rt_mode = par.rt_mode;%RT-DKE power consistency
if par.rt_mode == 4
 
  disp('This version of LUKE only support rt_mode = 1');
  dkeparam.rt_mode = 1;

end
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
if isfield(varargin{13},'signe')
  signe = varargin{13}.signe;%Toroidal Bfield and plasma current sign (CRONOS convention: > 0 when counter-clockwise from top view)
else
  signe = varargin{12}.signe;  
end
%
% psipncronos    : coordonnee radiale normalisee de CRONOS en flux poloidal
% psipncronoshel : coordonnee radiale normalisee en flux poloidal associee a HELENA pour BR BZ et BPHI
% psitncronoshel : coordonnee radiale normalisee en flux toroidal associee a HELENA pour BR BZ et BPHI 
% psipn_jd       : coordonnee radiale normalisee en flux poloidal associee a LUKE
%
ohm.rho        = linspace(0,1,101);
psipncronos    = abs(equi.psi-equi.psi(1))/max(abs(equi.psi-equi.psi(1)));
psipncronoshel = abs(equi.psiRZ-equi.psiRZ(1))/max(abs(equi.psiRZ-equi.psiRZ(1)));
psitncronoshel = equi.rhoRZ/equi.rhomax;
psipn_ohm       = rho2psi_jd(equil,ohm.rho);
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
ripple.mode = par.ripple;
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
% cas sans transport, strucutre vide
%
if transpfaste.Dr0 == 0 & transpfaste.Vr0 == 0

  transpfaste = [];

end

%
% PARAMETRES WAVE LH + EC (C3PO) 
%
for iw = 1:length(launchs),
    [waveparam,fitequilparam,rayparam,raydisplay,C3POparam] = make_wavert_cronos(launchs{iw}.type);%parameter for ray-tracing are adapted to the selected wave
    %   	
    wavestructs{iw}.id = [par.conf,'_',launchs{iw}.id];
    wavestructs{iw}.equil_id = equil.id;
    wavestructs{iw}.launch = launchs{iw};
    wavestructs{iw}.waveparam = waveparam;
    wavestructs{iw}.fitequilparam = fitequilparam;
    wavestructs{iw}.rayparam = rayparam;
    wavestructs{iw}.raydisplay = raydisplay;
    wavestructs{iw}.C3POparam = C3POparam;
    %
    wavestructs{iw}.wavesolver = 'C3PO';
    wavestructs{iw}.waveparam.mmode = launchs{iw}.mmode;% cold mode (+1 for m; -1 for p)
    wavestructs{iw}.waveparam.kmode = par.kmode;%Dielectric tensor (0:cold,1:warm,2:hot;3:weak relativistic,4:full relativistic)
    %
    if isfield(wavestructs{iw}.launch,'a_sdNpar'),
        wavestructs{iw}.waveparam.a_sdNpar = wavestructs{iw}.launch.a_sdNpar;
        wavestructs{iw}.launch = rmfield(wavestructs{iw}.launch,'a_sdNpar');
    end
    %
    wavestructs{iw}.rayparam.tensortype = wavestructs{iw}.waveparam.kmode;%(0:cold,1:warm,2:hot;3:weak relativistic,4:full relativistic)
    wavestructs{iw}.rayparam.tfinal = par.ray_tfinal;
    %
    if strcmp(par.oneray,'Yes') & strcmp(wavestructs{iw}.launch.type,'LH'),
    	wavestructs{iw}.launch.rZ0 = mean(wavestructs{iw}.launch.rZ0);
    end
    %
end
%
if isfield(par,'save')
  opt_save = par.save;%For debugging or scan only.
else
  opt_save = 0;
end
%
% Reload waves if the script has been used at least once
%
waves   = [];
iww     = 0;
iw_list = [];
%
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
% accessibility test
%
acces_lh
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
%
clear raytracing_yp alphaphimex_jd trapz_dke_yp dmumpsmex
%
if sum(abs(ohm.epsi)) ~= 0,%Calculate the Ohmic electric field contribution to the plasma current
   [Znorm,Zcurr,ZP0,dke_out] = run_lukert('cronos',[],[],[],radialDKE.xrho_S_dke,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,[],[]);
end
%
warning on
%
signe_out = -signe.ip;
%
j_TOT_c = signe_out*Zcurr_RF.x_0_vcfsav*mksa.j_ref;
if sum(abs(ohm.epsi)) ~= 0
  j_OHM_c = signe_out*Zcurr.x_0_vcfsav*mksa.j_ref;
else
  j_OHM_c = 0*j_TOT_c;
end
j_LH_c = j_TOT_c - j_OHM_c;
%
I_TOT_c = sum(signe_out*Zcurr_RF.x_0_fsav.*equilDKE.xdA_dke*mksa.j_ref);
if sum(abs(ohm.epsi)) ~= 0
    I_OHM_c = sum(signe_out*Zcurr.x_0_fsav.*equilDKE.xdA_dke*mksa.j_ref);
else
    I_OHM_c = 0*I_TOT_c;   
end
I_LH_c = I_TOT_c - I_OHM_c;

%
p_TOT_c = (ZP0_RF.x_rf_fsav' + ZP0_RF.x_e_fsav)*mksa.P_ref;
if sum(abs(ohm.epsi)) ~= 0
  p_OHM_c = ZP0.x_e_fsav*mksa.P_ref;
else
  p_OHM_c = 0*p_TOT_c;  
end
p_LH_c = p_TOT_c - p_OHM_c;
%
P_TOT_c = sum((ZP0_RF.x_rf_fsav' + ZP0_RF.x_e_fsav).*equilDKE.xdV_2piRp_dke*mksa.P_ref*2*pi*equilDKE.Rp);
if sum(abs(ohm.epsi)) ~= 0
  P_OHM_c = sum(ZP0.x_e_fsav.*equilDKE.xdV_2piRp_dke*mksa.P_ref*2*pi*equilDKE.Rp);
else
  P_OHM_c = 0*P_TOT_c;
end
P_LH_c = P_TOT_c - P_OHM_c;

%
if strcmp(dkedisplay.display_mode,'PARTIAL_VISUAL') | strcmp(dkedisplay.display_mode,'VISUAL'),
 %
 visu_luke
 %
end
%
%--------------------------- REMPLISSAGE DE LA STRUCTURE DE SORTIE POUR CRONOS --------------------------- 
%
% calcul du flux toroidal normalise associé a la grille de LUKE 
%
if ~isfield(par,'depip')
  par.depip = 1;
end
normip = 1;
if par.depip == 0
  iboot = equi.rhomax * trapz(gene.x,neo.jboot.*equi.spr,2);
  if I_LH_c*1e6 > equi.ip

    normip = equi.ip / (I_LH_c*1e6+iboot);
  
  end
  
end

%equilDKE.xcron = interp1(sqrt(psipncronos),gene.x,equilDKE.xpsin);

equilDKE.xcron = interp1(psipncronos,gene.x,equilDKE.xpsin);

%
% preparation des variables de sortie (sortie.j, sortie.el) pour CRONOS sur la bonne grille
% et avec les bonnes unites
%
sortie.j  = interp1(equilDKE.xrhoT,j_LH_c,gene.x,'pchip',0) * 1e6 * normip;
sortie.el = interp1(equilDKE.xrhoT,p_LH_c,gene.x,'pchip',0) * 1e6;
if par.Dr_model == 2
    sortie.j=diffJ(sortie.j,equi.rhomax*gene.x,par.Dr0);  % diffusion phenomenologique du courant
end
%
% pour les valeurs en dehors de la grille LUKE (centre du plasma uniquement), nous
% reportons la derniere valeur connue
%
indj = find(gene.x<equilDKE.xrhoT(1));
if ~isempty(indj)

  sortie.j(indj)=sortie.j(indj(end)+1);
  sortie.el(indj)=sortie.el(indj(end)+1);
 
end
sortie.err = normip;
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



