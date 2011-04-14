function [equil,profil0d] = make_equil_metis2luke(equil_id,profil0d_in,zerod,geo,option,equilparam)
%
% creates LUKE equilibrium structure from METIS output
%
equil.id = equil_id;
%
% MAGNETIC EQUILIBRIUM
%
nt = 65;% number of poloidal grid points
%
% see function mapequilibrium for call to metis2equi1t
%
% constante physique (phys)
phys.c           =   2.99792458e8;             % vitesse de la lumiere dans le vide (m/s)  (definition)
phys.h           =   6.62606876e-34;           % constante de Planck (J*s) (+/- 0.0000052e-34)
phys.e           =   1.602176462e-19;          % charge de l'electron (C)   (+/- 0.000000063e-19)
phys.mu0         =   4*pi*1e-7;                % permeabilite du vide (H/m) (definition)
phys.epsi0       =   1./phys.c.^2./phys.mu0;   % permitivite du vide (F/m)  (definition)
phys.g           =   6.673e-11;                % constante de la gravitation (N*m^2/kg^2) (+/- 0.010e-11)
phys.k           =   1.3806503e-23;            % constante de Boltzmann (J/K)  (+/- 0.0000024e-23)
phys.alpha       =   7.297352533e-3 ;          % constante de structure fine (+/- 0.000000027e-3 )
phys.me          =   9.10938188e-31;           % masse au repos de l'electron (kg) (+/- 0.00000079e-31)
phys.mp          =   1.6726485e-27;            % masse au repos du proton (kg)
phys.ua          =   1.66053873e-27;           % 1 unite atomique (kg) (+/- 1.00000013e-27)
phys.avo         =   6.02214199e23;            % nombre d'avogadro (mol^-1) (+/- 0.00000047e23)
phys.sigma       =   5.670400e-8;              % constante de stephan ( W*m^-2*K^-4) (+/- 0.000040e-8)
%    
% spread equilibrium data on interpolated grid
%
if equilparam.nbpx > 0,
    profil0d = z0dinterpx(profil0d_in,equilparam.nbpx,equilparam.mode);
else
    profil0d = profil0d_in;
end
%
prof.x    = profil0d.xli;
prof.kx   = profil0d.kx;     
prof.dx   = profil0d.dx;      
prof.rmx  = profil0d.rmx;     
prof.Raxe = profil0d.Raxe;
prof.psi  = profil0d.psi;
prof.fdia = profil0d.fdia;
prof.jmoy = profil0d.jli;
prof.ptot = profil0d.ptot;
%
if isfield(profil0d,'Rsepa') && isfield(profil0d,'Zsepa') && all(isfinite(profil0d.Rsepa(:))) && all(isfinite(profil0d.Zsepa(:)))
    geo.Rsepa = profil0d.Rsepa;
    geo.Zsepa = profil0d.Zsepa;
else
    geo.Rsepa = [];
    geo.Zsepa = []; 
    equilparam.expo = 0;
end
%
%[profil,deuxd,moment,scalaire,facteur] = metis2equi1t(profil,geo,phys,nbth,facteur,exposhape,regularisation);
%
% facteur is a dummy argument for now (02/01/2011)
%
[profil,deuxd] = metis2equi1t(prof,geo,phys,nt,1,equilparam.expo,0);
%
% In METIS, the sign of BPHI is set to be counter-clockwise from top, the
% relative sign of Ip is prescribed by option.signe
%
equil.Rp = deuxd.R(1,1);
equil.Zp = deuxd.Z(1,1);
%
equil.ptx = deuxd.R - equil.Rp;
equil.pty = deuxd.Z - equil.Zp;
equil.ptBx = option.signe*deuxd.BR;
equil.ptBy = option.signe*deuxd.BZ;
equil.ptBPHI = - deuxd.BPHI;% always negative
%
equil.psi_apRp = option.signe*(profil.psi - profil.psi(1))*equil.ptx(end,1)/equil.Rp;
equil.theta = linspace(0,2*pi,nt);
%
if equil.psi_apRp(end)*equil.ptBy(end,1) < 0,
    disp('Warning : equilibrium signs not self-consistent')
end
%
if equil.psi_apRp(end)*equil.ptBPHI(1,1)*option.signe < 0,
    disp('Warning : equilibrium signs not consistent with option.signe')
end
%
% EQUILIBRIUM PROFILES
%
% see function ./zerod/z0dacces
%
equil.pTe = profil0d.tep/1e3;
equil.pne = profil0d.nep;
%
zimp = fix(option.zimp);
aimp = fix(zimp*7/3);
zmax = fix(option.zmax);
amax = fix(zmax*7/3);
%
if strcmp(option.mino,'He3'),
    ahe = 3;
else
    ahe = 4;
end
%
equil.zZi = [1,1,1,2,zimp,zmax];
equil.zmi = [1,2,3,ahe,aimp,amax];
%
fD = zerod.nDm/zerod.n1m;
fT = zerod.nTm/zerod.n1m;
fH = max([0,1-fD-fT]);
%
equil.fi = [fH,fD,fT];
pzni1 = equil.fi.'*profil0d.n1p;
%
pnhe = profil0d.nhep;
pnimp = profil0d.nzp;
pnmax = profil0d.nzp*option.rimp;
%
equil.pzni = [pzni1;pnhe;pnimp;pnmax];
%
equil.pzTi = ones(length(equil.zZi),1)*profil0d.tip/1e3;
%
% calculation of moments from the LUKE equilibrium
%
[equil.pshift,equil.pelong,equil.ptrian,equil.pli] = equilmoments_jd(equil.theta,equil.ptx,equil.pty);
%
if equilparam.comp,
    %
    leg = {'METIS - orig.','METIS - interp.','LUKE'};
    %
    figure(101),clf
    plot(profil0d_in.xli,profil0d_in.Raxe - equil.Rp,'b-o',profil0d.xli,profil0d.Raxe - equil.Rp,'m-+',equil.pli,equil.pshift,'r--s')
    title('Shafranov shift (m)');legend(leg);
    %
    figure(102),clf
    plot(profil0d_in.xli,profil0d_in.kx,'b-o',profil0d.xli,profil0d.kx,'m-+',equil.pli,equil.pelong,'r--s')
    title('Elongation');legend(leg);
    %
    figure(103),clf
    plot(profil0d_in.xli,profil0d_in.dx,'b-o',profil0d.xli,profil0d.dx,'m-+',equil.pli,equil.ptrian,'r--s')
    title('Triangularity');legend(leg);
end

























