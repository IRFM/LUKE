function [dft] = moliere(dft,jmax,tf)
%
if nargin == 3 && tf == 1
    %
    r = dft.ionradius{tf}.rn{1};
    %
    ne = zeros(length(dft.ionradius{1}.dens{1}),length(dft.ionradius{1}.dens)-1);
    ne(:,1) = dft.ionradius{1}.dens{1};
    %
    for j = 2:length(dft.ionradius{1}.dens)-1
        ne(:,j) = interp1(dft.ionradius{1}.rn{j},dft.ionradius{1}.dens{j},r);
    end
    %
    ne(isnan(ne)) = 0;%remove NaN
    %
elseif nargin < 3
    %
    tf = 0;
    %
    r = dft.r;
    ne = dft.ne;
    %
end
%
for i = 1:dft.Z
    %
    for j = 1:jmax*2
        %
        n = j - 2;
        R(i,j) = 4*pi*simps(r,r.^(n+2).*ne(:,i))/(dft.Z - dft.Z0(i))/factorial(n+1);%
        %
    end
    %
end
%
if tf == 0
    %
    dft.moliere.r = r;%radius
    %
else
    %
    dft.moliere.tf.r = r;%radius (Thomas-Fermi model)
    %
end
%    
for i = 1:dft.Z
    %
    x = root_moliere(R(i,:));
    %
    jmax = length(x)/2;
    %
    if tf == 0
        %
        dft.moliere.maxnum_exp = jmax;
        %
    else
        %
        dft.moliere.tf.maxnum_exp = jmax;
        %
    end
    %
    if tf == 0
        %
        dft.moliere.checksum(i) = sum(x(1:jmax));
        %
    else
        %
        dft.moliere.tf.checksum(i) = sum(x(1:jmax));
        %
    end
    %
    for j = 1:jmax
        %
        if tf == 0
            %
            dft.moliere.A(i,j) = x(j);
            %
        else
            %
            dft.moliere.tf.A(i,j) = x(j);
            %
        end   
        %
    end
    %
    for j = jmax+1:2*jmax
        %
        if tf == 0
            %
            dft.moliere.alpha(i,j-jmax) = x(j);
            %
        else
            %
            dft.moliere.tf.alpha(i,j-jmax) = x(j);
            %
        end
        %
    end
    %
    xdens = 0;
    %
    for j = 1:jmax
        %
        if tf == 0
            %
            xdens = xdens + dft.moliere.A(i,j)*dft.moliere.alpha(i,j)*dft.moliere.alpha(i,j)*exp(-dft.moliere.alpha(i,j).*r);
            %
        else
            %
            xdens = xdens + dft.moliere.tf.A(i,j)*dft.moliere.tf.alpha(i,j)*dft.moliere.tf.alpha(i,j)*exp(-dft.moliere.tf.alpha(i,j).*r);
            %
        end
    end
    %
    if tf == 0
        %
        dens = (dft.Z - dft.Z0(i))*xdens/4/pi./r;
        %
    else
        %
        dens = (dft.Z - dft.Z0(i))*xdens/4/pi./r;
        %
    end
    %
    dens(1) = ne(1,i)*dens(2)/ne(2,i);%avoid sigularity at r = 0
    %
    if tf == 0
        %
        dft.moliere.ne(:,i) = dens;
        dft.moliere.neR2(:,i) = sum((dft.moliere.ne(:,i) - ne(:,i)).^2)/length(ne(:,i))^2;
        %
        dft.moliere.Ndft(i) = 4*pi*simps(r,r.*r.*ne(:,i));
        dft.moliere.Nfit(i) = 4*pi*simps(r,r.*r.*dft.moliere.ne(:,i));
        %
    else
        %
        dft.moliere.tf.ne(:,i) = dens;
        dft.moliere.tf.neR2(:,i) = sum((dft.moliere.tf.ne(:,i) - ne(:,i)).^2)/length(ne(:,i))^2;
        %
        dft.moliere.tf.Ndft(i) = 4*pi*simps(r,r.*r.*ne(:,i));
        dft.moliere.tf.Nfit(i) = 4*pi*simps(r,r.*r.*dft.moliere.tf.ne(:,i));
        %
    end
    %
    clear dens xdens
end


