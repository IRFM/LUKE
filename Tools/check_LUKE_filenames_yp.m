function not_compatible_filename_list = check_LUKE_filenames_yp(dirName)
%LUKE - check the compatibility of LUKE file names for buiding the documentation
%
% Check the compatibility of LUKE file names for buiding the documentation
%
% INPUTS: 
%
%   - dirName: directory path [string]
%
% OUTPUTS:
%
%   - not_compatible_filename_list: A list of non compatible file names and their corresponding path
%
% by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
if nargin == 0,
	dirName = pwd; 
end
%
filelist = get_all_filesname_yp(dirName);
not_compatible_filename_list = {};
%
j = 1;
%
if ~isempty(filelist),
    for i = 1:length(filelist),
        %
        fs = strfind(filelist{i},filesep);
        filename = filelist{i}(fs(end)+1:end);
        dirname = filelist{i}(1:fs(end));
        %
        fd = strfind(filename,'.');
        %
        if ~isempty(fd),
            fext = ['.',filename(fd(end)+1:end)];
            filename = filename(1:fd(end)-1);
        else
            fext = '';
        end
        %
        if strcmp(fext,'.m') || strcmp(fext,'.c') || strcmp(fext,'.f') || strcmp(fext,'.f90') || strcmp(fext,'.h') || strcmp(fext,'.cpp'),
            if strfind(filename,'-'),
                not_compatible_filename_list{j} = ['The name of the file ''',filename,fext,''' in the directory ''',dirname,''' is not compatible to build the documentation (No ''-'' is allowed).'];
                j = j+1;
            end
        end

    end
end





