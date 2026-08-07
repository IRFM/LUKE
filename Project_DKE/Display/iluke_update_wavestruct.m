% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
% script iluke_update_wavestruct
%

%
% clear outdated wavestructs and update list, status
%

wavestructss(status.wavestructs <= 0) = {[]};

iwclearmask = ~any(status.wavestructs == 1,2);
wavestructids(iwclearmask,:) = [];
wavestructss(iwclearmask,:) = [];
status.wavestructs(iwclearmask,:) = [];
%
clear iwclearmask
%
% flag_external &  external_wave
%
if isfield(external,'wave'),% include data from external structure if available
    if curtime == 0,% treat all times from external structure if available
        flag_external = any(intersect(shotimes(status.equil == 1),external.times));
    elseif curtime > 0,% select one time from external structure if available
        flag_external = any(external.times == shotimes(curtime));
    else
        flag_external = false;
    end
else
    flag_external = false;
end 
%
if flag_external,
    lukeobj.wavestruct.import.state = 'on';
else
    lukeobj.wavestruct.import.state = 'off';
end
%
% display and state properties
%
if isempty(wavestructids) || (curtime > 0 && all(status.wavestructs(:,curtime) <= 0)),% no wavestructs
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
    if flag_external,
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
    %
    % build lukeobj.wavestruct.select.string
    %
    if lukeobj.wavestruct.select.value > 0,
        wavestructid = lukeobj.wavestruct.select.string{lukeobj.wavestruct.select.value};
    else
        wavestructid = '';
    end
    %
    if curtime > 0,
        iw_curtime = find(status.wavestructs(:,curtime) == 1);
    else
        iw_curtime = 1:length(wavestructids);
    end
    %
    lukeobj.wavestruct.select.string = wavestructids(iw_curtime);
    lukeobj.wavestruct.select.value = find(strcmp(lukeobj.wavestruct.select.string,wavestructid));
    %
    if isempty(lukeobj.wavestruct.select.value),% pre-selected wavestruct does not exist for curtime, or was cleared for all times
        lukeobj.wavestruct.select.value = length(lukeobj.wavestruct.select.string);
    end
    %
    iw = iw_curtime(lukeobj.wavestruct.select.value);% current index in wavestructss
    %
    % wavestruct
    %
    lukeobj.wavestruct.save.state = 'on';
    lukeobj.wavestruct.clear.state = 'on';
    %
    % c3po run
    %
    lukeobj.runc3po.state = 'on';
    lukeobj.runc3poall.state = 'on';    
    %
    if strcmp(lukeobj.wavestruct.visible,'on'),
        lukeobj.wavestruct.select.visible = 'on';
    end
    %
    lukeobj.wavestruct.import.highlight = false;
    lukeobj.wavestruct.make.highlight = false;
    lukeobj.runc3po.highlight = true;
    lukeobj.runc3poall.highlight = true;    
    %
    if curtime > 0,
        %
        wavestruct = wavestructss{iw,curtime};
        %
        % launch
        %
        lukeobj.launch.modify.state = 'on';
        lukeobj.launch.save.state = 'on';
        %
        if isfield(wavestruct.launch,'orig'),
            lukeobj.launch.reset.state = 'on';
        else
            lukeobj.launch.reset.state = 'off';
        end
        %
        lukeobj.launch.text.string = [  'ID : ',num2str(wavestruct.launch.id),...
            ' ; type : ',num2str(wavestruct.launch.type)];
        %
        % c3poparam
        %
        lukeobj.c3poparam.modify.state = 'on';
        lukeobj.c3poparam.load.state = 'on';
        lukeobj.c3poparam.save.state = 'on';
        %
        if isfield(wavestruct,'rtparam'),
            lukeobj.c3poparam.text.string = wavestruct.rtparam;
        end
        %
        if isfield(wavestruct,'orig'),
            lukeobj.c3poparam.reset.state = 'on';
        else
            lukeobj.c3poparam.reset.state = 'off';
        end
        %
        % c3po dist computing
        %
        lukeobj.wsparamtitle.state = 'on';
        lukeobj.wsparam.state = 'on';
        %
        if strcmp(wavestruct.launch.type,'LH'),
            if isfield(wavestruct.launch,'spectrum'),
                lukeobj.spectrum.modify.state = 'on';
                lukeobj.spectrum.save.state = 'on';
                %
                if isfield(wavestruct.launch.spectrum,'orig'),
                    lukeobj.spectrum.reset.state = 'on';
                else
                    lukeobj.spectrum.reset.state = 'off';
                end
                %
    %             lukeobj.spectrum.text.string = ['ne0_17 = ',num2str(wavestruct.launch.spectrum.plasma.ne0/1e17,3),'',...
    %                 ' ; l1 = ',num2str(wavestruct.launch.spectrum.plasma.lambda_n(1)/1e3,3),' mm',...
    %                 ' ; l2 = ',num2str(wavestruct.launch.spectrum.plasma.lambda_n(2)/1e3,3),' mm'];
                lukeobj.spectrum.text.string = ['ID : ',wavestruct.launch.spectrum.id,... 
                    ' ; #lobes = ',num2str(wavestruct.launch.spectrum.param_tor.nlobes,3),'',...
                    ' ; dir = ',num2str(wavestruct.launch.spectrum.param_tor.dir,3),'',...
                    ' ; mode = ',num2str(wavestruct.launch.spectrum.param_tor.mode,3),''];
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
            if any(imag(wavestruct.launch.bNpar0) ~= 0),            
                nparstr = 'Nz0';
                npar0disp = imag(wavestruct.launch.bNpar0(find(wavestruct.launch.bPlhtot == max(wavestruct.launch.bPlhtot),1,'first')));
            else
                nparstr = 'N//0';
                npar0disp = wavestruct.launch.bNpar0(find(wavestruct.launch.bPlhtot == max(wavestruct.launch.bPlhtot),1,'first'));
            end
            lukeobj.launch.text.string = [lukeobj.launch.text.string,...
                ' ; ',nparstr,' : ',num2str(npar0disp,3),'',...
                ' ; P = ',num2str(sum(wavestruct.launch.bPlhtot)/1e6,3),' MW'];
            %
            clear npar0disp
            %
        elseif strcmp(wavestruct.launch.type,'EC'),
            if isfield(wavestruct.launch,'angles'),
                lukeobj.angles.modify.state = 'on';
                lukeobj.angles.save.state = 'on';
                if isfield(wavestruct.launch.angles,'orig'),
                    lukeobj.angles.reset.state = 'on';
                else
                    lukeobj.angles.reset.state = 'off';
                end
                %
                lukeobj.angles.text.string = [  'ID : ',num2str(wavestruct.launch.angles.id),...
                    ' ; P = ',num2str(wavestruct.launch.angles.P0/1e3,3),' kW',...
                    ' ; f = ',num2str(wavestruct.launch.angles.freq/1e9,3),' GHz'];
                %
            else
                lukeobj.angles.modify.state = 'off';
                lukeobj.angles.save.state = 'off';
                lukeobj.angles.reset.state = 'off';
                lukeobj.angles.text.string = '';
            end
            %
            lukeobj.runc3pooptim.state = 'on';
            %
            lukeobj.spectrum.text.string = '';
            lukeobj.launch.text.string = [lukeobj.launch.text.string,...
                ' ; alpha = ',num2str(wavestruct.launch.yalpha_L*180/pi,3),' °',...
                ' ; beta = ',num2str(wavestruct.launch.ybeta_L*180/pi,3),' °'];
            %
        end
        %
        lukeobj.runc3pooptim.highlight = true;    
        %
        clear wavestruct
    else
        %
        lukeobj.runc3pooptim.state = 'off'; 
        lukeobj.runc3pooptim.highlight = false;
        %
        % launch
        %
        lukeobj.launch.modify.state = 'off';
        lukeobj.launch.save.state = 'on';
        lukeobj.launch.reset.state = 'off';
        lukeobj.launch.text.string = '< time specific >';
        %
        % spectrum
        %
        lukeobj.spectrum.modify.state = 'off';
        lukeobj.spectrum.save.state = 'off';
        lukeobj.spectrum.reset.state = 'off';
        lukeobj.spectrum.text.string = '';
        %
        % angles
        %
        lukeobj.angles.modify.state = 'off';
        lukeobj.angles.save.state = 'off';
        lukeobj.angles.reset.state = 'off';
        lukeobj.angles.text.string = '';
        %
        % c3poparam
        %
        itlist = find(status.wavestructs(iw,:) == 1);% list of times
        rtparam = selectfields_jd(wavestructss{iw,itlist(1)},{'rtparam','rayparam','waveparam','fitparam','C3POparam','C3POdisplay'});
        %
        comptest = true;
        %
        for it = 2:length(itlist),
            rtparam_comp = selectfields_jd(wavestructss{iw,itlist(it)},{'rtparam','rayparam','waveparam','fitparam','C3POparam','C3POdisplay'});
            comptest = comptest && comp_struct_jd(rtparam,rtparam_comp,0);
        end
        %
        if comptest,
            lukeobj.c3poparam.modify.state = 'on';
            lukeobj.c3poparam.load.state = 'on';
            lukeobj.c3poparam.save.state = 'on';
            lukeobj.c3poparam.text.string = rtparam.rtparam;
            %
            if isfield(wavestructss{iw,itlist(1)},'orig'),
                lukeobj.c3poparam.reset.state = 'on';
            else
                lukeobj.c3poparam.reset.state = 'off';
            end
        else
            lukeobj.c3poparam.modify.state = 'off';
            lukeobj.c3poparam.load.state = 'off';
            lukeobj.c3poparam.save.state = 'off';
            lukeobj.c3poparam.reset.state = 'off';
            lukeobj.c3poparam.text.string = '< time specific >';
        end
        %
        clear itlist iwlist rtparam rtparam_comp comptest
    end
    %
    clear iw_curtime wavestructid
    %
end
%
clear flag_external wavestructs iw nw 
%
% upgrade graph status
%
% plotindices = [lukeobj.plot1.gindex,lukeobj.plot2.gindex,lukeobj.plot3.gindex];
% %
% nstr = length('spectrum for ');
% %
% ngraphs = length(graphs);
% for igraph = ngraphs:-1:1,
%     if strcmp(graphs(igraph).tag,'spectrum') && ~any(strcmp(graphs(igraph).info(nstr+1:end),lukeobj.wavestruct.select.string)),% the corresponding wavestruct no longer exists
%         for ich = 1:length(graphs(igraph).handles),
%             delete(graphs(igraph).handles(ich))
%         end
%         graphs(igraph) = [];
%         plotindices(plotindices == igraph) = 0;
%         plotindices(plotindices > igraph) = plotindices(plotindices > igraph) - 1;
%     end
% end
% %
% lukeobj.plot1.gindex = plotindices(1);
% lukeobj.plot2.gindex = plotindices(2);
% lukeobj.plot3.gindex = plotindices(3);
%
clear nstr igraph ngraphs plotindices











