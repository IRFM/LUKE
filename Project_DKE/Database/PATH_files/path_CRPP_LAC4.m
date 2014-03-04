function [dkepath] = path_CRPP_LAC4
%
% path definitions for CRPP (EPFL, Suisse) lac4 computer
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath = path_CRPP_LAC2;% LAC2 and LAC4 have equivalent settings
%
dkepath.hostname = 'crpppc296.epfl.ch';
dkepath.machine = 'lac4';
%