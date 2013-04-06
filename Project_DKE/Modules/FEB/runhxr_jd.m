function hxrdata = runhxr_jd(data,basestr,hxr_file,exp_file,workdir,texp,opt_save)
%
% This function calculates the hard X-ray emisssion from LUKE results
%
if nargin < 7,
    opt_save = 0;
end
if nargin < 6,
    texp = NaN;
end
if nargin < 5,
    workdir = '';
end
%
if isstruct(data),
    %
    % data from input structure
    %
    if isfield(data,'lukestructs'),
        data = data.lukestructs;
    end
    %
    if isfield(data,'luke_input'),
        equil = data.luke_input.equil;
        dkeparam = data.luke_input.dkeparam;
        dkedisplay = data.luke_input.dkedisplay;
    else
        equil = data.equil;
        dkeparam = data.dkeparam;
        dkedisplay = data.dkedisplay;
    end
    %
    if isfield(data,'output'),% case of LUKE_DATA file
        Zcurr = data.output.Zcurr;
        dke_out = data.output.dke_out;
        equilDKE = data.output.equilDKE;
        radialDKE = data.output.radialDKE;
        momentumDKE = data.output.momentumDKE;
        mksa = data.output.mksa;
        Zmomcoef = data.output.Zmomcoef;
        if isfield(data,'external'),
            external = data.external;
        else
            external = '';
        end
    else % case of LUKE_RESULTS file
        Zcurr = data.Zcurr;
        dke_out = data.dke_out;
        equilDKE = data.equilDKE;
        radialDKE = data.radialDKE;
        momentumDKE = data.momentumDKE;
        mksa = data.mksa;
        Zmomcoef = data.Zmomcoef;
        external = '';
    end        
    %
else
    %
    % data from file
    %
    external = '';
    %
    load(data,'equil','dkeparam','dkedisplay','Zcurr','dke_out','equilDKE','radialDKE','momentumDKE','mksa','Zmomcoef','external');
    %
end    
%
clear data
%
if ~isfield(Zmomcoef,'Ec_ref'),
    if isfield(mksa,'Ec_ref'),
        Zmomcoef.Ec_ref = mksa.Ec_ref;
    else
        error('Kinetic energy data missing. Please correct manually.')
    end
end    
%
% load HXR camera spec
%
load(hxr_file,'hxrspec','hxrparam');
%
if ~exist('hxrspec','var'),%old spec file
    %
    load(hxr_file,'hxr','hxrparam');
    hxrspec = hxr;
    clear hxr %to avoid name conflict
    %
end
%
nc = length(hxrspec.beta_hxr);% number of chords
%
% load and treat HXR experimental results
%
if all(ischar(exp_file)),
    %
    if isfield(external,'hxr'),
        %
        t = external.hxr.t;
        energy = external.hxr.energy;
        hxr = external.hxr.counts;
        %filter_thickness = external.hxr.filter_thickness;
        %filter_material = external.hxr.filter_material;
        %
        if isfield(external,'beta')
            beta = external.beta;
        else
            beta = NaN(1,size(hxr,3));
        end
        %
        if iscell(t),%old TCV data file
            t = t{ishot};
            energy = energy{ishot};
            hxr = hxr{ishot};
            %filter_thickness = filter_thickness{ishot};
            %filter_material = filter_material{ishot};
        end
        %
    else
        %
        % load HXR experimental results
        %
        if isfield(equil,'info') && isfield(equil.info,'shotnum'),
            shotnum = equil.info.shotnum;
        elseif isfield(equil,'id'),
            idsep = find(equil.id == '_');
            shotnum = equil.id(idsep(1)+1:idsep(2)-1); 
        else
            disp('-----> Shot number information missing');
            return
        end
        %
        if ~isempty(exp_file),% hxr experimental data from file
            %
            load(exp_file,'shot','energy','hxr','t','beta');%,'filter_thickness','filter_material'
            %
            ishot = find(shot == str2num(shotnum));
            %
            if isempty(ishot) || ~exist('hxr','var'),
                disp(['-----> hxr data not found for shot :',shotnum]);
                disp(quitmsg)
                return
            end
            %
            if length(ishot) > 1,
                disp(['-----> WARNING : Several entries are found for shot :',shotnum,', first entry selected']);
                ishot = ishot(1);
            end
            %
            clear exp_file
            %
            if iscell(t),%old TCV data file
                t = t{ishot};
                energy = energy{ishot};
                hxr = hxr{ishot};
                %filter_thickness = filter_thickness{ishot};
                %filter_material = filter_material{ishot};
            end
            %
            clear ishot
            %
        else % hxr experimental data fromdatabase
            %
            [energy,hxr,t,beta] = collect_hxr_forLUKE_jd(basestr,str2num(shotnum));%,opt,data_path,'filter_thickness','filter_material'
            %
        end
        %
        clear shotnum
        %
        if ~exist('beta','var') || (isscalar(beta) && isnan(beta)),
            beta = NaN(1,size(hxr,3));
        end
        %
    end
    %
    % test angles
    %
    beta(beta > pi) = 2*pi - beta(beta > pi);% correct beta definition        
    %
    if length(beta) ~= nc,
        error('number of chords mismatch')
    end
    if ~all(isnan(beta)) && any(abs(beta - hxrspec.beta_hxr) > 1e-15),
        error('angle of chords mismatch')
    end
    %
    energy = energy.';
    %
    % time sample of experimental data
    %
    if isnan(texp),
        if isfield(equil,'info') && isfield(equil.info,'t1') && isfield(equil.info,'t2'),
            t1 = equil.info.t1;
            t2 = equil.info.t2;
        elseif isfield(equil,'external') && isfield(equil.external,'id'),
            idsep = find(equil.external.id == '_');
            t1 = str2num(equil.external.id(idsep(3)+1:idsep(4)-1));
            t2 = str2num(equil.external.id(idsep(4)+1:idsep(5)-1));
        else
            disp(['-----> hxr averaging time span not found']);
            disp(quitmsg)
            return
        end
    else
        t1 = texp(1);
        t2 = texp(2);
    end
    %
    it1 = find(t >= t1,1,'first');
    it2 = find(t <= t2,1,'last');
    %
    if isempty(it1) || isempty(it2),% no data available in averaging range
        %
        hxrexp = NaN*ones(length(energy),nc);
        dt = 1;
        %
    else        
        %
        % time averaging
        %
        hxrexp = squeeze(sum(hxr(it1:it2,:,:)));
        dt = t(it2) - t(it1);
        hxrexp = hxrexp/dt;%taux de comptage
        %
        % incremental contribution of energy canal
        %
        hxrexp = hxrexp - [hxrexp(2:end,:);zeros(1,size(hxrexp,2))];% raw data is all hits above given energy
        %
        hxrexp(:,any(hxrexp < 0)) = NaN;% hxrexp cannot be negative - probably malfunctioning chords
        %
    end
    %
    hxrspec.kdiag_hxr = [energy(1:end-1),hxrspec.kdiag_hxr(1,end);energy(2:end),hxrspec.kdiag_hxr(2,end)];%redefine kdiag according to measurements
    %
else
    %
    filter_thickness = NaN;
    filter_material = NaN;
    %
    energy = [hxrspec.kdiag_hxr(1,1:end-1),hxrspec.kdiag_hxr(2,end-1)];
    hxrexp = NaN*ones(length(energy),nc);
    dt = 1;
    %
end
%
[Zbremchord,equilHXR] = bremchord_dke_yp(dkeparam,dkedisplay,equil,radialDKE,Zcurr,hxrspec,hxrparam);
%
Zbremchord.mask_hxr(:) = 1;%so that the bremmstrahlung is calculated at all positions, for display purposes
%
[Zbremplasma] = bremsstrahlung_dke_yp(dkeparam,dkedisplay,equilHXR,radialDKE,mksa,momentumDKE,Zmomcoef,dke_out,Zbremchord,hxrspec,hxrparam);
%
[Zbremdiag] = bremdiag_dke_yp(Zbremplasma,hxrspec,hxrparam,dt);
%
% Save results
%
if opt_save,
    id_simul = dke_out.simul.id;
    filename = [workdir,'HXR_RESULTS_',id_simul,'.mat'];
    save(filename,'Zbremchord','Zbremplasma','Zbremdiag','equilHXR','hxrexp');
    disp(['HXR data saved in file ',filename])
end
%
hxrdata.Zbremchord = Zbremchord;
hxrdata.Zbremplasma = Zbremplasma;
hxrdata.Zbremdiag = Zbremdiag;
hxrdata.equilHXR = equilHXR;
hxrdata.hxrexp = hxrexp;
%




