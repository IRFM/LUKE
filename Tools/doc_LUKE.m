    function [stat,h1] = doc_LUKE(dkepath)
%	LUKE - Access the on-line LUKE help
%
%	Access the on-line LUKE help. Enables to build it if necessary
%
%   dkepath: dkepath structure 
%
%
%by Y.PEYSSON CEA/IRFM <yves.peysson@cea.fr> and Joan Decker CEA/IRFM <joan.decker@cea.fr>
%
if nargin == 0,
    %
    dkepath = load_structures_yp('dkepath','','');
    %
end
%
if nargin == 1 && isempty(dkepath),
    %
    dkepath = load_structures_yp('dkepath','','');
    %
end
%
if nargin > 1,error('Too many input arguments in doc_LUKE.m');end
%
if ~exist([dkepath.luke_root,'Help/index.html'])
    %
    disp('The LUKE help has not been created on this computer during the install process.');
    %
    doc_opt = input('Do you want to build it now (WARNING: it may take long minutes) (y/n)? [y] : ','s');
    %
    if strcmp(doc_opt,'y'),
        %
        dirinit = pwd;
        cd(dkepath.luke_root);
        %                       
        eval('install_doc_LUKE');
        %
        cd(dirinit);
    end
else
    web(['file://',dkepath.luke_root,'Help/index.html'], '-new');
end    
