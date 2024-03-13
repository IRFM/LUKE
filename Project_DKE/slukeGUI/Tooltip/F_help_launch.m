function varargout = F_help_launch(key)
%   F_help_launch()
%   help = F_help_launch(key)
%
%plot help for launch substruct or find help for specific field of the 
%substruct defined in key

tp.omega_rf = "";
tp.bNpar0   = "";
tp.bdNpar0  = "";
tp.bPlhtot  = "";
tp.mainlobeshift = "Artificial shift of the main lobe of the LH power spectrum : 0 nothing done, < 1 : reduction of the absolute value, > 1 increase of the absolute value";
tp.rZ0      = "";
tp.m0       = "";
tp.phi0     = "";
tp.i_ref    = "";
tp.LFS      = "";
tp.mmode    = "";
tp.nparp    = "";
tp.a_sdNpar = "";
tp.w0       = "";
tp.z_L      = "";
tp.tail     = {"Tail model",@F_help_tail};

if ~exist('key','var'),     key = {};   end

help = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end