function [sortie,memoire] = cronos2luke(par,equi,neo,gene,prof,compo,impur,proto,memoire)
%
%  Non-thermal distribution and associated current (LH, EC, runaways, ...) calculated  by the codes C3PO/LUKE for CRONOS
%
% INPUTS :
%
%   - par     : parametres C3PO/LUKE 
%   - equi    : donnees de l'equilibre plasma (data.equi)
%   - neo     : donnees neoclassiques (data.neo)
%   - gene    : parametres generaux (param.gene)
%   - prof    : profils des donnees calculees par le code (data.prof) 
%   - compo   : composition du plasma: charge et masse des atomes (param.compo)
%   - impur   : sous strcuture des impurtes (data.impur)
%   - proto   : prototype de la structure pour les sources, valeurs a zeros (proto : zsourceproto;)
%   - memoire : structure des dernieres valeurs calculees
% 
% OUTPUTS :
% 
%     sortie  : structure de type source remplie par le module (sortie = proto)
%     memoire : datak.memoire.hyb (valeur de reference pour le dernier calcul complet, ne pas utiliser dans cette fonction, reserve pour d'autres modules)
%
% by J. Decker, Y. Peysson, J.-F. Artaud and V. Basiuk
%
sortie     = proto;% output initialization
sortie.err = 0;% flag d'erreur a 0 par defaut (pas d'erreur)
%
%--------------------------- LIEN AVEC C3PO + LUKE ------------------
%
% tokamak name
%
if ~isfield(par,'tok')
    tokamak = 'unknown';
else
    tokamak = par.tok;
end
%
% shot number
%
if ~isfield(par,'shot')
    shotnum = '0';
else
    shotnum = num2str(par.shot); 
end
%
% shot time
%
if isempty(memoire.data),
    shotime = par.temps_cons.tempsini;% the distribution is evolved between -infinity and the initial time
else
    shotime = par.temps_cons.tempsend;% the distribution is evolved between the initial and the final time
end
%
shotimestr = num2str(shotime,'%6.4f');
%
% equil ID
%
equil_id = [tokamak,'_',shotnum,'_',shotimestr];
%
% PARAMETRES LUKE
%
dkeparam = make_dkeparam_cronos(par);
%
% PATH LUKE
%
dkepath = load_structures_yp('dkepath','','');
%
% PARAMETRES DISPLAY
%
dkedisplay = make_display_cronos;
dkedisplay.rho_display  = par.rho_display;%Approximate radial position at which results are displayed if display.display_mode >= 1 [1,1]. Not used if NaN
dkedisplay.display_mode = par.display_mode;%Display mode: (0): no, (1): partial, (2): full
%
% PARAMETRES EQUILIBRE
%
if equi.psiRZ(1) == equi.psiRZ(2)
   disp('non monotonic psiRZ');
   psiRZ = interp1(gene.x*equi.rhomax,equi.psi,double(equi.rhoRZ),'pchip','extrap');
   equi.psiRZ = double(psiRZ);
else
   psiRZ = double(equi.psiRZ); 
end
%
equil = make_equil_cronos(equil_id,equi,gene,prof,compo,impur);
%
% PARAMETRES OHMIC, transformation en flux poloidal puis en coordonnees radials de LUKE
%
% psipncronos    : coordonnee radiale normalisee de CRONOS en flux poloidal
% psipncronoshel : coordonnee radiale normalisee en flux poloidal associee a HELENA pour BR BZ et BPHI
% psitncronoshel : coordonnee radiale normalisee en flux toroidal associee a HELENA pour BR BZ et BPHI 
% psipn_jd       : coordonnee radiale normalisee en flux poloidal associee a LUKE
%
nrho_ohm       = 101;
ohm.rho        = linspace(0,1,nrho_ohm);
%psipncronos    = abs(equi.psi-equi.psi(1))/max(abs(equi.psi-equi.psi(1)));
psipncronoshel = abs(psiRZ-psiRZ(1))/max(abs(psiRZ-psiRZ(1)));
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
ohm.epsi     = -sign(gene.signe.ip)*sign(gene.signe.b0)*interp1(gene.x,prof.epar,psitncronoshel);
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
cons=par.cons;
if strcmp(par.luke_mode,'lh')
  [launchs_lh] = make_wavelaunchs_cronos_lh(gene,par,cons.lh_cons);%for the LH waves
  launchs_ec   = [];
end
if strcmp(par.luke_mode,'ec')
  [launchs_ec] = make_wavelaunchs_cronos_ec(equil,par,cons.ecrh_cons);%for the EC waves
  launchs_lh   = [];
end
if strcmp(par.luke_mode,'mixte')
  [launchs_lh] = make_wavelaunchs_cronos_lh(gene,par,cons.lh_cons);%for the LH waves
  [launchs_ec] = make_wavelaunchs_cronos_ec(equil,par,cons.ecrh_cons);%for the EC waves
end
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
    if ~isfield(par,'prfmin') || wprf >= par.prfmin,
        mask = [mask,iw];
        prf = prf + wprf;
    else
        disp(['wave #',int2str(iw),': dismissed as Prf = ',num2str(wprf),' < Prfmin = ',num2str(par.prfmin),'.'])
    end
end
launchs = launchs(mask);  
nw = length(launchs);
%
if nw == 0
   sortie.j                    = zeros(size(gene.x));
   sortie.el                   = zeros(size(gene.x));
   memoire.data.output.j       = sortie.j;
   memoire.data.output.el      = sortie.el;
   memoire.data.output.paddrf  = 0;
   memoire.data.output.prf     = 0;
   memoire.data.output.ne      = prof.ne;
   memoire.data.output.irf     = 0;
   return 
end
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
        disp(['wave #',int2str(iw),': type :',launchs{iw}.type])
        %
    else
        disp(['wave #',int2str(iw),': type :',launchs{iw}.type,' n// = ',num2str(wavestructs{iw}.launch.bNpar0,4)])
        disp(['wave #',int2str(iw),': type :',launchs{iw}.type,' Plh = ',num2str(wavestructs{iw}.launch.bPlhtot,4)])
    end
    %
end
if isempty(dkeparam.w_mask)
    dkeparam.w_mask = 1:length(launchs);
end
%
% accessibility test
%
if nw > 0
  acces_lh
end
%
distrib_RF  = [];
distrib_TOT = [];
distrib_OHM = [];
%
if ~isempty(memoire)
  if isfield(memoire,'data')
    if isfield(memoire.data,'edistribution')  
        disp(['-------------using the last distribution function------------'])
        tm = memoire.data.edistribution(end).shotime;
        if tm == shotime,% remove last distribution info if time has not advanced
            memoire.data.edistribution = memoire.data.edistribution(1:end-1);
        end
        %
        if length(memoire.data.edistribution) >= 1,% the time here is necessarily anterior
            distrib_RF     = memoire.data.edistribution(end).f0_RF;
            distrib_TOT    = memoire.data.edistribution(end).f0_TOT;
            distrib_OHM    = memoire.data.edistribution(end).f0_OHM;
            dkeparam.rho_S = memoire.data.edistribution(end).rho_S;
            dkeparam.tn    = (shotime - memoire.data.edistribution(end).shotime)*distrib_RF.mksa.nhu_ref;% LUKE time step
        end
    end
  end
end
%
if par.save == 2,%save before LUKE
   %  
  try
    workdir = fileparts(evalin('base','param.gene.file'));
  catch 
    workdir = [];
  end
  if isempty(workdir)
    disp('you can not save the luke file in batch mode')
  else
    save([workdir,'/before_luke@',equil_id,'.mat']);
    error('Exiting after saving LUKE parameters')
  end

end
%
%--------------------------- Execution du trace de rayon C3PO et du code cinetique LUKE --------------------------- 
%
ik = 1;
warning off
disp(['LUKE is running ....'])
%
signe_out = -gene.signe.ip;
%
% CALCULATION WITH RF ONLY
%
[Znorm_RF,Zcurr_RF,ZP0_RF,dke_out_RF,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa] = ...
    run_lukert_batchopt('cronos',wavestructs,[],dkepath,equil,dkeparam,dkedisplay,[],transpfaste,ripple,distrib_RF,par);
%
j_RF_c = signe_out*Zcurr_RF.x_0_vcfsav*mksa.j_ref*1e6;
I_RF_c = sum(signe_out*Zcurr_RF.x_0_fsav.*equilDKE.xdA_dke*mksa.j_ref*1e6);
p_RF_c = ZP0_RF.x_rf_fsav.'*mksa.P_ref*1e6;
P_RF_c = sum(p_RF_c.*equilDKE.xdV_2piRp_dke*2*pi*equilDKE.Rp);
f0_RF = dke_out_RF.Zf0_interp;%For time evolution
%
waves = dke_out_RF.waves;%waves reused for synergy calculations
dkeparam.rho_S = radialDKE.xrho_S_dke;% retrieve RF rho grid if (re)calculated within run_lukert
dkeparam.rt_mode = 1;%a_sdNpar fixed by previous RF calculation
%
if strcmp(par.syn,'Yes') && sum(abs(ohm.epsi)) ~= 0,%Calculate the synergy between RF and OHMIC
    %
    % CALCULATION WITH RF AND OHMIC
    %
    [Znorm_TOT,Zcurr_TOT,ZP0_TOT,dke_out_TOT] = run_lukert_batchopt('cronos',[],waves,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,distrib_TOT,par);
    %
    j_TOT_c = signe_out*Zcurr_TOT.x_0_vcfsav*mksa.j_ref*1e6;
    I_TOT_c = sum(signe_out*Zcurr_TOT.x_0_fsav.*equilDKE.xdA_dke*mksa.j_ref*1e6);
    p_RF_TOT_c = ZP0_TOT.x_rf_fsav.'*mksa.P_ref*1e6;
    % p_OHM_TOT_c = ZP0_TOT.x_e_fsav*mksa.P_ref*1e6;
    % P_RF_TOT_c = sum(p_RF_TOT_c.*equilDKE.xdV_2piRp_dke*2*pi*equilDKE.Rp);
    % P_OHM_TOT_c = sum(p_OHM_TOT_c.*equilDKE.xdV_2piRp_dke*2*pi*equilDKE.Rp);
    %
    f0_TOT = dke_out_TOT.Zf0_interp;%For time evolution
    %
    % CALCULATION OHMIC ONLY
    %
    [Znorm_OHM,Zcurr_OHM,ZP0_OHM,dke_out_OHM] = run_lukert_batchopt('cronos',[],[],dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,distrib_OHM,par);
    %
    j_OHM_c = signe_out*Zcurr_OHM.x_0_vcfsav*mksa.j_ref*1e6;
    I_OHM_c = sum(signe_out*Zcurr_OHM.x_0_fsav.*equilDKE.xdA_dke*mksa.j_ref*1e6);
    % p_OHM_c = ZP0_OHM.x_e_fsav*mksa.P_ref*1e6;
    % P_OHM_c = sum(p_OHM_c.*equilDKE.xdV_2piRp_dke*2*pi*equilDKE.Rp);
    %
    f0_OHM = dke_out_OHM.Zf0_interp;%For time evolution
    %
else
    %
    j_TOT_c     = j_RF_c;% total current is RF current
    I_TOT_c     = I_RF_c;
    p_RF_TOT_c  = p_RF_c;% RF deposition profile in the absence of ohmic
    j_OHM_c     = zeros(1,length(j_RF_c));% no ohmic current
    I_OHM_c     = 0;
    f0_TOT      = f0_RF;% electron distribution in the absence of ohmic
    f0_OHM      = [];% maxwellian distribution
    %
end
%
% SYNERGISTIC EFFECTS - proportional to the electric field in linear limit
%
% Note : p_OHM_SYN_c is commented as it should be already accounted for in cronos E.J with J including j_SYN_c
%
j_SYN_c = j_TOT_c - j_RF_c - j_OHM_c;% synergistic current
I_SYN_c = I_TOT_c - I_RF_c - I_OHM_c;% synergistic current
% p_OHM_SYN_c = p_OHM_TOT_c - p_OHM_c;% synergistic ohmic heating
%
warning on
%
if strcmp(dkedisplay.display_mode,'PARTIAL_VISUAL') || strcmp(dkedisplay.display_mode,'VISUAL'),
    %
    visu_luke
    %
end
%
% par.ipfrac : maximum fraction of IP allowed for RF current
%
if isfield(par,'ipfrac'),
    %
    I_boot = zintsurf(neo.jboot,gene.x,equi.spr,equi.rhomax);
    %
    if (I_RF_c+I_boot)/equi.ip > par.ipfrac,
        %
        normip = par.ipfrac*equi.ip/(I_RF_c+I_boot);
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
sortie.err = normip;
%
%--------------------------- REMPLISSAGE DE LA STRUCTURE DE SORTIE POUR CRONOS --------------------------- 
%
%
% preparation des variables de sortie (sortie.j, sortie.el) pour CRONOS
%
method = 'linear';
%
xrhoT = [0,equilDKE.xrhoT,1];
j_RF_c = [j_RF_c(1),j_RF_c,0];
j_SYN_c = [j_SYN_c(1),j_SYN_c,0];
p_RF_TOT_c = [p_RF_TOT_c(1),p_RF_c,0];
%
cj_RF_c  = interp1(xrhoT,j_RF_c,gene.x,method);% (A/m2)
cj_SYN_c  = interp1(xrhoT,j_SYN_c,gene.x,method);% (A/m2)
cp_RF_TOT_c = interp1(xrhoT,p_RF_TOT_c,gene.x,method);% (W/m3)
%
% remise de la puissance et du courant de LUKE
%
irfnew = zintsurf(cj_RF_c,gene.x,equi.spr,equi.rhomax);
isynnew = zintsurf(cj_SYN_c,gene.x,equi.spr,equi.rhomax);
paddrfnew = zintvol(cp_RF_TOT_c,gene.x,equi.vpr,equi.rhomax);
%
if abs(irfnew - I_RF_c)/abs(I_RF_c) > 0.01,
    disp(['WARNING : surface integral on LUKE and CRONOS grids give different results. RF current renormalized by ',num2str(I_RF_c / irfnew)])
end
if abs(isynnew - I_SYN_c)/max([abs(I_SYN_c),eps]) > 0.01,
    disp(['WARNING : surface integral on LUKE and CRONOS grids give different results. SYN current renormalized by ',num2str(I_SYN_c / isynnew)])
end
if abs(paddrfnew - P_RF_c)/abs(P_RF_c) > 0.01,
    disp(['WARNING : volume integral on LUKE and CRONOS grids give different results. RF power renormalized by ',num2str(P_RF_c / paddrfnew)])
end
cj_RF_c  = cj_RF_c  * I_RF_c / irfnew * normip;
if isynnew ~= 0,
    cj_SYN_c  = cj_SYN_c  * I_SYN_c / isynnew;
end
if paddrfnew ~= 0,
    cp_RF_TOT_c = cp_RF_TOT_c * P_RF_c / paddrfnew;
end
%
% SMOOTHING
%
if isfield(par,'smooth') && strcmp(par.smooth,'Yes')
    newj  = smooth_dke_yp(cj_RF_c.',par.width_smooth,par.method_smooth).';  % diffusion phenomenologique du courant
    norm1 = zintsurf(cj_RF_c,gene.x,equi.spr,equi.rhomax);
    norm2 = zintsurf(newj,gene.x,equi.spr,equi.rhomax);
    cj_RF_c = newj/norm2*norm1;
    %
    newjsyn  = smooth_dke_yp(cj_SYN_c.',par.width_smooth,par.method_smooth).';  % diffusion phenomenologique du courant
    norm1 = zintsurf(cj_SYN_c,gene.x,equi.spr,equi.rhomax);
    norm2 = zintsurf(newjsyn,gene.x,equi.spr,equi.rhomax);
    if norm1 ~= 0,
        cj_SYN_c  = newjsyn/norm2*norm1;
    end
    %
    newel  = smooth_dke_yp(cp_RF_TOT_c.',par.width_smooth,par.method_smooth).';  % diffusion phenomenologique du courant
    norm1 = zintvol(cp_RF_TOT_c,gene.x,equi.vpr,equi.rhomax);
    norm2 = zintvol(newel,gene.x,equi.vpr,equi.rhomax);
    if norm1 ~= 0,
        cp_RF_TOT_c = newel/norm2*norm1;
    end
end
%
% if negative RF power is found at any xy grid point, it means the calculation was somewhat unstable
% 
if any(any(ZP0_RF.xy_rf_fsav < 0)),
    %
    sortie.err = sortie.err + 1i;
    %
    disp('Problem in LUKE, negative absorbed power calculated for some value, use the previous LUKE calculation if possible')
    %
    if isfield(memoire.data,'output')
        %
        % assume constant efficiency n.I/P
        %
        cj_RF_c   = memoire.data.output.j*prf/memoire.data.output.prf.*memoire.data.output.ne./prof.ne;
        cj_SYN_c = 0;
        cp_RF_TOT_c  = memoire.data.output.el*prf/memoire.data.output.prf;
        %
    end
end    
%
% In principle the synergy increases with both RF power and efield. Thus it
% makes sense, to avoid divergence in sigmasyn, to cap the sigmasyn with 
% its value obtained at the max of abs(cj_SYN_c)
%
sigmasyn = cj_SYN_c./prof.epar;
sigmasyn(prof.epar == 0) = 0;% To avoid NAN
sigmasynmax = sigmasyn(find(abs(cj_SYN_c) == max(abs(cj_SYN_c)),1,'first'));%value obtained at the max of abs(cj_SYN_c)
sigmasyn = sign(sigmasyn).*min([abs(sigmasyn);repmat(abs(sigmasynmax),[1,length(sigmasyn)])]);% caping
%
sortie.j = cj_RF_c;% RF current in the absence of ohmic
sortie.sigmasyn = sigmasyn;% synergistic conductivity (= HOT - COLD). 
sortie.el = cp_RF_TOT_c;% Note : the RF power deposition profile calculated in the presence of ohmic must be used.
%
irf = zintsurf(cj_RF_c,gene.x,equi.spr,equi.rhomax);
paddrf = zintvol(cp_RF_TOT_c,gene.x,equi.vpr,equi.rhomax);
%
disp(['I_L_H = ',num2str(irf/1e3,3),' kA / I_p =',num2str(equi.ip/1e3,4),' kA'])
disp(['P_L_H = ',num2str(paddrf/1e3,3),' kW / P_r_e_f = ',num2str(prf/1e3,3),' kW'])
%
memoire.data.output.j         = cj_RF_c;
memoire.data.output.el        = cp_RF_TOT_c;
memoire.data.output.paddrf    = paddrf;
memoire.data.output.prf       = prf;
memoire.data.output.ne        = prof.ne;
memoire.data.output.irf       = irf;
%
for iw = 1:nw,
    if isfield(wavestructs{iw}.launch,'aloha') & wavestructs{iw}.launch.aloha.mode ~= 0
       if isfield(memoire.data.output,'npar') 
           if iw <= length(memoire.data.output.npar)
             memoire.data.output.npar{iw}(end+1,:) = wavestructs{iw}.launch.bNpar0;
           else
             memoire.data.output.npar{iw}(1,:) = wavestructs{iw}.launch.bNpar0;
           end
       else
           memoire.data.output.npar{iw}(1,:) = wavestructs{iw}.launch.bNpar0;
       end
       if isfield(memoire.data.output,'pow') 
           if iw <= length(memoire.data.output.pow)
             memoire.data.output.pow{iw}(end+1,:) = wavestructs{iw}.launch.bPlhtot;
           else
             memoire.data.output.pow{iw}(1,:) = wavestructs{iw}.launch.bPlhtot;
           end
       else
           memoire.data.output.pow{iw}(1,:) = wavestructs{iw}.launch.bPlhtot;
       end
    end
end
%
if isfield(memoire.data,'edistribution')
    memoire.data.edistribution(end + 1).shotime = shotime;%For time evolution
else
    memoire.data.edistribution.shotime = shotime;%For time evolution
end
%
memoire.data.edistribution(end).f0_RF   = f0_RF;%For time evolution
memoire.data.edistribution(end).f0_TOT  = f0_TOT;%For time evolution
memoire.data.edistribution(end).f0_OHM  = f0_OHM;%For time evolution
memoire.data.edistribution(end).rho_S   = radialDKE.xrho_S_dke;
%
%
% For diagnostic post-processing (HXR,...)
%
%memoire.data.edistribution.dkeparam  = dkeparam;%For HXR calculations
%memoire.data.edistribution.dkedisplay = momentumDKE.dkedisplay;%For HXR calculations
%memoire.data.edistribution.equil = equil;%For HXR calculations
%memoire.data.edistribution.radialDKE = radialDKE;%For HXR calculations
%memoire.data.edistribution.Zcurr = Zcurr;%For HXR calculations
%memoire.data.edistribution.hxr = hxr;%For HXR calculations
%memoire.data.edistribution.hxrparam = hxrparam;%For HXR calculations
%memoire.data.edistribution.mksa = mksa;%For HXR calculations
%memoire.data.edistribution.momentumDKE = momentumDKE;%For HXR calculations
%memoire.data.edistribution.dke_out = dke_out_RF;%For HXR calculations
%
if par.save == 1,
  try
    workdir = fileparts(evalin('base','param.gene.file'));
  catch 
    workdir = [];
  end
  if isempty(workdir)
    disp('you can not save the luke file in batch mode')
  else
    save([workdir,'/last_luke@',equil_id,'.mat']);
  end
end
end
%
% Generic function to use either direct call to run_lukert or batch run
%
function [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource,dke_warnings] = ...
    run_lukert_batchopt(id_simul,wavestructs,waves,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,distrib,par)
    %
    dkepath.remnum = par.remnum;% remote profile number. Use 0 for local sequential calculations
    dkepath.remtimout = par.remtimout;% timeout for remote calculations, in minutes. Use (0) to return later and check results by running this script again
    dkepath.rempause = par.rempause;% pause between job checks (in minutes) (only for remtimout > 0)
    dkepath.debugmode = par.debugmode;% debug mode (0) off (1) on
    dkepath.clean = par.clean;% clean job files/folders : both on remote and local (2), only on remote (1) or not at all (0)
    %
    % backup & save options
    %
    opt.save = par.saveluke;% (1): save LUKE_RESULTS or return error (0): return results or error
    if isinf(par.fields),
        opt.fields = NaN;% selected fields in returned lukestructs. Use NaN for all fields
    else
        opt.fields = par.fields;% selected fields in returned lukestructs. Use NaN for all fields
    end
    opt.backup = par.backup;% (1) save fluctuation time steps (0) do not save
    opt.waves = par.waves;% (1) save waves at each time step (0) do not save
    %
    lukestructs = struct;
    lukestructs.simul.id_simul = id_simul;
    lukestructs.simul.path = '';
    lukestructs.dkeparam = dkeparam;
    lukestructs.dkepath = dkepath;
    lukestructs.dkedisplay = dkedisplay;
    lukestructs.equil = equil;
    lukestructs.waves = waves;
    lukestructs.wavestructs = wavestructs;
    lukestructs.ohm = ohm;
    lukestructs.transpfaste = transpfaste;
    lukestructs.ripple = ripple;
    lukestructs.Zf0_interp = distrib;
    lukestructs.opt = opt;
    %
    lukestructs = run_lukert(lukestructs,dkepath);
    %
    if isfield(lukestructs,'err'),
        zverbose('Remote LUKE run failed, aborted.')
    else
        %
        Znorm = lukestructs.output.Znorm;
        Zcurr = lukestructs.output.Zcurr;
        ZP0 = lukestructs.output.ZP0;
        dke_out = lukestructs.output.dke_out;
        radialDKE = lukestructs.output.radialDKE;
        equilDKE = lukestructs.output.equilDKE;
        momentumDKE = lukestructs.output.momentumDKE;
        gridDKE = lukestructs.output.gridDKE;
        Zmomcoef = lukestructs.output.Zmomcoef;
        Zbouncecoef = lukestructs.output.Zbouncecoef;
        Zmripple = lukestructs.output.Zmripple;
        mksa = lukestructs.output.mksa;
        XXsinksource = lukestructs.output.XXsinksource;
        %
    end
    %
    clear raytracing_yp alphaphimex_jd trapz_dke_yp dmumpsmex
    %
end
