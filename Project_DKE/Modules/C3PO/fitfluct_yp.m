function [fluct_out] = fitfluct_yp(fluct_in,mode,method,ngrid,nharm)
%
% Build vectorial plasma fluctuation profiles from its numerical counterpart
% Two operating modes :
% 1) Spline-Fourier description for (psi,theta) magnetic equilibrium (HELENA for example)
%
%    1-D: use interp1.m MatLab built-in function (Hermite polynomials (pchip), spline, bi-cubic, linear,  nearest,...)
%    2-D: use Fourier series expansion for the poloidal dependence and the
%    interp1.m for the Fourier series coefficients (Hermite polynomials (pchip), spline, bi-cubic, linear,
%    nearest,...)
%
% 2) Spline-Spline description for (x,y) magnetic equilibrium (EFIT for example)
%
%    1-D: use interp1.m MatLab built-in function (Hermite polynomials (pchip), spline, bi-cubic, linear, nearest,...)
%    2-D: use interp1.m for the x-direction and the interp1.m again for the coefficients of the 
%    previous spline (Hermite polynomials (pchip), spline, bi-cubic, linear, nearest,...)
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
if nargin == 1, 
    mode = 1;%Spline-Fourier case
    method = 'pchip';
    ngrid = 2000;
    nharm = [];
end
if nargin == 2, 
    method = 'pchip';
    ngrid = 2000;
    nharm = [];
end
if nargin == 3, 
    ngrid = 2000;  
    nharm = [];
end
if nargin == 4, 
    nharm = [];%For Spline-Fourier case only
end
%
srho = linspace(0,1,ngrid).^2;
lrho = length(fluct_in.rho);
mtheta = length(fluct_in.theta);
nphi = length(fluct_in.phi);
%
nharm = length(fluct_in.theta) - 1;
%
field_name = fieldnames(fluct_in);
%
test_field_name_ne = strfind(field_name,'ne');%test existence of density fluctuation
test_field_name_B = strfind(field_name,'B');%test existence of magnetic field fluctuation
flag_core_fluct = 0;
for i = 1:length(field_name),
    if ~isempty(test_field_name_ne{i}) | ~isempty(test_field_name_B{i}), flag_core_fluct = flag_core_fluct + 1;end
end
%
for i = 1:length(field_name),
    if isfield(fluct_in,field_name(i)),
        if isstruct(fluct_in.(char(field_name(i)))) && isempty(strfind(char(field_name(i)),'fitparam')) && isempty(strfind(char(field_name(i)),'edge')),
            for istruct = 1:length(fluct_in.(char(field_name(i)))),
                subfield_name = fieldnames(fluct_in.(char(field_name(i))));
                % 
                for j = 1:length(subfield_name),
                    if strcmp(char(subfield_name{j}(1)),'phase') || strcmp(char(subfield_name{j}(1)),'X'), 
                        if mode == 1,%Mode 1 (rho,theta,phi)
                            if size(fluct_in.(char(field_name(i))),1) == lrho && size(fluct_in.(char(field_name(i))),2) == mtheta && size(fluct_in.(char(field_name(i))),3) == nphi,%(rho,theta,phi) vectorisation 
                                %Not yet implemented
                            elseif size(fluct_in.(char(field_name(i)))(istruct).(char(subfield_name(j))),1) == lrho && size(fluct_in.(char(field_name(i)))(istruct).(char(subfield_name(j))),2) == mtheta && size(fluct_in.(char(field_name(i)))(istruct).(char(subfield_name(j))),3) == 1,%(rho,theta) vectorisation 
                                fluct_out.([char(field_name(i)),'_fit'])(istruct).([char(subfield_name(j)),'_fit']) = interpequilpt_yp(method,interp1(fluct_in.rho,fluct_in.(char(field_name(i)))(istruct).(char(subfield_name(j))),srho,method),srho,fluct_in.theta,nharm);% Data are resampled on a finer mesh close to psi (or rho) = 0 before Hermite-Fourier calculations.                              
                            elseif size(fluct_in.(char(field_name(i)))(istruct).(char(subfield_name(j))),1) == lrho && size(fluct_in.(char(field_name(i)))(istruct).(char(subfield_name(j))),2) == 1 && size(fluct_in.(char(field_name(i)))(istruct).(char(subfield_name(j))),3) == 1,%(rho) vectorisation 
                                fluct_out.([char(field_name(i)),'_fit'])(istruct).([char(subfield_name(j)),'_fit']) = interpequilpt_yp(method,interp1(fluct_in.rho,fluct_in.(char(field_name(i)))(istruct).(char(subfield_name(j))),srho,method),srho);% Data are resampled on a finer mesh close to psi (or rho) = 0 before Hermite-Fourier calculations.                              
                            %else
                                %fluct_out.([char(field_name(i)),'_fit'])(istruct).([char(subfield_name(j))]) = fluct_in.(char(field_name(i)))(istruct).(char(subfield_name(j)));
                            end
                        else
                            error('Mode 2 (x,y,phi) not yet implemented in fitfluct_yp.m');
                        end
                    else
                        fluct_out.([char(field_name(i)),'_fit'])(istruct).([char(subfield_name(j))]) = fluct_in.(char(field_name(i)))(istruct).(char(subfield_name(j)));
                    end
                end  
            end
        else
            if strcmp(char(field_name{i}(1)),'x') || strcmp(char(field_name{i}(1)),'X'), 
                if flag_core_fluct,%only is a fluctuation or a magnetic ripple model exists
                    if size(fluct_in.(char(field_name(i))),1) == lrho && size(fluct_in.(char(field_name(i))),2) == mtheta && size(fluct_in.(char(field_name(i))),3) == nphi,%(rho,theta,phi) vectorisation 
                       %Not yet implemented
                    elseif size(fluct_in.(char(field_name(i))),1) == lrho && size(fluct_in.(char(field_name(i))),2) == mtheta && size(fluct_in.(char(field_name(i))),3) == 1,%(rho,theta) vectorisation 
                        fluct_out.([char(field_name(i)),'_fit']) = interpequilpt_yp(method,interp1(fluct_in.rho,fluct_in.(char(field_name(i))),srho,method),srho,fluct_in.theta,nharm);% Data are resampled on a finer mesh close to psi (or rho) = 0 before Hermite-Fourier calculations.                              
                    elseif size(fluct_in.(char(field_name(i))),1) == lrho && size(fluct_in.(char(field_name(i))),2) == 1 && size(fluct_in.(char(field_name(i))),3) == 1,%(rho) vectorisation 
                        fluct_out.([char(field_name(i)),'_fit']) = interpequilpt_yp(method,interp1(fluct_in.rho,fluct_in.(char(field_name(i))),srho,method),srho);% Data are resampled on a finer mesh close to psi (or rho) = 0 before Hermite-Fourier calculations.                              
                    end
                end
            else
                if ~strcmp(char(field_name(i)),'rho') && ~strcmp(char(field_name(i)),'theta') && ~strcmp(char(field_name(i)),'phi')
                    if strcmp(char(field_name(i)),'edge') || strcmp(char(field_name(i)),'id'),
                        fluct_out.(char(field_name(i))) = fluct_in.(char(field_name(i)));
                    else
                    	if flag_core_fluct,
                        	fluct_out.(char(field_name(i))) = fluct_in.(char(field_name(i)));
                            if strcmp(char(field_name(i)),'equil_id'),fluct_out.method = method;end
                        end 
                    end
                end
            end
        end
    end
end
%




