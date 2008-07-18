function [nfile] = fig2figs(fileformat,workdir,option,value)
%LUKE - batch convert *.fig files into eps, pdf, jpg, emf and png format
%
% Batch convert *.fig files into eps, pdf, jpg, emf and png format.
% Use advexpfig.m private function (see MatLab central)
%
% Input:
%
%   - fileformat: 'eps', 'pdf', 'jpg', 'emf' and 'png'. If '*', all are used. It can be also 'epspdf' or anycombination of the keys words like eps, pdf, ... [string]
%   - dirnit: working directory [string]
%   - option: figure option (see matlab documentation)
%   - value: figure option value (see matlab documentation)
%
% Output: 
%
%   - nfile: number of figure files processed [1,1]
%
% by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE
% (jodecker@mit.edu)
%
%warning off
%
if nargin == 0,
    fileformat = '*';
    workdir = pwd;
end
if nargin == 1,
	workdir = pwd;
end
if nargin == 3,
    error('Wrong number of input arguments in fig2figs.m');
end
%
close all
%
filelist = dir('*.fig');
%
if strcmp(fileformat,'*'),fileformat = 'eps pdf jpg emf png';end
%
for ifile = 1:length(filelist),
    %
    open(filelist(ifile).name)
    %
    if strfind(fileformat,'eps'),
        if exist('option') == 1 & exist('value') == ifile,
            advexpfig(ifile,strtok(fullfile(workdir,filelist(ifile).name),'.'),'-depsc',option,value);
        else
            advexpfig(ifile,strtok(fullfile(workdir,filelist(ifile).name),'.'),'-depsc');
        end
    end
    %
    if strfind(fileformat,'pdf'),
        if exist('option') == 1 & exist('value') == 1,
            advexpfig(ifile,strtok(fullfile(workdir,filelist(ifile).name),'.'),'-dpdf ',option,value);   
        else
            advexpfig(ifile,strtok(fullfile(workdir,filelist(ifile).name),'.'),'-dpdf ');   
        end
    end
    %
    if strfind(fileformat,'jpg'),
        if exist('option') == 1 & exist('value') == 1,
            advexpfig(ifile,strtok(fullfile(workdir,filelist(ifile).name),'.'),'-djpeg ',option,value);   
        else
            advexpfig(ifile,strtok(fullfile(workdir,filelist(ifile).name),'.'),'-djpeg ');   
        end
    end
    %
    if strfind(fileformat,'emf'),
        if exist('option') == 1 & exist('value') == 1,
            if ~strfind(computer,'WIN'),
                advexpfig(ifile,strtok(fullfile(workdir,filelist(ifile).name),'.'),'-demf',option,value);
            end
        else
            if ~strfind(computer,'WIN'),
                advexpfig(ifile,strtok(fullfile(workdir,filelist(ifile).name),'.'),'-demf');
            end
        end
    end
    %
    if strfind(fileformat,'png'),
        if exist('option') == 1 & exist('value') == 1,
            advexpfig(ifile,strtok(fullfile(workdir,filelist(ifile).name),'.'),'-dpng',option,value);   
        else
            advexpfig(ifile,strtok(fullfile(workdir,filelist(ifile).name),'.'),'-dpng');   
        end
    end
end     
%
nfile = length(filelist);
%
close all
%

