function equil_luke = makeEquilLuke(equil,amplitudes)

a = amplitudes(1);
Rm = amplitudes(2);
Zm = amplitudes(5);

equil_luke.id = equil.id;

equil_luke.Rp = Rm;
equil_luke.Zp = Zm;

% defining a uniform grid of psi for equil_luke
rhos = linspace(0,a,101)';
ni = length(rhos);
ap = R_rho_theta(a,0,equil,amplitudes)-Rm;
equil_luke.ap = ap;
equil_luke.psi_apRp = ap./Rm.*phi_p_rho(rhos,equil,amplitudes)';

% defining a uniform grid of thetas for equil_luke
thetas = linspace(0,2*pi,101); % uniform grid of thetas, used both for equil_luke and equil
equil_luke.theta = thetas;
nj = length(thetas);

% calculation of the geometrical angles
R = R_rho_theta(rhos,thetas,equil,amplitudes);
Z = Z_rho_theta(rhos,thetas,equil,amplitudes);
thetas_g = theta_geometrical_luke_R_Z(R,Z,amplitudes); % this grid is not equal to thetas and non uniform
thetas_g(1,:) = linspace(0,2*pi,101);
thetas_g(:,end) = 2.*pi.*ones(ni,1);

% flux surfaces
% one can use interp2 to avoid the loop
R_luke = zeros(ni,nj);
Z_luke = zeros(ni,nj);
for i=1:ni
    R_luke(i,:) = interp1(thetas_g(i,:),R(i,:),thetas,"spline","extrap");
    Z_luke(i,:) = interp1(thetas_g(i,:),Z(i,:),thetas,"spline","extrap");
end
equil_luke.ptx = R_luke-Rm ;
equil_luke.pty = Z_luke-Zm ;

% magnetic field
[B_R,B_Z,B_phi] = B_RZphi_rhotheta(rhos,thetas,equil,amplitudes);
Bx_luke = zeros(ni,nj);
By_luke = zeros(ni,nj);
BPHI_luke = zeros(ni,nj);
for i=1:ni
    Bx_luke(i,:) = interp1(thetas_g(i,:),B_R(i,:),thetas,"spline","extrap");
    By_luke(i,:) = interp1(thetas_g(i,:),B_Z(i,:),thetas,"spline","extrap");
    BPHI_luke(i,:) = interp1(thetas_g(i,:),B_phi(i,:),thetas,"spline","extrap");
end
equil_luke.ptBx = Bx_luke;
equil_luke.ptBy = By_luke;
equil_luke.ptBPHI = BPHI_luke;

% temperature profiles
equil_luke.pTe = Te_rho(rhos,equil)';
equil_luke.pzTi = Ti_rho(rhos,equil)';

% pressure profiles
equil_luke.pne = ne_rho(rhos,equil)';
equil_luke.pzni = ni_rho(rhos,equil)';

% plasma composition (charge and mass)
if isfield(equil,'zZi')
    equil_luke.zZi = equil.zZi;
elseif isfield(equil.density,'ion')
    % no information on ion charges, we assume it is full hydrogen
    equil_luke.zZi = ones(1,size(equil.density.ion.profile,1));
else 
    % no information on ion charges, we assume it is full hydrogen
    equil_luke.zZi = 1;
end

if isfield(equil,'zmi')
    equil_luke.zmi = equil.zmi;
elseif isfield(equil.density,'ion')
    equil_luke.zmi = 2.*equil_luke.zZi;
else
    % no information on ion masses, we assume it is full deuterium
    equil_luke.zmi = 2;
end

% "Ludwig type" equilibrium structure kept in memory
equil_luke.ludwig = equil;

end