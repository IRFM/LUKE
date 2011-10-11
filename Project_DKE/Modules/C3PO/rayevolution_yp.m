function [P0] = rayevolution_yp(wavetype,equil_fit,waves,mode,rho_S,itn)
%
% Analysis of the ray dynamics and the power spectrum (check is the
% spectral gap is filled
%
% INPUT
%    - wavetype: wave type (0 -> LH, 1 -> EC, 2 ->...). May be in between if different waves types are launched into the plasma
%    - equil_fit: interpolated magnetic equilibrium structure
%    - waves: wave structure
%    - mode: 1 -> the first wave is without fluctuations, 0 -> no distinction is done between rays [1,1]
%    - itn: iteration number (optional) [1,1]
%
% OUTPUT:
%    - P0: total rf power (MW) [1,1]
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
if nargin < 2,
    error('Wrong number of input arguments in rayevolution_yp.m.');
end
%
if nargin < 3,
    mode = 0;
    rho_S = linspace(0,1,20);
    itn = -1;
end
%
if nargin < 4,
    rho_S = linspace(0,1,20);
    itn = -1;
end
%
if nargin < 5,
    itn = -1; 
end
%
Rp = equil_fit.Rp;
%
nw = length(waves);
nr = ones(1,nw);
%
for iw = 1:nw,nr(iw) = length(waves{iw}.rays);end
%
nparbin = [-10:0.1:10];
hr = zeros(length(rho_S)-1,length(nparbin));
hr_nofluct = zeros(length(rho_S)-1,length(nparbin));
rho = (rho_S(1:end-1) + rho_S(2:end))/2;
P0 = 0;
%
%
if itn > 0,
    figure('Name',['Ray dynamics, itn = ',int2str(itn)]),
    title_fig = ['Ray evolution, iteration = ',int2str(itn)];
else
    figure('Name','Ray dynamics'),
    title_fig = 'Ray evolution';
end
%
for iw = 1:nw,
    for ir = 1:nr(iw),
        if iw == 1 & mode == 1,
            graph1D_jd(waves{iw}.rays{ir}.ss,real(waves{iw}.rays{ir}.sNpar),0,0,'Ray length','N_{||}',[],NaN,'',[nparbin(1),nparbin(end)],'-','none','g',2);
            if ~wavetype == 1,
                graph1D_jd(waves{iw}.rays{ir}.ss,sign(real(waves{iw}.rays{ir}.sNpar(1)))*6.5./sqrt(waves{iw}.rays{ir}.sTe),0,0,'Ray length (m)','N_{||}',title_fig,NaN,'',[nparbin(1),nparbin(end)],'-','none','r',2);        
            end
        else
            graph1D_jd(waves{iw}.rays{ir}.ss,real(waves{iw}.rays{ir}.sNpar),0,0,'Ray length','N_{||}',[],NaN,'',[nparbin(1),nparbin(end)],'-','none','b',0.5);
            if ~wavetype == 1,
                graph1D_jd(waves{iw}.rays{ir}.ss,sign(real(waves{iw}.rays{ir}.sNpar(1)))*6.5./sqrt(waves{iw}.rays{ir}.sTe),0,0,'Ray length (m)','N_{||}',title_fig,NaN,'',[nparbin(1),nparbin(end)],'-','none','r',0.5);                   
            end
            %
            P0 = P0 + waves{iw}.rays{ir}.P0_2piRp*2*pi*Rp/1e6;
        end
        %
        for irho = 1:length(rho_S)-1,
            if iw == 1 & mode == 1,%the first ray without fluctuations
                ii = find((0 <= waves{iw}.rays{ir}.srho) & (waves{iw}.rays{ir}.srho < rho_S(irho + 1)));
                hr_nofluct(irho,:) = hr_nofluct(irho,:) + hist(real(waves{iw}.rays{ir}.sNpar(ii)),nparbin);
            else
                ii = find((0 <= waves{iw}.rays{ir}.srho) & (waves{iw}.rays{ir}.srho < rho_S(irho + 1)));
                hr(irho,:) = hr(irho,:) + hist(real(waves{iw}.rays{ir}.sNpar(ii)),nparbin);                
            end
        end
    end
end
%
if mode == 1,
    for ir = 1:nr(1),
        graph1D_jd(waves{1}.rays{ir}.ss,real(waves{1}.rays{ir}.sNpar),0,0,'Ray length','N_{||}',[],NaN,'',[nparbin(1),nparbin(end)],'-','none','g',2);
        %
        if ~wavetype == 1,
            graph1D_jd(waves{1}.rays{ir}.ss,sign(real(waves{1}.rays{ir}.sNpar(1)))*6.5./sqrt(waves{1}.rays{ir}.sTe),0,0,'Ray length (m)','N_{||}',title_fig,NaN,'',[nparbin(1),nparbin(end)],'-','none','r',2);        
        end
    end
    %
    if ~wavetype == 1,
        legend('no fluct.','6.5/\surdT_{e}','with fluct.');
    else
        legend('with fluct.');       
    end
else
    if ~wavetype == 1,   
        legend('with fluct.','6.5/\surdT_{e}');
    else
        legend('with fluct.');
    end
end
%
if ~wavetype == 1,
    if itn > 0,
        figure('Name',['Power density, itn = ',int2str(itn)]);
    else
        figure('Name','Power density');
    end
    %
    for irho = 1:length(rho),
        %
        if irho <= ceil(-1+sqrt(1+length(rho)))*(ceil(-1+sqrt(1+length(rho)))+1);
            subplot(ceil(-1+sqrt(1+length(rho))),ceil(-1+sqrt(1+length(rho)))+1,irho),
            %
            if rem(irho,ceil(-1+sqrt(1+length(rho)))+1) == 1,
                label_y = 'dP_{rf}/dN_{||}';
            else
                label_y = '';
            end
            %
            if mode == 1,
                graph1D_jd(nparbin,hr_nofluct(irho,:)/max(hr_nofluct(irho,:)),0,0,'N_{||}',label_y,['\rho = ',num2str(rho(irho))],NaN,[nparbin(1),nparbin(end)],[0,1],'-','none','g',1);     
            end
            %
            graph1D_jd(nparbin,hr(irho,:)/max(hr(irho,:)),0,0,'N_{||}',label_y,['\rho = ',num2str(rho(irho))],NaN,[nparbin(1),nparbin(end)],[0,1],'-','none','b',1);
            %
            Npar_th = 6.5./sqrt(ppval(equil_fit.Te_fit.pp_f,rho(irho)));
            %
            graph1D_jd([Npar_th,Npar_th],[0,1],0,0,'N_{||}',label_y,['\rho = ',num2str(rho(irho))],NaN,[-Npar_th,Npar_th],[0,1],'--','none','r',2);
            graph1D_jd([-Npar_th,-Npar_th],[0,1],0,0,'N_{||}',label_y,['\rho = ',num2str(rho(irho))],NaN,[-Npar_th,Npar_th],[0,1],'--','none','r',2);
            %
            for iw = 1:nw,
                for ir = 1:nr(iw),
                    graph1D_jd([real(waves{iw}.rays{ir}.sNpar(1)),real(waves{iw}.rays{ir}.sNpar(1))],[0,1],0,0,'N_{||}',label_y,['\rho = ',num2str(rho(irho))],NaN,[-Npar_th,Npar_th],[0,1],'-','none','m',1);
                end
            end
        end
    end
end
%


