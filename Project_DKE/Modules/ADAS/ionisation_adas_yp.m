function [zZi_out,zmi_out,pzni_out,pzTi_out] = ionisation_adas_yp(adas,zZi_in,zmi_in,pzni_in,pzTi_in,pne,pTe)
%elements,frac,pTe,pne,fi)
%
%   Calculation of the relative fraction of ionisation states Zij from Te profile for a given set of elements and their relative
%   fractions. Use the Atomic Data and Analysis Structure (ADAS). 
%
%   INPUTS:
%
%       - adas : Atomic Data and Analysis Structure 
%       - zZi_in : vector of all ions atomic numbers (zZi = [1,1,1,Zi1,Zi2,...,Zim], the first three values are corresponding to different isotopes of hydrogen) [1,m]
%       - zmi_in : vector of all ions atomic weights (fH,fD,fT,mi1,mi2,...,mim] where fH+fD+fT=1 and fx are the relative fractions of hydrogen isotopes) [1,m]
%       - pzni_in : matrix of ion density profiles, Zi = sum(Zij) (m-3) [m,nr]
%       - pzTi_in : matrix of ion temperature profiles Zi = sum(Zij) (keV) [m,nr]
%       - pTe : electron temperature profile (keV) [1,nr]
%       - pne : electron density profile profile (m-3) [1,nr]
%
%   OUTPUTS:
%
%       - zZi_out : vector of all ions atomic numbers [1,k]
%       - zmi_out : vector of all ions atomic weights [1,k]
%       - pzni_out : matrix of ion density profiles, Zij (m-3) [k,nr]
%       - pzTi_out : matrix of ion temperature profiles Zij (keV) [k,nr]
%
%   By Y. Peysson CEA-IRFM <yves.peysson@cea.fr>
%
if length(pne) ~= size(pzni_in,2)
    error('ERROR: inconsistent dimensions between pzni and pne');
end
%
if length(pne) ~= length(pTe)
    error('ERROR: inconsistent dimensions between pne and pTe');
end
%
if length(pTe) ~= size(pzTi_in,2)
    error('ERROR: inconsistent dimensions between pzTi and pTe');
end
%
if find(zZi_in==0)
    %
    disp('WARNING: ionisation states Zij already calculated from electron temperature profile.');
    %
    zZi_out = zZi_in;
    zmi_out = zmi_in;
    pzni_out = pzni_in;
    pzTi_out = pzTi_in;
    %
    return;
    %
end
%
frac_ij = zeros(length(pTe),99,100);%table of all ionization states fraction for Te, Zi, Zij starting from 0 (neutral) to Zi (full ionized)
%
if zZi_in(1) == 1 && sum(zZi_in(1:3)) == 3 && length(zZi_in) > 3
    %
    zZimp_in = zZi_in(4:end);%only impurities are considered
    pznimp_in = pzni_in(4:end,:);%only impurities are considered
    pzTimp_in = pzTi_in(4:end,:);%only impurities are considered
    %
    [zZimp_test] = element2ZA_yp(adas,Z2element_yp(adas,zZimp_in));
    %
    if length(zZimp_in) ~= length(zZimp_test) 
        if length(zZimp_test) == 0
            error('ERROR: all elements are missing in ADAS structure.')
        else
            zZimp_missing = [];
            for i = 1:length(zZimp_in)
                if isempty(find(zZimp_test == zZimp_in(i)))
                    zZimp_missing = [zZimp_missing,zZimp_in(i)];
                end
            end
            %
            error(['ERROR: Z values [',int2str(zZimp_missing),'] are missing in ADAS structure.']);
        end
    else
        [elements] = Z2element_yp(adas,zZimp_in);
    end
    %
    zZimp_out = [];
    zmimp_out = [];
    pznimp_out = [];
    pzTimp_out = [];
    %
    for i = 1:length(elements)
        %
        for j = 1:size(adas.(elements{i}).rep,2)
            frac_ij = interp1(adas.(elements{i}).Te,adas.(elements{i}).rep(:,j),pTe(:)');%keV
            %
            zZimp_out = [zZimp_out,j - 1];
            zmimp_out = [zmimp_out,adas.(elements{i}).A];
            pznimp_out = [pznimp_out;frac_ij.*pznimp_in(i,:)];
            pzTimp_out = [pzTimp_out;pzTimp_in(i,:)];
            %
        end
        %
    end
    %
    zZi_out = [zZi_in(1:3),zZimp_out];
    zmi_out = [zmi_in(1:3),zmimp_out];
    pzni_out = [pzni_in(1:3,:);pznimp_out];
    pzTi_out = [pzTi_in(1:3,:);pzTimp_out];
    %
else
    zZi_out = zZi_in;
    zmi_out = zmi_in;
    pzni_out = pzni_in;
    pzTi_out = pzTi_in;
end
%

