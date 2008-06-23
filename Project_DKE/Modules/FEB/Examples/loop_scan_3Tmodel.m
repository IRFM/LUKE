function [norm,curr,Tph,Tph_star] = loop_scan_3Tmodel(iEcut,frac,Ecut,Tpar,Tperp,Tback,Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,hxr,hxrparam,fieldside,chordview,hxr,hxrparam,fieldside,chordview)
%
%
%
norm = zeros(length(Tpar),length(Tperp));
curr = zeros(length(Tpar),length(Tperp));
Tph = zeros(length(Tpar),length(Tperp));
Tph_star = zeros(length(Tpar),length(Tperp));
%
dt = 1;%integration time step (s)
%
f3tempmodel(equilDKE,gridDKE,frac,Tpar,Tperp,Tback,Ecut);

[Zbremchord,equilHXR] = bremchord_dke_yp(dkeparam,dkedisplay,equil,radialDKE,Zcurr,hxr,hxrparam);
[Zbremplasma] = bremsstrahlung_dke_yp(dkeparam,dkedisplay,equilHXR,radialDKE,mksa,momentumDKE,dke_out,Zbremchord,hxr,hxrparam,fieldside,chordview);%No magnetic field line effect (perp view)
[Zbremdiag] = bremdiag_dke_yp(Zbremplasma,hxr,hxrparam,dt);
%
norm(ivmin,ivmax) = Znorm.x_0(1);
curr(ivmin,ivmax) = Zcurr.x_0(1);
Tph(ivmin,ivmax) = Zbremdiag.tphot_plasma;
Tph_star(ivmin,ivmax) = Zbremdiag.tphot_plasma_exp;
end


