function varargout = F_help_scheduler_cm(key)
%   F_help_scheduler_cm()
%   help = F_help_scheduler_cm(key)
%
%plot help for wave_solver_yp substruct or find help for specific field of
%wave_solver_yp defined in key

tp.mode = "(0) MatLab distributed computing environment disabled, (1) enabled with the dedicated toolbox, (2) enabled with a private method (2) for the relative function (MDC toolbox must be installed for option 1).";

if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end