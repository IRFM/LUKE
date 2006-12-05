function [] = bremchorddisplay_dke_yp(equilHXR,Zbremchord,chordnum_disp,p_opt,filename)
%
% This function draws chord positions for bremsstrahlung tomography
%
% INPUTS
%
%       - Zbremchord: Bremsstrahlung diagnostic arrangement data strcuture
%       
% OUTPUTS: none
%
% by J. Decker (jodecker@alum.mit.edu) and Y. Peysson (yves.peysson@cea.fr)
%
if nargin < 2, error('Not enough input argument in bremchorddisplay_dke_yp');end
if nargin == 2, 
    chordnum_disp= [];
    p_opt = 2;
    filename = '';
end
if nargin == 3, 
    p_opt = 2;
    filename = '';
end
if nargin == 4, 
    filename = '';
end
%
ptrho = Zbremchord.ptrho;
xq = Zbremchord.xq;
sR = Zbremchord.sR;
sZ = Zbremchord.sZ;
RR_pol = Zbremchord.RR_pol;
ZZ_pol = Zbremchord.ZZ_pol;
HHR_pol = Zbremchord.HHR_pol;
HHZ_pol = Zbremchord.HHZ_pol;
VVR_pol = Zbremchord.VVR_pol;
VVZ_pol = Zbremchord.VVZ_pol;
ptR = Zbremchord.ptR;
ptZ = Zbremchord.ptZ;
BR_pol = Zbremchord.BR_pol;
BZ_pol = Zbremchord.BZ_pol;
X_mfl_lcs = Zbremchord.X_mfl_lcs;
Y_mfl_lcs = Zbremchord.Y_mfl_lcs;
Z_mfl_lcs = Zbremchord.Z_mfl_lcs;
BX_mfl_lcs = Zbremchord.BX_mfl_lcs;
BY_mfl_lcs = Zbremchord.BY_mfl_lcs;
Ipdir_mfl_lcs = Zbremchord.Ipdir_mfl_lcs;
Ipdkedir_mfl_lcs = Zbremchord.Ipdkedir_mfl_lcs;
sR = Zbremchord.sR;
sphi = Zbremchord.sphi;
XX_tor_min = Zbremchord.XX_tor_min;
YY_tor_min = Zbremchord.YY_tor_min;
XX_tor = Zbremchord.XX_tor;
YY_tor = Zbremchord.YY_tor;
XX_tor_max = Zbremchord.XX_tor_max;
YY_tor_max = Zbremchord.YY_tor_max;
VVX = Zbremchord.VVX;
VVY = Zbremchord.VVY;
HHX = Zbremchord.HHX;
HHY = Zbremchord.HHY;
xpsin_S = Zbremchord.xpsin_S;
%
figure('Name','Safety factor','Position',[360,278,760,585]);
[ax] = graph1D_jd(ptrho,xq,0,0,'Normalized radius {\rho}','q','Safety factor',NaN,'','','-','none','b',2);drawnow;%Safety factor profile
print_jd(p_opt,[filename,'_SafetyFactor']);
%
figure('Name','Bremsstrahlung tomography (Poloidal view)','Position',[360,278,760,585]);
[ax] = graph1D_jd(sR,sZ,0,0,'','','',NaN,'','','-','none','b',2);drawnow;%Poloidal plot
hold on
for ichord = 1:size(sR,2),
   sRc = sR(~isnan(sR(:,ichord)),ichord);
   sZc = sZ(~isnan(sZ(:,ichord)),ichord);
   if ~isempty(sRc) & ~isempty(sZc)
      ht = text(sRc(end),sZc(end),['  #',int2str(ichord)]);set(ht,'fontsize',10);
   end
end
if isempty(chordnum_disp) == 0,
   [ax] = graph1D_jd(sR(:,chordnum_disp),sZ(:,chordnum_disp),0,0,'','','',NaN,'','','-','none','g',2);drawnow;%Poloidal plot
end
for ir = 1:length(xpsin_S),
   graph1D_jd(RR_pol(ir,:),ZZ_pol(ir,:),0,0,'','','',NaN,'','','-','non','r',1);
end
axis('equal');
graph1D_jd(HHR_pol,HHZ_pol,0,0,'','','',NaN,'','','-.','non','r',1);
graph1D_jd(VVR_pol,VVZ_pol,0,0,'','','',NaN,'','','-.','non','r',1);
graph1D_jd(HHR_pol,HHZ_pol,0,0,'','','',NaN,'','','-.','non','r',1);
graph1D_jd(VVR_pol,VVZ_pol,0,0,'','','',NaN,'','','-.','non','r',1); 
graph1D_jd(ptR,ptZ,0,0,'X=R (m)','Z (m)','Bremsstrahlung tomography (Poloidal view)',NaN,'','','-','non','r',1);
hold off
print_jd(p_opt,[filename,'_PoloidalView']);
%
figure('Name','Poloidal field','Position',[360,278,760,585]);
quiver(RR_pol,ZZ_pol,BR_pol,BZ_pol);
axis('equal');
hold on
graph1D_jd(ptR,ptZ,0,0,'','','',NaN,'','','-','non','c',1);
graph1D_jd(HHR_pol,HHZ_pol,0,0,'','','',NaN,'','','-.','non','r',1);
graph1D_jd(VVR_pol,VVZ_pol,0,0,'X=R (m)','Z (m)','B_{\theta} field (T)',NaN,'','','-.','non','r',1);
hold off
print_jd(p_opt,[filename,'_BthetaField']);
%
figure('Name','Bremsstrahlung tomography (Toroidal top view, Z = 0)','Position',[360,278,760,585]);
h = quiver(X_mfl_lcs(1:40:end),Y_mfl_lcs(1:40:end),BX_mfl_lcs(1:40:end),BY_mfl_lcs(1:40:end),0.5);%Magnetic field line direction
set(h,'Color','k');
hold on
sssB = sign(BY_mfl_lcs(1));%sign at phi = 0. if BPHI > 0, sss < 0, and for BPHI < 0, sss > 0
sssIp = sign(Ipdir_mfl_lcs(1));
sssIPdke = sign(Ipdkedir_mfl_lcs(1));
h = quiver(X_mfl_lcs(20:40:end),Y_mfl_lcs(20:40:end),sssIp*sssB*BX_mfl_lcs(20:40:end),sssIp*sssB*BY_mfl_lcs(20:40:end),0.5);%Current direction on magnetic field line direction
set(h,'Color','g');
h = quiver(X_mfl_lcs(20:40:end),Y_mfl_lcs(20:40:end),sssIPdke*sssB*BX_mfl_lcs(20:40:end),sssIPdke*sssB*BY_mfl_lcs(20:40:end),0.3);%Current direction on magnetic field line direction
set(h,'Color','m');
axis('equal');	
graph1D_jd(sR.*cos(sphi),sR.*sin(sphi),0,0,'','','',NaN,'','','-','non','b',2);
graph1D_jd(XX_tor_min,YY_tor_min,0,0,'','','',NaN,'','','-','non','r',2);
graph1D_jd(XX_tor,YY_tor,0,0,'','','',NaN,'','','-.','non','r',2);
graph1D_jd(XX_tor_max,YY_tor_max,0,0,'','','',NaN,'','','-','non','r',2);
graph1D_jd(VVX,VVY,0,0,'','','',NaN,'','','-.','non','r',1);
graph1D_jd(HHX,HHY,0,0,'','','',NaN,'','','-.','non','r',1);
graph1D_jd(X_mfl_lcs(1:3:end),Y_mfl_lcs(1:3:end),0,0,'','','',NaN,'','',':','non','k',1);%Z < 0 
i_mfl_lcs = find(Z_mfl_lcs>=0);
graph1D_jd(X_mfl_lcs(i_mfl_lcs(1:end-1)),Y_mfl_lcs(i_mfl_lcs(1:end-1)),0,0,'X (m)','Y (m)','Bremsstrahlung tomography (Toroidal top view, Z = 0)','B-field, (Ip: green, Ip-dke: magenta)','','','-','non','k',1);%Z >= 0 
graph1D_jd(X_mfl_lcs(i_mfl_lcs(1)),Y_mfl_lcs(i_mfl_lcs(1)),0,0,'X (m)','Y (m)','Bremsstrahlung tomography (Toroidal top view, Z = 0)','B-field, (Ip: green, Ip-dke: magenta)','','','non','*','k',1);%Z >= 0 
hold off
set(gca,'YDir','rev');%Because the reference is indirect by definition
%
print_jd(p_opt,[filename,'_TopView']);