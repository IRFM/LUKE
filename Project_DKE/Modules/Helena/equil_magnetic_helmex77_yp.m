function [equil_magnetic,prho,pspsin,pspsinT,pp,li] = equil_magnetic_helmex77_yp(ap,Rp,Zp,xpoint,Bt,Ip,ppsi,pj,ptot,ntheta,display_opt,id_path,path_path)
%
%   Create a magnetic equilibrium structure for C3PO/LUKE using HELENA code
%   (mex file version)
%
%   by Y. Peysson (CEA/DSM/IRFM,yves.peysson@cea.fr) and J. Decker
%   (CEA/DSM/IRFM,joan.decker@cea.fr)
%
if nargin < 10,
   error('Not enough input arguments in equil_magnetic_helmex77_yp.')
elseif nargin == 10,
   display_opt = 0;
   id_path = '';
   path_path = '';
elseif nargin == 11,
   id_path = '';
   path_path = '';
elseif nargin == 11,
   path_path = '';
end 
%
dkepath = load_structures_yp('dkepath',id_path,path_path);
%
[R_sep0,Z_sep0] = sep4helmex_yp(xpoint,ap,Rp,Zp,ntheta);
%
% For the input to HELENA
%
ap_in = ap;
Rp_in = Rp;
Zp_in = Zp;
R_in = R_sep0;
Z_in = Z_sep0 - Zp_in;%because HELENA work only at Zp = 0.
%
Bt_in = Bt;
Ip_in = Ip;
%
ppsi_in = ppsi;
ptot_in = ptot;
pj_in = pj; 
%
[equil_magnetic,prho,pspsin,pspsinT,pp,li] = build_helmex_equil_yp(ppsi_in,ptot_in,pj_in,Rp_in,Zp_in,Bt_in,Ip_in*1e6,ap_in,R_in,Z_in,ntheta,display_opt);
%