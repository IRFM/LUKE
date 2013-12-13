% script iluke_update_wavestruct
%
if isfield(external,'wave'),
    lukeobj.wavestruct.import.state = 'on';
else
    lukeobj.wavestruct.import.state = 'off';
end
%
nw = length(wavestructs);
lukeobj.wavestruct.select.string = cell(1,nw);
%
for iw = 1:nw,
    %
    lukeobj.wavestruct.select.string{iw} = wavestructs{iw}.id;
    %
end
%
% display and state properties
%
if nw == 0,
    %
    lukeobj.wavestruct.select.visible = 'off';
    lukeobj.wavestruct.save.state = 'off';
    lukeobj.wavestruct.clear.state = 'off';
    lukeobj.spectrum.modify.state = 'off';
    lukeobj.spectrum.save.state = 'off';
    lukeobj.spectrum.reset.state = 'off';
    lukeobj.angles.modify.state = 'off';
    lukeobj.angles.save.state = 'off';
    lukeobj.angles.reset.state = 'off';
    lukeobj.launch.modify.state = 'off';
    lukeobj.launch.save.state = 'off';
    lukeobj.launch.reset.state = 'off';
    lukeobj.c3poparam.modify.state = 'off';
    lukeobj.c3poparam.load.state = 'off';
    lukeobj.c3poparam.save.state = 'off';
    lukeobj.c3poparam.reset.state = 'off';
    lukeobj.runc3po.state = 'off';
    lukeobj.runc3poall.state = 'off';    
    lukeobj.runc3pooptim.state = 'off';    
    lukeobj.wsparamtitle.state = 'off';
    lukeobj.wsparam.state = 'off';
    %
    lukeobj.spectrum.text.string = '';
    lukeobj.angles.text.string = '';
    lukeobj.launch.text.string = '';
    lukeobj.c3poparam.text.string = '';
    %
    if isfield(external,'wave'),
        lukeobj.wavestruct.import.highlight = true;
        lukeobj.wavestruct.make.highlight = false;
    else
        lukeobj.wavestruct.make.highlight = true;
        lukeobj.wavestruct.import.highlight = false;
    end
    lukeobj.runc3po.highlight = false;
    lukeobj.runc3poall.highlight = false;    
    lukeobj.runc3pooptim.highlight = false;    
else
    iw = lukeobj.wavestruct.select.value;
    %
    % wavestruct
    %
    lukeobj.wavestruct.save.state = 'on';
    lukeobj.wavestruct.clear.state = 'on';
    %
    % launch
    %
    lukeobj.launch.modify.state = 'on';
    lukeobj.launch.save.state = 'on';
    lukeobj.launch.reset.state = 'on';
    %
    if isfield(wavestructs{iw}.launch,'orig'),
        lukeobj.launch.reset.state = 'on';
    else
        lukeobj.launch.reset.state = 'off';
    end
    %
    lukeobj.launch.text.string = [  'ID : ',num2str(wavestructs{iw}.launch.id),...
        ' ; type : ',num2str(wavestructs{iw}.launch.type)];
    %
    % c3poparam
    %
    lukeobj.c3poparam.modify.state = 'on';
    lukeobj.c3poparam.load.state = 'on';
    lukeobj.c3poparam.save.state = 'on';
    %
    if isfield(wavestructs{iw},'rtparam'),
        lukeobj.c3poparam.text.string = wavestructs{iw}.rtparam;
    end
    %
    if isfield(wavestructs{iw},'orig'),
        lukeobj.c3poparam.reset.state = 'on';
    else
        lukeobj.c3poparam.reset.state = 'off';
    end
    %
    % c3po run
    %
    lukeobj.runc3po.state = 'on';
    lukeobj.runc3poall.state = 'on';    
    lukeobj.wsparamtitle.state = 'on';
    lukeobj.wsparam.state = 'on';
    %
    if strcmp(wavestructs{iw}.launch.type,'LH'),
        if isfield(wavestructs{iw}.launch,'spectrum'),
            lukeobj.spectrum.modify.state = 'on';
            lukeobj.spectrum.save.state = 'on';
            %
            if isfield(wavestructs{iw}.launch.spectrum,'orig'),
                lukeobj.spectrum.reset.state = 'on';
            else
                lukeobj.spectrum.reset.state = 'off';
            end
            %
%             lukeobj.spectrum.text.string = ['ne0_17 = ',num2str(wavestructs{iw}.launch.spectrum.plasma.ne0/1e17,3),'',...
%                 ' ; l1 = ',num2str(wavestructs{iw}.launch.spectrum.plasma.lambda_n(1)/1e3,3),' mm',...
%                 ' ; l2 = ',num2str(wavestructs{iw}.launch.spectrum.plasma.lambda_n(2)/1e3,3),' mm'];
            lukeobj.spectrum.text.string = ['ID : ',wavestructs{iw}.launch.spectrum.id,... 
                ' ; #lobes = ',num2str(wavestructs{iw}.launch.spectrum.param_tor.nlobes,3),'',...
                ' ; dir = ',num2str(wavestructs{iw}.launch.spectrum.param_tor.dir,3),'',...
                ' ; mode = ',num2str(wavestructs{iw}.launch.spectrum.param_tor.mode,3),''];
            %
        else
            lukeobj.spectrum.modify.state = 'off';
            lukeobj.spectrum.save.state = 'off';
            lukeobj.spectrum.reset.state = 'off';
            lukeobj.spectrum.text.string = '';
        end
        %
        lukeobj.angles.text.string = '';
        lukeobj.runc3pooptim.state = 'off';
        %
        if any(imag(wavestructs{iw}.launch.bNpar0) ~= 0),            
            nparstr = 'Nz0';
            npar0disp = imag(wavestructs{iw}.launch.bNpar0(find(wavestructs{iw}.launch.bPlhtot == max(wavestructs{iw}.launch.bPlhtot),1,'first')));
        else
            nparstr = 'N//0';
            npar0disp = wavestructs{iw}.launch.bNpar0(find(wavestructs{iw}.launch.bPlhtot == max(wavestructs{iw}.launch.bPlhtot),1,'first'));
        end
        lukeobj.launch.text.string = [lukeobj.launch.text.string,...
            ' ; ',nparstr,' : ',num2str(npar0disp,3),'',...
            ' ; P = ',num2str(sum(wavestructs{iw}.launch.bPlhtot)/1e6,3),' MW'];
        %
        clear npar0disp
        %
    elseif strcmp(wavestructs{iw}.launch.type,'EC'),
        if isfield(wavestructs{iw}.launch,'angles'),
            lukeobj.angles.modify.state = 'on';
            lukeobj.angles.save.state = 'on';
            if isfield(wavestructs{iw}.launch.angles,'orig'),
                lukeobj.angles.reset.state = 'on';
            else
                lukeobj.angles.reset.state = 'off';
            end
            %
            lukeobj.angles.text.string = [  'ID : ',num2str(wavestructs{iw}.launch.angles.id),...
                ' ; P = ',num2str(wavestructs{iw}.launch.angles.P0/1e3,3),' kW',...
                ' ; f = ',num2str(wavestructs{iw}.launch.angles.freq/1e9,3),' GHz'];
            %
            lukeobj.runc3pooptim.state = 'on';
            %
        else
            lukeobj.angles.modify.state = 'off';
            lukeobj.angles.save.state = 'off';
            lukeobj.angles.reset.state = 'off';
            lukeobj.angles.text.string = '';
            lukeobj.runc3pooptim.state = 'off';
        end
        %
        lukeobj.spectrum.text.string = '';
        lukeobj.launch.text.string = [lukeobj.launch.text.string,...
            ' ; alpha = ',num2str(wavestructs{iw}.launch.yalpha_L*180/pi,3),' °',...
            ' ; beta = ',num2str(wavestructs{iw}.launch.ybeta_L*180/pi,3),' °'];
        %
    end
    %
    if strcmp(lukeobj.wavestruct.visible,'on'),
        lukeobj.wavestruct.select.visible = 'on';
    end
    %
    lukeobj.wavestruct.import.highlight = false;
    lukeobj.wavestruct.make.highlight = false;
    lukeobj.runc3po.highlight = true;
    lukeobj.runc3poall.highlight = true;    
    lukeobj.runc3pooptim.highlight = true;    
    %
end
%
% upgrade graph status
%
plotindices = [lukeobj.plot1.gindex,lukeobj.plot2.gindex,lukeobj.plot3.gindex];
%
nstr = length('spectrum for ');
%
ngraphs = length(graphs);
for igraph = ngraphs:-1:1,
    if strcmp(graphs(igraph).tag,'spectrum') && ~any(strcmp(graphs(igraph).info(nstr+1:end),lukeobj.wavestruct.select.string)),% the corresponding wavestruct no longer exists
        for ich = 1:length(graphs(igraph).handles),
            delete(graphs(igraph).handles(ich))
        end
        graphs(igraph) = [];
        plotindices(plotindices == igraph) = 0;
        plotindices(plotindices > igraph) = plotindices(plotindices > igraph) - 1;
    end
end
%
lukeobj.plot1.gindex = plotindices(1);
lukeobj.plot2.gindex = plotindices(2);
lukeobj.plot3.gindex = plotindices(3);
%
clear iw nw nstr igraph ngraphs plotindices











