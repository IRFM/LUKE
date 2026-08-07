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