function equil_magnetic = equildipole_fxd(ap,RT,M,prho,ntheta,test_mode,method)
%
% Create dipole magnetic equilibrium
%
% by F.-X Duthoit (CEA/DSM/IRFM, francois-xavier.duthoit@cea.fr),
%    J. Decker (CEA/DSM/IRFM, joan.decker@cea.fr) and
%    Y. Peysson (CEA/DSM/IRFM, yves.paysson@cea.fr)
%
if nargin < 7,
    method = 1;
end
%
if nargin < 6,
    test_mode = 0;
end
%
if nargin < 5,
    ntheta = 65;
end
%
if nargin < 4,
    prho = linspace(0,1,101); 
end
%
if (ntheta - 1)/4 ~= round((ntheta - 1)/4),
    error('ntheta - 1 must be a multiple of 4')
end
%
it1 = (ntheta - 1)/4 + 1;
it2 = (ntheta - 1)/2 + 1;
it3 = 3*(ntheta - 1)/4 + 1;
%
iar = ap/RT;
%
[qe,me,mp,mn,e0,mu0] = pc_dke_yp;
%
npsi = length(prho);%radial grid rho = (R - RT)/ap taken on LFS horizontal midplane
theta = linspace(0,2*pi,ntheta);%poloidal grid
%
pR0 = 1 + iar*prho;
%
if method == 0,
    %
    nlambda = 1001;
    N = fix((ntheta - 1)/2);
    %
    lambda = linspace(0,pi,nlambda);%vertical angle in spherical view
    %
    XR0 = repmat(pR0,[nlambda,1]);
    Xlambda = repmat(lambda.',[1,npsi]);
    %
    Xrs = XR0.*sin(Xlambda).^2;
    %
    Xx = Xrs.*sin(Xlambda) - 1;
    Xy = Xrs.*cos(Xlambda);
    %
    Xtheta = atan(Xy./Xx) + pi*(Xx < 0).*(Xy >= 0) - pi*(Xx < 0).*(Xy < 0);% -pi < theta < pi
    Ydtheta = -diff(Xtheta);
    Ytheta = (Xtheta(1:end-1,:) + Xtheta(2:end,:))/2;
    Yx = (Xx(1:end-1,:) + Xx(2:end,:))/2;
    Yy = (Xy(1:end-1,:) + Xy(2:end,:))/2;
    %
    n = 1:N;
    %
    Ynx = repmat(Yx,[1,1,N]);
    Yny = repmat(Yy,[1,1,N]);
    Yntheta = repmat(Ytheta,[1,1,N]);
    Yndtheta = repmat(Ydtheta,[1,1,N]);
    %
    Ynn = repmat(reshape(n,[1,1,N]),[nlambda-1,npsi,1]);
    %
    % Note that x is even is theta while y is odd
    %
    npan = reshape(sum(Ynx.*cos(Ynn.*Yntheta).*Yndtheta)/pi,[npsi,N]).';
    pa0 = sum(Yx.*Ydtheta)/pi;
    npbn = reshape(sum(Yny.*sin(Ynn.*Yntheta).*Yndtheta)/pi,[npsi,N]).';
    %
    nptan = repmat(npan,[1,1,ntheta]);
    nptbn = repmat(npbn,[1,1,ntheta]);
    nptn = repmat(n.',[1,npsi,ntheta]);
    nptheta = repmat(reshape(theta,[1,1,ntheta]),[N,npsi,1]);
    pta0 = repmat(pa0.',[1,ntheta]);
    %
    ptx = reshape(sum(nptan.*cos(nptn.*nptheta)),[npsi,ntheta]) + pta0/2;
    pty = reshape(sum(nptbn.*sin(nptn.*nptheta)),[npsi,ntheta]);
    %
    ptR = ptx + 1;
    ptZ = pty;
	%	
	ptrhos = sqrt(ptR.^2+ptZ.^2);
    %
else
    %
    ptR = NaN(npsi,ntheta);
    %
    for it = 1:ntheta,
        %
        c = cos(theta(it));
        c6 = c^6;
        s2 = sin(theta(it))^2;
        s4 = s2*s2;
        s6 = s4*s2;
        %
        A3 = 3*s2*(1+4*s2);
        A = [1,-6*s2,NaN,-4*s4*(3+2*s2),3*s4*(1+4*s2),-6*s6,s6];
        %
        for ir = 2:npsi,
            %
            A(3) = A3 - c6*pR0(ir)*pR0(ir);
            %
            R = roots(A);
            %
            iR = find(imag(R) == 0 & real(R) >= 0 & (real(R) - 1)*c >= 0);
            %
            if isempty(iR),
                error('no root found')
            elseif length(iR) > 1 && max(abs(diff(R(iR)))) > 0,
                error('no unique root found')
            end
            %
            ptR(ir,it) = R(iR(1));
            %
        end
    end
    %
    % particular case rho = 0
    %
    for it = 1:ntheta,
        %
        c = cos(theta(it));
        %
        if c < 0,
            c6 = c^6;
            s2 = sin(theta(it))^2;
            s4 = s2*s2;
            s6 = s4*s2;
            %
            A = [1,-6*s2,3*s2*(1+4*s2)-c6,-4*s4*(3+2*s2),3*s4*(1+4*s2),-6*s6,s6];
            %
            R = roots(A);
            %
            iR = find(imag(R) == 0 & real(R) >= 0);
            %
            if isempty(iR),
                error('no root found')
            end
            %
            ptR(1,it) = min(R(iR));
            %
        else
            %
            ptR(1,it) = 1;
            %
        end
    end
    %
    ptR(:,1) = pR0;% to avoid roundup errors
    ptR(:,it1) = 1;% to avoid roundup errors
    ptR(:,it2) = 0;% to avoid roundup errors
    ptR(:,it3) = 1;% to avoid roundup errors
    ptR(:,end) = pR0;% to avoid roundup errors
    %
    ptR0 = repmat(pR0.',[1,ntheta]);
    ptrhos = (ptR0.*ptR.*ptR).^(1/3);
    ptZ = sqrt(ptrhos.^2 - ptR.^2).*repmat(sign(sin(theta)),[npsi,1]);
    %
    ptZ(:,1) = 0;% to avoid roundup errors
    ptZ(:,end) = 0;% to avoid roundup errors
    %
    ptx = ptR - 1;
    pty = ptZ;
    %
end
%
C = mu0*M/(4*pi);
%
ptBx = 3*C*ptR.*ptZ./ptrhos.^5;
ptBy = C*(2*ptZ.^2-ptR.^2)./ptrhos.^5;
ptBPHI = zeros(npsi,ntheta);
%
ptBx(:,it2) = 0;
ptBy(:,it2) = -sign(M)*Inf;
%
psi = C*(1./pR0 - 1);
psi_apRp = psi*iar;
%
if test_mode
    %
    % The precision of interpolation is tested by ensuring that psi is constant along the field lines
    %
    figure(1),
    plot(ptx.',pty.');axis('equal');
    %
    ptmask = ptrhos >= 1;
    pntheta = sum(ptmask.');
    %
    ptpsi = C*(ptR.^2./ptrhos.^3 - 1);
    ptpsi(:,it2) = 0;%theta = pi
    %
    pavg_ptpsi = sum(ptpsi.'.*ptmask.')./pntheta;
    pdev_ptpsi = sqrt(sum((ptpsi.' - repmat(pavg_ptpsi,[ntheta,1])).^2.*ptmask.'))./pntheta;
    prec_ptpsi = max(abs(ptpsi.' - repmat(psi,[ntheta,1])).*ptmask.');
    %
    figure(2),
    semilogy(prho,abs(pavg_ptpsi - psi)./psi,prho,pdev_ptpsi./psi,prho,prec_ptpsi./psi);
    %
    phtBV = (ptBy(1:end-1,1) + ptBy(2:end,1))/2;
    phtdA_2pi = diff(ptx(:,1)).*(ptR(1:end-1,1) + ptR(2:end,1))/2;
    psiI = [0,cumsum(phtBV.*phtdA_2pi).'];
    %
    figure(3),clf
    plot(prho,psi,prho,psiI,'r--')
    %
end
%
% renormalization
%
equil_magnetic.psi_apRp = psi_apRp/RT;
equil_magnetic.theta = theta;
equil_magnetic.ptx = ptx*RT;
equil_magnetic.pty = pty*RT;
equil_magnetic.ptBx = ptBx/RT^3;
equil_magnetic.ptBy = ptBy/RT^3;
equil_magnetic.ptBPHI = ptBPHI/RT^3;
%
equil_magnetic.Rp = RT;
equil_magnetic.Zp = 0;
%
