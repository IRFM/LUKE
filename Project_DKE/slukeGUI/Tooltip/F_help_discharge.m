function varargout = F_help_discharge(key)
%   F_help_discharge()
%   help = F_help_discharge(key)
%
%plot help for discharge substruct or find help for specific field of discharge
%defined in key

tp.shot = "Shot number";
tp.gas  = "'Main gas type (H, D, He), or empty if unknown.";
tp.tmin = "Minimum of the considered time interval (s)";
tp.tmax = "Maximum of the considered time interval (s)";
tp.nt   = "Number of sub-intervals between tmin and tmax (n>=1). If none, n = 1 is considered in the calculations. Use sluke_params_time to expand the params structure before calculations";

if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end