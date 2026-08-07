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
function [XXf0] = legendre2f_yp(dkeparam,momentumDKE,XXf0_interp)
% LUKE: Restore the distribution function with its projection on the Legendre polynomial basis ( for data compression)
%
% Restore the distribution function with its projection on the Legendre polynomial basis ( for data compression)
%
%   INPUTS:
%   
%       - dkeparam: LUKE parameter structure
%       - momentumDKE: LUKE grid structure 
%       - XXf0_interp: distribution unction projected on the Legendre polynomials basis. May be an array cell 
%       
%   OUTPUTS:
%   
%       - XXf0: initial distribution function.
%
% by Yves Peysson(CEA/IRFM, yves.peysson@cea.fr) and Joan Decker (EPFL/CRPP, joan.decker@epfl.ch)
%
n_pol = dkeparam.n_gauleg;%Necessary for accurate reconstruction at ksi = -1
[x_leg] = gauleg_dke_yp(dkeparam.n_gauleg,dkeparam.epsi_gauleg);%Gauss-Legendre abscissa and weigth calculations between -1 and + 1
[Pm,cL] = leg_dke_yp(x_leg(:)',n_pol);%Legendre polynomial calculation
%
if iscell(XXf0_interp)
    for it = 1:length(XXf0_interp),
        XXf0{it} = restoref_legendre_yp(Pm,x_leg,cL,dkeparam.method,momentumDKE.mhu,XXf0_interp{it});
    end
else
    XXf0 = restoref_legendre_yp(Pm,x_leg,cL,dkeparam.method,momentumDKE.mhu,XXf0_interp);
end
%
end

function XXf0 = restoref_legendre_yp(Pm,x_leg,cL,method,mhu,XXf0_leg)
    %
    XXf0 = zeros(size(XXf0_leg,1),length(mhu),size(XXf0_leg,3));
    %
    for ir = 1:size(XXf0_leg,3),
        Xf0_i1 = (Pm.'*(XXf0_leg(:,:,ir).*(ones(size(XXf0_leg(:,:,ir),1),1)*cL.')).').';%Distribution function on the Legendre polynomials pitch-angle grid back calculated
        XXf0(:,:,ir) = interp1(x_leg(:),Xf0_i1.',mhu(:),method).';%Distribution function on initial pitch-angle grid back calculated from Legendre polynomial fit
    end
    %
end

