function [aBx,aBy,aBz,delta_rho,delta_theta,delta_phi] = bripfield_yp(ripple,equilDKE,mode)
%
%	Calculation of the toroidal magnetic field ripple
%
%	(1): windings with circular cross-section: approximate perturbative calculation, rot(B) = 0, div(B) <> 0, see thesis work of Grua
%	(2): windings with circular cross-section: exact calculation with N filiform coils
%	(3): windings with circular cross-section: exact perturbative calculation laplacian(F) = 0 and B = rot(F)(see ref yus90)
%   (4): windings with arbitrary cross-section.
%
%	Input:
%
%       - ripple: magnetic ripple parameters structure
%       - equilDKE: axisymmetric magnetic equilibrium structure (equil.id must be consistent with ripple.equil_id)
%		- mode: mode of calculation (see above) [1,1]
%
%	Output:
%
%       - aBx: amplitude of the horizontal magnetic ripple field (T) [nrho,ntheta]
%       - aBy: amplitude of the vertical magnetic ripple field (T) [nrho,ntheta]
%       - aBz: amplitude of the toroidal magnetic ripple field (T) [nrho,ntheta] 
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
if nargin < 4,
	dopt = 0;
end
%
if nargin < 3,
	error(2,'Wrong number of input arguments in bripfield_yp.m');
end
%
if strcmp(equilDKE.tokname,ripple.equil_id),
    if mode == 1,
        error('Not yet implemented');
    elseif mode == 2,
        error('Not yet implemented');
    elseif mode == 3,
        [aBx,aBy,aBz,delta_rho,delta_theta,delta_phi] = bripfield_circ3_yp(equilDKE.Xx + equilDKE.Rp,equilDKE.Xy + equilDKE.Zp,ripple.N,ripple.B0,ripple.R0,ripple.rn,ripple.rx);
    elseif mode >= 4,
        error('Not yet implemented');
    end   
else
    error('ID of the magnetic field ripple and the magnetic field equilibrium are inconsistent.');
end
%
