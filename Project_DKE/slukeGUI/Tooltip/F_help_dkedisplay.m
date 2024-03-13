function varargout = F_help_dkedisplay(key)
%   F_help_dkedisplay()
%   help = F_help_dkedisplay(key)
%
%plot help for dkedisplay substruct or find help for specific field of dkedisplay
%defined in key

tp.comment = "Comments on the kinetics dkeparam parameters";
tp.source  = "Source of dkedisplay: 'preset', 'code' or 'file'";
tp.preset  = "Preset name";

if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end