function display_lhdata(data,display_mode,save_mode,display_path)
%
%LUKE -  Function which display multiple LH signals from Tore Supra (or WEST) database for ALOHA power spectra calculations (output for upper and lower modules)
% 
%   Input:
%
%		data : LH data structure from Tore Supra or WEST
%       display_mode : 
%       display_path :
%
%   Output: none
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
if nargin < 2
    %
    visible_mode = 'On';
    save_mode = 1;
    display_path = '';%local save
    %
else
    %
    if display_mode == 1
        %
        visible_mode = 'On';
        %
    elseif display_mode == -1
        %
        visible_mode = 'Off';   
        %
    else
        %
        return;
        %
    end
    %
    if nargin == 2
        %
        save_mode = 0;
        display_path = '';%local save
        %
    elseif nargin == 3
        %
        display_path = '';%local save
        %
    end
    %
end
%
%
%xpos = [1 200 1900 1000];%window position for large output
xpos = '';%window position for large output
%
for ii = 1:length(data)
    %
    for jj = 1:length(data(ii).type_signal)
        %
        h1 = figure('Visible',visible_mode);
        %
        h1.Name = [data(ii).machine,', #',int2str(data(ii).shot),', antenna : ',data(ii).antenna,'(port : ',data(ii).port,'), ',data(ii).type_signal{jj}];
        if ~isempty(xpos)
            h1.Position = xpos;
        end
        %
        sgtitle(sprintf([h1.Name,'\nURx: upper row index, LRx: lower row index, Mx: module numbering, Ax: ALOHA numbering']),'Color','Red');
        %
        for j = 1:4
            %
            i = 2*j-1;
            subplot(4,2,i),plot(data(ii).signal(jj).time,data(ii).signal(jj).modules(:,data(ii).mask.upper(i)),'b',data(ii).signal(jj).time,data(ii).signal(jj).modules(:,data(ii).mask.lower(i)),'g')
            legend(['UR',int2str(i),',M',int2str(data(ii).mask.modules(data(ii).mask.upper(i))),',A',int2str(data(ii).mask.aloha(data(ii).mask.upper(i)))],['LR',int2str(i),',M',int2str(data(ii).mask.modules(data(ii).mask.lower(i))),',A',int2str(data(ii).mask.aloha(data(ii).mask.lower(i)))]);
            xlabel('Time (s)'),ylabel(data(ii).type_signal{jj})
            if strcmp(data(ii).type_signal{jj},'gpinjc1') || strcmp(data(ii).type_signal{jj},'gpinjc2')
                ylim([0,300]);
            elseif strcmp(data(ii).type_signal{jj},'gcrefc1') || strcmp(data(ii).type_signal{jj},'gcrefc2')
                ylim([0,30]);
            elseif strcmp(data(ii).type_signal{jj},'gphic1') || strcmp(data(ii).type_signal{jj},'gphrc1') || strcmp(data(ii).type_signal{jj},'gphic2') || strcmp(data(ii).type_signal{jj},'gphrc2')
                ylim([-200,200]);
            end
            grid minor
            %
            i = 2*j;
            subplot(4,2,i),plot(data(ii).signal(jj).time,data(ii).signal(jj).modules(:,data(ii).mask.upper(i)),'b',data(ii).signal(jj).time,data(ii).signal(jj).modules(:,data(ii).mask.lower(i)),'g')
            legend(['UR',int2str(i),',M',int2str(data(ii).mask.modules(data(ii).mask.upper(i))),',A',int2str(data(ii).mask.aloha(data(ii).mask.upper(i)))],['LR',int2str(i),',M',int2str(data(ii).mask.modules(data(ii).mask.lower(i))),',A',int2str(data(ii).mask.aloha(data(ii).mask.lower(i)))]),xlabel('Time (s')
            xlabel('Time (s)'),ylabel(data(ii).type_signal{jj})
            if strcmp(data(ii).type_signal{jj},'gpinjc1') || strcmp(data(ii).type_signal{jj},'gpinjc2')
                ylim([0,300]);
            elseif strcmp(data(ii).type_signal{jj},'gcrefc1') || strcmp(data(ii).type_signal{jj},'gcrefc2')
                ylim([0,30]);
            elseif strcmp(data(ii).type_signal{jj},'gphic1') || strcmp(data(ii).type_signal{jj},'gphrc1') || strcmp(data(ii).type_signal{jj},'gphic2') || strcmp(data(ii).type_signal{jj},'gphrc2')
                ylim([-200,200]);
            end
            grid minor
            %
        end
        %
        if strcmp(visible_mode,'On')
            drawnow
        end
        %
        if save_mode == 1
            %
            if ~exist([display_path,'Data/Figures/'])
                mkdir([display_path,'Data/Figures/'])
            end
            %
            filename = [data(ii).machine,'_',int2str(data(ii).shot),'_',data(ii).antenna,'_',data(ii).port,'_',data(ii).type_signal{jj}];
            %
            print(h1,'-depsc2','-loose','-r600',[display_path,'Data/Figures/fig_',filename,'.eps']);
            print(h1,'-dpng','-r72',[display_path,'Data/Figures/fig_',filename,'.png']);
        end
        %
    end
    %
    h2 = figure('Visible',visible_mode);
    %
    h2.Name = [data(ii).machine,', #',int2str(data(ii).shot),', antenna : ',data(ii).antenna,'(port : ',data(ii).port,'), density probes'];
    if ~isempty(xpos)
        h2.Position = xpos;
    end
    %
    sgtitle(sprintf([h2.Name,'\nDensity probes in front of the LH antennas (view from inside)']),'Color','Red');
    %
    if isfield(data(ii),'probe') && length(data(ii).probe) >= 1 && isfield(data(ii).probe(1),'time')
        plot(data(ii).probe(1).time,smooth(data(ii).probe(1).ne/1e17,5),'r','LineWidth',2),hold on
        legend(['Top left']);
    end
    %
    if isfield(data(ii),'probe') && length(data(ii).probe) >= 2 && isfield(data(ii).probe(2),'time')
        plot(data(ii).probe(2).time,smooth(data(ii).probe(2).ne/1e17,5),'k','LineWidth',2),hold on
        legend(['Top left'],['Top right']);
    end
    %
    if isfield(data(ii),'probe') && length(data(ii).probe) >= 3 && isfield(data(ii).probe(3),'time')
        plot(data(ii).probe(3).time,smooth(data(ii).probe(3).ne/1e17,5),'b','LineWidth',2),hold on
        legend(['Top left'],['Top right'],['Botton left']);
    end
    %
    if isfield(data(ii),'probe') && length(data(ii).probe) >= 4 && isfield(data(ii).probe(4),'time')
        plot(data(ii).probe(4).time,smooth(data(ii).probe(4).ne/1e17,5),'g','LineWidth',2),hold on
        legend(['Top left'],['Top right'],['Botton left'],['Botton right']);
    end
    %
    xlabel('Time (s)'),ylabel('n_e (10^{+17} m^{-3})')
    ylim([0,10]);
    grid minor
    %
    if strcmp(visible_mode,'On')
        drawnow
    end
    %
    if isfield(data(ii),'probe') 
        %
        if isfield(data(ii).probe(1),'time') || isfield(data(ii).probe(2),'time') || isfield(data(ii).probe(3),'time') || isfield(data(ii).probe(4),'time')
            %
            if save_mode == 1
                %
                if ~exist([display_path,'Data/Figures/'])
                    mkdir([display_path,'Data/Figures/'])
                end
                %
                filename = [data(ii).machine,'_',int2str(data(ii).shot),'_',data(ii).antenna,'_',data(ii).port,'_density_probes'];
                %
                print(h2,'-depsc2','-loose','-r600',[display_path,'Data/Figures/fig_',filename,'.eps']);
                print(h2,'-dpng','-r72',[display_path,'Data/Figures/fig_',filename,'.png']);
            end
            %
        end
    else
        close(h2)
    end
    %
end

