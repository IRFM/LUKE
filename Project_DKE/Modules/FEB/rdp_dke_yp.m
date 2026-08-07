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
function [seRDP,seRDP_1,seRDP_2,ec,k,c] = rdp_dke_yp(ec_in,k_in,t0_in,Z,n2f1,nphi,ntheta,integral_mode)
%
%	Differential electron-ion bremstrahlung cross-section (dsigma/dk.domegak)
%	Roche-Ducos-Proriol formula (extended version of Elwer-Haug formula)
%	Ref: E. Haug, Radiation Physics and Chemistry, 207 (2008) 207-214
%
%	Input:
%
%		- ec_in: kinetic energy of the incoming electron (keV) [1,m] 
%		- kc_in: photon energy (keV)  [1,n] 
%		- t0_in: cosine of the angle between the direction of displacement of the incoming  electron and the photon emitted by bremsstrahlung (radian) [1,p] (default = 0)
%		- Z: target ion charge (default = 1) [1,1]
%       - n2f1: number of terms in the series for the calculation o the Gaussian hypergeometric function [1,1]
%         (default : 100)
%       - nphi: number of azimuthal angles for the scattered electron [1,1]
%         (default : 301)
%       - ntheta: number of theta angles for the scattered electron [1,1]
%         (default : 351)
%       - integral_mode: mode of integration over phi and theta of the scatteredd electron ('simps' for Simpson method or 'trapz' or trapeze method)
%         (default : 'simps')
%
%	Output: 
%
%		- seRDP: Full Roche-Ducos-Proriol bremsstrahlung cross-section (m^2) [p,m,n]
%		- seRDP_1: 1st order Roche-Ducos-Proriol bremsstrahlung cross-section, equivalent to Elwert-Haug calculations (m^2) [p,m,n]
%		- seRDP_2: 2nd order Roche-Ducos-Proriol bremsstrahlung cross-section (m^2) [p,m,n]
%		- ec: kinetic energy of the incoming electron (mc2) [p,m,n] 
%		- k: photon energy (mc2)  [p,m,n] 
%		- c: cosine angle between the direction of displacement of the incoming electron and the photon emitted by bremsstrahlung (radian) [p,m,n]
%
%	Warning: Cross-section units : m^2 but energies are in relativistic units. To get 
%			 cross-sections in standard m^2/keV units, seRDP must be divided by 511 keV.
%
%
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr>
%
    if nargin < 4
	    error(2,'Wrong number of input arguments for bhe_dke_yp');
    end
    %
    if nargin == 4
        %
        n2f1 = 100;
        nphi = 101; 
        ntheta = 151; 
        integral_mode = 'simps';
        %
    elseif nargin == 5
        %
        nphi = 101; 
        ntheta = 151; 
        integral_mode = 'simps';
        %
    elseif nargin == 6
        %
        ntheta = 151; 
        integral_mode = 'simps';
        %
    elseif nargin == 7
        %
        integral_mode = 'simps';
        %
    end
    %
    [~,~,~,~,~,~,re,mc2,~,alpha] = pc_dke_yp;%Physics constant
    %
    phi = linspace(0,2*pi,nphi);
    dphi = phi(2) - phi(1);
    %
    [theta] = relativistic_thetagrid_yp(max(ec_in),ntheta);
    %theta = linspace(0,pi,ntheta);
    %dtheta = theta(2) - theta(1);
    c = cos(theta);
    %
    ec_out = repmat(ones(length(t0_in),1)*ec_in(:)'/mc2,[1,1,length(k_in)]);%Relativistic units
    k_out = shiftdim(repmat(ones(length(ec_in),1)*k_in(:)'/mc2,[1,1,length(t0_in)]),2);%Relativistic units
    if (length(ec_in) == 1) && (length(t0_in) == 1),%For the case ec_in and t_in are scalars
	    k_out = reshape(k_out,1,1,length(k_in));
    end
    %
    c0_out = repmat(t0_in(:)*ones(1,length(ec_in)),[1,1,length(k_in)]);
    %
    mask = ec_out > k_out;%Photon are only emitted by electron of higher energies
    %
    ec = repmat(repmat(ec_out,[1,1,1,length(theta)]),[1,1,1,1,length(phi)]);%size(ec)
    k = repmat(repmat(k_out,[1,1,1,length(theta)]),[1,1,1,1,length(phi)]);%size(k)
    c0 = repmat(repmat(c0_out,[1,1,1,length(theta)]),[1,1,1,1,length(phi)]);%size(c0)
    %
    c = permute(repmat(ones(length(phi),1)*c(:)',[1,1,length(ec_in),length(k_in),length(t0_in)]),[5,3,4,2,1]);%size(c)
    phi = permute(repmat(phi(:)*ones(1,length(theta)),[1,1,length(ec_in),length(k_in),length(t0_in)]),[5,3,4,2,1]);%size(phi)
    %
    s0 = sqrt(1 - c0.^2);
    s = sqrt(1 - c.^2);
    %
    e0 = ec + 1; %Initial total energy of electron
    p0 = sqrt(e0.^2 - 1); %Initial momentum of electron
    ep = e0 - k; %Final total energy of electron
    p = sqrt(ep.^2 - 1); %Final momentum of electron
    %
    q2 = p.^2 + p0.^2 + k.^2 - 2*p0.*k.*c0 + 2*p.*k.*c - 2*p0.*p.*(c.*c0 + s.*s0.*cos(phi));
    %
    a0 = alpha*Z*e0./p0;
    a = alpha*Z*ep./p;
    %
    N = 4*pi^2*a0.*a./(exp(2*pi*a0)-1)./(1-exp(-2*pi*a));
    %
    D0 = 2*(e0.*k-p0.*c0.*k);
    D = 2*(ep.*k-p.*c.*k);
    %
    mhu = 2*(e0.*ep+p0.*p-1);
    %
    x = 1 - D0.*D./mhu./q2;
    %
    PHI = a0.*log(q2./D) - a.*log(mhu./D);
    %
    V = gaussianhypergeometric(-1i*a0,1i*a,1,x,n2f1);
    W = gaussianhypergeometric(1-1i*a0,1+1i*a,2,x,n2f1);
    %
    VWsq2 = (V+1i*a.*x.*W)./q2;
    xWsDD0 = (1-x).*W./(D0.*D);
    mD0p1 = mhu./D0+1;
    mDm1 = mhu./D-1;
    %
    J1 = 2*(VWsq2.*(ep./D0 - e0./D) + 1i.*xWsDD0.*(e0.*a.*mDm1 - ep.*a0.*mD0p1));
    J1c = conj(J1);
    %
    Xk = {zeros(size(k)),zeros(size(k)),k};
    Xkn = {zeros(size(k)),zeros(size(k)),ones(size(k))};
    %
    Xp0 = {p0.*s0,zeros(size(p0)),p0.*c0};
    %
    Xp = {p.*s.*cos(phi),p.*s.*sin(phi),p.*c};
    %
    Xq = {Xp0{1} - Xp{1} - Xk{1},Xp0{2} - Xp{2} - Xk{2},Xp0{3} - Xp{3} - Xk{3}};
    %
    XP = {p0.*Xp{1} + p.*Xp0{1},p0.*Xp{2} + p.*Xp0{2},p0.*Xp{3} + p.*Xp0{3}};
    %
    XJ2 = {(VWsq2./D).*Xq{1} - 1i*a.*xWsDD0.*(mDm1.*Xq{1} - XP{1}./p0),...
           (VWsq2./D).*Xq{2} - 1i*a.*xWsDD0.*(mDm1.*Xq{2} - XP{2}./p0),...
           (VWsq2./D).*Xq{3} - 1i*a.*xWsDD0.*(mDm1.*Xq{3} - XP{3}./p0)};
    %
    XJ2c = {conj((VWsq2./D).*Xq{1} - 1i*a.*xWsDD0.*(mDm1.*Xq{1} - XP{1}./p0)),...
            conj((VWsq2./D).*Xq{2} - 1i*a.*xWsDD0.*(mDm1.*Xq{2} - XP{2}./p0)),...
            conj((VWsq2./D).*Xq{3} - 1i*a.*xWsDD0.*(mDm1.*Xq{3} - XP{3}./p0))};
    %
    XJ3 = {(VWsq2./D0).*Xq{1} - 1i*a0.*xWsDD0.*(mD0p1.*Xq{1} - XP{1}./p),...
           (VWsq2./D0).*Xq{2} - 1i*a0.*xWsDD0.*(mD0p1.*Xq{2} - XP{2}./p),...
           (VWsq2./D0).*Xq{3} - 1i*a0.*xWsDD0.*(mD0p1.*Xq{3} - XP{3}./p)};
    %
    XJ3c = {conj((VWsq2./D0).*Xq{1} - 1i*a0.*xWsDD0.*(mD0p1.*Xq{1} - XP{1}./p)),...
           conj((VWsq2./D0).*Xq{2} - 1i*a0.*xWsDD0.*(mD0p1.*Xq{2} - XP{2}./p)),...
           conj((VWsq2./D0).*Xq{3} - 1i*a0.*xWsDD0.*(mD0p1.*Xq{3} - XP{3}./p))};
    %
    A1 = (e0.*ep - 1 - sdot(Xkn,Xp0).*sdot(Xkn,Xp)).*J1.*J1c;
    A2 = (e0.*ep + 1 + sdot(Xkn,Xp0).*sdot(Xkn,Xp)).*(sdot(XJ2,XJ2c) + sdot(XJ3,XJ3c));
    A3 = 2*real((sdot(XJ3c,Xp0) - sdot(XJ2c,Xp0)).*sdot(XJ2,Xkn).*sdot(Xp,Xkn) - (sdot(XJ3c,Xp) - sdot(XJ2c,Xp)).*sdot(XJ3,Xkn).*sdot(Xp0,Xkn));
    A4 = -2*real((e0.*ep + 1 + sdot(Xp0,Xp)).*sdot(XJ2,Xkn).*sdot(XJ3c,Xkn));
    A5 = 2*real(sdot(XJ2,Xp0).*sdot(XJ3c,Xp) - sdot(XJ2,Xp).*sdot(XJ3c,Xp0));
    A6 = 2*real(e0.*J1c.*(sdot(XJ3,Xp) - sdot(XJ2,Xkn).*sdot(Xp,Xkn)));
    A7 = 2*real(ep.*J1c.*(sdot(XJ2,Xp0) - sdot(XJ3,Xkn).*sdot(Xp0,Xkn)));
    A8 = 2*real(sdot(XJ2,XJ3c).*(sdot(Xp0,Xp) - sdot(Xkn,Xp0).*sdot(Xkn,Xp)));
    %
    B11 = (e0.*ep - 1 - sdot(Xkn,Xp0).*sdot(Xkn,Xp)).*J1;
    B12 = e0.*(sdot(XJ3,Xp) - sdot(XJ2,Xkn).*sdot(Xp,Xkn));
    B13 = ep.*(sdot(XJ2,Xp0) - sdot(XJ3,Xkn).*sdot(Xp0,Xkn));
    %
    B1 = 2*real((B11 + B12 + B13).*(cos(PHI) + 1i*sin(PHI)))/pi;
    B2 = alpha*Z*sdot(Xq,Xk).*(e0.*ep - 1 - sdot(Xkn,Xp0).*sdot(Xkn,Xp))./sqrt(q2)./D0./D;
    %
    d5_1 = alpha*Z^2*re^2*k.*p.*N.*(A1 + A2 + A3 + A4 + A5 + A6 + A7 + A8)./p0/pi^2;
    d5_2 = alpha^2*Z^3*re^2*k.*p.*N.*sdot(Xq,Xk).*(B1 + B2)./p0./sqrt(q2)./D0./D;
    %
    ds5_1 = d5_1.*s;
    ds5_2 = d5_2.*s;
    %
    if exist('integral_mode') && strcmp(integral_mode,'simps') && exist('simps')
        %
        ds4_1 = simps(linspace(0,2*pi,nphi),ds5_1,5);%integration over phi
        ds3_1 = simps(theta,ds4_1,4);%integration over theta
        %
        ds4_2 = simps(linspace(0,2*pi,nphi),ds5_2,5);%integration over phi
        ds3_2 = simps(theta,ds4_2,4);%integration over theta
        %
    else
        %
        ds4_1 = trapz(linspace(0,2*pi,nphi),ds5_1,5);%integration over phi
        ds3_1 = trapz(theta,ds4_1,4);%integration over theta
        %
        ds4_2 = trapz(linspace(0,2*pi,nphi),ds5_2,5);%integration over phi
        ds3_2 = trapz(theta,ds4_2,4);%integration over theta
        %
    end
    %
    seRDP_1 = ds3_1.*mask;
    seRDP_2 = ds3_2.*mask;
    %
    test = abs(squeeze(imag(seRDP_1)).*k/Z^2/mc2/1e-31);%millibarns (10^-31 m2)
    %
    if find(test > eps) 
        %
        disp('WARNING : some values of the first order RDP cross-section have an imaginary part larger than numerical accuracy.)')
        %
    end
    %
    [ineg_seRDP_2] = find(seRDP_2 < 0);
    %
    if ~isempty(ineg_seRDP_2)
        %
        disp(['WARNING : ',int2str(length(ineg_seRDP_2)),' values of the second order RDP cross-section are negative. Zero is enforced.'])
        %
    end
    %
    seRDP_2(seRDP_2 < 0) = 0;
    %
    seRDP = real(seRDP_1) + seRDP_2;
    %
    seRDP(isnan(seRDP)) = 0;
    %
end
%
function [y] = gaussianhypergeometric(a,b,c,z,n2f1)
    %
    % Resampling for vectorial calculations or by mex function (specific for the bremsstrahlung cross-section calculation)
    %
    y = hypergeometric2f1(a(:),b(:),c*ones(length(z(:)),1),z(:),n2f1);
    %
    y = reshape(y,size(a));
    %
end

function [s] = sdot(X,Y)
    %
    % generalized scalar product for vectorial calculations
    %
    s = X{1}.*Y{1} + X{2}.*Y{2} + X{3}.*Y{3};
    %
end
