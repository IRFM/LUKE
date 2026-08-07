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
%   This script generates the data file of a Soloviev Equilibrium
%  
%   By R. Saura <CEA/IRFM> riccardo.saura@cea.fr

k0 = 1;
g  = 0;
R0 = 2.4;                       % m
ap = linspace(0.3,0.7,5);       % m
Bphi0 = 3.6;                    % T
b0 = 1e-2;

theta = linspace(0,2*pi,65);
psin = linspace(0,1,101);

for i = 1:5
    [R,Z,Br,Bz,Bphi,psia,p0] = soloviev(psin,theta,R0,ap(i),k0,g,b0,Bphi0);
    
    equil.theta = theta;
    equil.ptx = R-R0;
    equil.pty = Z;
    equil.ptBx = Br;
    equil.ptBy = Bz;
    equil.ptBPHI = Bphi;
    equil.psi_apRp = ap(i)/R0*psia.*psin;
    equil.Rp = R0;
    equil.Zp = 0;
    equil.pTe = 5*ones(1,101);
    equil.pne = 2e19*ones(1,101);
    equil.pzTi = 5*ones(4,101);
    equil.pzni = zeros(4,101);
    equil.pzni(2,:) = 2e19;
    equil.zZi = [1 1 1 6];
    equil.zmi = [1 2 3 12];
    aps = num2str(ap(i));
    iaps = find(aps=='.');
    if ~isempty(iaps),    aps = aps(iaps+1:end);    end
    equil.id = ['Soloviev01_ap',aps];
    
    save(['EQUIL_' equil.id],'equil')
    clear equil
end






function [R,Z,Br,Bz,Bphi,psia,p0] = soloviev(psin,theta,R0,a,k0,gamma,b0,Bphi0)
%[R,Z,Br,Bz,Bphi,Psia,p0] = soloviev(psin,theta,R0,a,kappa,gamma,beta0,Bphi0)

[~,~,~,~,~,mu0,~,~,~,~,~,~,~,~,~] = pc_dke_yp;

[PSIN,THETA] = meshgrid(psin,theta);
PSIN = PSIN';
THETA = THETA';
RHO = nan(length(psin),length(theta));

eps = a/R0;

for i = 1:length(psin)
    for j = 1:length(theta)
        th = THETA(i,j);
        ps = PSIN(i,j);
        A = cos(th)^2*(4/k0^2*sin(th)^2 +           cos(th)^2);
        B = 4*cos(th)*(2/k0^2*sin(th)^2 +           cos(th)^2);
        C =         4*((1+gamma)/k0^2*sin(th)^2 +   cos(th)^2);
        D = - eps^2*(2+eps)^2*ps;
        
        rt = roots([A B C 0 D]);
        RHO(i,j) = min(rt(imag(rt)==0 & real(rt)>=0));
    end
end

psia = k0/sqrt(1+k0^2)*eps*(2+eps)/4*sqrt(b0)*Bphi0*R0^2;
p0 = 1/mu0*(k0^2+1)/k0^2 *8/(eps^2*(2+eps)^2)*psia^2/R0^4;
R  = R0*(1 + RHO.*cos(THETA));
Z  = R0*RHO.*sin(THETA);
Br = - psia/(eps^2*(2+eps)^2*R0^4)*8/k0^2*(R.^2+gamma*R0^2).*Z./R;
Bz =   psia/(eps^2*(2+eps)^2*R0^4)*4*(2/k0^2*Z.^2 + (R.^2-R0^2) );
Bphi = sqrt(Bphi0^2 - 2*gamma./(k0^2+1)*p0*mu0 * PSIN ) .* R0./R;
end 