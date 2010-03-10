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
if isempty(nharm),nharm = length(fluct_in.theta) - 1;end
%
struct_name = fieldnames(fluct_in);
substruct_name = {'sf','mf','nf','cf'};
%
for i = 1:length(struct_name),
    if isfield(fluct_in,struct_name(i)),
        if isstruct(fluct_in.(char(struct_name(i)))),
            for istruct = 1:length(fluct_in.(char(struct_name(i)))),
                if mode == 1,%Mode 1 (rho,theta) 
                    % Data are resampled on a finer mesh close to psi (or rho) = 0 before Hermite-Fourier calculations.     
                    fluct_out.(char(struct_name(i)))(istruct).([char(substruct_name(1)),'_fit']) = interpequilpt_yp(method,interp1(fluct_in.prho,fluct_in.(char(struct_name(i)))(istruct).(char(substruct_name(1))),srho,method),srho,fluct_in.theta,nharm);
                    %
                    for j = 1:length(substruct_name),
                        nkpar = size(fluct_in.(char(struct_name(i)))(istruct).(char(substruct_name(j))),1)./length(fluct_in.prho);
                        nkperp = size(fluct_in.(char(struct_name(i)))(istruct).(char(substruct_name(j))),2)./length(fluct_in.theta);
                        %
                        for ikpar = 1:nkpar,
                            for ikperp = 1:nkperp,
                                j,ikperp
                                fluct_out.(char(struct_name(i)))(istruct).([char(substruct_name(j)),'_fit'])(ikpar,ikperp) = interpequilpt_yp(method,interp1(fluct_in.prho,fluct_in.(char(struct_name(i)))(istruct).(char(substruct_name(j)))([(ikpar-1)*length(fluct_in.prho)+1:ikpar*length(fluct_in.prho)],[(ikperp-1)*length(fluct_in.theta)+1:ikperp*length(fluct_in.theta)]),srho,method),srho,fluct_in.theta,nharm);
                            end
                        end
                    end
                else
                    error('Mode 2 (x,y) not yet implemented in fitfluct_yp.m');
                end  
            end
        else
            if ~strcmp(char(struct_name(i)),'theta') & ~strcmp(char(struct_name(i)),'prho'),
                fluct_out.(char(struct_name(i))) = fluct_in.(char(struct_name(i)));
            end
        end
    end
end
fluct_out.method = method;
%



