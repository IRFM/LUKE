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