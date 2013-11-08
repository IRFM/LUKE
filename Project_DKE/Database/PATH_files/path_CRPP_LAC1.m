function [lac1] = path_CRPP_LAC1(luke_ref)
%
% path definitions for CRPP (EPFL, Suisse) lac computer
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
lac1 = path_CRPP_LAC5(luke_ref);% LAC1 and LAC5 have equivalent settings
%
lac1.hostname = 'lac.epfl.ch';
lac1.machine = 'lac1';
%