function [mask_ft,mask_ht,xNperp_ft,xepol_pmz_ft,xNperp_ht,xepol_pmz_ht,xalphaphi_lin,xphiP_xyz,xphiT_xyz,...
        xepol_xyz_ft,xepol_pyk_ft,xepol_xyz_ht,xepol_pyk_ht,xphiP_pmz,xphiP_pyk,xphiT_pmz,xphiT_pyk,...
        xD_ft,xX_ft,xX_s_ft,xD_ht,xX_ht,xX_s_ht] = ...%xX_sn_ft,xX_sn_ht
    disp_kinetic_nr_jd(xB,xne,xTe,xzni,xzTi,zmi,zZi,xNpar,omega_rf,xNperp_in,display_mode,nmax,tol);
%
% Kinetic plasma dispersion solver hotdisp_dke_jd 
%
% by J. Decker
%
if nargin < 13
    tol = 1e-5;
end
if nargin < 12
    nmax = 50;
end
if nargin < 11
    display_mode = 0;
end
if nargin < 10
    xNperp_in = 1;
end
%
ns = 1 + size(xzTi,1);
nx = length(xB);
nn = 2*nmax+1;
%
if length(xNperp_in) == nx,
    guess_mode = 1;
else
    guess_mode = 0;
end    
%
xNperp_ft = zeros(1,nx);
xepol_xyz_ft = zeros(3,nx);
xepol_pmz_ft = zeros(3,nx);
xepol_pyk_ft = zeros(3,nx);
xD_ft = zeros(3,3,nx);
xX_ft = zeros(3,3,nx);
xX_s_ft = zeros(3,3,ns,nx);
%xX_sn_ft = zeros(3,3,ns,nn,nx);
%
xNperp_ht = zeros(1,nx);
xepol_xyz_ht = zeros(3,nx);
xepol_pmz_ht = zeros(3,nx);
xepol_pyk_ht = zeros(3,nx);
xD_ht = zeros(3,3,nx);
xX_ht = zeros(3,3,nx);
xX_s_ht = zeros(3,3,ns,nx);
%xX_sn_ht = zeros(3,3,ns,nn,nx);
%
xalphaphi_lin = zeros(1,nx);
xphiP_xyz = zeros(3,nx);
xphiP_pmz = zeros(3,nx);
xphiP_pyk = zeros(3,nx);
xphiT_xyz = zeros(3,nx);
xphiT_pmz = zeros(3,nx);
xphiT_pyk = zeros(3,nx);
%
xNperp_in_ft = xNperp_in;
xNperp_in_ht = real(xNperp_in);
%
h = waitbar(0,'Calculates NR kinetic Roots');
%
for ix=1:nx,
    herm_mode = 0;
    [xNperp_ft(ix),xepol_xyz_ft(:,ix),xepol_pmz_ft(:,ix),xepol_pyk_ft(:,ix),...
            xD_ft(:,:,ix),xX_ft(:,:,ix),xX_s_ft(:,:,:,ix),X_sn_ft]...%xX_sn_ft(:,:,:,:,ix)
        = hotdisp_dke_jd(xNpar(ix),omega_rf,xTe(ix),xne(ix),xzTi(:,ix),xzni(:,ix),zZi,zmi,xB(ix),xNperp_in_ft(ix),herm_mode,display_mode,nmax);%,NZ
    %
    herm_mode = 1;
    [xNperp_ht(ix),xepol_xyz_ht(:,ix),xepol_pmz_ht(:,ix),xepol_pyk_ht(:,ix),...
            xD_ht(:,:,ix),xX_ht(:,:,ix),xX_s_ht(:,:,:,ix),X_sn_ht,...%xX_sn_ht(:,:,:,:,ix)
            xalphaphi_lin(ix),xphiT_xyz(:,ix),xphiP_xyz(:,ix),xphiT_pmz(:,ix),xphiP_pmz(:,ix),xphiT_pyk(:,ix),xphiP_pyk(:,ix)]...
        = hotdisp_dke_jd(xNpar(ix),omega_rf,xTe(ix),xne(ix),xzTi(:,ix),xzni(:,ix),zZi,zmi,xB(ix),xNperp_in_ht(ix),herm_mode,display_mode,nmax);%,NZ
    %
    if guess_mode == 0,% continuous calculation case, guess is Nperp at previous location
        if ~isnan(xNperp_ft(ix))
            xNperp_in_ft(ix+1) = xNperp_ft(ix);
        else
            xNperp_in_ft(ix+1) = xNperp_in_ft(ix);
        end
        if ~isnan(xNperp_ht(ix))
            xNperp_in_ht(ix+1) = xNperp_ht(ix);
        else
            xNperp_in_ht(ix+1) = xNperp_in_ht(ix);
        end
    end
    %
    waitbar(ix/nx,h);
end
close(h)
%
imask_ft_min = min(find(~isnan(xNperp_ft)));
if ~isempty(imask_ft_min),
    imask_ft_max = min([find(isnan(xNperp_ft(imask_ft_min:nx))) + imask_ft_min - 1,nx]);
    mask_ft = [imask_ft_min:imask_ft_max];
else
    mask_ft = [];
end
nx_out_ft = length(mask_ft);
%
if nx_out_ft ~= nx
    diff_nx = [num2str(100 - nx_out_ft*100/nx),'  '];
    disp(['Warning: FT disp. calc. have been truncated by ',diff_nx(1:3),' %'])
end
%
imask_ht_min = min(find(~isnan(xNperp_ht)));
if ~isempty(imask_ht_min),
    imask_ht_max = min([find(isnan(xNperp_ht(imask_ht_min:nx))) + imask_ht_min - 1,nx]);
    mask_ht = [imask_ht_min:imask_ht_max];
else
    mask_ht = [];
end
nx_out_ht = length(mask_ht);
%
if nx_out_ht ~= nx
    diff_nx = [num2str(100 - nx_out_ht*100/nx),'  '];
    disp(['Warning: HT disp. calc. have been truncated by ',diff_nx(1:3),' %'])
end
%
%xNperp_ft = xNperp_ft(1,mask_ft);
%xepol_xyz_ft = xepol_xyz_ft(:,mask_ft);
%xepol_pmz_ft = xepol_pmz_ft(:,mask_ft);
%xepol_pyk_ft = xepol_pyk_ft(:,mask_ft);
%xD_ft = xD_ft(:,:,mask_ft);
%xX_ft = xX_ft(:,:,mask_ft);
%xX_s_ft = xX_s_ft(:,:,:,mask_ft);
%%xX_sn_ft = xX_sn_ft(:,:,:,:,mask_ft);
%
%xNperp_ht = xNperp_ht(1,mask_ht);
%xepol_xyz_ht = xepol_xyz_ht(:,mask_ht);
%xepol_pmz_ht = xepol_pmz_ht(:,mask_ht);
%xepol_pyk_ht = xepol_pyk_ht(:,mask_ht);
%xD_ht = xD_ht(:,:,mask_ht);
%xX_ht = xX_ht(:,:,mask_ht);
%xX_s_ht = xX_s_ht(:,:,:,mask_ht);
%%xX_sn_ht = xX_sn_ht(:,:,:,:,mask_ht);
%
%xalphaphi_lin = xalphaphi_lin(1,mask_ht);
%xphiP_xyz = xphiP_xyz(:,mask_ht);
%xphiP_pmz = xphiP_pmz(:,mask_ht);
%xphiP_pyk = xphiP_pyk(:,mask_ht);
%xphiT_xyz = xphiT_xyz(:,mask_ht);
%xphiT_pmz = xphiT_pmz(:,mask_ht);
%xphiT_pyk = xphiT_pyk(:,mask_ht);
%
xphiP_xyz = real(xphiP_xyz);
xphiP_pmz = real(xphiP_pmz);
xphiP_pyk = real(xphiP_pyk);
xphiT_xyz = real(xphiT_xyz);
xphiT_pmz = real(xphiT_pmz);
xphiT_pyk = real(xphiT_pyk);
%
xalphaphi_lin = real(xalphaphi_lin);
