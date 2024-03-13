function varargout = F_help_generalWave(key)
%   F_help_generalWave()
%   help = F_help_generalWave(key)
%
%plot help for a wave substruct (EC,LH) or find help for specific field of 
% the substruct defined in key

tp.ALOHA    = {"Spectral distribution calculations",@F_help_ALOHA};
tp.C3PO     = {"Ray tracing calculations",@F_help_C3PO};

if ~exist('key','var'),     key = {};   end

help = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end