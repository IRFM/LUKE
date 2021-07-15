function [id] = sluke_id(sparams,ii,type)
%
if strcmp(type,'ohm')
    %
    if isempty(sparams.ohm.id{ii})
        %
        id = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',int2str(ii)];
        %
    else
        %
        id = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',sparams.ohm.id{ii},'_',int2str(ii)];
        %
    end
end
%
if strcmp(type,'equil')
    %
    if isempty(sparams.equil.id{ii})
        %
        id = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',int2str(ii)];
        %
    else
        %
        id = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',sparams.equil.id{ii},'_',int2str(ii)];
        %
    end
end
%
if strcmp(type,'simul')
    %
    if isempty(sparams.simul.id{ii})
        %
        id = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',int2str(ii)];
        %
    else
        %
        id = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',sparams.simul.id{ii},'_',int2str(ii)];
        %
    end
end
%
if strcmp(type,'dkeparam')
    %
    if isempty(sparams.dkeparam.id{ii})
        %
        id = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',int2str(ii)];
        %
    else
        %
        id = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',sparams.simul.id{ii},'_',sparams.dkeparam.id{ii},'_',int2str(ii)];
        %
    end
end
%
if strcmp(type,'dkedisplay')
    %
    if isempty(sparams.dkedisplay.id{ii})
        %
        id = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',int2str(ii)];
        %
    else
        %
        id = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',sparams.simul.id{ii},'_',sparams.dkedisplay.id{ii},'_',int2str(ii)];
        %
    end
end
%
if strcmp(type,'fit')
    %
    if isempty(sparams.equil.fit.id{ii})
        %
        id = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',int2str(ii)];
        %
    else
        %
        id = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',sparams.simul.id{ii},'_',sparams.equil.fit.id{ii},'_',int2str(ii)];
        %
    end
end
%
if strcmp(type,'equilconsistency')
    %
    if isempty(sparams.equil.equilconsistency.id{ii})
        %
        id = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',int2str(ii)];
        %
    else
        %
        id = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',sparams.simul.id{ii},'_',sparams.equil.equilconsistency.id{ii},'_',int2str(ii)];
        %
    end
end
%
if strcmp(type,'launch')
    %
    if isfield(sparams,'rf')
        %
        if isempty(sparams.launch.id{ii})
            %
            id = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',int2str(ii)];
            %
        else
            %
            id = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',sparams.simul.id{ii},'_',sparams.rf.launch.id{ii},'_',int2str(ii)];
            %
        end
        %
    else
        %
        id = '';
        disp('WARNING : the ''rf'' sub-structure is not available -> launch id is empty.')
        %
    end
end
%
if strcmp(type,'rayparam')
    %
    if isfield(sparams,'rf')
        %
        if isempty(sparams.rf.rayparam.id{ii})
            %
            id = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',int2str(ii)];
            %
        else
            %
            id = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',sparams.simul.id{ii},'_',sparams.rf.rayparam.id{ii},'_',int2str(ii)];
            %
        end
        %
    else
        %
        id = '';
        disp('WARNING : the ''rf'' sub-structure is not available -> rayparam id is empty.')
        %
    end
end
%
if strcmp(type,'raydisplay')
    %
    if isfield(sparams,'rf')
        %
        if isempty(sparams.rf.raydisplay.id{ii})
            %
            id = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',int2str(ii)];
            %
        else
            %
            id = '';
            id = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',sparams.simul.id{ii},'_',sparams.rf.raydisplay.id{ii},'_',int2str(ii)];
            %
        end
    else
        %
        id = '';
        disp('WARNING : the ''rf'' sub-structure is not available -> raydisplay id is empty.')
        %         
    end
end
%
if strcmp(type,'waveparam')
    %
    if isfield(sparams,'rf')
        %
        if isempty(sparams.rf.waveparam.id{ii})
            %
            id = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',int2str(ii)];
            %
        else
            %
            id = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',sparams.simul.id{ii},'_',sparams.rf.waveparam.id{ii},'_',int2str(ii)];
            %
        end
        %
    else
        %
        id = '';
        disp('WARNING : the ''rf'' sub-structure is not available -> waveparam id is empty.')
        %
    end
end
%
id = strrep(id,' ','_');%
id = strrep(id,',','_');%
id = strrep(id,';','_');%
%


%