function varargout = F_help_jprofileconsistency(key)
%   F_help_jprofileconsistency()
%   help = F_help_jprofileconsistency(key)
%
%plot help for jprofileconsistency substruct or find help for specific 
%field of jprofileconsistency defined in key

tp.code = "selfconsistency between LUKE and equilibrium solver (current density profiles)";
tp.nit  = "selfconsistency between LUKE and equilibrium solver for the current density profile (may be METIS). Time-independent calculation";
 
if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end