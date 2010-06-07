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
function [sortie,memoire] = zstarwars(varargin)
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
     if isempty(natfunc)
       try
         natfunc = evalin('caller','param.fonction');
         natrac = evalin('caller','racine');
       catch
       end 
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
  app = dbstack;      
  if length(app) > 1 & strcmp(app(2).name,'zineb1test') 
         nathyb  = app(1).file;
         nblh = evalin('caller','param.gene.nbhyb');
  else 
         nblh  = evalin('base','param.gene.nbhyb');
  end
  tokamak = evalin('base','param.from.machine');
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
if nargin == 13,% LH case
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
    %
    % cas zinebupdatetest
    %
    if ~isfield(par,'rt_mode') & strcmp(app(2).name,'zineb1test') 
        tokamak = evalin('caller','param.from.machine');
        luke_parameters;
        par = valeur;
    end  
    if ~isfield(par,'zinterpolation')
        par.zinterpolation = [];
    end
    %
    if ~isfield(par,'luke_mode')
        par.luke_mode='lh';
    end
    %
    if ~isstruct(cons)% LH only (a verifier)
        if strcmp(par.luke_mode,'lh'),
            cons.lh_cons = cons;
            cons.ecrh_cons = '';
        elseif strcmp(par.luke_mode,'ecrh'),
            cons.ecrh_cons = cons;
            cons.lh_cons = '';
        else
            error('LUKE mode not determined')
        end
    end
else
    error('Wrong number of inputs in zstarwars')
end
%
% info machine
%
tokamak = evalin('base','param.from.machine');
shotnum = num2str(round(evalin('base','param.from.shot.num')));
if isfield(par,'temps'),
    gene.t = par.temps;
end    
shotime = num2str(gene.t,'%6.4f');
%
equil_id = [tokamak,'_',shotnum,'_',shotime];
%
sortie.err = 0;
sortie = proto;
%
% on definit le flag d'erreur a 0 par defaut (pas d'erreur)
%
%--------------------------- LIEN AVEC C3PO + LUKE ------------------
%
% PARAMETRES LUKE
%
dkeparam = make_dkeparam_cronos(par);
%
% TMP PATH LUKE
%
dkepath = getappdata(0,'DKEPATH');
dkepath.temppath = [dkepath.temppathroot,filesep,'CRONOS',filesep,timeid_jd(clock)];%Temporary subdirectory in scratch folder
%
% PARAMETRES DISPLAY
%
dkedisplay = make_display_cronos;
dkedisplay.rho_display  = par.rho_display;%Approximate radial position at which results are displayed if display.display_mode >= 1 [1,1]. Not used if NaN
dkedisplay.display_mode = par.display_mode;%Display mode: (0): no, (1): partial, (2): full
%
% PARAMETRES EQUILIBRE
%
equil = make_equil_cronos(equil_id,equi,gene,prof,compo,impur);
%
% PARAMETRES OHMIC, transformation en flux poloidal puis en coordonnees radials de LUKE
%
signe = varargin{12}.signe;%Toroidal Bfield and plasma current sign (CRONOS convention: > 0 when counter-clockwise from top view)
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
%
% prof.epar (V/m): signe par rapport à IP
% ohm.epsi (V/m): signe par rapport à BT
% - signe is electron charge
%----------------------------------------------------------
ohm.epsi     = -sign(signe.ip)*sign(signe.b0)*interp1(gene.x,prof.epar,psitncronoshel);
ohm.epsi     = complex(interp1(psipncronoshel,ohm.epsi,psipn_ohm));%Imaginary for considering the definition of the flux surface averaging of CRONOS in LUKE
%
% PARAMETRES RIPPLE 
%
ripple.mode = par.ripple;
%
% PARAMETRES FAST ELECTRON TRANSPORT 
%
if par.Dr0 == 0 && par.Vr0 == 0
    %
    % cas sans transport, structure vide
    %
    transpfaste = '';
else
    transpfaste.vparmin  = par.vparmin_r;%Lower limit of the parallel velocity dependence of the radial diffusion and pinch (vth_ref or vth)
    transpfaste.norm_ref = par.norm_ref;%Normalization procedure for the lower limit of radial transport parallel velocity dependence: (0) from local values Te and ne, (1) from reference values Te_ref and ne_ref
    transpfaste.Dr0      = par.Dr0;%Core radial diffusion coefficient (m^2/s)
    transpfaste.pDr      = par.pDr;%Coefficient for the Dr radial profile
    transpfaste.Vr0      = par.Vr0;%Core radial pinch coefficient (m/s)
    transpfaste.pVr      = par.pVr;%Coefficient for the Vr radial profile
    transpfaste.Dr_model = par.Dr_model;%Radial diffusion type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth),
    transpfaste.Vr_model = par.Vr_model;%Radial pinch type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth),
end
%
% PARAMETRES WAVE LH + EC (C3PO) 
%
if ~isfield(par,'conf')
 par.conf = tokamak;
end 
%
[launchs_lh] = make_wavelaunchs_cronos_lh(equil,gene,par,cons.lh_cons);%for the LH waves
[launchs_ec] = make_wavelaunchs_cronos_ec(equil,par,cons.ecrh_cons);%for the EC waves
%    
launchs = [launchs_lh,launchs_ec];
%
mask = [];
prf = 0;
for iw = 1:length(launchs),
    %
    if strcmp(launchs{iw}.type,'LH')
        wprf = sum(launchs{iw}.bPlhtot);
    elseif strcmp(launchs{iw}.type,'EC')
        wprf = sum(launchs{iw}.yP_L);
    end
    %
    if ~isfield(par,'prfmin') || wprf > par.prfmin,
        mask = [mask,iw];
        prf = prf + wprf;
    end
end
launchs = launchs(mask);  
nw = length(launchs);
%
wavestructs = cell(1,length(launchs));
%
dkeparam.w_mask = [];% waves to be accounted for in radial grid optimization: EC only or LH if no EC present
%
for iw = 1:nw,
    wavestructs{iw} = make_wavert_cronos(launchs{iw},par);%parameter for ray-tracing are adapted to the selected wave
    %
    wavestructs{iw}.equil_id = equil.id;
    %
    if strcmp(launchs{iw}.type,'EC')
        %
        dkeparam.w_mask = [dkeparam.w_mask,iw];
        disp(['wave :',int2str(iw),' type :',launchs{iw}.type])
        %
    else
        disp(['wave :',int2str(iw),' type :',launchs{iw}.type,' n// = ',num2str(wavestructs{iw}.launch.bNpar0,4)])
    end
    %
end
if isempty(dkeparam.w_mask)
    dkeparam.w_mask = 1:length(launchs);
end
%
% accessibility test
%
acces_lh
%
if par.save == 2,%save before LUKE
   %
   workdir = fileparts(evalin('base','param.gene.file'));
   save([workdir,'/before_luke@',equil_id,'.mat']);
   %
   error('Exiting after saving LUKE parameters')
end
%
%--------------------------- Execution du trace de rayon C3PO et du code cinetique LUKE --------------------------- 
%
ik = 1;
warning off
disp(['LUKE is running ....'])
%
[Znorm_RF,Zcurr_RF,ZP0_RF,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource,dke_warnings] = run_lukert('cronos',wavestructs,[],[],dkeparam.rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,[],[]);
%
clear raytracing_yp alphaphimex_jd trapz_dke_yp dmumpsmex
%
signe_out = -signe.ip;
%
j_TOT_c = signe_out*Zcurr_RF.x_0_vcfsav*mksa.j_ref;
I_TOT_c = sum(signe_out*Zcurr_RF.x_0_fsav.*equilDKE.xdA_dke*mksa.j_ref);
p_TOT_c = (ZP0_RF.x_rf_fsav.' + ZP0_RF.x_e_fsav)*mksa.P_ref;
p_RF_c = ZP0_RF.x_rf_fsav.'*mksa.P_ref;
P_TOT_c = sum(p_RF_c.*equilDKE.xdV_2piRp_dke*2*pi*equilDKE.Rp);
P_RF_c = sum(p_RF_c.*equilDKE.xdV_2piRp_dke*2*pi*equilDKE.Rp);
%
if sum(abs(ohm.epsi)) ~= 0,%Calculate the Ohmic electric field contribution to the plasma current
    %
    [Znorm,Zcurr,ZP0] = run_lukert('cronos',[],[],[],radialDKE.xrho_S_dke,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,[],[]);
    %
    j_OHM_c = signe_out*Zcurr.x_0_vcfsav*mksa.j_ref;
    I_OHM_c = sum(signe_out*Zcurr.x_0_fsav.*equilDKE.xdA_dke*mksa.j_ref);
    p_OHM_c = ZP0.x_e_fsav*mksa.P_ref;
    P_OHM_c = sum(p_OHM_c.*equilDKE.xdV_2piRp_dke*2*pi*equilDKE.Rp);
else
    j_OHM_c = 0;
    I_OHM_c = 0;
    p_OHM_c = 0;  
    P_OHM_c = 0;
end
%
warning on
%
j_RF_c = j_TOT_c - j_OHM_c;
I_RF_c = I_TOT_c - I_OHM_c;
p_OHMsyn_c = p_TOT_c - p_OHM_c - p_RF_c;% synergistic power spent on electric field, already accounted for in cronos E.J
P_OHMsyn_c = P_TOT_c - P_OHM_c - P_RF_c;% synergistic power spent on electric field, already accounted for in cronos E.J
%
if strcmp(dkedisplay.display_mode,'PARTIAL_VISUAL') || strcmp(dkedisplay.display_mode,'VISUAL'),
    %
    visu_luke
    %
end
%
if isfield(par,'ipfrac'),
    %
    I_boot = equi.rhomax*trapz(gene.x,neo.jboot.*equi.spr,2);
    %
    if (I_RF_c*1e6+I_boot)/equi.ip > par.ipfrac,
        %
        normip = par.ipfrac*equi.ip/(I_RF_c*1e6+I_boot);
        disp(['----> to avoid I_L_H + I_b_o_o_t > Ip'])
        disp(['normalisation =',num2str(normip,3)])
        %
    else
        %
        normip = 1;
        %
    end
end
%
%--------------------------- REMPLISSAGE DE LA STRUCTURE DE SORTIE POUR CRONOS --------------------------- 
%
%
% preparation des variables de sortie (sortie.j, sortie.el) pour CRONOS sur la bonne grille
% et avec les bonnes unites
%
method = 'linear';
%
xrhoT = [0,equilDKE.xrhoT,1];
j_RF_c = [j_RF_c(1),j_RF_c,0];
p_RF_c = [p_RF_c(1),p_RF_c,0];
%
sortie.j  = interp1(xrhoT,j_RF_c,gene.x,method)*1e6*normip;% (A/m2)
sortie.el = interp1(xrhoT,p_RF_c,gene.x,method)*1e6;% (W/m3)
%
% SMOOTHING
%
if isfield(par,'smooth') && strcmp(par.smooth,'Yes')
    newj  = smooth_dke_yp(sortie.j.',par.width_smooth,par.method_smooth).';  % diffusion phenomenologique du courant
    norm1 = trapz(gene.x,sortie.j.*equi.spr);
    norm2 = trapz(gene.x,newj.*equi.spr);
    sortie.j = newj/norm2*norm1;
    newel  = smooth_dke_yp(sortie.el.',par.width_smooth,par.method_smooth).';  % diffusion phenomenologique du courant
    norm1 = trapz(gene.x,sortie.el.*equi.vpr);
    norm2 = trapz(gene.x,newel.*equi.vpr);
    sortie.el = newel/norm2*norm1;
end
%
sortie.err = normip;
%
if any(p_RF_c < 0),
    %
    sortie.err = sortie.err + 1i;
    %
    disp('Problem in LUKE, negative absorbed power, use the last value if possible')
    %
    if isfield(memoire.data,'output')
        %
        sortie.j   = memoire.data.output.j*prf/memoire.data.output.prf*memoire.data.output.ne/prof.ne;
        sortie.el  = memoire.data.output.el*prf/memoire.data.output.prf;
        %
    end
end    
%
irf = zintsurf(sortie.j,gene.x,equi.spr,equi.rhomax);
paddrf = zintvol(sortie.el,gene.x,equi.vpr,equi.rhomax);
%
disp(['I_L_H = ',num2str(irf/1e3,3),' kA / I_p =',num2str(equi.ip/1e3,4),' kA'])
disp(['P_L_H = ',num2str(paddrf/1e3,3),' kW / P_r_e_f = ',num2str(prf/1e3,3),' kW'])
%
memoire.data.output.j     = sortie.j;
memoire.data.output.el    = sortie.el;
memoire.data.output.paddrf  = paddrf;
memoire.data.output.prf  = prf;
memoire.data.output.ne    = prof.ne;
memoire.data.output.irf  = irf;
if length(memoire.t) == 1
    memoire.t = gene.t;
else
    memoire.t = [memoire.t gene.t];
end
%
na = length(memoire.t);
%
for iw = 1:nw,
    if isfield(wavestructs{iw}.launch,'aloha'), 
        memoire.data.output.npar{iw}(na,:) = wavestructs{iw}.launch.bNpar0;
        memoire.data.output.pow{iw}(na,:)  = wavestructs{iw}.launch.bPlhtot;
        memoire.data.output.fr{iw}(na,:)   = wavestructs{iw}.launch.bPlhtot/sum(wavestructs{iw}.launch.bPlhtot)*100;
    end
end
%
memoire.data.edistribution.f0 = dke_out.XXf0;
memoire.data.edistribution.pn = momentumDKE.pn;
memoire.data.edistribution.mhu = momentumDKE.mhu;
memoire.data.edistribution.psin = equilDKE.xpsin;
memoire.data.edistribution.betath_ref = mksa.betath_ref;
memoire.data.edistribution.ne_ref = mksa.ne_ref;
%
if par.save == 1,
   workdir = fileparts(evalin('base','param.gene.file'));
   save([workdir,'/last_luke@',equil_id,'.mat']);
end
%



