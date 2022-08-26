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

