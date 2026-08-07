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
function varargout = F_help_partial(key)
%   F_help_partial()
%   help = F_help_partial(key)
%
%plot help for partial substruct or find help for specific field of partial
%defined in key

tp.elastic  = "Elastic scattering by partially ionized atoms. List of models : 'DFT', 'Thomas-Fermi', 'Thomas-Fermi-Kirillov', 'Tseng-Pratt-Avdonina-Lamoureux', 'Tseng-Pratt-Botto', 'Tseng-Pratt-Thomas-Fermi'";
tp.inelastic= "Inelastic scattering by partially ionized atoms: (0) -> no (1) -> yes";
tp.dftpath  = "For specific DFT file path only. Leave empty otherwise and the default calculations will be considered in LUKE";

if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end
