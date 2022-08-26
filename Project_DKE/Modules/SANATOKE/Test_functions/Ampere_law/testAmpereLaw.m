function [j_R,j_Z,j_phi,rotB_R,rotB_Z,rotB_phi,rel_diff_R,rel_diff_Z,rel_diff_phi] = testAmpereLaw(rhos,thetas,equil,amplitudes)
% computes mu0*J and rot(B) in cylindric coordinates

[~,~,~,~,~,mu0] = pc_dke_yp;

% current profile

[j_R,j_Z,j_phi] = j_RZphi_rhotheta(rhos,thetas,equil,amplitudes);
j_phi = -j_phi ; % minus sign because the phi coordinate of thje cylindric system is opposite to the phi coordinate used in this code

% magnetic curl

ni = length(rhos);
nj = length(thetas);
rotB_R = zeros(ni,nj);
rotB_Z = zeros(ni,nj);
rotB_phi = zeros(ni,nj);

rhos(abs(rhos-equil.a)<equil.a/200) = 0.99*equil.a;
Rs = R_rho_theta(rhos,thetas,equil,amplitudes);
Zs = Z_rho_theta(rhos,thetas,equil,amplitudes);

for i=1:ni
    for j=1:nj
        R = Rs(i,j);
        Z = Zs(i,j);

        dl = equil.a/500;
        Rgrad = [R-dl,R+dl]';
        Zgrad = [Z-dl,Z+dl];

        [~,BZ_R(1),Bphi_R(1)] = B_RZphi_RZ(Rgrad(1),Z,equil,amplitudes);
        Bphi_R(1) = -Bphi_R(1);
        [~,BZ_R(2),Bphi_R(2)] = B_RZphi_RZ(Rgrad(2),Z,equil,amplitudes);
        Bphi_R(2) = -Bphi_R(2);
        
        [BR_Z(1),~,Bphi_Z(1)] = B_RZphi_RZ(R,Zgrad(1),equil,amplitudes);
        Bphi_Z(1) = -Bphi_Z(1);
        [BR_Z(2),~,Bphi_Z(2)] = B_RZphi_RZ(R,Zgrad(2),equil,amplitudes);
        Bphi_Z(2) = - Bphi_Z(2);

        rotB_R(i,j) = -1./mu0.*(Bphi_Z(2)-Bphi_Z(1))/(2*dl);
        rotB_Z(i,j) = 1./mu0.*1/R*(Rgrad(2)*Bphi_R(2)-Rgrad(1)*Bphi_R(1))/(Rgrad(2)-Rgrad(1));
        rotB_phi(i,j) = 1./mu0.*((BR_Z(2)-BR_Z(1))/(Zgrad(2)-Zgrad(1)) - (BZ_R(2)-BZ_R(1))/(Rgrad(2)-Rgrad(1)));
        
    end
end

rel_diff_R = abs((j_R-rotB_R)./j_R);
rel_diff_Z = abs((j_Z-rotB_Z)./j_Z);
rel_diff_phi = abs((j_phi-rotB_phi)./j_phi);

disp('Relative difference in R coordinate : ');
disp(rel_diff_R);
disp('Relative difference in Z coordinate : ');
disp(rel_diff_Z);
disp('Relative difference in phi coordinate : ');
disp(rel_diff_phi);


end