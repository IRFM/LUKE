%
% How to start SLUKE simulations
%
% by Yves Savoye-Peysson, CEA/IRFM (yves.savoye-peysson@cea.fr)
%
SLUKE is a script layer to LUKE suite of codes, in order to perform easily complex simulations
(multi-machine, multi-time, multi-discharge) of fast electron dynamics in an inhomogenous and anistropic plasma, 
like in a tokamak.

All simulations parameters are contained by the 'sparams' structure that can be build manually, 
interactively (sluke_params_generator.m) or from available PRESETS (sluke_params_preset.m).

NOTE : sluke_params_preset.m is a script that allows to create a full simulation environment (folder and subfolders,
data,two consistent scripts) ready for starting a simulation, with the correct tips. There several examples 
that can be chosen as starting to specific studies, with local opr remote calculations (available machines 
can be chosen interactively). 

The 'sparams' structure can be also defined from the script sluke_params_defaults.m, where all fields are defined, 
but are all empty.

From a 'sparams' structure, it is always possible to create a Matlab script using the script sluke_params_script.m 
that can be used for the simulations that are launched by the Matlab command sluke_params_script(sparams,filename)

Once the ''sparams'' is fully defined or loaded, the simulations can be started by typing sluke(sparams,mfilename),
where mfilename is a MatLab defined function which returns the most recently invoked code file.

It is convenient to operate simulations with two scripts : 1) the script make_sparams_XXXXX.m that create and check
the consistency of the structure 'sparams', and 2) a second script names for example simulation_YYYYY.m that call 
make_sparams_XXXXX, and launch the simulation with sluke(sparams,mfilename. In such a way, all customizations and display 
are gathered ion a single script, that can be updated according to the needs.



