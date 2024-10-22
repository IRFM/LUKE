function sluke_make_simulation_folder(foldername,overwrite)
%
% LUKE - Generate a SLUKE simulation folder with all available subfolders.
% 
% INPUT :
%
%   - foldername : name of the sluke simulation folder [string]
%   - overwrite : (1) : overwrite a folder with an existing name, (0) : no overwrite
%       (default : 0)
%
% OUTPUT : none (output is a folder with its subfolders)
%
% by Y.Savoye-Peysson (CEA/DSM/IRFM) <yves.savoye-peysson@cea.fr>
%
if nargin == 1
    %
    overwrite = 0;
    %
elseif nargin == 0
    %
    error('Wrong number of input arguments in ''sluke_make_simulation_folder'' function');
    %
end
%
if ischar(foldername)
    %
    dirinit = pwd;
    %
    if (exist(foldername) && overwrite) || ~exist(foldername)
        %
        mkdir(foldername);
        cd(foldername);
        [success_out,messages] = sluke_create_folders;
        cd(dirinit);
        %
    else
        %
        disp(['WARNING : the folder named : ''',foldername,''' exists and cannot be overwritten. Choose the correct option or erase the folder first.']);
        return;
        %
    end
    %
else
    %
    error('ERROR : the input name of the folder is not a string')
    %
end