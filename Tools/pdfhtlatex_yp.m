function pdfhtlatex_yp(filelist,dkepath)
%LUKE - LATEX to PDF and HTML documentation builder
%
% Create dynamically all the documentation for C3PO/LUKE in html format from Latex files
% (needs standard TeX package with TeX4ht. TeXLive 2007 or above package is strongly recommanded)
%
% by Y. PEYSSON (CEA/DSM/IRFM, yves.peysson@cea.fr) and J. DECKER (CEA/DSM/IRFM, joan.decker@cea.fr)
%
flag = 0;
%
if ~strcmp(computer,'PCWIN'),
    [status_ht, result_ht] = unix('which htlatex');
    [status_pdf, result_pdf] = unix('which pdflatex');
else
    [status_ht, result_ht] = unix('which htlatex');
    [status_pdf, result_pdf] = dos('which pdflatex');
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
if nargin == 0,
    info_dke_yp(1,'A list of Tex files must be given as input.');    
    return
end
if nargin == 1,
    dkepath = path_LUKE_LOCAL;
end
%
luke_root = dkepath.luke_root;
docpath = luke_root;
latexdochtmlpath = [luke_root,'Documentation/LateX'];
%
if ~exist(latexdochtmlpath),
    mkdir(docpath,['Documentation',filesep,'LateX']);
else
    rmdir(latexdochtmlpath,'s');
    mkdir(docpath,['Documentation',filesep,'LateX']);
end
%
dirinit = pwd;%initial directory
%
for i = 1:length(filelist)*0+1,
    try
        [pathstr, name, ext, versn] = fileparts(filelist{i});
        texfile = [name,ext];        
        source_dir = [luke_root,pathstr];
        destination_dir = [latexdochtmlpath,filesep,pathstr];
        %
        if ~exist(destination_dir),
            mkdir(destination_dir);
        else
            rmdir(destination_dir,'s');
            mkdir(destination_dir);
        end
        [status,message,messageid] = copyfile(source_dir,destination_dir,'f');
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
        cd(luke_root);%back to the LUKE root directory
    catch
        cd(luke_root);
        rmdir(destination_dir,'s');
        info_dke_yp(1,['An error occured during LateX translation of the file ',texfile]);
    end
end
%
cd(dirinit);%back to the initial directory
%
