% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function wave_disp_outputs_mt(wavess,shotimes,style,axs)
%
nt = length(shotimes);
%
nr_dep = 40;
%
opt_peak = 0;
%
rho_dep_S = linspace(0,1,nr_dep+1);
rho_dep = (rho_dep_S(1:end-1) + rho_dep_S(2:end))/2;
drho_dep = diff(rho_dep_S);
%
alpha_L = NaN(nt,0);
beta_L = NaN(nt,0);
P0 = NaN(nt,0);
Pabs = NaN(nt,0);
rhoabs = NaN(nt,0);
%
launchids = {};
%
for it = 1:nt,
    waves = wavess{it};
    if isempty(waves),% times for which no RF wave is calculated
        %
        continue
        %
    else% times for which RF wave are calculated
        %
        for ilaun = 1:length(waves),
            %
            wave = waves{ilaun};
            launch = wave.rayinit.launch;
            %
            launchid = launch.id;
            %launchid = launchid(1:min([end,strfind(launchid,'_')-1]));
            %
            iw = find(strcmp(launchids,launchid));
            %
            if isempty(iw),% add new launcher to list
                %
                launchids = [launchids,launchid];
                %
                alpha_L(:,end+1) = NaN(nt,1);
                beta_L(:,end+1) = NaN(nt,1);
                P0(:,end+1) = NaN(nt,1);
                Pabs(:,end+1) = NaN(nt,1);
                rhoabs(:,end+1) = NaN(nt,1);
                %
                iw = length(launchids);
                %
            elseif P0(it,iw) > 0
                error('problem identifying launchers')
            end
            %
            alpha_L(it,iw) = launch.yalpha_L;
            beta_L(it,iw) = launch.ybeta_L;
            %
            dP_drho_lin = zeros(1,nr_dep);
            P0(it,iw) = 0;
            Pleft = 0;
            %
            if wave.rayinit.yP0_2piRp > 0
                Rp2pi = launch.yP_L/wave.rayinit.yP0_2piRp;
                %
                for iy = 1:length(wave.rays),
                    P0(it,iw) = P0(it,iw) + Rp2pi*wave.rays{iy}.P0_2piRp;
                    srho_P = sqrt(wave.rays{iy}.spsin);
                    sP_norm = wave.rays{iy}.sP_2piRp_lin/wave.rays{iy}.sP_2piRp_lin(1);
                    dP_drho_lin = dP_drho_lin + Rp2pi*wave.rays{iy}.P0_2piRp*radialdampingprofile_jd(srho_P,sP_norm,rho_dep_S);
                    Pleft = Pleft + Rp2pi*wave.rays{iy}.sP_2piRp_lin(end);
                end
                %
                Pabs(it,iw) = sum(dP_drho_lin.*drho_dep);
                if abs(P0(it,iw) - Pabs(it,iw) - Pleft)/(P0(it,iw) + eps) > 1e-6,%to check consistency
                    disp('WARNING : consistency pb in power deposition')
                    keyboard
                end
                %
                if all(isnan(dP_drho_lin)),
                    rhoabs(it,iw) = NaN;
                elseif opt_peak == 0,%max position
                    rhoabs(it,iw) = rho_dep(find(dP_drho_lin == max(dP_drho_lin),1,'first'));
                else
                    rhoabs(it,iw) = sum(dP_drho_lin.*rho_dep.*drho_dep)/Pabs(it,iw);
                end
            else
                rhoabs(it,iw) = NaN;
            end
        end
    end
end
%
nw = length(launchids);
%
phi_L = pi - alpha_L;
phi_L(phi_L > pi) = phi_L(phi_L > pi) - 2*pi;
theta_L = pi/2 - beta_L;
%
fabs = Pabs./P0;
%
colors = {'r','b',[0,0.5,0],'k'};
markers = {'s','d','+','o'};
%
xlab = 't (s)';
xlim = 0;
%
if nargin < 4,
    red = 0.9;
    lspace = 0.7;
    lspace2 = 0.5;
    bspace = 0.7;
    bspace2 = 0.5;
else
    red = 1;
    lspace = NaN;
    lspace2 = NaN;
    bspace = NaN;
    bspace2 = NaN;
end
%
% poloidal angle
%
if nargin < 4,
    figure(1),clf,set(1,'Name','Poloidal angle')
    ax = gca;
else
    ax = axs(1);
end
%
ylab = 'pol. angle (deg.)';
ylim = NaN;%[-90,90];
%
for iw = 1:nw-1,
    [ax] = graph1D_jd(shotimes,theta_L(:,iw)*180/pi,0,0,'','','',NaN,NaN,NaN,'-',markers{iw},colors{iw},2,style,ax);
end
[ax] = graph1D_jd(shotimes,theta_L(:,nw)*180/pi,0,0,xlab,ylab,'',launchids,xlim,ylim,'-',markers{nw},colors{nw},2,style,ax);
%
% toroidal angle
%
if nargin < 4,
    figure(2),clf,set(2,'Name','Toroidal angle')
    ax = gca;
else
    ax = axs(2);
end
%
ylab = 'tor. angle (deg.)';
ylim = NaN;%[-90,90];
%
for iw = 1:nw-1,
    [ax] = graph1D_jd(shotimes,phi_L(:,iw)*180/pi,0,0,'','','',NaN,NaN,NaN,'-',markers{iw},colors{iw},2,style,ax);
end
[ax] = graph1D_jd(shotimes,phi_L(:,nw)*180/pi,0,0,xlab,ylab,'',launchids,xlim,ylim,'-',markers{nw},colors{nw},2,style,ax);
%
% launched power
%
if nargin < 4,
    figure(3),clf,set(3,'Name','launched power')
    ax = gca;
else
    ax = axs(3);
end
%
ylab = 'RF power (kW)';
ylim = 0;
%
for iw = 1:nw-1,
    [ax] = graph1D_jd(shotimes,P0(:,iw)/1e3,0,0,'','','',NaN,NaN,NaN,'-',markers{iw},colors{iw},2,style,ax);
end
[ax] = graph1D_jd(shotimes,P0(:,nw)/1e3,0,0,xlab,ylab,'',launchids,xlim,ylim,'-',markers{nw},colors{nw},2,style,ax);
%
% power absorption
%
if nargin < 4,
    figure(4),clf,set(4,'Name','power absorption')
    ax = gca;
else
    ax = axs(4);
end
%
ylab = 'Power absorption (%)';
ylim = [-10,110];
%
for iw = 1:nw-1,
    [ax] = graph1D_jd(shotimes,fabs(:,iw)*100,0,0,'','','',NaN,NaN,NaN,'-',markers{iw},colors{iw},2,style,ax);
end
[ax] = graph1D_jd(shotimes,fabs(:,nw)*100,0,0,xlab,ylab,'',launchids,xlim,ylim,'-',markers{nw},colors{nw},2,style,ax);
%
% power deposition
%
if nargin < 4,
    figure(5),clf,set(5,'Name','power deposition')
    ax = gca;
else
    ax = axs(5);
end
%
ylab = '\rho_{abs} (pol. flux)';
ylim = [0,1];
%
for iw = 1:nw-1,
    [ax] = graph1D_jd(shotimes,rhoabs(:,iw),0,0,'','','',NaN,NaN,NaN,'-',markers{iw},colors{iw},2,style,ax);
end
[ax] = graph1D_jd(shotimes,rhoabs(:,nw),0,0,xlab,ylab,'',launchids,xlim,ylim,'-',markers{nw},colors{nw},2,style,ax);
%
