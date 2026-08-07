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
function varargout = F_help_sparams(key)
%   F_help_sparams()
%   help = F_help_sparams(key)
%
%plot help for sparams struct or find help for specific field of sparams

tp.value    = {"Luke parameters",@F_help_value};
tp.rfwaves	= {"Radio-frequency waves parametes", @F_help_rfwaves};
tp.postprocessing = {"Postprocessing parameters", @F_help_postprocessing};
tp.diags    = {"Sintetic diagnostics parameters", @F_help_diags};

if ~exist('key','var'),     key = {};   end

help = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end

