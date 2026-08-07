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
function testRho_luke_ludwig(equil,equil_luke)

if isfield(equil_luke,'ap')
    ap = equil_luke.ap;
else
    ap = max(equil_luke.ptx(end,:));
end

psi = equil_luke.Rp./ap.*equil_luke.psi_apRp;
psin = equil_luke.psi_apRp/equil_luke.psi_apRp(end);
rhos_luke = psi2rho_jd(equil_luke,psin)'; % rhos of equil_luke


figure;
plot(psi',rhos_luke,psi',equil.rhos);
title('Comparison of \rho_{luke} and \rho_{Ludwig}');
legend('\rho_{luke} (normalized)','\rho_{Ludwig} (in m)','Location','northwest');
xlabel('\psi (Wb)');
ylabel('\rho (normalized for \rho_{luke}, in m for \rho_{Ludwig})');

end

