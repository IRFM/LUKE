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
function varargout = F_help_scheduler_cm(key)
%   F_help_scheduler_cm()
%   help = F_help_scheduler_cm(key)
%
%plot help for wave_solver_yp substruct or find help for specific field of
%wave_solver_yp defined in key

tp.mode = "(0) MatLab distributed computing environment disabled, (1) enabled with the dedicated toolbox, (2) enabled with a private method (2) for the relative function (MDC toolbox must be installed for option 1).";

if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end