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
function [] = tsclean(shotnumbers)
%
%LUKE -  Function which clean all signals of the specified shot numbers from Tore Supra database (work for WEST shot date only) that are saved locally
%
%   Input:
%
%		shotnumbers: array of shot numbers (ex: 45525 or [27503,27549,32299]) [1,m]
%
%   Output: none
%
%NOTE : data are save in a file place in a folder whose path is defined by the environment variable 'EXPERIMENTAL_TOKAMAK_DATA'. This variable must
%be defined in the startup file startup.m -> setenv('EXPERIMENTAL_TOKAMAK_DATA','**************')
%
% by Y.Savoye-Peysson (CEA/DSM/IRFM) <yves.savoye-peysson@cea.fr>
%
if nargin < 1
    %
    error('Not enough input argument in remote_tsclean.m');
    %
end
%
datapath = getenv('EXPERIMENTAL_TOKAMAK_DATA');%folder path
%
if isempty(datapath)
    %
    warning('The environment variable EXPERIMENTAL_TOKAMAK_DATA is not set in the startup.m file. Data cannot be cleared locally')
    return
    %
end
%
if nargin == 0
    %
    error('ERROR : not enough input arguments in function tsclean');
    %
elseif nargin == 1
    %
    list_dir = dir(datapath);
    %
    for ii = 1:length(shotnumbers)
        %
        shotnumber = real(shotnumbers(ii));
        %
        kk = 1;
        %
        for jj = 1:length(list_dir)
            %
            if list_dir(jj).isdir == 0 && ~isempty(strfind(list_dir(jj).name,int2str(shotnumber)))
                %
                delete([datapath,list_dir(jj).name]);
                %
                kk = kk + 1;
                %
            end
            %
        end
        %
        disp(['---> ',int2str(kk-1),' files for the discharge ''',int2str(shotnumber),''' have been deleted.'])
        %
    end
    %
end