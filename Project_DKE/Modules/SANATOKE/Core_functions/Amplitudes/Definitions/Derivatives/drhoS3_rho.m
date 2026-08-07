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
function drhoS3 = drhoS3_rho(rho,equil,amplitudes)

amps = num2cell(amplitudes);
a = amps{1};
[dS3_0,d3S3_0] = amps{15:16};
[S3_a,dS3_a,d2S3_a,d3S3_a] = amps{39:42};

rho_star = equil.rho_star;

drhoS3 = drhoS2_like_rho(rho,rho_star,a,dS3_0,d3S3_0,S3_a,dS3_a,d2S3_a,d3S3_a);
end
