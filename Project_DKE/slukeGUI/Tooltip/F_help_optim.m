function varargout = F_help_optim(key)
%   F_help_optim()
%   help = F_help_optim(key)
%
%plot help for optim substruct (EC,LH) or find help for specific field of 
% the substruct defined in key

tp.method   = "(1) edge density in front of the grill is calculated such that simulated RC coefficients are the clostest to observations (0) Edge density in front of the grill is given by the guess";
tp.ne_guess = "edge density in front of the grill (initial guess or enforced value) (m-3)";
tp.tolfun   = "Relative tolerance on targets (if aloha.optim.method = 1)";
tp.tolx     = "Relative tolerance on inputs (if aloha.optim.method = 1)";
tp.nitmax   = "Maximum number of iterations (if aloha.optim.method = 1)";

if ~exist('key','var'),     key = {};   end

help = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end