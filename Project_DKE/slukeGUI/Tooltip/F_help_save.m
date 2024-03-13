function varargout = F_help_save(key)
%   F_help_save()
%   help = F_help_save(key)
%
%plot help for save substruct or find help for specific field of save 
%defined in key

tp.waves    = "(1) save waves at each fluctuation time step (0) do not save in runlukert.m";
tp.backup   = "(1) save fluctuation time steps (0) do not save in runlukert.m";

if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end