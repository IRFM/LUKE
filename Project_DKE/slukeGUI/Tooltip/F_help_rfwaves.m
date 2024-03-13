function varargout = F_help_rfwaves(key)
%   F_help_rfwaves()
%   help = F_help_rfwaves(key)
%
%plot help for rfwaves substruct or find help for specific field of rfwaves

tp.comment  = "Comments on wave type source";
tp.source   = "Source of the waves, 'file', 'code'";
tp.code     = "Code name, needed if source is 'code'";
tp.file     = "File name, needed if source is 'file'";
tp.path     = "File path, needed if source is 'file'";
tp.enable   = "nable (1) or not (0) waves in the simulation";
tp.antenna  = {"Antenna parameters",@F_help_antenna};
tp.solver   = "Solver parameters";%,@F_help_solver}; 

if ~exist('key','var'),     key = {};   end

help = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end