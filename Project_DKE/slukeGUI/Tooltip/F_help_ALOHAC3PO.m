function varargout = F_help_ALOHAC3PO(key)
%   F_help_ALOHAC3PO()
%   help = F_help_ALOHAC3PO(key)
%
%plot help for ALOHA substruct in C3PO or find help for specific field of
%the substruct defined in key

tp.spectrum    = {"Spectral distribution data",@F_help_spectrum};

if ~exist('key','var'),     key = {};   end

help = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end