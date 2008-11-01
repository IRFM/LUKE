function [equil_prof,equil_magnetic,prho,pspsin,pspsinT,pkin] = imake_equil_ideal(basestr)
% LUKE - Create an ideal magnetic equilibrium structure for C3PO/LUKE
%
%   Create an ideal magnetic equilibrium structure for C3PO/LUKE. Circular
%   and concentric magnetic flux surfaces. 
%
%   by Y. Peysson (CEA/DSM/IRFM,yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM,joan.decker@cea.fr)
%
npsi = 101;%ONLY 101 radial profile grid points
ntheta = 65;%ONLY 65 poloidal grid points
%
while 1,
    Rp = input_dke_yp('Plasma major radius on axis (m) (Rp = Inf for the cylindrical limit)');
    if ~isempty(Rp),
        break;
    else
        info_dke_yp(2,'WARNING: the value cannot be empty !');
    end
end
%
while 1,
    ap = input_dke_yp('Plasma minor radius on LFS midplane (m)');
    if ~isempty(ap),
        break;
    else
        info_dke_yp(2,'WARNING: the value cannot be empty !');
    end
end
%
while 1,
    Zp = input_dke_yp('Global plasma vertical shift (m)');
    if ~isempty(Zp),
        break;
    else
        info_dke_yp(2,'WARNING: the value cannot be empty !');
    end
end
%
while 1,
    Ip = input_dke_yp('Signed value of the plasma current (MA) (with R,Z,phi direct)');
    if ~isempty(Ip),
        break;
    else
        info_dke_yp(2,'WARNING: the value cannot be empty !');
    end
end
%
while 1,
    Bt = input_dke_yp('Signed value of the toroidal magnetic field on the magnetic axis (T) (with R,Z,phi direct)');
    if ~isempty(Bt),
        break;
    else
        info_dke_yp(2,'WARNING: the value cannot be empty !');
    end
end
%
if ~isinf(Rp),
    %
    qopt = input_dke_yp('Safety factor profile (0): constant (uniform current, psi=rho^2), (1): from qmin and eq',1,{0,1},'Invalid value');
    %
    if qopt,
        while 1,
            qmin = input_dke_yp('Safety factor q0 at plasma center');
            if ~isempty(qmin),
                break;
            else
                info_dke_yp(2,'WARNING: the value cannot be empty !');
            end
        end
    %
        while 1,
            eq = input_dke_yp('Exponent for q radial profile (q = (qmax - qmin)*(r/a).^eq + qmin, qmax calculated by the Ampere''s theorem at the plasma edge with a circular plasma cross-section)  multiplied by Rp/ap');
            if ~isempty(eq),
                break;
            else
                info_dke_yp(2,'WARNING: the value cannot be empty !');
            end
        end
    else
        qmin = NaN;
        eq = NaN;    
    end
else
    qopt = 0;
    qmin = NaN;
    eq = NaN;        
end
%
% Plasma parameters
%
while 1,
    Zi = input_dke_yp('Ion types: (1) H/D/T, (2) He, ..., (6) C [1,p] (WARNING: Zi must be [1,1,1,imp1,imp2] for hydrogen plasmas)');
    mi = input_dke_yp('Ion mass (uma) [1,p] (WARNING: Zi must be [1,2,3,mimp1,mimp2] for hydrogen plasmas)');
    if (length(Zi) == length(mi)) & (length(Zi) > 0) & (length(mi)>0),
        break;
    else
        info_dke_yp(2,'WARNING: inconsistent vector length between Zi and mi !');
    end
end
%
while 1,
    fi = input_dke_yp('Hydrogen isotopic fraction (H/D/T) [1,3] (WARNING: only used when hydrogen plasmas are considered)');
    %
    if (sum(fi) == 1) & (length(fi) > 0),
        break;
    else
        info_dke_yp(2,'WARNING: inconsistent hydrogen isotopic fraction. The sum must be exactly zero !');
    end
end
%
while 1,
    Te0 = input_dke_yp('Core electron temperature (keV)');
    if ~isempty(Te0),
        break;
    else
        info_dke_yp(2,'WARNING: the value cannot be empty !');
    end
end
%
while 1,
    Tea = input_dke_yp('Edge electron temperature (keV)');
    if ~isempty(Tea),
        break;
    else
        info_dke_yp(2,'WARNING: the value cannot be empty !');
    end
end
%
while 1,
    eTe1 = input_dke_yp('Exponent #1 for Te profile (Te(r) = (Te0-Tea)*(1-(r/a)^eTe1)^eTe2 + Tea)');
    if ~isempty(eTe1),
        break;
    else
        info_dke_yp(2,'WARNING: the value cannot be empty !');
    end
end
%
while 1,
    eTe2 = input_dke_yp('Exponent #2 for Te profile (Te(r) = (Te0-Tea)*(1-(r/a)^eTe1)^eTe2 + Tea)');
    if ~isempty(eTe2),
        break;
    else
        info_dke_yp(2,'WARNING: the value cannot be empty !');
    end
end
%
while 1,
    Ti0 = input_dke_yp('Core ion temperature (keV)');
    if ~isempty(Ti0),
        break;
    else
        info_dke_yp(2,'WARNING: the value cannot be empty !');
    end
end
%
while 1,
    Tia = input_dke_yp('Edge ion temperature (keV)');
    if ~isempty(Tia),
        break;
    else
        info_dke_yp(2,'WARNING: the value cannot be empty !');
    end
end
%
while 1,
    eTi1 = input_dke_yp('Exponent #1 for Ti profile (Ti(r) = (Ti0-Tia)*(1-(r/a)^eTi1)^eTi2 + Tia)');
    if ~isempty(eTi1),
        break;
    else
        info_dke_yp(2,'WARNING: the value cannot be empty !');
    end
end
%
while 1,
    eTi2 = input_dke_yp('Exponent #2 for Ti profile (Ti(r) = (Ti0-Tia)*(1-(r/a)^eTi1)^eTi2 + Tia)');
    if ~isempty(eTi2),
        break;
    else
        info_dke_yp(2,'WARNING: the value cannot be empty !');
    end
end
%
while 1,
    ne0 = input_dke_yp('Core electron density (m-3)');
    if ~isempty(ne0),
        break;
    else
        info_dke_yp(2,'WARNING: the value cannot be empty !');
    end
end
%
while 1,
    nea = input_dke_yp('Edge electron density (m-3)');
    if ~isempty(nea),
        break;
    else
        info_dke_yp(2,'WARNING: the value cannot be empty !');
    end
end
%
while 1,
    ene1 = input_dke_yp('Exponent #1 for ne profile (ne(r) = (ne0-nea)*(1-(r/a)^ene1)^ene2 + nea)');
    if ~isempty(ene1),
        break;
    else
        info_dke_yp(2,'WARNING: the value cannot be empty !');
    end
end
%
while 1,
    ene2 = input_dke_yp('Exponent #2 for ne profile (ne(r) = (ne0-nea)*(1-(r/a)^ene1)^ene2 + nea)');
    if ~isempty(ene2),
        break;
    else
        info_dke_yp(2,'WARNING: the value cannot be empty !');
    end
end
%
while 1,
    Zeff0 = input_dke_yp('Core effective charge Zeff (a.u.)');
    if ~isempty(Zeff0),
        break;
    else
        info_dke_yp(2,'WARNING: the value cannot be empty !');
    end
end
%
while 1,
    Zeffa = input_dke_yp('Edge effective charge Zeff (a.u.)');
    if ~isempty(Zeffa),
        break;
    else
        info_dke_yp(2,'WARNING: the value cannot be empty !');
    end
end
%
Zeffopt = input_dke_yp('Effective charge profile (0): Zeff(r) = (Zeff0-Zeffa)*(1-(r/a)^2)^eZeff + Zeffa, (1): 0.5*(Zeffa - Zeff0)*tanh(eZeff*(r - xZeff)) + 0.5*(Zeffa + Zeff0)',0,{0,1},'Invalid value');
%
if Zeffopt,
    while 1,
        eZeff = input_dke_yp('Exponent for the effective charge profile pZeff = 0.5*(Zeffa - Zeff0)*tanh(eZeff*(r - xZeff)) + 0.5*(Zeffa + Zeff0)');
        if ~isempty(eZeff),
            break;
        else
            info_dke_yp(2,'WARNING: the value cannot be empty !');
        end
    end
    %
    while 1,
        xZeff = input_dke_yp('Radial inflexion point for the effective charge profile pZeff = 0.5*(Zeffa - Zeff0)*tanh(eZeff*(r - xZeff)) + 0.5*(Zeffa + Zeff0)');
        %
        if abs(xZeff) <= 1,
            break;
        else
            info_dke_yp(2,'WARNING: Radial inflexion point must be expresssed in normalized units (0 < r/a < 1) !');
        end
    end
else
    while 1,
        eZeff = input_dke_yp('Exponent for the effective charge profile Zeff(r) = (Zeff0-Zeffa)*(1-(r/a)^2)^eZeff + Zeffa');
        if ~isempty(eZeff),
            break;
        else
            info_dke_yp(2,'WARNING: the value cannot be empty !');
        end
    end
    %
    xZeff = NaN;
end
%
% Create ideal magnetic equilibrium
%
[prho,pTe,pne,pzTi,pzni,zZi,zmi,fi,pkin] = idealprof_yp(Zi,mi,fi,Te0,Tea,eTe1,eTe2,ne0,nea,ene1,ene2,Ti0,Tia,eTi1,eTi2,Zeff0,Zeffa,eZeff,xZeff,npsi);%Profiles
%
[ppsin,ppsi_apRp,theta,x,y,Bx,By,BPHI,pBpp,pq_Rpap,pj,pmag,Ip_test,prho,pspsin,pspsinT] = idealequilcyl_yp(ap,Rp,Zp,Bt,Ip,qmin*Rp/ap,eq,qopt,npsi,ntheta);%Cylindrical magnetic equilibrium
%
equil_magnetic.psi_apRp = ppsi_apRp;%psi_apRp = psi(poloidal usual)*ap/Rp for the cylindrical limit
equil_magnetic.theta = theta;
equil_magnetic.ptx = x;
equil_magnetic.pty = y;
equil_magnetic.ptBx = Bx;
equil_magnetic.ptBy = By;
equil_magnetic.ptBPHI = BPHI;
equil_magnetic.Rp = Rp;
equil_magnetic.Zp = Zp;
%
equil_prof.pTe = pTe;
equil_prof.pne = pne;
equil_prof.pzTi = pzTi;
equil_prof.pzni = pzni;
equil_prof.zZi = zZi;
equil_prof.zmi = zmi;
%