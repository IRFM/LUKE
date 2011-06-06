function irunhxr_jd(opt_gui,workdir,basestr,output,external,id_simul,equil,dkeparam,dkedisplay)
%
% This function calculates the hard X-ray emisssion from LUKE results
%
quitmsg = '-----> HXR calculation aborted';
warning off
%
% load LUKE results if needed
%
if nargin < 9,
    %
    % data from LUKE_RESULTS_*.mat file
    %
    [luke_file,luke_path] = uigetfile('LUKE_RESULTS_*.mat','Please select the LUKE RESULTS file',output);
    %
    if luke_file == 0,
        disp('-----> No LUKE RESULTS file specified.')
        disp(quitmsg)
        return
    end  
    load([luke_path,luke_file],'id_simul','equil','dkeparam','dkedisplay','Zcurr','dke_out','equilDKE','radialDKE','momentumDKE','mksa','Zmomcoef');
    %
else
    %
    % data from output structure
    %
    Zcurr = output.Zcurr;
    dke_out = output.dke_out;
    equilDKE = output.equilDKE;
    radialDKE = output.radialDKE;
    momentumDKE = output.momentumDKE;
    mksa = output.mksa;
    Zmomcoef = output.Zmomcoef;
    %
end
%
if ~isfield(Zmomcoef,'Ec_ref'),
    if isfield(mksa,'Ec_ref'),
        Zmomcoef.Ec_ref = mksa.Ec_ref;
    else
        error('Kinetic energy data missing. Please correct manually.')
    end
end    
%
if isfield(equil,'info') && isfield(equil.info,'shotnum'),
    shotnum = equil.info.shotnum;
elseif isfield(equil,'id'),
    idsep = find(equil.id == '_');
    shotnum = equil.id(idsep(1)+1:idsep(2)-1); 
else
    shotnum = '';
end
%
% load HXR camera spec
%
if strcmp(basestr,'TS') && ~isempty(shotnum) && exist('tsdate','file') && input_dke_yp('Do you want to load the HXR camera spec automatically (y/n)','y',{'y','n'}) == 'y',
    %
    [hxrspec,hxrparam] = get_hxrspec_forLUKE_jd('TS',str2num(shotnum));
    %
else
    %
    hxr_file = which(['HXR_',basestr,'.mat']);
    [hxr_file,hxr_path] = igetfile_jd(opt_gui,'HXR_*.mat','Please select the HXR camera spec file',hxr_file);
    if hxr_file == 0,
        disp('-----> No HXR camera spec file specified.')
        disp(quitmsg)
        return
    end
    %
    load([hxr_path,hxr_file],'hxr','hxrparam');
    %
    hxrspec = hxr;
    clear hxr %to avoid name conflict
    %
end
%
nc = length(hxrspec.beta_hxr);% number of chords
%
% display options
%
p_opt = input_dke_yp('Option for output figures? -1 (nothing), 0 (print), 1 (print and save), 2 (save)',-1,-1:2,'',[1,1]);
%
d_opt = input_dke_yp('Do you want to plot the chords? [y/n]','n',{'y','n'},'',[1,1]);
%
if strcmp(d_opt,'y'),
    %
    figure(1),clf
    %
    plot(equil.ptx' + equil.Rp,equil.pty');hold on
    %
    L = [-2:0.1:2];%Chord length
    R = zeros(nc,length(L));
    Z = zeros(nc,length(L));
    for chord = 1:nc,
           R(chord,:) = hxrspec.R_hxr(chord) + L*sin(hxrspec.beta_hxr(chord))*cos(hxrspec.alpha_hxr(chord));
           Z(chord,:) = hxrspec.Z_hxr(chord) + L*cos(hxrspec.beta_hxr(chord));
    end
    plot(R',Z'),
    plot(R(1),Z(1),'*')
    hold off
    axis('equal')
    xlabel('R(m)');ylabel('Z(m)');title(basestr)
    print_jd(p_opt,[basestr,'_HXR'],1)
end 
%
% load and treat HXR experimental results
%
if isfield(external,'hxr'),
    n_opt = input_dke_yp(['Option for hxr experimental data? 0 (structure external), 1 (data file), 2 (',basestr,' database) -1 (no exp. data)'],0,-1:2,'',[1,1]);
else
    n_opt = input_dke_yp(['Option for hxr experimental data? 1 (data file), 2 (',basestr,' database) -1 (no exp. data)'],-1,[-1,1,2],'',[1,1]);
end
%
if n_opt == 0,% structure external
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
elseif n_opt > 0,
    if isempty(shotnum)
        disp('-----> Shot number information missing');
        return
    end
    %
    if n_opt == 1,% hxr experimental data from file
        %
        [data_file,data_path] = igetfile_jd(opt_gui,'*.*','Please select the hxr experimental data file :');
        %
        if data_file == 0,
            disp(quitmsg)
           return
        end
        %
        load([data_path,data_file],'shot','energy','hxr','t','beta');%,'filter_thickness','filter_material'
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
        clear data_path data_file
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
    elseif n_opt == 2,% hxr experimental data fro database
        %
        opt.R = input_dke_yp('Pile-up rejection (TS only)? (0) no, (1) yes)',1,[0,1],'',[1,1]);
        opt.V = input_dke_yp('Real time diagnostic (TS only)? (0) no, (1) yes)',1,[0,1],'',[1,1]);
        %
        [energy,hxr,t,beta] = collect_hxr_forLUKE_jd(basestr,str2num(shotnum),opt);%,'data_path','filter_thickness','filter_material'
        %
    end
    %
    if ~exist('beta','var') || (isscalar(beta) && isnan(beta)),
        beta = NaN(1,size(hxr,3));
    end
    %        
else
    energy = NaN;
end
%
if any(isnan(energy)),% no or useless exp. data
    %
    filter_thickness = NaN;
    filter_material = NaN;
    %
    %energy = [hxrspec.kdiag_hxr(1,1:end-1),hxrspec.kdiag_hxr(2,end-1)];
    hxrexp = NaN*ones(length(energy),nc);
    dt = 1;
else
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
    if isfield(equil,'info') && isfield(equil.info,'t1') && isfield(equil.info,'t2'),
        t1 = equil.info.t1;
        t2 = equil.info.t2;
    elseif isfield(external,'id') && length(find(external.id == '_')) >= 5,
        idsep = find(external.id == '_');
        t1 = str2num(external.id(idsep(3)+1:idsep(4)-1));
        t2 = str2num(external.id(idsep(4)+1:idsep(5)-1));
    else
        t1 = NaN;
        t2 = NaN;
    end
    %
    t1 = input_dke_yp('Initial time for TCV HXR data averaging',t1,[0;Inf],'',[1,1]);
    t2 = input_dke_yp('Final time for TCV HXR data averaging',t2,[0;Inf],'',[1,1]);
    %
    it1 = find(t >= t1,1,'first');
    it2 = find(t <= t2,1,'last');
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
 end        
%
hxrspec.kdiag_hxr = [energy(1:end-1),hxrspec.kdiag_hxr(1,end);energy(2:end),hxrspec.kdiag_hxr(2,end)];%redefine kdiag according to measurements
%
% HXR emission calculations
%
[Zbremchord,equilHXR] = bremchord_dke_yp(dkeparam,dkedisplay,equil,radialDKE,Zcurr,hxrspec,hxrparam);
%
Zbremchord.mask_hxr(:) = 1;%so that the bremmstrahlung is calculated at all positions, for display purposes
%
[Zbremplasma] = bremsstrahlung_dke_yp(dkeparam,dkedisplay,equilHXR,radialDKE,mksa,momentumDKE,Zmomcoef,dke_out,Zbremchord,hxrspec,hxrparam);
%
[Zbremdiag] = bremdiag_dke_yp(Zbremplasma,hxrspec,hxrparam,dt);
%
%For display HXR
%
d_opt = input('Do you want to plot the results? [y/n] : ','s');
if strcmp(d_opt,'y'),
    %
    c_opt = input(['Focus on chord? (1-',num2str(nc),') [1] : ']);
    if isempty(c_opt),
        c_opt = 1;
    end
    if ~isnumeric(c_opt) | ~any(c_opt == 1:nc),
        disp('-----> Invalid chord number');
        disp(quitmsg)
        return
    end
    %
    r_opt = input('Local bremsstrahlung at radial position? (0<rho<1) [0.5] : ');
    if isempty(r_opt),
        r_opt = 0.5;
    end
    if ~isnumeric(r_opt) | r_opt < 0 | r_opt > 1,
        disp('-----> Invalid radial position');
        disp(quitmsg)
        return
    end
    %
    t_opt = input('Local bremsstrahlung at poloidal position? (0<theta<360) [0] : ');
    if isempty(t_opt),
        t_opt = eps;
    end
    if ~isnumeric(t_opt) | t_opt < 0 | t_opt > 360,
        disp('-----> Invalid poloidal position');
        disp(quitmsg)
        return
    end
    %
    k_opt = input(['Local bremsstrahlung at energy? (',num2str(Zbremdiag.kfit),') [',num2str(Zbremdiag.kfit(1)),'] : ']);
    if isempty(k_opt),
        k_opt = Zbremdiag.kfit(1);
    end
    if ~isnumeric(t_opt) | ~any(k_opt == Zbremdiag.kfit),
        disp('-----> Invalid energy');
        disp(quitmsg)
        return
    else
        ik = find(k_opt == Zbremdiag.kfit);
    end
    %
    bremchorddisplay_dke_yp(equilHXR,Zbremchord,c_opt,p_opt,equil.id);
    %
    if ~isempty(r_opt) & ~isempty(t_opt) & ~isempty(k_opt)
        bremlocaldisplay_dke_yp(dkeparam,dkedisplay,equilDKE,momentumDKE,Zmomcoef,radialDKE,dke_out,mksa,Zbremchord,Zbremplasma,r_opt,t_opt,k_opt,p_opt,equil.id)
    end
    %
    bremdiagdisplay_dke_yp(hxrspec,Zbremchord,Zbremplasma,Zbremdiag,c_opt,k_opt,p_opt,equil.id,hxrexp(ik,1:nc))
end
%
s_opt = input('Do you want to save the HXR output data? [y/n] : ','s');
if strcmp(s_opt,'y'),
    sd = pwd;
    cd(workdir);
    [save_file,save_path] = uiputfile(['HXR_RESULTS_',id_simul,'*.mat'],'Please provide the RESULTS file name',['HXR_RESULTS_',id_simul,'.mat']);
    %
    if save_file == 0,
        disp('-----> No file name specified, HXR output data not saved.')
    else
        save([save_path,save_file],'Zbremchord','Zbremplasma','Zbremdiag','equilHXR','hxrexp');
        disp('-----> The output data is saved')
    end
    cd(sd);
end 
%




