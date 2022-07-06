function [q,ff_tfn,ff_tfk,ff_mol] = tf_form_factor_yp(rn,dens,Z,N)
    %
    %   Calculation of the Thomas-Fermi form factor from DFT calculations and the approximate values from
    %   the Thomas-Fermi-Kirillov (Kirillov et al, 1975), Thomas-Fermi-Yukawa model (Yukawa single exponential) 
    %   and Moliere multi-exponential models (three exponentials) for the neutral atom only.
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
    %       - q : momentum transfer in mec units [N,nq]
    %       - ff_tfn : exact Thomas-Fermi form factor by numerical integration [N,nq]
    %       - ff_tfk : Thomas-Fermi-kirillov form factor [N,nq]
    %       - ff_mol : Thomas-Fermi-Moliere form factor [N,nq] (Note: only the case of neutral atom is not NaN)
    %
    %   By Y. Peysson CEA-IRFM <yves.peysson@cea.fr>, A. Jardin IJF/PAN <axel.jardin@ifj.edu.pl>, Krzysztof Krol IFJ/PAN <krzysztof.krol@ifj.edu.pl>
    %
    nq = 1000;
    q = logspace(-4,1,nq);%normalized momentum
    %
    [~,~,~,~,~,~,re,mc2,~,alpha] = pc_dke_yp;%Physics constant
    %
    a_tfk = (3*sqrt(pi))^(2/3)*N.^(2/3)/Z/4;%Thomas-Fermi-Kirillov
    %
    a_tfk_bar = 2*a_tfk/alpha;%normalization
    %
    B1 = 0.1;%Universal Moliere's value for the Thomas-Fermi model
    B2 = 0.55;%Universal Moliere's value for the Thomas-Fermi model
    B3 = 0.35;%Universal Moliere's value for the Thomas-Fermi model
    %
    beta1 = 6.0;%Universal Moliere's value for the Thomas-Fermi model
    beta2 = 1.2;%Universal Moliere's value for the Thomas-Fermi model
    beta3 = 0.3;%Universal Moliere's value for the Thomas-Fermi model
    %
    A1 = B1;
    A2 = B2;
    A3 = B3;
    %
    lambda1 = beta1*Z^(1/3)/0.885;
    lambda2 = beta2*Z^(1/3)/0.885;
    lambda3 = beta3*Z^(1/3)/0.885;
    %
    a_mol1_bar = 2/lambda1/alpha;
    a_mol2_bar = 2/lambda2/alpha;
    a_mol3_bar = 2/lambda3/alpha;
    %{
    Z0 = Z - N;
    nz = Z*(1/3 - 0.0020*Z);
    lambda0 = 0.9*Z^0.42;%a0^(-1) units with a0 Bohr radius  
    lambdaz2 = lambda0^2*(1.0 - (Z0/Z).^(nz+1))./(1.0 - (Z0/Z)).^2;%the term .../(1.0 - (Z0/Z))^2 is added for an accurate dependencie with Z0/Z (notes Y. Peysson)
    lambdaz = sqrt(lambdaz2);
    a_tpb = 1./lambdaz;%Tseng-Pratt-Botto
    %
    a_tpb_bar = 2*a_tpb/alpha;%normalization
    %}
    %ff_tf = zeros(length(N),nq);
    %
    if iscell(rn) && iscell(dens)
        %
        for i = 1:Z
            %
            for iq = 1:nq
                ff_tfn(i,iq) = 4*pi*alpha*trapz_dke_yp([rn{i}(:),dens{i}(:).*rn{i}(:).*sin(q(iq)*rn{i}(:)/alpha)/q(iq)]);%Exact calculation
            end
            %
            ff_tfk(i,:) = formfactor_yp(a_tfk_bar(i),q,N(i),3/2);%Approximate Thomas-Fermi model
            %ff_tpb(i,:) = formfactor_yp(a_tpb_bar(i),q,N(i),2);%Tseng-Pratt-Botto
            %
            if N(i) == Z %neutral atom
                %
                ff_mol(i,:) = A1*formfactor_yp(a_mol1_bar,q,Z,2) + A2*formfactor_yp(a_mol2_bar,q,Z,2) + A3*formfactor_yp(a_mol3_bar,q,Z,2);
                %
            else
                %
                ff_mol(i,:) = NaN;
                %
            end
        end
        %
    else
        %
        for i = 1:length(N)
            %
            ff_tfk(i,:) = formfactor_yp(a_tfk_bar(i),q,N(i),3/2);%Approximate Thomas-Fermi model
           % ff_tpb(i,:) = formfactor_yp(a_tpb_bar(i),q,N(i),2);%Tseng-Pratt-Botto
            %
            for iq = 1:nq
                %
                ff_tfn(i,iq) = 4*pi*alpha*trapz_dke_yp([rn(:),dens(:,i).*rn(:).*sin(q(iq)*rn(:)/alpha)/q(iq)]);%Exact calculation
                %
            end
            %
            if N(i) == Z %neutral atom
                %
                ff_mol(i,:) = A1*formfactor_yp(a_mol1_bar,q,Z,2) + A2*formfactor_yp(a_mol2_bar,q,Z,2) + A3*formfactor_yp(a_mol3_bar,q,Z,2);%Moliere model
                %
            else
                %
                ff_mol(i,:) = NaN;
                %
            end
            %
        end
        %
    end
    %
end

