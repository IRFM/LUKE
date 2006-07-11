function [gridDKE] = matrix3Dgridbuilder_dke_yp(dkeparam,display,equilDKE,radialDKE,momentumDKE)
%
%   Calculate matrix 3D grids for the 3D electron relativistic drift kinetic solver.
%
%   by Y. Peysson (CEA-DRFC) (yves.peysson@cea.fr) and J. Decker (CEA-DRFC) (joan.decker@cea.fr)
%
Rp = equilDKE.Rp;
Zp = equilDKE.Zp;
ap = equilDKE.ap;
xmhubounce2 = equilDKE.xmhu0T2;
xrho = equilDKE.xrho;
%
mhu = momentumDKE.mhu;
dmhu = momentumDKE.dmhu;
mhum = momentumDKE.mhum;
dmhum = momentumDKE.dmhum;
mhup = momentumDKE.mhup;
dmhup = momentumDKE.dmhup;
mhu_S = momentumDKE.mhu_S;
pn = momentumDKE.pn;
dpn = momentumDKE.dpn;
pnm = momentumDKE.pnm;
dpnm = momentumDKE.dpnm;
pnp = momentumDKE.pnp;
dpnp = momentumDKE.dpnp;
pn_S = momentumDKE.pn_S;
spfac = dkeparam.spfac;
%
xpsin = radialDKE.xpsin_f;
xpsin_dke = radialDKE.xpsin_f_dke;
xdpsin_dke = radialDKE.xdpsin_f_dke;
xpsinm_dke = radialDKE.xpsinm_S_dke;
xdpsinm_dke = radialDKE.xdpsinm_S_dke;
xpsinp_dke = radialDKE.xpsinp_S_dke;
xdpsinp_dke = radialDKE.xdpsinp_S_dke;
xpsin_S_dke = radialDKE.xpsin_S_dke;
rdke = radialDKE.r_dke;
ir_display_out = radialDKE.ir_display_out;
%
npn = length(pn);%Size of the momentum grid for the distribution function (half grid)
nmhu = length(mhu);%Size of the pitch-angle grid for the distribution function (half grid)
nr = length(xpsin);%Size of the radial grid for the distribution function (half grid)
nr_dke = length(rdke);%Size of the effective radial grid for the drift kinetic equation (nr_dke = nr for FPE equation only)
%
masku = triu(ones(npn,npn)) - 0.5*diag(ones(1,npn));
maskl = tril(ones(npn,npn)) - 0.5*diag(ones(1,npn));
%
%Angular grid
%
mhu2 = mhu.*mhu;
Xmhu = ones(npn,1)*mhu;
XXmhu = repmat(Xmhu,[1,1,nr]);
Xmhu2 = ones(npn,1)*mhu2;
X1mmhu2 = 1 - Xmhu2;
XX1mmhu2 = repmat(X1mmhu2,[1,1,nr]);
Xdmhu = ones(npn,1)*dmhu;
XXdmhu = repmat(Xdmhu,[1,1,nr]);
Xmhum = ones(npn,1)*mhum;
Xmhum(find(Xmhum==0)) = eps;
XXmhum = repmat(Xmhum,[1,1,nr]);
Xmhumm = ones(npn,1)*[mhu(1),mhu(1:nmhu-1)];
Xmhu2m = Xmhum.*Xmhum;
X1mmhu2m = 1 - Xmhu2m;
X1mmhu2m(find(X1mmhu2m==0)) = eps;
XX1mmhu2m = repmat(X1mmhu2m,[1,1,nr]);
Xdmhum = ones(npn,1)*dmhum;
XXdmhum = repmat(Xdmhum,[1,1,nr]);
Xdmhumm = ones(npn,1)*[dmhu(1),dmhu(1:nmhu-1)];
Xmhup = ones(npn,1)*mhup;
Xmhup(find(Xmhup==0)) = eps;
XXmhup = repmat(Xmhup,[1,1,nr]);
Xmhupp= ones(npn,1)*[mhu(2:nmhu),mhu(nmhu)];
Xmhu2p = Xmhup.*Xmhup;
X1mmhu2p = 1 - Xmhu2p;
X1mmhu2p(find(X1mmhu2p==0)) = eps;
XX1mmhu2p = repmat(X1mmhu2p,[1,1,nr]);
Xdmhup = ones(npn,1)*dmhup;
XXdmhup = repmat(Xdmhup,[1,1,nr]);
Xdmhupp= ones(npn,1)*[dmhu(2:nmhu),dmhu(nmhu)];
%
%Momentum grid
%
ip_th_ref = min(find(pn >= 1));
Xdpn = dpn'*ones(1,nmhu);
pn2 = pn.*pn;
pn3 = pn2.*pn;
xpn = pn'*ones(1,npn);
xpn2 = xpn.*xpn;
xpn3 = xpn2.*xpn;
Xpn = pn'*ones(1,nmhu);
Xdpn = dpn'*ones(1,nmhu);
Xpn2 = Xpn.*Xpn;
Xpn3 = Xpn2.*Xpn;
Xdpnm = dpnm'*ones(1,nmhu);
XXdpnm = repmat(Xdpnm,[1,1,nr]);
pn2m = pnm.*pnm;
Xpnm = pnm'*ones(1,nmhu);
XXpnm = repmat(Xpnm,[1,1,nr]);
Xpn2m = Xpnm.*Xpnm;
XXpn2m = XXpnm.*XXpnm;
Xdpnp   = dpnp'*ones(1,nmhu);
XXdpnp = repmat(Xdpnp,[1,1,nr]);
pn2p = pnp.*pnp;  
Xpnp = pnp'*ones(1,nmhu);
XXpnp = repmat(Xpnp,[1,1,nr]);
Xpn2p = Xpnp.*Xpnp;
XXpn2p = XXpnp.*XXpnp;
pnmm = [eps,pn(1:npn-1)];
Xpnmm = pnmm'*ones(1,nmhu);
XXpnmm = repmat(Xpnmm,[1,1,nr]);
XXpn2mm = XXpnmm.*XXpnmm;
Xdpnmm  = [dpn(1),dpn(1:npn-1)]'*ones(1,nmhu);
pnpp = [pn(2:npn),pn(npn)];
Xpnpp = pnpp'*ones(1,nmhu);
XXpnpp = repmat(Xpnpp,[1,1,nr]);
XXpn2pp = XXpnpp.*XXpnpp;
Xdpnpp  = [dpn(2:npn),dpn(npn)]'*ones(1,nmhu);
XXpn = repmat(Xpn,[1,1,nr]);
XXpn2 = repmat(Xpn2,[1,1,nr]);
%
% Fill structure gridDKE for output
%
gridDKE.masku = masku;
gridDKE.maskl = maskl;
%
gridDKE.mhu2 = mhu2;
gridDKE.Xmhu = Xmhu;
gridDKE.XXmhu = XXmhu;
gridDKE.Xmhu2 = Xmhu2;
gridDKE.X1mmhu2 = X1mmhu2;
gridDKE.XX1mmhu2 = XX1mmhu2;
gridDKE.Xdmhu = Xdmhu;
gridDKE.XXdmhu = XXdmhu;
gridDKE.Xmhum = Xmhum;
gridDKE.XXmhum = XXmhum;
gridDKE.Xmhumm = Xmhumm;
gridDKE.Xmhu2m = Xmhu2m;
gridDKE.X1mmhu2m = X1mmhu2m;
gridDKE.XX1mmhu2m = XX1mmhu2m;
gridDKE.Xdmhum = Xdmhum;
gridDKE.XXdmhum = XXdmhum;
gridDKE.Xdmhumm = Xdmhumm;
gridDKE.Xmhup = Xmhup;
gridDKE.XXmhup = XXmhup;
gridDKE.Xmhupp = Xmhupp;
gridDKE.Xmhu2p = Xmhu2p;
gridDKE.X1mmhu2p = X1mmhu2p;
gridDKE.XX1mmhu2p = XX1mmhu2p;
gridDKE.Xdmhup = Xdmhup;
gridDKE.XXdmhup = XXdmhup;
gridDKE.Xdmhupp = Xdmhupp;
gridDKE.mhu = mhu;
gridDKE.dmhu = dmhu;
gridDKE.mhum = mhum;
gridDKE.dmhum = dmhum;
gridDKE.mhup = mhup;
gridDKE.dmhup = dmhup;
gridDKE.mhu_S = mhu_S;
%
%Momentum grid
%
gridDKE.ip_th_ref = ip_th_ref;
gridDKE.Xdpn = Xdpn;
gridDKE.pn2 = pn2;
gridDKE.pn3 = pn3;
gridDKE.xpn = xpn;
gridDKE.xpn2 = xpn2;
gridDKE.xpn3 = xpn3;
gridDKE.Xpn = Xpn;
gridDKE.Xdpn = Xdpn;
gridDKE.Xpn2 = Xpn2;
gridDKE.Xpn3 = Xpn3;
gridDKE.Xdpnm = Xdpnm;
gridDKE.XXdpnm = XXdpnm;
gridDKE.pn2m = pn2m;
gridDKE.Xpnm = Xpnm;
gridDKE.XXpnm = XXpnm;
gridDKE.Xpn2m = Xpn2m;
gridDKE.XXpn2m = XXpn2m;
gridDKE.Xdpnp = Xdpnp;
gridDKE.XXdpnp = XXdpnp;
gridDKE.pn2p = pn2p;  
gridDKE.Xpnp = Xpnp;
gridDKE.XXpnp = XXpnp;
gridDKE.Xpn2p = Xpn2p;
gridDKE.XXpn2p = XXpn2p;
gridDKE.pnmm = pnmm;
gridDKE.Xpnmm = Xpnmm;
gridDKE.XXpnmm = XXpnmm;
gridDKE.XXpn2mm = XXpn2mm;
gridDKE.Xdpnmm = Xdpnmm;
gridDKE.pnpp = pnpp;
gridDKE.Xpnpp = Xpnpp;
gridDKE.XXpnpp = XXpnpp;
gridDKE.XXpn2pp = XXpn2pp;
gridDKE.Xdpnpp = Xdpnpp;
gridDKE.XXpn = XXpn;
gridDKE.XXpn2 = XXpn2;
gridDKE.pn = pn;
gridDKE.dpn = dpn;
gridDKE.pnm = pnm;
gridDKE.dpnm = dpnm;
gridDKE.pnp = pnp;
gridDKE.dpnp = dpnp;
gridDKE.pn_S = pn_S;
gridDKE.spfac = spfac;
%
gridDKE.xmhubounce2 = xmhubounce2;
gridDKE.xrho = xrho;
gridDKE.xpsin = xpsin;
gridDKE.xpsin_dke = xpsin_dke;
gridDKE.xdpsin_dke = xdpsin_dke;
gridDKE.xpsinm_dke = xpsinm_dke;
gridDKE.xdpsinm_dke = xdpsinm_dke;
gridDKE.xpsinp_dke = xpsinp_dke;
gridDKE.xdpsinp_dke = xdpsinp_dke;
gridDKE.rdke = rdke;
gridDKE.xpsin_S_dke = xpsin_S_dke;
gridDKE.ir_display_out = ir_display_out;
%
gridDKE.npn = npn;
gridDKE.nmhu = nmhu;
gridDKE.nr = nr;
gridDKE.nr_dke = nr_dke;
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










