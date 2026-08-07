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
function wavestruct = imake_wavestructs_jd(equil,launch)
%
id_rtparam = launch.type;
wavestruct = load_structures_yp('rtparam',id_rtparam,'');
wavestruct.rtparam = ['C3POPARAM_',id_rtparam,'.mat'];
%
wavestruct.launch = launch;
wavestruct.wavesolver = 'C3PO';
wavestruct.id = [wavestruct.wavesolver,'_',wavestruct.launch.id];
wavestruct.equil = equil;
wavestruct.equil_id = equil.id;
