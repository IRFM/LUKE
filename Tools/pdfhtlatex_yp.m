function pdfhtlatex_yp(root_path,filelist)
%LUKE - LATEX to PDF and HTML documentation builder
%
% Create dynamically all the documentation for C3PO/LUKE in html format from Latex files
% (needs standard TeX package with TeX4ht. TeXLive 2007 or above package is strongly recommanded)
%
% INPUT:
%

%   - root_path: path where the documentation directory should be placed (string)
%       (default: local directory)
%   - filelist: full path to LaTeX files (celles of string)
%       (default: local directory)
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
if ~strcmp(computer,'PCWIN'),
    [status_ht,result_ht] = unix('which htlatex');
    [status_pdf,result_pdf] = unix('which pdflatex');
else
    [status_ht,result_ht] = unix('which htlatex');
    [status_pdf,result_pdf] = dos('which pdflatex');
end
%
if isempty(result_ht),
    info_dke_yp(1,'The package TeX4ht is not available. LateX to HTML conversion is not possible. Please set-up the path for MatLab correctly');
end
if isempty(result_pdf),
    info_dke_yp(1,'The package pdfLatex is not available. LateX to PDF conversion is not possible. Please set-up the path for MatLab correctly');
end
%
if isempty(result_ht) & isempty(result_pdf)
    return
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
    latexdochtmlpath = fullfile(docpath,'Documentation','LateX');
end
%
if nargin > 1,
    if ~exist(latexdochtmlpath),
        mkdir(docpath,fullfile('Documentation','LateX'));
    else
        rmdir(latexdochtmlpath,'s');
        mkdir(docpath,fullfile('Documentation','LateX'));
    end
else
    latexdochtmlpath = docpath;
end
%
for i = 1:length(filelist),
    try
%        keyboard
        [pathstr, name, ext, versn] = fileparts(filelist{i});
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
        if ~isempty(result_ht),
            [status_ht, result] = unix(['htlatex  ',texfile,' ''html,index=2,3,next'''],'-echo');
        end
        %
        if ~isempty(result_pdf),
            [status_pdf, result] = unix(['pdflatex  ',texfile],'-echo');
        end        
        %
        if status_ht == 0,
            info_dke_yp(1,['Successfull LateX to HTML conversion of the file ',texfile]);
        else
            info_dke_yp(1,['Unsuccessfull LateX to HTML conversion of the file ',texfile]);
            disp(result);
        end
        %
        if status_pdf == 0,
            info_dke_yp(1,['Successfull LateX to PDF conversion of the file ',texfile]);
        else
            info_dke_yp(1,['Unsuccessfull LateX to PDF conversion of the file ',texfile]);
            disp(result);
        end
        %
        cd(root_path);%back to the LUKE root directory
    catch
        cd(root_path);
        rmdir(destination_dir,'s');
        info_dke_yp(1,['An error occured during LateX translation of the file ',texfile]);
    end
end
%
cd(dirinit);%back to the initial directory
%
