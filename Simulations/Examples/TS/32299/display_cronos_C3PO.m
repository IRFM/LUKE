function [] = display_cronos_C3PO(id_simul,equilDKE,ZP0,Zcurr,dkeparam,mksa,itnmin,racc,p_opt,remote,rootdir)
%
if nargin == 6, 
    itnmin = 1;
    racc = 0.05;
    p_opt = 0;
    remote = 0;
    rootdir = [pwd,'/'];
elseif nargin == 7,
    racc = 0.05;
    p_opt = 0;
    remote = 0;
    rootdir = [pwd,'/'];
elseif nargin == 8,
    p_opt = 0;
    remote = 0;
    rootdir = [pwd,'/'];
elseif nargin == 9,
    remote = 0;
    rootdir = [pwd,'/'];
elseif nargin == 10,
    rootdir = [pwd,'/'];
end
%
if isempty(p_opt), p_opt = 0;end
%
if remote,
    if strcmp(computer,'MACI64') & strfind(dkeparam.path_simul,'/local/peysson/Simulations/Yves/DKE/FLUCT/')
        path_simul = dkeparam.path_simul(length('/local/peysson/Simulations/Yves/DKE/FLUCT/')+1:end);%calculations done on cephee and display done on macbook or elsewhere locally
    elseif strcmp(computer,'GLNXA64') & ~strfind(dkeparam.path_simul,'/local/peysson/Simulations/Yves/DKE/FLUCT/')
        path_simul = ['/local/peysson/Simulations/Yves/DKE/FLUCT/',dkeparam.path_simul];%calculations done on macbook or elsewhere locally and display done on cephee
    else
        path_simul = dkeparam.path_simul;%calculations and display done on the same machine
    end
else
    path_simul = dkeparam.path_simul;%local
end
%
path_simul = [rootdir,path_simul];
%
if ~exist(path_simul) == 7,
    disp(['WARNING: the directory ',path_simul,' must exist before launching the display program.'])
end
%
if ~isempty(itnmin),%fluctuation case
    [tn,tn_all,fluctres] = fluctanalysis_yp(equilDKE,ZP0,Zcurr,dkeparam,mksa,racc,itnmin);
    %
    diary_file = ['LUKE_DIARY_',id_simul,'.mat'];
    diary([path_simul,diary_file])
    diary on;
    %
    info_dke_yp(2,['Total co-current     : ',num2str(fluctres.I.Itotm*fluctres.I.scocurr),' +/- ',num2str(abs(fluctres.I.Itots)*fluctres.I.scocurr),' MA, relative unbiased accuracy: ',num2str(abs(fluctres.I.Itotr))]);
    info_dke_yp(2,['Total RF power    : ',num2str(fluctres.P.Ptotm),' +/- ',num2str(abs(fluctres.P.Ptots)),' MW, relative unbiased accuracy: ',num2str(abs(fluctres.P.Ptotr))]);
    disp(['Rejected simulations (Pin not equal to Pabs within error bars): ',int2str(fluctres.P.iPtotr(:)'),', index offset: ',int2str(itnmin - 1)]);
    %
    diary off;
    %
    h = figure('Name','Time evolution LH current (fluctuation)');
    %
    if ~isscalar(fluctres.I.xJs), 
        graph1D_jd(fluctres.I.tnI_all,fluctres.I.tI_all*fluctres.I.scocurr,0,0,'t\nu_{coll}','I_{lh} co-current (MA)',[],NaN,'','','-','none','r',1,20,gca,1,NaN,NaN);
        graph1D_jd(fluctres.I.tnI,fluctres.I.tI*fluctres.I.scocurr,0,0,'t\nu_{coll}','I_{lh} co-current (MA)',[],NaN,'','','-','none','r',2,20,gca,1,NaN,NaN);
        graph1D_jd(fluctres.I.tnI,fluctres.I.tI*fluctres.I.scocurr,0,0,'t\nu_{coll}','I_{lh} co-current (MA)',[],NaN,'','','-','none','r',2,20,gca,1,NaN,NaN);
        graph1D_jd(fluctres.I.tnI(fluctres.I.iItot),fluctres.I.tI(fluctres.I.iItot)*fluctres.I.scocurr,0,0,'t\nu_{coll}','I_{lh} co-current (MA)',[],NaN,'','','none','+','r',2,20,gca,1,NaN,NaN);
        graph1D_jd(fluctres.I.tnI(fluctres.I.iItot),fluctres.I.Itotm*fluctres.I.scocurr*ones(1,length(tn(fluctres.I.iItot))),0,0,'t\nu_{coll}','I_{lh} (MA)',['I_{tot} = ',num2str(fluctres.I.Itotm),'\pm',num2str(fluctres.I.Itots*fluctres.I.scocurr),' (MA)'],NaN,'','','--','none','r',1,20,gca,1,NaN,NaN);
        graph1D_jd(fluctres.I.tnI(fluctres.I.iItot),fluctres.I.Itotm*fluctres.I.scocurr*ones(1,length(fluctres.I.iItot)),0,0,'t\nu_{coll}','I_{lh} co-current (MA)',['I_{tot} = ',num2str(fluctres.I.Itotm),'\pm',num2str(fluctres.I.Itots*fluctres.I.scocurr),' (MA)'],NaN,[min(tn_all),max(tn_all)],'','none','+','r',1,20,gca,1,NaN,NaN,fluctres.I.Itots*ones(1,length(fluctres.I.iItot)),fluctres.I.Itots*ones(1,length(fluctres.I.iItot)));
        %
        print_jd(p_opt,[id_simul,'_ILH_time'],path_simul,h);
    end
    %
    h = figure('Name','Time evolution LH power (fluctuation)');
    %
    if ~isscalar(fluctres.P.xPs), 
        graph1D_jd(fluctres.P.tnP_all,fluctres.P.tP_all,0,0,'t*\nu_{coll}','P_{lh} (MW)',['P_{tot} = ',num2str(fluctres.P.Ptotm),'\pm',num2str(fluctres.P.Ptots),' (MW)'],NaN,'','','-','none','b',1,20,gca,1,NaN);
        graph1D_jd(tn,fluctres.P.tP,0,0,'t*\nu_{coll}','P_{lh} (MW)',['P_{tot} = ',num2str(fluctres.P.Ptotm),'\pm',num2str(fluctres.P.Ptots),' (MW)'],NaN,[min(tn),max(tn)],'','-','none','b',2,20,gca,1,NaN);
        graph1D_jd(tn(fluctres.P.iPtot),fluctres.P.tP(fluctres.P.iPtot),0,0,'t\nu_{coll}','P_{lh} (MW)',['P_{tot} = ',num2str(fluctres.P.Ptotm),'\pm',num2str(fluctres.P.Ptots),' (MW)'],NaN,[min(tn),max(tn)],'','+','none','b',2,20,gca,1,NaN,NaN);
        graph1D_jd(tn,fluctres.P.Ptotm*ones(1,length(tn)),0,0,'t\nu_{coll}','P_{lh} (MW)',['P_{tot} = ',num2str(fluctres.P.Ptotm),'\pm',num2str(fluctres.P.Ptots),' (MW)'],NaN,[min(tn),max(tn)],'','--','none','b',1,20,gca,1,NaN);
        graph1D_jd(tn(fluctres.P.iPtot),fluctres.P.Ptotm*ones(1,length(fluctres.P.iPtot)),0,0,'t\nu_{coll}','P_{lh} (MW)',['P_{tot} = ',num2str(fluctres.P.Ptotm),'\pm',num2str(fluctres.P.Ptots),' (MW)'],NaN,[min(tn_all),max(tn_all)],'','none','+','b',1,20,gca,1,NaN,NaN,fluctres.P.Ptots*ones(1,length(fluctres.P.iPtot)),fluctres.P.Ptots*ones(1,length(fluctres.P.iPtot)));
        %
        print_jd(p_opt,[id_simul,'_PLH_time'],path_simul,h);
    end
    %
    h = figure('Name','Mean co-current profile (fluctuation)');
    %
    if isscalar(fluctres.I.xJs), 
        graph1D_jd(equilDKE.xrho,fluctres.I.xJm*fluctres.I.scocurr,0,0,'\rho','J_{lh} co-current (MA/m^2)',['I_{lh} (co-current) = ',num2str(fluctres.I.Itotm*fluctres.I.scocurr),'\pm',num2str(abs(fluctres.I.Itots)*fluctres.I.scocurr),' (MA)'],NaN,'','','-','none','r',2,20,gca,1,NaN,NaN);
    else
        graph1D_jd(equilDKE.xrho,fluctres.I.xJm*fluctres.I.scocurr,0,0,'\rho','J_{lh} co-current (MA/m^2)',['I_{lh} (co-current) = ',num2str(fluctres.I.Itotm*fluctres.I.scocurr),'\pm',num2str(abs(fluctres.I.Itots)*fluctres.I.scocurr),' (MA)'],NaN,'','','-','none','r',2,20,gca,1,NaN,NaN,fluctres.I.xJs*fluctres.I.scocurr,fluctres.I.xJs*fluctres.I.scocurr);
    end
    legend(['\Deltat*\nu_{coll} = [',num2str(min(tn)),',',num2str(max(tn)),']'])
    %
    print_jd(p_opt,[id_simul,'_jcocurr_LH_profile'],path_simul);
    %
    h = figure('Name','Mean LH power absorption profile (fluctuation)');
    %
    if isscalar(fluctres.P.xPs),
        graph1D_jd(equilDKE.xrho,fluctres.P.xPm,0,0,'\rho','P_{tot} (MW/m^3)',['P_{tot} = ',num2str(fluctres.P.Ptotm),'\pm',num2str(fluctres.P.Ptots),' (MW)'],NaN,'','','-','none','b',2,20,gca,1,NaN,NaN);
    else
        graph1D_jd(equilDKE.xrho,fluctres.P.xPm,0,0,'\rho','P_{tot} (MW/m^3)',['P_{tot} = ',num2str(fluctres.P.Ptotm),'\pm',num2str(fluctres.P.Ptots),' (MW)'],NaN,'','','-','none','b',2,20,gca,1,NaN,NaN,fluctres.P.xPs,fluctres.P.xPs);
    end
    legend(['\Deltat*\nu_{coll} = [',num2str(min(tn)),',',num2str(max(tn)),']'])
    %
    print_jd(p_opt,[id_simul,'_p_LH_profile'],path_simul,h);
    %
else
    h = figure('Name','Co-current profile (no fluctuation)');
    %
    I_tot = sum(Zcurr.x_0_fsav.*equilDKE.xdA_dke*mksa.j_ref);
    graph1D_jd(equilDKE.xrho,Zcurr.x_0_fsav*mksa.j_ref,0,0,'\rho','J_{tot} (MA/m^2)',['Tore Supra,I_{tot} = ',num2str(I_tot),' (MA)'],NaN,'','','-','none','r',2);drawnow
    %
    print_jd(p_opt,[id_simul,'_jcocurr_LH_profile'],path_simul);
    %
    h = figure('Name','LH power absorption profile (no fluctuation)');
    %
    PLH_tot = sum(ZP0.x_rf_fsav.*equilDKE.xdV_2piRp_dke(:)*mksa.P_ref*2*pi*equilDKE.Rp);
    graph1D_jd(equilDKE.xrho,ZP0.x_rf_fsav*mksa.P_ref,0,0,'\rho','P_{LH} (MW/m^3)',['Tore Supra,P_{LH} = ',num2str(PLH_tot),' (MW)'],NaN,'','','-','none','r',2);drawnow
    %
    print_jd(p_opt,[id_simul,'_p_LH_profile'],path_simul,h);  
end

