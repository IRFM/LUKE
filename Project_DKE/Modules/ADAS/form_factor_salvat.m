function [q,ff_dhfs,ff_sal] = form_factor_salvat(dft,code)
%
% Numerical calculation of the atomic form factor from DHFS calculations and the Salvat moment method (up to three exponentials)
%
%   INPUTS:
%
%       - dft : dft structure 
%       - code : name of the dft code (gaussian, grap,...) 
%           (default : gaussian)
%
%   OUTPUTS:
%
%       - q : recoil momentum normalized to mec units [1,q]
%       - ff_dhfs : exact atomic form factor from DHFS calculations (using code) [Z,q]
%       - ff_sal : approximate atomic form factor from Salvat moment method {3}[Z,q]
%
%   Note : ff_dhfs is calculated for all Z ionization states. Idem ff_sal but also for one, two or three exponentials
%
%   By Y. Peysson CEA-IRFM <yves.peysson@cea.fr>
%
if nargin == 0
    %
    error('ERROR: wrong number of input arguments in form_factor_salvat.m')
    %
elseif nargin == 1
    %
    code = 'gaussian';%Gaussian DFT code
    %
end
%
if isfield(dft,'salvat')
    %
    if isfield(dft.salvat,code) 
        %
        nq = 1000;
        q = logspace(-4,1,nq);%normalized recoil momentum normalized to mec
        %
        [~,~,~,~,~,~,re,mc2,~,alpha] = pc_dke_yp;%Physics constant
        %
        for iZ = 1:length(dft.Z0)
            %
            [~,ff_dhfs(iZ,:)] = formfactornum_yp(dft.r,dft.ne(:,iZ),q);
            %
            for ii = 1:length(dft.salvat.(code))
                %
                if ii == 1
                    %
                    A1 = dft.salvat.(code){ii}.A(iZ,1);
                    a_sal1_bar = 2/dft.salvat.(code){ii}.alpha(iZ,1)/alpha;
                    %
                    ff_sal{ii}(iZ,:) = A1*formfactor_yp(a_sal1_bar,q,dft.salvat.(code){ii}.Ndft(iZ),2);
                    %
                elseif ii == 2
                    %
                    A1 = dft.salvat.(code){ii}.A(iZ,1);
                    a_sal1_bar = 2/dft.salvat.(code){ii}.alpha(iZ,1)/alpha;
                    A2 = dft.salvat.(code){ii}.A(iZ,2);
                    a_sal2_bar = 2/dft.salvat.(code){ii}.alpha(iZ,2)/alpha;
                    %
                    ff_sal{ii}(iZ,:) = A1*formfactor_yp(a_sal1_bar,q,dft.salvat.(code){ii}.Ndft(iZ),2) + A2*formfactor_yp(a_sal2_bar,q,dft.salvat.(code){ii}.Ndft(iZ),2);
                    %
                elseif ii == 3 
                    %
                    A1 = dft.salvat.(code){ii}.A(iZ,1);
                    a_sal1_bar = 2/dft.salvat.(code){ii}.alpha(iZ,1)/alpha;
                    A2 = dft.salvat.(code){ii}.A(iZ,2);
                    a_sal2_bar = 2/dft.salvat.(code){ii}.alpha(iZ,2)/alpha;
                    A3 = dft.salvat.(code){ii}.A(iZ,3);
                    a_sal3_bar = 2/dft.salvat.(code){ii}.alpha(iZ,3)/alpha;
                    %
                    ff_sal{ii}(iZ,:) = A1*formfactor_yp(a_sal1_bar,q,dft.salvat.(code){ii}.Ndft(iZ),2) + A2*formfactor_yp(a_sal2_bar,q,dft.salvat.(code){ii}.Ndft(iZ),2) + A3*formfactor_yp(a_sal3_bar,q,dft.salvat.(code){ii}.Ndft(iZ),2);
                    %
                elseif ii == 4 
                    %
                    A1 = dft.salvat.(code){ii}.A(iZ,1);
                    a_sal1_bar = 2/dft.salvat.(code){ii}.alpha(iZ,1)/alpha;
                    A2 = dft.salvat.(code){ii}.A(iZ,2);
                    a_sal2_bar = 2/dft.salvat.(code){ii}.alpha(iZ,2)/alpha;
                    A3 = dft.salvat.(code){ii}.A(iZ,3);
                    a_sal3_bar = 2/dft.salvat.(code){ii}.alpha(iZ,3)/alpha;
                    A4 = dft.salvat.(code){ii}.A(iZ,4);
                    a_sal4_bar = 2/dft.salvat.(code){ii}.alpha(iZ,4)/alpha;
                    %
                    ff_sal{ii}(iZ,:) = A1*formfactor_yp(a_sal1_bar,q,dft.salvat.(code){ii}.Ndft(iZ),2) + A2*formfactor_yp(a_sal2_bar,q,dft.salvat.(code){ii}.Ndft(iZ),2) + A3*formfactor_yp(a_sal3_bar,q,dft.salvat.(code){ii}.Ndft(iZ),2) + A4*formfactor_yp(a_sal4_bar,q,dft.salvat.(code){ii}.Ndft(iZ),2);
                    %
                end
                %
            end
            %
        end
        %
    else
        %
        error('ERROR : the dft.salvat.',dft_code,' substructure does not exist.')
        %
    end
    %
else
    %
    error('ERROR : the dft.salvat substructure does not exist.')
    %
end


