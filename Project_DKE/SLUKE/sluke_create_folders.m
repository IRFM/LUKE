function [success_out,messages] = sluke_create_folders
%
%LUKE - Create folders locally for sluke simulations
%
%   Input: none
%
%   Output: 
%
%       success_out : success if (1) or failure is (0). In the latter, have
%       a look to messages
%       messages : structure of folder creation messages
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
if ~exist('SLUKE_RESULTS')
	[success(1),messages.results] = mkdir('SLUKE_RESULTS');
else
    success(1) = 1;
    messages.results = '';
end
%
if ~exist('SLUKE_LOGS')
	[success(1),messages.results] = mkdir('SLUKE_LOGS');
else
    success(1) = 1;
    messages.results = '';
end
%
if ~exist('SLUKE_KINETICS')
	[success(2),messages.results] = mkdir('SLUKE_KINETICS');
else
    success(2) = 1;
    messages.results = '';
end
%
if ~exist('SLUKE_EQUILS')
	[success(3),messages.equils] = mkdir('SLUKE_EQUILS');
else
    success(3) = 1;
    messages.equils = '';
end
%
if ~exist('SLUKE_OHMS')
    [success(4),messages.ohms] = mkdir('SLUKE_OHMS');
else
    success(4) = 1;
    messages.ohms = '';
end
%
if ~exist('SLUKE_RFWAVES')
     [success(5),messages.waves] = mkdir('SLUKE_RFWAVES');
else
    success(5) = 1;
    messages.waves = '';
end
%
if ~exist('SLUKE_TRANSPS')
     [success(6),messages.transps] = mkdir('SLUKE_TRANSPS');
else
    success(6) = 1;
    messages.transps = '';
end
%
if ~exist('SLUKE_RIPPLES')
     [success(7),messages.ripple] = mkdir('SLUKE_RIPPLES');
else
    success(7) = 1;
    messages.ripple = '';
end
%
if ~exist('SLUKE_FIGURES')
	[success(8),messages.results] = mkdir('SLUKE_FIGURES');
else
    success(8) = 1;
    messages.results = '';
end
%
if ~exist('SLUKE_DIAGNOSTICS')
	[success(9),messages.results] = mkdir('SLUKE_DIAGNOSTICS');
else
    success(9) = 1;
    messages.results = '';
end
%
if sum(success) == length(success)
    %
    success_out = 1;
    %
else
    %
    success_out = 0;
    %
end
