function [dft] = salvat(dft,model)
%
% Calculate the Salvat's coefficients (up to three Yukawa potentials) from
% various atomic models using the density averaged constraint. 
% Data are saved in a substructure dft.salvat.model{i} where i is ranging
% from 1 to 3 epending of the number of exponentials used for the
% calculations
%
%	Input:
%
%		- dft: initial dft structure
%		- model: atomic model (see available atomic models in the dft structure)
%         (default: gaussian)
%
%	Output: 
%
%		- dft: final dft structure with salvat substructure [p,m,n]
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
    %
    for kk = 1:3
        %
        for i = 1:dft.Z
            %
            for j = 1:kk*2
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
            dft.salvat.(lower(dft.code.codetype)){kk}.r = r;%radius
            %
        else
            %
            dft.salvat.(lower(strrep(dft.models{imodel},'-','_'))){kk}.r = r;%radius (Thomas-Fermi model)
            %
        end
        %    
        for i = 1:dft.Z
            %
            x = root_salvat(R(i,:));
            %
            maxnumexp = min(length(x)/2,kk);
            %
            if imodel == 0
                %
                dft.salvat.(lower(dft.code.codetype)){kk}.maxnum_exp = maxnumexp;
                %
            else
                %   
                dft.salvat.(lower(strrep(dft.models{imodel},'-','_'))){kk}.maxnum_exp = maxnumexp;
                %
            end
            %
            if imodel == 0
                %
                dft.salvat.(lower(dft.code.codetype)){kk}.checksum(i) = sum(x(1:maxnumexp));
                %
            else
                %
                dft.salvat.(lower(strrep(dft.models{imodel},'-','_'))){kk}.checksum(i) = sum(x(1:maxnumexp));
                %
            end
            %
            for j = 1:maxnumexp
                %
                if imodel == 0
                    %
                    dft.salvat.(lower(dft.code.codetype)){kk}.A(i,j) = x(j);
                    %
                else
                    %
                    dft.salvat.(lower(strrep(dft.models{imodel},'-','_'))){kk}.A(i,j) = x(j);
                    %
                end   
                %
            end
            %
            for j = maxnumexp+1:2*maxnumexp
                %
                if imodel == 0
                    %
                    dft.salvat.(lower(dft.code.codetype)){kk}.alpha(i,j-maxnumexp) = x(j);
                    %
                else
                    %
                    dft.salvat.(lower(strrep(dft.models{imodel},'-','_'))){kk}.alpha(i,j-maxnumexp) = x(j);
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
                    xdens = xdens + dft.salvat.(lower(dft.code.codetype)){kk}.A(i,j)*dft.salvat.(lower(dft.code.codetype)){kk}.alpha(i,j)*dft.salvat.(lower(dft.code.codetype)){kk}.alpha(i,j)*exp(-dft.salvat.(lower(dft.code.codetype)){kk}.alpha(i,j).*r);
                    %
                else
                    %
                    xdens = xdens + dft.salvat.(lower(strrep(dft.models{imodel},'-','_'))){kk}.A(i,j)*dft.salvat.(lower(strrep(dft.models{imodel},'-','_'))){kk}.alpha(i,j)*dft.salvat.(lower(strrep(dft.models{imodel},'-','_'))){kk}.alpha(i,j)*exp(-dft.salvat.(lower(strrep(dft.models{imodel},'-','_'))){kk}.alpha(i,j).*r);
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
                dft.salvat.(lower(dft.code.codetype)){kk}.ne(:,i) = dens;
                dft.salvat.(lower(dft.code.codetype)){kk}.neR2(:,i) = sum((dft.salvat.(lower(dft.code.codetype)){kk}.ne(:,i) - ne(:,i)).^2)/length(ne(:,i));
                %
                dft.salvat.(lower(dft.code.codetype)){kk}.Ndft(i) = 4*pi*simps(r,r.*r.*ne(:,i));
                dft.salvat.(lower(dft.code.codetype)){kk}.Nfit(i) = 4*pi*simps(r,r.*r.*dft.salvat.(lower(dft.code.codetype)){kk}.ne(:,i));
                %
            else
                %
                dft.salvat.(lower(strrep(dft.models{imodel},'-','_'))){kk}.ne(:,i) = dens;
                dft.salvat.(lower(strrep(dft.models{imodel},'-','_'))){kk}.neR2(:,i) = sum((dft.salvat.(lower(strrep(dft.models{imodel},'-','_'))){kk}.ne(:,i) - ne(:,i)).^2)/length(ne(:,i))^2;
                %
                dft.salvat.(lower(strrep(dft.models{imodel},'-','_'))){kk}.Ndft(i) = 4*pi*simps(r,r.*r.*ne(:,i));
                dft.salvat.(lower(strrep(dft.models{imodel},'-','_'))){kk}.Nfit(i) = 4*pi*simps(r,r.*r.*dft.salvat.(lower(strrep(dft.models{imodel},'-','_'))){kk}.ne(:,i));
                %
            end
            %
        end
        %
        clear dens xdens
        %
    end
    %
end

