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
clear all
%
% default HXR parameters
%
hxrparam.id = 'EC';
hxrparam.mfactor = 1;%For the magnetic equilibrium
hxrparam.method = 'spline';%For the magnetic equilibrium in the HXR calculations
hxrparam.ns = 3000;%for chord integration
hxrparam.n_gauleg = 35;%Number of Legendre polynomials for projections of cross-section and electron velocity distribution
hxrparam.epsi_gauleg = 1e-14;%Accuracy of the Legendre projection
hxrparam.kmin = 35;% standard minimum value for Tph calculation (LH : 50; EC : 35)
hxrparam.kmax = 75;% standard maximum value for Tph calculation (LH : 110; EC : 75)
hxrparam.kphot = 20:10:200;% standard photon energy list for calculations
%
save(['HXRPARAM_',hxrparam.id,'.mat'],'hxrparam');
%
