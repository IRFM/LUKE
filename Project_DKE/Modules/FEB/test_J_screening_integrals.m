function [err,output] = test_J_screening_integrals(aa,bb,cc)
%
%	Test routine to calculate the values of the screening integrals derived
%	analytically and compare with results from a numerical integral solver.
%
%	Input:
%
%		- aa < 0, integral parameter, coef. of cos(phi).
%		- bb > 0, integral parameter with abs(b) > abs(a).
%		- cc > 0, parameter related to the effective ion radius.
%
%	Output: 
%
%		- J_kl, indexes: 1 = numerical, 2 = analytical value, 3 = error.
%
% by A.Jardin <axel.jardin@ifj.edu.pl>, K.Krol IFJ-PAN <krzysztof.krol@ifj.edu.pl> and Y.Peysson CEA-DRFC <yves.peysson@cea.fr>
% Date: 30 August 2019
%
format long
%
dphi = 2*pi/1e4;
phi = [0:dphi:2*pi];
%
if nargin == 0
    %
    n = 3;
    %
    aa = -ones(length(phi),1)*rand(1,n);
    bb = -3*aa;%b./a < -1
    %cc = ones(length(phi),1)*rand(1,n);
    cc = rand;
    %
end
%
aa = aa(:)';
bb = bb(:)';
%
a = aa(1,:);
b = bb(1,:);
c = cc; 
%
% Definition. Indexes: 1 = numerical, 2 = analytical value, 3 = error.
%
n = length(a);
phi = phi'*ones(1,n);
%
output.J12_1 = zeros(1,n); output.J13_1 = zeros(1,n);
output.J22_1 = zeros(1,n); output.J23_1 = zeros(1,n);
output.J32_1 = zeros(1,n); output.J33_1 = zeros(1,n);
output.J42_1 = zeros(1,n); output.J43_1 = zeros(1,n);
%
output.J12_2 = zeros(1,n); output.J13_2 = zeros(1,n);
output.J22_2 = zeros(1,n); output.J23_2 = zeros(1,n);
output.J32_2 = zeros(1,n); output.J33_2 = zeros(1,n);
output.J42_2 = zeros(1,n); output.J43_2 = zeros(1,n);

% INTEGRAL PARAMETERS
if a~=0
    %
    delta = b./a; % delta < -1

    A0 = delta-1;               % A0 < 0
    B0 = delta+1;               % B0 < 0
    C0 = 1 + a.*c.*(delta-1);   % C0 > 0
    D0 = 1 + a.*c.*(delta+1);   % D0 > 0

    A = B0./A0; % A > 0
    B = D0./C0; % B > 0

    num = sqrt(delta.^2 - 1);
    
    % --- Integral J11 ---
    
    output.J11_1 = trapz(phi(:,1), 1./((aa.*cos(phi)+bb).^2),1);
    
    output.J11_2 = -2*pi*delta./num.^3./a.^2;
    
    output.J11_3 = output.J11_2 - output.J11_1;
    
    % --- Integral J21 ---
    
    output.J21_1 = trapz(phi(:,1), 1./((aa.*cos(phi)+bb)),1);
    
    output.J21_2 = -2*pi./num./a;
    
    output.J21_3 = output.J21_2 - output.J21_1;
    
    % --- Integral J31 ---
    
    output.J31_1 = trapz(phi(:,1), cos(phi)./((aa.*cos(phi)+bb).^2),1);
    
    output.J31_2 = 2*pi./num.^3./a.^2;
    
    output.J11_3 = output.J31_2 - output.J31_1;
    
    % --- Integral J41 ---
    
    output.J41_1 = trapz(phi(:,1), cos(phi)./((aa.*cos(phi)+bb)),1);
    
    output.J41_2 = 2*pi*(1 + delta./num)./a;
    
    output.J41_3 = output.J41_2 - output.J41_1;
    
    % --- Integral J12 ---

    output.J12_1 = trapz(phi(:,1), 1./((aa.*cos(phi)+bb).^2.*(1+(aa.*cos(phi)+bb).*cc)),1);

    T1 = (A.^2-1+2*B.*(1-A)) ./ (B-A).^2;
    T2 = (1-A).^2 ./ (B-A);
    T3 = (B-1).^2 ./ (B-A).^2;

    output.J12_2 = 2*pi./a.^2.*1./(A0.^2.*C0).*(T1./sqrt(A)+T2./(2*A.^(3/2))+T3./sqrt(B));

    output.J12_3 = output.J12_2 - output.J12_1;

    % --- Integral J13 ---

    output.J13_1 = trapz( phi(:,1), 1./ ((aa.*cos(phi)+bb).^2.*(1+(aa.*cos(phi)+bb).*cc).^2),1 );

    T1 = (3*A.^2.*B+3*B+3*A-6*A.*B-A.^3-2) ./ (B-A).^3;
    T2 = (1-A).^3 ./ (B-A).^2;
    T3 = (B.^3-3*A.*B.^2-3*B-3*A+6*A.*B+2) ./ (B-A).^3;
    T4 = (3*B.^2-B.^3-3*B+1) ./ (B-A).^2;

    output.J13_2 = 2*pi./a.^2 .* 1./(A0.^2.*C0.^2) .* ( T1./sqrt(A) + T2./(2*A.^(3/2)) + T3./sqrt(B) + T4./(2*B.^(3/2)) );

    output.J13_3 = output.J13_2 - output.J13_1;

    % --- Integral J22 ---

    output.J22_1 = trapz( phi(:,1), 1./ ((aa.*cos(phi)+bb).*(1+(aa.*cos(phi)+bb).*cc)) ,1);

    output.J22_2 = 2*pi./a .* 1./(A0.*C0) .* 1./(B-A) .* ( (1-A)./sqrt(A) + (B-1)./sqrt(B) );

    output.J22_3 = output.J22_2 - output.J22_1;

    % --- Integral J23 ---

    output.J23_1 = trapz( phi(:,1), 1./ ((aa.*cos(phi)+bb).*(1+(aa.*cos(phi)+bb).*cc).^2) ,1);

    T1 = (B.^2-1+2*A.*(1-B)) ./ (A-B).^2;
    T2 = (1-B).^2 ./ (A-B);
    T3 = (A-1).^2 ./ (A-B).^2;

    output.J23_2 = 2*pi./a .* 1./(A0.*C0.^2) .* ( T1./sqrt(B) + T2./(2*B.^(3/2)) + T3./sqrt(A) );

    output.J23_3 = output.J23_2 - output.J23_1;

    % --- Integral J32 ---

    output.J32_1 = trapz( phi(:,1), cos(phi) ./ ((aa.*cos(phi)+bb).^2.*(1+(aa.*cos(phi)+bb).*cc)) ,1);

    output.J32_2 = 1./a .* output.J22_2 - delta .* output.J12_2;

    output.J32_3 = output.J32_2 - output.J32_1;

    % --- Integral J33 ---

    output.J33_1 = trapz( phi(:,1), cos(phi) ./ ((aa.*cos(phi)+bb).^2.*(1+(aa.*cos(phi)+bb).*cc).^2) ,1);

    output.J33_2 = 1./a.*output.J23_2 - delta.*output.J13_2;

    output.J33_3 = output.J33_2 - output.J33_1;

    % --- Integral J42 ---

    output.J42_1 = trapz( phi(:,1), cos(phi) ./ ((aa.*cos(phi)+bb).*(1+(aa.*cos(phi)+bb).*cc)),1 );

    %J42(2) = 2*pi.*( (b.*c+1) ./ (a.*((b-a).*c+1).^(1/2).*((b+a).*c+1).^(1/2))- b./(a.*(b-a).^(1/2).*(b+a).^(1/2)) );
    output.J42_2 = 2*pi./a .* 1./sqrt(C0.*D0) - delta .* output.J22_2;

    output.J42_3 = output.J42_2 - output.J42_1;

    % --- Integral J43 ---

    output.J43_1 = trapz( phi(:,1), cos(phi) ./ ((aa.*cos(phi)+bb).*(1+(aa.*cos(phi)+bb).*cc).^2) ,1);

    output.J43_2 = pi./a.*(B+1)./(B.^(3/2).*C0.^2) - delta .* output.J23_2;

    output.J43_3 = output.J43_2 - output.J43_1;
else
    
    % --- Integral J11 ---
    
    output.J11_1 = trapz(phi(:,1), 1./(aa.*cos(phi)+bb).^2,1);
    
    output.J11_2 =  2*pi./b.^2;
    
    output.J11_3 = output.J11_2 - output.J11_1;
    
    % --- Integral J21 ---
    
    output.J21_1 = trapz(phi(:,1), 1./(aa.*cos(phi)+bb),1);
    
    output.J21_2 = 2*pi./b;
    
    output.J21_3 = output.J21_2 - output.J21_1;
    
    % --- Integral J31 ---
    
    output.J31_1 = trapz(phi(:,1), cos(phi)./(aa.*cos(phi)+bb).^2,1);
    
    output.J31_2 = zeros(size(output.J31_1))
    
    output.J31_3 = output.J31_2 - output.J31_1;
    
    % --- Integral J41 ---
    
    output.J41_1 = trapz(phi(:,1), cos(phi)./(aa.*cos(phi)+bb),1);
    
    output.J41_2 = zeros(size(output.J41_1))
    
    output.J41_3 = output.J41_2 - output.J41_1;
    
    %
    output.J12_1 = trapz(phi(:,1), 1./((aa.*cos(phi)+bb).^2.*(1+(aa.*cos(phi)+bb).*cc)),1);

    output.J12_2 = 2*pi./b.^2./(1 + b.*c);

    output.J12_3 = output.J12_2 - output.J12_1;

    % --- Integral J13 ---

    output.J13_1 = trapz( phi(:,1), 1./ ((aa.*cos(phi)+bb).^2.*(1+(aa.*cos(phi)+bb).*cc).^2),1 );

    output.J13_2 = 2*pi./b.^2./(1 + b.*c).^2;

    output.J13_3 = output.J13_2 - output.J13_1;

    % --- Integral J22 ---

    output.J22_1 = trapz( phi(:,1), 1./ ((aa.*cos(phi)+bb).*(1+(aa.*cos(phi)+bb).*cc)) ,1);

    output.J22_2 = 2*pi./b./(1 + b.*c);
    
    output.J22_3 = output.J22_2 - output.J22_1;

    % --- Integral J23 ---

    output.J23_1 = trapz( phi(:,1), 1./ ((aa.*cos(phi)+bb).*(1+(aa.*cos(phi)+bb).*cc).^2) ,1);

    output.J23_2 = 2*pi./b./(1 + b.*c).^2;

    output.J23_3 = output.J23_2 - output.J23_1;

    % --- Integral J32 ---

    output.J32_1 = trapz( phi(:,1), cos(phi) ./ ((aa.*cos(phi)+bb).^2.*(1+(aa.*cos(phi)+bb).*cc)) ,1);

    output.J32_2 = zeros(size(output.J32_1));

    output.J32_3 = output.J32_2 - output.J32_1;

    % --- Integral J33 ---

    output.J33_1 = trapz( phi(:,1), cos(phi) ./ ((aa.*cos(phi)+bb).^2.*(1+(aa.*cos(phi)+bb).*cc).^2) ,1);

    output.J33_2 = zeros(size(output.J33_1));

    output.J33_3 = output.J33_2 - output.J33_1;

    % --- Integral J42 ---

    output.J42_1 = trapz( phi(:,1), cos(phi) ./ ((aa.*cos(phi)+bb).*(1+(aa.*cos(phi)+bb).*cc)),1 );

    output.J42_2 = zeros(size(output.J42_1));

    output.J42_3 = output.J42_2 - output.J42_1;

    % --- Integral J43 ---

    output.J43_1 = trapz( phi(:,1), cos(phi) ./ ((aa.*cos(phi)+bb).*(1+(aa.*cos(phi)+bb).*cc).^2) ,1);

    output.J43_2 = zeros(size(output.J43_1));

    output.J43_3 = output.J43_2 - output.J43_1;    
    %
end

% --- Global root mean square error ---

err = sqrt( output.J11_3.^2 + output.J21_3.^2 + output.J31_3.^2 + output.J41_3.^2 + output.J12_3.^2 + output.J13_3.^2 + output.J22_3.^2 + output.J23_3.^2 + output.J32_3.^2 + output.J33_3.^2 + output.J42_3.^2 + output.J43_3.^2 ); 

% --- END OF SCRIPT ---


