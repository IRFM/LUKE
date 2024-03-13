function varargout = F_help_C3PO(key)
%   F_help_C3PO()
%   help = F_help_C3PO(key)
%
%plot help for C3PO substruct or find help for specific field of the 
%substruct defined in key

tp.ALOHA    = {"Spectral distribution data",@F_help_ALOHAC3PO};
tp.launch   = {"Launching wave parameters", @F_help_launch};

if ~exist('key','var'),     key = {};   end

help = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end