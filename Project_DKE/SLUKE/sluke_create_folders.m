function [success_out,messages] = sluke_create_folders
%
%LUKE - Create folders locally for sluke simulations
%
%   Input: none
%
%   Output: 
%
%       success_out : success if (1) or failure is (0). In the latter, have a look to messages
%       messages : structure of folder creation messages
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
ii = 1;
%
if ~exist('SLUKE_RESULTS','dir')
	[success(ii),messages.results] = mkdir('SLUKE_RESULTS');
else
    success(ii) = 1;
    messages.results = '';
end
%
ii = ii + 1;
%
if ~exist('SLUKE_KINETICS','dir')
	[success(ii),messages.results] = mkdir('SLUKE_KINETICS');
else
    success(ii) = 1;
    messages.results = '';
end
%
ii = ii + 1;
%
if ~exist('SLUKE_EQUILS','dir')
	[success(ii),messages.equils] = mkdir('SLUKE_EQUILS');
else
    success(ii) = 1;
    messages.equils = '';
end
%
ii = ii + 1;
%
if ~exist('SLUKE_OHMS','dir')
    [success(ii),messages.ohms] = mkdir('SLUKE_OHMS');
else
    success(ii) = 1;
    messages.ohms = '';
end
%
ii = ii + 1;
%
if ~exist('SLUKE_RFWAVES','dir')
     [success(ii),messages.waves] = mkdir('SLUKE_RFWAVES');
else
    success(ii) = 1;
    messages.waves = '';
end
%
ii = ii + 1;
%
if ~exist('SLUKE_TRANSPS','dir')
     [success(ii),messages.transps] = mkdir('SLUKE_TRANSPS');
else
    success(ii) = 1;
    messages.transps = '';
end
%
if ~exist('SLUKE_RIPPLES','dir')
     [success(ii),messages.ripple] = mkdir('SLUKE_RIPPLES');
else
    success(ii) = 1;
    messages.ripple = '';
end
%
ii = ii + 1;
%
if ~exist('SLUKE_FIGURES','dir')
	[success(ii),messages.figures] = mkdir('SLUKE_FIGURES');
else
    success(ii) = 1;
    messages.figures = '';
end
%
ii = ii + 1;
%
if ~exist('SLUKE_DIAGNOSTICS','dir')
	[success(ii),messages.diagnostics] = mkdir('SLUKE_DIAGNOSTICS');
else
    success(ii) = 1;
    messages.diagnostics = '';
end
%
if ~exist('SLUKE_LOGS','dir')
	[success(ii),messages.logs] = mkdir('SLUKE_LOGS');
else
    success(ii) = 1;
    messages.logs = '';
end
%
ii = ii + 1;
%
if ~exist('SLUKE_TEMP','dir')
	[success(ii),messages.results] = mkdir('SLUKE_TEMP');
else
    success(ii) = 1;
    messages.results = '';
end
%
ii = ii + 1;
%
if ~exist('SLUKE_STAMPS','dir')
	[success(ii),messages.results] = mkdir('SLUKE_STAMPS');
else
    success(ii) = 1;
    messages.results = '';
end
%
ii = ii + 1;
%
if ~exist('SLUKE_FLUCTS','dir')
	[success(ii),messages.results] = mkdir('SLUKE_FLUCTS');
else
    success(ii) = 1;
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
