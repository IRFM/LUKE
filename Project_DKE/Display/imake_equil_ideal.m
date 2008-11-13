function [equil_data,shotnum,shotime] = imake_equil_ideal(e_opt)
%
% LUKE - Create an ideal magnetic equilibrium structure for C3PO/LUKE
%
%   Create an ideal magnetic equilibrium structure for C3PO/LUKE. Circular
%   and concentric magnetic flux surfaces. 
%
%   by Y. Peysson (CEA/DSM/IRFM,yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM,joan.decker@cea.fr)
%
if nargin < 1,
    e_opt = NaN;
end
%
shotnum = '';
shotime = '';
%
if ~isnan(e_opt),% magnetic equilibrium data
    %
    disp(' ');
    info_dke_yp(1,'Manual equilibrium construction : please provide the following data : ')
    disp(' ');
    %
    shotnum = input_dke_yp('Shot number','');
    shotime = input_dke_yp('Shot time',[],'','',[1,1]);
    %
    shotime = num2str(shotime,'%6.4f');
    %
    Rp = input_dke_yp('Plasma major radius on axis (m) (Rp = Inf for the cylindrical limit)',[],[0;Inf],'',[1,1]);
    Zp = input_dke_yp('Plasma vertical position on axis (m)',0,'','',[1,1]);
    ap = input_dke_yp('Plasma minor radius on LFS midplane (m)',[],[0;Rp],'',[1,1]);
    %
    Ip = input_dke_yp('Signed value of the plasma current (MA) (positive if clockwise in top view)',[],'','',[1,1]);
    Bt = input_dke_yp('Signed value of the toroidal magnetic field on axis (T) (positive if clockwise in top view)',[],'','',[1,1]);
    %
    qopt = input_dke_yp(['Safety factor profile : ',...
        '\n(0) constant (uniform current density, psi=rho^2)',...
        '\n(1) profile ofthe form : q = q0 + (qe-q0)*rho^eq'],...
        0,{0,1},'Invalid value');
    %
    if qopt == 1,
        %
        if isinf(Rp),
            qmin_Rpap = input_dke_yp('Safety factor q0 at plasma center, multiplied by Rp/ap',[],[0;Inf],'',[1,1]);
        else
            qmin_Rpap = Rp/ap*input_dke_yp('Safety factor q0 at plasma center',[],[0;Inf],'',[1,1]);
        end
        disp('qe is calculated from Ampere''s law at the plasma edge with a circular plasma cross-section.')
        eq = input_dke_yp('Exponent for q radial profile',[],[],'',[1,1]);
        %
    else
        qmin_Rpap = NaN;
        eq = NaN;    
    end
    %
    equil_data.Rp = Rp;
    equil_data.Zp = Zp;
    equil_data.ap = ap;
    equil_data.Ip = Ip;
    equil_data.Bt = Bt;
    equil_data.qopt = qopt;
    equil_data.qmin_Rpap = qmin_Rpap;
    equil_data.eq = eq;
    %
    if e_opt == 1,
        %
        info_dke_yp(1,'Shape of the separatrix');
        %
        xpoint(1) = input_dke_yp('Vertical position of the top X point (circular = 1) (m)',1,[0;Inf],'',[1,1]);
        xpoint(2) = input_dke_yp('Horizontal position of the top X point (circular = 0) (m)',0,[],'',[1,1]);
        xpoint(3) = input_dke_yp('Angle between the separatrix and the horizontal plane for the top X point (degree) (circular = 0)',0,[],'',[1,1]);
        xpoint(4) = input_dke_yp('Angle between the separatrix and the horizontal plane for the top X point (degree) (circular = 0)',0,[],'',[1,1]);
        xpoint(5) = input_dke_yp('Vertical position of the bottom X point (always positive value) (circular = 1) (m)',1,[0;Inf],'',[1,1]);
        xpoint(6) = input_dke_yp('Horizontal position of the bottom X point (circular = 0) (m)',0,[],'',[1,1]);
        xpoint(7) = input_dke_yp('Angle between the separatrix and the horizontal plane for the bottom X point (degree) (circular = 0)',0,[],'',[1,1]);
        xpoint(8) = input_dke_yp('Angle between the separatrix and the horizontal plane for the bottom X point (degree) (circular = 0)',0,[],'',[1,1]); 
        %
        equil_data.xpoint = xpoint;
    end
    %
else % equilibrium profiles data
    %
    Zimp = input_dke_yp('Impurity charge (6 for carbon)',6,[],'',[1,1]);
    mimp = input_dke_yp('Impurity mass (uma)',12,[],'',[1,1]);
    fi = input_dke_yp('Hydrogen isotopic fraction (H/D/T) [1,3]',[0,0.5,0.5],[],'',[1,3]);
    %
    Te0 = input_dke_yp('Core electron temperature (keV)',[],[],'',[1,1]);
    Tea = input_dke_yp('Edge electron temperature (keV)',[],[],'',[1,1]);
    eTe1 = input_dke_yp('Exponent #1 for Te profile (Te(r) = (Te0-Tea)*(1-(r/a)^eTe1)^eTe2 + Tea)',[],[],'',[1,1]);
    eTe2 = input_dke_yp('Exponent #2 for Te profile (Te(r) = (Te0-Tea)*(1-(r/a)^eTe1)^eTe2 + Tea)',[],[],'',[1,1]);
    %
    Ti0 = input_dke_yp('Core ion temperature (keV)',[],[],'',[1,1]);
    Tia = input_dke_yp('Edge ion temperature (keV)',[],[],'',[1,1]);
    eTi1 = input_dke_yp('Exponent #1 for Ti profile (Ti(r) = (Ti0-Tia)*(1-(r/a)^eTi1)^eTi2 + Tia)',[],[],'',[1,1]);
    eTi2 = input_dke_yp('Exponent #2 for Ti profile (Ti(r) = (Ti0-Tia)*(1-(r/a)^eTi1)^eTi2 + Tia)',[],[],'',[1,1]);
    %
    ne0 = input_dke_yp('Core electron density (m-3)',[],[],'',[1,1]);
    nea = input_dke_yp('Edge electron density (m-3)',[],[],'',[1,1]);
    ene1 = input_dke_yp('Exponent #1 for ne profile (ne(r) = (ne0-nea)*(1-(r/a)^ene1)^ene2 + nea)',[],[],'',[1,1]);
    ene2 = input_dke_yp('Exponent #2 for ne profile (ne(r) = (ne0-nea)*(1-(r/a)^ene1)^ene2 + nea)',[],[],'',[1,1]);
    %
    Zeff0 = input_dke_yp('Core effective charge Zeff (a.u.)',1,[1;Zimp],'',[1,1]);
    Zeffa = input_dke_yp('Edge effective charge Zeff (a.u.)',1,[1;Zimp],'',[1,1]);
    Zeffopt = input_dke_yp(['Effective charge profile :\n',...
        '(0): Zeff(r) = (Zeff0-Zeffa)*(1-(r/a)^2)^eZeff + Zeffa,\n',...
        '(1): 0.5*(Zeffa - Zeff0)*tanh(eZeff*(r - xZeff)) + 0.5*(Zeffa + Zeff0)\n'],...
        0,{0,1},'Invalid value',[1,1]);
    eZeff = input_dke_yp('Exponent for the effective charge profile',[],[],'',[1,1]);
    %
    if Zeffopt == 1,
        xZeff = input_dke_yp('Radial inflexion point for the effective charge profile',[],[0;1],'',[1,1]);
    else
        xZeff = NaN;
    end
    %
    equil_data.Zi = [1,1,1,Zimp];
    equil_data.mi = [1,2,3,mimp];
    equil_data.fi = fi;
    equil_data.Te0 = Te0;
    equil_data.Tea = Tea;
    equil_data.eTe1 = eTe1;
    equil_data.eTe2 = eTe2;
    equil_data.ne0 = ne0;
    equil_data.nea = nea;
    equil_data.ene1 = ene1;
    equil_data.ene2 = ene2;
    equil_data.Ti0 = Ti0;
    equil_data.Tia = Tia;
    equil_data.eTi1 = eTi1;
    equil_data.eTi2 = eTi2;
    equil_data.Zeff0 = Zeff0;
    equil_data.Zeffa = Zeffa;
    equil_data.eZeff = eZeff;
    equil_data.xZeff = xZeff;
    %
end
%
    
