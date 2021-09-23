function ohm = sluke_ohm(sparams,ii)

ohm_id = sluke_id(sparams,ii,'ohm');
%
if exist(['SLUKE_OHMS/OHM_',ohm_id,'.mat'])
    %
    load(['SLUKE_OHMS/OHM_',ohm_id,'.mat']);
    %
else
    %
    if strcmp(sparams.ohm.source{ii},'code')
        %
        %
    elseif strcmp(sparams.ohm.source{ii},'file')
        %
        ohm_file = sparams.ohm.file{ii};
        ohm_path = sparams.ohm.path{ii};
        %
        if strcmp(sparams.ohm.path{ii},'.')
            ohm_path = [pwd,'/'];
        else
            if strcmp(sparams.ohm.path{ii}(end),'/')
                ohm_path = sparams.ohm.path{ii};
            else
                ohm_path = [sparams.ohm.path{ii},'/'];
            end
        end
        %
        data = load([ohm_path,ohm_file]);
        %
        if isfield(data,'post') % ohmic field from metis simulations
            %
            sparams.equil.equilconsistencyparam.run = 0;
            [~,~,~,ohm,~,~,~] = auto_extract_metisdata_for_luke(data.post,sparams.discharge.tmin{ii});
            %
            movefile('before_luke@*','./INPUTS/','f');% move all before_luke* files created by auto_extract_metisdata_for_luke. Files may be overwritten
            %
            fns = fieldnames(sparams.ohm);
            %
            for jj = 1:length(fns)
                %
                eval(['source.',fns{jj},' = sparams.ohm.',fns{jj},'{',int2str(ii),'};']);
                %
            end
            %
            ohm.source = source;
            clear source
            %
            save(['SLUKE_OHMS/OHM_',ohm_id,'.mat'],'ohm');
            %
        elseif isfield(data,'ohm') %existing ohm at LUKE format complatible with equil
            %
            ohm = data.ohm;
            save(['SLUKE_OHMS/OHM_',ohm_id,'.mat'],'ohm');
            %
        else
            error([]);
        end
        %
    else 
        %
        %
    end
end
