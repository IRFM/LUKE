function print_jd(opt,savename,fignum)
%
% prints (opt = 0) and (opt = 1) / or (opt = 2, default) saves to file the current figure under the name savename
%
% by J. Decker (jodecker@alum.mit.edu) 09/28/04
%
if nargin < 3
    fignum = NaN;
end
if nargin < 2
    savename = NaN;
end
if nargin < 1
    opt = 1;
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
%
if opt <= 1,
    print
end
%
if opt >= 1,
    if exist('figures','dir') ~= 7
        mkdir('figures')
    end
    cd figures
    eval(['print -depsc -loose ',savename,'.eps']); 
    saveas(gcf,savename,'fig')
    cd ..
end

