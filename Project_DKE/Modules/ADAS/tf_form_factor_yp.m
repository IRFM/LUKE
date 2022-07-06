function [q,ff,ff_tfk,ff_tpb] = form_factor_yp(rn,dens,Z,N)
    %
    %   Calculation of the exact form factor and the approximate value from
    %   the Thomas-Fermi model (Kirillov et al, 1975)
    %
    %   INPUTS:
    %
    %      rn : radial grid of the solid angle averaged density of bound electrons (normalized to Bohr radius a0) [m,1]
    %      dens : solid angle averaged density of bound electrons (normalized to Bohr radius a0^(-3)) [m,n]
    %      Z : atomic number [1,1]
    %      N : number of bound electrons [1,N]
    %
    %   OUTPUTS:
    %
    %       - q : momentum transfer [N,nq]
    %       - ff = exact form factor [N,nq]
    %       - ff_tfk = approximate form factor from Thomas-Fermi-kirillov model [N,nq]
    %       - ff_tpb = approximate form factor from Tseng-Pratt-Botto model [N,nq]
    %
    %   By Y. Peysson CEA-IRFM <yves.peysson@cea.fr>, A. Jardin IJF/PAN <axel.jardin@ifj.edu.pl>, Krzysztof Krol IFJ/PAN <krzysztof.krol@ifj.edu.pl>
    %
    nq = 1000;
    q = logspace(-2,4,nq);%
    %
    a_tfk = (3*sqrt(pi))^(2/3)*N.^(2/3)/Z/4;%Thomas-Fermi-Kirillov
    %
    Z0 = Z - N;
    nz = Z*(1/3 - 0.0020*Z);
    lambda0 = 0.9*Z^0.42;%a0^(-1) units with a0 Bohr radius  
    lambdaz2 = lambda0^2*(1.0 - (Z0/Z).^(nz+1))./(1.0 - (Z0/Z)).^2;%the term .../(1.0 - (Z0/Z))^2 is added for an accurate dependencie with Z0/Z (notes Y. Peysson)
    lambdaz = sqrt(lambdaz2);
    a_tpb = 1./lambdaz;%Tseng-Pratt-Botto
    %
    ff_tf = zeros(length(N),nq);
    ff = ff_tf;
    %
    if iscell(rn) && iscell(dens)
        %
        for i = 1:Z
            %
            ff_tf(i,:) = N(i)./(1 + (a_tfk(i).*q).^(3/2));%Approximate Thomas-Fermi model
            %
            for iq = 1:nq
                ff(i,iq) = 4*pi*trapz_dke_yp([rn{i}(:),dens{i}(:).*rn{i}(:).*sin(q(iq)*rn{i}(:))/q(iq)]);%Exact calculation
            end
            %
        end
        %
    else
        %
        for i = 1:length(N)
            %
            ff_tfk(i,:) = N(i)./(1 + (a_tfk(i).*q).^(3/2));%Approximate Thomas-Fermi model
            ff_tpb(i,:) = N(i)./(1 + (a_tpb(i).*q).^(2));%Tseng-Pratt-Botto
            %
            for iq = 1:nq
                %
                ff(i,iq) = 4*pi*trapz_dke_yp([rn(:),dens(:,i).*rn(:).*sin(q(iq)*rn(:))/q(iq)]);%Exact calculation
                %
            end
        %
    end
    %
end

