% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function [rho] = psi2rho_jd(equil,psin,method)
%
% gives the normalized rho grid corresponding to the input normalized psi
% grid.
%
%   INPUTS:
%
%       - equil: Magnetic equilibrium structure
%       - psin: poloidal flux [1:nr]
%       - method: interpolation method (default: linear)
%
%   OUTPUTS:
%
%       - rho: normalized radius [1:nr]
%
if nargin < 3
    method = 'linear';%Interpolation method 
end
if nargin < 2
    error('no psi grid specified');
end
%
npsi = length(equil.psi_apRp);
%
ap =  equil.ptx(npsi,1);%plasma radius on the LFS midplane 
prho = equil.ptx(:,1)/ap;
%
% Interpolation of calculation grid
%
rho = interp1(equil.psi_apRp/equil.psi_apRp(npsi),prho,psin,method);


