function [XXsinksource] = sinksourcecoeffbuilder_dke_yp(dkeparam,display,gridDKE,mksa,Zbouncecoef,XXsinksource_in)
%
%   Calculate the external sink and source coefficients for the 3D electron
%   relativistic drift kinetic solver (right-hand side terms of the FP
%   equation. Some sink and source terme may be described by Krook term.
%   See magnetic ripple case for example)
%
%   by Y. Peysson (CEA-DRFC) (yves.peysson@cea.fr) and J. Decker (CEA-DRFC) (joan.decker@cea.fr)
%
%   modified version for runaway implementation (03/07/2007) (D Schmitt)
%
%  Warning : the call line in main must be modified; the number of
%            argument has changed.
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
XXpn2=gridDKE.XXpn2;
Zmask_f0_Tp=Zbouncecoef.Zmask_f0_Tp;
Zmask_f0_Tm=Zbouncecoef.Zmask_f0_Tm;
Zmask_f0_P=Zbouncecoef.Zmask_f0_P;

%
if isempty(XXsinksource_in),XXsinksource = zeros(npn,nmhu,nr);
%
else 
%
if bounce_mode==1
    for ir=1:nr %symetrization of the trapped region
      XXsinksource(:,Zmask_f0_Tp{ir},ir) = ( XXsinksource_in(:,Zmask_f0_Tp{ir},ir) +fliplr(XXsinksource_in(:,Zmask_f0_Tm{ir},ir)) )/2;  
      XXsinksource(:,Zmask_f0_Tm{ir},ir) = XXsinksource_in(:,Zmask_f0_Tm{ir},ir); % symetrization useless here
      XXsinksource(:,Zmask_f0_P{ir},ir )= XXsinksource_in(:,Zmask_f0_P{ir},ir);
    end
else XXsinksource=XXsinksource_in;
end
%
% partial Jacobian multiplication to avoid singularities, and normalization
XXsinksource = XXsinksource/(mksa.nhu_ref*mksa.ne_ref);
end
%
%