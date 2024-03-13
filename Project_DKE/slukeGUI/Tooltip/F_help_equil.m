function varargout = F_help_equil(key)
%   F_help_equil()
%   help = F_help_equil(key)
%
%plot help for equil substruct or find help for specific field of equil
%defined in key

tp.comment  = "Comments on the MHD equilibrium source";
tp.source   = "Source of the equilibrium, 'file' or 'code'";
tp.code     = "Code name, needed if source is 'code'";
tp.file     = "File name, needed if source is 'file'";
tp.path     = "File path, needed if source is 'file'";
tp.equilconsistency = {"", @F_help_equilconsistency}; %??
tp.fit      = {"", @F_help_fit};   %??
tp.ripple   = {"Magnetic ripple source parameter",@F_help_ripple}; 

if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end