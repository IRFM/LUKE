%
% This script is used to run LUKE for the runaway problem
%
% by J. Decker, Y. Peysson and E. Nilsson
%
% Note : A comparison with Kulsrud is provided for the follwoing parameters :
%
% - betath2 = 1e-6 (NR limit)
% - alpha among [4,6,8,10]*1e4;
% - Zi among [1,2,3,10]
% - coll_mode = 0 (Relativistic Maxwellian background)
%
clear all
clear mex
clear functions
close all
warning('off')
%
% grid parameters
%
pnmax_S = 20;
np_S = 101;
pn_S = linspace(0,pnmax_S,np_S);
%
%
% normalized electric field (with respect to the Critical field Ec)
%
alpha = 1e4;%E/Ec
%
% temperature betath2 = Te/mc2
% (betath2 = 10^(-6) is validated for NR limit)
%
betath2 = 1e-6;%
%
% ion charge (single species, cold ions)
%
Zi = 2;%
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
RR = frundke_runaway(id_simul,alpha,betath2,Zi,coll_mode,pn_S);
%
epsi_kulsrud = [0.04;0.06;0.08;0.10];
Zi_kulsrud =[1,2,3,10];
RR_kulsrud = 1e-4*[ 0.01914,NaN   ,NaN  ,NaN   ;...%Kulsrud (PRL, 31,11, (1972) 690)
                    0.5411 ,0.2611,NaN  ,NaN   ;...  
                    3.177  ,1.735 ,1.047,0.09  ;...
                    10.04  ,5.839 ,3.757,0.449];
%
iepsi = find(abs((alpha*betath2 - epsi_kulsrud)./epsi_kulsrud) < 10*eps);
%
if coll_mode == 0 && abs((betath2 - 1e-6)/1e-6) < 10*eps && ~isempty(iepsi) && any(Zi == Zi_kulsrud),
    RR_k = RR_kulsrud(iepsi,Zi == Zi_kulsrud);
else
    RR_k = '';
end
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
disp(['NR limit : pc/pT = ',num2str(1/sqrt(alpha*betath2))])%NR
disp(['Relativ. : pc/pT = ',num2str(1/sqrt(alpha*betath2 - betath2))])%rel
disp(' ')
disp(['--> LUKE    RR : ',num2str(RR)])
if ~isempty(RR_k),
    disp(['--> Kulsrud RR : ',num2str(RR_k)])
end
disp('----------------------')
%
diary off
%
%************************************************************************************************************************************
%
