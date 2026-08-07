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
function varargout = F_help_fit(key)
%   F_help_fit()
%   help = F_help_fit(key)
%
%plot help for fit substruct or find help for specific field of fit
%defined in key

tp.comment      = "Comments on the fit";
tp.mode_equil   = "";
tp.method       = "";
tp.nharm        = "";
tp.ngridesample = "";
tp.otp_load     = "";
        
if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end