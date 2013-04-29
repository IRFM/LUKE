function [dkepath] = path_CEA_ANDROMEDE3(luke_ref)
%
% path definitions for the ANDROMEDE cluster 
%
%	Input:
%
%       - luke_ref: for CVS tagged LUKE version [1,1]
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
if nargin == 0, 
    luke_ref = 'LUKE';
end
%
[dkepath] = path_CEA_ANDROMEDE1(luke_ref);% similar to andromede 1
%
dkepath.hostname = 'andromede3';
dkepath.machine = 'andromede3';
%
dkepath.JD211098(1).remote(1).host = 'andromede1.intra.cea.fr';% empty for local host
%
dkepath.YP105119(1).remote(1).host = 'andromede1.intra.cea.fr';% empty for local host
