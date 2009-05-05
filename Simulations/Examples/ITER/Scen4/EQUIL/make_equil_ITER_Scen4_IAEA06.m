% script make_equil_ITER_Scen4_IAEA06
%
%
clear all
%
% original calculation from EFIT output and assuming EFIT standards
%
% Here Bphi > 0 and Ip < 0. Co-current has N// > 0
%
load EQUIL_ITER_Scen4.mat
%
% for the sake of benchmarking with other codes
% see P. Bonoli IAEA 2006
%
% Here Bphi < 0 and Ip > 0. Co-current has N// > 0
%
equil.id = 'ITER_Scen4_IAEA06';
equil.psi_apRp = - equil.psi_apRp;
equil.ptBx = - equil.ptBx;
equil.ptBy = - equil.ptBy;
equil.ptBPHI = - equil.ptBPHI;
%
%save EQUIL_ITER_Scen4_IAEA06.mat equil
%
% according to ITER specifications
%
% Here Bphi > 0 and Ip > 0. Co-current has N// < 0
%
equil.ptBPHI = - equil.ptBPHI;
%
save EQUIL_ITER_Scen4_IAEA06.mat equil
