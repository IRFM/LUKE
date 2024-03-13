function varargout = F_help_simul(key)
%   F_help_simul()
%   help = F_help_simul(key)
%
%plot help for simul substruct or find help for specific field of simul
%defined in key

tp.id       = "General silmulation id";
tp.comment  = "Comments on the simulations (context, author for example)";
tp.enable   = "Enable (1) or not (0) the simulations";
tp.enforce  = "(2) -> enforce new simulation (erase all corresponding files), (1) -> enforce new simulation if stamp inconsistencies are found, (0) -> simulation is not enforced (but may be cancelled manually : file LUKE_DATA_*** is deleted in case of problem),  (-1) -> simulation is not enforced and not cancelled";
tp.max_simulations = "Maximum number of distributed simulations (remote machine dependent). if Inf, no limit.";
tp.log      = "Generate log file and specific diaries. O : no log file, 1, log files enabled";
tp.output   = "0 or empty : LUKE output structure with all or reduced fields as defined in sparams.kinetics.dkeparam.opt_struct, (1) : processed data and synthetic diagnostics if any, (2) : processed data and synthetic diagnostics if any + LUKE output structure with all or reduced fields as defined in sparams.kinetics.dkeparam.opt_struct, (3) : save LUKE_RESULTS in SLUKE_TEMP ";
tp.save     = {"Save parameters for fluctuation time step",@F_help_save};
tp.remote   = {"Remote calculations parameters", @F_help_remote};
tp.jprofileconsistency  = {"",@F_help_jprofileconsistency};
tp.initial_distribution = "Time evolution of the distribution function : (0) -> at each time, initial distribution is a Maxwellian, (-1) -> at each time, initial distribution is the distribution from previous time (except the first that is necessarily Maxwellian)";
tp.mute     = {"Enable or disable display of various functions",@F_help_mute};

if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end
