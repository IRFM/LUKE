% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function varargout = F_help_mute(key)
%   F_help_mute()
%   help = F_help_mute(key)
%
%plot help for mute substruct or find help for specific field of mute 
%defined in key

tp.load_structures_yp   = "(0) enable or (1) disable display of the function load_structure_yp if any";
tp.run_lukert           = "(0) enable or (1) disable display of the function run_lukert if any";
tp.clustermode_luke     = "(0) enable or (1) disable display of the function clustermode_luke if any";
tp.mdce_clustermode     = "(0) enable or (1) disable display of the function mdce_clustermode if any";
tp.displayrunningjob    = "(0) enable or (1) disable display of the function displayrunningjob if any";
tp.remote_tsdate        = "(0) enable or (1) disable display of the function remote_tsdate if any";
tp.bremsstrahlung_dke_yp= "(0) enable or (1) disable display of the function bremsstrahlung_dke_yp if any";
tp.bremdiag_dke_yp      = "(0) enable or (1) disable display of the function bremdiag_dke_yp if any";
tp.metis2luke           = "(0) enable or (1) disable display of the function metis2luke if any";
tp.equilconsistency_yp  = "(0) enable or (1) disable display of the function equilconsistency_yp if any";
tp.make_equil_metis2luke= "(0) enable or (1) disable display of the function make_equil_metis2luke if any";
tp.make_sluke_build_launchs = "(0) enable or (1) disable display of the function make_sluke_build_launchs if any";
tp.lukeschedulerparam   = "(0) enable or (1) disable display of the function lukeschedulerparam if any";
    
if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end