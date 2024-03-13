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