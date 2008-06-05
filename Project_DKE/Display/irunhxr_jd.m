function irunhxr_jd(workdir,basestr,filename,id_simul,equil,dkeparam,dkedisplay,output)
%
% This function calculates the hard X-ray emisssion from LUKE results
%
if nargin < 1,
    workdir = '.';
end
if nargin < 2,
    basestr = '';
end
if nargin < 3,
    filename = workdir;
end
%
quitmsg = '-----> HXR calculation aborted';
warning off
%
% load LUKE results if needed
%
if nargin < 8,
    %
    [luke_file,luke_path] = uigetfile('LUKE_RESULTS_*.mat','Please select the LUKE RESULTS file',filename);
    %
    if luke_file == 0,
        disp('-----> No LUKE RESULTS file specified.')
        disp(quitmsg)
        return
    end  
    load([luke_path,luke_file],'id_simul','equil','dkeparam','dkedisplay','Zcurr','dke_out','equilDKE','radialDKE','momentumDKE','mksa');
    %
else
    %
    Zcurr = output.Zcurr;
    dke_out = output.dke_out;
    equilDKE = output.equilDKE;
    radialDKE = output.radialDKE;
    momentumDKE = output.momentumDKE;
    mksa = output.mksa;
    %
end
%
% load HXR camera spec
%
hxr_file = which(['HXR_',basestr,'.mat']);
[hxr_file,hxr_path] = uigetfile('HXR_*.mat','Please select the HXR camera spec file',hxr_file);
if hxr_file == 0,
    disp('-----> No HXR camera spec file specified.')
    disp(quitmsg)
    return
end
load([hxr_path,hxr_file],'hxr','hxrparam');
hxrspec = hxr;
clear hxr%to avoid name conflict
%
p_opt = input('Option for output figures? -1 (nothing), 0 (print), 1 (print and save), 2 (save) [-1] : ');
if isempty(p_opt) | ~isnumeric(p_opt) | ~any(p_opt == [0,1,2]),
    p_opt = -1;
end
%
d_opt = input('Do you want to plot the chords? [y/n] : ','s');
nc = length(hxrspec.beta_hxr);
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
           R(chord,:) = hxrspec.R_hxr(chord) + L*cos(hxrspec.beta_hxr(chord) - pi/2);
           Z(chord,:) = hxrspec.Z_hxr(chord) + L*sin(hxrspec.beta_hxr(chord) - pi/2);
    end
    plot(R',Z'),
    plot(R(1),Z(1),'*')
    hold off
    axis('equal')
    xlabel('R(m)');ylabel('Z(m)');title(basestr)
    print_jd(p_opt,[basestr,'_HXR'],1)
end 
%
% load HXR results
%
if strcmp(basestr,'TCV'),% TCV launching data
%     if isfield(equil.info,'shotime');
%         shotime = equil.info.shotime;
%     else
%         disp('-----> Shot time information missing');
%         return
%     end
%     %
    n_opt = input('Option for hxr experimental data? 0 (no exp. data), 1 (data file), 2 (TCV database) [0] : ');
    if isempty(n_opt),
        n_opt = 0;
    end
    if ~isnumeric(n_opt) | ~any(n_opt == [0,1,2]),
        disp('-----> Invalid hxr experimental data option');
        disp(quitmsg)
        return
    end
    %
    if n_opt > 0,
        if isfield(equil.info,'shotnum');
            shotnum = equil.info.shotnum;
        else
            disp('-----> Shot number information missing');
            return
        end
    end
    %
    if n_opt == 1,% hxr experimental data from file
        %
        [data_file,data_path] = uigetfile('*.*',['Please select the hxr experimental data file :']);
        %
        if data_file == 0,
            disp(quitmsg)
           return
        end
        %
        load([data_path,data_file],'shot','energy','hxr','t','filter_thickness','filter_material');
        %
        ishot = find(shot == str2num(shotnum));
        %
        if isempty(ishot) | ~exist('hxr','var'),
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
    elseif n_opt == 2,% hxr experimental data from TCV database
        %
        shot = str2num(shotnum);
        collect_hxr;
        ishot = 1;
        %
    else
        t = {NaN};
        energy = {NaN};
        hxr = {NaN};
        filter_thickness = {NaN};
        filter_material = {NaN};
        ishot = 1;
    end
    %
    t = t{ishot};
    energy = energy{ishot};
    hxr = hxr{ishot};
    filter_thickness = filter_thickness{ishot};
    filter_material = filter_material{ishot};
    %
    %it = min(find(t > str2num(shotime)));
    it1 = min(find(t > equil.info.t1));
    it2 = max(find(t < equil.info.t2));
    hxrexp = squeeze(sum(hxr(it1:it2,:,:)));
    dt = t(it2) - t(it1);
    %
    if isnan(energy),
        energy = hxrspec.kphot;
        hxrexp = NaN*ones(length(energy),nc);
        dt = 1;
    else
        energy = energy.';
    end
    %
    hxrspec.kphot = sort([energy,(energy(1:end-1) + energy(2:end))/2]);
    hxrspec.kdiag_hxr = [energy(1:end-1),(energy(1)+energy(2))/2;energy(2:end),(energy(end)+energy(end-1))/2];
    %
else
    %
    disp(['-----> hxr experimental data not implemented yet for :',basestr]);
    disp(quitmsg)
    return    
    %
end
%
[Zbremchord,equilHXR] = bremchord_dke_yp(dkeparam,dkedisplay,equil,radialDKE,Zcurr,hxrspec,hxrparam);
%
Zbremchord.mask_hxr(:) = 1;%so that the bremmstrahlung is calculated at all positions, for display purposes
%
[Zbremplasma] = bremsstrahlung_dke_yp(dkeparam,dkedisplay,equilHXR,radialDKE,mksa,momentumDKE,dke_out,Zbremchord,hxrspec,hxrparam);
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
        bremlocaldisplay_dke_yp(dkeparam,dkedisplay,equilDKE,momentumDKE,radialDKE,dke_out,mksa,Zbremchord,Zbremplasma,r_opt,t_opt,k_opt,p_opt,equil.id)
    end
    %
    bremdiagdisplay_dke_yp(hxrspec,Zbremchord,Zbremplasma,Zbremdiag,c_opt,k_opt,p_opt,equil.id,hxrexp(ik,1:nc)/dt)
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
        save([save_path,save_file],'Zbremchord','Zbremplasma','Zbremdiag','equilHXR');
        disp('-----> The output data is saved')
    end
    cd(sd);
end 
%




