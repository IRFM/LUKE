function equil_out = ionization_model_yp(equil_in)
%
%   Update equilibrium structure ionisation states of all impurity species for the given electron temperature profile 
%   using the Atomic Data and Analysis Structure (ADAS). If no ADAS structure or Te profiles are found, equilibrium structure is unchanged
%
%   INPUTS:
%
%       - equil_in : equilibrium structure
%
%   OUTPUTS:
%
%       - equil_out : equilibrium structure
%
%   By Y. Peysson CEA-IRFM <yves.peysson@cea.fr>
%
if ~isfield(equil_in,'pTe')
    equil_out = equil_in;
else 
    %
    if isfield(equil_in,'ADAS') && ~isempty(equil_in.ADAS)
        %
        if isempty(find(equil_in.zZi == 0))
            %
            equil_out = equil_in;
            %
            load(equil_in.ADAS);
            %
            if isempty(find(equil_in.zZi == 1))
                equil_out.impurities_ADAS = Z2element_yp(tabmat,equil_in.zZi);%only impurities
            else
                if length(find(equil_in.zZi == 1)) == 1 && length(equil_in.zZi > 1)
                    equil_out.impurities_ADAS = Z2element_yp(tabmat,equil_in.zZi(2:end));
                elseif length(find(equil_in.zZi == 1)) == 3 && length(equil_in.zZi > 3)
                    equil_out.impurities_ADAS = Z2element_yp(tabmat,equil_in.zZi(4:end));
                else
                    equil_out.impurities_ADAS = [];%no impurities
                end
            end
            %
            [equil_out.zZi,equil_out.zmi,equil_out.pzni,equil_out.pzTi] = ionisation_adas_yp(tabmat,equil_in.zZi,equil_in.zmi,equil_in.pzni,equil_in.pzTi,equil_in.pne,equil_in.pTe);
            %
        else
            equil_out = equil_in;
        end
    else
        equil_out = equil_in;
    end
end

