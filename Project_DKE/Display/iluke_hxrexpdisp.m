function [nobj,graphids] = iluke_hxrexpdisp(hxr,sdiags,shotimes,ic,ichord,ibin,axs,style)
%
%       data: [40x19x110 double]
%       time: [1x40 double]
%     energy: [15 25 35 45 55 65 75 85 95 105 115 125 135 145 155 165 175 185 195]
%
camstr = ['Cam #',num2str(hxr.cam{ic}.camnum)];
%
chordsind = hxr.cam{ic}.chordsind;% indices for chords of camera # ic
%
nshotimes = length(shotimes);
%
if iscell(sdiags) && isfield(sdiags{1},'Zbremdiag'),% HXR calculations by LUKE performed,
    %
    lukedata = NaN(nshotimes,length(sdiags{1}.Zbremdiag.kfit),length(chordsind));
    %
    for ishotime = 1:nshotimes,
        lukedata(ishotime,:,:) = reshape(sdiags{ishotime}.Zbremdiag.brem_bd_diag(chordsind,:).',[1,length(sdiags{1}.Zbremdiag.kfit),length(chordsind)]);
    end
    flag_luke = true;
else
    flag_luke = false;
end
%
if isfield(hxr,'exp') && ~isempty(hxr.exp),% experimental data exist
    hxrdata = hxr.exp.data(:,:,chordsind);
    flag_exp = true;
    energy = hxr.exp.energy;
else
    hxrdata = NaN(size(lukedata));
    flag_exp = false;
    energy = sdiags{1}.Zbremdiag.kfit;
end
%
if ~flag_luke,
    lukedata = NaN(size(hxrdata));
end
%
if flag_luke && flag_exp,
    leg = {'Exp.','LUKE'};
else
    leg = NaN;
end
%
if ichord > 0,% display for one chord
    hxrdata = hxrdata(:,:,ichord);
    lukedata = lukedata(:,:,ichord);
    chordstr = ['Chord #',num2str(hxr.cam{ic}.chordsnum(ichord))];
    nchords = 1;
else
    chordsnum = hxr.cam{ic}.chordsnum;
    nchords = length(chordsnum);
end
%
if ibin > 0,% display for one energy
    nbins = 1;
    hxrdata = hxrdata(:,ibin,:);
    lukedata = lukedata(:,ibin,:);
    if ibin < length(energy),
        energystr = [num2str(energy(ibin)),' < k (keV) < ',num2str(energy(ibin + 1))];
    else    
        energystr = ['k (keV) > ',num2str(energy(ibin))];
    end
else
    energyind = find(energy(1:end-1) >= hxr.param.kmin & energy(2:end) <= hxr.param.kmax);
    %
    energysep = [3*energy(1) - energy(2),energy(2:end) + energy(1:end-1),3*energy(end) - energy(end-1)]/2;
    denergy = diff(energysep);
    nbins = length(energy);
    %
    energystr = [num2str(hxr.param.kmin),' < k (keV) < ',num2str(hxr.param.kmax)];
end
%
nobj = [0,0,0];
graphids = {'','',''};
%
if nshotimes > 1,% display time dependence
    %
    timesind = [];
    shotimesmask = false(1,nshotimes);
    timesep = [3*hxr.exp.time(1) - hxr.exp.time(2),hxr.exp.time(2:end) + hxr.exp.time(1:end-1),3*hxr.exp.time(end) - hxr.exp.time(end-1)]/2;
    dt = diff(timesep);
    xlim = [timesep(1),timesep(end)];
    %
    for ishotime = 1:nshotimes,
        it = find(hxr.exp.time == shotimes(ishotime));
        %
        if length(it) == 1,
            timesind = [timesind,it];
            shotimesmask(ishotime) = true;
        end
    end
    %
    shotimes = shotimes(shotimesmask);
    %
    hxrdata = hxrdata(timesind,:,:);
    dt = dt(timesind);
    %
    nt = length(timesind);
    %
    if ichord == 0,% display for all chords
        %
        % TODO
        %
    else% display for one chord
        %
        if ibin == 0,% display for all energies - show global count rate and photon temperature
            %
            Nphotons = repmat(dt,[nbins,1]).*hxrdata.';% number of photons measured per energy bin
            hxrsum = sum(hxrdata(:,energyind),2).';
            ehxrsum = sqrt(hxrsum./dt);
            %
            [Tphexp,eTphexp] = tphfit_dke_yp(repmat(energy(energyind).',[1,nt]),Nphotons(energyind,:),sqrt(Nphotons(energyind,:)));
            Tphmax = 2*Tphexp(find(hxrsum == max(hxrsum),1,'first'));
            if isempty(Tphmax),
                Tphmax = NaN;
            end
            Tphmask = Tphexp > 0 & Tphexp < Tphmax & eTphexp < Tphexp;
            Tphexp(~Tphmask) = NaN;
            eTphexp(~Tphmask) = NaN;
            %
            Nphotons_luke = repmat(dt,[nbins,1]).*lukedata.';% number of photons measured per energy bin
            hxrsum_luke = sum(lukedata(:,energyind),2).';
            ehxrsum_luke = sqrt(hxrsum_luke./dt);
            %
            [Tphluke,eTphluke] = tphfit_dke_yp(repmat(energy(energyind).',[1,nt]),Nphotons_luke(energyind,:),sqrt(Nphotons_luke(energyind,:)));
            Tphmax_luke = 2*Tphluke(find(hxrsum_luke == max(hxrsum_luke),1,'first'));
            if isempty(Tphmax_luke),
                Tphmax_luke = NaN;
            end
            Tphmask_luke = Tphluke > 0 & Tphluke < Tphmax_luke & eTphluke < Tphluke;
            Tphluke(~Tphmask_luke) = NaN;
            eTphluke(~Tphmask_luke) = NaN;
            %
            graph1D_jd(shotimes,Tphexp,0,0,'t (s)','T_{ph.} (keV)','',NaN,xlim,'','-','o','r',2,style,axs(1),1,NaN,NaN,eTphexp);%Poloidal plot
            graph1D_jd(shotimes,Tphluke,0,0,'','','',leg,xlim,'','-','s','b',2,style,axs(1),1,NaN,NaN,eTphluke);%Poloidal plot
            ylim = get(axs(1),'ylim');
            set(axs(1),'ylim',[0,min([ylim(2),Tphmax,Tphmax_luke])]);drawnow
            %
            nobj(1) = 1 + iscell(leg);
            graphids{1} = ['Tph - ',camstr,'; ',chordstr,'; ',energystr];  
            %
            graph1D_jd(shotimes,hxrsum,0,0,'t (s)','CR (Counts/s)','',NaN,xlim,'','-','o','r',2,style,axs(2),1,NaN,NaN,ehxrsum);%Poloidal plot
            graph1D_jd(shotimes,hxrsum_luke,0,0,'','','',leg,xlim,'','-','s','b',2,style,axs(2),1,NaN,NaN,ehxrsum_luke);%Poloidal plot
            %
            nobj(2) = 1 + iscell(leg);
            graphids{2} = ['CR - ',camstr,'; ',chordstr,'; ',energystr];                  
            %
        else% display for one energy - display specific count rate
            %
            ehxrdata = sqrt(hxrdata./dt.');
            elukedata = sqrt(lukedata./dt.');
            %
            graph1D_jd(shotimes,hxrdata,0,0,'t (s)','CR (Counts/s)','',NaN,xlim,'','-','o','r',2,style,axs(1),1,NaN,NaN,ehxrdata);%Poloidal plot
            graph1D_jd(shotimes,lukedata,0,0,'','','',leg,xlim,'','-','s','b',2,style,axs(1),1,NaN,NaN,elukedata);%Poloidal plot
            %
            nobj(1) = 1 + iscell(leg);
            graphids{1} = ['CR - ',camstr,'; ',chordstr,'; ',energystr];  
            %
        end
        %
    end
    %
else% display for one time step
    %
    if flag_exp,
        it = find(hxr.exp.time == shotimes);
        if isempty(it),
            return
        end
    else
        it = 1;
    end
    %
    timestr = ['t = ',num2str(shotimes,'%6.4f')];
    %
    hxrdata = reshape(hxrdata(it,:,:),[nbins,nchords]);
    if flag_luke,
        lukedata = reshape(lukedata,[nbins,nchords]);
    else
        lukedata = reshape(lukedata(it,:,:),[nbins,nchords]);
    end
    %
    if flag_exp,
        CRmin = min(hxrdata(hxrdata(:) > 0));
        %
        dt = 1/CRmin;% assuming a single photon count occured somewhere... to improve from database!
    else
        dt = sdiags{1}.Zbremdiag.dt;
    end
    %
    Nphotons = dt*hxrdata;% number of photons measured per energy bin
    Nphotons_luke = dt*lukedata;% number of photons measured per energy bin
    %
    if ichord == 0,% display for all chords
        %
        xlim = [chordsnum(1) - 1,chordsnum(end)+1];
        %
        if ibin == 0,% display for all energies - show global count rate and photon temperature
            %
            hxrsum = sum(hxrdata(energyind,:),1);
            ehxrsum = sqrt(hxrsum/dt);
            %
            [Tphexp,eTphexp] = tphfit_dke_yp(repmat(energy(energyind).',[1,nchords]),Nphotons(energyind,:),sqrt(Nphotons(energyind,:)));
            Tphmax = 2*Tphexp(find(hxrsum == max(hxrsum),1,'first'));
            if isempty(Tphmax),
                Tphmax = NaN;
            end
            Tphmask = Tphexp > 0 & Tphexp < Tphmax & eTphexp < Tphexp;
            Tphexp(~Tphmask) = NaN;
            eTphexp(~Tphmask) = NaN;
            %
            hxrsum_luke = sum(lukedata(energyind,:),1);
            ehxrsum_luke = sqrt(hxrsum_luke/dt);
            %
            [Tphluke,eTphluke] = tphfit_dke_yp(repmat(energy(energyind).',[1,nchords]),Nphotons_luke(energyind,:),sqrt(Nphotons_luke(energyind,:)));
            Tphmax_luke = 2*Tphluke(find(hxrsum_luke == max(hxrsum_luke),1,'first'));
            if isempty(Tphmax_luke),
                Tphmax_luke = NaN;
            end
            Tphmask_luke = Tphluke > 0 & Tphluke < Tphmax_luke & eTphluke < Tphluke;
            Tphluke(~Tphmask_luke) = NaN;
            eTphluke(~Tphmask_luke) = NaN;
            %
            graph1D_jd(chordsnum,Tphexp,0,0,'chord #','T_{ph.} (keV)','',NaN,xlim,'','-','o','r',2,style,axs(1),1,NaN,NaN,eTphexp);%Poloidal plot
            graph1D_jd(chordsnum,Tphluke,0,0,'','','',leg,xlim,'','-','s','b',2,style,axs(1),1,NaN,NaN,eTphluke);%Poloidal plot
            ylim = get(axs(1),'ylim');
            set(axs(1),'ylim',[0,min([ylim(2),Tphmax,Tphmax_luke])]);drawnow
            %
            nobj(1) = 1 + iscell(leg);
            graphids{1} = ['Tph - ',camstr,'; ',timestr,'; ',energystr];  
            %
            graph1D_jd(chordsnum,hxrsum,0,0,'chord #','CR (Counts/s)','',NaN,xlim,'','-','o','r',2,style,axs(2),1,NaN,NaN,ehxrsum);%Poloidal plot
            graph1D_jd(chordsnum,hxrsum_luke,0,0,'','','',leg,xlim,'','-','s','b',2,style,axs(2),1,NaN,NaN,ehxrsum_luke);%Poloidal plot
            %
            nobj(2) = 1 + iscell(leg);
            graphids{2} = ['CR - ',camstr,'; ',timestr,'; ',energystr];                  
            %
        else% display for one energy - display specific count rate
            %
            ehxrdata = sqrt(hxrdata/dt);
            elukedata = sqrt(lukedata/dt);
            %
            graph1D_jd(chordsnum,hxrdata,0,0,'chord #','CR (Counts/s)','',NaN,xlim,'','-','o','r',2,style,axs(1),1,NaN,NaN,ehxrdata);%Poloidal plot
            graph1D_jd(chordsnum,lukedata,0,0,'','','',leg,xlim,'','-','s','b',2,style,axs(1),1,NaN,NaN,elukedata);%Poloidal plot
            %
            nobj(1) = 1 + iscell(leg);
            graphids{1} = ['CR - ',camstr,'; ',timestr,'; ',energystr];  
            %
        end
        %
    else% display spectrum
        %
        if ibin == 0,% display for all energies - show global count rate and photon temperature
            %
            xlim = [0,max(energysep)];
            %
            [Tphexp,~,Aexp] = tphfit_dke_yp(energy(energyind).',Nphotons(energyind),sqrt(Nphotons(energyind)));
            %
            [Tphluke,~,Aluke] = tphfit_dke_yp(energy(energyind).',Nphotons_luke(energyind),sqrt(Nphotons_luke(energyind)));
            %
            %log(Ei*Ni/dE) = a+b*Ei -> Tph = -1/b
            %
            ehxrdata = sqrt(hxrdata/dt);
            hxrdatafit = Aexp*exp(-energy/Tphexp).*denergy./energy/dt;
            %
            elukedata = sqrt(lukedata/dt);
            lukedatafit = Aluke*exp(-energy/Tphluke).*denergy./energy/dt;
            %
            graph1D_jd(energy,hxrdata,0,1,'k (keV)','CR (Counts/s)','',NaN,xlim,'','none','o','r',2,style,axs(1),1,NaN,NaN,ehxrdata);%Poloidal plot
            graph1D_jd(energy,lukedata,0,1,'','','',leg,xlim,'','none','s','b',2,style,axs(1),1,NaN,NaN,elukedata);%Poloidal plot
            graph1D_jd(energy,hxrdatafit,0,1,'','','',NaN,xlim,'','--','none','r',1,style,axs(1));%Poloidal plot
            graph1D_jd(energy,lukedatafit,0,1,'','','',NaN,xlim,'','--','none','b',1,style,axs(1));%Poloidal plot
            graph1D_jd(hxr.param.kmin*[1,1],get(axs(1),'ylim'),0,1,'','','',NaN,xlim,'','--','none','k',2,style,axs(1));%Poloidal plot
            graph1D_jd(hxr.param.kmax*[1,1],get(axs(1),'ylim'),0,1,'','','',NaN,xlim,'','--','none','k',2,style,axs(1));%Poloidal plot
            %
            nobj(1) = 1 + iscell(leg);
            graphids{1} = ['dCRdE - ',camstr,'; ',timestr,'; ',chordstr];  
            %
        else% display for one energy - display specific count rate
            %
            % TODO
            %
        end
        %
    end
    %
end
%
