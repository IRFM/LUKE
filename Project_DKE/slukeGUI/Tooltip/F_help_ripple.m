function varargout = F_help_ripple(key)
%   F_help_ripple()
%   help = F_help_ripple(key)
%
%plot help for ripple substruct or find help for specific field of ripple
%defined in key

tp.comment  = "Comments on the ripple source";
tp.source   = "Source of the ripple,'preset' 'file' or 'code'";
tp.preset   = "Preset name, needed if source is 'preset";
tp.file     = "File name, needed if source is 'file'";
tp.path     = "File path, needed if source is 'file'";
tp.mode     = "(0): non magnetic ripple, (1) with toroidal magnetic ripple. For Tore Supra or WEST tokamaks only yet";
  
if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end