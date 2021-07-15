function [sparams,err,status] = sluke_params_defaults
%
% LUKE - Simulation parameters structure for sluke calculations with default values. All parameters are in a structure of cell arrays of the SAME SIZE. 
% 
% INPUT :
%
%   - varargin : initial 'sparams' structures for modifications (one -> identical output, 2 -> merged structures is created)
%
% OUTPUT :
%
%   - sparams : structure of parameters for sluke calculations with default values
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
sparams = {};
%
sparams.machine = {'TOKAMAK NAME'};%Machine name
%
sparams.discharge.shot = {'SHOT NUMBER'};%shot number
sparams.discharge.tmin = {0};%minimum time in seconds
sparams.discharge.tmax = {1};%maximum time in seconds
sparams.discharge.nt = {1};%number of subtimes
%
sparams.simul.id = {'SIMULATION ID'};%general simulation id
sparams.simul.comment = {'COMMENTS ON SIMULATION'};% comments on the simulations (context, author)
sparams.simul.enable = {1};%simulation enabled
sparams.simul.enforce = {0};%no enforce
sparams.simul.remote_profile = {0};%Local calculations
sparams.simul.wait4results = {0};%Do not wait
%
sparams.dkeparam.id = {'LH_RT'};%kinetic simulation parameters id
sparams.dkeparam.comment = {''};% comments on the kinetic simulation parameters
sparams.dkeparam.source = {'preset'};%source of the data (preset, file, value)
sparams.dkeparam.preset = {'LH_RT'};%preset name (LH_RT, EC_RT, RT)
sparams.dkeparam.file = {''};%filename. Used if source is 'file'
sparams.dkeparam.path = {''};%absolute path to the file. Used if source is 'file'
%
sparams.dkedisplay.id = {'NO_DISPLAY'};%kinetic simulation display options id
sparams.dkedisplay.comment = {''};% comments on the kinetic simulation display options
sparams.dkedisplay.source = {'preset'};%source of the data (preset, file, value)
sparams.dkedisplay.preset = {'NO_DISPLAY'};%preset name (NO_DISPLAY, PARTIAL_VISUAL, VISUAL))
sparams.dkedisplay.file = {''};%filename. Used if source is 'file'
sparams.dkedisplay.path = {''};%absolute path to the file. Used if source is 'file'
%
sparams.equil.id = {''};%toroidal MHD equilibrium id
sparams.equil.comment = {''};%comments on toroidal MHD equilibrium id
sparams.equil.source = {''};%source of the data (code, file, value)
sparams.equil.code = {''};%code name. if source is 'code'
sparams.equil.file = {''};%filename. Used if source is 'file'
sparams.equil.path = {''};%absolute path to the file. Used if source is 'file'
%
sparams.equil.equilconsistency.id = {'DEFAULT'};%id of the consistency procedure for the toroidal MHD equilibrium
sparams.equil.equilconsistency.comment = {''};%comments on the consistency procedure for the toroidal MHD equilibrium
sparams.equil.equilconsistency.source = {'value'};%source of the data (file, value)
sparams.equil.equilconsistency.auto_mode = {1};%used if source is 'value'
sparams.equil.equilconsistency.display_mode = {0};%used if source is 'value'
sparams.equil.equilconsistency.prho = {''};%used if source is 'value'
sparams.equil.equilconsistency.mtheta = {''};%used if source is 'value'
%
sparams.equil.fit.id = {'DEFAULT'};%id of the fit procedure for the toroidal MHD equilibrium (used by ray-tracing and equilibrium consistency)
sparams.equil.fit.comment = {''};%comments on the fit procedure for the toroidal MHD equilibrium
sparams.equil.fit.source = {'value'};%source of the data (file, value)
sparams.equil.fit.mode_equil = {1};%used if source is 'value'
sparams.equil.fit.method = {'spline'};%used if source is 'value'
sparams.equil.fit.nharm = {''};%used if source is 'value'
sparams.equil.fit.ngridresample = {1001};%used if source is 'value'
sparams.equil.fit.opt_load = {0};%used if source is 'value'
%
sparams.ohm.id = {''};%id for the Ohmic electric field
sparams.ohm.comment = {''};%comment on the Ohmic electric field
sparams.ohm.source = {''};%source of the data (code, file, value)
sparams.ohm.code = {''};%code name. if source is 'code'
sparams.ohm.file = {''};%filename. Used if source is 'file'
sparams.ohm.path = {''};%absolute path to the file. Used if source is 'file'
%
sparams.rf.rayparam.id = {'C3PO_LH'};
sparams.rf.rayparam.comment = {''};
sparams.rf.rayparam.source = {''};
sparams.rf.rayparam.test_mode = {0};
sparams.rf.rayparam.tensortype = {0};
sparams.rf.rayparam.t0 = {0};
sparams.rf.rayparam.dt0 = {1e-4};
sparams.rf.rayparam.dS = {1e-4};
sparams.rf.rayparam.tol = {1e-12};
sparams.rf.rayparam.kmax = {30000};
sparams.rf.rayparam.ncyclharm = {0};
sparams.rf.rayparam.reflection = {1};
sparams.rf.rayparam.rel_opt = {1};
sparams.rf.rayparam.nperp = {1000};
sparams.rf.rayparam.pperpmax = {10};
sparams.rf.rayparam.tau_lim = {20};
sparams.rf.rayparam.metricmode = {1};
sparams.rf.rayparam.rhoswitch = {0.1};
sparams.rf.rayparam.substitution_method = {7};
%
sparams.rf.raydisplay.id = {'NO_DISPLAY'};
sparams.rf.raydisplay.comment = {''};
sparams.rf.raydisplay.source = {''};
sparams.rf.raydisplay.ray = {0};
sparams.rf.raydisplay.equilibrium = {0};
sparams.rf.raydisplay.fluctuations = {0};
sparams.rf.raydisplay.p_opt = {-1};
sparams.rf.raydisplay.mdce = {0};
%
sparams.postprocessing.id = {{} {} {}};
sparams.postprocessing.comment = {'' '' ''};
sparams.postprocessing.source = {'value' 'value' 'value'};
sparams.postprocessing.ir_display = {0,0,0};
sparams.postprocessing.p_opt = {-1,-1,-1};
sparams.postprocessing.dp_cyl = {0.1,0.1,0.1};
sparams.postprocessing.pnmax = {NaN,NaN,NaN};
sparams.postprocessing.subtitle = {'','',''};
sparams.postprocessing.opt.peak = {'','',''};
sparams.postprocessing.opt.wave = {'','',''}
sparams.postprocessing.opt.jpeak = {0,0,0};
sparams.postprocessing.opt.peakmode = {0,0,0};
sparams.postprocessing.opt.blist = {'','',''};
sparams.postprocessing.opt.spec = {1,1,1};
sparams.postprocessing.opt.its_rf = {true,true,true};
sparams.postprocessing.opt.diaryname = {[],[],[]};
%
[err,status] = sluke_params_consistency(sparams);
%