function varargout = F_help_equilconsistency(key)
%   F_help_equilconsistency()
%   help = F_help_equilconsistency(key)
%
%plot help for equilconsistency substruct or find help for specific field of equilconsistency
%defined in key

tp.comment  = "Comments on the equilconsistency";
tp.auto_mode= "";
tp.display_mode = "";
tp.prho     = "";
tp.mtheta   = "interpolation factor (the interpolation will be done on m times points on theta direction)";

if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end       
