function print_jd(opt,savename,savedir,fignum,res)
%
% prints (opt = 0) and (opt = 1) / or (opt = 2, default) saves to file the current figure under the name savename
%
% by J. Decker (jodecker@alum.mit.edu) 09/28/04
%
if nargin < 5
    res = 600;
end
if nargin < 4
    fignum = NaN;
end
if nargin < 3
    savedir = NaN;
end
if nargin < 2
    savename = NaN;
end
if nargin < 1
    opt = 1;
end
%
if isnan(savedir),
    savedir = 'figures';
end
if ~isnan(fignum),
    figure(fignum)
else
    fignum = get(0,'currentfigure');
end
if isnan(savename)
    savename = ['fig_',num2str(fignum)];
end
%
% Printing default options
%
set(gcf,'PaperPositionMode','auto');
set(gca, 'XTickMode','manual');
set(gca, 'YTickMode','manual');
set(gca, 'ZTickMode','manual');
%
if opt >= 0 & opt <= 1,
    print
end
%
if opt >= 1,
    if exist(savedir,'dir') ~= 7
        mkdir(savedir)
    end
    wd = pwd;
    cd(savedir)
    eval(['print -depsc -loose -tiff -r',num2str(res),' ',savename,'.eps']); 
    saveas(gcf,savename,'fig')
    if strcmp(computer,'PCWIN'),
        eval(['print -dmeta -r',num2str(res),' ',savename,'.emf']); 
    else
        eval(['print -djpeg90 -r',num2str(res),' ',savename,'.jpg']); 
    end    
    cd(wd)
end

