function [Zlossmripple] = mripplecoefbuilder_dke_yp(dkeparam,display,equil,equilDKE,gridDKE,mksa,ripple)
%
%   Calculate magnetic ripple coefficients for the 3D electron relativistic drift kinetic solver.
%
%   by Y. Peysson (CEA-DRFC) (yves.peysson@cea.fr) and J. Decker (CEA-DRFC) (joan.decker@cea.fr)
%
%
npn = gridDKE.npn;
nmhu = gridDKE.nmhu;
nr = gridDKE.nr;
xrho = gridDKE.xrho; 
%
display_mode = display.display_mode;
%
XXlossripple = zeros(npn,nmhu,nr);%Defined on the distribution function grid (half grid)
xdeltaripple = zeros(size(xrho));
xdeltaripple = zeros(size(xrho));
xNq = zeros(size(xrho));
Xnhuloss = zeros(npn,nmhu);
xthetabanana = zeros(size(xrho));
xthetaloss = zeros(size(xrho));
xpndetrap = zeros(size(xrho));
xEseuil = zeros(size(xrho));
%
if ~isempty(ripple) & ((isstruct(ripple) & ripple.mode == 1),
    etime_rip = 0;
    time0 = clock;
    %
    bounce_mode = dkeparam.bounce_mode;
    %
    xne = equilDKE.xne;
    xBT0 = equilDKE.xBT0;
    xZeff = equilDKE.xZeff;
    ap = equilDKE.ap;
    Rp = equilDKE.Rp;
    %
    Xpn = gridDKE.Xpn;
    Xmhu = gridDKE.Xmhu;
    %
    tokname = equil.id;%Tokamak name
    %
    xnhuloss = ones(size(xrho))*1000;%Normalized to the reference frequency(forced to very large loss frequency, otherwise no physical meaning)
    %
    for ir = 1:nr,
		if isnan(xnhuloss(ir)) == 0 & bounce_mode == 1 & ~isempty(findstr(tokname,'TS')) == 1,%WARNING: only valid for the TORE SUPRA tokamak with large magnetic ripple
			if ir == 1, 
				info_dke_yp(2,'WARNING: Ripple losses calculations only valid for Tore Supra tokamak, see main_dke_1yp.m for BeLi, Ip and Ncoils values');
				disp('-------------------------------------------------------------------------------------------------------------------');
				Ip = 0.61;%MA (For magnetic equilibrium in the magnetic ripple routine)
				BeLi = 1.0;%For magnetic equilibrium in the magnetic ripple routine
			end
%			Ncoils = 1;%Ncoils is here forced to 1, as prescribed in Ref. M. Ju et al., Phys. Plasmas, 9 (2002) 493. Upper bound of ripple losses is then calculated
%			xNq(ir) = Ncoils*xq(ir);%Exact N may be used but large values may lead to numerical instabilities due to round-off errors
			[xthetabanana(ir),xthetaloss(ir),pndetrap,xEseuil(ir),xdeltaripple(ir)] = detrapmj3(xZeff(ir),ap,xBT0(ir),Rp,BeLi,Ip,xne(ir),xrho(ir));%WARNING: Only valid for the TORE SUPRA tokamak
			xpndetrap(ir) = pndetrap/mksa.betath_ref;
%
			xmhusupertrap(ir) = sin(pi*xthetaloss(ir)/180);
			Xmaskrip = (Xpn > xpndetrap(ir)).*(abs(Xmhu) < xmhusupertrap(ir));
			Xnhuloss = Xmaskrip*xnhuloss(ir);
		else
			if isnan(xnhuloss(ir)) == 0 & bounce_mode == 1 & isempty(findstr(tokname,'TS')) == 1
				if ir == 1, 
					info_dke_yp(2,'WARNING: Ripple losses calculations only valid for Tore Supra tokamak. Wrong tokamak name');
					disp('-------------------------------------------------------------------------------------------------------------------');
				end
			elseif isnan(xnhuloss(ir)) == 0 & bounce_mode == 0 & isempty(findstr(tokname,'TS')) == 0
				if ir == 1, 
					info_dke_yp(2,'WARNING: Ripple losses calculations only valid for bounce averaged calculations');
					disp('-------------------------------------------------------------------------------------------------------------------');
				end
			end	
		end
		XXlossripple(:,:,ir) = Xnhuloss;%Magnetic ripple loss term is expressed in a Krook term
    end
    %
    etime_rip = etime_rip + etime(clock,time0);
    if display_mode >= 1,info_dke_yp(2,['Magnetic ripple coefficients calculations done in ',num2str(etime_rip),' (s)']);end	
end
%
%if isempty(XXsource),XXsource = zeros(npn,nmhu,nr);end
%XXsource = XXsource/mksa.ne_ref/mksa.nhu_ref;%Source or sink terms
%
Zlossmripple.XXlossripple = XXlossripple;
Zlossmripple.xdeltaripple = xdeltaripple;
Zlossmripple.xNq = xNq;
Zlossmripple.Xnhuloss = Xnhuloss;
Zlossmripple.xthetabanana = xthetabanana;
Zlossmripple.xthetaloss = xthetaloss;
Zlossmripple.xpndetrap = xpndetrap;
Zlossmripple.xEseuil = xEseuil;
%
 
