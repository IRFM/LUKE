function ohm = imake_ohm_jd(dkepath,basestr,equil,external,workdir,opt_gui)
%
% This function interactively builds the ohm structure
%
if nargin < 6,
	opt_gui = 1;
end
%
if nargin < 5,
	workdir = pwd;
end
%
if nargin < 4,
	external = '';
end
%
ohm = '';
%
if ~isempty(external),
    %
    i_opt = input_dke_yp(['Do you want to :\n',...
        '(0) use data loaded from the external database \n',...
        '(1) use data from an existing file \n',...
        '(2) build the ohmic data locally \n'],...
        0,{0,1,2},'Invalid selection');
    %
else
    %
    i_opt = input_dke_yp(['Do you want to :\n',...
        '(1) use data from an existing file \n',...
        '(2) build the ohmic data locally \n'],...
        2,{1,2},'Invalid selection');
    %
end
%
if i_opt == 0,% data loaded from external database
    %
    if isfield(equil.info,'shotnum');
        shotnum = equil.info.shotnum;
    else
        disp('-----> Shot number information missing');
        return
    end
    %
    if isfield(external,'shot'),
        %
        ishot = find(external.shot == str2num(shotnum));
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
    else
        ishot = 1;
    end
    %
    vloop = external.vloop(ishot);
    %
    o_opt = 0;
    %
elseif i_opt == 1,
    %
    if strcmp(basestr,'ITER'),
        %
        if isfield(equil.info,'shotnum') && isfield(equil.info,'shotime');
            shotnum = equil.info.shotnum;
            shotime = equil.info.shotime;
        else
            disp('-----> Shot information missing');
            return
        end
        %
        [data_file,data_path] = igetfile_jd(opt_gui,'*.*',['Please select the data file for shot ',shotnum,' at time ',shotime,' :'],workdir);
        %
        if data_file == 0,
            return
        end
        %
        filename = [data_path,data_file];
        %
        [pspsinT,dummy,dummy,dummy,dummy,dummy,dummy,dummy,pvloop] = textread(filename,'%n%n%n%n%n%n%n%n%n');
        %
        prho = pspsinT;
        ohm.rhotype = 't';
        %
        o_opt = 2;
        %
    else
        %
        disp('-----> function not yet implemented for this machine.')
        return
    end
    %
elseif i_opt == 2,
    %
    o_opt = input('Option for ohm calculation? 0 (VLOOP), 1 (E/ED) : [0] ');
    %
    if isempty(o_opt),
        o_opt = 0;
    end
    %
    if ~isnumeric(o_opt) || ~any(o_opt == [0,1]),
        disp('-----> Invalid ohm option');
        return
    end
    %
    if o_opt == 0,% ohm from VLOOP
        %
        vloop = input('Please specify the value for Vloop (V) : ');
        if isempty(vloop) || ~isnumeric(vloop),
            disp('-----> Invalid vloop value');
            return
        end
        %
    else
        %
        epsi = input('Please specify the value for E/ED (Dreicer field) : ');
        if isempty(epsi) || ~isnumeric(epsi),
            disp('-----> Invalid vloop value');
            return
        end        
        %
    end
end
%
if o_opt == 0,% ohm from constant VLOOP
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
elseif o_opt == 1,% ohm from E/ED
    %
    ohm = ohm_flat(equil,epsi);
    %
    id_ohm = input('Please specify a name for the ohm structure : [ED]','s');
    if isempty(id_ohm),
        id_ohm = 'ED';
    end
    ohm.id = id_ohm;
    %    
    %
elseif o_opt == 2,% ohm from varying VLOOP
    %
    sigma = - sign(equil.ptBPHI(1,1)*equil.psi_apRp(end));
    %
    id_ohm = input('Please specify a name for the ohm structure : [VLOOP]','s');
    if isempty(id_ohm),
        id_ohm = 'VLOOP';
    end
    ohm.id = id_ohm;
    %
    ohm.rho = prho;%Arbitrary normalized minor radius
    ohm.epsi = sigma*pvloop/(2*pi*equil.Rp);%(V/m)
    %    
end
%    
