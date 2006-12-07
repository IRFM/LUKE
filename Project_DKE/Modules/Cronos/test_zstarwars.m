%Program test for zstarwars function
%
load contexte_input_starwars.mat
[sortie] = zstarwars;
[sortie,memoire] = zstarwars(par,proto,cons,experience,geo,equi,injection,prof,neo,impur,phy,compo,gene,memoire);
