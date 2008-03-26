function [flag] = itm_starwars(numshot,numrun,numshot_ref,numrun_ref,time,interp_method)
%
% itm_starwars: MatLab interface for running C3PO + LUKE in the ITM framework
%
%-------------------------------------------------------------------------
% itm_starwars.m -> source file in directory ~/Project_DKE/Modules/ITM/
%-------------------------------------------------------------------------
% 
% by Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
% by Yves Buranvand (CEA/DSM/IRFM, yves.buravand@cea.fr) and M. Airaj (CEA/DSM/IRFM, mohamed.airaj@cea.fr) for the Matlab UAL functions
%
%--------------------------- READ CPO's' from ITM database ------------------
%
import ualmemory.javainterface.*;
expIdx = openBD('euitm',numshot,numrun);%Open the database
%
equil_ITM = CPO_get(expIdx, 'equilibrium');%Read magnetic equilibrium
%
 
 keyboard
 
 
 
 
%
closeBD(expIdx,'euitm',numshot,numrun);%Close the currently open database
%
%--------------------------- Data conversion between ITM CPO's and C3PO/LUKE format ------------------
%
%equil = make_equil_itm(equil_ITM);
%
flag = 0;
return




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
    if strcmp(par.conf,'Ohmic')
      [launchs] = make_wavelaunchs_cronos_lh(equil,gene.signe,'MIXTE',cons,cons_spec);%for the LH waves
    else
      [launchs] = make_wavelaunchs_cronos_lh(equil,gene.signe,par.conf,cons,cons_spec);%for the LH waves
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
signe = evalin('base','param.gene.signe');%Toroidal Bfield and plasma current sign (CRONOS convention: > 0 when counter-clockwise from top view)
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
transpfaste.Dr0      = par.Dr0;%Core radial diffusion coefficient (m^2/s)
transpfaste.pDr      = par.pDr;%Coefficient for the Dr radial profile
transpfaste.Vr0      = par.Vr0;%Core radial pinch coefficient (m/s)
transpfaste.pVr      = par.pVr;%Coefficient for the Vr radial profile
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
    wavestructs{iw}.waveparam.mmode = launchs{iw}.mmode;% cold mode (+1 for m; -1 for p)
    wavestructs{iw}.waveparam.kmode = par.kmode;%Dielectric tensor (0:cold,1:warm,2:hot;3:weak relativistic,4:full relativistic)
    wavestructs{iw}.rayparam.tensortype = wavestructs{iw}.waveparam.kmode;%(0:cold,1:warm,2:hot;3:weak relativistic,4:full relativistic)
    wavestructs{iw}.rayparam.tfinal = par.ray_tfinal;
    %
    if strcmp(par.oneray,'Yes') & strcmp(wavestructs{iw}.launch.type,'LH'),
    	wavestructs{iw}.launch.ry0 = mean(wavestructs{iw}.launch.ry0);
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
%
if sum(abs(ohm.epsi)) ~= 0,%Calculate the Ohmic electric field contribution to the plasma current
   [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource,dke_warnings] = main_dke_yp('cronos',[],par.rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,'',transpfaste,ripple,[],[]);
end
%
while 1,
   [Znorm_RF,Zcurr_RF,ZP0_RF,dke_out_RF,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource,dke_warnings] = run_lukert('cronos',wavestructs,waves,[],par.rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,[],[],opt_save);
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
   if sum(abs(real(ohm.epsi))) > 0 | sum(abs(imag(ohm.epsi))) > 0,	
	  I_ohm = sum(Zcurr.x_0_fsav.*equilDKE.xdA_dke*mksa.j_ref);
	  figure('Name','Ohmic current profile'),
	  graph1D_jd(equilDKE.xrho,Zcurr.x_0_fsav*mksa.j_ref,0,0,'\rho','J_{tot} (MA/m^2)',[par.machine_nom,',I_{tot} = ',num2str(I_ohm*1000),' (kA)'],NaN,'','','-','none','r',2);hold on
	  graph1D_jd(equilDKE.xrho,Zcurr.x_0_vfsav*mksa.j_ref,0,0,'\rho','J_{tot} (MA/m^2)',[par.machine_nom,',I_{tot} = ',num2str(I_ohm*1000),' (kA)'],NaN,'','','-','none','b',2);hold off,drawnow
      legend('LUKE flux surface averaging','CRONOS flux surface averaging')
%	  print_jd(p_opt,[filename,'_Curr']);
%
	  POHM_ohm = sum(ZP0.x_e_fsav.*equilDKE.xdV_2piRp_dke*mksa.P_ref*2*pi*equilDKE.Rp);
	  figure('Name','Ohmic Power'),
	  graph1D_jd(equilDKE.xrho,ZP0.x_e_fsav*mksa.P_ref,0,0,'\rho','P_{OHM} (MW/m^3)',[par.machine_nom,',P_{OHM} = ',num2str(POHM_ohm*1000),' (kW)'],NaN,'','','-','none','r',2);drawnow
%	  print_jd(p_opt,[filename,'_Ohm']);
   end		
%
	I_tot = sum(Zcurr_RF.x_0_fsav.*equilDKE.xdA_dke*mksa.j_ref);
	figure('Name','Current profile'),
	graph1D_jd(equilDKE.xrho,Zcurr_RF.x_0_fsav*mksa.j_ref,0,0,'\rho','J_{tot} (MA/m^2)',[par.machine_nom,',I_{tot} = ',num2str(I_tot*1000),' (kA)'],NaN,'','','-','none','r',2);hold on
	graph1D_jd(equilDKE.xrho,Zcurr_RF.x_0_vfsav*mksa.j_ref,0,0,'\rho','J_{tot} (MA/m^2)',[par.machine_nom,',I_{tot} = ',num2str(I_tot*1000),' (kA)'],NaN,'','','-','none','b',2);hold off,drawnow
    legend('LUKE flux surface averaging','CRONOS flux surface averaging')
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
%--------------------------- WRITE CPO's' into ITM database ------------------%



