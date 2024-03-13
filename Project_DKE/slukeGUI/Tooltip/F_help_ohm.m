function varargout = F_help_ohm(key)
%   F_help_ohm()
%   help = F_help_ohm(key)
%
%plot help for ohm substruct or find help for specific field of ohm defined
%in key

tp.comment  = "Comments on the electric field evaluation source";
tp.source   = "Source of the equilibrium, 'file' or 'code'";
tp.code     = "Code name, needed if source is 'code'";
tp.file     = "File name, needed if source is 'file'";
tp.path     = "File path, needed if source is 'file'";

if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end