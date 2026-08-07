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
function varargout = F_help_spectrum(key)
%   F_help_spectrum()
%   help = F_help_spectrum(key)
%
%plot help for spectrum substruct or find help for specific field of
%the substruct defined in key

tp.param_tor    = {"Toroidal parameter",@F_help_param_tor};
tp.param_pol    = {"Poloidal parameter",@F_help_param_pol};
tp.opt_otimum   = "Use of function lsqnonlin for gaussian lobe fit (default : 0)";
tp.globalspectrum = "Upper and lower half-antenna modules are considered independently (0) or only half upper module for the whole antenna (1). If sparams.rfwaves.antenna.LH.ALOHA.optim.method == 0, sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.globalspectrum = 1 is enforced.";
tp.sdisplay     = {"",@F_help_sdisplay};

if ~exist('key','var'),     key = {};   end

help = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end