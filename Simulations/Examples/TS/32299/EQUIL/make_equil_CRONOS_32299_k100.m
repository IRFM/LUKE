% script make_equil_CRONOS_32299_k100
%
clear all
%
load ('../gigajoule_pouryves_luke.mat','dkeparam','dkedisplay','transpfaste','ohm','ripple','wavestructs','shot','equi','gene','prof','compo','impur');%data file from cronos
equil = make_equil_cronos(shot,equi,gene,prof,compo,impur);
%
save EQUIL_CRONOS_32299_k100.mat equil
