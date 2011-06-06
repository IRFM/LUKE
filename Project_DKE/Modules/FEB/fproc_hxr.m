function [hxr_proc,hxr,data_proc] = fproc_hxr(hxr_path,load_id,hxr_file,exp_file,texp,ic,krange,opt,display_mode,p_opt)
%
if nargin < 10,
    p_opt = -1;
end
%
if nargin < 9,
    display_mode = 0;
end
%
if nargin < 8,
    opt.save = 0;
end
%
if nargin < 7,
    krange = NaN;
end
%
if nargin < 6,
    ic = NaN;
end
%
if nargin < 5,
    texp = NaN;
end
%
opt_save_0 = opt.save;
%
dt = diff(texp);
%
basestr = load_id(1:find(load_id == '_',1,'first') - 1);
%
% This function processes (and eventually displays) HXR data
%
%
datafile1 = ['LUKE_RESULTS_',load_id,'.mat'];
datafile2 = ['LUKE_DATA_',load_id,'.mat'];
datafile3 = ['LUKE_BACKUP_',load_id,'.mat'];
proc_datafile1 = ['PROC_',datafile1];
proc_datafile2 = ['PROC_',datafile2];
proc_datafile3 = ['PROC_',datafile3];
hxr_datafile = ['HXR_RESULTS_',load_id,'.mat'];
proc_hxr_datafile = ['PROC_HXR_RESULTS_',load_id,'.mat'];
%
hxrdata = 0;
procdata = 0;
%
hxr = '';
data_proc = '';
hxr_proc = '';
%
if hxrdata == 0 && exist([hxr_path,proc_datafile1],'file'),
    %
    load([hxr_path,proc_datafile1],'data_proc');
    %
    procdata = 1;
    %
    disp(['LUKE data loaded from file ',hxr_path,proc_datafile1])
    %
    if isfield(data_proc,'hxr'),
        hxr = data_proc.hxr;
        opt.save = 0;
        %
        hxrdata = 1;
        %
        disp(['HXR data loaded from file ',hxr_path,proc_datafile1])
        %
    end
    %
    if isstruct(hxr), 
        if ~isfield(hxr,'dt')
            if isnan(dt),
                error('No value found for dt as input or from PROC_RESULT file')
            else
                hxr.dt = dt;
                disp(['Warning : input dt = ',num2str(dt),' enforced, No value found for dt in PROC_RESULT file'])
                if opt_save_0 == 1,
                    opt.save = 1;
                end
            end
        elseif ~isempty(dt) && ~isnan(dt) && abs(dt - hxr.dt)/dt > 1e-2,
            disp(['Warning : input dt = ',num2str(dt),' discarded, PROC_RESULT file dt = ',num2str(hxr.dt),' enforced.'])
        end
    end
    datafile = datafile1;
    %
end
%
if hxrdata == 0 && exist([hxr_path,proc_datafile2],'file'),
    %
    load([hxr_path,proc_datafile2],'data_proc');
    %
    procdata = 1;
    %
    disp(['LUKE data loaded from file ',hxr_path,proc_datafile2])
    %
    if isfield(data_proc,'hxr'),
        hxr = data_proc.hxr;
        opt.save = 0;
        %
        hxrdata = 1;
        %
        disp(['HXR data loaded from file ',hxr_path,proc_datafile2])
        %
    end
    %
    if isstruct(hxr),
        if ~isfield(hxr,'dt')
            if isnan(dt),
                error('No value found for dt as input or from PROC_DATA file')
            else
                hxr.dt = dt;
                disp(['Warning : input dt = ',num2str(dt),' enforced, No value found for dt in PROC_DATA file'])
                if opt_save_0 == 1,
                    opt.save = 1;
                end
            end
        elseif ~isempty(dt) && ~isnan(dt) && abs(dt - hxr.dt)/dt > 1e-2,
            disp(['Warning : input dt = ',num2str(dt),' discarded, PROC_DATA file dt = ',num2str(hxr.dt),' enforced.'])
        end
    end
    datafile = datafile2;
    %
end
%
if hxrdata == 0 && exist([hxr_path,proc_datafile3],'file'),
    %
    load([hxr_path,proc_datafile3],'data_proc');
    %
    procdata = 1;
    %
    disp(['LUKE data loaded from file ',hxr_path,proc_datafile3])
    %
    if isfield(data_proc,'hxr'),
        hxr = data_proc.hxr;
        opt.save = 0;
        %
        hxrdata = 1;
        %
        disp(['HXR data loaded from file ',hxr_path,proc_datafile3])
        %
    end
    %
    if isstruct(hxr),
        if ~isfield(hxr,'dt')
            if isnan(dt),
                error('No value found for dt as input or from PROC_DATA file')
            else
                hxr.dt = dt;
                disp(['Warning : input dt = ',num2str(dt),' enforced, No value found for dt in PROC_DATA file'])
                if opt_save_0 == 1,
                    opt.save = 1;
                end
            end
        elseif ~isempty(dt) && ~isnan(dt) && abs(dt - hxr.dt)/dt > 1e-2,
            disp(['Warning : input dt = ',num2str(dt),' discarded, PROC_DATA file dt = ',num2str(hxr.dt),' enforced.'])
        end
    end
    datafile = datafile3;
    %
end
%
if exist([hxr_path,proc_hxr_datafile],'file'),
    %
    load([hxr_path,proc_hxr_datafile],'hxr');
    %
    if ~isempty(dt) && ~isnan(dt) && abs(dt - hxr.dt)/dt > 1e-2,
        disp(['Warning : input dt = ',num2str(dt),' discarded, HXR file dt = ',num2str(hxr.dt),' enforced.'])
    end
    %
    hxrdata = 1;
    opt.save = 0;
    %
    disp(['HXR data loaded from file ',hxr_path,proc_hxr_datafile])
    %
end
%
if hxrdata == 0 && exist([hxr_path,hxr_datafile],'file'),
    %
    load([hxr_path,hxr_datafile],'Zbremdiag','hxrexp');
    %
    hxr.kfit = Zbremdiag.kfit;
    hxr.brem_bd_plasma = Zbremdiag.brem_bd_plasma;
    hxr.brem_bd_diag = Zbremdiag.brem_bd_diag;
    hxr.dt = Zbremdiag.dt;
    hxr.hxrexp = hxrexp.';
    %
    if ~isempty(dt) && ~isnan(dt) && abs(dt - hxr.dt)/dt > 1e-2,
        disp(['Warning : input dt = ',num2str(dt),' discarded, HXR file dt = ',num2str(hxr.dt),' enforced.'])
    end
    %
    clear Zbremdiag hxrexp dt
    %
    hxrdata = 1;
    datafile = hxr_datafile;
    %
    disp(['HXR data loaded from file ',hxr_path,hxr_datafile])
    %
end
%
if hxrdata == 0 && exist([hxr_path,datafile1],'file'),
    %
    data = load([hxr_path,datafile1]);
    %
    disp(['LUKE data loaded from file ',hxr_path,datafile1])
    %
    if procdata == 0,
        %
        data_proc = proc_luke_jd(data,-1,-1,0.1,NaN,'',opt);
        %
        procdata = 1;
        %
    end
    %
    if isempty(hxr_file),
        error('No HXR spec file specified')
    end
    %
    hxrdata = runhxr_jd(data,basestr,hxr_file,exp_file,hxr_path,texp);
    %
    hxr.kfit = hxrdata.Zbremdiag.kfit;
    hxr.brem_bd_plasma = hxrdata.Zbremdiag.brem_bd_plasma;
    hxr.brem_bd_diag = hxrdata.Zbremdiag.brem_bd_diag;
    hxr.dt = hxrdata.Zbremdiag.dt;
    hxr.hxrexp = hxrdata.hxrexp.';
    %
    if ~isempty(dt) && ~isnan(dt) && abs(dt - hxr.dt)/dt > 1e-2,
        disp(['Warning : input dt = ',num2str(dt),' discarded, PROC_RESULTS file dt = ',num2str(hxr.dt),' enforced.'])
    end
    %
    clear data hxrdata 
    %
    hxrdata = 1;
    datafile = datafile1;
    %
end
%
if hxrdata == 0 && exist([hxr_path,datafile2],'file'),
    %
    data = load([hxr_path,datafile2]);
    %
    disp(['LUKE data loaded from file ',hxr_path,datafile2])
    %
    if procdata == 0,
        %
        data_proc = proc_luke_jd(data.output,-1,-1,0.1,NaN,'',opt);
        %
        procdata = 1;
        %
    end
    %
    if isempty(hxr_file),
        error('No HXR spec file specified')
    end
    %
    hxrdata = runhxr_jd(data,basestr,hxr_file,exp_file,hxr_path,texp);
    %
    hxr.kfit = hxrdata.Zbremdiag.kfit;
    hxr.brem_bd_plasma = hxrdata.Zbremdiag.brem_bd_plasma;
    hxr.brem_bd_diag = hxrdata.Zbremdiag.brem_bd_diag;
    hxr.dt = hxrdata.Zbremdiag.dt;
    hxr.hxrexp = hxrdata.hxrexp.';
    %
    if ~isempty(dt) && ~isnan(dt) && abs(dt - hxr.dt)/dt > 1e-2,
        disp(['Warning : input dt = ',num2str(dt),' discarded, PROC_DATA file dt = ',num2str(hxr.dt),' enforced.'])
    end
    %
    clear data hxrdata 
    %
    hxrdata = 1;
    datafile = datafile2;
    %
end
%
if hxrdata == 0 && exist([hxr_path,datafile3],'file'),
    %
    data = load([hxr_path,datafile3]);
    %
    disp(['LUKE data loaded from file ',hxr_path,datafile3])
    %
    data = proc_backup_jd(data,opt);
    %
    if procdata == 0,
        %
        data_proc = proc_luke_jd(data,-1,-1,0.1,NaN,'',opt);
        %
        procdata = 1;
        %
    end
    %
    if isempty(hxr_file),
        error('No HXR spec file specified')
    end
    %
    hxrdata = runhxr_jd(data,basestr,hxr_file,exp_file,hxr_path,texp);
    %
    hxr.kfit = hxrdata.Zbremdiag.kfit;
    hxr.brem_bd_plasma = hxrdata.Zbremdiag.brem_bd_plasma;
    hxr.brem_bd_diag = hxrdata.Zbremdiag.brem_bd_diag;
    hxr.dt = hxrdata.Zbremdiag.dt;
    hxr.hxrexp = hxrdata.hxrexp.';
    %
    if ~isempty(dt) && ~isnan(dt) && abs(dt - hxr.dt)/dt > 1e-2,
        disp(['Warning : input dt = ',num2str(dt),' discarded, PROC_RESULTS file dt = ',num2str(hxr.dt),' enforced.'])
    end
    %
    clear data hxrdata 
    %
    hxrdata = 1;
    datafile = datafile1;
    %
end
%
if hxrdata == 0,
    disp('Warning : No data found, aborted')
    return
end
%  
if opt.save,
    %
    if procdata == 1,
        %
        data_proc.hxr = hxr;
        %
        save([hxr_path,'PROC_',datafile],'data_proc');
        %
    else
        %
        save([hxr_path,'PROC_',datafile],'hxr');
        %
    end
end
%
nc = length(ic);
%
%dt = hxr.dt;
if strcmp(basestr,'TS'),
    dt = 0.016;%hxr.dt;%sampling time
elseif strcmp(basestr,'TCV'),
    dt = 0.0025;
else
    error('this machine is not implemented yet')
end
%
ikfitmin = find(hxr.kfit >= krange(1),1,'first');
ikfitmax = find(hxr.kfit <= krange(2),1,'last');
ik = ikfitmin:ikfitmax;
nk = length(ik);
%
hxr_proc.k = hxr.kfit;
hxr_proc.ik = ik;
hxr_proc.ic = ic;
hxr_proc.dNdtplasma = hxr.brem_bd_plasma.';
hxr_proc.dNdtdiag = hxr.brem_bd_diag.';
hxr_proc.dNdtexp = hxr.hxrexp.';
%
hxr_proc.dvarplasmak = abs(sum(hxr.brem_bd_plasma(ic,ik)) - sum(hxr.hxrexp(ic,ik)))./abs(sum(hxr.hxrexp(ic,ik)));
hxr_proc.dvarplasma = sqrt(sum(hxr_proc.dvarplasmak.^2))/nk;        
%
hxr_proc.dvardiagk = abs(sum(hxr.brem_bd_diag(ic,ik)) - sum(hxr.hxrexp(ic,ik)))./abs(sum(hxr.hxrexp(ic,ik)));
hxr_proc.dvardiag = sqrt(sum(hxr_proc.dvardiagk.^2))/nk;        
%
[hxr_proc.Tphplasma,hxr_proc.eTphplasma,hxr_proc.Aplasma,hxr_proc.eAplasma,hxr_proc.Qplasma] = ...
    tphfit_dke_yp(repmat(hxr_proc.k(ik).',[1,nc]),dt*hxr.brem_bd_plasma(ic,ik).',sqrt(dt*hxr.brem_bd_plasma(ic,ik)).');
[hxr_proc.Tphdiag,hxr_proc.eTphdiag,hxr_proc.Adiag,hxr_proc.eAdiag,hxr_proc.Qdiag] = ...
    tphfit_dke_yp(repmat(hxr_proc.k(ik).',[1,nc]),dt*hxr.brem_bd_diag(ic,ik).',sqrt(dt*hxr.brem_bd_diag(ic,ik)).');
[hxr_proc.Tphexp,hxr_proc.eTphexp,hxr_proc.Aexp,hxr_proc.eAexp,hxr_proc.Qexp] = ...
    tphfit_dke_yp(repmat(hxr_proc.k(ik).',[1,nc]),dt*hxr.hxrexp(ic,ik).',sqrt(dt*hxr.hxrexp(ic,ik)).');
%
%hxr_proc.icpeak = ic(find(sum(hxr.brem_bd_diag(ic,ik),2) == max(sum(hxr.brem_bd_diag(ic,ik),2)),1,'first'));
hxr_proc.icpeak = ic(find(sum(hxr.brem_bd_plasma(ic,ik),2) == max(sum(hxr.brem_bd_plasma(ic,ik),2)),1,'first'));
%
if display_mode > 0,
    %
    style0 = 'none';
    style = '-';
    style2 = '--';
    marker = 'none';
    marker1 = '+';
    marker2 = 'o';
    marker3 = 's';
    marker4 = '.';
    markers = {marker1,marker2,marker3};
    color = NaN;
    color1 = 'k';
    color2 = 'r';
    color3 = 'b';
    color4 = 'g';
    color5 = 'm';
    color6 = 'c';
    colors = {color2,color3,color4};
    %
    width = 0.5;
    width2 = 2;
    siz = 20+14*1i;
    %
    red = 0.9;
    lspace = 0.7;
    lspace2 = 0.5;
    bspace = 0.7;
    bspace2 = 0.5;
    %
    n1 = 3;
    siz = 14+10*1i;
    %
    k = hxr_proc.k(ik);
    dNdtplasma = hxr_proc.dNdtplasma(ik,ic);
    dNdtdiag = hxr_proc.dNdtdiag(ik,ic);
    dNdtexp = hxr_proc.dNdtexp(ik,ic);
    %
    xlab = 'Chord #';
    xlim = [min(ic)-1,max(ic)+1];
    xtick = 0:5:60;
    %
    xlab2 = 'Photon Energy (keV)';
    xlim2 = [0,2*k(end) - k(end-1)];
    xtick2 = k;
    %
    ylim = NaN;
    %ytick = 0:500:2500;
    %
    %
    figure(1),clf,set(1,'name','profile per channel')
    %
    ylab = 'dN/dt [s^{-1}]';
    leg = {'sim.','exp.'};%{'plasma','diag.','exp.'};%
    n2 = ceil(nk/n1);
    %
    for iik = 1:nk,
        %
        subplot(n1,n2,iik)
        %
        tit = ['Pulse count rate, E=',num2str(k(iik)),' keV'];
        %
        %graph1D_jd(ic,dNdtplasma(iik,:),0,0,'','','',NaN,xlim,ylim,style,marker,color1,width2,siz);
        graph1D_jd(ic,dNdtdiag(iik,:),0,0,'','','',NaN,xlim,ylim,style,marker,color2,width2,siz);
        graph1D_jd(ic,dNdtexp(iik,:),0,0,xlab,ylab,tit,leg,xlim,ylim,style2,marker,color3,width2,siz,gca,red);
        %
        set(gca,'xtick',xtick);
        %set(gca,'ytick',ytick);
        %
    end
    %
    print_jd(p_opt,['Fig_hxrcomp_',load_id],[hxr_path,'figures'],1);
    %  
    %
    figure(2),clf,set(2,'name','spectrum per chord')
    %
    n2 = ceil(nc/n1);
    %
    for iic = 1:nc,
        %
        subplot(n1,n2,iic)
        %
        tit = ['Pulse count rate, chord # ',num2str(ic(iic))];
        %
        %graph1D_jd(k,dNdtplasma(:,iic),0,1,'','','',NaN,xlim2,ylim,style,marker,color1,width2,siz);
        graph1D_jd(k,dNdtdiag(:,iic),0,1,'','','',NaN,xlim2,ylim,style,marker,color2,width2,siz);
        graph1D_jd(k,dNdtexp(:,iic),0,1,xlab2,ylab,tit,leg,xlim2,ylim,style2,marker,color3,width2,siz,gca,red);
        %
        set(gca,'xtick',xtick2);
        %set(gca,'ytick',ytick);
        %
    end
    %
    print_jd(p_opt,['Fig_hxrcomp_spec_',load_id],[hxr_path,'figures'],2);
    %  
    %
    figure(3),clf,set(3,'Name','Count rate')
    %
    kmin = min(k);
    kmax= max(k);
    %
    ylab = ['Count rate (s^{-1}) [',num2str(kmin),' - ',num2str(kmax),' keV]'];
    tit = '';
    %
    %Nplasma = sum(dNdtplasma,1);%Count rate
    Ndiag = sum(dNdtdiag,1);%Count rate
    Nexp = sum(dNdtexp,1);%Count rate
    %
    %graph1D_jd(ic,Nplasma,0,0,'','','',NaN,xlim,ylim,style,marker,color1,width2,siz,gca,1,lspace,bspace,sqrt(Nplasma/dt));
    graph1D_jd(ic,Ndiag,0,0,'','','',NaN,xlim,ylim,style,marker,color2,width2,siz,gca,1,lspace,bspace,sqrt(Ndiag/dt));
    graph1D_jd(ic,Nexp,0,0,xlab,ylab,tit,leg,xlim,ylim,style,marker,color3,width2,siz,gca,red,lspace,bspace,sqrt(Nexp/dt));
    % 
    set(gca,'xtick',xtick);
    %set(gca,'ytick',ytick);
    %
    print_jd(p_opt,['Fig_hxrcomp_tot_',load_id],[hxr_path,'figures'],3);
    %
    %
    figure(4),clf,set(4,'Name','Normalized count rate')
    %
    ylab = 'Normalized count rate';
    ylim = [0,1.2];
    ytick = 0:0.2:1.2;
    %
    %nNplasma = Nplasma/Nplasma(ic == opt.icc);%Count rate
    nNdiag = Ndiag/Ndiag(ic == opt.icc);%Count rate
    nNexp = Nexp/Nexp(ic == opt.icc);%Count rate
    %
    %enNplasma = sqrt(Nplasma/dt)/Nplasma(ic == opt.icc);%Count rate
    enNdiag = sqrt(Ndiag/dt)/Ndiag(ic == opt.icc);%Count rate
    enNexp = sqrt(Nexp/dt)/Nexp(ic == opt.icc);%Count rate
    %
    %graph1D_jd(ic,nNplasma,0,0,'','','',NaN,xlim,ylim,style,marker,color1,width2,siz,gca,1,lspace,bspace,enNplasma);
    graph1D_jd(ic,nNdiag,0,0,'','','',NaN,xlim,ylim,style,marker,color2,width2,siz,gca,1,lspace,bspace,enNdiag);
    graph1D_jd(ic,nNexp,0,0,xlab,ylab,tit,leg,xlim,ylim,style,marker,color3,width2,siz,gca,red,lspace,bspace,enNexp);
    % 
    set(gca,'xtick',xtick);
    %set(gca,'ytick',ytick);
    %
    print_jd(p_opt,['Fig_hxrcomp_norm_',load_id],[hxr_path,'figures'],4);
    %
    %
    figure(5),clf,set(5,'Name','Normalized exp emission')
    %
    Nnorm = dNdtexp.'./repmat(max(dNdtexp.'),[nc,1]);
    eNnorm = sqrt(dNdtexp.'/dt)./repmat(max(dNdtexp.'),[nc,1]);
    %
    for iik = 1:nk,
        leg2{iik} = ['k = ',num2str(k(iik)),' keV'];
    end
    %
    graph1D_jd(repmat(ic.',[1,nk]),Nnorm,0,0,xlab,ylab,tit,leg2,xlim,ylim,...
        style,marker,color,width2,siz,gca,red,lspace,bspace,eNnorm);
    % 
    set(gca,'xtick',xtick);
    set(gca,'ytick',ytick);
    %
    print_jd(p_opt,['Fig_countrate_exp_',load_id],[hxr_path,'figures'],5);
    %
    %
    maskplasma = 1 - hxr_proc.Qplasma < 1e-1;%1e-2;%1e-4;
    maskdiag = 1 - hxr_proc.Qdiag < 1e-1;%1e-2;%1e-4;
    maskexp = 1 - hxr_proc.Qexp < 1e-1;%1e-2;%1e-4;
    %
    figure(6),clf,set(6,'Name','Photon Temperature')
    %
    ylim = [0,max([hxr_proc.Tphplasma(maskplasma),hxr_proc.Tphdiag(maskdiag),hxr_proc.Tphexp(maskexp)])]*1.2;
    %ytick = 0:2:16;
    ylab = ['Photon temperature (keV)'];
    tit = '';
    %
    %
    %graph1D_jd(ic(maskplasma),hxr_proc.Tphplasma(maskplasma),0,0,'','','',NaN,xlim,ylim,style,marker,color1,width2,siz,gca,1,lspace,bspace,hxr_proc.eTphplasma(maskplasma));
    graph1D_jd(ic(maskdiag),hxr_proc.Tphdiag(maskdiag),0,0,'','','',NaN,xlim,ylim,style,marker,color2,width2,siz,gca,1,lspace,bspace,hxr_proc.eTphdiag(maskdiag));
    graph1D_jd(ic(maskexp),hxr_proc.Tphexp(maskexp),0,0,xlab,ylab,tit,leg,xlim,ylim,style,marker,color3,width2,siz,gca,red,lspace,bspace,hxr_proc.eTphexp(maskexp));
    % 
    set(gca,'xtick',xtick);
    %set(gca,'ytick',ytick);
    %
    print_jd(p_opt,['Fig_tph_',load_id],[hxr_path,'figures'],6);
    %
    %
    figure(7),clf,set(7,'Name','Photon Amplitude')
    %
    ylim = [0,max([hxr_proc.Aplasma(maskplasma),hxr_proc.Adiag(maskdiag),hxr_proc.Aexp(maskexp)])]*1.2;
    ylab = ['Emission Amplitude'];
    tit = '';
    %
    %
    %graph1D_jd(ic(maskplasma),hxr_proc.Aplasma(maskplasma),0,0,'','','',NaN,xlim,ylim,style,marker,color1,width2,siz,gca,1,lspace,bspace,hxr_proc.eAplasma(maskplasma));
    graph1D_jd(ic(maskdiag),hxr_proc.Adiag(maskdiag),0,0,'','','',NaN,xlim,ylim,style,marker,color2,width2,siz,gca,1,lspace,bspace,hxr_proc.eAdiag(maskdiag));
    graph1D_jd(ic(maskexp),hxr_proc.Aexp(maskexp),0,0,xlab,ylab,tit,leg,xlim,ylim,style,marker,color3,width2,siz,gca,red,lspace,bspace,hxr_proc.eAexp(maskexp));
    % 
    set(gca,'xtick',xtick);
    %set(gca,'ytick',ytick);
    %
    print_jd(p_opt,['Fig_A_',load_id],[hxr_path,'figures'],7);
    %
    %
    figure(8),clf,set(8,'name','spectrum for central chord')
    %
    ylab = 'dN/dt [s^{-1}]';
    %ymin = floor(min(log10([dNdtplasma(:,ic == opt.icc);dNdtdiag(:,ic == opt.icc);dNdtexp(:,ic == opt.icc)])));
    %ymax =  ceil(max(log10([dNdtplasma(:,ic == opt.icc);dNdtdiag(:,ic == opt.icc);dNdtexp(:,ic == opt.icc)])));
    %
    ylim = NaN;%[ymin,ymax];
%     ytick = ymin:ymax;
%     yticklabel = cell(1,length(ytick));
%     for iy = 1:length(ytick),
%         yticklabel{iy} = ['10^{',num2str(ytick(iy)),'}'];
%     end
    %
    tit = ['Pulse count rate, chord # ',num2str(opt.icc)];
    %
    %graph1D_jd(k,dNdtplasma(:,ic == opt.icc),0,1,'','','',NaN,xlim2,ylim,style,marker,color1,width2,siz,gca,1,lspace,bspace,sqrt(dNdtplasma(:,ic == opt.icc)/dt));
    graph1D_jd(k,dNdtdiag(:,ic == opt.icc),0,0,'','','',NaN,xlim2,ylim,style,marker,color2,width2,siz,gca,1,lspace,bspace,sqrt(dNdtdiag(:,ic == opt.icc)/dt));
    graph1D_jd(k,dNdtexp(:,ic == opt.icc),0,0,xlab2,ylab,tit,leg,xlim2,ylim,style2,marker,color3,width2,siz,gca,red,lspace,bspace,sqrt(dNdtexp(:,ic == opt.icc)/dt));
    %
    set(gca,'xtick',xtick2);
    %set(gca,'ytick',ytick);
    %set(gca,'yticklabel',yticklabel)
    %
    print_jd(p_opt,['Fig_hxrcomp_central_',load_id],[hxr_path,'figures'],8);
    %  
    %
end
