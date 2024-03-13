function varargout = F_help_display(key)
%   F_help_display()
%   help = F_help_display(key)
%
%plot help for display substruct or find help for specific field of 
% the substruct defined in key

tp.data     = {"Experimental data parameters",@F_help_data};
tp.results  = "Display and save ALOHA power spectrum and RC figures (2), display and do not save figures (1), do not display but save figures (0), do nothing (-1)";

if ~exist('key','var'),     key = {};   end

help = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end