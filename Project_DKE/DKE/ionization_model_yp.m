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
            if exist(equil_in.ADAS,'file')
                %
                load(equil_in.ADAS);
                %
            else
                %
                equil_out = equil_in;
                disp('*****************')
                disp(['WARNING: file : ',equil_in.ADAS,' is not found. Screening effects are not considered in calculations.'])
                disp('*****************')
                equil_out = rmfield(equil_in,'ADAS');
                return
                %
            end
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
            [equil_out.zZi,equil_out.zNbound,equil_out.zmi,equil_out.pzni,equil_out.pzTi] = ionisation_adas_yp(tabmat,equil_in.zZi,equil_in.zmi,equil_in.pzni,equil_in.pzTi,equil_in.pne,equil_in.pTe);
            %
            iZneutral = find(equil_out.zZi==0);
            %
            if isempty(iZneutral)
                equil_out.Znucleus = equil_out.zZi;
            else
                equil_out.Znucleus = [1,1,equil_out.zZi(iZneutral-1),equil_out.zZi(end)];
            end
            %
            if isfield(equil_in,'screening') && ~isempty(equil_in.screening)
                %
                equil_out.screening = equil_in.screening;
                %
            end
            %
        else
            equil_out = equil_in;
        end
    else
        equil_out = equil_in;
    end
end
%