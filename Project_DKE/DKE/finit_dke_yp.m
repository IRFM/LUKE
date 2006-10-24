function [XXfinit] = finit_dke_yp(dkeparam,display,equilDKE,gridDKE,mksa,Zmomcoef,waveparam,XXf0_in)
%
%   Calculate initial distribution function for the 3D electron relativistic drift kinetic solver.
%
%   by Y. Peysson (CEA-DRFC) (yves.peysson@cea.fr) and J. Decker (CEA-DRFC) (joan.decker@cea.fr)
%
npn = gridDKE.npn;
nmhu = gridDKE.nmhu;
nr = gridDKE.nr;
ir_display = gridDKE.ir_display_out;
pn = gridDKE.pn;
pn2 = gridDKE.pn2;
dpn = gridDKE.dpn;
mhu = gridDKE.mhu;
dmhu = gridDKE.dmhu;
Xpn = gridDKE.Xpn;
Xmhu = gridDKE.Xmhu;
zZi = equilDKE.zZi;
%
xrho = equilDKE.xrho;
%
gamma = Zmomcoef.gamma;
Xgamma = Zmomcoef.Xgamma;
v = Zmomcoef.v;
%
display_mode = display.display_mode;
dp_cyl = display.dp_cyl;
nlevel = display.nlevel;
%
dke_mode = dkeparam.dke_mode;
%
[xTe_norm,xne_norm,xzni_norm,xzTi_norm,xnloss_norm,xbetath,xlnc_e,xnhu,xrnhuth] = normcoef_dke_yp(mksa,equilDKE,gridDKE);
%
XXfinit = zeros(npn,nmhu,nr);%Defined on the distribution function grid (half grid)
%
if size(waveparam,2) ~= 1,
    dkeparam.initguess_f = 0;
else
    if isstruct(waveparam) | isnan(waveparam(ir_display,1,5)) == 1 | isnan(waveparam(ir_display,1,6)) == 1,
         dkeparam.initguess_f = 0;
    else
         xvparmin_lh = 1./waveparam(:,1,6)/mksa.betath_ref;
         xvparmax_lh = 1./waveparam(:,1,5)/mksa.betath_ref;
    end
end
%
for ir = 1:nr,	
	if dkeparam.initguess_f == 0 & isempty(XXf0_in) == 1,
		fM = exp(-pn.*pn./(1 + gamma)/xTe_norm(ir))/2/pi/xTe_norm(ir)/sqrt(2*pi*xTe_norm(ir));%Maxwellian distribution normalized to normalized density ne_norm (1st order gamma corrections)
		XfM = fM'*ones(1,nmhu);
		normfM = 2*pi*integral_dke_jd(dpn(:),pn(:).*pn(:).*integral_dke_jd(dmhu,XfM,2),1);
		XfM = xne_norm(ir)*XfM/normfM;
		Xf0 = XfM;
		title_initguess = 'Relativistic Maxwellian';        
	elseif dkeparam.initguess_f == 1 & isempty(XXf0_in) == 1,
%
%   Initial guess for the distribution function from ref. V.Fuchs et al.,Phys. Fluids 28 (1985) 3619. 
%   (Only for the old method for calculating the quasilinear diffusion coefficient of the LH operator)
%
		alpha = 2 - 2/(2+zZi(1));%Dominant ion contribution (it is a guess only)
		beta = 2 - alpha;
		Tp1nr = (xvparmax_lh(ir)^(alpha+1) - xvparmin_lh(ir)^(alpha+1))*(alpha-1)/(alpha+1) - (alpha-1)*(xvparmax_lh(ir) - xvparmin_lh(ir))*xvparmin_lh(ir)^alpha + xvparmax_lh(ir)^(alpha-1) - xvparmin_lh(ir)^(alpha-1);
		Tp2nr = 2*(alpha-1)*(xvparmax_lh(ir) - xvparmin_lh(ir))*xvparmin_lh(ir)^(alpha-2) - (xvparmax_lh(ir)^(alpha-1) - xvparmin_lh(ir)^(alpha-1));
		Tpnr = Tp1nr/Tp2nr;
		Tpr = 1.0*Tpnr;%Relativistic correction (if necessary)
		Xpperp2 = Xpn.*Xpn.*(1 - Xmhu.*Xmhu);
		Xppar = Xpn.*Xmhu;
		Xppar2 = Xppar.*Xppar;
		Xpparmin = xvparmin_lh(ir)*sqrt((1+Xpperp2*mksa.betath_ref^2)/(1-mksa.betath_ref^2*xvparmin_lh(ir)^2));
		Xpparmax = xvparmax_lh(ir)*sqrt((1+Xpperp2*mksa.betath_ref^2)/(1-mksa.betath_ref^2*xvparmax_lh(ir)^2));
		Xmaskplat = (Xppar >= Xpparmin).*(Xppar <= Xpparmax);
		Xfsth0 = Xmaskplat.*exp(-Xpperp2/2/Tpr)/2/pi/Tpr;
		Xmaskback = (Xppar <= Xpparmin);
		Xfsth1 = Xmaskback.*exp(-Xpn.*Xpn/2/Tpr).*exp(Xpparmin.*Xpparmin/2/Tpr)/2/pi/Tpr;
		Xmaskup = (Xppar > Xpparmax);
		Xfsth2 = Xmaskup.*exp(-(Xpn.*Xpn.*(Xppar./Xpparmax).^(2/zZi(1)) - Xpparmax.*Xpparmax)/Tpr/2)/2/pi/Tpr;%See thesis of R.Arslanbekov
		Xfsth = Xfsth0+Xfsth1+Xfsth2;
		fM = xne_norm(ir)*exp(-pn.*pn./(1+gamma)/xTe_norm(ir))/2/pi/xTe_norm(ir)/sqrt(2*pi*xTe_norm(ir));
		XfM = fM'*ones(1,nmhu);
        normfM = 2*pi*integral_dke_jd(dpn(:),pn2(:).*integral_dke_jd(dmhu,XfM,2),1);
		normfsth = 2*pi*integral_dke_jd(dpn(:),pn2(:).*integral_dke_jd(dmhu,Xfsth,2),1);
		XfM = XfM/normfM;
		Xfsth = Xfsth/normfsth;
		lambda = 1/(1 + Xfsth(min(find(Xmaskplat(:,nmhu-1)==1)),nmhu-1)/XfM(min(find(Xmaskplat(:,nmhu-1)==1)),nmhu-1));
		Xf0 = XfM + Xfsth*lambda;   
        normf0 = 2*pi*integral_dke_jd(dpn(:),pn2(:).*integral_dke_jd(dmhu,Xf0,2),1);
		Xf0 = xne_norm(ir)*Xf0/normf0;
		title_initguess = 'Fuchs et al. LH model';
	else
		Xf0 = XXf0_in(:,:,ir);
		title_initguess = 'Initial distribution from input arguments';
	end
	XXfinit(:,:,ir) = Xf0;
end
%
% *************************** Display initial distribution function ***************************
%
dbstop 87
if display_mode == 2,
	Fig_InitDistr = figure('Name','Initial distribution');	
	Fig_InitDistrp0 = figure('Name','Initial distribution at pperp=0');
	Fig_ElecVeloc = figure('Name','Electron velocity');
end
%
for ir = 1:nr,
	if display_mode == 2,
		if dke_mode == 1,
%
			view = 0;
%
			if ir == ir_display-1,
				figure(Fig_InitDistr),subplot(131);zoom on
				view = 1;
			elseif ir == ir_display,
				figure(Fig_InitDistr),subplot(132);zoom on
				view = 1;
			elseif ir == ir_display+1,
				figure(Fig_InitDistr),subplot(133);zoom on
				view = 1;
			end	
%		
			if view == 1,		
				normf0 = 2*pi*integral_dke_jd(dpn(:),pn2(:).*integral_dke_jd(dmhu,Xf0,2),1);
				[logXf0_cyl,ppar_cyl,dppar_cyl,pperp_cyl,dpperp_cyl] = s2c_dke_yp(log(Xf0),pn,mhu,dp_cyl);
				Xf0_cyl = exp(logXf0_cyl);%For accurate representation in figures 
%
				Xppar_cyl = ones(length(pperp_cyl),1)*ppar_cyl(:)';
				Xpperp_cyl = pperp_cyl(:)*ones(1,length(ppar_cyl));
				Xp_cyl = sqrt(Xppar_cyl.*Xppar_cyl + Xpperp_cyl.*Xpperp_cyl);
				Xmhu_cyl = Xppar_cyl./sqrt(Xppar_cyl.^2+Xpperp_cyl.^2);
				Xgamma_cyl = sqrt(1 + Xp_cyl.*Xp_cyl*mksa.betath_ref*mksa.betath_ref);
				Xvpar_cyl = Xppar_cyl./Xgamma_cyl;
%
        		Xf0_cyl = Xf0_cyl.*(Xf0_cyl>0);%Remove negative values
        		Xf0_cyl = Xf0_cyl.*(Xp_cyl<max(ppar_cyl));%Remove values above max(ppar)
                Xf0_cyl(isnan(Xf0_cyl)) = 0;%Remove NaN values
%
        		curr0 = 2*pi*integral_dke_jd(dpn(:),pn2(:).*(pn(:)./gamma(:)).*integral_dke_jd(dmhu,Xmhu.*Xf0,2),1);
        		curr0_cyl = 2*pi*integral_dke_jd(dpperp_cyl(:),pperp_cyl(:).*integral_dke_jd(dppar_cyl,Xvpar_cyl.*Xf0_cyl,2),1);
%
				C = contour(ppar_cyl,pperp_cyl,log(Xf0_cyl),[-20:20/nlevel:0]);axis('equal');
				faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
				text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,['rho = ',num2str(xrho(ir))]);
				text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*10,['Te(norm) = ',num2str(xTe_norm(ir))]);
				text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*15,['ne(norm) = ',num2str(xne_norm(ir))]);
				xlabel('ppar/pth-ref');ylabel('pperp/pth-ref');title(title_initguess);
				drawnow;
%
			end
%
			view = 0;
			if ir == ir_display-1,
				figure(Fig_InitDistrp0),subplot(231);zoom on
				view = 1;
			elseif ir == ir_display,
				figure(Fig_InitDistrp0),subplot(232);zoom on
				view = 1;
			elseif ir == ir_display+1,
				figure(Fig_InitDistrp0),subplot(233);zoom on
				view = 1;
			end
%
			if view == 1,
				semilogy(-v,XfM(:,1),'g--',v,XfM(:,nmhu),'g--',-v,Xf0(:,1),'c-',v,Xf0(:,nmhu),'c-');%Forward and backward directions only
				axis([-max(v),max(v),1e-20,10]);grid on;zoom on
				xlabel('vpar/vth-ref');ylabel('f(pperp = 0)');title(['Norm.(rho=',num2str(xrho(ir)),') = ',num2str(normf0)]);
				drawnow;
			end
%           
			view = 0;
			if ir == ir_display-1,
				figure(Fig_ElecVeloc),subplot(234);zoom on
				view = 1;
			elseif ir == ir_display,
				figure(Fig_ElecVeloc),subplot(235);zoom on
				view = 1;
			elseif ir == ir_display+1,
				figure(Fig_ElecVeloc),subplot(236);zoom on
				view = 1;
			end  
%
			if view == 1,
				plot(pn,pn,'r-.',pn,v,'b:');grid on;zoom on
				xlabel('p/pth-ref');ylabel('v/vth-ref');title(['j = ',num2str(curr0)]);
				drawnow;
			end
		else
			view = 0;
			if ir == ir_display,
				figure(Fig_InitDistr),subplot(132);zoom on
				view = 1;
			end
%
			if view == 1,
				normf0 = 2*pi*integral_dke_jd(dpn(:),pn2(:).*integral_dke_jd(dmhu,Xf0,2),1);
        		[logXf0_cyl,ppar_cyl,dppar_cyl,pperp_cyl,dpperp_cyl] = s2c_dke_yp(log(Xf0),pn,mhu,dp_cyl);
        		Xf0_cyl = exp(logXf0_cyl);%For accurate representation in figures 
%
        		Xppar_cyl = ones(length(pperp_cyl),1)*ppar_cyl(:)';
        		Xpperp_cyl = pperp_cyl(:)*ones(1,length(ppar_cyl));
        		Xp_cyl = sqrt(Xppar_cyl.*Xppar_cyl + Xpperp_cyl.*Xpperp_cyl);
        		Xmhu_cyl = Xppar_cyl./sqrt(Xppar_cyl.^2 + Xpperp_cyl.^2);
        		Xgamma_cyl = sqrt(1 + Xp_cyl.*Xp_cyl*mksa.betath_ref*mksa.betath_ref);
        		Xvpar_cyl = Xppar_cyl./Xgamma_cyl;
%
        		Xf0_cyl = Xf0_cyl.*(Xf0_cyl>0);%Remove negative values
        		Xf0_cyl = Xf0_cyl.*(Xp_cyl<max(ppar_cyl));%Remove values above max(ppar)
%
        		curr0 = 2*pi*integral_dke_jd(dpn(:),pn2(:).*(pn(:)./gamma(:)).*integral_dke_jd(dmhu,Xmhu.*Xf0,2),1);
        		curr0_cyl = 2*pi*integral_dke_jd(dpperp_cyl(:),pperp_cyl(:).*integral_dke_jd(dppar_cyl,Xvpar_cyl.*Xf0_cyl,2),1);
%
				C = contour(ppar_cyl,pperp_cyl,log(Xf0_cyl),[-20:20/nlevel:0]);axis('equal');
				faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
				text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,['rho = ',num2str(xrho(ir))]);
				text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*10,['Te(norm) = ',num2str(xTe_norm(ir))]);
				text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*15,['ne(norm) = ',num2str(xne_norm(ir))]);
				xlabel('ppar/pth-ref');ylabel('pperp/pth-ref');title(title_initguess);
				drawnow;
%
			end
%
			view = 0;
			if ir == ir_display,
				figure(Fig_InitDistrp0),zoom on;drawnow;
				view = 1;
			end
%
			if view == 1,
				semilogy(-v,XfM(:,1),'g--',v,XfM(:,nmhu),'g--',-v,Xf0(:,1),'c-',v,Xf0(:,nmhu),'c-');%Forward and backward directions only
				axis([-max(v),max(v),1e-20,10]);grid on;zoom on
				xlabel('vpar/vth-ref');ylabel('f(pperp = 0)');title(['Norm.(rho=',num2str(xrho(ir)),') = ',num2str(normf0)]);
				drawnow;
			end
%           
			view = 0;
			if ir == ir_display,
				figure(Fig_ElecVeloc);zoom on;drawnow;
				view = 1;
			end    
%
			if view == 1,
				plot(pn,pn,'r-.',pn,v,'b:');grid on;zoom on
				xlabel('p/pth-ref');ylabel('v/vth-ref');title(['j = ',num2str(curr0)]);
				drawnow;
			end
%						
        end
	end
end