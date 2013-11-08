function [lac4] = path_CRPP_LAC4(luke_ref)
%
% path definitions for CRPP (EPFL, Suisse) lac4 computer
%
%	Input:
%
%       - luke_ref: for CVS tagged LUKE version [1,m]
%         (default: 'LUKE')
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
if nargin == 0, luke_ref = 'LUKE';end
%
lac4 = path_CRPP_LAC2(luke_ref);% LAC2 and LAC4 have equivalent settings
%
lac4.hostname = 'lac4.epfl.ch';
lac4.machine = 'lac4';
%