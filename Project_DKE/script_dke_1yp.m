%Script for testing the DKE solver
%by Y. Peysson <yves.peysson@cea.fr> (CEA/DRFC)
%
clear all;pause(0.5);
clear mex;pause(0.5);
clear functions;pause(0.5);
close all;
warning off;
global nfig;
pause(1);
%
disp('-------------------------------------------------------------------------------------------------------------------');
disp('-------------------------------------------------------------------------------------------------------------------');
disp(['Drift Kinetic calculations for the electron population during current drive in tokamaks']);
disp(['for arbitrary plasma equilibrium']);
disp(['Authors:  - Yves Peysson (CEA-DSM-DRFC, France, yves.peysson@cea.fr)']);
disp(['          - Joan Decker (MIT-RLE, USA, jodecker@alum.mit.edu)']);
disp('-------------------------------------------------------------------------------------------------------------------');
%
%
[s,dossier,machine] = comput_dke_yp;
%
%Simulation parameters
%
[tokname,snumber,...
grid_uniformity,grid_power,nmhu_S_in,np_S_in,pnmax_S_in,sfac,spfac,snmhu,snp,...
psin_S,psin_display_in,dpsin_dke,...
ref_mode,norm_ref,...
epsi0_in,epsia_in,eepsi,...
coll_mode,bounce_mode,dke_mode,equil_mode,...
vparmin_r,Dr0,pDr,Dr_model,Vr0,pVr,Vr_model,...
nhuloss,...
prec0_f,nit_f,dtn,prec0_g,nit_g,initguess,invproc_in,param_inv_in,dp_cyl,display_mode,nlevel,store_mode,diary_mode,auto_mode]...
= psim_dke_1yp;
%
nloop = length(nmhu_S_in)*length(np_S_in)*length(pnmax_S_in);
nloop = nloop*length(psin_display_in)*length(epsi0_in)*length(epsia_in)*length(invproc_in)*size(param_inv_in,1);
disp(['- Total number of loops: ',int2str(nloop)]);
disp('-------------------------------------------------------------------------------------------------------------------');
%
iloop = 0;
for nmhu_S = nmhu_S_in,
for np_S = np_S_in,
for pnmax_S = pnmax_S_in,
for psin_display = psin_display_in,
for epsi0 = epsi0_in,
for epsia = epsia_in,
for invproc	= invproc_in,
for sparam_inv = 1:size(param_inv_in,1),
   	param_inv = param_inv_in(sparam_inv,:); 
 %
	iloop = iloop + 1;
    disp(['- Loop number: ',int2str(iloop),'/',int2str(nloop)]);
%
	[Jrf0(iloop,:),Jboot_e(iloop,:),Jboot_i(iloop,:),Jtot(iloop,:),Pabs0(iloop,:),Pabs_tot(iloop,:),efficiency(iloop,:),epsi_fsav(iloop,:),...
	    ia(iloop,:),ft(iloop,:),time(iloop),memoryLU_f(iloop),memoryLU_g(iloop)] =...
	    test_dke_1yp(tokname,snumber,...
	    grid_uniformity,grid_power,nmhu_S,np_S,pnmax_S,sfac,spfac,snmhu,snp,psin_S,psin_display,dpsin_dke,...
	    ref_mode,norm_ref,...
	    epsi0,epsia,eepsi,...
	    coll_mode,bounce_mode,dke_mode,equil_mode,...
	    vparmin_r,Dr0,pDr,Dr_model,Vr0,pVr,Vr_model,...
	    nhuloss,...
	    prec0_f,nit_f,dtn,prec0_g,nit_g,initguess,invproc,param_inv,dp_cyl,display_mode,nlevel,store_mode,diary_mode,auto_mode,iloop);
    disp('-------------------------------------------------------------------------------------------------------------------');
end
end
end
end
end
end
end
end
%
eval(['save script_dke_s',int2str(snumber),'_out.mat']);
info_dke_yp(2,['The script file : script_dke_s',int2str(snumber),'_out.mat has been successfully saved !']);
disp('-------------------------------------------------------------------------------------------------------------------');


