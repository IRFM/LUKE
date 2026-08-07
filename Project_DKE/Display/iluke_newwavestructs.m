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
% script iluke_newwavestructs
%
replaceopts = repmat({[]},size(wavestructids));
%
newwavestructids = cell(0,1);
newwavestructsstatus = zeros(0,ntimes);
newwavestructss = cell(0,ntimes);
%
nt = length(flag_shotimes);
for it = 1:nt,
    for iw = 1:length(launchs{it});
        %
        wavestruct = imake_wavestructs_jd(equils{flag_shotimes(it)},launchs{it}{iw});
        %
        isel = find(strcmp(wavestruct.id,wavestructids));% compare with existing wavestructids
        if isempty(isel),% wavestruct id is not listed in existing wavestructids
            %
            status.data = 2;
            %
            newisel = find(strcmp(wavestruct.id,newwavestructids));% compare with existing newwavestructids
            if isempty(newisel),% new wavestruct id
                newwavestructids{end+1,1} = wavestruct.id;
                %
                newwavestructsstatus(end+1,:) = zeros(1,ntimes);
                newwavestructss(end+1,:) = cell(1,ntimes);
                %
                newwavestructsstatus(end,flag_shotimes(it)) = 1;
                newwavestructss{end,flag_shotimes(it)} = wavestruct;
            else% wavestruct id listed in existing newwavestructids
                if newwavestructsstatus(newisel,flag_shotimes(it)) == 1,
                    disp(['Warning : replacing an existing new wavestructs with id ',wavestruct.id])
                end
                newwavestructsstatus(newisel,flag_shotimes(it)) = 1;
                newwavestructss{newisel,flag_shotimes(it)} = wavestruct;
            end
            %
        else% wavestruct id is listed in existing wavestructids
            %
            if isempty(replaceopts{isel})% prompt for action
                %
                replaceopt = iselect_jd({...
                    'Discard new wavestruct',...
                    'Fill or replace existing wavestructss cell',...
                    'Modify new wavestruct id'},...                                    
                    ['The wavestruct id ',wavestruct.id,' is already referenced :'],lukeobj.infopanel.handle,style.buttonselectstyle,3,'buttongroup');
                %
                if replaceopt == 2,% replace
                    %
                    status.data = 2;
                    %
                    wavestructss{isel,flag_shotimes(it)} = wavestruct;
                    status.wavestructs(isel,flag_shotimes(it)) = 1;
                elseif replaceopt == 3,% create new wavestruct id
                    %
                    status.data = 2;
                    %
                    while any(strcmp(wavestruct.id,wavestructids)),
                        wavestruct.id = iselect_jd({},'New wavestruct id : ',lukeobj.infopanel.handle,style.editselectstyle,wavestruct.id,'edit');
                    end
                    newwavestructids{end+1} = wavestruct.id;
                    %
                    newwavestructsstatus(end+1,:) = zeros(1,ntimes);
                    newwavestructss(end+1,:) = cell(1,ntimes);
                    %
                    newwavestructsstatus(end,flag_shotimes(it)) = 1;
                    newwavestructss{end,flag_shotimes(it)} = wavestruct;
                end
                %
                if nt > 1,% prompt to apply same to all shot times
                    %
                    allopt = iselect_jd({'Yes','No'},'Apply to all times ?',lukeobj.infopanel.handle,style.buttonselectstyle,1,'buttongroup');
                    %
                    if allopt == 1,
                        %
                        if replaceopt == 1,% discard all
                            replaceopts{isel} = false;
                        elseif replaceopt == 2,% replace all
                            replaceopts{isel} = true;
                        else% modify wavestruct id
                            replaceopts{isel} = wavestruct.id;
                        end
                    end
                    %
                    clear allopt
                    %
                end
                %
                clear replaceopt 
                %
            elseif islogical(replaceopts{isel}) && replaceopts{isel},% fill or replace all with new 
                %
                status.data = 2;
                %
                wavestructss{isel,flag_shotimes(it)} = wavestruct;
                status.wavestructs(isel,flag_shotimes(it)) = 1;
                %
            elseif ischar(replaceopts{isel}), %use this id as new id
                %
                status.data = 2;
                %
                wavestruct.id = replaceopts{isel};
                newisel = find(strcmp(wavestruct.id,newwavestructids));
                newwavestructss{newisel,flag_shotimes(it)} = wavestruct;
                newwavestructsstatus(newisel,flag_shotimes(it)) = 1;
            end
        end
    end
end
%
wavestructids = [wavestructids;newwavestructids];
status.wavestructs = [status.wavestructs;newwavestructsstatus];
wavestructss = [wavestructss;newwavestructss];
%
clear replaceopts wavestruct newwavestructids newwavestructsstatus newwavestructss it nt iw isel newisel
