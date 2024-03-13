function varargout = F_help_git(key)
%   F_help_git()
%   help = F_help_git(key)
%
%plot help for git substruct or find help for specific field of git
%defined in key

tp.projects = "Git list of projects that may be updated remotely from repository (git pull) prior a simulation.";
tp.pull     = "Git pull remote projects (1), no git pull (0).";
tp.display  = "(0) : no display, (1) : display results";
        
if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end