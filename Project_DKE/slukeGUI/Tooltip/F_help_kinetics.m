function varargout = F_help_kinetics(key)
%   F_help_kinetics()
%   help = F_help_kinetics(key)
%
%plot help for kinetics substruct or find help for specific field of 
%kinetics defined in key

tp.dkeparam     = {"DKE solver parameters",@F_help_dkeparam};
tp.dkedisplay   = {"",@F_help_dkeparam};
tp.elements     = {"",@F_help_elements};
tp.fast_electron_anomalous_transport = {"Fast electron transport parameters",@F_help_fast_electron_anomalous_transport};

if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end