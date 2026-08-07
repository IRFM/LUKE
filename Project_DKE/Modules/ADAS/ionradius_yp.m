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
function [ionradius] = ionradius_yp(element,model)
%
%   Calculation of the ion radius for any positive ion of an element of atomic number Z. 
%   It is calculated using  the density functional theory (DFT) by
%   different models. From the ion radius, it is possible to calculate the
%   screening function in Fokker-Planck equation as well as the screening
%   effect on the bremsstrahlung emission
%
%   INPUTS:
%
%       - element : atomic number or name of the element or symbol of the element
%       - model : DFT model ('Thomas-Fermi', 'Thomas-Fermi-Kirillov','Tseng-Pratt-Avdonina-Lamoureux','Tseng-Pratt-Botto','Tseng-Pratt-Thomas-Fermi','Full_screening'...)
%
%   OUTPUTS:
%
%       - screening : output structure containing the ion radius (bohr radius units), model type, electron distribution and other physical quantities
%
%   By Y. Peysson CEA-IRFM <yves.peysson@cea.fr>, A. Jardin IJF/PAN <axel.jardin@ifj.edu.pl>, K. Krol IFJ/PAN <krzysztof.krol@ifj.edu.pl>
%
if nargin == 0
    %
    element = 'Tungsten';
    model = 'Thomas-Fermi';
    %
end
%
if nargin == 1
    %
    model = 'Thomas-Fermi';
    %
end
%
if ischar(element) && length(element) > 3
    %
    Z = elements('name', element, 'atomic_number');
    %
elseif ischar(element) && length(element) < 3
    %
    Z = elements('symbol', element, 'atomic_number');
    %
elseif ~ischar(element)
    %
    Z = element;
    %
end
%
Z = double(Z);
%
Z0 = Z - [Z:-1:0];%ion charge 
%
ionradius.element = elements('atomic_number', Z, 'name');
ionradius.symbol = elements('atomic_number', Z, 'symbol');
ionradius.model = model;
ionradius.Z = Z;
%
warning off
%
for j = 1:length(Z0)
    %
    [ionradius.Z0(j),ionradius.N(j),ionradius.q(j),ionradius.a(j),ionradius.nff(j),ionradius.B(j),ionradius.r0n(j),ionradius.rn{j},ionradius.bbar{j},ionradius.dens{j},ionradius.I1{j},ionradius.I2{j},ionradius.output{j}]  = fionradius_yp(Z,Z0(j),model);
    %
end
%
warning on
%
