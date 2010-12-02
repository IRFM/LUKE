function [hxrspec,hxrparam] = get_hxrspec_forLUKE_jd(basestr,shot,data_path)
%
if ~strcmp(basestr,'TS'),
    error('Function valid for TS only for now')
end
%
shotdate = tsdate(shot);
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
hxrparam.mfactor = 1;%For the magnetic equilibrium
hxrparam.method = 'spline';%For the magnetic equilibrium in the HXR calculations
hxrparam.ns = 3000;%for chord integration
hxrparam.n_gauleg = 35;%Number of Legendre polynomials for projections of cross-section and electron velocity distribution
hxrparam.epsi_gauleg = 1e-14;%Accuracy of the Legendre projection
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
