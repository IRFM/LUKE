function [dkepath] = path_CRPP_LAC1

% path definitions for CRPP (EPFL, Suisse) lac1 computer
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath = path_CRPP_LAC5;% LAC1 and LAC5 have equivalent settings
%
dkepath.hostname = 'crpppc172.epfl.ch';
dkepath.machine = 'lac1';
%