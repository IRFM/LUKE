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
function [wavestructss,wavestructids] = iluke_mod_P0_wavestructs(wavestructss,wavestructids,status,iw,P0_kW)
%
P0str = ['_P0_',num2str(P0_kW),'_kW'];
%
flag_shotimes = find(status.wavestructs(iw,:) == 1);
%
for it = flag_shotimes,
    %
    wavestructss{iw,it}.launch.angles.P0 = P0_kW*1e3;
    wavestructss{iw,it}.launch.angles.id = [wavestructss{iw,it}.launch.angles.id,P0str];
    %
    wavestructss{iw,it}.launch.yP_L = P0_kW*1e3;
    wavestructss{iw,it}.launch.id = [wavestructss{iw,it}.launch.id,P0str];
    %
    wavestructss{iw,it}.id = [wavestructss{iw,it}.id,P0str];
    %
end
%
wavestructids{iw} = wavestructss{iw,it}.id;
%       
    
    
    
    
    