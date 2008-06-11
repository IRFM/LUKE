id_simul = 'LH_karney_rippleon';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'NONUNIFORM10010020';%For DKE code parameters
path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil = 'TScirc_peak';%For plasma equilibrium
path_equil = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_display = 'PARTIAL_VISUAL';%For output code display
path_display = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_hxr = 'TS99';%For HXR diagnostic configuration
path_hxr = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
[equil,dkedisplay,hxr,hxrparam,dkeparam] = load_structures_yp('equil',id_equil,path_equil,'dkedisplay',id_display,path_display,'hxr',id_hxr,path_hxr,'dkeparam',id_dkeparam,path_dkeparam);
load([path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
%
[Zbremchord,equilHXR] = bremchord_dke_yp(dkeparam,dkedisplay,equil,radialDKE,Zcurr,hxr,hxrparam);
[Zbremplasma] = bremsstrahlung_dke_yp(dkeparam,dkedisplay,equilHXR,radialDKE,mksa,momentumDKE,dke_out,Zbremchord,hxr,hxrparam);
[Zbremdiag] = bremdiag_dke_yp(Zbremplasma,hxr,hxrparam);
%
%For display HXR
%
bremchorddisplay_dke_yp(Zbremchord,1);
bremlocaldisplay_dke_yp(dkeparam,dkedisplay,equilHXR,momentumDKE,radialDKE,dke_out,mksa,Zbremchord,Zbremplasma,0.3,180);
bremdiagdisplay_dke_yp(hxr,Zbremchord,Zbremplasma,Zbremdiag,42,50);
%
eval(['save ',path_simul,'HXR_RESULTS_',id_equil,'_',id_simul,'_',id_hxr,'.mat Zbremchord Zbremplasma Zbremdiag equilHXR']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'_',id_hxr,'.mat']);