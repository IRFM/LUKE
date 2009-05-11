function [varargout] = itm_starwars(CPOs)
%LUKE -  Interface for running C3PO/LUKE as a Kepler actor
%
% Interface for running C3PO/LUKE as a Kepler actor. Arguments of itm_starwars.m are MatLab structures 
% which are mirror copies of the corresponding CPO's in the ITM MDS+ database. Read/write from/to the MDS+ 
% database is supported by the wrapper outside this function.
% 
% by Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
%--------------------------- CPO to LUKE structure conversion ------------------
%
[dkepath] = load_structures_yp('dkepath','','');
%
if ~nargin,%local test mode only (ITER/Scen4 + LH_20Z) case
	id_equil = 'ITER_Scen4_IAEA06';%For plasma equilibrium
	path_equil = [dkepath.luke_root,'Simulations/Examples/ITER/Scen4/EQUIL/'];%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
	%
	ids_wave = {'20Z'};%For RF waves contribution (put all the type of waves needed)
	paths_wave = {[dkepath.luke_root,'Simulations/Examples/ITER/Scen4/WAVE/C3PO/']};%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
	luke_mode = 'lh';
	%
	[equil,waves] = load_structures_yp('equil',id_equil,path_equil,'waves',ids_wave,paths_wave);
	disp('Warning: local mode calculation. No access to the ITM MDS+ database !');
else,%connexion to the MDS+ database
	for ii = 1:length(CPOs),
		if isfield(CPOs{ii},'eqgeometry'),
			magnetic_LUKE = CPO2LUKEstruct_yp('equilibrium',CPOs{ii});% Data conversion between ITM CPO's and C3PO/LUKE format
		end
		%
		if isfield(CPOs{ii},'composition') & isfield(CPOs{ii},'te'),
			coreprof_LUKE = CPO2LUKEstruct_yp('coreprof',CPOs{ii});% Data conversion between ITM CPO's and C3PO/LUKE format
		end
	end
	%
	if ~isempty(magnetic_LUKE) & ~isempty(coreprof_LUKE)
		equil = conc_struct_jd(magnetic_LUKE,coreprof_LUKE);
		%
		varargout{1} = 'coreprof';
		varargout{2} = coreprof_LUKE;
		return
	else
		if isempty(magnetic_LUKE),error('Magnetic equilibrium data (''equilibrium'') not loaded for LUKE.');end
		if isempty(coreprof_LUKE),error('Kinetic data (''coreprof'') not loaded for LUKE.');end
	end
end
%
% Determines run type
%
switch luke_mode
  %    
  case 'mixte'
    %
    % Mixed LH and EC waves case
    %
    [launchs_lh] = make_wavelaunchs_ITM_lh(equil,gene.signe,par.lh_param.conf,cons.lh_cons,cons_spec);%for the LH waves
    [launchs_ec] = make_wavelaunchs_ITM_ec(equil,par.ecrh_param,cons.ecrh_cons);%for the EC waves
    %    
    launchs = [launchs_lh,launchs_ec];
    launchtype = 'LH';
    %
  case 'lh'
    %
    % LH waves only
    %
    if strcmp(par.conf,'Ohmic')
      [launchs] = make_wavelaunchs_ITM_lh(equil,gene.signe,'MIXTE',cons,cons_spec);%for the LH waves
    else
      [launchs] = make_wavelaunchs_ITM_lh(equil,gene.signe,par.conf,cons,cons_spec);%for the LH waves
    end
    launchtype = 'LH';
    %    
  case 'ecrh'
    %
    % EC waves only
    %
    [launchs] = make_wavelaunchs_ITM_ec(equil,par,cons);%for the EC waves    
    launchtype = 'EC';
    %
  otherwise
    %
    error('luke mode could not be determined: must be lh, ec or mixed')
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
dkeparam         = make_dkeparam_ITM(launchtype);
dkedisplay       = make_display_ITM(make_display);
dkepath.temppath = [dkepath.temppathroot,filesep,'LUKE',filesep,timeid_jd(clock)];%Temporary subdirectory in scratch folder
%
% PARAMETRES WAVE LH + EC (C3PO) 
%
for iw = 1:length(launchs),
    [waveparam,fitequilparam,rayparam,raydisplay] = make_wavert_ITM(launchs{iw}.type);%parameter for ray-tracing are adapted to the selected wave
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
%if sum(abs(ohm.epsi)) ~= 0,%Calculate the Ohmic electric field contribution to the plasma current
%   [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource,dke_warnings] = main_dke_yp('cronos',[],par.rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,'',transpfaste,ripple,[],[]);
%end
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



