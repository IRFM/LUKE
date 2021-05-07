function display_lhdata(data,signal_lim)
%
%LUKE -  Function which display multiple LH signals from Tore Supra (or WEST) database for ALOHA power spectra calculations (output for upper and lower modules)
% 
%   Input:
%
%		data : LH data structure from Tore Supra or WEST
%		signal_lim : Vertical axis limits to plot curves with the same scale (optional) [1,2]
%
%   Output: none
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
if nargin < 2
    signal_lim = [];
end
%
for ii = 1:length(data)
    %
    for jj = 1:length(data(ii).type_signal)
        %
        h1 = figure;
        %
        h1.Name = [data(ii).machine,', #',int2str(data(ii).shot),', antenna : ',data(ii).antennas,'(port : ',data(ii).port,'), ',data(ii).type_signal{jj}];
        sgtitle(sprintf([h1.Name,'\nURx: upper row index, LRx: lower row index, Mx: module numbering, Ax: ALOHA numbering']),'Color','Red');
        %
        for j = 1:4
            %
            i = 2*j-1;
            subplot(4,2,i),plot(data(ii).signal(jj).time,data(ii).signal(jj).modules(:,data(ii).mask.upper(i)),'b',data(ii).signal(jj).time,data(ii).signal(jj).modules(:,data(ii).mask.lower(i)),'g')
            legend(['UR',int2str(i),',M',int2str(data(ii).mask.modules(data(ii).mask.upper(i))),',A',int2str(data(ii).mask.aloha(data(ii).mask.upper(i)))],['LR',int2str(i),',M',int2str(data(ii).mask.modules(data(ii).mask.lower(i))),',A',int2str(data(ii).mask.aloha(data(ii).mask.lower(i)))]);
            xlabel('Time (s'),ylabel(data(ii).type_signal{jj})
            if ~isempty(signal_lim)
                ylim(signal_lim);
            end
            %
            i = 2*j;
            subplot(4,2,i),plot(data(ii).signal(jj).time,data(ii).signal(jj).modules(:,data(ii).mask.upper(i)),'b',data(ii).signal(jj).time,data(ii).signal(jj).modules(:,data(ii).mask.lower(i)),'g')
            legend(['UR',int2str(i),',M',int2str(data(ii).mask.modules(data(ii).mask.upper(i))),',A',int2str(data(ii).mask.aloha(data(ii).mask.upper(i)))],['LR',int2str(i),',M',int2str(data(ii).mask.modules(data(ii).mask.lower(i))),',A',int2str(data(ii).mask.aloha(data(ii).mask.lower(i)))]),xlabel('Time (s')
            xlabel('Time (s'),ylabel(data(ii).type_signal{jj})
            if ~isempty(signal_lim)
                ylim(signal_lim);
            end
            %
        end
        %
        drawnow
        %
        if ~exist('ALOHA/Figures/')
            mkdir('ALOHA/Figures/')
        end
        %
        filename = [data(ii).machine,'_',int2str(data(ii).shot),'_',data(ii).antennas,'_',data(ii).port,'_',data(ii).type_signal{jj}];
        %
        print(h1,'-depsc2','-loose','-r600',['ALOHA/Figures/fig_',filename,'.eps']);
        print(h1,'-dpng','-r72',['ALOHA/Figures/fig_',filename,'.png']);
        %
    end
end

