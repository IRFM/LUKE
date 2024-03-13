function varargout = F_help_remote(key)
%   F_help_remote()
%   help = F_help_remote(key)
%
%plot help for remote substruct or find help for specific field of remote
%defined in key

tp.profile  = "Type dispremoteprofiles('','scheduler'); to get the values or names. Local interactive calculations -> (0). May be indexes or names";
tp.mode     = "Calculation distribution mode -> (-2,-1) : remcomputing on the remote cluster dkepath.remote(-mdce_mode) (0) : sequential calculation, (1)  : use of jobcomputing,  (2) : use of parcomputing (parfor) (3) : remcomputing on the local cluster";
tp.remtimout= "Returnmode -> (0): wait for result, (1) : return hand after starting calculation (valid only if profile > 0 (or not empty or not 'local' or mode < 0)";
tp.debugmode= "Debug mode (0) off (1) or (2) on";
tp.cleanmode= "Clean job files/folders : both on remote and local (2), only on remote (1) or not at all (0)";
tp.matver   ="Matlab version used on the remote machine (if not exist, the defaut value in remote profile is used). By definition, it should be of the form matxxx, where xxx for the matlab version : type version in matlab, and 9.3 -> xxx = 903 or 9.11 -> xxx = 911";
tp.git      = {"Git update during luke call parameters",@F_help_git};
tp.scheduler= {"Selected scheduler. E.g. pbs, torque", @F_help_scheduler};

if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end