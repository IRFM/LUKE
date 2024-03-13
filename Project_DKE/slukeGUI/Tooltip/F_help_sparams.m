function varargout = F_help_sparams(key)
%   F_help_sparams()
%   help = F_help_sparams(key)
%
%plot help for sparams struct or find help for specific field of sparams

tp.value    = {"Luke parameters",@F_help_value};
tp.rfwaves	= {"Radio-frequency waves parametes", @F_help_rfwaves};
tp.postprocessing = {"Postprocessing parameters", @F_help_postprocessing};
tp.diags    = {"Sintetic diagnostics parameters", @F_help_diags};

if ~exist('key','var'),     key = {};   end

help = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end

