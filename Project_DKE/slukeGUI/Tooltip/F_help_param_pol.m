function varargout = F_help_param_pol(key)
%   F_help_param_pol()
%   help = F_help_param_pol(key)
%
%plot help for param_pol substruct or find help for specific field of
%the substruct defined in key

tp.Pin_in   = "corrected initial total power. If NaN take value ALOHA else the value is enforced by Pin_in (W). Consider globalspectrum to get the total LH power. ";

if ~exist('key','var'),     key = {};   end

help = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end