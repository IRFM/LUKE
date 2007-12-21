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
if isfield(display,'display_init'),
    display_mode = display.display_init;
else
    display_mode = 0;
end
%
dp_cyl = display.dp_cyl;
nlevel = display.nlevel;
%
dke_mode = dkeparam.dke_mode;
%
[xTe_norm,xne_norm,xzni_norm,xzTi_norm,xnloss_norm,xbetath,xlnc_e,xnhu,xrnhuth] = normcoef_dke_yp(mksa,equilDKE,gridDKE);
%
XXfinit = zeros(npn,nmhu,nr);%Defined on the distribution function grid (half grid)
%
if exist('waveparam'),
    if isreal(waveparam.bdNpar_rf),%General RF power spectrum
         dkeparam.initguess_f = 0;
    else,%dNpar is made imaginary to identify square power spectrum type (for the Lower Hybrid wave comparison with theoretical models only)
         xvparmin_lh = 1./(waveparam.bNpar_rf + imag(waveparam.bdNpar_rf)/2)/mksa.betath_ref;
         xvparmax_lh = 1./(waveparam.bNpar_rf - imag(waveparam.bdNpar_rf)/2)/mksa.betath_ref;
    end
else
    dkeparam.initguess_f = 0;%Maxwellian distribition function as initial guess if no RF wave in the plasma
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
		Tp1nr = (xvparmax_lh^(alpha+1) - xvparmin_lh^(alpha+1))*(alpha-1)/(alpha+1) - (alpha-1)*(xvparmax_lh - xvparmin_lh)*xvparmin_lh^alpha + xvparmax_lh^(alpha-1) - xvparmin_lh^(alpha-1);
		Tp2nr = 2*(alpha-1)*(xvparmax_lh - xvparmin_lh)*xvparmin_lh^(alpha-2) - (xvparmax_lh^(alpha-1) - xvparmin_lh^(alpha-1));
		Tpnr = Tp1nr/Tp2nr;
		Tpr = (1 + 8*mksa.betath_ref/5)*Tpnr;%Relativistic correction
        Tpr = Tpnr;
		Xpperp2 = Xpn.*Xpn.*(1 - Xmhu.*Xmhu);
		Xppar = Xpn.*Xmhu;
		Xppar2 = Xppar.*Xppar;
		Xpparmin = xvparmin_lh*sqrt((1+Xpperp2*mksa.betath_ref^2)/(1-mksa.betath_ref^2*xvparmin_lh^2));
		Xpparmax = xvparmax_lh*sqrt((1+Xpperp2*mksa.betath_ref^2)/(1-mksa.betath_ref^2*xvparmax_lh^2));
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
		title_initguess = 'V. Fuchs et al., Phys. Fluids, 28 (1985) 3619';
	else
		Xf0 = XXf0_in(:,:,ir);
		title_initguess = 'Initial distribution from input arguments';
	end
	XXfinit(:,:,ir) = Xf0;
end
%
% *************************** Display initial distribution function ***************************
%
if display_mode ~= 0,
	Fig_InitDistr = figure('Name','Initial distribution');	
	Fig_InitDistrp0 = figure('Name','Initial distribution at pperp=0');
	Fig_ElecVeloc = figure('Name','Electron velocity');
end
%
for ir = 1:nr,
	if display_mode ~= 0,
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
				figure(Fig_InitDistr),zoom on
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
                graph2D_jd(ppar_cyl,pperp_cyl,Xf0_cyl','p_{||}/p_{Te}','p_{\perp}/p_{Te}',title_initguess,[-dkeparam.pnmax_S,dkeparam.pnmax_S],[0,dkeparam.pnmax_S],0,mksa.betath_ref,[0:1:dkeparam.pnmax_S],0,'-','r',2,20,0.9,max(max(Xf0_cyl)));
                axis('equal');axis([-dkeparam.pnmax_S,dkeparam.pnmax_S,0,dkeparam.pnmax_S]);drawnow;
				faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
				text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*6,['\rho = ',num2str(xrho(ir))]);
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
                graph1D_jd(-v,XfM(:,1),0,1,'','','',NaN,[-max(v),max(v)],[1e-20,10],'-','none','b',1,20,gca,0.9,0.7,0.7);
                graph1D_jd(v,XfM(:,nmhu),0,1,'','','',NaN,[-max(v),max(v)],[1e-20,10],'-','none','b',1,20,gca,0.9,0.7,0.7);
                graph1D_jd(-v,Xf0(:,1),0,1,'','','',NaN,[-max(v),max(v)],[1e-20,10],'-','none','r',2,20,gca,0.9,0.7,0.7);
                graph1D_jd(v,Xf0(:,nmhu),0,1,'v_{||}/v_{Te}','f(p_{\perp}=0)',['Norm.=',num2str(normf0),', \beta_{Te}=',num2str(mksa.betath_ref),', J_{LH}=',num2str(curr0)],NaN,[-max(v),max(v)],[1e-20,10],'-','none','r',2,20,gca,0.9,0.7,0.7);
                grid on;zoom on;drawnow;				
			end
%           
			view = 0;
			if ir == ir_display,
				figure(Fig_ElecVeloc);zoom on;drawnow;
				view = 1;
			end    
%
			if view == 1,
                graph1D_jd(pn,pn,0,0,'','','',NaN,[0,max(pn)],[0,max(v)],'-','none','b',1,20,gca,0.9,0.7,0.7);
                graph1D_jd(pn,v,0,0,'p/p_{Te}','v/v_{Te}','',NaN,[0,max(pn)],[0,max(v)],'-','none','r',2,20,gca,0.9,0.7,0.7);
                grid on;zoom on;drawnow;				
			end
%						
        end
	end
end