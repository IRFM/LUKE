%script make_equil_ITER_Scen4
%
% This script creates the equil strucure for CMOD to be used by DKE
%   based on the eqdsk file and some profile data
%
clear all
close all
%
% path
%
id_dkepath = '';%For all paths used by DKE solver
path_dkepath = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
[dkepath] = load_structures_yp('dkepath',id_dkepath,path_dkepath);
%
% file name
%
filename = 'Scen4';
pathname = 'Source_files/';
type = 4;
display_mode = 2;
p_opt = 2;
dispname = 'ITER Scenario 4';
savename = 'ITER_Scen4';
Zeff = 2.23;

equil_EFIT_jd([pathname,filename],type,display_mode,p_opt,dispname,savename,Zeff)