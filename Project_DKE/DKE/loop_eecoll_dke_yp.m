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
function [F1_1,F1_2,F2_1,B1_1,B1_2,B1_3,B1_4,B1_5,B2_1,B2_2,B2_3] = loop_eecoll_dke_yp(ip,pn,sfM,spn,spn2,sv,sgamma,sgamma2,ssigma,sz,sJ1,sJ2)
%LUKE - Electron-electron Belaiev-Budker collision operator (loop function for distributed computing environment)
%
%Electron-electron Belaiev-Budker collision operator (loop function
%for distributed computing environment)
%
%by Yves Peysson (CEA-IRFM,yves.peysson@cea.fr) and Joan Decker (CEA-IRFM,joan.decker@cea.fr) 
%
    smasku = spn <= pn(ip);
    smaskl = spn >= pn(ip);
    %
    F1_1 = trapz_dke_yp([spn,sfM.*spn.*sv.*smasku])';
    F1_2 = trapz_dke_yp([spn,sfM.*spn.*sv.*(1 - sgamma.*ssigma./sz).*smasku])';
    F2_1 = trapz_dke_yp([spn,sfM.*spn.*smaskl])';
    %
    B1_1 = trapz_dke_yp([spn,sfM.*smasku.*spn2])';
    B1_2 = trapz_dke_yp([spn,sfM.*smasku.*spn2.*spn2])';
    B1_3 = trapz_dke_yp([spn,sfM.*smasku.*spn2.*sJ1./sgamma])';
    B1_4 = trapz_dke_yp([spn,sfM.*smasku.*spn2.*sJ2./sgamma])';
    B1_5 = trapz_dke_yp([spn,sfM.*smasku.*spn2.*((sgamma - ssigma./sz)./sgamma)])';
    B2_1 = trapz_dke_yp([spn,sfM.*smaskl.*spn2./sv])';
    B2_2 = trapz_dke_yp([spn,sfM.*smaskl.*spn2./sv./sgamma2])';
    B2_3 = trapz_dke_yp([spn,sfM.*smaskl.*spn2.*sv])'; 
end
