% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
    function [stat,h1] = doc_LUKE(dkepath)
%	LUKE - Access the on-line LUKE help
%
%	Access the on-line LUKE help. Enables to build it if necessary
%
%   dkepath: dkepath structure 
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
