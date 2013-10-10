function which_remote
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
[dkepath_list] = load_dkepath_yp('','');
dkepath_list_fieldnames = fieldnames(dkepath_list);
%
for idkepath_list_fieldnames = 2:length(dkepath_list_fieldnames),%computer
     dkepath = dkepath_list.(dkepath_list_fieldnames{idkepath_list_fieldnames});
     dkepath_fieldnames = fieldnames(dkepath);
     %
     jdkepath_fieldnames_ref = 0;
     %
     for jdkepath_fieldnames = 1:length(dkepath_fieldnames),
        if strfind(dkepath_fieldnames{jdkepath_fieldnames},'default'),
            jdkepath_fieldnames_ref = jdkepath_fieldnames;
            break
        end
     end
     %
     disp('----------------------------------------------------------------------'),
     info_dke_yp(1,['COMPUTER: ',dkepath.machine])
     disp('----------------------------------------------------------------------'),
     disp(' '),
     %
     if jdkepath_fieldnames_ref,%user
        for jdkepath_fieldnames = jdkepath_fieldnames_ref+1:length(dkepath_fieldnames),
            disp(['-------> USER: ',dkepath_fieldnames{jdkepath_fieldnames}]);
            if isfield(dkepath.(dkepath_fieldnames{jdkepath_fieldnames}),'remote')
                update_remote_jd(dkepath.(dkepath_fieldnames{jdkepath_fieldnames}));
            else
                disp('-------> No compatible remote profiles available');
                disp(' ');
            end
        end
     end
end
%
disp('**********************************************************************'),
disp('**********************************************************************'),
disp(' ');
info_dke_yp(0,'To check if the remote profiles are currently functionning, please run :')
info_dke_yp(4,'check_remote_yp(load_structures_yp(''dkepath'','''',''''));')
disp (' ');
