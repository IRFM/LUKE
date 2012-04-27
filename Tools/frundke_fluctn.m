function frundke_fluctn(luke_input,dkepath,opt_save,p_opt,path_simul,dtn,tn,Nfluct,sigmar_max,sigmar_hwhm)
%
id_simul = luke_input.id_simul;
dkeparam = luke_input.dkeparam;
equil = luke_input.equil;
%
% in this scan, the imaginary part of tn specifies the number of iterations if Nfluct = 1
% - dkeparam.tn is adjusted to have final time constant
% - dkeparam.dtn is adjusted to have internal time step constant
if imag(tn) > 0,
    dkeparam.tn = tn/Nfluct;% as an imaginary number, dkeparam.tn prescribes the number of fluctuation iterations
else % in this scan, a real tn specifies the final time explicitly
    dkeparam.tn = tn;% as an imaginary number, dkeparam.tn prescribes the number of fluctuation iterations
end
if imag(dtn) > 0,
    dkeparam.dtn = dtn*Nfluct;% internal LUKE time step. As an imaginary number, dkeparam.dtn prescribes the number of internal time steps
else % in this scan, a real tn specifies the final time explicitly
    dkeparam.dtn = dtn;% internal LUKE time step. As an imaginary number, dkeparam.dtn prescribes the number of internal time steps
end
%
dkeparam.Nfluct = Nfluct;% Ratio of the LUKE evolution time (phase refresh) to the fluctuation time - also equal to the number of duplicated rays
equil.fluct.ne.sigmar_max = sigmar_max;% Maximum value of the relative fluctuations variance at the poloidal angle theta = 0 [1,nfluct_types]
equil.fluct.ne.sigmar_hwhm = sigmar_hwhm;%Radial half width at half maximum of the relative fluctuations variance at the poloidal angle theta = 0 [1,nfluct_types]
%
id_simul = [id_simul,'_sigma',num2str(sigmar_max),'_delta',num2str(sigmar_hwhm),'_dtn',num2str(dtn),'_tn',num2str(tn),'_Nfluct',num2str(Nfluct)];
id_simul(id_simul == '.') = 'p';
id_simul(id_simul == '+') = 'p';
%
[Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = ...
    run_lukert(id_simul,luke_input.wavestructs,luke_input.waves,dkeparam.psin_S,dkeparam.rho_S,...
    dkepath,equil,dkeparam,luke_input.dkedisplay,luke_input.ohm,luke_input.transpfaste,luke_input.ripple,luke_input.Zf0_interp,[],opt_save);
%
% ---------------------------------------------- Save results ----------------------------------------------
%
filename = [path_simul,'LUKE_RESULTS_',id_simul,'.mat'];
save(filename);
info_dke_yp(2,['LUKE Results saved in ',filename]);
%
% ---------------------------------------------- Display results ----------------------------------------------
%
[tn,tn_all,fluctres] = fluctanalysis_yp(equilDKE,ZP0,Zcurr,dkeparam,mksa,0);
%
xJm = fluctres.I.xJm*fluctres.I.scocurr;
Itotm = fluctres.I.Itotm*fluctres.I.scocurr;
%
info_dke_yp(2,['Total co-current     : ',num2str(Itotm),' +/- ',num2str(abs(fluctres.I.Itots)*fluctres.I.scocurr),' MA, relative unbiased accuracy: ',num2str(abs(fluctres.I.Itotr))]);
info_dke_yp(2,['Total RF power    : ',num2str(fluctres.P.Ptotm),' +/- ',num2str(abs(fluctres.P.Ptots)),' MW, relative unbiased accuracy: ',num2str(abs(fluctres.P.Ptotr))]);
disp(['Rejected simulations (Pin not equal to Pabs within error bars): ',int2str(fluctres.P.iPtotr(:)')]);
%
figure('Name','Time evolution EC current (fluctuation)')
%
if ~isscalar(fluctres.I.xJs), 
    graph1D_jd(fluctres.I.tnI,fluctres.I.tI*fluctres.I.scocurr,0,0,'t\nu_{coll}','I_{lh} co-current (MA)',[],NaN,'','','-','none','r',2,20,gca,1,NaN);
    graph1D_jd(fluctres.I.tnI,fluctres.I.tI*fluctres.I.scocurr,0,0,'t\nu_{coll}','I_{lh} co-current (MA)',[],NaN,'','','-','none','r',2,20,gca,1,NaN);
    graph1D_jd(fluctres.I.tnI(fluctres.I.iItot),fluctres.I.tI(fluctres.I.iItot)*fluctres.I.scocurr,0,0,'t\nu_{coll}','I_{lh} co-current (MA)',[],NaN,'','','none','+','r',2,20,gca,1,NaN);
    graph1D_jd(fluctres.I.tnI(fluctres.I.iItot),Itotm*ones(1,length(tn(fluctres.I.iItot))),0,0,'t\nu_{coll}','I_{lh} (MA)',['I_{tot} = ',num2str(fluctres.I.Itotm),'\pm',num2str(fluctres.I.Itots*fluctres.I.scocurr),' (MA)'],NaN,'','','--','none','r',1,20,gca,1,NaN);
    graph1D_jd(fluctres.I.tnI(fluctres.I.iItot),Itotm*ones(1,length(fluctres.I.iItot)),0,0,'t\nu_{coll}','I_{lh} co-current (MA)',['I_{tot} = ',num2str(fluctres.I.Itotm),'\pm',num2str(fluctres.I.Itots*fluctres.I.scocurr),' (MA)'],NaN,[min(tn),max(tn)],'','none','+','r',1,20,gca,1,NaN,NaN,fluctres.I.Itots*ones(1,length(fluctres.I.iItot)),fluctres.I.Itots*ones(1,length(fluctres.I.iItot)));
    %legend(['t_{fluct}\nu_{coll} = ',num2str(dtn_fluct)],['HWHM_{fluct} = ',num2str(hwhm_npar)]);
    %
    print_jd(p_opt,[id_simul,'_IEC_time'],path_simul);
end
%
figure('Name','Time evolution EC power (fluctuation)')
%
if ~isscalar(fluctres.P.xPs), 
    graph1D_jd(tn,fluctres.P.tP,0,0,'t*\nu_{coll}','P_{lh} (MW)',['P_{tot} = ',num2str(fluctres.P.Ptotm),'\pm',num2str(fluctres.P.Ptots),' (MW)'],NaN,[min(tn),max(tn)],[fluctres.P.Ptotm-10*abs(fluctres.P.Ptots),fluctres.P.Ptotm+10*abs(fluctres.P.Ptots)],'-','none','b',2,20,gca,1,NaN);
    graph1D_jd(tn(fluctres.P.iPtot),fluctres.P.tP(fluctres.P.iPtot),0,0,'t\nu_{coll}','P_{lh} (MW)',['P_{tot} = ',num2str(fluctres.P.Ptotm),'\pm',num2str(fluctres.P.Ptots),' (MW)'],NaN,[min(tn),max(tn)],[fluctres.P.Ptotm-10*abs(fluctres.P.Ptots),fluctres.P.Ptotm+10*abs(fluctres.P.Ptots)],'+','none','b',2,20,gca,1,NaN);
    graph1D_jd(tn,fluctres.P.Ptotm*ones(1,length(tn)),0,0,'t\nu_{coll}','P_{lh} (MW)',['P_{tot} = ',num2str(fluctres.P.Ptotm),'\pm',num2str(fluctres.P.Ptots),' (MW)'],NaN,[min(tn),max(tn)],'','--','none','b',1,20,gca,1,NaN);
    graph1D_jd(tn(fluctres.P.iPtot),fluctres.P.Ptotm*ones(1,length(fluctres.P.iPtot)),0,0,'t\nu_{coll}','P_{lh} (MW)',['P_{tot} = ',num2str(fluctres.P.Ptotm),'\pm',num2str(fluctres.P.Ptots),' (MW)'],NaN,[min(tn),max(tn)],'','none','+','b',1,20,gca,1,NaN,NaN,fluctres.P.Ptots*ones(1,length(fluctres.P.iPtot)),fluctres.P.Ptots*ones(1,length(fluctres.P.iPtot)));
    %
    print_jd(p_opt,[id_simul,'_PEC_time'],path_simul);
end
%
figure('Name','Mean co-current profile (fluctuation)')
%
xJmmax = max(xJm);
rhomax = equilDKE.xrho(xJm == xJmmax);
%
if isscalar(fluctres.I.xJs), 
    graph1D_jd(equilDKE.xrho,xJm,0,0,'\rho','J_{lh} co-current (MA/m^2)',['I_{lh} (co-current) = ',num2str(Itotm),'\pm',num2str(abs(fluctres.I.Itots)*fluctres.I.scocurr),' (MA)'],NaN,'','','-','none','r',2,20,gca,1,NaN);
else
    graph1D_jd(equilDKE.xrho,xJm,0,0,'\rho','J_{lh} co-current (MA/m^2)',['I_{lh} (co-current) = ',num2str(Itotm),'\pm',num2str(abs(fluctres.I.Itots)*fluctres.I.scocurr),' (MA)'],NaN,'','','-','none','r',1,20,gca,1,NaN,NaN,fluctres.I.xJs*fluctres.I.scocurr,fluctres.I.xJs*fluctres.I.scocurr);
    graph1D_jd(equilDKE.xrho,xJm,0,0,'\rho','J_{lh} co-current (MA/m^2)',['I_{lh} (co-current) = ',num2str(Itotm),'\pm',num2str(abs(fluctres.I.Itots)*fluctres.I.scocurr),' (MA)'],NaN,'','','-','none','r',2,20,gca,1,NaN);
    %
    if exist('fit.m','file'),
        index = find(xJm > 1e-5*xJmmax)
        [curve, goodness] = fit(equilDKE.xrho(index)',log(abs(xJm(index)))','poly2');
        fitmax = max(exp(curve.p1*equilDKE.xrho(index).^2 + curve.p2*equilDKE.xrho(index) + curve.p3));
        delta_Jm = 2*sqrt(-log(2)/curve.p1);
        graph1D_jd(equilDKE.xrho(index),xJmmax*exp(curve.p1*equilDKE.xrho(index).^2 + curve.p2*equilDKE.xrho(index) + curve.p3)/fitmax,0,0,'\rho','J_{lh} co-current (MA/m^2)',['I_{lh} (co-current) = ',num2str(Itotm),'\pm',num2str(abs(fluctres.I.Itots)*fluctres.I.scocurr),' (MA)'],NaN,'','','--','none','k',1,20,gca,1,NaN);
        %
        disp(['FWHM of the current density profile = ',num2str(delta_Jm)]);
        disp(['Position of the current density profile = ',num2str(rhomax)]);
    end
end
%
print_jd(p_opt,[id_simul,'_jcocurr_EC_profile'],path_simul);
%
figure('Name','Mean EC power absorption profile (fluctuation)')
%
if isscalar(fluctres.P.xPs),
    graph1D_jd(equilDKE.xrho,fluctres.P.xPm,0,0,'\rho','P_{tot} (MW/m^3)',['P_{tot} = ',num2str(fluctres.P.Ptotm),'\pm',num2str(fluctres.P.Ptots),' (MW)'],NaN,'','','-','none','b',2,20,gca,1,NaN);
else
    graph1D_jd(equilDKE.xrho,fluctres.P.xPm,0,0,'\rho','P_{tot} (MW/m^3)',['P_{tot} = ',num2str(fluctres.P.Ptotm),'\pm',num2str(fluctres.P.Ptots),' (MW)'],NaN,'','','-','none','b',1,20,gca,1,NaN,NaN,fluctres.P.xPs,fluctres.P.xPs);
    graph1D_jd(equilDKE.xrho,fluctres.P.xPm,0,0,'\rho','P_{tot} (MW/m^3)',['P_{tot} = ',num2str(fluctres.P.Ptotm),'\pm',num2str(fluctres.P.Ptots),' (MW)'],NaN,'','','-','none','b',2,20,gca,1,NaN);
end
print_jd(p_opt,[id_simul,'_p_EC_profile'],path_simul);
%