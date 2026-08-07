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
function varargout = F_help_elements(key)
%   F_help_elements()
%   help = F_help_elements(key)
%
%plot help for elements substruct or find help for specific field of element
%defined in key

tp.coulog_model = "Coulomb logarithm model (1i or 2i if no p-dependence)";
tp.Zi_ref       = "i values whose density may be modified by the factor density_factor from C3PO/LUKE/R5X2 calculations if exist in equil structure (for tests). May be vector";
tp.Zi_density_factor = "Ad-hoc multiplication factors of the density of the elements Zi_ref";
tp.screening = {"Screening model", @F_help_screening};

if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end