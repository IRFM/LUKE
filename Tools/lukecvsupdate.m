function lukecvsupdate(dkepath)
%
% This function updates LUKE and associated toolboxes remotely for the profiles stored
% in dkepath
%
%	Input:
%
%       - dkepath: path structure with remote profiles
%           (default: if no input structure or empty, dkepath is automatically loaded from LUKE_PATH.mat
%
if nargin < 1,
    dkepath = load_structures_yp('dkepath','','');
end
%
remotefunctions = {'select_LUKE_jd.m','load_remoteprofiles_jd.m','luke_root'};% update MatTools, MatRemote, and LUKE
%
display_mode = 3;% show detailed results
%
exclude = {'.mat','~','.mexa64','.o'};
%
remotecvsupdate(dkepath.remote,remotefunctions,display_mode,exclude)
%