function [MMXR_f_t,Xmask_r_edge] = rad_dke_yp(dkeparam,display,equilDKE,gridDKE,mksa,Zbouncecoef,Zmomcoef,transpfaste)
%
% Calculation of the anomalous radial fast electron transport matrix coefficients for arbitrary magnetic plasma equilibrium 
%
% by J. Decker (MIT-RLE) <joan.decker@cea.fr> and Y. Peysson (CEA-DRFC) <yves.peysson@cea.fr>
%
%
if nargin < 7,
   error('Wrong number of input arguments for rad_dke_yp');
end
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;%Universal physics constants
%
npn = gridDKE.npn;
nmhu = gridDKE.nmhu;
nr = gridDKE.nr;
xpsin = gridDKE.xpsin_dke;
xdpsin = gridDKE.xdpsin_dke;
xpsinm = gridDKE.xpsinm_dke;
xdpsinm = gridDKE.xdpsinm_dke;
xpsinp = gridDKE.xpsinp_dke;
xdpsinp = gridDKE.xdpsinp_dke;
XXpn2 = gridDKE.XXpn2;
Xmhu = gridDKE.Xmhu;
Xmhu2 = gridDKE.Xmhu2;
xmhubounce2 = gridDKE.xmhubounce2;
pn = gridDKE.pn;
ir_display = gridDKE.ir_display_out;
mhu = gridDKE.mhu;
%
gamma = Zmomcoef.gamma;
Xvpar = Zmomcoef.Xvpar;
%
ns_f = Zbouncecoef.ns_f;
XXlambda = Zbouncecoef.XXlambda;
blocksize_f_t = Zbouncecoef.blocksize_f_t;
xqtilde = Zbouncecoef.xqtilde;
%
xR0 = equilDKE.xR0;
xBp0 = equilDKE.xBp0;
xB0 = equilDKE.xB0;
ap = equilDKE.ap;
psia = equilDKE.psia;
xrho = equilDKE.xrho;
%
betath_ref = mksa.betath_ref;
nhu_ref = mksa.nhu_ref;
%
bounce_mode = dkeparam.bounce_mode;
temppath = dkeparam.temppath;
%
dp_cyl = display.dp_cyl;
nlevel = display.nlevel;
display_mode = display.display_mode;
%
nMMXP_f_t = max(cumsum(Zbouncecoef.blocksize_f_t));
%
Xmask_r_edge = [];
%
if ~isempty(transpfaste), 
   time0 = clock;
%
   [xTe_norm,xne_norm,xzni_norm,xzTi_norm,xnloss_norm,xbetath,xlnc_e,xnhu,xrnhuth] = normcoef_dke_yp(mksa,equilDKE,gridDKE);   
%
   XXDpsi = zeros(npn,nmhu,nr);%Defined on the distribution function grid (half grid) (psi coordinate)
   XXVpsi = zeros(npn,nmhu,nr);%Defined on the distribution function grid (half grid) (psi coordinate)
%
   if transpfaste.norm_ref == 1,
      xvparmin_r = transpfaste.vparmin*ones(size(xrho));%Normalized to vth_ref
   elseif transpfaste.norm_ref == 0,
      xvparmin_r = transpfaste.vparmin*ones(size(xrho)).*xbetath/betath_ref;%Normalized to vth (local)
   end
   xDr = transpfaste.Dr0*(1 + transpfaste.pDr*xrho.^2);
   xVr = transpfaste.Vr0*(1 + transpfaste.pVr*xrho.^2);
%
   for ir = 1:nr,	
	  ivpar_r_threshold = min(find(abs(Xvpar) >= xvparmin_r(ir)));
   	  xEc_r_threshold(ir) = mc2*(sqrt(1+pn(ivpar_r_threshold).*pn(ivpar_r_threshold)*betath_ref^2) - 1);%in keV
%
   	  if transpfaste.Dr_model==0,%No vpar dependence
	     XDpsiv = xDr(ir)*ones(size(npn,nmhu)).*(abs(Xvpar) >= xvparmin_r(ir))/(psia*psia*nhu_ref);%Normalized to the central collision frequency
	  elseif transpfaste.Dr_model==1,%Magnetic turbulence model: Dr(r)*vpar_ref/vth_ref
		 XDpsiv = xDr(ir)*(abs(Xvpar) - xvparmin_r(ir)).*(abs(Xvpar) >= xvparmin_r(ir))/xvparmin_r(ir)/(psia*psia*nhu_ref);%Normalized to the central collision frequency
      end
	  XXDpsi(:,:,ir) = XDpsiv;%3-D radial diffusion matrix (radial profile dependence) (psi coordinate)
	  xmaxDpsi(ir) = max(max(XXDpsi(:,:,ir)));%Maximum value of the radial diffusion coefficient (psi coordinate)
%
      if transpfaste.Vr_model==0,%No vpar dependence
	     XVpsiv = xVr(ir)*ones(size(npn,nmhu)).*(abs(Xvpar) >= xvparmin_r(ir))/(psia*nhu_ref);%Normalized to the central collision frequency (psi coordinate)
	  elseif transpfaste.Vr_model==1,%Magnetic turbulence model: Vr(r) = Vr0(r)*vpar_ref/vth_ref
	     XVpsiv = xVr(ir)*(abs(Xvpar) - xvparmin_r(ir)).*(abs(Xvpar) >= xvparmin_r(ir))/xvparmin_r(ir)/(psia*nhu_ref);%Normalized to the central collision frequency (psi coordinate)
      end
	  XXVpsi(:,:,ir) = XVpsiv;%3-D radial pinch matrix (radial profile dependence) (psi coordinate)
	  xmaxVpsi(ir) = max(max(XXVpsi(:,:,ir)));%Maximum value of the radial convection coefficient (psi coordinate)
   end
% 
   if display_mode == 2,
      Fig_radialdiff = figure('Name','Fast electron radial diffusion');
%	
	  figure(Fig_radialdiff),subplot(121);zoom on;
	  [XDpsiv_cyl,ppar_cyl,dppar_cyl,pperp_cyl,dpperp_cyl] = s2c_dke_yp(XXDpsi(:,:,ir_display),pn,mhu,dp_cyl);
%
	  Xppar_cyl = ones(length(pperp_cyl),1)*ppar_cyl(:)';
	  Xpperp_cyl = pperp_cyl(:)*ones(1,length(ppar_cyl));
	  Xp_cyl = sqrt(Xppar_cyl.*Xppar_cyl + Xpperp_cyl.*Xpperp_cyl);
%
	  XDpsiv_cyl = XDpsiv_cyl.*(XDpsiv_cyl>0);%Remove negative values
	  XDpsiv_cyl = XDpsiv_cyl.*(Xp_cyl<max(ppar_cyl));%Remove values above max(ppar)
 %
 	  C = contourf(ppar_cyl,pperp_cyl,XDpsiv_cyl,nlevel);
      if xmaxDpsi(ir_display)>0,colorbar;end
 	  axis('equal');
	  faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
	  text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,['rho = ',num2str(xrho(ir_display))]);
	  text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*10,['v//-threshold(norm) = ',num2str(xvparmin_r(ir_display))]);
	  text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*15,['Ec-threshold = ',num2str(xEc_r_threshold(ir_display)),' (keV)']);
	  xlabel('ppar/pth-ref');ylabel('pperp/pth-ref');title('Radial diffusion coefficient (nhu-ref*psia*psia)');
%
	   subplot(122),plot(pn./gamma,XXDpsi(:,nmhu,ir_display),'b');
	   faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
	   text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,['mhu = 1']);
	   xlabel('v/vth-ref');ylabel('Dr (nhu-ref*psia*psia)');title('Radial diffusion coefficient ');drawnow
%
       Fig_radialpinch = figure('Name','Fast electron radial pinch');
	   figure(Fig_radialpinch),subplot(121);zoom on,
	   [XVpsiv_cyl,ppar_cyl,dppar_cyl,pperp_cyl,dpperp_cyl] = s2c_dke_yp(XXVpsi(:,:,ir_display),pn,mhu,dp_cyl);
%
	   Xppar_cyl = ones(length(pperp_cyl),1)*ppar_cyl(:)';
	   Xpperp_cyl = pperp_cyl(:)*ones(1,length(ppar_cyl));
	   Xp_cyl = sqrt(Xppar_cyl.*Xppar_cyl + Xpperp_cyl.*Xpperp_cyl);
%
	   XVpsiv_cyl = XVpsiv_cyl.*(XVpsiv_cyl>0);%Remove negative values
	   XVpsiv_cyl = XVpsiv_cyl.*(Xp_cyl<max(ppar_cyl));%Remove values above max(ppar)
%
 	   C = contourf(ppar_cyl,pperp_cyl,XVpsiv_cyl,nlevel);
        if xmaxVpsi(ir_display)>0,colorbar;end
 	   axis('equal');
	   faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
	   text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,['rho = ',num2str(xrho(ir_display))]);
	   text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*10,['v//-threshold(norm) = ',num2str(xvparmin_r(ir_display))]);
	   text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*15,['Ec-threshold = ',num2str(xEc_r_threshold(ir_display)),' (keV)']);
	   xlabel('ppar/pth-ref');ylabel('pperp/pth-ref');title('Radial convection coefficient (nhu-ref*psia)');
%
	   subplot(122),plot(pn./gamma,XXVpsi(:,nmhu,ir_display),'r');
	   faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
	   text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,['mhu = 1']);
       xlabel('v/vth-ref');ylabel('Vr (nhu-ref*psia)');title('Radial convection coefficient ');drawnow
%
      Fig_radialtranspvthreshold = figure('Name','Fast electron radial transport velocity threshold');
       figure(Fig_radialtranspvthreshold);
       subplot(121),plot(xrho,xvparmin_r,'g-x');grid on;zoom on;
       axis([0,1,0,1.1*max(xvparmin_r)]);
	   xlabel('rho');
	   ylabel('v// threshold (vth-ref)');
	   title('Radial transport');
	   subplot(122),plot(xrho,xEc_r_threshold,'c-x');grid on;zoom on;
	   axis([0,1,0,1.1*max(xEc_r_threshold)]);
	   xlabel('xrho');
	   ylabel('Kinetic energy threshold (keV)');
	   title('Radial transport');drawnow
%
       Fig_fastetransp = figure('Name','Fast electron radial transport'); 
       figure(Fig_fastetransp);
	   subplot(121),plot(xrho,xmaxDpsi,'b-o');grid on;zoom on;
	   if sum(xmaxDpsi) ~= 0,axis([0,1,0,1.1*max(xmaxDpsi)]);end
	   xlabel('rho');
	   ylabel('Maximum value (nhu-ref*psia*psia)');
	   title('Radial diffusion');
	   subplot(122),plot(xrho,xmaxVpsi,'r-o');grid on;zoom on;
	   if sum(xmaxVpsi) ~= 0,axis([0,1,0,1.1*max(xmaxVpsi)]);end
	   xlabel('rho');
	   ylabel('Maximum value (nhu-ref*psia)');
	   title('Radial convection');drawnow
   end
 %
   XXMrm = zeros(nmhu,npn,nr);
   XXMr = zeros(nmhu,npn,nr);
   XXMrp = zeros(nmhu,npn,nr);
%   
%   load([fullfile(temppath,'temp_DKE.mat'],'MMXR_f_t');
%
   if exist('MMXR_f_t') == 1, %The radial matrix was calculated before.
   
   else
      MMXR_f_t = sparse(nMMXP_f_t,nMMXP_f_t);%Create supermatrix
% 
      xdpsinmm = [0,xdpsin(1:nr-1)];
      xdpsinpp = [xdpsin(2:nr),0];
%
      XXpsin = reshape(repmat(xpsin,[npn*nmhu,1]),[npn,nmhu,nr]);
      XXdpsin = reshape(repmat(xdpsin,[npn*nmhu,1]),[npn,nmhu,nr]);   
      XXpsinm = reshape(repmat(xpsinm,[npn*nmhu,1]),[npn,nmhu,nr]);   
      XXdpsinm = reshape(repmat(xdpsinm,[npn*nmhu,1]),[npn,nmhu,nr]); 
      XXpsinp = reshape(repmat(xpsinp,[npn*nmhu,1]),[npn,nmhu,nr]);   
      XXdpsinp = reshape(repmat(xdpsinp,[npn*nmhu,1]),[npn,nmhu,nr]); 
      XXdpsinmm = reshape(repmat(xdpsinmm,[npn*nmhu,1]),[npn,nmhu,nr]);   
      XXdpsinpp = reshape(repmat(xdpsinpp,[npn*nmhu,1]),[npn,nmhu,nr]);
%
      XXdeltalp = XXdpsinpp./(XXdpsinpp + XXdpsin);%Grid interpolation coefficients
      XXdeltalm = XXdpsin./(XXdpsinmm + XXdpsin);%Grid interpolation coefficients
%
      XXDpsimm = zeros(npn,nmhu,nr);
      XXDpsimm(:,:,2:nr) = XXDpsi(:,:,1:nr-1);
      XXDpsipp = zeros(npn,nmhu,nr);
      XXDpsipp(:,:,1:nr-1) = XXDpsi(:,:,2:nr);
%
      XXDpsip = (1 - XXdeltalp).*XXDpsipp + XXdeltalp.*XXDpsi;%Evaluation of the diffusion rate on the flux grid (linear interpolation)
      XXDpsim = (1 - XXdeltalm).*XXDpsi + XXdeltalm.*XXDpsimm;%Evaluation of the diffusion rate on the flux grid (linear interpolation)
%
      XXVpsimm = zeros(npn,nmhu,nr);
      XXVpsimm(:,:,2:nr) = XXVpsi(:,:,1:nr-1);
      XXVpsipp = zeros(npn,nmhu,nr);
      XXVpsipp(:,:,1:nr-1) = XXVpsi(:,:,2:nr);
%
      XXVpsip = (1 - XXdeltalp).*XXVpsipp + XXdeltalp.*XXVpsi;%Evaluation of the convection on the flux grid (linear interpolation)
      XXVpsim = (1 - XXdeltalm).*XXVpsi + XXdeltalm.*XXVpsimm;%Evaluation of the convection on the flux grid (linear interpolation)
%
      XXR0 = repmat(reshape(xR0',[1,1,nr]),[npn,nmhu,1]);
      XXR0mm = zeros(npn,nmhu,nr);
      XXR0mm(:,:,2:nr) = XXR0(:,:,1:nr-1);
      XXR0pp = zeros(npn,nmhu,nr);
      XXR0pp(:,:,1:nr-1) = XXR0(:,:,2:nr);
%
      XXR0p = (1 - XXdeltalp).*XXR0pp + XXdeltalp.*XXR0;%Evaluation on the flux grid (linear interpolation)
      XXR0m = (1 - XXdeltalm).*XXR0 + XXdeltalm.*XXR0mm;%Evaluation on the flux grid (linear interpolation)
%
      XXqtilde = repmat(reshape(xqtilde',[1,1,nr]),[npn,nmhu,1]);
      XXqtildemm = zeros(npn,nmhu,nr);
      XXqtildemm(:,:,2:nr) = XXqtilde(:,:,1:nr-1);
      XXqtildepp = zeros(npn,nmhu,nr);
      XXqtildepp(:,:,1:nr-1) = XXqtilde(:,:,2:nr);
%
      XXqtildep = (1 - XXdeltalp).*XXqtildepp + XXdeltalp.*XXqtilde;%Evaluation on the flux grid (linear interpolation)
      XXqtildem = (1 - XXdeltalm).*XXqtilde + XXdeltalm.*XXqtildemm;%Evaluation on the flux grid (linear interpolation)
%   
      XXBp0 = repmat(reshape(xBp0',[1,1,nr]),[npn,nmhu,1]);
      XXBp0mm = zeros(npn,nmhu,nr);
      XXBp0mm(:,:,2:nr) = XXBp0(:,:,1:nr-1);
      XXBp0pp = zeros(npn,nmhu,nr);
      XXBp0pp(:,:,1:nr-1) = XXBp0(:,:,2:nr);
%
      XXBp0p = (1 - XXdeltalp).*XXBp0pp + XXdeltalp.*XXBp0;%Evaluation on the flux grid (linear interpolation)
      XXBp0m = (1 - XXdeltalm).*XXBp0 + XXdeltalm.*XXBp0mm;%Evaluation on the flux grid (linear interpolation)
%
      XXB0 = repmat(reshape(xB0',[1,1,nr]),[npn,nmhu,1]);
      XXB0mm = zeros(npn,nmhu,nr);
      XXp0mm(:,:,2:nr) = XXB0(:,:,1:nr-1);
      XXB0pp = zeros(npn,nmhu,nr);
      XXB0pp(:,:,1:nr-1) = XXB0(:,:,2:nr);
%
      XXB0p = (1 - XXdeltalp).*XXB0pp + XXdeltalp.*XXB0;%Evaluation on the flux grid (linear interpolation)
      XXB0m = (1 - XXdeltalm).*XXB0 + XXdeltalm.*XXB0mm;%Evaluation on the flux grid (linear interpolation)
%
      XXlambdamm = zeros(npn,nmhu,nr);
      XXlambdamm(:,:,2:nr) = XXlambda(:,:,1:nr-1);
      XXlambdapp = zeros(npn,nmhu,nr);
      XXlambdapp(:,:,1:nr-1) = XXlambda(:,:,2:nr);
%
      XXlambdap = (1 - XXdeltalp).*XXlambdapp + XXdeltalp.*XXlambda;%Evaluation on the flux grid (linear interpolation)
      XXlambdam = (1 - XXdeltalm).*XXlambda + XXdeltalm.*XXlambdamm;%Evaluation on the flux grid (linear interpolation)
%   
      XXalpharp = XXR0p.*XXqtildep.*XXBp0p.*XXlambdap./XXB0p;%Evaluation on the flux grid (linear interpolation)
      XXalpharm = XXR0m.*XXqtildem.*XXBp0m.*XXlambdam./XXB0m;%Evaluation on the flux grid (linear interpolation)
      XXalpharm(:,:,1) = 0;%Force zero at the plasma center, which is the natural analytical limit (In cylindrical geometry, r=0)
      XXalpharp(:,:,nr) = 0;%Avoid NaN
%
%************************************************** Matrices calculation ******************************************************** 
%
      XXMrm = -(XXalpharm.*XXR0m.*XXBp0m./XXdpsinm./XXdpsin).*XXDpsim - (XXalpharm./XXdpsin).*XXVpsim.*XXdeltalm;
      XXMr = (XXalpharp.*XXR0p.*XXBp0p./XXdpsinp./XXdpsin).*XXDpsip + (XXalpharp./XXdpsin).*XXVpsip.*XXdeltalp + ...
             (XXalpharm.*XXR0m.*XXBp0m./XXdpsinm./XXdpsin).*XXDpsim - (XXalpharm./XXdpsin).*XXVpsim.*(1 - XXdeltalm);                    
      XXMrp = -(XXalpharp.*XXR0p.*XXBp0p./XXdpsinp./XXdpsin).*XXDpsip + (XXalpharp./XXdpsin).*XXVpsip.*(1 - XXdeltalp);
%
      XXMrm = XXMrm.*XXpn2./XXlambda;%Partial Jacobian multiplication
      XXMr = XXMr.*XXpn2./XXlambda;%Partial Jacobian multiplication
      XXMrp = XXMrp.*XXpn2./XXlambda;%Partial Jacobian multiplication      
%
      Xmask_r_edge = (XXDpsi(:,:,nr) > 0);
      XXMrm(:,:,nr) = 0;%Edge boundary condition (Maxwellian solution)
	  XXMr(:,:,nr) = 0;%Edge boundary condition (Maxwellian solution)
%
% Radial off-diagonal terms for fast electron transport
%
      if bounce_mode == 0,
         XXMrm = permute(XXMrm,[2,1,3]);
         MMrm_t = reshape(XXMrm,npn*nmhu*nr,1,1);
         XXMr = permute(XXMr,[2,1,3]);
         MMr_t = reshape(XXMr,npn*nmhu*nr,1,1);
         XXMrp = permute(XXMrp,[2,1,3]);
         MMrp_t = reshape(XXMrp,npn*nmhu*nr,1,1);
%
         MMXR_f_t = MMXR_f_t + sparse([1+nmhu*npn:nMMXP_f_t],[1:nMMXP_f_t-nmhu*npn],MMrm_t(1+npn*nmhu:nMMXP_f_t),nMMXP_f_t,nMMXP_f_t);
         MMXR_f_t = MMXR_f_t + sparse([1:nMMXP_f_t],[1:nMMXP_f_t],MMr_t,nMMXP_f_t,nMMXP_f_t);    
         MMXR_f_t = MMXR_f_t + sparse([1:nMMXP_f_t-nmhu*npn],[1+npn*nmhu:nMMXP_f_t],MMrp_t(1:nMMXP_f_t-nmhu*npn),nMMXP_f_t,nMMXP_f_t);
%
         if display_mode >= 1,info_dke_yp(2,['Zero order configuration space matrix calculations done in ',num2str(etime(clock,time0)),' (s)']);end
      elseif bounce_mode == 1,    
         ir = 1;
         ib0 = 0;
         ibp = max(cumsum(blocksize_f_t(1:ir)));
%
         Xmask_f0 = (Xmhu2 < xmhubounce2(ir)) & (Xmhu < 0);%Only the half-bounce region is removed
         Xmask_f0 = nonzeros(~(Xmask_f0(2,:)==1).*cumsum(ones(1,nmhu)))';
         Xmask_f0p = (Xmhu2 < xmhubounce2(ir+1)) & (Xmhu < 0);%Only the half-bounce region is removed
         Xmask_f0p = nonzeros(~(Xmask_f0p(2,:)==1).*cumsum(ones(1,nmhu)))';
%   
         imhu0 = sum((Xmhu(1,Xmask_f0) < 0).*(Xmhu2(1,Xmask_f0) > xmhubounce2(ir))); 
         imhup = sum((Xmhu(1,Xmask_f0p) < 0).*(Xmhu2(1,Xmask_f0p) > xmhubounce2(ir+1)));
%
         XMr = XXMr(:,:,ir);
         XMr_t = XMr(:,Xmask_f0);%Matrix reduction along the angular direction (half-bounce region is removed)
         MMr_t = reshape(XMr_t',npn*(nmhu-ns_f(ir)),1,1);
 %        
         MMXR_f_t_i = zeros(nMMXP_f_t*11*nr,1);%Create oversized sparse matrix to avoid reallocation
         MMXR_f_t_j = zeros(nMMXP_f_t*11*nr,1);
         MMXR_f_t_v = zeros(nMMXP_f_t*11*nr,1);
%
         i = [1+ib0:ibp];
         j = [1+ib0:ibp];
         ia = 1;ib = ia+length(i);                 
         MMXR_f_t_i(ia:ib-1) = i;
         MMXR_f_t_j(ia:ib-1) = j;
         MMXR_f_t_v(ia:ib-1) = MMr_t;
%           
         XMrp = XXMrp(:,:,ir);
         XMrp_t = XMrp(:,Xmask_f0);%Matrix reduction along the angular direction (half-bounce region is removed)
         XMrp1_t = XMrp_t.*(Xmhu(:,Xmask_f0) < 0).*(Xmhu2(:,Xmask_f0) > xmhubounce2(ir+1));
         XMrp2_t = XMrp_t.*(Xmhu(:,Xmask_f0) < 0).*(Xmhu2(:,Xmask_f0) < xmhubounce2(ir+1)).*(Xmhu2(:,Xmask_f0) > xmhubounce2(ir));
         XMrp3_t = XMrp_t.*(Xmhu(:,Xmask_f0) > 0);
%   
         for ip = 1:npn, 
            i = [ib0+(nmhu-ns_f(ir))*(ip-1)+1:ib0+(nmhu-ns_f(ir))*(ip-1)+imhup];
            j = [ibp+(nmhu-ns_f(ir+1))*(ip-1)+1:ibp+(nmhu-ns_f(ir+1))*(ip-1)+imhup];
            ia = ib;ib = ia+length(i);
            MMXR_f_t_i(ia:ib-1) = i;
            MMXR_f_t_j(ia:ib-1) = j;
            MMXR_f_t_v(ia:ib-1) = XMrp1_t(ip,[1:imhup])';
            i = [ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0+1:ib0+(nmhu-ns_f(ir))*ip];
            j = [ibp+(nmhu-ns_f(ir+1))*(ip-1)+imhup+1:ibp+(nmhu-ns_f(ir+1))*ip];
            ia = ib;ib = ia+length(i);
            MMXR_f_t_i(ia:ib-1) = i;
            MMXR_f_t_j(ia:ib-1) = j;
            MMXR_f_t_v(ia:ib-1) = XMrp3_t(ip,[imhu0+1:nmhu-ns_f(ir)])';            
            i = [ib0+(nmhu-ns_f(ir))*(ip-1)+imhup+1:ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0];
            j = [ibp+(nmhu-ns_f(ir+1))*(ip-1)+((nmhu-ns_f(ir+1))-imhup):-1:ibp+(nmhu-ns_f(ir+1))*(ip-1)+((nmhu-ns_f(ir+1))-imhu0)+1];
            ia = ib;ib = ia+length(i);
            MMXR_f_t_i(ia:ib-1) = i;
            MMXR_f_t_j(ia:ib-1) = j;
            MMXR_f_t_v(ia:ib-1) = XMrp2_t(ip,[imhup+1:imhu0])';
         end 
%
         for ir = 2:nr-1,
            if ir == 2,
               ibm = 0;
            else
               ibm = max(cumsum(blocksize_f_t(1:ir-2)));%Block index reference
            end
%
            ib0 = max(cumsum(blocksize_f_t(1:ir-1)));%Block index reference
            ibp = max(cumsum(blocksize_f_t(1:ir)));
%
            Xmask_f0m = (Xmhu2 < xmhubounce2(ir-1)) & (Xmhu < 0);%Only the half-bounce region is removed
            Xmask_f0m = nonzeros(~(Xmask_f0m(2,:)==1).*cumsum(ones(1,nmhu)))';
            Xmask_f0 = (Xmhu2 < xmhubounce2(ir)) & (Xmhu < 0);%Only the half-bounce region is removed
            Xmask_f0 = nonzeros(~(Xmask_f0(2,:)==1).*cumsum(ones(1,nmhu)))';
            Xmask_f0p = (Xmhu2 < xmhubounce2(ir+1)) & (Xmhu < 0);%Only the half-bounce region is removed
            Xmask_f0p = nonzeros(~(Xmask_f0p(2,:)==1).*cumsum(ones(1,nmhu)))';
%   
            imhum = sum((Xmhu(1,Xmask_f0m) < 0).*(Xmhu2(1,Xmask_f0m) > xmhubounce2(ir-1)));
            imhu0 = sum((Xmhu(1,Xmask_f0) < 0).*(Xmhu2(1,Xmask_f0) > xmhubounce2(ir))); 
            imhup = sum((Xmhu(1,Xmask_f0p) < 0).*(Xmhu2(1,Xmask_f0p) > xmhubounce2(ir+1)));
%
            XMr = XXMr(:,:,ir);
            XMr_t = XMr(:,Xmask_f0);%Matrix reduction along the angular direction (half-bounce region is removed)
            MMr_t = reshape(XMr_t',npn*(nmhu-ns_f(ir)),1,1);
%           
            i = [1+ib0:ibp];
            j = [1+ib0:ibp];
            ia = ib;ib = ia+length(i); 
            MMXR_f_t_i(ia:ib-1) = i;
            MMXR_f_t_j(ia:ib-1) = j;
            MMXR_f_t_v(ia:ib-1) = MMr_t;
%           
            XMrp = XXMrp(:,:,ir);
            XMrp_t = XMrp(:,Xmask_f0);%Matrix reduction along the angular direction (half-bounce region is removed)
            XMrp1_t = XMrp_t.*(Xmhu(:,Xmask_f0) < 0).*(Xmhu2(:,Xmask_f0) > xmhubounce2(ir+1));
            XMrp2_t = XMrp_t.*(Xmhu(:,Xmask_f0) < 0).*(Xmhu2(:,Xmask_f0) < xmhubounce2(ir+1)).*(Xmhu2(:,Xmask_f0) > xmhubounce2(ir));
            XMrp3_t = XMrp_t.*(Xmhu(:,Xmask_f0) > 0);           
%           
            XMrm = XXMrm(:,:,ir);
            XMrm_t = XMrm(:,Xmask_f0);%Matrix reduction along the angular direction (half-bounce region is removed)
            XMrm1_t = XMrm_t.*(Xmhu(:,Xmask_f0) < 0).*(Xmhu2(:,Xmask_f0) > xmhubounce2(ir));
            XMrm2_t = XMrm_t.*(Xmhu(:,Xmask_f0) > 0);
%            
            for ip = 1:npn, 
               i = [ib0+(nmhu-ns_f(ir))*(ip-1)+1:ib0+(nmhu-ns_f(ir))*(ip-1)+imhup];
               j = [ibp+(nmhu-ns_f(ir+1))*(ip-1)+1:ibp+(nmhu-ns_f(ir+1))*(ip-1)+imhup];
               ia = ib;ib = ia+length(i);     
               MMXR_f_t_i(ia:ib-1) = i;
               MMXR_f_t_j(ia:ib-1) = j;
               MMXR_f_t_v(ia:ib-1) = XMrp1_t(ip,[1:imhup])';
               i = [ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0+1:ib0+(nmhu-ns_f(ir))*ip];
               j = [ibp+(nmhu-ns_f(ir+1))*(ip-1)+imhup+1:ibp+(nmhu-ns_f(ir+1))*ip];
               ia = ib;ib = ia+length(i);
               MMXR_f_t_i(ia:ib-1) = i;
               MMXR_f_t_j(ia:ib-1) = j;
               MMXR_f_t_v(ia:ib-1) = XMrp3_t(ip,[imhu0+1:nmhu-ns_f(ir)])'; 
               i = [ib0+(nmhu-ns_f(ir))*(ip-1)+imhup+1:ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0];
               j = [ibp+(nmhu-ns_f(ir+1))*(ip-1)+((nmhu-ns_f(ir+1))-imhup):-1:ibp+(nmhu-ns_f(ir+1))*(ip-1)+((nmhu-ns_f(ir+1))-imhu0)+1];
               ia = ib;ib = ia+length(i);
               MMXR_f_t_i(ia:ib-1) = i;
               MMXR_f_t_j(ia:ib-1) = j;
               MMXR_f_t_v(ia:ib-1) = XMrp2_t(ip,[imhup+1:imhu0])';  
               i = [ib0+(nmhu-ns_f(ir))*(ip-1)+1:ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0];
               j = [ibm+(nmhu-ns_f(ir-1))*(ip-1)+1:ibm+(nmhu-ns_f(ir-1))*(ip-1)+imhu0];
               ia = ib;ib = ia+length(i);
               MMXR_f_t_i(ia:ib-1) = i;
               MMXR_f_t_j(ia:ib-1) = j;
               MMXR_f_t_v(ia:ib-1) = XMrm1_t(ip,[1:imhu0])';               
               i = [ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0+1:ib0+(nmhu-ns_f(ir))*ip];
               j = [ibm+(nmhu-ns_f(ir-1))*(ip-1)+imhum+1:ibm+(nmhu-ns_f(ir-1))*ip];
               ia = ib;ib = ia+length(i);
               MMXR_f_t_i(ia:ib-1) = i;
               MMXR_f_t_j(ia:ib-1) = j;
               MMXR_f_t_v(ia:ib-1) = XMrm2_t(ip,[imhu0+1:nmhu-ns_f(ir)])';
            end 
%
         end
%
         ir = nr;
         ibm = max(cumsum(blocksize_f_t(1:ir-2)));%Block index reference
         ib0 = max(cumsum(blocksize_f_t(1:ir-1)));%Block index reference
         ibp = max(cumsum(blocksize_f_t(1:ir)));
%
         Xmask_f0m = (Xmhu2 < xmhubounce2(ir-1)) & (Xmhu < 0);%Only the half-bounce region is removed
         Xmask_f0m = nonzeros(~(Xmask_f0m(2,:)==1).*cumsum(ones(1,nmhu)))';
         Xmask_f0 = (Xmhu2 < xmhubounce2(ir)) & (Xmhu < 0);%Only the half-bounce region is removed
         Xmask_f0 = nonzeros(~(Xmask_f0(2,:)==1).*cumsum(ones(1,nmhu)))';
%   
         imhum = sum((Xmhu(1,Xmask_f0m) < 0).*(Xmhu2(1,Xmask_f0m) > xmhubounce2(ir-1)));
         imhu0 = sum((Xmhu(1,Xmask_f0) < 0).*(Xmhu2(1,Xmask_f0) > xmhubounce2(ir))); 
%
         XMr = XXMr(:,:,ir);
         XMr_t = XMr(:,Xmask_f0);%Matrix reduction along the angular direction (half-bounce region is removed)
         MMr_t = reshape(XMr_t',npn*(nmhu-ns_f(ir)),1,1);
%        
         i = [1+ib0:ibp];
         j = [1+ib0:ibp];
         ia = ib;ib = ia+length(i);
         MMXR_f_t_i(ia:ib-1) = i;
         MMXR_f_t_j(ia:ib-1) = j;
         MMXR_f_t_v(ia:ib-1) = MMr_t;
%           
         XMrm = XXMrm(:,:,ir);
         XMrm_t = XMrm(:,Xmask_f0);%Matrix reduction along the angular direction (half-bounce region is removed)
         XMrm1_t = XMrm_t.*(Xmhu(:,Xmask_f0) < 0).*(Xmhu2(:,Xmask_f0) > xmhubounce2(ir));
         XMrm2_t = XMrm_t.*(Xmhu(:,Xmask_f0) > 0);
%   
        for ip = 1:npn,       
           i = [ib0+(nmhu-ns_f(ir))*(ip-1)+1:ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0];
           j = [ibm+(nmhu-ns_f(ir-1))*(ip-1)+1:ibm+(nmhu-ns_f(ir-1))*(ip-1)+imhu0];
           ia = ib;ib = ia+length(i);
           MMXR_f_t_i(ia:ib-1) = i;
           MMXR_f_t_j(ia:ib-1) = j;
           MMXR_f_t_v(ia:ib-1) = XMrm1_t(ip,[1:imhu0])';      
           i = [ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0+1:ib0+(nmhu-ns_f(ir))*ip];
           j = [ibm+(nmhu-ns_f(ir-1))*(ip-1)+imhum+1:ibm+(nmhu-ns_f(ir-1))*ip];
           ia = ib;ib = ia+length(i);
           MMXR_f_t_i(ia:ib-1) = i;
           MMXR_f_t_j(ia:ib-1) = j;
           MMXR_f_t_v(ia:ib-1) = XMrm2_t(ip,[imhu0+1:nmhu-ns_f(ir)])';
        end
%
        MMXR_f_t = sparse(MMXR_f_t_i(1:ib-1),MMXR_f_t_j(1:ib-1),MMXR_f_t_v(1:ib-1),nMMXP_f_t,nMMXP_f_t);%Create sparse radial transport matrix
%
%       save([fullfile(temppath,'temp_DKE.mat'],'MMXR_f_t');	
%
         if display_mode >= 1,info_dke_yp(2,['Zero order configuration space matrix calculations done in ',num2str(etime(clock,time0)),' (s)']);end
      end 
   end
else
    MMXR_f_t = sparse(nMMXP_f_t,nMMXP_f_t);%Create empty supermatrix
end

    
