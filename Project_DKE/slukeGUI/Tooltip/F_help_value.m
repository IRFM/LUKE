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
function varargout = F_help_value(key)
%   F_help_value()
%   help = F_help_value(key)
%
%plot help for value substruct or find help for specific field of value
%defined in key

tp.machine      = "Machine name. WARNING: It is used to access to database if needed. If wrong could lead to not operate part of the code.  (WEST --> WEST, TORE SUPRA --> TS, ...)";
tp.discharge    = {"Discharge parameters",@F_help_discharge};
tp.simul        = {"Simulation progresses parameters",@F_help_simul};
tp.kinetics     = {"Parameters for the dkesolver",@F_help_kinetics};
tp.equil        = {"Magnetic and thermodinamic equilibrium parametes",@F_help_equil};
tp.ohm          = {"Electric field struct",@F_help_ohm};

if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end