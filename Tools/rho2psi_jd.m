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
function [psin] = rho2psi_jd(equil,rho,method)
%
% gives the normalized psi grid corresponding to the input normalized rho grid.
%
%   INPUTS:
%
%       - tokamak: identification name of the scenario
%       - rho: normalized radius [1:nr]
%       - method: interpolation method (default: linear)
%
%   OUTPUTS:
%
%       - psin: poloidal flux [1:nr]
%
if nargin < 3
    method = 'linear';%Interpolation method 
end
if nargin < 2
    error('no rho grid specified');
end
%
if strcmp(equil.id,'LOCAL'),
    psin = rho;
    return
end
npsi = length(equil.psi_apRp);
%
ap =  equil.ptx(npsi,1);%plasma radius on the LFS midplane 
prho = equil.ptx(:,1)/ap;
%
psia = equil.psi_apRp(npsi);%poloidal flux at the edge
%
% Interpolation of calculation grid
%
psin = interp1(prho,equil.psi_apRp/psia,rho,method);

