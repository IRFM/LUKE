function lukeobj = iluke_info(lukeobj,s)
    %
    % manages content of info panel
    %
    if ischar(s) && isempty(s),
        %
        lukeobj = iluke_switch(lukeobj,'');% disable display
        %
    elseif ischar(s) && strcmp(s,'text'),
        %
        lukeobj = iluke_switch(lukeobj,'text');% enable display
        %
        lukeobj.infostr.string = {'INFOS'};
        %
    elseif ischar(s) && strcmp(s,'startup'),% startup display
        %
        lukeobj = iluke_switch(lukeobj,'text');
        %
        lukeobj.infostr.string = {'INFOS'};
        lukeobj.infotext.string = {'',...
        '            To get started :',...
        '            ==============','',...
        '    - "Load" Existing simulation','',...
        '    - "Import" Exp. data to import from database',...
        '    - "Load" Exp. data to load from existing EXTERNAL file',...
        '    - "New" Equilibrium to create equilibrium or import EQDSK file',...
        '    - "Load" Equilibrium  to load from existing EQUIL file'};

        %
    elseif ischar(s) && strcmp(s,'data'),% display after external
        %
        lukeobj = iluke_switch(lukeobj,'text');
        %
        lukeobj.infostr.string = {'INFOS'};
        lukeobj.infotext.string = {'','Next step :',...
                   '=========  ','',...
        '- "New" Equilibrium to create equilibrium from EXTERNAL structure'};

        %
    elseif ischar(s) && strcmp(s,'output'),% display after external
        %
        lukeobj = iluke_switch(lukeobj,'text');
        %
        lukeobj.infostr.string = {'INFOS'};
        lukeobj.infotext.string = {'','Next step :',...
                   '=========  ','',...
        '- You may now create additional input structures, or run LUKE'};

        %
    elseif ischar(s) && strcmp(s,'luke'),% display after external
        %
        lukeobj = iluke_switch(lukeobj,'luke');
        %
        lukeobj.infostr.string = {'RUN LUKE'};
        %
    elseif ischar(s) && strcmp(s,'c3po'),% display after external
        %
        lukeobj = iluke_switch(lukeobj,'c3po');
        %
        lukeobj.infostr.string = {'RUN C3PO'};
        %
    elseif ischar(s) && strcmp(s,'c3po_MultiTimes'),% display after external
        %
        lukeobj = iluke_switch(lukeobj,'c3po_MultiTimes');
        %
        lukeobj.infostr.string = {'RUN C3PO'};
        %
    elseif ischar(s) && strcmp(s,'r5x2'),% display after external
        %
        lukeobj = iluke_switch(lukeobj,'r5x2');
        %
        lukeobj.infostr.string = {'RUN R5X2'};
        %
    end
    %
    iluke_update_state(lukeobj);
    %
end

function lukeobj = iluke_switch(lukeobj,str)
    %
    % switches between panels
    %
    if strcmp(str,'luke'),
        %
        set(lukeobj.infotext.handle,'visible','off');
        set(lukeobj.infostr.handle,'visible','on');
        %
        lukeobj.param.visible = 'on';
%         lukeobj.display.visible = 'on';
        lukeobj.timedep.visible = 'on';
        lukeobj.remote.visible = 'on';
        lukeobj.runluke.visible = 'on';
        lukeobj.lukeidtitle.visible = 'on';
        lukeobj.lukeid.visible = 'on';
        lukeobj.runcheck.visible = 'on';
        lukeobj.lukechecktext.visible = 'on';
        %
    else
        %
        lukeobj.param.visible = 'off';
%         lukeobj.display.visible = 'off';
        lukeobj.timedep.visible = 'off';
        lukeobj.remote.visible = 'off';
        lukeobj.runluke.visible = 'off';
        lukeobj.lukeidtitle.visible = 'off';
        lukeobj.lukeid.visible = 'off';
        lukeobj.runcheck.visible = 'off';
        lukeobj.lukechecktext.visible = 'off';
        %
    end
    %
    if strcmp(str,'c3po'),
        %
        set(lukeobj.infotext.handle,'visible','off');
        set(lukeobj.infostr.handle,'visible','on');
        %
        lukeobj.angles.visible = 'on';
        lukeobj.spectrum.visible = 'on';
        lukeobj.launch.visible = 'on';
        lukeobj.c3poparam.visible = 'on';%
        lukeobj.runc3pooptim.visible = 'on';
        lukeobj.wsparamtitle.visible = 'on';
        lukeobj.wsparam.visible = 'on';
        %
    else
        %
        lukeobj.angles.visible = 'off';
        lukeobj.spectrum.visible = 'off';
        lukeobj.launch.visible = 'off';
        lukeobj.c3poparam.visible = 'off';%
        lukeobj.runc3pooptim.visible = 'off';
        lukeobj.wsparamtitle.visible = 'off';
        lukeobj.wsparam.visible = 'off';
        %
    end
    %
    if strcmp(str,'c3po_MultiTimes'),
        %
%         lukeobj.shotdist.visible = 'on';
%         lukeobj.wavedist.visible = 'on';
%         lukeobj.raydist.visible = 'on';
        %
    else
        %
%         lukeobj.shotdist.visible = 'off';
%         lukeobj.wavedist.visible = 'off';
%         lukeobj.raydist.visible = 'off';
        %
    end
    %
    if any(strcmp(str,{'c3po_MultiTimes','c3po'})),
        %
        set(lukeobj.infotext.handle,'visible','off');
        set(lukeobj.infostr.handle,'visible','on');
        %
        lukeobj.wavestruct.visible = 'on';
        lukeobj.wavestruct.select.visible = 'off';
%         lukeobj.c3poparam.visible = 'on';
        lukeobj.runc3po.visible = 'on';
        lukeobj.runc3poall.visible = 'on';
        %
    else
        %
        lukeobj.wavestruct.visible = 'off';
        lukeobj.wavestruct.select.visible = 'off';
%         lukeobj.c3poparam.visible = 'off';
        lukeobj.runc3po.visible = 'off';
        lukeobj.runc3poall.visible = 'off';
        %
    end
    %
    if strcmp(str,'r5x2'),
        %
        set(lukeobj.infotext.handle,'visible','off');
        set(lukeobj.infostr.handle,'visible','on');
        %
        lukeobj.hxrcam.visible = 'on';
        lukeobj.hxrcam.select.visible = 'on';
        lukeobj.hxrexp.visible = 'on';
        lukeobj.hxrparam.visible = 'on';
        lukeobj.hxrbrem.visible = 'on';
        lukeobj.hxrdiag.visible = 'on';
        %
    else
        %
        lukeobj.hxrcam.visible = 'off';
        lukeobj.hxrcam.select.visible = 'off';
        lukeobj.hxrexp.visible = 'off';
        lukeobj.hxrparam.visible = 'off';
        lukeobj.hxrbrem.visible = 'off';
        lukeobj.hxrdiag.visible = 'off';
    end
    %
    if isempty(str),
        %
        set(lukeobj.infotext.handle,'visible','off');
        set(lukeobj.infostr.handle,'visible','off');
        %
    elseif strcmp(str,'text'),
        %
        set(lukeobj.infotext.handle,'visible','on');
        set(lukeobj.infostr.handle,'visible','on');
        %
    end
end
        
    




