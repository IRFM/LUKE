% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function testEquilLukeRecomputed(equil_luke,equil_luke_recomputed)

% Equilibrium geometry
disp("Initial Rp = "+num2str(equil_luke.Rp)+" m   /   Recomputed Rp = "+num2str(equil_luke_recomputed.Rp)+" m");
disp("Initial Zp = "+num2str(equil_luke.Zp)+" m   /   Recomputed Zp = "+num2str(equil_luke_recomputed.Zp)+" m");


[~,ind_pi1] = min(abs(equil_luke.theta-pi));
R1 = equil_luke.Rp+equil_luke.ptx;
Z1 = equil_luke.Zp+equil_luke.pty;

[~,ind_pi2] = min(abs(equil_luke_recomputed.theta-pi));
R2 = equil_luke_recomputed.Rp+equil_luke_recomputed.ptx;
Z2 = equil_luke_recomputed.Zp+equil_luke_recomputed.pty;

% Plasma boundary
figure;
plot(R1(end,:),Z1(end,:),R2(end,:),Z2(end,:));
legend('Initial','Recomputed');
xlabel('R (m)');
ylabel('Z (m)');
title('Plamsma boundary');
axis equal;

% Density profile
figure;
plot(equil_luke.psi_apRp,equil_luke.pne./1e3,equil_luke_recomputed.psi_apRp,equil_luke_recomputed.pne./1e3);
legend('Initial','Recomputed');
title('Electron density profile');
xlabel('psi\_apRp');
ylabel('ne (kPa)');

% Temperature
figure;
plot(equil_luke.psi_apRp,equil_luke.pTe,equil_luke_recomputed.psi_apRp,equil_luke_recomputed.pTe);
legend('Initial','Recomputed');
title('Electron temperature profile');
xlabel('psi\_apRp');
ylabel('Te (keV)');

% Magnetic field

% BT equatorial
figure;
BT1 = equil_luke.ptBPHI;
BT2 = equil_luke_recomputed.ptBPHI;
plot(cat(1,flip(R1(:,ind_pi1)),R1(:,1)),cat(1,flip(BT1(:,ind_pi1)),BT1(:,1)),...
    cat(1,flip(R2(:,ind_pi2)),R2(:,1)),cat(1,flip(BT2(:,ind_pi2)),BT2(:,1)));
legend('Initial','Recomputed');
title('BT equatorial');
xlabel('R (m)');
ylabel('BP (T)');

% BP equatorial
figure;
BP1 = sqrt(equil_luke.ptBx.^2+equil_luke.ptBy.^2);
BP2 = sqrt(equil_luke_recomputed.ptBx.^2+equil_luke_recomputed.ptBy.^2);
plot(cat(1,flip(R1(:,ind_pi1)),R1(:,1)),cat(1,flip(BP1(:,ind_pi1)),BP1(:,1)),...
    cat(1,flip(R2(:,ind_pi2)),R2(:,1)),cat(1,flip(BP2(:,ind_pi2)),BP2(:,1)));
legend('Initial','Recomputed');
title('BP equatorial');
xlabel('R (m)');
ylabel('BP (T)');
end

