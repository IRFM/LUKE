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
function Z = pdispm(x)
%
% This function is the link between matlab and the pdisp.dll file 
%
% It calculates the plasma dispersion function for a complex argument
%
%   INPUTS:
%           - x: argument [1,nx] complex
%
%   OUTPUTS:
%   
%           - Z: Z(x) [1,nx] complex
%
% by J. Decker, 10/27/05
%
nx = length(x);
%
if nx > 1001,
    error('The input vector is too long')
end
%
xr = zeros(1,1001);
xi = zeros(1,1001);
%
xr(1:nx) = real(x(:))';
xi(1:nx) = imag(x(:))';
%
[Zr,Zi] = pdisp(nx,xr,xi);
%
Z = Zr(1:nx) + i*Zi(1:nx);
%


