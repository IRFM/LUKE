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
function simulid = make_luke_simulid_jd(equil,ohm,transpfaste,ripple,waves,wavestructs,locid)
%
% This function creates a generic id for LUKE simulations from input structures
%
if nargin < 7,
    locid = '';
end
%
if nargin < 6,
    wavestructs = '';
end
%
if nargin < 5,
    waves = '';
end
%
if nargin < 4,
    ripple = '';
end
%
if nargin < 3,
    transpfaste = '';
end
%
if nargin < 2,
    ohm = '';
end
%
if nargin < 1
    error('The ''equil'' structure must be specified');
end
%
if isfield(equil,'id'),
    simulid = equil.id;
else
    error('The ''equil'' structure must have a field ''id''');
end
%
if isfield(equil,'fluct') && isfield(equil.fluct,'id'),
    simulid = [simulid,'_',equil.fluct.id];
end
%
if isfield(ohm,'id'),
    simulid = [simulid,'_',ohm.id];
end
%
if isfield(transpfaste,'id'),
    simulid = [simulid,'_',transpfaste.id];
end
%
if isfield(ripple,'id'),
    simulid = [simulid,'_',ripple.id];
end
%
if ~isempty(waves),
    if isstruct(waves{1}),%no fluctuations
        for iw = 1:length(waves),
            simulid = [simulid,'_',waves{iw}.id];
        end
    else %with fluctuations
        for iw = 1:length(waves{1}),
            is1 = max(strfind(waves{1}{iw},'C3PO_'));%wavess contains wave files 
            is2 = strfind(waves{1}{iw},'_itn_1.mat') - 1;
            %
            simulid = [simulid,'_',waves{1}{iw}(is1:is2)];
        end        
    end
end
%
for iw = 1:length(wavestructs),
    simulid = [simulid,'_',wavestructs{iw}.id];
end
%
if ~isempty(locid),
    simulid = [simulid,'_',locid];
end
