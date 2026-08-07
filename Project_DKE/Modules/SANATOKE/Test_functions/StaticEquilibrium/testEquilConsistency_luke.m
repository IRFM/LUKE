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
function testEquilConsistency_luke(equil_luke)
    
[~,gradpthermalsgradrho,gradpmagsgradrho] = equilconsistency_yp(equil_luke);

rhos = linspace(0,1,length(gradpthermalsgradrho))';
nthetas = size(gradpmagsgradrho,2);

figure;
sgtitle('Comparison of thermal and magnetic pressure gradients');

for i=1:6
    subplot(3,2,i)
    plot(rhos,gradpthermalsgradrho/.1e6,rhos,gradpmagsgradrho(:,floor((i-1)*nthetas/6)+1)/.1e6);
    legend('Thermal','Magnetic');
    xlabel('\rho');
    ylabel('\nablaP / \nabla\rho (MPa/m)');
    switch i
        case 1
            name_theta = "0";
        case 2
            name_theta = "\pi/3";
        case 3
            name_theta = "2\pi/3";
        case 4
            name_theta = "\pi";
        case 5
            name_theta = "4\pi/3";
        case 6
            name_theta = "5\pi/3";
    end
    title("Profiles at \theta = "+name_theta);
end

figure;
plot(rhos,gradpthermalsgradrho/.1e6,rhos,mean(gradpmagsgradrho(:,1:end-1),2)/.1e6);
legend('Thermal','Magnetic');
xlabel('\rho');
ylabel('\nablaP / \nabla\rho (MPa/m)');
title("Thermal vs mean magnetic pressure gradient");

end
