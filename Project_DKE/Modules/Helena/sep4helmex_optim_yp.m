function [delta] = sep4helmex_optim_yp(X,R_sep,Z_sep)
%
%   Optimize the parameters to define the separatrix for the toroidal MHD equilibrium solver HELENA
%   (helmex)
%
%   INPUTS
%
%       - X : parameters of the shape of the separatrix (xpoint,ap,Rp,Zp)
%       - R_sep : major radius of the prescribed separatrix (m) [1,1] 
%       - Z_sep : vertical shift of the prescribed separatrix (m) [1,1] 
%
ntheta = length(R_sep);
if length(Z_sep) ~= ntheta,
    error('Inconsistent length between the major radius and the vertical shift of the input separatrix in sep4helmex_optim_yp');
end
%
%
[R_sep0,Z_sep0] = sep4helmex_yp(X,ntheta);
%
delta = sum(sqrt((R_sep-R_sep0).^2 + (Z_sep-Z_sep0).^2))/ntheta;
%