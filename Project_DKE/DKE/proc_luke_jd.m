function proc_luke_jd(data,ir_display,p_opt,dp_cyl,pnmax,subtitle)
%LUKE -  Function which plots the results from LUKE data structures
%
% This function plots the results from LUKE data structures
%
% To use this function from saved rundke files:
%		data = load(filename);
%		proc_luke_jd(data,ir_display,p_opt,dp_cyl,pnmax,subtitle);
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr> and J. Decker (CEA/DSM/IRFM) <joan.decker@cea.fr>
%
if nargin < 6,
    subtitle = '';
end
if nargin < 5,
    pnmax = NaN;
end
if nargin < 4,
    dp_cyl = 0.1;
end
if nargin < 3,
    p_opt = -1;
end
if nargin < 2,
    ir_display = 0;
end
%
Znorm = data.Znorm;
Zcurr = data.Zcurr;
ZP0 = data.ZP0;
dke_out = data.dke_out;
radialDKE = data.radialDKE;
equilDKE = data.equilDKE;
momentumDKE = data.momentumDKE;
gridDKE = data.gridDKE;
Zmomcoef = data.Zmomcoef;
Zbouncecoef = data.Zbouncecoef;
Zmripple = data.Zmripple;
mksa = data.mksa;
%
simul_id = dke_out.simul.id;
%
style0 = 'none';
style = '-';
style2 = '--';
marker = 'none';
marker1 = '+';
marker2 = 'o';
marker3 = 's';
marker4 = '.';
color1 = 'k';
color2 = 'r';
color3 = 'b';
color4 = 'g';
color5 = 'm';
color6 = 'c';
%
width = 0.5;
width2 = 2;
siz = 20;
%
red = 0.9;
lspace = 0.7;
lspace2 = 0.5;
bspace = 0.7;
bspace2 = 0.5;
%
xrho = equilDKE.xrho; 
xpsin = equilDKE.xpsin;
xTe = equilDKE.xTe;
xne = equilDKE.xne;
%
pn = momentumDKE.pn;
mhu = momentumDKE.mhu;
%
nr = length(xrho);
%
scocurr = sign(equilDKE.psia_apRp)*sign(equilDKE.XBphi(1,1));
%
J_tot = Zcurr.x_0_fsav*mksa.j_ref*scocurr;
P_rf = ZP0.x_rf_fsav.'*mksa.P_ref;
P_e = ZP0.x_e_fsav*mksa.P_ref;
P_tot = P_rf + P_e;
%
I_tot = sum(J_tot.*equilDKE.xdA_dke);
%
if ir_display == 0,
    diaryname = ['res_',simul_id,'.log'];
else
    tir_display = num2str(ir_display);
    diaryname = ['res_',simul_id,'_irho_',tir_display,'.log'];
end
delete(diaryname)
diary(diaryname)
%
disp(['Simulation id: ',dke_out.simul.id]);
disp(['Simulation date: ',timeid_jd(dke_out.simul.timeid)]);
disp(['User id: ',dke_out.simul.userid]);
disp(['LUKE Version: ',dke_out.simul.LUKEversion]);
disp(' ');
%
%if I_tot < 0,
%    disp('Warning : sign of J inverted for positive total current')
%    J_tot = -J_tot;
%    I_tot = -I_tot;
%end
%
p_rf_2piRp = sum(P_rf.*equilDKE.xdV_2piRp_dke);
p_e_2piRp = sum(P_e.*equilDKE.xdV_2piRp_dke);
p_tot_2piRp = sum(P_tot.*equilDKE.xdV_2piRp_dke);
EtaRp = I_tot/(p_tot_2piRp*2*pi);    
%
eta = J_tot./P_tot;
i_peak = find(P_rf == max(P_rf));
eta_peak = eta(i_peak);
%
if nr > 1,
    %
    dep = 1;
    ip_rf_2piRp = 0;
    xp_rf_2piRp = P_rf.*equilDKE.xdV_2piRp_dke;
    xI_tot = J_tot.*equilDKE.xdA_dke;
    %
    xp_rf_2piRp(xp_rf_2piRp < 0) = 0;
    %
    p_rf_2piRp_peak = 0;
    I_tot_peak = 0;
    %
    peaks.ir = []; 
    peaks.p_rf_2piRp = [];
    peaks.I_tot = [];
    %
    for ir = 1:nr,
        if (xp_rf_2piRp(ir) - ip_rf_2piRp)*dep < 0,
            if dep == 1,% ir-1 is a peak
                peaks.ir = [peaks.ir,ir-1];
                dep = -1;
            else% ir-1 is a low - power and current shared
                %
                p_rf_2piRp_peak = p_rf_2piRp_peak - xp_rf_2piRp(ir-1)/2;  
                I_tot_peak = I_tot_peak - xI_tot(ir-1)/2;
                %
                peaks.p_rf_2piRp = [peaks.p_rf_2piRp,p_rf_2piRp_peak];
                peaks.I_tot = [peaks.I_tot,I_tot_peak];
                %
                p_rf_2piRp_peak = xp_rf_2piRp(ir-1)/2;  
                I_tot_peak = xI_tot(ir-1)/2;
                %
                dep = 1;
            end
        end
        %
        ip_rf_2piRp = xp_rf_2piRp(ir);
        p_rf_2piRp_peak = p_rf_2piRp_peak + xp_rf_2piRp(ir);  
        I_tot_peak = I_tot_peak + xI_tot(ir);
    end  
    %
    if dep == 1,%finish with a high
        peaks.ir = [peaks.ir,nr];
    end
    peaks.p_rf_2piRp = [peaks.p_rf_2piRp,p_rf_2piRp_peak];
    peaks.I_tot = [peaks.I_tot,I_tot_peak];
    %
    peaks.rho = xrho(peaks.ir);
    peaks.spsin = sqrt(xpsin(peaks.ir));
    peaks.Te = xTe(peaks.ir);
    peaks.ne = xne(peaks.ir);
    peaks.EtaRp = peaks.I_tot./(peaks.p_rf_2piRp*2*pi);
    peaks.ksirf = 32.7*peaks.I_tot.*peaks.ne*1e-20./(peaks.Te*2*pi.*peaks.p_rf_2piRp);
    %
    disp(['Total current (I): ',num2str(I_tot),' MA (positive for co-current)'])
	if isinf(equilDKE.Rp),
    	disp(['RF power (P/2piRp): ',num2str(p_rf_2piRp),' MW/m'])
    	disp(['Ohmic power (P/2piRp): ',num2str(p_e_2piRp),' MW/m'])
    	disp(['Total power (P/2piRp): ',num2str(p_tot_2piRp),' MW/m'])
    	disp(['CD efficiency (I*Rp/P): ',num2str(EtaRp),' A.m/W'])
        %
        for ipeak = 1:length(peaks.ir),
            disp(' ');
            disp(['RF Peak # ',num2str(ipeak)])
            disp(['Position rho: ',num2str(peaks.rho(ipeak))])
            disp(['Position sqrt(xpsin): ',num2str(peaks.spsin(ipeak))])
            disp(['Temperature Te: ',num2str(peaks.Te(ipeak)),' keV'])
            disp(['Density ne: ',num2str(peaks.ne(ipeak)/1e20),' *10^20 m^-3'])
            disp(' ');
            disp(['RF power (P/2piRp): ',num2str(peaks.p_rf_2piRp(ipeak)),' MW/m'])
            disp(['Total current (I): ',num2str(peaks.I_tot(ipeak)),' MA'])
            disp(['CD efficiency (I*Rp/P): ',num2str(peaks.EtaRp(ipeak)),' A.m/W'])
            disp(['Normalized CD efficiency xi: ',num2str(peaks.ksirf(ipeak))])
        end
	else
    	disp(['RF power (P): ',num2str(p_rf_2piRp*(2*pi*equilDKE.Rp)),' MW'])
    	disp(['Ohmic power (P): ',num2str(p_e_2piRp*(2*pi*equilDKE.Rp)),' MW'])
    	disp(['Total power (P): ',num2str(p_tot_2piRp*(2*pi*equilDKE.Rp)),' MW'])
    	disp(['CD efficiency (I/P): ',num2str(EtaRp/equilDKE.Rp),' A/W'])
        %
        for ipeak = 1:length(peaks.ir),
            disp(' ');
            disp(['RF Peak # ',num2str(ipeak)])
            disp(['Position rho: ',num2str(peaks.rho(ipeak))])
            disp(['Position sqrt(xpsin): ',num2str(peaks.spsin(ipeak))])
            disp(['Temperature Te: ',num2str(peaks.Te(ipeak)),' keV'])
            disp(['Density ne: ',num2str(peaks.ne(ipeak)/1e20),' *10^20 m^-3'])
            disp(' ');
            disp(['RF power (P): ',num2str(peaks.p_rf_2piRp(ipeak)*(2*pi*equilDKE.Rp)),' MW'])
            disp(['Total current (I): ',num2str(peaks.I_tot(ipeak)),' MA'])
            disp(['CD efficiency (I/P): ',num2str(peaks.EtaRp(ipeak)/equilDKE.Rp),' A/W'])
            disp(['Normalized CD efficiency xi: ',num2str(peaks.ksirf(ipeak))])
        end
	end
    %
    % power profiles
    %
    figure('Name',['RF power density profile - ',dke_out.simul.id]),clf
    %
    xlab = '\rho';
    ylab = 'P_{RF} (MW/m^3)';
    tit = '';
    %
    xlim = [0,1];
    xtick = 0:0.2:1;
    ylim = NaN;
    %
    graph1D_jd(xrho,P_rf,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker1,color2,width2,siz,gca,red,lspace,bspace);
    set(gca,'xtick',xtick);
    %
    print_jd(p_opt,[simul_id,'_Prf_profile'],'.');
    %
    figure('Name',['Ohmic power density profile - ',dke_out.simul.id]),clf
    %
    xlab = '\rho';
    ylab = 'P_{OHM} (MW/m^3)';
    tit = '';
    %
    xlim = [0,1];
    xtick = 0:0.2:1;
    ylim = NaN;
    %
    graph1D_jd(xrho,P_e,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker1,color2,width2,siz,gca,red,lspace,bspace);
    set(gca,'xtick',xtick);
    %
    print_jd(p_opt,[simul_id,'_Pe_profile'],'.');
    %
    figure('Name',['Total power density profile - ',dke_out.simul.id]),clf
    %
    xlab = '\rho';
    ylab = 'P_{TOT} (MW/m^3)';
    tit = '';
    %
    xlim = [0,1];
    xtick = 0:0.2:1;
    ylim = NaN;
    %
    graph1D_jd(xrho,P_tot,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker1,color2,width2,siz,gca,red,lspace,bspace);
    set(gca,'xtick',xtick);
    %
    print_jd(p_opt,[simul_id,'_Ptot_profile'],'.');
    %
    % current profile
    %
    figure('Name',['Current density profile - ',dke_out.simul.id]),clf
    %
    ylab = 'J (MA/m^2)';
    tit = 'J > 0 for co-current';
    ylim = NaN;
    %
    graph1D_jd(xrho,J_tot,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker1,color2,width2,siz,gca,red,lspace,bspace2);
    set(gca,'xtick',xtick);
    %set(gca,'ylim',[0,max(get(gca,'ylim'))])
    %
    print_jd(p_opt,[simul_id,'_J_profile'],'.');
    %
    % efficiency profile
    %
    figure('Name',['Current efficiency profile - ',dke_out.simul.id]),clf
    %
    ylab = '\eta (A.m/W)';
    tit = '';
    ylim = 2*[min([0,eta_peak]),max([0,eta_peak])];
    %
    graph1D_jd(xrho,eta,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker1,color2,width2,siz,gca,red,lspace,bspace);
    set(gca,'xtick',xtick);
    %
    print_jd(p_opt,[simul_id,'_eta_profile'],'.');
    %
    figure('Name',['Current and RF power density profiles - ',dke_out.simul.id]),clf
    %    
    ylab1 = 'J (MA/m^2)';
    ylab2 = 'P_{RF} (MW/m^3)';
    tit = 'J > 0 for co-current';
    ylim1 = NaN;
    ylim2 = NaN;
    %
    graph1D2jd(xrho,J_tot,xrho,P_rf,xlab,ylab1,ylab2,tit,xlim,ylim1,ylim2,...
    style,marker1,color2,width2,style,marker1,color3,width2,siz,red,lspace2,bspace2);
    %
    print_jd(p_opt,[simul_id,'_J_Prf_profile'],'.');
	%
	if exist('Zmripple'),
		if ~isempty(Zmripple) & sum(sum(Zmripple.Xnhuloss)) ~= 0,
	    	figure('Name',['Magnetic ripple losses - ',dke_out.simul.id])
			[ax] = graph1D_jd(xrho,dke_out.xMRR_flux,0,0,'\rho','Ripple losses (m-3.s-1)',subtitle,NaN,[0,1],[0,max(max([dke_out.xMRR_flux(:),dke_out.xMRR_tau(:)]))],style,marker1,color2,width2,siz,gca,red,lspace,bspace);hold on
			[ax] = graph1D_jd(xrho,dke_out.xMRR_tau,0,0,'\rho','Ripple losses (m-3.s-1)',subtitle,NaN,[0,1],[0,max(max([dke_out.xMRR_flux(:),dke_out.xMRR_tau(:)]))],style,marker1,color3,width2,siz,gca,red,lspace,bspace);hold on
			legend('Boundary losses','Volumic losses');
			print_jd(p_opt,[simul_id,'_RippleLosses_profile'],'.');
			%
			figure('Name',['Cones angles - ',dke_out.simul.id])
			[ax] = graph1D_jd(xrho,Zmripple.xthetabanana,0,0,'\rho','Angle (Deg.)',subtitle,NaN,[0,1],[0,60],style,marker1,color2,width2,siz,gca,red,lspace,bspace);hold on
			[ax] = graph1D_jd(xrho,Zmripple.xthetaloss,0,0,'\rho','Angle (Deg.)',subtitle,NaN,[0,1],[0,60],style,marker1,color3,width2,siz,gca,red,lspace,bspace);hold on
			legend('Banana cone angle','Loss cone angle');
			print_jd(p_opt,[simul_id,'_RippleConeAngles_profile'],'.');
			%
			ylab1 = 'p/p_{Te}';
    		ylab2 = 'p/p_{Te(loc.)}';
    		ytick = [0:2:10];
    		ylim1 = [0,10];
    		ylim2 = [0,40];
			figure('Name',['Collision detrapping threshold - ',dke_out.simul.id])
			[ax] = graph1D_jd(xrho,Zmripple.xpndetrap,0,0,'\rho','',subtitle,NaN,[0,1],'',style,marker1,color2,width2,siz,gca,red,lspace,bspace);hold on
			[ax] = graph1D_jd(xrho,Zmripple.xpnth,0,0,'\rho','',subtitle,NaN,[0,1],'',style,marker1,color3,width2,siz,gca,red,lspace,bspace);hold on
			[ax] = graph1D2jd(xrho,Zmripple.xpnth,xrho,Zmripple.xpndetrap./Zmripple.xpnth,xlab,ylab1,ylab2,tit,xlim,ylim1,ylim2,style,marker1,color3,width2,style,marker1,color4,width2,siz,red,lspace2,bspace);
  			set(gca,'ytick',ytick);
			legend('p_{c}/p_{Te}','p_{Te(loc.)}/p_{Te}','p_{c}/p_{Te(loc.)}');
			print_jd(p_opt,[simul_id,'_RippleDetrapping_profile'],'.');
		end  
	end
else
    %
    disp(['normalized current: ',num2str(Zcurr.x_0_fsav)])
    disp(['normalized RF power: ',num2str(ZP0.x_rf_fsav)])
    disp(['normalized Ohmic power: ',num2str(ZP0.x_e_fsav)])
    disp(['normalized Total power: ',num2str(ZP0.x_e_fsav+ZP0.x_rf_fsav)])
    disp(['normalized CD efficiency: ',num2str(Zcurr.x_0_fsav./(ZP0.x_e_fsav+ZP0.x_rf_fsav))])
    %
end
%
if ir_display > 0 & ir_display <= nr,
    %
    disp(['normalized radius for distribution plots: ',num2str(xrho(ir_display))])
    %
    [logXf0_cyl_ref,ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(log(dke_out.XXf0(:,:,ir_display)),pn,mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
    Xf0_cyl_ref = exp(logXf0_cyl_ref);%For accurate representation in figures 
    %
    logXfinit_cyl_ref = s2c_dke_yp(log(dke_out.XXfinit(:,:,ir_display)),pn,mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
    Xfinit_cyl_ref = exp(logXfinit_cyl_ref);%For accurate representation in figures 
    %
    XDparpar_cyl_ref = s2c_dke_yp(dke_out.ZXXD_rf.parpar_ij(:,:,ir_display),pn,mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
    %
    Xppar_cyl_ref = ones(length(pperp_cyl_ref),1)*ppar_cyl_ref(:)';%Grid for the distribution functions only
    Xpperp_cyl_ref = pperp_cyl_ref(:)*ones(1,length(ppar_cyl_ref));
    Xp_cyl_ref = sqrt(Xppar_cyl_ref.*Xppar_cyl_ref + Xpperp_cyl_ref.*Xpperp_cyl_ref);
    %
    Xf0_cyl_ref = Xf0_cyl_ref.*(Xf0_cyl_ref>0);%Remove negative values
    Xf0_cyl_ref = Xf0_cyl_ref.*(Xp_cyl_ref<=max(ppar_cyl_ref));%Remove values above max(ppar)
    Xf0_cyl_ref(isnan(Xf0_cyl_ref)) = 0;%Remove NaN values
    %
    Xfinit_cyl_ref = Xfinit_cyl_ref.*(Xfinit_cyl_ref>0);%Remove negative values
    Xfinit_cyl_ref = Xfinit_cyl_ref.*(Xp_cyl_ref<=max(ppar_cyl_ref));%Remove values above max(ppar)
    Xfinit_cyl_ref(isnan(Xfinit_cyl_ref)) = 0;%Remove NaN values
    %
    % Remove values less than computer accuracy
    %
    Xmask = abs(Xf0_cyl_ref) < eps;
    %
    pnmax_S = max(momentumDKE.pn_S);
    pnmax_0 = min(min(Xp_cyl_ref(Xmask)));
    %
    if isnan(pnmax),
        pnmax = min([pnmax_0,pnmax_S]);
    end
    %
    Xmask = Xp_cyl_ref >= pnmax;    
    %
    Xf0_cyl_ref(Xmask) = 0;
    Xfinit_cyl_ref(Xmask) = 0;
    XDparpar_cyl_ref(Xmask) = 0;
    %
    Fpar0_cyl_ref = 2*pi*integral_dke_jd(dpperp_cyl_ref,Xpperp_cyl_ref.*Xf0_cyl_ref,1);
    Fparinit_cyl_ref = 2*pi*integral_dke_jd(dpperp_cyl_ref,Xpperp_cyl_ref.*Xfinit_cyl_ref,1);		
    %
    % Figures
    %
    radialloc = ['\rho = ',num2str(xrho(ir_display))];
    figure('Name',['2-D contour of f - ',dke_out.simul.id]),clf
    %
    x1 = ppar_cyl_ref;
    xlab1 = 'p_{||}/p_{Te}';
    xlim1 = [-pnmax,pnmax];
    %
    x2 = pperp_cyl_ref;
    xlab2 = 'p_{\perp}/p_{Te}';
    xlim2 = [0,pnmax];
    %
    leg = {'f_M','f'};
    %
    y1 = Xfinit_cyl_ref;
    y2 = Xf0_cyl_ref;
    y3 = XDparpar_cyl_ref;
    y3max = max(max(y3));
    %
    y9 = sqrt(pnmax^2 - x1.^2);
    %
    graph2D_jd(x1,x2,y1','','',radialloc,xlim1,xlim2,0,mksa.betath_ref,[0:0.5:pnmax],0,style,color3,width,siz,1,max(max(y1)));
    hold on
    graph2D_jd(x1,x2,y2','','',radialloc,xlim1,xlim2,0,mksa.betath_ref,[0:0.5:pnmax],0,style,color2,width2,siz,1,max(max(y1)));
    %
    if y3max > 1e-5,
        graph2D_jd(x1,x2,y3','','',radialloc,xlim1,xlim2,0,NaN,y3max/100,0,style,color4,width2,siz);
    end
    hold off
    %
    graph1D_jd(x1,y9,0,0,xlab1,xlab2,radialloc,NaN,xlim1,xlim2,style,marker,color1,width2,siz,gca,red,lspace,bspace);
    %
    axis('equal');axis([xlim1,xlim2]);
    legend(leg);
    %
    if equilDKE.Rp ~= Inf,
        bounce_ripple_jd(1,pnmax,gridDKE.xmhubounce2,ir_display,Zmripple);
    end
    %
    print_jd(p_opt,[simul_id,'_f_2D',tir_display],'.');
    %
    if max(max(abs(y3))) > 0,
        %
        figure('Name',['2-D contour of D|| - ',dke_out.simul.id]),clf
        %
        cont = 10;
        %
        graph2D_jd(x1,x2,y3','','',radialloc,xlim1,xlim2,1,NaN,cont,0,style,NaN,width,siz,1);
        graph1D_jd(x1,y9,0,0,xlab1,xlab2,radialloc,NaN,xlim1,xlim2,style,marker,color1,width2,siz,gca,red,lspace,bspace);
        axis('equal');axis([xlim1,xlim2])
        %
        if equilDKE.Rp ~= Inf,
            bounce_ripple_jd(1,pnmax,gridDKE.xmhubounce2,ir_display,Zmripple);
        end
        colorbar
        %
        print_jd(p_opt,[simul_id,'_DQL',tir_display],'.');
        %
    end
    %
    % ---------- parallel distribution difference-----------
    %
    figure('Name',['F||-F||M - ',dke_out.simul.id]),clf
    %
    y1 = Fpar0_cyl_ref - Fparinit_cyl_ref;
    ylab = 'F_{||} - F_{||M}';
    ylim = NaN;
    %
    graph1D_jd(x1,y1,0,0,xlab1,ylab,radialloc,NaN,xlim1,ylim,style,marker,color2,width2,siz,gca,red,lspace,bspace);
    %
    print_jd(p_opt,[simul_id,'_F0mFM_1D',tir_display],'.');
    %
    % ---------- parallel distribution -----------
    %
    figure('Name',['F|| - ',dke_out.simul.id]),clf
    %
    y1 = Fparinit_cyl_ref;
    y2 = Fpar0_cyl_ref;
    ylab = 'F_{||}';
    ylim = [eps,1];
    %
    graph1D_jd(x1,y1,0,1,'','',radialloc,NaN,xlim1,ylim,style,marker,color3,width,siz,gca,red,lspace,bspace);
    graph1D_jd(x1,y2,0,1,xlab1,ylab,radialloc,leg,xlim1,ylim,style,marker,color2,width2,siz);
    legend(leg);
    %
    print_jd(p_opt,[simul_id,'_F0pFM_1D_',tir_display],'.');
end
%
diary off
%


