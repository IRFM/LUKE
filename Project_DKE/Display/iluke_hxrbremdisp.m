function [nobj,graphids] = iluke_hxrbremdisp(shotimes,sdiags,ikphot,irho,itheta,idir,axs,select)
%
%       data: [40x19x110 double]
%       time: [1x40 double]
%     energy: [15 25 35 45 55 65 75 85 95 105 115 125 135 145 155 165 175 185 195]
%
% camstr = ['Cam #',num2str(hxr.cam{ic}.camnum)];
% %
% chordsind = hxr.cam{ic}.chordsind;% indices for chords of camera # ic
% %
% hxrdata = hxr.exp.data(:,:,chordsind);
% %
% if ichord > 0,% display for one chord
%     hxrdata = hxrdata(:,:,ichord);
%     chordstr = ['Chord #',num2str(hxr.cam{ic}.chordsnum(ichord))];
%     nchords = 1;
% else
%     chordsnum = hxr.cam{ic}.chordsnum;
%     nchords = length(chordsnum);
% end
% %
% if ibin > 0,% display for one energy
%     nbins = 1;
%     hxrdata = hxrdata(:,ibin,:);
%     if ibin < length(hxr.exp.energy),
%         energystr = [num2str(hxr.exp.energy(ibin)),' < k (keV) < ',num2str(hxr.exp.energy(ibin + 1))];
%     else    
%         energystr = ['k (keV) > ',num2str(hxr.exp.energy(ibin))];
%     end
% else
%     energyind = find(hxr.exp.energy(1:end-1) >= hxr.param.kmin & hxr.exp.energy(2:end) <= hxr.param.kmax);
%     %
%     energy = hxr.exp.energy;
%     energysep = [3*energy(1) - energy(2),energy(2:end) + energy(1:end-1),3*energy(end) - energy(end-1)]/2;
%     denergy = diff(energysep);
%     nbins = length(energy);
%     %
%     energystr = [num2str(hxr.param.kmin),' < k (keV) < ',num2str(hxr.param.kmax)];
% end
%
nshotimes = length(shotimes);
%
nobj = [0,0,0];
graphids = {'','',''};
%
if nshotimes > 1,% display time dependence
    %
%     timesind = [];
%     shotimesmask = false(1,nshotimes);
%     timesep = [3*hxr.exp.time(1) - hxr.exp.time(2),hxr.exp.time(2:end) + hxr.exp.time(1:end-1),3*hxr.exp.time(end) - hxr.exp.time(end-1)]/2;
%     dt = diff(timesep);
%     xlim = [timesep(1),timesep(end)];
%     %
%     for ishotime = 1:nshotimes,
%         it = find(hxr.exp.time == shotimes(ishotime));
%         %
%         if length(it) == 1,
%             timesind = [timesind,it];
%             shotimesmask(ishotime) = true;
%         end
%     end
%     %
%     shotimes = shotimes(shotimesmask);
%     %
%     hxrdata = hxrdata(timesind,:,:);
%     dt = dt(timesind);
%     %
%     nt = length(timesind);
%     %
%     if ichord == 0,% display for all chords
%         %
%         % TODO
%         %
%     else% display for one chord
%         %
%         if ibin == 0,% display for all energies - show global count rate and photon temperature
%             %
%             Nphotons = repmat(dt,[nbins,1]).*hxrdata.';% number of photons measured per energy bin
%             %
%             hxrsum = sum(hxrdata(:,energyind),2).';
%             ehxrsum = sqrt(hxrsum./dt);
%             %
%             [Tphexp,eTphexp] = tphfit_dke_yp(repmat(energy(energyind).',[1,nt]),Nphotons(energyind,:),sqrt(Nphotons(energyind,:)));
%             Tphmax = 2*Tphexp(find(hxrsum == max(hxrsum),1,'first'));
%             Tphmask = Tphexp > 0 & Tphexp < Tphmax & eTphexp < Tphexp;
%             Tphexp(~Tphmask) = NaN;
%             eTphexp(~Tphmask) = NaN;
%             %
%             graph1D_jd(shotimes,Tphexp,0,0,'t (s)','T_{ph.} (keV)','',NaN,xlim,'','-','o','r',2,style,axs(1),1,NaN,NaN,eTphexp);%Poloidal plot
%             ylim = get(axs(1),'ylim');
%             if ~isnan(Tphmax),
%                 set(axs(1),'ylim',[0,min([ylim(2),Tphmax])]);drawnow
%             end
%             %
%             nobj(1) = 1;
%             graphids{1} = ['Tph - ',camstr,'; ',chordstr,'; ',energystr];  
%             %
%             graph1D_jd(shotimes,hxrsum,0,0,'t (s)','CR (Counts/s)','',NaN,xlim,'','-','o','r',2,style,axs(2),1,NaN,NaN,ehxrsum);%Poloidal plot
%             %
%             nobj(2) = 1;
%             graphids{2} = ['CR - ',camstr,'; ',chordstr,'; ',energystr];                  
%             %
%         else% display for one energy - display specific count rate
%             %
%             ehxrdata = sqrt(hxrdata./dt.');
%             %
%             graph1D_jd(shotimes,hxrdata,0,0,'t (s)','CR (Counts/s)','',NaN,xlim,'','-','o','r',2,style,axs(1),1,NaN,NaN,ehxrdata);%Poloidal plot
%             %
%             nobj(1) = 1;
%             graphids{1} = ['CR - ',camstr,'; ',chordstr,'; ',energystr];  
%             %
%         end
%         %
%     end
    %
else% display for one time step
    %
    timestr = ['t = ',num2str(shotimes,'%6.4f')];
    Zbremplasma = sdiags{1}.Zbremplasma;
    equilHXR = sdiags{1}.equilHXR;
    %
    [nrho,ntheta] = size(Zbremplasma.theta_hxr);
    %
    bremdata = {Zbremplasma.brem_forward,Zbremplasma.brem_backward,Zbremplasma.brem_perp,Zbremplasma.brem_4pi};
    %
    if ikphot == 0,
        %
        
        %
    else
        %
        kphotstr = ['Photon energy k = ',num2str(Zbremplasma.kphot(ikphot)),' keV'];
        %
        if idir == 0,
            %
            

            %
        else% plot 2D FEB for a given energy and direction
            %
            dirstr = [select.dir{1 + idir},' direction'];
            %
            if irho == 0 && itheta == 0,
                %
                bremdisp = NaN(nrho,ntheta+1);
                %
                for ir = 1:nrho,
                    for it = 1:ntheta,
                        bremdisp(ir,it) = bremdata{idir}{ir,it}(ikphot);
                    end
                end
                %
                bremdisp(:,end) = bremdisp(:,1);% for better plot
                %
                graph2D_jd(equilHXR.Xx,equilHXR.Xy,bremdisp.','x','y','',NaN,NaN,1,NaN,NaN,0,'-',NaN,0.5,select.style,1,NaN,axs(1));
                axis(axs(1),'equal');
                %
                nobj(1) = 1;
                graphids{1} = ['FEB - 2D ',timestr,'; ',dirstr,'; ',kphotstr];  
                %
            elseif irho == 0 && itheta > 0,
                %
                thetastr = ['theta = ',num2str(equilHXR.mtheta(itheta))*180/pi,' deg.'];
                %
                bremdisp = NaN(1,nrho);
                %
                for ir = 1:nrho,
                    bremdisp(ir) = bremdata{idir}{ir,itheta}(ikphot);
                end
                %
                graph1D_jd(equilHXR.xrhoT,bremdisp,0,0,'r/a','emissivity (ph. s^{-1} keV^{-1} st^{-1})','',NaN,NaN,NaN,'-','o','r',2,select.style,axs(1));
                %
                nobj(1) = 1;
                graphids{1} = ['FEB - rho ',timestr,'; ',dirstr,'; ',kphotstr,'; ',thetastr];  
                %                
            elseif irho > 0 && itheta == 0,
                %
                rhostr = ['rho = ',num2str(equilHXR.xrhoT)];
                %
                bremdisp = NaN(1,ntheta+1);
                %
                for it = 1:ntheta,
                    bremdisp(it) = bremdata{idir}{irho,it}(ikphot);
                end
                %
                bremdisp(end) = bremdisp(1);% for better plot
                %
                graph1D_jd(equilHXR.mtheta,bremdisp,0,0,'\theta (deg.)','emissivity (ph. s^{-1} keV^{-1} st^{-1})','',NaN,NaN,NaN,'-','o','r',2,select.style,axs(1));
                %
                nobj(1) = 1;
                graphids{1} = ['FEB - theta ',timestr,'; ',dirstr,'; ',kphotstr,'; ',rhostr];  
                %                
            end
            %
        end
        % 
    end
    
    
%     hxrdata = reshape(hxrdata(it,:,:),[nbins,nchords]);
%     %
%     CRmin = min(hxrdata(hxrdata(:) > 0));
%     %
%     dt = 1/CRmin;% assuming a single photon count occured somewhere... to improve from database!
%     %
%     Nphotons = dt*hxrdata;% number of photons measured per energy bin
%     %
%     if ichord == 0,% display for all chords
%         %
%         xlim = [chordsnum(1) - 1,chordsnum(end)+1];
%         %
%         if ibin == 0,% display for all energies - show global count rate and photon temperature
%             %
%             hxrsum = sum(hxrdata(energyind,:),1);
%             %
%             ehxrsum = sqrt(hxrsum/dt);
%             %
%             [Tphexp,eTphexp] = tphfit_dke_yp(repmat(energy(energyind).',[1,nchords]),Nphotons(energyind,:),sqrt(Nphotons(energyind,:)));
%             Tphmax = 2*Tphexp(find(hxrsum == max(hxrsum),1,'first'));
%             Tphmask = Tphexp > 0 & Tphexp < Tphmax & eTphexp < Tphexp;
%             Tphexp(~Tphmask) = NaN;
%             eTphexp(~Tphmask) = NaN;
%             %
%             graph1D_jd(chordsnum,Tphexp,0,0,'chord #','T_{ph.} (keV)','',NaN,xlim,'','-','o','r',2,style,axs(1),1,NaN,NaN,eTphexp);%Poloidal plot
%             ylim = get(axs(1),'ylim');
%             if ~isnan(Tphmax),
%                 set(axs(1),'ylim',[0,min([ylim(2),Tphmax])]);drawnow
%             end
%             %
%             nobj(1) = 1;
%             graphids{1} = ['Tph - ',camstr,'; ',timestr,'; ',energystr];  
%             %
%             graph1D_jd(chordsnum,hxrsum,0,0,'chord #','CR (Counts/s)','',NaN,xlim,'','-','o','r',2,style,axs(2),1,NaN,NaN,ehxrsum);%Poloidal plot
%             %
%             nobj(2) = 1;
%             graphids{2} = ['CR - ',camstr,'; ',timestr,'; ',energystr];                  
%             %
%         else% display for one energy - display specific count rate
%             %
%             ehxrdata = sqrt(hxrdata/dt);
%             %
%             graph1D_jd(chordsnum,hxrdata,0,0,'chord #','CR (Counts/s)','',NaN,xlim,'','-','o','r',2,style,axs(1),1,NaN,NaN,ehxrdata);%Poloidal plot
%             %
%             nobj(1) = 1;
%             graphids{1} = ['CR - ',camstr,'; ',timestr,'; ',energystr];  
%             %
%         end
%         %
%     else% display spectrum
%         %
%         if ibin == 0,% display for all energies - show global count rate and photon temperature
%             %
%             xlim = [0,max(energysep)];
%             %
%             [Tphexp,~,Aexp] = tphfit_dke_yp(energy(energyind).',Nphotons(energyind),sqrt(Nphotons(energyind)));
%             %
%             %log(Ei*Ni/dE) = a+b*Ei -> Tph = -1/b
%             %
%             ehxrdata = sqrt(hxrdata/dt);
%             %
%             hxrdatafit = Aexp*exp(-energy/Tphexp).*denergy./energy/dt;
%             %
%             graph1D_jd(energy,hxrdata,0,1,'k (keV)','CR (Counts/s)','',NaN,xlim,'','-','o','r',2,style,axs(1),1,NaN,NaN,ehxrdata);%Poloidal plot
%             graph1D_jd(energy,hxrdatafit,0,1,'','','',NaN,xlim,'','-','none','b',1,style,axs(1));%Poloidal plot
%             graph1D_jd(hxr.param.kmin*[1,1],get(axs(1),'ylim'),0,1,'','','',NaN,xlim,'','--','none','k',2,style,axs(1));%Poloidal plot
%             graph1D_jd(hxr.param.kmax*[1,1],get(axs(1),'ylim'),0,1,'','','',NaN,xlim,'','--','none','k',2,style,axs(1));%Poloidal plot
%             %
%             nobj(1) = 1;
%             graphids{1} = ['dCRdE - ',camstr,'; ',timestr,'; ',chordstr];  
%             %
%         else% display for one energy - display specific count rate
%             %
%             % TODO
%             %
%         end
%         %
%     end
end
%
