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
function varargout = F_help_jprofileconsistency(key)
%   F_help_jprofileconsistency()
%   help = F_help_jprofileconsistency(key)
%
%plot help for jprofileconsistency substruct or find help for specific 
%field of jprofileconsistency defined in key

tp.code = "selfconsistency between LUKE and equilibrium solver (current density profiles)";
tp.nit  = "selfconsistency between LUKE and equilibrium solver for the current density profile (may be METIS). Time-independent calculation";
 
if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end