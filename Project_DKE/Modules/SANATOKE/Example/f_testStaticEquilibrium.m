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
%% Test the static equilibrium equilibrium condition jxB = gradP


%% Test this condition on the 'Ludwig-type' equilibrium
plotStaticEquilibrium(equil,amplitudes);


%% Test the conditions on the Luke equilbrium
%%% testEquilConsistency_luke(equil_luke_recomputed);