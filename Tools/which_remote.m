function which_remote(dkepath)
%LUKE - Test quickly List of compatible remote profiles available
%
% List of compatible remote profiles available
%
%   INPUTS:
%
%       - dkepath: dkepath structure 
%
%   OUTPUTS: none
%
% by Y.Peysson <CEA/DSM/IRFM, yves.peysson@cea.fr> and J. Decker <CEA/DSM/IRFM, joan.decker@cea.fr>
%
if nargin == 0,
    [dkepath] = load_structures_yp('dkepath','','');
elseif nargin == 1,
    [dkepath] = update_remote_jd(dkepath);
else
    error('The number of input arguments in which_remote.m is too large');
end