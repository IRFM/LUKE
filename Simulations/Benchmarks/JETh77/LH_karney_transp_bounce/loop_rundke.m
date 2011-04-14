function [Zcurr,ZP0,dke_out,equilDKE,mksa] = loop_rundke(iDr0,Dr0_list,iDr0_save,...
    id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple)
%
%
transpfaste.Dr0 = Dr0_list(iDr0);
%
[Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
if iDr0 == iDr0_save,
    filename = ['DKE_RESULTS_',equil.id,'_',id_simul,'_Dr0_',num2str(Dr0_list(iDr0)),'.mat'];
    save(filename);
    info_dke_yp(2,['Data saved in ',filename]);
end
