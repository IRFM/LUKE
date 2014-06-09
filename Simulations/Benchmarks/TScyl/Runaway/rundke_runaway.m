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
pnmax_S = 50;
np_S = 101;
pn_S = linspace(0,pnmax_S,np_S);
%
%
% normalized electric field (with respect to the Critical field Ec)
%
alpha = 10;%E/Ec
%
% temperature betath2 = Te/mc2
% (betath2 = 10^(-6) is validated for NR limit)
%
betath2 = 0.01;%
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
[RR,mksa] = frundke_runaway(id_simul,alpha,betath2,Zi,coll_mode,pn_S);
%
% additional parameters
%
% Dreicer field ED = Ec/betath2
% Critical momentum at mhu=1 : 
% - NR limit     : pc = 1/sqrt(betath2*alpha)
% - Relativistic : pc = 1/sqrt(betath2*alpha - betath2))
%
%************************************************************************************************************************************
%
format
%
delete res_runaway
%
diary res_runaway
%
disp('Simulation parameters : ')
disp(['coll_mode = ',num2str(coll_mode),' ; Te/mc2 = ',num2str(betath2),' ; E/Ec = ',num2str(alpha),' ; E/ED = ',num2str(alpha*betath2),' ; Zi = ',num2str(Zi)])
disp(['NR limit : pc/pT = ',num2str(1/sqrt(alpha*betath2)),' ; pmax/pc = ',num2str(pnmax_S*sqrt(alpha*betath2))])%NR
disp(['Relativ. : pc/pT = ',num2str(1/sqrt((alpha - 1)*betath2)),' ; pmax/pc = ',num2str(pnmax_S*sqrt((alpha - 1)*betath2))])%rel
disp(' ')
disp(['--> LUKE RR (normalized to ne and tauc) : ',num2str(RR)])
disp('----------------------')
%
diary off
%
%************************************************************************************************************************************
%

eval(['save ','test','.mat']);
%info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'_',filename,'.mat']);
