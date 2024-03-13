function varargout = F_help_data(key)
%   F_help_data()
%   help = F_help_data(key)
%
%plot help for data substruct or find help for specific field of the 
%substruct defined in key

tp.mode     = "";
tp.results  = "display and save experimental data figures (2), display and do not save figures (1), do not display but save figures (0), do nothing (-1) if exist";

if ~exist('key','var'),     key = {};   end

help = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end