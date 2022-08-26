function [BR_ludwig,BR_luke,BZ_ludwig,BZ_luke,BPHI_ludwig,BPHI_luke] = compareMagneticField(equil,amplitudes,equil_luke)
% compare the magnetic fields of an equil and an equil_luke : 

indi = 1:4:size(equil_luke.ptx,1);
indj = 1:3:size(equil_luke.ptx,2);

BR_luke = equil_luke.ptBx(indi,indj);
BZ_luke = equil_luke.ptBy(indi,indj);
BPHI_luke = equil_luke.ptBPHI(indi,indj);

R = equil_luke.Rp + equil_luke.ptx(indi,indj);
Z = equil_luke.Zp + equil_luke.pty(indi,indj);

BR_ludwig = zeros(size(R));
BZ_ludwig = zeros(size(R));
BPHI_ludwig = zeros(size(R));
for i=1:size(R,1)
    for j=1:size(R,2)
        [BR_ludwig(i,j), BZ_ludwig(i,j), BPHI_ludwig(i,j)] = B_RZphi_RZ(R(i,j),Z(i,j),equil,amplitudes);
    end
end

figure; 
surf(R,Z,BR_ludwig);
hold on;
surf(R,Z,BR_luke);
title('B_R');
xlabel('R (m)');
ylabel('Z (m)');
axis equal;
c= colorbar;
c.Label.String = 'Magnetic field (T)';

figure;
surf(R,Z,BZ_ludwig);
hold on;
surf(R,Z,BZ_luke);
title('B_Z');
xlabel('R (m)');
ylabel('Z (m)');
axis equal;
c= colorbar;
c.Label.String = 'Magnetic field (T)';

figure;
surf(R,Z,BPHI_ludwig);
hold on;
surf(R,Z,BPHI_luke);
title('B_{\phi}');
xlabel('R (m)');
ylabel('Z (m)');
axis equal;
c= colorbar;
c.Label.String = 'Magnetic field (T)';


disp("Maximum difference between BR_ludwig and BR_luke");
disp("In absolute value : " + num2str(max(abs(BR_luke-BR_ludwig),[],'all')) + " T");
disp("In relative value : " + num2str(max(abs((BR_luke-BR_ludwig)./BR_ludwig),[],'all')) + " %");

disp("Maximum difference between BZ_ludwig and BZ_luke");
disp("In absolute value : " + num2str(max(abs(BZ_luke-BZ_ludwig),[],'all')) + " T");
disp("In relative value : " + num2str(100*max(abs((BZ_luke-BZ_ludwig)./BZ_ludwig),[],'all')) + " %");

disp("Maximum difference between BPHI_ludwig and BPHI_luke");
disp("In absolute value : " + num2str(max(abs(BPHI_luke-BPHI_ludwig),[],'all')) + " T");
disp("In relative value : " + num2str(100*max(abs((BPHI_luke-BPHI_ludwig)./BPHI_ludwig),[],'all')) + " %");

end

