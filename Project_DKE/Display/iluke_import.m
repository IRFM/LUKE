%
% script iluke_import
%
if isfield(import,'equil') && ~isempty(import.equil)
    % 
    % clear current simulation
    %
    action = 'newshot';iluke_callbacks;
    %
    % new equil
    %
    equil = import.equil;
    status.equil = 1;
    lukeobj = iluke_equilstrings(lukeobj,equil);
    %
    action = 'equildisp';iluke_callbacks;
    %
    if isfield(import,'dkeparam') && ~isempty(import.dkeparam),
        dkeparam = import.dkeparam;
        lukeobj.param.text.string = dkeparam.id;
    end
    %
    if isfield(import,'dkedisplay') && ~isempty(import.dkedisplay),
        dkedisplay = import.dkedisplay;
        lukeobj.display.text.string = dkedisplay.id;
    end
    %
    if isfield(import,'ohm') && ~isempty(import.ohm),
        ohm = import.ohm;
        status.ohm = 1;
        %
        action = 'ohmdisp';iluke_callbacks;
    else
        status.ohm = 0;                    
    end
    %
    if isfield(import,'transpfaste') && ~isempty(import.transpfaste),
        transpfaste = import.transpfaste;
        status.transpfaste = 1;
        %
        action = 'transpdisp';iluke_callbacks;
    else
        status.transpfaste = 0;                    
    end
    %
    if isfield(import,'ripple') && ~isempty(import.ripple),
        ripple = import.ripple;
        status.ripple = 1;
        %
        action = 'rippledisp';iluke_callbacks;
    else
        status.ripple = 0;
    end
    %
    if isfield(import,'waves') && ~isempty(import.waves),
        waves = import.waves;
        status.waves = 1;
        %
        action = 'wavedisp';iluke_callbacks;
    elseif isfield(import,'output') && isfield(import.output,'dke_out') && isfield(import.output.dke_out,'waves') && ~isempty(import.output.dke_out.waves),
        waves = import.output.dke_out.waves;
        status.waves = 1;
        %
        action = 'wavedisp';iluke_callbacks;
    else
        status.waves = 0;
    end
    %
    if isfield(import,'wavestructs') && ~isempty(import.wavestructs),
        for iw = 1:length(import.wavestructs),
            if isfield(import.wavestructs{iw},'fitequilparam'),
                import.wavestructs{iw}.fitparam = import.wavestructs{iw}.fitequilparam;
                import.wavestructs{iw} = rmfield(import.wavestructs{iw},'fitequilparam');
            end
            if isfield(import.wavestructs{iw},'raydisplay'),
                import.wavestructs{iw}.C3POdisplay = import.wavestructs{iw}.raydisplay;
                import.wavestructs{iw} = rmfield(import.wavestructs{iw},'raydisplay');
            end
        end
        wavestructs = [wavestructs,import.wavestructs];
        lukeobj.wavestruct.select.value = length(wavestructs);
    end                
    if isfield(import,'output') && ~isempty(import.output),
        output = import.output;
        status.output = 1;
        %
        action = 'lukedisp';iluke_callbacks;
    else
        status.output = 0;
    end
    %
    status.data = 1;
    lukeobj.simulfile.string = filename;%[pathname,filename];
end                          
