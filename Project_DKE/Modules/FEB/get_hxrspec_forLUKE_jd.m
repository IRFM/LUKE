function [hxrspec,hxrparam] = get_hxrspec_forLUKE_jd(basestr,shot,data_path)
%
if ~(strcmp(basestr,'TS') || strcmp(basestr,'WEST')),
    error('Function valid for TS or WEST for now')
end
%
dkepath = load_structures_yp('dkepath','','');
opt_gui = false;
select.style = struct;
scheduler.remnum = iselect_jd(dkepath.remprofiles,'Remote calculation mode (mdce_remote): ',opt_gui,select.style,1)-1;
if scheduler.remnum > 1,
    remote = dkepath.remote(scheduler.remnum);
    %remote.link_mode=1;%ssh bridge otherwise 0 (direct ssh)
    job = matstandardjob_jd('runmat');
    [err,job,shotdate] = matremote_jd('tsdate',{shot},remote,job);%find remotely the shot date
else
    disp('WARNING: direct connexion to the CEA network is necessary');
    [shotdate] = tsdate(shot);
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

hxrspec.alpha_hxr(hxrspec.alpha_hxr < 0) = hxrspec.alpha_hxr(hxrspec.alpha_hxr < 0) + 2*pi;
hxrspec.alpha_hxr(hxrspec.alpha_hxr > 2*pi) = hxrspec.alpha_hxr(hxrspec.alpha_hxr > 2*pi) - 2*pi;
%
hxrparam.mfactor = 1;%For the magnetic equilibrium
hxrparam.method = 'spline';%For the magnetic equilibrium in the HXR calculations
hxrparam.ns = 3000;%for chord integration
hxrparam.n_gauleg = 35;%Number of Legendre polynomials for projections of cross-section and electron velocity distribution
hxrparam.epsi_gauleg = 1e-14;%Accuracy of the Legendre projection
%
hxrparam.kphot = hxrspec.kphot;
hxrparam.kmin = hxrspec.kmin;
hxrparam.kmax = hxrspec.kmax;
%
if nargout == 0,
    %
    if nargin < 3,
        data_path = './';
    end  
    %
    data_file = ['HXR_',basestr,'_',num2str(shot),'.mat'];
    %
    save([data_path,data_file],'hxrspec','hxrparam');
    %
end
