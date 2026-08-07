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
function testIphi_luke(equil,equil_luke)

psin = equil_luke.psi_apRp/equil_luke.psi_apRp(end);
rhos_luke = psi2rho_jd(equil_luke,psin)';
if size(rhos_luke,1)==1
    rhos_luke = rhos_luke';
end
thetas_luke = 0:pi/50:2*pi;

equil_fit = fitequil_yp(equil_luke);
equil_val = equilval_yp(equil_fit,rhos_luke,thetas_luke);

Iphi = Iphi_luke(rhos_luke,thetas_luke,equil_val);

figure;
plot(rhos_luke,Iphi./1e6);
title('Toroidal current');
xlabel('\rho (m)');
ylabel('IT (MA)');

disp("Recomputed IT(a) = " + num2str(Iphi(end)./1e6) + " MA");
disp("IT(a) in equil : " + num2str(equil.current.IT.IT_a./1e6) + " MA");
disp("IT(a) in equil_luke_rec : " + num2str(Iphi(end)./1e6) + " MA");

[~,ind_pi] = min(abs(thetas_luke-pi));
R = equil_luke.Rp+equil_val.x;
Z = equil_luke.Zp+equil_val.y;

jphi = jphi_luke(rhos_luke,thetas_luke,equil_val);
figure;
plot(cat(1,flip(R(:,ind_pi)),R(:,1)),cat(1,flip(jphi(:,ind_pi)),jphi(:,1))./1e6);
title('jt equatorial');
xlabel('R (m)');
ylabel('jt (MA/m²)');

%{
figure;
plot(equil.rhos,drhoIT./1e6);
title('jt(\rho) integrated in \theta');
xlabel('\rho (m)');
ylabel('jt (MA/m)');
%}

figure;
contourf(R,Z,jphi./1e6);
title('jt(R,Z)');
c = colorbar;
c.Label.String = 'jt (MA/m²)';
axis equal;
xlabel('R (m)');
ylabel('Z (m)');

BP = equil_val.BP;
figure;
plot(cat(1,flip(R(:,ind_pi)),R(:,1)),cat(1,flip(BP(:,ind_pi)),BP(:,1)));
title('BP equatorial');
xlabel('R (m)');
ylabel('BP (T)');

end

