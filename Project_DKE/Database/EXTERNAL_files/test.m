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
numshot = 2;
numrun_in = 551;
numrun_out = 502;%single ray: 502, beam: 503
timeslice = 0;
%
time_interp = 1;%nearest point
%
wordkir = pwd;
%
[flag,~,external] = matremote_jd(@load_externaldata_ITM,{workdir,numshot,numrun,timeslice,time_interp,opt_gui,select},remote