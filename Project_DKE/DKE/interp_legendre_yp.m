function [XXf0_interp,normfinterp] = interp_legendre_yp(dkeparam,gridDKE,XXf0,test)
% LUKE: Perform a projection of the distribution function on the Legendre polynomial basis ( for data compression)
%
% Compact input LUKE data structure (LUKE_RESULTS or LUKE_DATA) by performing a projection of the distribution function on the Legendre polynomial basis
%
%   INPUTS:
%   
%       - dkeparam: LUKE parameter structure
%       - gridDKE: LUKE grid structure 
%       - XXf0: initial distribution function. May be an array cell
%       - test: check the projection with the normalization
%       
%   OUTPUTS:
%   
%      - XXf0_interp: projected Legendre polynomial structure
%
% by Yves Peysson(CEA/IRFM, yves.peysson@cea.fr) and Joan Decker (EPFL/CRPP, joan.decker@epfl.ch)
%
if nargin < 4,
    test = 0;
end
%
n_pol = dkeparam.n_gauleg;%Necessary for accurate reconstruction at ksi = -1
[x_leg,w_leg] = gauleg_dke_yp(dkeparam.n_gauleg,dkeparam.epsi_gauleg);%Gauss-Legendre abscissa and weigth calculations between -1 and + 1
[Pm,cL] = leg_dke_yp(x_leg(:)',n_pol);%Legendre polynomial calculation
%
if iscell(XXf0),
    for it = 1:length(XXf0),
        XXf0_interp{it} = finterp_legendre_yp(Pm,x_leg,w_leg,cL,dkeparam.method,gridDKE.mhu,XXf0{it});
    end
else
    XXf0_interp = finterp_legendre_yp(Pm,x_leg,w_leg,cL,dkeparam.method,gridDKE.mhu,XXf0);
end
%
% Distribution function reconstruction test
%
if test,
    if iscell(XXf0_interp)
        for it = 1:length(XXf0_interp),
            normfinterp(it) = test_finterp_legendre_yp(Pm,x_leg,cL,dkeparam.method,gridDKE.pn2,gridDKE.dpn,gridDKE.mhu,XXf0{it},XXf0_interp{it});
        end
    else
        normfinterp = test_finterp_legendre_yp(Pm,x_leg,cL,dkeparam.method,gridDKE.pn2,gridDKE.dpn,gridDKE.mhu,XXf0,XXf0_interp);
    end
end
%
end

function XXf0_leg = finterp_legendre_yp(Pm,x_leg,w_leg,cL,method,mhu,XXf0)
    %
    XXf0_leg = zeros(size(XXf0,1),length(cL),size(XXf0,3));
    %
    for ir = 1:size(XXf0,3),%radial position
        XXf0_leg(:,:,ir) = (interp1(mhu(:),XXf0(:,:,ir)',x_leg(:),method)'.*(w_leg*ones(1,size(XXf0,1)))')*Pm';%Calculation of the Legendre coefficients for local values of the distribution function
    end
    %
end

function normfinterp = test_finterp_legendre_yp(Pm,x_leg,cL,method,pn2,dpn,mhu,XXf0,XXf0_leg)
    %
    for ir = 1:size(XXf0_leg,3),
        Xf0_i1 = (Pm.'*(XXf0_leg(:,:,ir).*(ones(size(XXf0_leg(:,:,ir),1),1)*cL.')).').';%Distribution function on the Legendre polynomials pitch-angle grid back calculated
        Xf0_i2 = interp1(x_leg(:),Xf0_i1.',mhu(:),method).';%Distribution function on initial pitch-angle grid back calculated from Legendre polynomial fit
        normfinterp.norm0(ir) = 2*pi*integral_dke_jd(dpn.',pn2.'.*trapz_dke_yp([mhu(:),XXf0(:,:,ir).']).',1);%initial normalization
        normfinterp.normi1(ir) = 2*pi*integral_dke_jd(dpn.',pn2.'.*trapz_dke_yp([x_leg(:),Xf0_i1.']).',1);%normamization with Legendre pitch-angle grid
        normfinterp.normi2(ir) = 2*pi*integral_dke_jd(dpn.',pn2.'.*trapz_dke_yp([mhu(:),Xf0_i2.']).',1);%normalization from fitted distribution
    end
    %
end

