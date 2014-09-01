function [equil_magnetic,prho,pspsin,pspsinT,pp,li] = equil_magnetic_helmex77_yp(xpoint,Bt,Ip,ppsi,pj,ptot,ntheta,nit,display_opt,id_path,path_path)
%
%   Create a magnetic equilibrium structure for C3PO/LUKE using HELENA code
%   (mex file version)
%
%   by Y. Peysson (CEA/DSM/IRFM,yves.peysson@cea.fr) and J. Decker
%   (CEA/DSM/IRFM,joan.decker@cea.fr)
%
if nargin < 7,
   error('Not enough input arguments in equil_magnetic_helmex77_yp.')
elseif nargin == 7,
   nit = 20;
   display_opt = 0;
   id_path = '';
   path_path = '';
elseif nargin == 8,
   display_opt = 0;
   id_path = '';
   path_path = '';
elseif nargin == 9,
   id_path = '';
   path_path = '';
elseif nargin == 10,
   path_path = '';
end 
%
dkepath = load_structures_yp('dkepath',id_path,path_path);
%
[R_in,Z_in] = sep4helmex_yp(xpoint,ntheta);
%
% For the input to HELENA
%
ap_in = xpoint(9);
Rp_in = xpoint(10);
Zp_in = xpoint(11);
%
Bt_in = Bt;
Ip_in = Ip;
%
ppsi_in = ppsi;
ptot_in = ptot;
pj_in = pj; 
%
[equil_magnetic,prho,pspsin,pspsinT,pp,li] = build_helmex_equil_yp(nit,ppsi_in,ptot_in,pj_in,Rp_in,Zp_in,Bt_in,Ip_in*1e6,ap_in,R_in,Z_in,ntheta,display_opt);
%