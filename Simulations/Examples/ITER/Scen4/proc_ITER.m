%
clear all
close all
%
si = 1;
opt_rho = 1;
%
ids_equil = {'ITER_Scen4_IAEA06_mod'};% if same for all runs, just give one 
%
select = [1,2,3];
%ids_wave = {'19Z','20Z','21Z'};
%ids_wave = {'19Z_Alpha_3p7','20Z_Alpha_3p7','21Z_Alpha_3p7'};
ids_wave = {'19Z_Alpha_5p0','20Z_Alpha_5p0','21Z_Alpha_5p0'};
leglist = ['N_{||} = 1.9';'N_{||} = 2.0';'N_{||} = 2.1'];
%
%select = [1,2];
%ids_wave = {'19Z_Alpha_3p7','19Z_Alpha_5p0'};
%ids_wave = {'20Z_Alpha_3p7','20Z_Alpha_5p0'};
%ids_wave = {'21Z_Alpha_3p7','21Z_Alpha_5p0'};
%leglist = ['\omega/2\pi = 3.7 GHz';'\omega/2\pi = 5.0 GHz'];
%
%ids_wave = {'20Z_Alpha_5p0','20Z_Alpha_5p0_noBounce'};
%ids_wave = {'20Z_Alpha_3p7','20Z_Alpha_3p7_noBounce'};
%leglist = ['Magnetic trapping On ';'Magnetic trapping Off'];
%
%
compres_luke_jd(ids_equil,ids_wave(select),leglist(select,:),si,opt_rho)