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







%{
    try
        data = sluke_id_add(data,'',data.input.simulation.machine);
        data = sluke_id_add(data,'',data.input.simulation.name);
        data = sluke_id_add(data,'',data.input.simulation.shotnumber);
        data = sluke_id_add(data,'',data.input.simulation.timegrid);
        data = sluke_id_add(data,'',data.input.simulation.datasource.mode);
        %data = sluke_id_add(data,'',data.input.models.equilibrium.code);
        data = sluke_id_add(data,'SELF',data.input.models.equilibrium.consistency);
        data = sluke_id_add(data,'',data.input.remote.computer.name);
    catch
        
    end
    %
    function [data] = sluke_id_add(data,label,x)
        %
        if ~isempty(x),
            %
            if ~isfield(data.input.simulation,'id'),
                data.input.simulation.id = '';
            end
            %
            if ~isempty(label)
               label = [label,'_'];
            end
            %
            if ischar(x)
                %
                if isempty(data.input.simulation.id)
                    data.input.simulation.id = [data.input.simulation.id,x];
                else
                    data.input.simulation.id = [data.input.simulation.id,'_',x];
                end
                %
            else
                if length(x) > 1
                    %
                    y = mat2str(x);
                    iy  = strfind(y,' ')
                    %
                    if length(iy) ==  1
                        y = y(2:end-1);
                        z = [y(1:iy(1)-2),'-',y(iy(end):end)];
                        z = strrep(z,'.','p');
                        data.input.simulation.id = [data.input.simulation.id,'_',label,z]
                    elseif length(iy) > 1
                        y = y(2:end-1);
                        z = [y(1:iy(1)-2),':',y(iy(end):end)];
                        z = strrep(z,'.','p');
                        data.input.simulation.id = [data.input.simulation.id,'_',label,z];
                    elseif length(iy) ==  0
                        data.input.simulation.id = [data.input.simulation.id,'_',label,int2str(x)];
                    end
                    %
                else
                    %
                    if isempty(data.input.simulation.id)
                        data.input.simulation.id = [data.input.simulation.id,num2str(x)];
                    else
                        data.input.simulation.id = [data.input.simulation.id,'_',num2str(x)];
                    end
                    %
                end
            end
            %
            data.input.simulation.id = strrep(data.input.simulation.id,'.','p');
            %
            return
        end
    end
end
%}