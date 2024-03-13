function varargout = F_help_screening(key)
%   F_help_screening()
%   help = F_help_screening(key)
%
%plot help for screening substruct or find help for specific field of 
%screening defined in key

tp.ADAS     = "Full path for the full ion screening model ADAS (necessary for screening of partially ionized atoms). If empty, fully ionized impurities are considered. If 'ADAS.mat', default ADAS value in LUKE";
tp.partial  = {"", @F_help_partial};

if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end