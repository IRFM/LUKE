function [id_equil,omega_rf,ays,aypsin,ayR,ayZ,ayphi,...
          ayNpar,aydNpar,ayNperp,...
          ayepol_x,ayepol_y,ayepol_z,ayphi_x,...
          ayalpha,ayB,ayne,ayTe,...
          yP0,yr_in,yz_in,yphi_in,yNtor,yNpol] = process_genray_jd(data_out_netcdf);
%
% This function normalizes genray NETCDF data to DKE standards
%
% INPUT: structure containing NETCDF data 
%
% OUPUTS:   
%
%       - ays: poloidal ray path length (m)
%   
%
% by J. Decker 04/10/06 (joan.decker@cea.fr)
%
id_equil = data_out_netcdf.eqdskin;
%
omega_rf = 2*pi*data_out_netcdf.freqcy;
%
nray = data_out_netcdf.nray;
%
ays = data_out_netcdf.ws.'/100;
aypsin = data_out_netcdf.spsi.';
%
nx = size(ays,1);
%
ayR = data_out_netcdf.wr.'/100;
ayZ = data_out_netcdf.wz.'/100;
ayphi = data_out_netcdf.wphi.';
%
ayNpar = data_out_netcdf.wnpar.';
aydNpar = data_out_netcdf.wdnpar.';
ayNperp = data_out_netcdf.wnper.';

ayepol_x = reshape(data_out_netcdf.cwexde(1,:,:),nray,nx).' + i*reshape(data_out_netcdf.cwexde(2,:,:),nray,nx).';
ayepol_y = reshape(data_out_netcdf.cweyde(1,:,:),nray,nx).' + i*reshape(data_out_netcdf.cweyde(2,:,:),nray,nx).';
ayepol_z = reshape(data_out_netcdf.cwezde(1,:,:),nray,nx).' + i*reshape(data_out_netcdf.cwezde(2,:,:),nray,nx).';

ayphi_x = data_out_netcdf.fluxn.';

yP0 = data_out_netcdf.delpwr(:,1).'/1e7;
ayalpha = data_out_netcdf.salphal.';

ayB = abs(data_out_netcdf.sbtot).';
ayne = 1e6*data_out_netcdf.sene.';
ayTe = data_out_netcdf.ste.';

yr_in = data_out_netcdf.r_starting.';
yz_in = data_out_netcdf.z_starting.';
yphi_in = data_out_netcdf.phi_starting.';

yNtor = data_out_netcdf.N_toroidal_starting.';
yNpol = data_out_netcdf.N_poloidal_starting.';
