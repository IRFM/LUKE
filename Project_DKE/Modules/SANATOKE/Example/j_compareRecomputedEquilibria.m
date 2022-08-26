%% Compare a recomputed equilibrium with the original one
% It enables to test the self consistency of the equilibrium, and the
% proper functioning of the function makeEquilFromLuke.m and makeEquilLuke.m


%% Test the loop equil -> equil_luke_recomputed -> equil_recomputed

equil_recomputed = makeEquilFromLuke(equil_luke_recomputed);
compareEquilRecomputed(equil,equil_recomputed);


%% Test the loop equil_luke_recomputed -> equil_recomputed -> equil_luke_recomputed_2

%%% equil_recomputed = makeEquilFromLuke(equil_luke_recomputed);
%%% amplitudes_recomputed = computeAmplitudes(equil_recomputed);
%%% equil_luke_recomputed_2 = makeEquilLuke(equil_recomputed,amplitudes_recomputed);
%%% testEquilLukeRecomputed(equil_luke_recomputed,equil_luke_recomputed_2);