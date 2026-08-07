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
%% Benchmark parameters
timeconsistency = true;     %Set to false to not allow time looping 
equilibriaFamily = 1;       %0: use equilibriaCostum 
                            %1: Soloviev01_ap3-->Soloviev01_ap7 (make_equil_Soloviev01_apxx)
                            %2: TScirc_ap3 -->TScirc_ap7        (make_equil_TScirc_apxx)
                            %3: All TScirc                      (make_equil_TScirc)
                            %4: All TScyl                       (make_equil_TScyl)
equilibriaCostum_ids = {''};
equilibriaCosutm_path = '';

id_simul = 'Benchmark'; 
%% Physical parameters
eps_in = 0; %Adimentionalised electric field

%% Figure output
%put any of this to false to suppress figure creation
equilibriaFlag       = true;
distributionFlag    = true;
normFlag            = true;

Nr = 1; %Number of radial points on which plot the distribution (max nrho)
%% Id & simulation
switch equilibriaFamily
    
    case 0
        id_equil = equilibriaCostum_ids; 
        path_equil = equilibriaCosutm_path;
    case 1
        id_equil = {'Soloviev01_ap3','Soloviev01_ap4','Soloviev01_ap5','Soloviev01_ap6','Soloviev01_ap7'};    
        path_equil = '';
    case 2
        id_equil = {'TScirc_ap3','TScirc_ap4','TScirc_ap5','TScirc_ap6','TScirc_ap7'};
        path_equil = '';
    case 3
        id_equil = {'TScirc','TScirc','TScirc','TScirc','TScirc'};    
        path_equil = '';
    case 4
        id_equil = {'TScyl','TScyl','TScyl','TScyl','TScyl'};    
        path_equil = '';
    otherwise 
        error('equilibriaFamily not recognised')
end

id_path = '';
path_path = '';

id_dkeparam = 'LH_RT';
path_dkeparam = '';

id_display = 'NO_DISPLAY';%'NO_DISPLAY';
path_display = '';

ids_wave = {''}; %RF waves contribution
paths_wave = '';

id_transpfaste = ''; %Fast electron radial transport
path_transpfaste = '';

id_ripple = ''; %Fast electron magnetic ripple losses
path_ripple = '';


%% load Id & simulation
[dkepath,dkeparam,dkedisplay,waves,transpfaste,ripple] = ...
    load_structures_yp(                                 ...
    'dkepath',     id_path,        path_path           ...
    ,'dkeparam',    id_dkeparam,    path_dkeparam       ...
    ,'dkedisplay',  id_display,     path_display        ...
    ,'wave',        ids_wave,       paths_wave          ...
    ,'transpfaste', id_transpfaste, path_transpfaste    ...
    ,'ripple',      id_ripple,      path_ripple);

%% dkeparam correction
nrho_S = 21;
nmhu_S = 101;
np_S   = 151;

psin_S = linspace(0,1,nrho_S).^2;
rho_S  = [];
dkeparam.rho_S  = rho_S;
dkeparam.psin_S = psin_S;
dkeparam.nmhu_S = nmhu_S;
dkeparam.np_S   = np_S;

%% loop

nS = length(id_equil);

for i = 1:nS
    %% loadinf equil
    fprintf('----------------  ITERATION %d ----------------\n', i)
    
    equil = load_structures_yp('equil', id_equil{i},	path_equil);
    epsi = eps_in;
    ohm = ohm_flat(equil,epsi);
    
    
    %% looping with previous data
    if timeconsistency
        if i == 1
            dkeparam.selfCoherence = [];
            XXf0_in = [];
        else
            if i == 2
                dkeparam.psin_S = radialDKE.xpsin_S_dke;
                dkeparam.rho_S = [];
                dkeparam.selfCoherence.xmhu0 = momentumDKE.xmhu0;
            end
            dkeparam.selfCoherence.XmhuPrev = gridDKE.Xmhu;
            dkeparam.selfCoherence.XpnPrev  = gridDKE.Xpn;
            dkeparam.selfCoherence.xmhu0T2Input = equilDKE.xmhu0T2;
            equil.xmhu0T2Prev = equilDKE.xmhu0T2;
            
            XXf0_in = dke_out.XXf0{1};
        end
    else
        if isfield(dkeparam,'selfCoherence')
            dkeparam = rmfield(dkeparam,'selfCoherence');
        end
        XXf0_in = [];
    end
    
    % launch luke <3
    [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,...
        Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp( ...
        id_simul, dkepath, equil, dkeparam, dkedisplay, ohm, waves, ...
        transpfaste,ripple,XXf0_in,[],[]);
    fprintf('--> Simulation completed.\n')
    
    % saving data
    Rp_C{i} = equilDKE.Rp;
    Xx_C{i} = equilDKE.Xx;
    Xy_C{i} = equilDKE.Xy;
    xpsin_C{i} = gridDKE.xpsin;
    Xmhu_C{i}  = gridDKE.Xmhu;
    Xpn_C{i}   = gridDKE.Xpn;
    XXf0_C{i} = dke_out.XXf0{1};
    normf0(:,i) = dke_out.normf0{1}(:,end);
end

%% figure output

if equilibriaFlag
    
    fequ = figure('Color','w');
    
    tiledlayout('flow')
    for i = 1:nS
        
        Rp = Rp_C{i};
        Xx = Xx_C{i};
        Xy = Xy_C{i};
        
        nexttile
        plot(Rp+Xx',Xy','k')
        title(id_equil{i},'Interpreter','none')
        axis tight
        axis equal
        xlabel('R [m]')
        ylabel('Z [m]')
    end
    
    disp('--> equilibria plotted');
    pause(0.5)
end

if distributionFlag
    if Nr == 1,     irr = 1;
    else,           irr = round(linspace(1,size(xrho,1),Nr));   end
    
    for j = 1:Nr
        ir = irr(j);
        fdis{j} = figure('Color','w'); %#ok<*SAGROW>
        tiledlayout('flow')
        for i = 1:nS
           
            Xmhu = Xmhu_C{i};
            Xpn  = Xpn_C{i};
            f0   = XXf0_C{i}(:,:,ir);
            
            Ppa  = Xmhu.*Xpn;
            Ppe  = sqrt(1-Xmhu.^2).*Xpn;
            
            nexttile
            contourf(Ppa,Ppe,log10(f0),30)
            cb = colorbar;
            c.Label.String = 'log_{10}(f0)';
            title(id_equil{i},'Interpreter','none')
            axis tight
            axis equal
            xlabel('p_{||}');
            ylabel('p_{\perp}');
        end
    end
end
    
if normFlag
    fnor = figure('Color','w');
    xpsin = xpsin_C{1};
    subplot(1,2,1)
    plot(xpsin,normf0);    
    grid on
    xlabel('\psi_n [-]');
    ylabel('normf0');
        
    legend(id_equil,'location','best');
    title('normf0')
    grid minor
    
    subplot(1,2,2)
    semilogy(xpsin,abs(1-normf0));    
    grid on
    xlabel('\psi_n [-]');
    ylabel('|1-normf0|');
        
    legend(id_equil,'location','best');
    title('normf0','Interpreter','none')
    grid minor
    
end
    
    
    
