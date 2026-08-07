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
%% How to compute an input equilibrium
% comment/uncomment the lines with %%% depending on what you want to test

%% First example : an equilibrium as parametrized by G.O. Ludwig in his article
% To change the parameters of this equilibrium, you can directly modifify the values in makeEquilLudwig.m

equil = makeEquilLudwig;



%% Second example : a circular equilibrium
% syntax to use: makeEquilCirculsear(major radius, vertical position of the geometrical centre, minor radius)

%%% equil = makeEquilCircular(3,0,1);



%% Third example : compute an equilibrium from a LUKE equilibrium
% equil_luke is a LUKE equilibrium
% a set of LUKE equilibria is provided in the folder 'Luke_EQUIL_files'
% the Equil_JETh77.mat file is used below as an example

%%% equil_luke = open("Equil_JETh77.mat").equil_luke;
%%% equil = makeEquilLuke(equil_luke);