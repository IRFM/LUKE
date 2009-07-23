function [gridDKE] = matrix3Dgridbuilder_dke_yp(dkeparam,display,equilDKE,radialDKE,momentumDKE)
%
%   Calculate matrix 3D grids for the 3D electron relativistic drift kinetic solver.
%
%   by Y. Peysson (CEA-DRFC) (yves.peysson@cea.fr) and J. Decker (CEA-DRFC) (joan.decker@cea.fr)
%
% Grid sizes
%
gridDKE.nmhu = length(momentumDKE.mhu);%Size of the pitch-angle grid for the distribution function (half grid)
gridDKE.npn = length(momentumDKE.pn);%Size of the momentum grid for the distribution function (half grid)
gridDKE.nr = length(radialDKE.xpsin_f);%Size of the radial grid for the distribution function (half grid)
gridDKE.nr_dke = length(radialDKE.r_dke);%Size of the effective radial grid for the drift kinetic equation (nr_dke = nr for FPE equation only)
%
% Pitch-angle grid
%
gridDKE.mhu = momentumDKE.mhu;
gridDKE.mhu2 = momentumDKE.mhu2;
gridDKE.dmhu = momentumDKE.dmhu;
gridDKE.mhum = momentumDKE.mhum;
gridDKE.dmhum = momentumDKE.dmhum;
gridDKE.mhup = momentumDKE.mhup;
gridDKE.dmhup = momentumDKE.dmhup;
gridDKE.mhu_S = momentumDKE.mhu_S;
gridDKE.xmhubounce2 = equilDKE.xmhu0T2;
%
[gridDKE.Xmhu,gridDKE.Xmhu2,gridDKE.X1mmhu2,gridDKE.Xdmhu] = multidimbuilder_dke_yp(1,gridDKE,momentumDKE.mhu,momentumDKE.mhu2,momentumDKE.onemmhu2,momentumDKE.dmhu);
[gridDKE.Xmhum,gridDKE.Xmhu2m,gridDKE.X1mmhu2m,gridDKE.Xdmhum] = multidimbuilder_dke_yp(1,gridDKE,momentumDKE.mhum,momentumDKE.mhu2m,momentumDKE.onemmhu2m,momentumDKE.dmhum);
[gridDKE.Xmhumm,gridDKE.Xdmhumm] = multidimbuilder_dke_yp(1,gridDKE,momentumDKE.mhumm,momentumDKE.dmhumm);
[gridDKE.Xmhup,gridDKE.Xmhu2p,gridDKE.X1mmhu2p,gridDKE.Xdmhup] = multidimbuilder_dke_yp(1,gridDKE,momentumDKE.mhup,momentumDKE.mhu2p,momentumDKE.onemmhu2p,momentumDKE.dmhup);
[gridDKE.Xmhupp,gridDKE.Xdmhupp] = multidimbuilder_dke_yp(1,gridDKE,momentumDKE.mhupp,momentumDKE.dmhupp);
%
[gridDKE.XXmhu,gridDKE.XXmhu2,gridDKE.XX1mmhu2,gridDKE.XXdmhu] = multidimbuilder_dke_yp(3,gridDKE,gridDKE.Xmhu,gridDKE.Xmhu2,gridDKE.X1mmhu2,gridDKE.Xdmhu);
[gridDKE.XXmhum,gridDKE.XXmhu2m,gridDKE.XX1mmhu2m,gridDKE.XXdmhum] = multidimbuilder_dke_yp(3,gridDKE,gridDKE.Xmhum,gridDKE.Xmhu2m,gridDKE.X1mmhu2m,gridDKE.Xdmhum);
[gridDKE.XXmhumm,gridDKE.XXdmhumm] = multidimbuilder_dke_yp(3,gridDKE,gridDKE.Xmhumm,gridDKE.Xdmhumm);
[gridDKE.XXmhup,gridDKE.XXmhu2p,gridDKE.XX1mmhu2p,gridDKE.XXdmhup] = multidimbuilder_dke_yp(3,gridDKE,gridDKE.Xmhup,gridDKE.Xmhu2p,gridDKE.X1mmhu2p,gridDKE.Xdmhup);
[gridDKE.XXmhupp,gridDKE.XXdmhupp] = multidimbuilder_dke_yp(3,gridDKE,gridDKE.Xmhupp,gridDKE.Xdmhupp);
%
% Momentum grid
%
gridDKE.pn = momentumDKE.pn;
gridDKE.pn2 = momentumDKE.pn2;
gridDKE.pn3 = momentumDKE.pn3;
gridDKE.dpn = momentumDKE.dpn;
%
gridDKE.pnm = momentumDKE.pnm;
gridDKE.pn2m = momentumDKE.pn2m;
gridDKE.pn3m = momentumDKE.pn3m;
gridDKE.dpnm = momentumDKE.dpnm;
%
gridDKE.pnp = momentumDKE.pnp;
gridDKE.dpnp = momentumDKE.dpnp;
gridDKE.pn2p = momentumDKE.pn2p;
gridDKE.pn3p = momentumDKE.pn3p;
%
gridDKE.pnmm = momentumDKE.pnmm;
gridDKE.pnpp = momentumDKE.pnpp;
%
gridDKE.pn_S = momentumDKE.pn_S;
%
gridDKE.spfac = dkeparam.spfac;
%
gridDKE.masku = triu(ones(gridDKE.npn,gridDKE.npn)) - 0.5*diag(ones(1,gridDKE.npn));
gridDKE.maskl = tril(ones(gridDKE.npn,gridDKE.npn)) - 0.5*diag(ones(1,gridDKE.npn));
%
gridDKE.ip_th_ref = min(find(momentumDKE.pn >= 1));
%
gridDKE.xpn = momentumDKE.pn(:)*ones(1,gridDKE.npn);
gridDKE.xpn2 = momentumDKE.pn2(:)*ones(1,gridDKE.npn);
gridDKE.xpn3 = momentumDKE.pn3(:)*ones(1,gridDKE.npn);
%
[gridDKE.Xpn,gridDKE.Xpn2,gridDKE.Xpn3,gridDKE.Xdpn] = multidimbuilder_dke_yp(2,gridDKE,momentumDKE.pn,momentumDKE.pn2,momentumDKE.pn3,momentumDKE.dpn);
[gridDKE.Xpnm,gridDKE.Xpn2m,gridDKE.Xpn3m,gridDKE.Xdpnm] = multidimbuilder_dke_yp(2,gridDKE,momentumDKE.pnm,momentumDKE.pn2m,momentumDKE.pn3m,momentumDKE.dpnm);
[gridDKE.Xpnp,gridDKE.Xpn2p,gridDKE.Xpn3p,gridDKE.Xdpnp] = multidimbuilder_dke_yp(2,gridDKE,momentumDKE.pnp,momentumDKE.pn2p,momentumDKE.pn3p,momentumDKE.dpnp);
[gridDKE.Xpnmm,gridDKE.Xpn2mm,gridDKE.Xdpnmm] = multidimbuilder_dke_yp(2,gridDKE,momentumDKE.pnmm,momentumDKE.pn2mm,momentumDKE.dpnmm);
[gridDKE.Xpnpp,gridDKE.Xpn2pp,gridDKE.Xdpnpp] = multidimbuilder_dke_yp(2,gridDKE,momentumDKE.pnpp,momentumDKE.pn2pp,momentumDKE.dpnpp);
%
[gridDKE.XXpn,gridDKE.XXpn2,gridDKE.XXpn3,gridDKE.XXdpn] = multidimbuilder_dke_yp(3,gridDKE,gridDKE.Xpn,gridDKE.Xpn2,gridDKE.Xpn3,gridDKE.Xdpn);
[gridDKE.XXpnm,gridDKE.XXpn2m,gridDKE.XXpn3m,gridDKE.XXdpnm] = multidimbuilder_dke_yp(3,gridDKE,gridDKE.Xpnm,gridDKE.Xpn2m,gridDKE.Xpn3m,gridDKE.Xdpnm);
[gridDKE.XXpnp,gridDKE.XXpn2p,gridDKE.XXpn3p,gridDKE.XXdpnp] = multidimbuilder_dke_yp(3,gridDKE,gridDKE.Xpnp,gridDKE.Xpn2p,gridDKE.Xpn3p,gridDKE.Xdpnp);
[gridDKE.XXpnmm,gridDKE.XXpn2mm,gridDKE.XXdpnmm] = multidimbuilder_dke_yp(3,gridDKE,gridDKE.Xpnmm,gridDKE.Xpn2mm,gridDKE.Xdpnmm);
[gridDKE.XXpnpp,gridDKE.XXpn2pp,gridDKE.XXdpnpp] = multidimbuilder_dke_yp(3,gridDKE,gridDKE.Xpnpp,gridDKE.Xpn2pp,gridDKE.Xdpnpp);
%
% Radial grid
%
gridDKE.ir_display_out = radialDKE.ir_display_out;%For display purposes
%
gridDKE.xrho = equilDKE.xrho;
gridDKE.xpsin = radialDKE.xpsin_f;
gridDKE.xpsin_dke = radialDKE.xpsin_f_dke;
gridDKE.xdpsin_dke = radialDKE.xdpsin_f_dke;
gridDKE.xpsinm_dke = radialDKE.xpsinm_S_dke;
gridDKE.xdpsinm_dke = radialDKE.xdpsinm_S_dke;
gridDKE.xpsinp_dke = radialDKE.xpsinp_S_dke;
gridDKE.xdpsinp_dke = radialDKE.xdpsinp_S_dke;
gridDKE.xdpsinmm_dke = radialDKE.xdpsinmm_f_dke;
gridDKE.xdpsinpp_dke = radialDKE.xdpsinpp_f_dke;
%
[gridDKE.XXdpsin_dke] = multidimbuilder_dke_yp(4,gridDKE,gridDKE.xpsin_dke);
[gridDKE.XXdpsinm_dke,gridDKE.XXdpsinp_dke] = multidimbuilder_dke_yp(4,gridDKE,gridDKE.xdpsinm_dke,gridDKE.xdpsinp_dke);
[gridDKE.XXdpsinmm_dke,gridDKE.XXdpsinpp_dke] = multidimbuilder_dke_yp(4,gridDKE,gridDKE.xdpsinmm_dke,gridDKE.xdpsinpp_dke);
%
gridDKE.rdke = radialDKE.r_dke;
%
gridDKE.xpsin_S_dke = radialDKE.xpsin_S_dke;

%
% Display grids
%
if display.display_mode == 2, 
	Fig_PitchGrid = figure('Name','Pitch-angle grid');
	figure(Fig_PitchGrid),plot(1:nmhu,mhu,'bo',1:nmhu,mhum,'g*',1:nmhu,mhup,'r+');grid on;zoom on;
	axis([1,nmhu+1,-1,1])
	title('Pitch-angle grid');
	xlabel('Index');
	ylabel('mhu');
    drawnow
%
	Fig_MomGrid = figure('Name','Momentum grid');
	figure(Fig_MomGrid),plot(1:npn,pn,'bo',1:npn,pnm,'g*',1:npn,pnp,'r+');grid on;zoom on; 
	axis([1,npn+1,0,max(pnp)])
	title('Momentum grid');
	xlabel('Index');
	ylabel('pn');
    drawnow
%
	Fig_MomStepGrid = figure('Name','Momentum step grid');
	figure(Fig_MomStepGrid),semilogx(pn,dpn,'bo',pnm,dpnm,'g*',pnp,dpnp,'r+');grid on;zoom on; 
	title('Momentum mesh (grid step)');
	xlabel('pn');
	ylabel('dpn');
    drawnow
%	
	Fig_RadGrid = figure('Name','Radial grid');
	figure(Fig_RadGrid),plot(1:nr,xpsin,'bo',rdke,xpsin(rdke),'r+',rdke,xrho(rdke),'bx');grid on;zoom on; 
	axis([0,nr+1,0,1])
	title('Radial mesh');
	xlabel('Index');
	ylabel('(psin: +,rho: x)');
    drawnow
%
    Fig_MetRel = figure('Name','Metric relation');
	figure(Fig_MetRel),subplot(121),plot(xpsin,xrho,'r-.',xpsin,xrho,'b+');grid on;zoom on
	xlabel('psi/psia');ylabel('rho');title('Metric relation');
	axis('square');axis([0,1,0,1]);
	figure(Fig_MetRel),subplot(122),plot(xrho,xpsin,'r-.',xrho,xpsin,'b+');grid on;zoom on
	xlabel('rho');ylabel('psi/psia');title('Metric relation');
	axis('square');axis([0,1,0,1]);
    drawnow
end
%






