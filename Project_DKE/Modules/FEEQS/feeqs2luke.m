function [equil] = feeqs2luke(LCFS,Ip,gamma,beta,xx,plist_in)


equil = struct;
%
[jj_LCFS,psi,DMaps,psi_ax,lambda,plist_out] = FixedBoundaryEquilibrium_hpFEM(LCFS,Ip,gamma,beta,xx,plist_in);
%
[profiles_2d,FPSI,FBR,FBZ,FBPHI,hout,plist1] = compute_inverse_grid_interp_hpFEM(plist_out);
%
equil.Rp = plist_out.R0;
%{
equil.Zp = ;
equil.ptx = ;
equil.pty = ;
equil.ptBx = ;
equil.ptBy = ;
equil.ptBPHI = ;
equil.psi_apRp = ;
%}
equil.theta = profiles_2d.grid.dim2;
%{
equil.pTe = ;
equil.pne = ;
equil.zZi = ;
equil.zmi = ;
equil.fi = ;
equil.pzni = ;
equil.pzTi = ;
%}