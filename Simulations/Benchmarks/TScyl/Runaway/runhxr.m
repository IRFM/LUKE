id_simul = 'Runaway_particule_loss';%Simulation ID
id_equil = 'TScirc';%For plasma equilibrium
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_hxr = 'TS99';%For HXR diagnostic configuration
path_hxr = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
%************************************************************************************************************************************
%************************************************************************************************************************************
%************************************************************************************************************************************
%
if exist([path_hxr,'HXR_',id_hxr,'.mat']) == 0,%HXR
	info_dke_yp(2,[path_equil,'HXR_',id_hxr,'.mat does not exist']);
	break
else
	eval(['load ',path_equil,'HXR_',id_hxr,'.mat']);
	info_dke_yp(2,'Structures ''hxr and hxrparam'' successfully loaded');
end
%
if exist([path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']) == 0,%DKE results
	info_dke_yp(2,[path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat does not exist']);
	break
else
	eval(['load ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
	info_dke_yp(2,['DKE data results in file ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat successfully loaded']);
end
%
[Zbremchord,equilHXR] = bremchord_dke_yp(display,equil,radialDKE,Zcurr,hxr,hxrparam);
[Zbremplasma] = bremsstrahlung_dke_yp(dkeparam,display,equilHXR,radialDKE,mksa,momentumDKE,dke_out,Zbremchord,hxr,hxrparam);
[Zbremdiag] = bremdiag_dke_yp(Zbremplasma,hxr,hxrparam);
%
%For display HXR
%
bremchorddisplay_dke_yp(Zbremchord,1);
bremlocaldisplay_dke_yp(dkeparam,display,equilHXR,momentumDKE,radialDKE,dke_out,mksa,Zbremchord,Zbremplasma,0.3,180);
bremdiagdisplay_dke_yp(hxr,Zbremchord,Zbremplasma,Zbremdiag,42,50);
%
eval(['save ',path_simul,'HXR_RESULTS_',id_equil,'_',id_simul,'_',id_hxr,'.mat Zbremchord Zbremplasma Zbremdiag equilHXR']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'_',id_hxr,'.mat']);