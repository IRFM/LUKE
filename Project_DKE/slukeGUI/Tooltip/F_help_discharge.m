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
function varargout = F_help_discharge(key)
%   F_help_discharge()
%   help = F_help_discharge(key)
%
%plot help for discharge substruct or find help for specific field of discharge
%defined in key

tp.shot = "Shot number";
tp.gas  = "'Main gas type (H, D, He), or empty if unknown.";
tp.tmin = "Minimum of the considered time interval (s)";
tp.tmax = "Maximum of the considered time interval (s)";
tp.nt   = "Number of sub-intervals between tmin and tmax (n>=1). If none, n = 1 is considered in the calculations. Use sluke_params_time to expand the params structure before calculations";

if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end