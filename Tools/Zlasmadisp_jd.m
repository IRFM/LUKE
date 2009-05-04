function [Z_sn,Zp_sn,Zpp_sn] = Zlasmadisp_jd(zeta_sn,display_mode,NZ)
%
% This function calculates the plasma dispersion function using mex files
% if they exist and a matlab function otherwise.
%
if nargin < 3
    NZ = 10000;
end
%
if nargin < 2
    display_mode = 0;
end
%
[Ns,Nn] = size(zeta_sn);
%
if exist(['erfcc_mex_jd.',mexext],'file') == 3,%fortran file
    Z_sn = zeros(Ns,Nn);
    for is = 1:Ns,
        %
        x = [zeta_sn(is,:),zeros(1,65536 - Nn)];
        %
        [yr,yi] = erfcc_mex_jd(Nn,real(x),imag(x));
        %
        Z_sn(is,:) = sqrt(pi)*(1i*yr(1:Nn) - yi(1:Nn));
    end
    Zp_sn = -2*(1 + zeta_sn.*Z_sn);
    Zpp_sn = -2*(Z_sn - 2*zeta_sn.*(1 + zeta_sn.*Z_sn));
    %
    maskp_sn = abs(zeta_sn) > sqrt(1e-2/(2*eps));
    maskpp_sn = abs(zeta_sn) > sqrt(sqrt(1e-2/(4*eps)));
    %
    if display_mode && any(maskp_sn),
        disp(['Warning : there are ',num2str(sum(maskp_sn(:))),'/',num2str(length(maskp_sn(:))),...
            ' points outside the plasma dispersion function first derivative calculation range'])
    end
    %
    if display_mode && any(maskpp_sn),
        disp(['Warning : there are ',num2str(sum(maskpp_sn(:))),'/',num2str(length(maskpp_sn(:))),...
            ' points outside the plasma dispersion function second derivative calculation range'])
    end
    %
elseif exist('pdisp','file') == 3,%fortran file
    if display_mode >= 1,
       wb = waitbar(0,'Plasma dispersion function');
    end
    Z_sn = NaN*ones(Ns,Nn);
    for is = 1:Ns,
        Z_sn(is,:) = pdispm(zeta_sn(is,:));
        if display_mode >= 1,
           waitbar(in/Nn,wb);
        end
    end
    if display_mode >= 1,
       close(wb)
    end
    Zp_sn = -2*(1 + zeta_sn.*Z_sn);
    Zpp_sn = -2*(Z_sn - 2*zeta_sn.*(1 + zeta_sn.*Z_sn));
    %
else
    %
    % error('Please compile the function erfcc.f as a mex file.');
    %
    % disp('Warning: Zplasma must be checked first. Second derivative calculations are wrong for imag. part and for small arguments.')
    %
    [Z_sn,Zp_sn,Zpp_sn] = Zplasma(zeta_sn,NZ);
    %
end
