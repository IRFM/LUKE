function fproc_fluctn_Nscan(p_opt,id_equil,id_fluct,id_wave,sigmar_max,sigmar_hwhm,Nfluct_list,tn,dtn)
%
%
id_simul0 = [id_equil,'_',id_wave,'_',id_fluct];
%
nfluct = length(Nfluct_list);
%
for ifluct = 1:nfluct,
    %
    Nfluct = Nfluct_list(ifluct);
    %
    id_simul = [id_simul0,'_sigma',num2str(sigmar_max),'_delta',num2str(sigmar_hwhm),'_dtn',num2str(dtn),'_tn',num2str(tn),'_Nfluct',num2str(Nfluct)];
    id_simul(id_simul == '.') = 'p';
    %
    filename = ['LUKE_RESULTS_',id_simul,'.mat'];
    %
    if exist(filename,'file'),
        %
        data = load(filename,'Zcurr','ZP0','equilDKE','mksa');
        %
        ztn{ifluct} = data.Zcurr.xtn;
        zJ{ifluct} = data.Zcurr.t_x_0_fsav*data.mksa.j_ref;
        zP{ifluct} = data.ZP0.t_x_rf_fsav*data.mksa.P_ref;
        zI_tot{ifluct} = zJ{ifluct}*data.equilDKE.xdA_dke.';
        zP_rf{ifluct} = zP{ifluct}*data.equilDKE.xdV_2piRp_dke.'*data.equilDKE.Rp;
        %
        [tnfluct,tnfluct_all,fluctres] = fluctanalysis_yp(data.equilDKE,data.ZP0,data.Zcurr,'',data.mksa,0);
        %
        ztnfluct{ifluct} = tnfluct;
        ztnfluct_all{ifluct} = tnfluct_all;
        zfluctres{ifluct} = fluctres;
        %
    else
    end
end
%