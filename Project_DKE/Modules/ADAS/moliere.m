function [dft] = moliere(dft,model,maxnumexp)
%
% Calculate the Moliere's coefficients (up to three Yukawa potentials) from
% various atomic models. Data are saved in a substructure dft.moliere.
%
%	Input:
%
%		- dft: initial dft structure
%		- model: atomic model (see available atomic models in the dft structure)
%         (default: gaussian)
%		- maxnumexp: maximum number of exponential (Yukawa potentials)  [1,n] 
%         (default = 3)
%
%	Output: 
%
%		- dft: final dft structure with moliere substructure [p,m,n]
%
% by Y.Peysson CEA-DRFC <yves.peysson@cea.fr>
%
if nargin == 0
    %
    error('ERROR : wrong number of input arguments in moliere.m .')
    %
elseif nargin == 1
    %
    model = 0;%Gaussian
    maxnumexp = 3;
    %
elseif nargin == 2
    %
    maxnumexp = 3;
    %
end
%
if ~isstruct(dft)
    %
    error('ERROR: the type of the 1st argument must be a structure in moliere.m')
    %
end
%
if isempty(model)
    %
    model = 0;
    %
end
%
for jj = 1:length(model)
    %
    imodel = model(jj);
    %
    if imodel > 0 
        %
        r = dft.ionradius{imodel}.rn{1};
        %
        ne = zeros(length(dft.ionradius{imodel}.dens{imodel}),length(dft.ionradius{imodel}.dens)-1);
        ne(:,1) = dft.ionradius{imodel}.dens{1};
        %
        for j = 2:length(dft.ionradius{imodel}.dens)-1
            ne(:,j) = interp1(dft.ionradius{imodel}.rn{j},dft.ionradius{imodel}.dens{j},r);
        end
        %
        ne(isnan(ne)) = 0;%remove NaN
        %
    else
        %
        r = dft.r;
        ne = dft.ne;
        %
    end
    %{
    for jj = 1:size(ne,2)
        ine(jj) = min(find(ne(:,jj)/ne(1,jj) < 1e-8));
    end
    %
    ineref = max(ine);
    %
    r = r(1:ineref);
    ne = ne(1:ineref,:);
    %}
    for i = 1:dft.Z
        %
        for j = 1:maxnumexp*2
            %
            n = j - 2;
            R(i,j) = 4*pi*simps(r,r.^(n+2).*ne(:,i))/(dft.Z - dft.Z0(i))/factorial(n+1);%
            %
        end
        %
    end
    %
    if imodel == 0
        %
        dft.moliere.(lower(dft.code.codetype)).r = r;%radius
        %
    else
        %
        dft.moliere.(lower(strrep(dft.models{imodel},'-','_'))).r = r;%radius (Thomas-Fermi model)
        %
    end
    %    
    for i = 1:dft.Z
        %
        x = root_moliere(R(i,:));
        %
        maxnumexp = length(x)/2;
        %
        if imodel == 0
            %
            dft.moliere.(lower(dft.code.codetype)).maxnum_exp = maxnumexp;
            %
        else
            %
            dft.moliere.(lower(strrep(dft.models{imodel},'-','_'))).maxnum_exp = maxnumexp;
            %
        end
        %
        if imodel == 0
            %
            dft.moliere.(lower(dft.code.codetype)).checksum(i) = sum(x(1:maxnumexp));
            %
        else
            %
            dft.moliere.(lower(strrep(dft.models{imodel},'-','_'))).checksum(i) = sum(x(1:maxnumexp));
            %
        end
        %
        for j = 1:maxnumexp
            %
            if imodel == 0
                %
                dft.moliere.(lower(dft.code.codetype)).A(i,j) = x(j);
                %
            else
                %
                dft.moliere.(lower(strrep(dft.models{imodel},'-','_'))).A(i,j) = x(j);
                %
            end   
            %
        end
        %
        for j = maxnumexp+1:2*maxnumexp
            %
            if imodel == 0
                %
                dft.moliere.(lower(dft.code.codetype)).alpha(i,j-maxnumexp) = x(j);
                %
            else
                %
                dft.moliere.(lower(strrep(dft.models{imodel},'-','_'))).alpha(i,j-maxnumexp) = x(j);
                %
            end
            %
        end
        %
        xdens = 0;
        %
        for j = 1:maxnumexp
            %
            if imodel == 0
                %
                xdens = xdens + dft.moliere.(lower(dft.code.codetype)).A(i,j)*dft.moliere.(lower(dft.code.codetype)).alpha(i,j)*dft.moliere.(lower(dft.code.codetype)).alpha(i,j)*exp(-dft.moliere.(lower(dft.code.codetype)).alpha(i,j).*r);
                %
            else
                %
                xdens = xdens + dft.moliere.(lower(strrep(dft.models{imodel},'-','_'))).A(i,j)*dft.moliere.(lower(strrep(dft.models{imodel},'-','_'))).alpha(i,j)*dft.moliere.(lower(strrep(dft.models{imodel},'-','_'))).alpha(i,j)*exp(-dft.moliere.(lower(strrep(dft.models{imodel},'-','_'))).alpha(i,j).*r);
                %
            end
        end
        %
        if imodel == 0
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
        if imodel == 0
            %
            dft.moliere.(lower(dft.code.codetype)).ne(:,i) = dens;
            dft.moliere.(lower(dft.code.codetype)).neR2(:,i) = sum((dft.moliere.(lower(dft.code.codetype)).ne(:,i) - ne(:,i)).^2)/length(ne(:,i))^2;
            %
            dft.moliere.(lower(dft.code.codetype)).Ndft(i) = 4*pi*simps(r,r.*r.*ne(:,i));
            dft.moliere.(lower(dft.code.codetype)).Nfit(i) = 4*pi*simps(r,r.*r.*dft.moliere.(lower(dft.code.codetype)).ne(:,i));
            %
        else
            %
            dft.moliere.(lower(strrep(dft.models{imodel},'-','_'))).ne(:,i) = dens;
            dft.moliere.(lower(strrep(dft.models{imodel},'-','_'))).neR2(:,i) = sum((dft.moliere.(lower(strrep(dft.models{imodel},'-','_'))).ne(:,i) - ne(:,i)).^2)/length(ne(:,i))^2;
            %
            dft.moliere.(lower(strrep(dft.models{imodel},'-','_'))).Ndft(i) = 4*pi*simps(r,r.*r.*ne(:,i));
            dft.moliere.(lower(strrep(dft.models{imodel},'-','_'))).Nfit(i) = 4*pi*simps(r,r.*r.*dft.moliere.(lower(strrep(dft.models{imodel},'-','_'))).ne(:,i));
            %
        end
        %
        clear dens xdens
    end
    %
end

