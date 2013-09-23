function pdfhtlatex_yp(root_path,htlatex_path,pdflatex_path,latex_env,imagemagick_env,filelist,verbose)
%LUKE - LaTeX to PDF and HTML documentation builder
%
% Create dynamically all the documentation for C3PO/LUKE in html format from Latex files
% (needs standard TeX package with TeX4ht. TeXLive 2007 or above package is strongly recommanded)
%
% INPUT:
%

%   - root_path: path where the documentation directory should be placed (string)
%       (default: local directory)
%   - htlatex_path: path where the htlatex command is located (string)
%       (default: local directory)
%   - pdflatex_path: path where the pdflatex command is located (string)
%       (default: local directory)
%   - latex_env: latex environment path (string)
%       (default: local directory)
%   - imagemagick_env: imagemagick environment path (string)
%       (default: local directory)
%   - filelist: full path to LaTeX files (celles of string)
%       (default: local directory)
%   - verbose: display Latex compilation echos if not empty
%       (default: empty)
%
% OUTPUT: none
%
% by Y. PEYSSON (CEA/DSM/IRFM, yves.peysson@cea.fr) and J. DECKER (CEA/DSM/IRFM, joan.decker@cea.fr)
%
    flag = 0;
    %
    if nargin == 0,
        root_path = '';
        filelist = {};
    end
    if nargin == 1,
        filelist = {};
    end
    %
    if isempty(htlatex_path),
        info_dke_yp(1,'The package TeX4ht is not available. LaTeX to HTML conversion is not possible.');
    end
    if isempty(pdflatex_path),
        info_dke_yp(1,'The package pdfLatex is not available. LaTeX to PDF conversion is not possible.');
    end
    %
    if isempty(pdflatex_path) && isempty(htlatex_path) && isempty(latex_env) && isempty(imagemagick_env)
        return
    end
    %
    if ~isempty(latex_env)
        getenv('PATH')
        setenv('PATH', [getenv('PATH'),':',latex_env]);
        setenv('PATH', [getenv('PATH'),':',imagemagick_env]);
        getenv('PATH')
    end
    %
    dirinit = pwd;%initial directory name
    %
    if isempty(root_path),
        root_path = [pwd,filesep];%Working in the local directories where pdfhtlatex_yp is launched
    end
    %
    if ~strcmp(root_path(end),filesep),
        root_path = [root_path,filesep];%root_path must be ended by a filesep
    end
    %
    cd(root_path);
    %
    if isempty(filelist),
        filelisttex = dir('*.tex');%scan the local directory to find a LaTeX file
        for ii = 1:length(filelisttex),
            filelist{ii} = fullfile(root_path,filelisttex(ii).name);
        end
        if isempty(filelist),
            info_dke_yp(1,'A list of Tex files must be given as input of pdfhtlatex_yp.m or the local directory must contain one or more LaTeX files !');    
            return
        end
    end
    %
    docpath = root_path;
    if nargin > 1,
        latexdochtmlpath = fullfile(docpath,'Documentation','LaTeX');
    end
    %
    if nargin > 1,
        if ~exist(latexdochtmlpath),
            mkdir(docpath,fullfile('Documentation','LaTeX'));
        else
            rmdir(latexdochtmlpath,'s');
            mkdir(docpath,fullfile('Documentation','LaTeX'));
        end
    else
        latexdochtmlpath = docpath;
    end
    %
    for i = 1:length(filelist),
        try
            [pathstr, name, ext] = fileparts(filelist{i});
            if ~strcmp(pathstr(end),filesep),
                pathstr = [pathstr,filesep];%root_path must be ended by a filesep
            end
            texfile = [name,ext];        
            source_dir = pathstr;
            destination_dir = fullfile(latexdochtmlpath,strrep(pathstr,root_path,''));
            %
            if nargin > 1,
                if ~exist(destination_dir),
                    mkdir(destination_dir);
                else
                    rmdir(destination_dir,'s');
                    mkdir(destination_dir);
                end
            end
            %
            if ~strcmp(pathstr,root_path),
                [status,message,messageid] = copyfile(source_dir,destination_dir,'f');
            else
                status = 1;
            end
            %
            if ~status,
                info_dke_yp(1,['The copy from ',source_dir,' to ',destination_dir, ' failed.']);
                return
            end
            %
            cd(destination_dir);
            %
            % Delete recursively possible CVS directories
            %
            delete_cvsdir_yp(destination_dir);
            %
            if ~isempty(htlatex_path),
                if isempty(verbose)
                    [status_ht, result] = unix([htlatex_path,'htlatex  ',texfile,' ''html,index=2,3,next''']);
                else
                    [status_ht, result] = unix([htlatex_path,'htlatex  ',texfile,' ''html,index=2,3,next'''],'-echo');
                end
            else
                status_ht = 1;
            end
            %
            if ~isempty(pdflatex_path),
                if isempty(verbose)
                    [status_pdf, result] = unix(['pdflatex  ',texfile],'-echo');
                else
                    [status_pdf, result] = unix(['pdflatex  ',texfile]);
                end 
            else
                status_pdf = 1;
            end        
            %
            if status_ht == 0,
                info_dke_yp(1,['Successfull LaTeX to HTML conversion of the file ',texfile]);
            else
                info_dke_yp(1,['Unsuccessfull LaTeX to HTML conversion of the file ',texfile]);
                disp(result);
            end
            %
            if status_pdf == 0,
                info_dke_yp(1,['Successfull LaTeX to PDF conversion of the file ',texfile]);
            else
                info_dke_yp(1,['Unsuccessfull LaTeX to PDF conversion of the file ',texfile]);
                disp(result);
            end
            %
            cd(root_path);%back to the LUKE root directory
        catch
            cd(root_path);
            rmdir(destination_dir,'s');
            info_dke_yp(1,['An error occured during LaTeX translation of the file ',texfile]);
        end
    end
    %
    cd(dirinit);%back to the initial directory
    %
end

function [search_path] = delete_cvsdir_yp(root_path,search_path)
%LUKE - Recursive directory scan
%
% Recursive delete of all CVS directories from root directory
%
% INPUT:
%
%   - root_path: absolute directory path name to be scanned (string)
%   - search_path: list of subdirectories (cell of strings)
%
% OUTPUT:
%
%   - search_path: structure of subdirectories scanned (not equal to input when recursive option is 'on') (structure)
%
% by Y. PEYSSON (CEA/DSM/IRFM, yves.peysson@cea.fr) and J. DECKER (CEA/DSM/IRFM, joan.decker@cea.fr)
%
    if nargin == 0,
        error('The root_path of the folder to be scanned must be given as input delete_cvsdir_yp.m !');
    end
    if nargin == 1,
        search_path = {};
    end
    %
    dirinit = pwd;%record the active directory name
    %
    if ~strcmp(root_path(end),filesep),
        root_path = [root_path,filesep];%root_path must be ended by a filesep
    end
    %
    cd(root_path);%move to the root folder to be scanned
    dirlist = dir;
    nsearch_path0 = length(search_path);
    nsearch_path = nsearch_path0;
    %
    for ii = 1:length(dirlist),
        if dirlist(ii).isdir == 1 & ~strcmp(dirlist(ii).name(1),'.') & ~strcmp(dirlist(ii).name,'CVS'),
            search_path = [search_path,[root_path,dirlist(ii).name]];
            nsearch_path = nsearch_path + 1;%a valid new directory has been found
        end
    end 
    %
    if exist('CVS','dir') == 7,%a CVS directory exists in the rootdir
        rmdir('CVS','s');
    end    
    %
    for ii = nsearch_path0+1:nsearch_path,
        [search_path] = delete_cvsdir_yp(search_path{ii},search_path);%recursive scan
    end
    %
    cd(dirinit);%back to the initial active directory
end

