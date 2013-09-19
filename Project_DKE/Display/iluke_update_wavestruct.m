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
    lukeobj.spectrum.state = 'off';
    lukeobj.spectrum.visible = 'off';
    lukeobj.angles.state = 'off';
    lukeobj.angles.visible = 'off';
    lukeobj.launch.state = 'off';
    lukeobj.c3poparam.state = 'off';
    lukeobj.runc3po.state = 'off';
    lukeobj.runc3poall.state = 'off';    
    lukeobj.wsparamtitle.state = 'off';
    lukeobj.wsparam.state = 'off';
    %
    lukeobj.spectrum.text.string = '';
    lukeobj.angles.text.string = '';
    lukeobj.launch.text.string = '';
    lukeobj.c3poparam.text.string = '';
else
    lukeobj.wavestruct.save.state = 'on';
    lukeobj.wavestruct.clear.state = 'on';
    %
    lukeobj.launch.state = 'on';
    lukeobj.launch.text.string = [  'ID : ',num2str(wavestructs{iw}.launch.id),...
        ' ; type : ',num2str(wavestructs{iw}.launch.type)];
    %
    lukeobj.c3poparam.state = 'on';
    if isfield(wavestructs{iw},'rtparam'),
        lukeobj.c3poparam.text.string = wavestructs{iw}.rtparam;
    end
    lukeobj.runc3po.state = 'on';
    lukeobj.runc3poall.state = 'on';    
    lukeobj.wsparamtitle.state = 'on';
    lukeobj.wsparam.state = 'on';
    %
    iw = lukeobj.wavestruct.select.value;
    if strcmp(wavestructs{iw}.launch.type,'LH') && isfield(wavestructs{iw}.launch,'aloha'),
        lukeobj.spectrum.state = 'on';
        if strcmp(lukeobj.wavestruct.visible,'on'),
            lukeobj.spectrum.visible = 'on';
        end
    elseif strcmp(wavestructs{iw}.launch.type,'EC') && isfield(wavestructs{iw}.launch,'angles'),
        lukeobj.angles.state = 'on';
        if strcmp(lukeobj.wavestruct.visible,'on'),
            lukeobj.angles.visible = 'on';
        end
        lukeobj.angles.text.string = [  'ID : ',num2str(wavestructs{iw}.launch.angles.id),...
            ' ; P = ',num2str(wavestructs{iw}.launch.angles.P0/1e3,3),' kW',...
            ' ; f = ',num2str(wavestructs{iw}.launch.angles.freq/1e9,3),' GHz'];
        lukeobj.launch.text.string = [lukeobj.launch.text.string,...
            ' ; alpha ',num2str(wavestructs{iw}.launch.yalpha_L*180/pi,3),' °',...
            ' ; beta : ',num2str(wavestructs{iw}.launch.ybeta_L*180/pi,3),' °'];
    end
    %
    if strcmp(lukeobj.wavestruct.visible,'on'),
        lukeobj.wavestruct.select.visible = 'on';
    end
    %
end
%
clear iw nw











