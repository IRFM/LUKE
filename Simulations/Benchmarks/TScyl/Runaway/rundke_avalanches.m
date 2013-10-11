%
% This script is used to run LUKE for the runaway problem
%
% by J. Decker, Y. Peysson and E. Nilsson
%
clear all
clear mex
clear functions
close all
warning('off')
%
% grid parameters
%
%for ia = 2:9
ia = 8;
f_pmax = 1; %for avalanche calculation. if avalanche_mode and not specified = 1
pnmax_S =  20;
np_S = 201;
nmhu_S = 201;
%
mfactor = 100;%Factor for super theta grid (equil -> equilDKE)
%
%
% normalized electric field (with respect to the Critical field Ec)
%
alpha = ia;%E/Ec

%
% temperature betath2 = Te/mc2
% (betath2 = 10^(-6) is validated for NR limit)
%
betath2 = 0.01;%
%
pnmin_S = 1/sqrt((alpha-1)*betath2);
%
% ion charge (single species, cold ions)
%
Zi = 1;%
%
% collision mode : 
% (0) : Relativistic Maxwellian background
% (1) : High-velocity limit
% (2) : Linearized Belaiev-Budker (momentum-conserving)
%
coll_mode = 0;
%
id_simul = 'Runaway';%Simulation ID
%
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%
%id_simul = 'Runaway';%Simulation ID
%path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [0.6];%1%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = '';%For all paths used by DKE solver
path_path = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil = 'TScirc';%For plasma equilibrium
path_equil = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'UNIFORM10010020';%For DKE code parameters
path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_display = 'NO_DISPLAY';%'NO_DISPLAY''PARTIAL_VISUAL';%For output code display, files from Project_DKE/DISPLAY_FILES/
path_display = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
%************************************************************************************************************************************
%************************************************************************************************************************************
%************************************************************************************************************************************
%
[dkepath,equil,dkeparam,dkedisplay] = load_structures_yp('dkepath',id_path,path_path,'equil',id_equil,path_equil,'dkeparam',id_dkeparam,path_dkeparam,'dkedisplay',id_display,path_display);
%
%**************************************************************************
%**************************************************************************
%
if exist('dmumpsmex','file') == 3,
    dkeparam.invproc = -2;
end
%t
dkeparam.pnmin_S = pnmin_S;
dkeparam.f_pmax = f_pmax; % multiplication of p grid. f_pmax*p_max
dkeparam.pnmax_S = pnmax_S;
dkeparam.boundary_mode_f = 0;%Enforcing the Maxwellian initial value at the first "boundary_mode_f" grid points
dkeparam.norm_mode_f = 0;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes
dkeparam.timevol = 1;
dkeparam.tn = 10000;%time for asymptotic solution with norm_mode_f = 1
dkeparam.dtn = 10;%10 time steps required for accurate runaway solution - see rundke_dtn
dkeparam.coll_mode = coll_mode;% mode for the collision operator
dkeparam.bounce_mode = 1; %bounce average
dkeparam.avalanche_mode = 1; %if 1 avalanche mode on, 0 or undefined for off
%
options_fzero = optimset('fzero');
options_fzero.Display = 'iter';
options_fzero.TolX = 1e-10;%convergence tolerance
dkeparam.options_fzero = options_fzero;
%
equil.pzTi = 1e-10*ones(size(equil.pzTi));% cold ions
%
[qe,me,dummy,dummy,e0,dummy,dummy,mc2,clum] = pc_dke_yp;%Universal physics constants
%
equil.pTe = betath2*mc2*ones(size(equil.pTe));
%
equil.zZi = [1,1,1,Zi];
equil.pzni = [0;0;0;1/Zi]*equil.pne;% single ion species
%
epsi = alpha*betath2;
%
xnre_init = zeros(1,length(rho_S)); % 0.1*ones
%
ohm = ohm_flat(equil,epsi);
%
ohm.xnre_init = xnre_init;
%
dkeparam.pn_S = linspace(0,pnmax_S,np_S);
dkeparam.nmhu_S = nmhu_S;
dkeparam.psin_S = psin_S;
dkeparam.rho_S = rho_S;
dkeparam.mfactor = mfactor;
%
% Global parameters for the vectorial magnetic equilibrium
%
fitparam.mode_equil = 1;%Magnetic equilibrium grid type: (1): (psi-theta), (2): (x-y)
fitparam.nharm = 32;%Number of harmonics in the magnetic equilibrium interpolation (less than ntheta_equil/2)
fitparam.ngridresample = 1001;%Number of grid points for resampling the radial profile of magnetic equilibrium parameters
fitparam.method = 'pchip';%nearest,spline,pchip
%
equil.equil_fit = fitequil_yp(equil,fitparam.mode_equil,fitparam.method,fitparam.ngridresample,fitparam.nharm);%Build vectorized magnetic equilibrium structure
%
[Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource,dke_warnings] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,'','','',[],[]);
%
RR_an = RR_rosenbluth_en(alpha, Zi, mksa.ne_ref, mksa.lnc_e_ref, equilDKE.ap*equilDKE.xrho/equilDKE.Rp); %analytic AVALANCHE growth rate Rosenbluth Putvinski NF 1997
%
%RR = dke_out.XxRR_fsav(end,:);
Rfrac = Znorm(1,end).x_Rfrac_0; %runaway fraction (nr of runaways between pmin and pmax) primary + avalanche
%
xnre = cell2mat(dke_out.xnre);
xnre_out_norm = dke_out.xnre_out_norm; %runaway population for avalanche generation
%
RRAint = Znorm(1,end).xRRAint/xnre(end-1); %integral over S[pmin pmax]
RRAinttot = Znorm(1,end).xRRAtot/xnre(end-1); %total integral S[0 pmax]
RRAintegral = RRAint*mksa.nhu_ref;
RR = dke_out.XxRR_fsav{end}; %runaway loss rate (primary)
RR = RR(end); %[vol-1 tau_c^-1]
%RRunnorm = RR*mksa.nhu_ref; %vol-1 s^-1
%RRRP = RR*mksa.nhu_ref/nre(1,1);
for it = 1:(length(xnre)-1)
    gr2(it) = (log(xnre(it+1)) - log(xnre(it)))/dkeparam.dtn;
    gr(it) = (xnre(it+1) - xnre(it))/xnre(it)/dkeparam.dtn;
end
figure;graph1D_jd(1:(length(xnre)-1),gr,0,0,'iteration','growth rate (s^-1)','Numerical growth rate',NaN,NaN,NaN,'-','o','b',1)
hold on
plot(1:(length(xnre)-1), RRAinttot,'rx')
plot(1:(length(xnre)-1), RRAint,'kx'); hold off
%
if dkeparam.avalanche_mode == 1
    pnext = pnmax_S*f_pmax;
    gamma_max = sqrt((pnmax_S*mksa.betath_ref)^2+1);
    gamma_ext = sqrt((pnext*mksa.betath_ref)^2+1);
    %Ec = mksa.ne_ref*qe^3*mksa.lnc_e_ref/(4*pi*e0^2*me*clum^2);
    %E = alpha * Ec;
    %nhu_c = qe^4*mksa.ne_ref*mksa.lnc_e_ref/(4*pi*e0^2*me^2*clum^3);
    %nhu_c = mksa.nhu_ref*mksa.betath_ref^3;
    dtn_min = me*clum*(sqrt(gamma_ext^2-1)-sqrt(gamma_max^2-1))/(qe*mksa.Edreicer_ref*epsi)*mksa.nhu_ref; %mininmum time step dtn for dreicer acc from pmax to pext
   
    %dtn_min = me*clum*(sqrt(gamma_ext^2-1)-sqrt(gamma_max^2-1))/(qe*E)*mksa.nhu_ref; %mininmum time step dtn for dreicer acc from rest to gamma
    gam = gamma_max:0.01:(gamma_max+10);
    dt_acc = me*clum*(sqrt(gam.^2-1)-sqrt(gamma_max^2-1))/(qe*mksa.Edreicer_ref*epsi)*mksa.nhu_ref; %mininmum time step dtn for dreicer acc from rest to gamma
    titl=['(ro): gamma @ p_{max} = ',num2str(pnmax_S),'p_{th}'];
    figure;graph1D_jd(gam,dt_acc,0,0,'gamma','dt_n Dreicer',titl,NaN,NaN,NaN,'-','none','b',2)
    hold on
    graph1D_jd(gamma_ext,dtn_min,0,0,'','','',NaN, NaN,NaN,'none','o','r',3);
    hold off
    disp(['     Mininmum time step dtn for dreicer acc from rest to gamma(p_max) = : ',num2str(gamma_max),' is tau*nhu_ref = ',num2str(dtn_min)])
end
%
if length(rho_S) == 1
%[logXf0_cyl_ref,ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(log(cell2mat(dke_out.XXf0)),momentumDKE.pn,momentumDKE.mhu,0.1);%Spherical to cylindrical coordinate transformation
[logXf0_cyl_ref,ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(log(dke_out.XXf0{end}),momentumDKE.pn,momentumDKE.mhu,0.1);%Spherical to cylindrical coordinate transformation
Xf0_cyl_ref = exp(logXf0_cyl_ref);%For accurate representation in figures 
%
logXfinit_cyl_ref = s2c_dke_yp(log(dke_out.XXfinit),momentumDKE.pn,momentumDKE.mhu,0.1);%Spherical to cylindrical coordinate transformation
Xfinit_cyl_ref = exp(logXfinit_cyl_ref);%For accurate representation in figures 
%
Xppar_cyl_ref = ones(length(pperp_cyl_ref),1)*ppar_cyl_ref(:)';%Grid for the distribution functions only
Xpperp_cyl_ref = pperp_cyl_ref(:)*ones(1,length(ppar_cyl_ref));
Xp_cyl_ref = sqrt(Xppar_cyl_ref.*Xppar_cyl_ref + Xpperp_cyl_ref.*Xpperp_cyl_ref);
%
Xf0_cyl_ref = Xf0_cyl_ref.*(Xf0_cyl_ref>0);%Remove negative values
Xf0_cyl_ref = Xf0_cyl_ref.*(Xp_cyl_ref<=max(ppar_cyl_ref));%Remove values above max(ppar)
Xf0_cyl_ref(isnan(Xf0_cyl_ref)) = 0;%Remove NaN values
%
Xfinit_cyl_ref = Xfinit_cyl_ref.*(Xfinit_cyl_ref>0);%Remove negative values
Xfinit_cyl_ref = Xfinit_cyl_ref.*(Xp_cyl_ref<=max(ppar_cyl_ref));%Remove values above max(ppar)
Xfinit_cyl_ref(isnan(Xfinit_cyl_ref)) = 0;%Remove NaN values
%
% Remove values less than computer accuracy
%
Xmask = abs(Xf0_cyl_ref) < eps;
%
pnmax = max(momentumDKE.pn_S);
pnmax_0 = min(min(Xp_cyl_ref(Xmask)));
%
Xmask = Xp_cyl_ref >= pnmax;    
%
Xf0_cyl_ref(Xmask) = 0;
Xfinit_cyl_ref(Xmask) = 0;
%
figure(1),clf
%
x1 = ppar_cyl_ref;
xlab1 = 'p_{||}/p_{Te}';
xlim1 = [-pnmax,pnmax];
%
x2 = pperp_cyl_ref;
xlab2 = 'p_{\perp}/p_{Te}';
xlim2 = [0,pnmax];
%
leg = {'f_M','f'};
%
y1 = Xfinit_cyl_ref;
y2 = Xf0_cyl_ref;
%
y9 = sqrt(pnmax^2 - x1.^2);
%
figure;
graph2D_jd(x1,x2,y1','','','',xlim1,xlim2,0,mksa.betath_ref,[0:0.5:pnmax],0,'-','b',0.5,20+14i,1,max(max(y1)));
hold on
graph2D_jd(x1,x2,y2','','','',xlim1,xlim2,0,mksa.betath_ref,[0:0.5:pnmax],0,'-','r',2,20+14i,1,max(max(y1)));
hold off
%
graph1D_jd(x1,y9,0,0,xlab1,xlab2,'',NaN,xlim1,xlim2,'-','none','k',2,20+14i,gca,0.9,0.7,0.7);
%
axis('equal');axis([xlim1,xlim2]);
legend(leg);
end
%
disp('Simulation parameters : ')
disp(['coll_mode = ',num2str(coll_mode),' ; Te/mc2 = ',num2str(betath2),' ; E/Ec = ',num2str(alpha),' ; E/ED = ',num2str(alpha*betath2),' ; Zi = ',num2str(Zi)])
disp(['NR limit : pc/pT = ',num2str(1/sqrt(alpha*betath2)),' ; pmax/pc = ',num2str(pnmax_S*sqrt(alpha*betath2))])%NR
disp(['Relativ. : pc/pT = ',num2str(1/sqrt((alpha - 1)*betath2)),' ; pmax/pc = ',num2str(pnmax_S*sqrt((alpha - 1)*betath2))])%rel
disp(' ')
disp(['--> LUKE RR (normalized to ne and tauc) : ',num2str(RR)])
disp('----------------------')
%disp(['--> RR (normalized to ne) : ',num2str(RRunnorm)])
%disp('----------------------')
%
diary off
%
figure;graph1D_jd((0:dkeparam.dtn:dkeparam.tn),xnre,0,0,'t_n','number of runaways (norm to n_e)','',NaN,NaN,NaN,'-','none','b',2)
figure;graph1D_jd((0:dkeparam.dtn:dkeparam.tn),xnre,0,1,'t_n','number of runaways (norm to n_e)','',NaN,NaN,NaN,'-','none','b',2)
%
figure;graph1D_jd((1:dkeparam.dtn:dkeparam.tn),cell2mat(dke_out.curr0(1:2:end)),0,0,'t_n','J_0','',NaN,NaN,NaN,'-','none','b',2)
%
growthrate(ia) = gr(end)*mksa.nhu_ref
%end
%gRA = qe^4*alpha*mksa.ne_ref/(8*pi*e0^2*me^2*clum^3)
%
%************************************************************************************************************************************
%
% 
eval(['save ','test','.mat']);
 %info_dke_yp(2,['Data saved in',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'_',filename,'.mat']);