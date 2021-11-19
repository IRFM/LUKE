function [hxrspec,hxrparam] = get_hxrspec_forLUKE_jd(basestr,shot,data_path,scheduler,hxrparam)
%
% Parameters for DSPX diagnostic
%
if nargin < 5
    %
    if isempty(hxrparam)
        %
        hxrparam.mfactor = 1;%For the magnetic equilibrium
        hxrparam.method = 'spline';%For the magnetic equilibrium in the HXR calculations
        hxrparam.ns = 3000;%for chord integration
        hxrparam.n_gauleg = 35;%Number of Legendre polynomials for projections of cross-section and electron velocity distribution
        hxrparam.epsi_gauleg = 1e-14;%Accuracy of the Legendre projection
        %
    end
    %
end
%
if nargin < 4
    scheduler = '';
end
%
if nargin < 3
    data_path = './';%local path
end
%
if nargin == 4
    %
    if ~(strcmp(basestr,'TS') || strcmp(basestr,'WEST'))
        %
        cprintf('red','The function get_hxrspec_forLUKE_jd.m is valid for TS or WEST.');disp(' ')
        hxrspec = '';
        hxrparam = '';
        return;
        %
    end
    %
    opt_gui = false;
    select.style = struct;
    %
    dkepath = load_structures_yp('dkepath','','');
    %
    scheduler.remnum = iselect_jd(dkepath.remprofiles,'Remote calculation mode (mdce_remote): ',opt_gui,select.style,1)-1;
    %
    if scheduler.remnum > 1
        remote = dkepath.remote(scheduler.remnum);
        job = matstandardjob_jd('runmat');
        [err,job,shotdate] = matremote_jd('tsdate',{shot},remote,job);%find remotely the shot date
    else
        cprintf([1,0.5,0],'WARNING: direct connexion to the CEA network is necessary');disp(' ')
        [shotdate] = tsdate(shot);
    end
else
    %
    if ~(strcmp(basestr,'TS') || strcmp(basestr,'WEST'))
        %
        cprintf([1,0.5,0],'WARNING : The function get_hxrspec_forLUKE_jd.m is valid for TS or WEST only. Empty structures will be returned.');disp(' ')
        hxrspec = '';
        hxrparam = '';
        return;
        %
    end
    %
    [shotdate] = remote_tsdate(shot);%date of the discharge (not network dependent)
    %
end
%
if isempty(shotdate)
    %
    cprintf('red','ERROR : shot date is empty. Problem of connection with remote_tsdate.m. Empty structures will be returned.');disp(' ')
    hxrspec = [];
    hxrparam = [];
    return
    %
end
%
hxrspec = bremTSconvert_dke_yp(str2num(shotdate(1:2)),str2num(shotdate(4:5)),str2num(shotdate(7:10)));
%
% according to the correct definitions of alpha (-pi -> pi) and beta (0 -> pi)
%
hxrspec.alpha_hxr(hxrspec.beta_hxr > pi) = hxrspec.alpha_hxr(hxrspec.beta_hxr > pi) + pi;
hxrspec.beta_hxr(hxrspec.beta_hxr > pi) = 2*pi - hxrspec.beta_hxr(hxrspec.beta_hxr > pi);
%
hxrspec.alpha_hxr(hxrspec.beta_hxr < 0) = hxrspec.alpha_hxr(hxrspec.beta_hxr < 0) + pi;
hxrspec.beta_hxr(hxrspec.beta_hxr < 0) = - hxrspec.beta_hxr(hxrspec.beta_hxr < 0);
%
hxrspec.alpha_hxr(hxrspec.alpha_hxr < 0) = hxrspec.alpha_hxr(hxrspec.alpha_hxr < 0) + 2*pi;
hxrspec.alpha_hxr(hxrspec.alpha_hxr > 2*pi) = hxrspec.alpha_hxr(hxrspec.alpha_hxr > 2*pi) - 2*pi;
%
hxrparam.kphot = hxrspec.kphot;
hxrparam.kmin = hxrspec.kmin;
hxrparam.kmax = hxrspec.kmax;
%
if nargout == 0 %backward compatibility for irunluke_jd
    %
    if nargin < 3
        data_path = './';
    end  
    %
    data_file = ['DSPX_',basestr,'_',num2str(shot),'.mat'];
    %
    save([data_path,data_file],'hxrspec','hxrparam');
    %
end
