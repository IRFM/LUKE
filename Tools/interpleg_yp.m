function [XXf0,x_0] = interpleg_yp(XXf0_leg,mhu,momentumDKE)
%
% Pitch-angle interpolation on a new mhu grid
%
% INPUT:
%
%   - XXf0_leg: Legendre coefficients of the bounce-averaged distribution function (npn,n_pol_legendre + 1,nr)
%   - mhu : new pitch-angle grid on which the distribution function will be interpoled (nmhu,1)
%   - momentumDKE structure for calculating the interpolated normalization
%     (optional)
%
% OUTPUT:
%
%   - XXf0: interpolation distribution function (npn,nmhu,nr)
%   - x_0: normalization at all radii (nr)
%
% By Yves Peysson (CEA-IRFM, yves.peysson@cea.fr) and Joan Decker (CEA-IRFM, joan.decker@cea.fr)
%
if nargin < 2,error('Wrong number of input arguments in interpleg_yp.m.');end
%
if (mhu(1) ~= -1) | (mhu(end) ~= 1) | (abs(mhu) > 1),error('Inconsistent input in interpleg_yp.m: pitch-angle values must lie between -1 and 1.');end
%
if ~exist('momentumDKE'),x_0 = [];end
%
XXf0 = zeros(size(XXf0_leg,1),length(mhu),size(XXf0_leg,3));
%
[Pm,cL] = leg_dke_yp(mhu(:)',size(XXf0_leg,2) - 1);%Legendre polynomial calculation
%
%
for ir = 1:size(XXf0_leg,3),%radial position
    XXf0(:,:,ir) = (Pm'*(XXf0_leg(:,:,ir).*(ones(size(XXf0_leg,1),1)*cL'))')';%Distribution function on the Legendre polynomials pitch-angle grid back calculated
    %
    if exist('momentumDKE'),
    	x_0(ir) = 2*pi*integral_dke_jd(momentumDKE.dpn',momentumDKE.pn'.*momentumDKE.pn'.*trapz_dke_yp([mhu(:),XXf0(:,:,ir)'])',1);
    end
end
%
    			 