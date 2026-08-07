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
function varargout = F_help_screening(key)
%   F_help_screening()
%   help = F_help_screening(key)
%
%plot help for screening substruct or find help for specific field of 
%screening defined in key

tp.ADAS     = "Full path for the full ion screening model ADAS (necessary for screening of partially ionized atoms). If empty, fully ionized impurities are considered. If 'ADAS.mat', default ADAS value in LUKE";
tp.partial  = {"", @F_help_partial};

if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end