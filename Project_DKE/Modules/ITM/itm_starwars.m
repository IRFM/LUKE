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
	[equil] = load_structures_yp('equil','ITER_Scen4_IAEA06',[dkepath.luke_root,'Simulations/Examples/ITER/Scen4/EQUIL/']);
	disp('Warning: local magnetic equilibrium. No access to the ITM MDS+ database !');
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
	else
		if isempty(magnetic_LUKE),error('Magnetic equilibrium data (''equilibrium'') not loaded for LUKE.');end
		if isempty(coreprof_LUKE),error('Kinetic data (''coreprof'') not loaded for LUKE.');end
	end
end
%
%TODO: Used until launchs ITM CPO is operational. ITER/Scen4/LH_20Z case only for demo use
%
if strfind(equil.id,'ITER_Scen4_IAEA06'),
	ids_launch = {[equil.id,'_20Z']};%For RF waves contribution (put all the type of waves needed)
	paths_launch = {[dkepath.luke_root,'Simulations/Examples/ITER/Scen4/WAVE/C3PO/']};%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
	luke_mode = 'lh';
	%
	[launchs] = load_structures_yp('launchs',ids_launch,paths_launch);
	launchs{1}.id = '';
	launchs{1}.mmode = -1;
	%
	rho_S = [0,0.6:0.04:1];
	%
	ohm.rho = rho_S;
	ohm.epsi = zeros(size(rho_S));
	transpfaste = '';
	ripple = '';
	%
	make_display = 'PARTIAL_VISUAL';
else
	error('The function itm_starwars.m works only with ITER_Scen4_IAEA06 magnetic equilibrium !');
end
%
% --------- Load first all parameters that are in files ------------
%
dkeparam         = make_dkeparam_ITM(launchs{1}.type);
dkedisplay       = make_display_ITM(make_display);
dkepath.temppath = [dkepath.temppathroot,filesep,'LUKE',filesep,timeid_jd(clock)];%Temporary subdirectory in scratch folder
%
% PARAMETRES WAVE LH + EC (C3PO) 
%
for iw = 1:length(launchs),
    [waveparam,fitequilparam,rayparam,raydisplay] = make_wavert_ITM(launchs{iw}.type);%parameter for ray-tracing are adapted to the selected wave
    %   	
    wavestructs{iw}.id = launchs{iw}.id;
    wavestructs{iw}.equil_id = equil.id;
    wavestructs{iw}.launch = launchs{iw};
    wavestructs{iw}.waveparam = waveparam;
    wavestructs{iw}.fitequilparam = fitequilparam;
    wavestructs{iw}.rayparam = rayparam;
    wavestructs{iw}.raydisplay = raydisplay;
    %
    wavestructs{iw}.wavesolver = 'C3PO';
    wavestructs{iw}.waveparam.mmode = launchs{iw}.mmode;% cold mode (+1 for m; -1 for p)
    wavestructs{iw}.waveparam.kmode = 0;%Dielectric tensor (0:cold,1:warm,2:hot;3:weak relativistic,4:full relativistic)
    wavestructs{iw}.rayparam.tensortype = wavestructs{iw}.waveparam.kmode;%(0:cold,1:warm,2:hot;3:weak relativistic,4:full relativistic)
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
opt_save=0;
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
   [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource,dke_warnings] = main_dke_yp('cronos',[],rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,'',transpfaste,ripple,[],[]);
end
%
while 1,
   [Znorm_RF,Zcurr_RF,ZP0_RF,dke_out_RF,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource,dke_warnings] = run_lukert('cronos',wavestructs,waves,[],rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,[],[],opt_save);
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
	  graph1D_jd(equilDKE.xrho,Zcurr.x_0_fsav*mksa.j_ref,0,0,'\rho','J_{tot} (MA/m^2)',[equil.id,',I_{tot} = ',num2str(I_ohm*1000),' (kA)'],NaN,'','','-','none','r',2);hold on
	  graph1D_jd(equilDKE.xrho,Zcurr.x_0_vfsav*mksa.j_ref,0,0,'\rho','J_{tot} (MA/m^2)',[equil.id,',I_{tot} = ',num2str(I_ohm*1000),' (kA)'],NaN,'','','-','none','b',2);hold off,drawnow
      legend('LUKE flux surface averaging','CRONOS flux surface averaging')
%	  print_jd(p_opt,[filename,'_Curr']);
%
	  POHM_ohm = sum(ZP0.x_e_fsav.*equilDKE.xdV_2piRp_dke*mksa.P_ref*2*pi*equilDKE.Rp);
	  figure('Name','Ohmic Power'),
	  graph1D_jd(equilDKE.xrho,ZP0.x_e_fsav*mksa.P_ref,0,0,'\rho','P_{OHM} (MW/m^3)',[equil.id,',P_{OHM} = ',num2str(POHM_ohm*1000),' (kW)'],NaN,'','','-','none','r',2);drawnow
%	  print_jd(p_opt,[filename,'_Ohm']);
   end		
%
	I_tot = sum(Zcurr_RF.x_0_fsav.*equilDKE.xdA_dke*mksa.j_ref);
	figure('Name','Current profile'),
	graph1D_jd(equilDKE.xrho,Zcurr_RF.x_0_fsav*mksa.j_ref,0,0,'\rho','J_{tot} (MA/m^2)',[equil.id,',I_{tot} = ',num2str(I_tot*1000),' (kA)'],NaN,'','','-','none','r',2);hold on
	graph1D_jd(equilDKE.xrho,Zcurr_RF.x_0_vfsav*mksa.j_ref,0,0,'\rho','J_{tot} (MA/m^2)',[equil.id,',I_{tot} = ',num2str(I_tot*1000),' (kA)'],NaN,'','','-','none','b',2);hold off,drawnow
    legend('LUKE flux surface averaging','CRONOS flux surface averaging')
%	print_jd(p_opt,[filename,'_Curr']);
%
	PLH_tot = sum(ZP0_RF.x_rf_fsav.*equilDKE.xdV_2piRp_dke(:)*mksa.P_ref*2*pi*equilDKE.Rp);
	figure('Name','LH Power'),
	graph1D_jd(equilDKE.xrho,ZP0_RF.x_rf_fsav*mksa.P_ref,0,0,'\rho','P_{LH} (MW/m^3)',[equil.id,',P_{LH} = ',num2str(PLH_tot*1000),' (kW)'],NaN,'','','-','none','r',2);drawnow
%	print_jd(p_opt,[filename,'_RF_Power']);
%
	POHM_tot = sum(ZP0_RF.x_e_fsav.*equilDKE.xdV_2piRp_dke*mksa.P_ref*2*pi*equilDKE.Rp);
	figure('Name','Ohmic Power'),
	graph1D_jd(equilDKE.xrho,ZP0_RF.x_e_fsav*mksa.P_ref,0,0,'\rho','P_{OHM} (MW/m^3)',[equil.id,',P_{OHM} = ',num2str(POHM_tot*1000),' (kW)'],NaN,'','','-','none','r',2);drawnow
%	print_jd(p_opt,[filename,'_Ohm']);
end
%
%--------------------------- WRITE CPO's' into ITM database ------------------%
varargout{1} = 'coreprof';
varargout{2} = equilDKE.xrho;
if sum(abs(ohm.epsi)) ~= 0,%Calculate the Ohmic electric field contribution to the plasma current
	varargout{3} = Zcurr.x_0_fsav*mksa.j_ref;
else
	varargout{3} = Zcurr_RF.x_0_fsav*mksa.j_ref*0;
end
varargout{4} = Zcurr_RF.x_0_fsav*mksa.j_ref;


