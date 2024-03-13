function varargout = F_help_sdisplay(key)
%   F_help_sdisplay()
%   help = F_help_sdisplay(key)
%
%plot help for sdisplay substruct or find help for specific field of
%the substruct defined in key

tp.inter    = "Interactive mode for selecting parameters";
tp.mode     = "display (0) none (1) text only (2) text and figures (default : 0)";
tp.comparison = "display comparison between experimental value and calculations (1) yes (0) no";
   
if ~exist('key','var'),     key = {};   end

help = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end