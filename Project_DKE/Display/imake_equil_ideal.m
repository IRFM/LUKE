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
    R_sep = input_dke_yp('Geometrical major radius of the separatrix (m) (R_sep = Inf for the cylindrical limit)',[],[0;Inf],'',[1,1]);
    Z_sep = input_dke_yp('Geometrical vertical shift of the separatrix (m)',0,'','',[1,1]);
    a_sep = input_dke_yp('Geometrical minor radius of the separatrix (m)',[],[0;R_sep],'',[1,1]);
    %
    if e_opt == 1,
        %
        disp(' ');
        info_dke_yp(1,'Parametric description of the separatrix');
        disp(' - R_sep = (R_sep_max + R_sep_min)/2, for the guess')
        disp(' - a_sep = (R_sep_max - R_sep_min)/2, for the guess.')
        disp(' - Z_sep = Z(R_sep_max), for the guess.')
        disp(' - elongation_sep = (Z_sep_max - Z_sep_min)/2 (always positive) (Upper triangularity + Lower triangularity in minor radius unit (m) is approximately elongation_sep*a_sep)')
        disp(' - upper_triangularity_sep = (R_sep - R(Z_sep_max))/2 (always positive). Upper triangularity in minor radius unit (m) = upper_triangularity_sep*a_sep')
        disp(' - lower_triangularity_sep = (R_sep - R(Z_sep_min))/2 (always positive). Lower triangularity in minor radius unit (m) = lower_triangularity_sep*a_sep')
        disp('----------------------------------------------------------------------')
        disp(' If no upper X-point exists, upper separatrix angles at LFS (R,X) and HFS (-R,X) sides have to be set to 0.')
        disp(' If no lower X-point exists, lower separatrix angles at LFS (R,X) and HFS (-R,X) sides have to be set to 0.')
        disp(' If an upper X-point exists, upper separatrix angles at LFS (R,X) + upper separatrix angles at LFS (-R,X) is close to 90 degrees')
        disp(' If an lower X-point exists, lower separatrix angles at LFS (R,X) + lower separatrix angles at LFS (-R,X) is close to 90 degrees')
        disp('----------------------------------------------------------------------')
        info_dke_yp(2,'Default values for xpoint correspond to a plasma with a circular poloidal cross-section.');
        disp('----------------------------------------------------------------------')
        disp(' ');
        %
        xpoint(1) = input_dke_yp('Upper altitude X point in minor radius unit',1,[0;Inf],'',[1,1]);
        xpoint(2) = input_dke_yp('Upper triangularity in minor radius unit (m)',0,[],'',[1,1]);
        xpoint(3) = input_dke_yp('Upper separatrix angle (R,X)  (LFS, degrees)',0,[],'',[1,1]);
        xpoint(4) = input_dke_yp('Upper separatrix angle (-R,X) (HFS, degrees)',0,[],'',[1,1]);
        xpoint(5) = input_dke_yp('Lower altitude X point in minor radius unit (always positive)',1,[0;Inf],'',[1,1]);
        xpoint(6) = input_dke_yp('Lower triangularity in minor radius unit',0,[],'',[1,1]);
        xpoint(7) = input_dke_yp('Lower separatrix angle (R,X)  (LFS, degrees)',0,[],'',[1,1]);
        xpoint(8) = input_dke_yp('Lower separatrix angle (-R,X)  (HFS, degrees)',0,[],'',[1,1]); 
        %
        equil_data.xpoint = xpoint;
    end    
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
        if isinf(R_sep),
            qmin_Rpap = input_dke_yp('Safety factor q0 at plasma center, multiplied by R_sep/a_sep',[],[0;Inf],'',[1,1]);
        else
            qmin_Rpap = R_sep/a_sep*input_dke_yp('Safety factor q0 at plasma center',[],[0;Inf],'',[1,1]);
        end
        disp('qe is calculated from Ampere''s law at the plasma edge with a circular plasma cross-section.')
        eq = input_dke_yp('Exponent for q radial profile',[],[],'',[1,1]);
        %
    else
        qmin_Rpap = NaN;
        eq = NaN;    
    end
    %
    equil_data.Rp = R_sep;
    equil_data.Zp = Z_sep;
    equil_data.ap = a_sep;
    equil_data.Ip = Ip;
    equil_data.Bt = Bt;
    equil_data.qopt = qopt;
    equil_data.qmin_Rpap = qmin_Rpap;
    equil_data.eq = eq;
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
    
