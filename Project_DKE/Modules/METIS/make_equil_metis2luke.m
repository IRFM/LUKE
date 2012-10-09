function [equil,profil0d] = make_equil_metis2luke(equil_id,profil0d_in,zerod,exp0d,cons,geo,option,equilparam)
%
% creates LUKE equilibrium structure from METIS output
%
% MAGNETIC EQUILIBRIUM
%
if equilparam.helena >= 1,
    %
    % ***** 2D equilibrium reconstructed by Helena *****
    %
    post.profil0d = profil0d_in;
    post.zerod = zerod;
    post.z0dinput.exp0d = exp0d;
    post.z0dinput.cons = cons;
    post.z0dinput.geo = geo;
    post.z0dinput.option = option;
    %
    if equilparam.helena == 1,% use helena to recalculate equilibrium
        %
        equi = z0dhelena(post,0);
        equil = make_equil_magnetic_cronos(equi);
        %
        xli = equi.a/equi.a(end);
        Raxe = equi.raxe;
        kx = equi.e;
        dx = equi.d;
        %
    else
        %
        [filename,pathname] = uigetfile('EQUIL_*.mat','Choose equilibrium file');
        %
        load([pathname,filename],'equil');
        %
        if ~isfield(equil,'pli'),
            disp('warning : pli data not available, using circular low beta approximation')
            xli = (equil.ptx(:,1) - equil.ptx(:,(end+1)/2))/(equil.ptx(end,1) - equil.ptx(end,(end+1)/2));
        else
            xli = equil.pli/equil.pli(end);
        end
        %
        Raxe = NaN;
        kx = NaN;
        dx = NaN;
        %
    end
    %
    profil0d.xli = xli;
    profil0d.tep = interp1(profil0d_in.xli,profil0d_in.tep,profil0d.xli,'pchip','extrap');
    profil0d.tip = interp1(profil0d_in.xli,profil0d_in.tip,profil0d.xli,'pchip','extrap');
    profil0d.nep = interp1(profil0d_in.xli,profil0d_in.nep,profil0d.xli,'pchip','extrap');
    profil0d.n1p = interp1(profil0d_in.xli,profil0d_in.n1p,profil0d.xli,'pchip','extrap');
    profil0d.nhep = interp1(profil0d_in.xli,profil0d_in.nhep,profil0d.xli,'pchip','extrap');
    profil0d.nzp = interp1(profil0d_in.xli,profil0d_in.nzp,profil0d.xli,'pchip','extrap');
    %
    profil0d.epar = interp1(profil0d_in.xli,profil0d_in.epar,profil0d.xli,'pchip','extrap');
    %
    % trois lignes suivantes à vérifier
    %
    profil0d.Raxe = Raxe;
    profil0d.kx = kx;
    profil0d.dx = dx;
    %
    % sign management
    %
    sigmaB = sign(equil.ptBPHI(1,1));
    sigmaI = sign(equil.ptBy(end,1));
    %
    equil.ptBPHI = sigmaB*option.bsigne*equil.ptBPHI;
    equil.ptBx = sigmaI*option.bsigne*option.signe*equil.ptBx;
    equil.ptBy = sigmaI*option.bsigne*option.signe*equil.ptBy;
    equil.psi_apRp = sigmaI*option.bsigne*option.signe*equil.psi_apRp;
    %
else
    %
    % ***** 2D equilibrium from moments by metis2equi1t ***** 
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
    % In METIS, deuxd.BPHI is always positive, the
    % relative sign of Ip is prescribed by option.signe
    %
    equil.Rp = deuxd.R(1,1);
    equil.Zp = deuxd.Z(1,1);
    %
    equil.ptx = deuxd.R - equil.Rp;
    equil.pty = deuxd.Z - equil.Zp;
    equil.ptBx = - option.bsigne*option.signe*deuxd.BR;
    equil.ptBy = - option.bsigne*option.signe*deuxd.BZ;
    equil.ptBPHI = option.bsigne*deuxd.BPHI;
    %
    equil.psi_apRp = - option.bsigne*option.signe*(profil.psi - profil.psi(1))*equil.ptx(end,1)/equil.Rp;
    equil.theta = linspace(0,2*pi,nt);
    %
end
%
if equil.psi_apRp(end)*equil.ptBy(end,1) < 0,
    disp('Warning : equilibrium signs not self-consistent')
end
%
if equil.psi_apRp(end)*equil.ptBPHI(1,1)*option.signe < 0,
    disp('Warning : equilibrium signs not consistent with option.signe')
end
%
if equil.ptBPHI(1,1)*option.bsigne < 0,
    disp('Warning : equilibrium signs not consistent with option.bsigne')
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
equil.ip = zerod.ip;% plasma current in A
equil.iohm = zerod.iohm;% ohmic current in A
equil.iboot = zerod.iboot;% bootstrap current in A
%
% modify after error correction in METIS
%
equil.icd = zerod.ipar - zerod.iohm - equil.iboot;% zerod.icd;% zerod.ini - equil.iboot;
%
if equilparam.comp,
    %
    if equilparam.helena == 'y',
        leg = {'METIS - orig.','HELENA','LUKE'};
    else
        leg = {'METIS - orig.','METIS - interp.','LUKE'};
    end
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
    %
end
%
equil.id = equil_id;
%
























