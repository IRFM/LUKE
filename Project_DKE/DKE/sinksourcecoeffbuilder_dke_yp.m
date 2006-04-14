function [XXsinksource] = sinksourcecoeffbuilder_dke_yp(dkeparam,display,equil,equilDKE,gridDKE,mksa,XXsinksource_in)
%
%   Calculate the external sink and source coefficients for the 3D electron
%   relativistic drift kinetic solver (right-hand side terms of the FP
%   equation. Some sink and source terme may be described by Krook term.
%   See magnetic ripple case for example)
%
%   by Y. Peysson (CEA-DRFC) (yves.peysson@cea.fr) and J. Decker (CEA-DRFC) (joan.decker@cea.fr)
%
time0 = clock;
timeCPU0 = cputime;
memoryLU_f = 0;
memoryLU_g = 0;
%
bounce_mode = dkeparam.bounce_mode;
%
display_mode = display.display_mode;
%
npn = gridDKE.npn;
nmhu = gridDKE.nmhu;
nr = gridDKE.nr;
%
if isempty(XXsinksource_in),XXsinksource = zeros(npn,nmhu,nr);end
XXsinksource = XXsinksource/mksa.ne_ref/mksa.nhu_ref;%Source or sink terms (normalized units)
%
