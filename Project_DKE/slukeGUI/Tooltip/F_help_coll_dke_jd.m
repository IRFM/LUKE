function varargout = F_help_coll_dke_jd(key)
%   F_help_coll_dke_jd()
%   help = F_help_coll_dke_jd(key)
%
%plot help for coll_dke_jd substruct or find help for specific field of
%coll_dke_jd defined in key

tp.scheduler = {"",@F_help_scheduler_cm};

if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end