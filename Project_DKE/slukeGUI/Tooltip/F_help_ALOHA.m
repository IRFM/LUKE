function varargout = F_help_ALOHA(key)
%   F_help_ALOHA()
%   help = F_help_ALOHA(key)
%
%plot help for ALOHA substruct (EC,LH) or find help for specific field of 
%the substruct defined in key

tp.port     = "antenna ports : Q6A, or Q6B or Q6A+Q6B -> (C2,C3) or (C3,C4) or (LH1,LH2) for Tore Supra or WEST";
tp.remote_profile = "";
tp.display  = {"",@F_help_display};
tp.optim    = {"optim",@F_help_optim};

if ~exist('key','var'),     key = {};   end

help = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end