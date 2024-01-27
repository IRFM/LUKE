function ohm = sluke_ohm(sparams,ii)

%
if ~isfield(sparams,'ohm')
    %
    cprintf([1,0.5,0],'No ohmic electric field is defined in sparams');disp(' ');
    ohm = [];
    return
    %
end
%
ohm_id = sluke_id(sparams,ii);
%
if exist(['SLUKE_OHMS/OHM_',ohm_id,'.mat'])
    %
    load(['SLUKE_OHMS/OHM_',ohm_id,'.mat']);
    %
else
    %
    if isfield(sparams.ohm,'code') && strcmp(sparams.ohm.code{ii},'code')
        %
        %
    elseif isfield(sparams.ohm,'source') && strcmp(sparams.ohm.source{ii},'file') && isfield(sparams.ohm,'file') && ~isempty(sparams.ohm.file{ii})
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
    elseif isfield(sparams.ohm,'source') && isempty(sparams.ohm.source{ii}) && isfield(sparams.ohm,'Vloop') && ~isempty(sparams.ohm.Vloop{ii}) 
        %
        cprintf('*green','Flat ohmic electric field is considered in sparams');disp(' ');
        %
        load(['./SLUKE_EQUILS/EQUIL_',ohm_id,'.mat'],'equil');
        %
        ohm.rho = psi2rho_jd(equil{end},equil{end}.psi_apRp);%Arbitrary normalized minor radius
        ohm.epsi = sparams.ohm.Vloop{ii}*ones(1,length(ohm.rho))/(2*pi*equil{end}.Rp);%(V/m)
        ohm.Vloop = sparams.ohm.Vloop{ii};
        %
        save(['SLUKE_OHMS/OHM_',ohm_id,'.mat'],'ohm');
        %
    else 
        %
        cprintf([1,0.5,0],'No ohmic electric field is considered in sparams');disp(' ');
        ohm = [];
        %
    end
end
