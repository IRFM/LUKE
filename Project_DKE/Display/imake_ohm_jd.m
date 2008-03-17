function ohm = imake_ohm_jd(basestr,equil)
%
% This function interactively builds the ohm structure
%
ohm = '';
%
o_opt = input('Option for ohm calculation? 0 (VLOOP), 1 (E/ED) : ');
%
if isempty(o_opt)| ~isnumeric(o_opt) | ~any(o_opt == [0,1]),
    disp('-----> Invalid ohm option');
    return
end
%
if o_opt == 0,% ohm from VLOOP
    %
    i_opt = input('Option for vloop value : 0 (from launching data), 1 (specify value) [0]');
    %
    if isempty(i_opt),
        i_opt = 0;
    end
    if ~isnumeric(i_opt) | ~any(i_opt == [0,1]),
        disp('-----> Invalid vloop option');
        return
    end
    %
    if i_opt == 0,%vloop from launching data 
        %
        if strcmp(basestr,'TCV'),% TCV launching data
            %
            if isfield(equil.info,'shotnum');
                shotnum = equil.info.shotnum;
            else
                disp('-----> Shot number information missing');
                return
            end
            %
%             if isfield(equil.info,'shotime');
%                 shotime = equil.info.shotime;
%             else
%                 disp('-----> Shot time information missing');
%                 return
%             end
%             %
%             % VLOOP value
%             %
%             n_opt = input('Option for vloop data? 0 (data file), 1 (TCV database) [0] : ');
%             if isempty(n_opt),
%                 n_opt = 0;
%             end
%             if ~isnumeric(n_opt) | ~any(n_opt == [0,1]),
%                 disp('-----> Invalid vloop data option');
%                 return
%             end
%             %
%             if n_opt == 0,% launching data from file
%                 %
%                 if isfield(equil.info,'prof');
%                     proffile = equil.info.prof;
%                 else
%                     proffile = '';
%                 end                
%                 %
%                 [data_file,data_path] = uigetfile('*.*',['Please select the data file for shot ',shotnum,' at time ',shotime,' :'],proffile);
%                 %
%                 if data_file == 0,
%                     return
%                 end
%                 %
%                 data = load([data_path,data_file],'shot','vloop');
%                 %
%             elseif n_opt == 1,% launching data from TCV database
%                 %
%                 disp('-----> launching data from TCV database not implemented yet');
%                 return
%             end
            %
            data = load(equil.info.data,'shot','vloop');
            %
            ishot = find(data.shot == str2num(shotnum));
            %
            if isempty(ishot),
                disp(['-----> launching data not found for shot :',shotnum]);
                return
            end
            %
            if length(ishot) > 1,
                disp(['-----> WARNING : Several entries are found for shot :',shotnum,', first entry selected']);
                ishot = ishot(1);
            end
            %
            vloop = data.vloop(ishot);
            %
        else
            %
            disp(['-----> vloop data not implemented yet for :',basestr]);
            return    
            %
        end
        %
    elseif i_opt == 1,%vloop specified 
        %
        vloop = input('Please specify the value for Vloop (V) : ');
        if isempty(vloop) | ~isnumeric(n_opt),
            disp('-----> Invalid vloop value');
            return
        end
    end
    %
    sigma = - sign(equil.ptBPHI(1,1)*equil.psi_apRp(end));
    %
    id_ohm = input('Please specify a name for the ohm structure : [VLOOP]','s');
    if isempty(id_ohm),
        id_ohm = 'VLOOP';
    end
    ohm.id = id_ohm;
    %
    psin = equil.psi_apRp/equil.psi_apRp(end);
    ohm.rho = psi2rho_jd(equil,psin);%Arbitrary normalized minor radius
    ohm.epsi = sigma*vloop*ones(1,length(ohm.rho))/(2*pi*equil.Rp);%(V/m)
    %
elseif o_opt == 1,% % ohm from E/ED
    %
    epsi = input('Please specify the value for E/ED (Dreicer field) : ');
    if isempty(epsi) | ~isnumeric(epsi),
        disp('-----> Invalid vloop value');
        return
    end
    %
    ohm = ohm_flat(equil,epsi);
    %
    id_ohm = input('Please specify a name for the ohm structure : [ED]','s');
    if isempty(id_ohm),
        id_ohm = 'ED';
    end
    ohm.id = id_ohm;
    %    
end
%    
