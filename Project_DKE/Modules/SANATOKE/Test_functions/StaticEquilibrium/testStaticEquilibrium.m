function [gradP_R,jxB_R,gradP_Z,jxB_Z] = testStaticEquilibrium(rhos,thetas,equil,amplitudes)
% computes gradP and jxB in cylindric coordinates

ni = length(rhos);
nj = length(thetas);
gradP_R = zeros(ni,nj);
gradP_Z = zeros(ni,nj);
jxB_R = zeros(ni,nj);
jxB_Z = zeros(ni,nj);

rhos(abs(rhos-equil.a)<equil.a/200) = 0.995*equil.a;

jps = jp_rho_theta(rhos,thetas,equil,amplitudes);
jts = jt_rho_theta(rhos,thetas,equil,amplitudes);
BPs = BP_rho_theta(rhos,thetas,equil,amplitudes);
BTs = BT_rho_theta(rhos,thetas,equil,amplitudes);

Rs = R_rho_theta(rhos,thetas,equil,amplitudes);
Zs = Z_rho_theta(rhos,thetas,equil,amplitudes);
thetas_g = theta_geometrical_R_Z(Rs,Zs,rhos,equil,amplitudes);
alphas = alpha_rho_theta(rhos,thetas,equil,amplitudes,thetas_g);

for i=1:ni
    for j=1:nj
        
        R = Rs(i,j);
        Z = Zs(i,j);

        % pressure gradient
        dl = equil.a/1000;
        Rgrad = [R-dl,R+dl]';
        Zgrad = [Z-dl,Z+dl];

        rho_R1 = rho_R_Z(Rgrad(1),Z,equil,amplitudes);
        rho_R2 = rho_R_Z(Rgrad(2),Z,equil,amplitudes);
        
        rho_Z1 = rho_R_Z(R,Zgrad(1),equil,amplitudes);
        rho_Z2 = rho_R_Z(R,Zgrad(2),equil,amplitudes);

        p_Rs = p_rho([rho_R1,rho_R2]',equil);
        p_Zs = p_rho([rho_Z1,rho_Z2]',equil);

        gradP_R(i,j) = (p_Rs(2)-p_Rs(1))/(Rgrad(2)-Rgrad(1));
        gradP_Z(i,j) = (p_Zs(2)-p_Zs(1))/(Zgrad(2)-Zgrad(1));

        % magnetic pressure gradient : jxB
        jp = jps(i,j);
        jt = jts(i,j);
        BP = BPs(i,j);
        BT = BTs(i,j);
        alpha = alphas(i,j);
        theta_g = thetas_g(i,j);

        jxB_R(i,j) = cos(theta_g-alpha)*(jp*BT-jt*BP);

        jxB_Z(i,j) = sin(theta_g-alpha)*(jp*BT-jt*BP);

    end
end

if nj==1
    disp("gradP_R = "+num2str(gradP_R)+" / jxB_R = "+num2str(jxB_R));
    disp("gradP_Z = "+num2str(gradP_Z)+" / jxB_Z = "+num2str(jxB_Z));
end

end

