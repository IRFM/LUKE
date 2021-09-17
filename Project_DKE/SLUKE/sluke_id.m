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
    if isempty(sparams.kinetics.dkeparam.id{ii})
        %
        id = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',int2str(ii)];
        %
    else
        %
        id = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',sparams.simul.id{ii},'_',sparams.kinetics.dkeparam.id{ii},'_',int2str(ii)];
        %
    end
end
%
if strcmp(type,'dkedisplay')
    %
    if isempty(sparams.kinetics.dkedisplay.id{ii})
        %
        id = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',int2str(ii)];
        %
    else
        %
        id = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',sparams.simul.id{ii},'_',sparams.kinetics.dkedisplay.id{ii},'_',int2str(ii)];
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
if strcmp(type,'wavestructs')
    %
    if isfield(sparams,'rfwaves')
        %
        if isempty(sparams.rfwaves.id{ii})
            %
            id = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',int2str(ii)];
            %
        else
            %
            id = [sparams.machine{ii},'_',sparams.discharge.shot{ii}];
            %
            id = [id,'_',sparams.rfwaves.id{ii}];
            %
            if isfield(sparams.rfwaves,'solver') && ~isempty(sparams.rfwaves.antenna.type{ii})
                %
                for jj = 1:length(sparams.rfwaves.antenna.type{ii})
                    %
                    if isfield(sparams.rfwaves,'antenna') && ~isempty(sparams.rfwaves.antenna.id{ii})
                        %
                        id = [id,'_',sparams.rfwaves.antenna.id{ii}{jj}];
                        %
                    end
                    %
                    if isfield(sparams.rfwaves,'antenna') && ~isempty(sparams.rfwaves.antenna.code{ii})
                        %
                        if ~isempty(sparams.rfwaves.antenna.code{ii}{jj})
                            %
                            id = [id,'_',sparams.rfwaves.antenna.code{ii}{jj}];
                            %
                        end
                        %
                    end
                    %
                    if isfield(sparams.rfwaves,'solver') && isfield(sparams.rfwaves.solver,'code') && ~isempty(sparams.rfwaves.solver.code{ii})
                        %
                        id = [id,'_',sparams.rfwaves.solver.code{ii}{jj}];
                        %
                    end
                    %
                end
                %
            end
            %
            id = [id,'_',int2str(ii)];
            %
        end
    end
end
%
id = strrep(id,' ','_');
id = strrep(id,',','_');
id = strrep(id,';','_');
