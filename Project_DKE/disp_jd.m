function [xpsin_out_ft,xMNperp_ft,xM3eps_pmz_ft,xpsin_out_ht,xMNperp_ht,xM3eps_pmz_ht,xM3Pflow_xyz_ht,xMPabs_at,xM3Pflow_pmz_ht] = ...
    disp_jd(xpsin,xB,xTe,xne,xNpar,omega,knr,nrt_nr,nrt_fr,kflag,GNperp,nn_nr,tol_ht,nd_ht);
%
% This function calls R2D2 and solves the wave equation for relativistic
% and non-relativistic maxwellian distribution, using the Hermitian
% part of the Dispersion Tensor. The outputs are Nperp and the polarization
% elements. Also the power flux and the power dissipated are calculated
% from the Hermitian and Anto-hermitian parts of the Dispersion Tensor
% respectively. For comparison, Nperp amd the polarization are also 
% calculated using the full Dispersion Tensor.
%
%   INPUTS:
%
%       - tokamak: 
%       - xpsin: 
%       - rho0: 
%       - xtheta: 
%       - xNpar: 
%       - omega: 
%       - knr: 
%       - nrt_nr: 
%       - nrt_fr: 
%       - kflag: 
%       - GNperp: 
%       - nn_nr:
%
%   OUTPUTS:    
%
%       - xpsin_out_ft: 
%       - xMNperp_ft: 
%       - xM3eps_pmz_ft: 
%       - xpsin_out_ht: 
%       - xMNperp_ht: 
%       - xM3eps_pmz_ht: 
%       - xMPflow_ht: 
%       - xMPabs_at:
%
% by Joan Decker 9/25/03
%   Code R2D2 by Abhay Ram
% 
% Updated 10/14/03
%
if nargin < 14
    nd_ht = 11;
end
if nargin < 13
    tol_ht = 0.2;
end
%
exename = 'R2D2f.exe';
%
pathname = getpath_jd(exename);%
%
root1 = [];
vect = [];
%
wd = cd;
eval(['cd ',pathname]);
%
while (isempty(root1) | isempty (vect)) & tol_ht < 1
%
%    makedisp_simparam_jd(xpsin,xB,xTe,xne,xNpar,omega,knr,nrt_nr,nrt_fr,kflag,GNperp,nn_nr,tol_ht,nd_ht);%
    [root_c,root_nr,root_r] = ...
    disp_new(xpsin,xB,xTe,xne,xNpar,omega,knr,nrt_nr,nrt_fr,kflag,GNperp,nn_nr,tol_ht,nd_ht);%
%
%    [s,w] = execute_jd(exename);
%
    if knr == 1
        pf = [];
        load pf.m -ascii
        root1 = root_nr;
        %nr1 = [];
        %load nr1.m -ascii
        %root1 = nr1;
        vect = pf;
    else
        pfr = [];
        load pfr.m -ascii
        root1 = root_nr;
        %r1 = [];
        %load r1.m -ascii
        %root1 = r1;
        vect = pfr;
    end
    tol_ht = tol_ht*1.2;
end
if isempty(root1)
    error('The ft root was not found')
elseif isempty(vect)
    error('The ht root was not found')
end
%
[nr_ft,nn] = size(root1);
%
xpsin_out_ft = root1(:,1)';
%
%nn = (nn-1)/2;
%
%xMNperp_re_ft = root1(:,2:2:2*nn);
%xMNperp_im_ft = root1(:,3:2:2*nn+1);
%
%xMNperp_ft = xMNperp_re_ft + i*xMNperp_im_ft;
xMNperp_ft = root1;
%
if knr == 0
    pr = [];
    load pr.m -ascii
    difu = pr;
else
    pn = [];
    load pn.m -ascii
    difu = pn;
end

nd_ft = size(difu,1);

%
for in = 1:nn
    xMepsp_re_ft(:,in) = difu(in:nn:nd_ft,4); 
    xMepsp_im_ft(:,in) = difu(in:nn:nd_ft,5); 
    xMepsm_re_ft(:,in) = difu(in:nn:nd_ft,6); 
    xMepsm_im_ft(:,in) = difu(in:nn:nd_ft,7); 
    xMepsz_re_ft(:,in) = difu(in:nn:nd_ft,8); 
    xMepsz_im_ft(:,in) = difu(in:nn:nd_ft,9); 
end

xMepsp_abs_ft = abs(xMepsp_re_ft + i*xMepsp_im_ft);
xMepsm_abs_ft = abs(xMepsm_re_ft + i*xMepsm_im_ft);
xMepsz_abs_ft = abs(xMepsz_re_ft + i*xMepsz_im_ft);
%
xMeps_norm_ft = sqrt(xMepsp_abs_ft.^2 + xMepsm_abs_ft.^2 + xMepsz_abs_ft.^2);
%
xMepsp_norm_ft = (xMepsp_re_ft + i*xMepsp_im_ft)./xMeps_norm_ft;
xMepsm_norm_ft = (xMepsm_re_ft + i*xMepsm_im_ft)./xMeps_norm_ft;
xMepsz_norm_ft = (xMepsz_re_ft + i*xMepsz_im_ft)./xMeps_norm_ft;
%
xM3eps_pmz_ft = zeros(nr_ft,nn,3);
%
xM3eps_pmz_ft(:,:,1) = xMepsp_norm_ft;
xM3eps_pmz_ft(:,:,2) = xMepsm_norm_ft;
xM3eps_pmz_ft(:,:,3) = xMepsz_norm_ft;
%
np_ht = size(vect,1);
%
xpsin_out_ht = vect(1:nn:np_ht,1)';
nr_ht = length(xpsin_out_ht);
%
for in = 1:nn
    xMNperp_re_ht(:,in) = vect(in:nn:np_ht,2);
    xMNperp_im_ht(:,in) = vect(in:nn:np_ht,3);
    xMPflow_re_ht_x(:,in) = vect(in:nn:np_ht,4);
    xMPflow_im_ht_x(:,in) = vect(in:nn:np_ht,5);
    xMPflow_re_ht_y(:,in) = vect(in:nn:np_ht,6);
    xMPflow_im_ht_y(:,in) = vect(in:nn:np_ht,7);
    xMPflow_re_ht_z(:,in) = vect(in:nn:np_ht,8);
    xMPflow_im_ht_z(:,in) = vect(in:nn:np_ht,9);
    xMPabs_re_at_x(:,in) = vect(in:nn:np_ht,10);
    xMPabs_im_at_x(:,in) = vect(in:nn:np_ht,11);
    xMepsx_re_ht(:,in) = vect(in:nn:np_ht,12); 
    xMepsx_im_ht(:,in) = vect(in:nn:np_ht,13); 
    xMepsy_re_ht(:,in) = vect(in:nn:np_ht,14); 
    xMepsy_im_ht(:,in) = vect(in:nn:np_ht,15); 
    xMepsz_re_ht(:,in) = vect(in:nn:np_ht,16); 
    xMepsz_im_ht(:,in) = vect(in:nn:np_ht,17); 
end
%
xMNperp_ht = xMNperp_re_ht + i*xMNperp_im_ht;
%
xMPflow_ht_x = xMPflow_re_ht_x + i*xMPflow_im_ht_x;
xMPflow_ht_y = xMPflow_re_ht_y + i*xMPflow_im_ht_y;
xMPflow_ht_z = xMPflow_re_ht_z + i*xMPflow_im_ht_z;
xMPabs_at_x = xMPabs_re_at_x + i*xMPabs_im_at_x;
%
xMepsx_abs_ht = abs(xMepsx_re_ht + i*xMepsx_im_ht);
xMepsy_abs_ht = abs(xMepsy_re_ht + i*xMepsy_im_ht);
xMepsz_abs_ht = abs(xMepsz_re_ht + i*xMepsz_im_ht);
%
xMeps_norm_ht = sqrt(xMepsx_abs_ht.^2 + xMepsy_abs_ht.^2 + xMepsz_abs_ht.^2);
%
xMepsx_norm_ht = (xMepsx_re_ht + i*xMepsx_im_ht)./xMeps_norm_ht;
xMepsy_norm_ht = (xMepsy_re_ht + i*xMepsy_im_ht)./xMeps_norm_ht;
xMepsz_norm_ht = (xMepsz_re_ht + i*xMepsz_im_ht)./xMeps_norm_ht;
%
xMepsp_norm_ht = (xMepsx_norm_ht + i*xMepsy_norm_ht)/sqrt(2);
xMepsm_norm_ht = (xMepsx_norm_ht - i*xMepsy_norm_ht)/sqrt(2);
%
xM3eps_pmz_ht = zeros(nr_ht,nn,3);
%
xM3eps_pmz_ht(:,:,1) = xMepsp_norm_ht;
xM3eps_pmz_ht(:,:,2) = xMepsm_norm_ht;
xM3eps_pmz_ht(:,:,3) = xMepsz_norm_ht;
%
xM3Pflow_xyz_ht(:,:,1) = xMPflow_ht_x.*abs(xMepsx_norm_ht).^2;
xM3Pflow_xyz_ht(:,:,2) = xMPflow_ht_y.*abs(xMepsx_norm_ht).^2;
xM3Pflow_xyz_ht(:,:,3) = xMPflow_ht_z.*abs(xMepsx_norm_ht).^2;
%
xM3Pflow_pmz_ht = zeros(nr_ht,nn,3);
%
xM3Pflow_pmz_ht(:,:,1) = (xM3Pflow_xyz_ht(:,:,1) + i*xM3Pflow_xyz_ht(:,:,2))/sqrt(2);
xM3Pflow_pmz_ht(:,:,2) = (xM3Pflow_xyz_ht(:,:,1) - i*xM3Pflow_xyz_ht(:,:,2))/sqrt(2);
xM3Pflow_pmz_ht(:,:,3) = xM3Pflow_xyz_ht(:,:,3);
%
xMPabs_at = xMPabs_at_x.*abs(xMepsx_norm_ht).^2;
%
eval(['cd ',wd]);
