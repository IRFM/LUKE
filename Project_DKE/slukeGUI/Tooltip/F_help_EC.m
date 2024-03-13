function varargout = F_help_EC(key)
%   F_help_EC()
%   help = F_help_EC(key)
%
%plot help for EC substruct or find help for specific field of EC 
%expressed in key

help = F_help_generalWave(key);
if nargout >= 1
    varargout{1} = help;
end

end