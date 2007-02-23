clear all
close all
%
id_equil = 'ITER_Scen4_IAEA06';
id_simul = '19Z';
%
nr_dep = 20;
opt_disp.equil = 0;
opt_disp.si = -1;
%
filename = ['DKE_RESULTS_',id_equil,'_',id_simul];
%
proc_wave_luke_jd(filename,opt_disp,nr_dep)

