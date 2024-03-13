function varargout = F_help_eecoll_dke_yp(key)
%   F_help_eecoll_dke_yp()
%   help = F_help_eecoll_dke_yp(key)
%
%plot help for eecoll_dke_yp substruct or find help for specific field of
%eecoll_dke_yp defined in key

tp.scheduler = {"",@F_help_scheduler_cm};

if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end