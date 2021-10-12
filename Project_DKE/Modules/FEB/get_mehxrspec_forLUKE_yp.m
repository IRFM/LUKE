function [hxrspec,hxrparam] = get_mehxrspec_forLUKE_yp(basestr,shot,data_path,scheduler,hxrparam)
%
% Parameters for MEHXR diagnostic
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
    if ~strcmp(basestr,'WEST')
        %
        error('The function get_mehxrspec_forLUKE_jd.m is valid for WEST only')
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
        disp('WARNING: direct connexion to the CEA network is necessary');
        [shotdate] = tsdate(shot);
    end
else
    %
    if ~strcmp(basestr,'WEST')
        %
        disp('WARNING : The function get_mehxrspec_forLUKE_yp.m is valid for WEST only. Empty structures are returned.')
        hxrspec = '';
        hxrparam = '';
        return;
        %
    end
    %
    % [shotdate] = remote_tsdate(shot);%date of the discharge (not network dependent)
    %
end
%{
if isempty(shotdate)
    %
    cprintf('red','ERROR : shot date is empty. Problem of connection with remote_tsdate.m.')
    hxrspec = [];
    hxrparam = [];
    return
    %
end
%}
hxrspec = mehxr_tb;
%
hxrparam.kphot = hxrspec.kphot;
hxrparam.kmin = hxrspec.kmin;
hxrparam.kmax = hxrspec.kmax;
%
if nargout == 0
    %
    if nargin < 3
        data_path = './';
    end  
    %
    data_file = ['MEHXR_',basestr,'_',num2str(shot),'.mat'];
    %
    save([data_path,data_file],'hxrspec','hxrparam');
    %
end
