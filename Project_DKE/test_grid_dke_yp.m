% Test program for:
%
%   - radialgrid_dke_jd.m 
%   - momentum_grid_jd.m
%
% for numerical equilibrium
%
%by J. Decker <jodecker@mit.edu> (MIT/RLE) and Y.Peysson <yves.peysson@cea.fr>(CEA/DRFC)
%
clear all
close all
%
% -------------------- test parameters ----------------------------
%
tokname = 'CMOD';
dke_mode = 0;
%
% Radial grid
%
psin_S = [];%Values of the poloidal flux grid [1,p] (If one radial value: local calculation only)
rho_S = [0.3,0.5];
%
dpsin_dke = 0.02;%maximum difference between two consecutive positions used for radial derivatives
%
% Momentum space grid
%
grid_uniformity = 0;%Pitch-angle and momentum grids uniformity: (0) no, (1) yes
grid_method = 1;%Pitch-angle grid calculation technique: (0): old method, (1) new method
nmhu_S_in = 109;%Number of angular values for the flux grid (WARNING: odd number) (>100 recommended for accurate run)
np_S_in = 110;%Number of momentum values for the flux grid (pnmax/np < 0.1 highly recommended for accurate run)
pnmax_S_in = 10;%Maximum value of the flux momentum grid (pth_ref)
%
% Pitch-angle grid parameter
%
sfac0_in = 1;%Reduction factor for fine grid near mhu = 0
sfac1_in = 2;%Reduction factor for fine grid near mhu = 1
sfact_in = 3;%Reduction factor for fine grid near mhu = mhut
%
snmhu0_in = 5;%Number of fine grid points near mhu = 0
snmhu1_in = 2;%Number of fine grid points near mhu = 1
snmhut_in = 3;%Number of fine grid points near mhu = mhut
%
grid_power = 1.5; % power for mhu grid step varations (grid_power > 1) (Note: for grid_method = 1 only)
%
% Momentum grid parameters
%
snp_in = 10;% pgridfactor
%
% ----------------- grid test ---------------------------------
%
sfac_in = [sfac0_in,sfac1_in,sfact_in];
snmhu_in = [snmhu0_in,snmhu1_in,snmhut_in];
%
psin_S = sort([psin_S,rho2psi_jd(tokname,rho_S)]);
psin_display = 0.5;
%
if grid_method == 0
    grid_power = 0;
end
%
% Radial grid
%
[xpsin,xpsin_dke,xdpsin_dke,xpsinm_dke,xdpsinm_dke,xpsinp_dke,xdpsinp_dke,xpsin_S_dke,r_dke,ir_display]...
    = radialgrid_dke_jd(dke_mode,psin_S,dpsin_dke,psin_display);
%
% Plasma equilibrium
%
[theta,XR,XZ,XBR,XBZ,XBphi,xB0,xR0,xBT0,xTe,xne,xzTi,xzni,zZi,zmi,xZeff,Rp,Zp,ap,Ncoils,BeLi,psia,xmhu0T2]...
    = equilibrium_jd(tokname,xpsin);
%
% Momentum Grid 
%
[pn,dpn,pnm,dpnm,pnp,dpnp,pn_S,...
    mhu,dmhu,mhum,dmhum,mhup,dmhup,mhu_S]...
= momentumgrid_dke_jd(grid_uniformity,grid_power,dke_mode,r_dke,xmhu0T2,nmhu_S_in,np_S_in,pnmax_S_in,sfac_in,snmhu_in,snp_in);
%
nmhu = length(mhu);
nmhu_S = length(mhu_S);
npn = length(pn);
npn_S = length(pn_S);
nr = length(xpsin);
nr_S_dke = length(xpsin_S_dke);
nr_dke = length(r_dke);%number of points for dke calculations
xmhut = sqrt(xmhu0T2);
%
disp(' ');
info_dke_yp(2,'Pitch angle grid vector lengths')
disp('Lengths of mhu / dmhu / mhum / dmhum / mhup / dmhup / mhu_S')
disp(['           ',int2str(length(mhu)),' /  ',int2str(length(dmhu)),' /  ',int2str(length(mhum)),' /   ',int2str(length(dmhum)),' /  ',int2str(length(mhup)),' /   ',int2str(length(dmhup)),' /   ',int2str(length(mhu_S))])
%
disp(' ');
info_dke_yp(2,'Momentum grid vector lengths')
disp('Lengths of pn / dpn / pnm / dpnm / pnp / dpnp / pn_S')
disp(['          ',int2str(length(pn)),' / ',int2str(length(dpn)),' / ',int2str(length(pnm)),' /  ',int2str(length(dpnm)),' / ',int2str(length(pnp)),' /  ',int2str(length(dpnp)),' /  ',int2str(length(pn_S))])
%
disp(' ');
info_dke_yp(2,'Radial grid vector lengths')

disp('Lengths of  xpsin / xpsin_dke / xdpsin_dke / xpsinm_dke / xdpsinm_dke / xpsinp_dke / xdpsinp_dke / xpsin_S_dke')
disp(['                ',int2str(length(xpsin)),' /         ',int2str(length(xpsin_dke)),' /          ',...
    int2str(length(xdpsin_dke)),' /          ',int2str(length(xpsinm_dke)),' /           ',int2str(length(xdpsinm_dke)),...
    ' /          ',int2str(length(xpsinp_dke)),' /           ',int2str(length(xdpsinp_dke)),' /           ',int2str(length(xpsin_S_dke))])
%
figure(1),clf
hold on
%
for i=1:nmhu,
    plot([0,mhu(i)],[0,sqrt(1 - mhu(i)^2)],'b'),
end
for i=1:nmhu_S,
    plot([0,mhu_S(i)],[0,sqrt(1-mhu_S(i)^2)],'g'),
end
for i=1:length(xmhut),
    plot([0,xmhut(i)],[0,sqrt(1-xmhut(i)^2)],'r',[-xmhut(i),0],[sqrt(1-xmhut(i)^2),0],'r'),
end
hold off
axis('equal')
ylabel('pperp')
xlabel('ppar')
title('Pitch-angle grids: Green -> flux, Blue -> distribution, Red -> T/P boundary');
zoom on
%
figure(2),clf
plot([1:nmhu]-1+1/2,mhu,'b+',[1:nmhu_S]-1,mhu_S,'gx',repmat([0,nmhu_S]',[1,2*nr]),repmat([-xmhut,xmhut],[2,1]),'r'),grid on,zoom on
ylabel('mhu')
xlabel('Index')
title('Pitch-angle grids: Green -> flux, Blue -> distribution, Red -> T/P boundary')
%
dmhu_ref = 2/(nmhu_S-1);%Grid step for uniform grid
%
smhu = zeros(2*nmhu);
sdmhu = zeros(2*nmhu);
%
sdmhu(1:2:2*nmhu-1) = dmhu;
sdmhu(2:2:2*nmhu) = dmhu;
%
smhu(1:2:2*nmhu-1) = mhu_S(1:nmhu);
smhu(2:2:2*nmhu) = mhu_S(2:nmhu + 1);
%
figure(3),clf
%
plot(smhu,sdmhu,'b+-',[-1,1],[dmhu_ref,dmhu_ref],'g--',mhu,dmhu,'mx',repmat([-xmhut,xmhut],[2,1]),repmat([0,max(dmhu)]',[1,2*nr]),'r')
ylabel('dmhu')
xlabel('mhu')
title(['Pitch-angle grid steps: Blue -> Flux, Red -> T/P boundary\\ Magenta -> distribution, Green -> Uniform grid (',int2str(nmhu_S_in),' pts)']);
grid on
zoom on
%
figure(4),clf
plot([1:nr_dke]-1+1/2,xpsin_dke,'b+',[1:nr_S_dke]-1,xpsin_S_dke,'rx',[1:nr]-1+1/2,xpsin,'go'),grid on
xlabel('Index')
title('Radial grid')
legend('\psi_n^{DKE}','\psi_n^{S, DKE}','\psi_n^{FP}')
zoom on
%
figure(5),clf
plot([1:npn]-1+1/2,pn,'b+',[1:npn_S]-1,pn_S,'rx'),grid on
xlabel('Index')
title('Momentum grid')
legend('p_n','p_n^S');
zoom on



