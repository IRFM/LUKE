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
sparams.postprocessing.id = {''};
sparams.postprocessing.comment = {''};
sparams.postprocessing.source = {'value'};
sparams.postprocessing.ir_display = {0};
sparams.postprocessing.p_opt = {-1};
sparams.postprocessing.dp_cyl = {0.1};
sparams.postprocessing.pnmax = {NaN};
sparams.postprocessing.subtitle = {''};
sparams.postprocessing.opt.peak = {''};
sparams.postprocessing.opt.wave = {''};
sparams.postprocessing.opt.jpeak = {0};
sparams.postprocessing.opt.peakmode = {0};
sparams.postprocessing.opt.blist = {''};
sparams.postprocessing.opt.spec = {1};
sparams.postprocessing.opt.its_rf = {true};
sparams.postprocessing.opt.diaryname = {''};
%
sparams.diags.hxr.hxrspec.id = {''};
sparams.diags.hxr.hxrspec.comment = {''};
sparams.diags.hxr.hxrspec.source = {'value'};%source of the data (code, file, value)
sparams.diags.hxr.hxrspec.code = {''};%source of the data (code, file, value)
sparams.diags.hxr.hxrspec.file = {''};%filename. Used if source is 'file'
sparams.diags.hxr.hxrspec.path = {''};%absolute path to the file. Used if source is 'file'
sparams.diags.hxr.hxrspec.nchords = 38;
sparams.diags.hxr.hxrspec.R_hxr = {[3.0311,3.0496,3.0654,3.0790,3.0910,3.1015,3.1107,3.1189,3.1260,3.1323,3.1378,3.1426,3.1468,3.1503,3.1532,3.1556,3.1575,3.1588,3.1596,3.1600,3.1598,3.1592,3.1581,3.1564,3.1542,3.1515,3.1482,3.1443,3.1398,3.1345,3.1285,3.1217,3.1139,3.1050,3.0949,3.0835,3.0703,3.0552]};%All default values correspond to HXR disagnostic on WEST tokamak
sparams.diags.hxr.hxrspec.Z_hxr= {[-0.4354,-0.4056,-0.3775,-0.3507,-0.3250,-0.3003,-0.2764,-0.2533,-0.2307,-0.2086,-0.1870,-0.1658,-0.1449,-0.1242,-0.1039,-0.0837,-0.0636,-0.0437,-0.0238,-0.0040,0.0158,0.0357,0.0556,0.0756,0.0958,0.1161,0.1367,0.1575,0.1787,0.2002,0.2222,0.2447,0.2677,0.2915,0.3160,0.3415,0.3680,0.3959]};
sparams.diags.hxr.hxrspec.alpha_hxr = {zeros(1,38)};
sparams.diags.hxr.hxrspec.beta_hxr = {[1.2558,1.2723,1.2889,1.3055,1.3221,1.3387,1.3552,1.3718,1.3884,1.4050,1.4216,1.4382,1.4547,1.4713,1.4879,1.5045,1.5211,1.5376,1.5542,1.5708,1.5874,1.6040,1.6205,1.6371,1.6537,1.6703,1.6869,1.7034,1.7200,1.7366,1.7532,1.7698,1.7863,1.8029,1.8195,1.8361,1.8527,1.8692]};
sparams.diags.hxr.hxrspec.EG_hxr = {1e-8*[0.1715,0.1766,0.1810,0.1854,0.1898,0.1941,0.1981,0.2024,0.2063,0.2101,0.2142,0.2179,0.2216,0.2256,0.2291,0.2326,0.2364,0.2398,0.2431,0.2460,0.2431,0.2398,0.2364,0.2326,0.2291,0.2256,0.2216,0.2179,0.2142,0.2101,0.2063,0.2024,0.1981,0.1941,0.1898,0.1854,0.1810,0.1766]};
sparams.diags.hxr.hxrspec.kd_hxr = {ones(38,1)*[10,30,50,70,90,110,130,150,170,190,210,250]};
sparams.diags.hxr.hxrspec.phf_hxr = {ones(38,1)*[0.75,0.62,0.51,0.41,0.32,0.20,0.20,0.20,0.20,0.20,0.20,0.20]};
sparams.diags.hxr.hxrspec.res_hxr = {ones(38,1)*[6,-0.9]};
sparams.diags.hxr.hxrspec.ef_hxr = {ones(1,38)};
sparams.diags.hxr.hxrspec.tf_hxr = {repmat('Al',[38,1])};
sparams.diags.hxr.hxrspec.ea_hxr = {0.4*ones(1,38)};
sparams.diags.hxr.hxrspec.ta_hxr = {repmat('Fe',[38,1])};
sparams.diags.hxr.hxrspec.ec_hxr = {0.3*ones(1,38)};
sparams.diags.hxr.hxrspec.tc_hxr = {repmat('Al',[38,1])};
sparams.diags.hxr.hxrspec.ed_hxr = {2*ones(1,38)};
sparams.diags.hxr.hxrspec.td_hxr = {repmat('CdTe',[38,1])};
sparams.diags.hxr.hxrspec.kdiag_hxr = {[[20:20:160],50;[40:20:180],110]};%keV
sparams.diags.hxr.hxrspec.kphot = {[20:10:240]};%keV
sparams.diags.hxr.hxrspec.kmin = {50};%keV
sparams.diags.hxr.hxrspec.kmax = {110};%keV
sparams.diags.hxr.hxrspec.chordstatus_hxr = {ones(1,38)};
%
sparams.diags.hxr.hxrparam.id = {'DEFAULT'};
sparams.diags.hxr.hxrparam.comment = {''};
sparams.diags.hxr.hxrparam.source = {'value'};%source of the data (file, value)
sparams.diags.hxr.hxrparam.file = {''};%filename. Used if source is 'file'
sparams.diags.hxr.hxrparam.path = {''};%absolute path to the file. Used if source is 'file'
sparams.diags.hxr.hxrparam.mfactor = {1};%For the magnetic equilibrium
sparams.diags.hxr.hxrparam.method = {'spline'};%For the magnetic equilibrium in the HXR calculations
sparams.diags.hxr.hxrparam.ns = {3000};%for chord integration
sparams.diags.hxr.hxrparam.n_gauleg = {35};%Number of Legendre polynomials for projections of cross-section and electron velocity distribution
sparams.diags.hxr.hxrparam.epsi_gauleg = {1e-14};%Accuracy of the Legendre projection
%
[err,status] = sluke_params_consistency(sparams);
%