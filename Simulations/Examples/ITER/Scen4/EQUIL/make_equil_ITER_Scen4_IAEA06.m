% script make_equil_ITER_IAEA06
%
%
clear all
%
load EQUIL_ITER_Scen4.mat
%
equil.id = 'ITER_Scen4_IAEA06';
equil.ptBPHI = - equil.ptBPHI;
%
save EQUIL_ITER_Scen4_IAEA06.mat equil