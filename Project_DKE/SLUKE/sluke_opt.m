
function opt = sluke_ohm(sparams,ii)

if isfield(sparams.simul,'output') && ~isempty(sparams.simul.output{ii})
    %
    opt.save = sparams.simul.output{ii};
    %
else
    %
    opt.save = 1;%processed data and diags by default 
    %
end
%
if isfield(sparams.simul,'save') && isfield(sparams.simul.save,'kinetics') && sparams.simul.save.kinetics{ii} == 1
    %
    opt.save = 3;%save LUKE in LUKE_RESULTS file (see run_lukert.m)
    %
end
%
if isfield(sparams.simul,'save') && isfield(sparams.simul.save,'waves') && sparams.simul.save.waves{ii} == 1
    %
    opt.waves = 0;%save waves structre in outputs (in runlukert.m)
    %
else
    %
    opt.waves = 1;%remove  waves structre in output
    %
end
%
if isfield(sparams.simul,'save') && isfield(sparams.simul.save,'backup') && sparams.simul.save.backup{ii} == 1
    %
    opt.backup = 1;%savebackup file at each time step (for fluctuations in runlukert.m)
    %
else
    %
    opt.backup = 0;%save waves structre at each time step
    %
end
%
if isfield(sparams,'postprocessing') && ~isempty(sparams.postprocessing)
    %
    opt.proc = sluke_params_value(sparams.postprocessing,ii);
    %
else
    %
    opt.proc = [];
    %  
end