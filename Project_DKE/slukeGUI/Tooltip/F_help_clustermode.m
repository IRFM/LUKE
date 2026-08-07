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
function varargout = F_help_clustermode(key)
%   F_help_clustermode()
%   help = F_help_clustermode(key)
%
%plot help for clustermode substruct or find help for specific field of
%clustermode defined in key

tp.coll_dke_jd = "Distributed computing environment parameters for function coll_dke_jd";
tp.eecoll_dke_jd = "Distributed computing environment parameters for function eecoll_dke_yp";
tp.wave_solver_yp = "Distributed computing environment parameters for function wave_solver_yp";
tp.rfdiff_dke_jd = "Distributed computing environment parameters for function rfdiff_dke_jd"; 

if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end
end