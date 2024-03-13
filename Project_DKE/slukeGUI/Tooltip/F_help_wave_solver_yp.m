function varargout = F_help_wave_solver_yp(key)
%   F_help_wave_solver_yp()
%   help = F_help_wave_solver_yp(key)
%
%plot help for wave_solver_yp substruct or find help for specific field of
%wave_solver_yp defined in key

tp.scheduler = {"",@F_help_scheduler_cm};

if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end