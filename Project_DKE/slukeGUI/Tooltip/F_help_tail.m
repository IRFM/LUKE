function varargout = F_help_tail(key)
%   F_help_tail()
%   help = F_help_tail(key)
%
%plot help for tail substruct or find help for specific field of the 
%substruct defined in key

tp.dtn      = "";
tp.mode     = "";
tp.bNparmax_tail = "";
tp.bn_tail  = "";
tp.bP_tail  = "Artificial shift of the main lobe of the LH power spectrum : 0 nothing done, < 1 : reduction of the absolute value, > 1 increase of the absolute value";
tp.bopt_tail= "";

if ~exist('key','var'),     key = {};   end

help = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end