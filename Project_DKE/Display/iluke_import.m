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
    equil = iluke_equilcorr(import.equil);
    %
    tokamak = equil.tokamak;
    shotnum = equil.shotnum;
    %
    curtime = 1;
    %
    equils{curtime} = equil;
    status.equil(curtime) = 3;
    shotimes(curtime) = equil.shotime;
    %
    status.data = 2;
    lukeobj.lukeid.string = '';
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
        %lukeobj.display.text.string = dkedisplay.id;
    end
    %
    if isfield(import,'ohm') && ~isempty(import.ohm),
        ohms{curtime} = import.ohm;
        status.ohm(curtime) = 1;
        %
        action = 'ohmdisp';iluke_callbacks;
    else
        status.ohm(curtime) = 0;                    
    end
    %
    if isfield(import,'transpfaste') && ~isempty(import.transpfaste),
        transpfastes{curtime} = import.transpfaste;
        status.transpfaste(curtime) = 1;
        %
        action = 'transpdisp';iluke_callbacks;
    else
        status.transpfaste(curtime) = 0;                    
    end
    %
    if isfield(import,'ripple') && ~isempty(import.ripple),
        ripples{curtime} = import.ripple;
        status.ripple(curtime) = 1;
        %
        action = 'rippledisp';iluke_callbacks;
    else
        status.ripple(curtime) = 0;
    end
    %
    if isfield(import,'waves') && ~isempty(import.waves),
        wavess{curtime} = import.waves;
        status.waves(curtime) = 1;
        %
        action = 'wavedisp';iluke_callbacks;
    elseif isfield(import,'output') && isfield(import.output,'dke_out') && isfield(import.output.dke_out,'waves') && ~isempty(import.output.dke_out.waves),
        wavess{curtime} = import.output.dke_out.waves;
        status.waves(curtime) = 1;
        %
        action = 'wavedisp';iluke_callbacks;
    else
        status.waves(curtime) = 0;
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
        wavestructss{curtime} = import.wavestructs;
        lukeobj.wavestruct.select.value = length(wavestructss{curtime});
    end                
    if isfield(import,'output') && ~isempty(import.output),
        outputs{curtime} = import.output;
        status.output(curtime) = 1;
        %
        action = 'lukedisp';iluke_callbacks;
    else
        status.output = 0;
    end
    %
    status.data = 1;
    lukeobj.simulfile.string = filename;%[pathname,filename];
end                          
