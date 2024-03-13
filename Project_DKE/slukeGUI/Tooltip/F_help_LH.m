function varargout = F_help_LH(key)
%   F_help_LH()
%   help = F_help_LH(key)
%
%plot help for LH substruct or find help for specific field of LH 
%expressed in key

help = F_help_generalWave(key);
if nargout >= 1
    varargout{1} = help;
end

end