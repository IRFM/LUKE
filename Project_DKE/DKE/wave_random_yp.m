function waves = wave_random_yp(dkepath,dkeparam,wavestructs,f0struct)
%
% Use parallel processing for reducing the computational time of all waves
% launched in the plasma by wavestructs
%
% INPUT
%    - dkepath structure
%    - dkeparam structure
%    - dkedisplay structure
%    - wavestructs structure
%    - f0struct structure
%
% OUTPUT: 
%    - waves structure
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
arg_range = cell(1,length(wavestructs));
%
for iws = 1:length(wavestructs),
    arg_range{iws} = wavestructs{iws};
end
%
if isfield(dkeparam,'clustermode'),
    if isfield(dkeparam.clustermode,'wave_solver_yp'),dkecluster = dkeparam.clustermode.wave_solver_yp;end
end
%
[dummy,out] = mdce_luke(@wave_solver_yp,{dkepath,wavestructs,f0struct},2,arg_range,dkecluster);
%
for iws = 1:length(wavestructs),
    waves{iws} = out{1}(iws);
end
%
     
        