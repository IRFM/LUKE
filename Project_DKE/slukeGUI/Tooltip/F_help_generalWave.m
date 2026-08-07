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
function varargout = F_help_generalWave(key)
%   F_help_generalWave()
%   help = F_help_generalWave(key)
%
%plot help for a wave substruct (EC,LH) or find help for specific field of 
% the substruct defined in key

tp.ALOHA    = {"Spectral distribution calculations",@F_help_ALOHA};
tp.C3PO     = {"Ray tracing calculations",@F_help_C3PO};

if ~exist('key','var'),     key = {};   end

help = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end