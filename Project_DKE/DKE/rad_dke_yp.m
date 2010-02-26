function [ZXXD_a,ZXXF_a] = rad_dke_yp(dkeparam,display,equilDKE,gridDKE,mksa,Zbouncecoef,Zmomcoef,transpfaste)
%
% Calculation of the anomalous radial fast electron transport matrix coefficients for arbitrary magnetic plasma equilibrium 
%
% by Y. Peysson (CEA-IRFM) <yves.peysson@cea.fr> and J. Decker (CEA-IRFM) <joan.decker@cea.fr>
%
if nargin < 7,
	error('Wrong number of input arguments for rad_dke_yp');
end
%
% Initialization of the coefficients
%
% Terms from Sp at l+1/2 (Notations: _imj -> (i,j+1+2);_ipj -> (i+1,j+1/2)
%
ZXXD_a.pp_ipj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%momentum dynamics only
ZXXD_a.pp_imj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%momentum dynamics only
ZXXD_a.pm_ipj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%momentum dynamics only
ZXXD_a.pm_imj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%momentum dynamics only
ZXXD_a.pr_ipj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
ZXXD_a.pr_imj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
ZXXF_a.p_ipj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%momentum dynamics only
ZXXF_a.p_imj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%momentum dynamics only
%
% Terms from Sksi at l+1/2 (Notations: _ijp -> (i+1/2,j+1);_ijm -> (i+1/2,j)
%
ZXXD_a.mm_ijp = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%momentum dynamics only
ZXXD_a.mm_ijm = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%momentum dynamics only
ZXXD_a.mp_ijp = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%momentum dynamics only
ZXXD_a.mp_ijm = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%momentum dynamics only
ZXXD_a.mr_ijp = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
ZXXD_a.mr_ijm = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
ZXXF_a.m_ijp = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%momentum dynamics only
ZXXF_a.m_ijm = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%momentum dynamics only
%
% Terms from Spsi at (i+1/2,j+1/2) (Notations: _lm -> (l);_lp -> (l+1);
%
ZXXD_a.rr_lm = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%radial dynamics only
ZXXD_a.rr_lp = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%radial dynamics only
ZXXD_a.rp_lm = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
ZXXD_a.rp_lp = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
ZXXD_a.rm_lm = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
ZXXD_a.rm_lp = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
ZXXF_a.r_lm = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%radial dynamics only
ZXXF_a.r_lp = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%radial dynamics only
%
% Terms used by the old scheme only for momentum cross-derivatives (M.
% Shoucri and I. Shkarofsky,Comp. Phys. Comm., 82 (1994) 287)
%
ZXXD_a.pp_ij = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
ZXXD_a.pm_ij = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
ZXXD_a.mp_ij = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
ZXXF_a.p_ij = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
%
if ~isempty(transpfaste), 
    %
    [qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;%Universal physics constants
    %
    npn = gridDKE.npn;
    nmhu = gridDKE.nmhu;
    nr = gridDKE.nr;
    xdpsin = gridDKE.xdpsin_dke;
    xdpsinm = gridDKE.xdpsinm_dke;
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
    xx0 = equilDKE.xx0;
    xBp0 = equilDKE.xBp0;
    xB0 = equilDKE.xB0;
    ap = equilDKE.ap;
    Rp = equilDKE.Rp;
    psia_apRp = equilDKE.psia_apRp;
    xrho = equilDKE.xrho;
    %
    betath_ref = mksa.betath_ref;
    nhu_ref = mksa.nhu_ref;
    %
    bounce_mode = dkeparam.bounce_mode;
    %
    dp_cyl = display.dp_cyl;
    nlevel = display.nlevel;
    display_mode = display.display_mode;
    %
    time0 = clock;
    %
    [xTe_norm,xne_norm,xzni_norm,xzTi_norm,xnloss_norm,xbetath] = normcoef_dke_yp(mksa,equilDKE,gridDKE);   
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
    xmaxDpsi = zeros(1,nr);
    xmaxVpsi = zeros(1,nr);
    xEc_r_threshold = zeros(1,nr);
%
    for ir = 1:nr,	
        ivpar_r_threshold = find(abs(Xvpar) >= xvparmin_r(ir),1);
        if isempty(ivpar_r_threshold),% xvparmin_r larger than last grid point
          ivpar_r_threshold = npn;
        end
        %
        xEc_r_threshold(ir) = mc2*(sqrt(1+pn(ivpar_r_threshold).*pn(ivpar_r_threshold)*betath_ref^2) - 1);%in keV
        %
        if real(transpfaste.Dr_model)==0,%No vpar dependence
            XDpsiv = xDr(ir)*ones(size(npn,nmhu)).*(abs(Xvpar) >= xvparmin_r(ir))/(ap*ap*nhu_ref);%Normalized to the central collision frequency
        elseif real(transpfaste.Dr_model)==1,%Magnetic turbulence model: Dr(r)*vpar_ref/vth_ref
            XDpsiv = xDr(ir)*(abs(Xvpar) - xvparmin_r(ir)).*(abs(Xvpar) >= xvparmin_r(ir))/xvparmin_r(ir)/(ap*ap*nhu_ref);%Normalized to the central collision frequency
        end
        XXDpsi(:,:,ir) = XDpsiv;%3-D radial diffusion matrix (radial profile dependence) (psi coordinate)
        xmaxDpsi(ir) = max(max(XXDpsi(:,:,ir)));%Maximum value of the radial diffusion coefficient (psi coordinate)
        %
        if real(transpfaste.Vr_model)==0,%No vpar dependence
            XVpsiv = xVr(ir)*ones(size(npn,nmhu)).*(abs(Xvpar) >= xvparmin_r(ir))/(ap*nhu_ref);%Normalized to the central collision frequency (psi coordinate)
        elseif real(transpfaste.Vr_model)==1,%Magnetic turbulence model: Vr(r) = Vr0(r)*vpar_ref/vth_ref
            XVpsiv = xVr(ir)*(abs(Xvpar) - xvparmin_r(ir)).*(abs(Xvpar) >= xvparmin_r(ir))/xvparmin_r(ir)/(ap*nhu_ref);%Normalized to the central collision frequency (psi coordinate)
        end
        XXVpsi(:,:,ir) = XVpsiv;%3-D radial pinch matrix (radial profile dependence) (psi coordinate)
        xmaxVpsi(ir) = max(max(XXVpsi(:,:,ir)));%Maximum value of the radial convection coefficient (psi coordinate)
    end
%
    if display_mode == 2,
        Fig_radialdiff = figure('Name','Fast electron radial diffusion');
        %	
        figure(Fig_radialdiff),subplot(121);zoom on;
        [XDpsiv_cyl,ppar_cyl,dppar_cyl,pperp_cyl] = s2c_dke_yp(XXDpsi(:,:,ir_display),pn,mhu,dp_cyl);
        %
        Xppar_cyl = ones(length(pperp_cyl),1)*ppar_cyl(:)';
        Xpperp_cyl = pperp_cyl(:)*ones(1,length(ppar_cyl));
        Xp_cyl = sqrt(Xppar_cyl.*Xppar_cyl + Xpperp_cyl.*Xpperp_cyl);
        %
        XDpsiv_cyl = XDpsiv_cyl.*(XDpsiv_cyl>0);%Remove negative values
        XDpsiv_cyl = XDpsiv_cyl.*(Xp_cyl<max(ppar_cyl));%Remove values above max(ppar)
        %
        contourf(ppar_cyl,pperp_cyl,XDpsiv_cyl,nlevel);
        if xmaxDpsi(ir_display)>0,colorbar;end
        axis('equal');
        faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
        text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,['rho = ',num2str(xrho(ir_display))]);
        text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*10,['v//-threshold(norm) = ',num2str(xvparmin_r(ir_display))]);
        text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*15,['Ec-threshold = ',num2str(xEc_r_threshold(ir_display)),' (keV)']);
        xlabel('ppar/pth-ref');ylabel('pperp/pth-ref');title('Radial diffusion coefficient (nhu-ref*psia_apRp*psia_apRp)');
        %
        subplot(122),plot(pn./gamma,XXDpsi(:,nmhu,ir_display),'b');
        faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
        text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,'mhu = 1');
        xlabel('v/vth-ref');ylabel('Dr (nhu-ref*psia_apRp*psia_apRp)');title('Radial diffusion coefficient ');drawnow
        %
        Fig_radialpinch = figure('Name','Fast electron radial pinch');
        figure(Fig_radialpinch),subplot(121);zoom on,
        [XVpsiv_cyl,ppar_cyl,dppar_cyl,pperp_cyl] = s2c_dke_yp(XXVpsi(:,:,ir_display),pn,mhu,dp_cyl);
        %
        Xppar_cyl = ones(length(pperp_cyl),1)*ppar_cyl(:)';
        Xpperp_cyl = pperp_cyl(:)*ones(1,length(ppar_cyl));
        Xp_cyl = sqrt(Xppar_cyl.*Xppar_cyl + Xpperp_cyl.*Xpperp_cyl);
        %
        XVpsiv_cyl = XVpsiv_cyl.*(XVpsiv_cyl>0);%Remove negative values
        XVpsiv_cyl = XVpsiv_cyl.*(Xp_cyl<max(ppar_cyl));%Remove values above max(ppar)
        %
        contourf(ppar_cyl,pperp_cyl,XVpsiv_cyl,nlevel);
        if xmaxVpsi(ir_display)>0,colorbar;end
        axis('equal');
        faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
        text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,['rho = ',num2str(xrho(ir_display))]);
        text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*10,['v//-threshold(norm) = ',num2str(xvparmin_r(ir_display))]);
        text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*15,['Ec-threshold = ',num2str(xEc_r_threshold(ir_display)),' (keV)']);
        xlabel('ppar/pth-ref');ylabel('pperp/pth-ref');title('Radial convection coefficient (nhu-ref*psia_apRp)');
        %
        subplot(122),plot(pn./gamma,XXVpsi(:,nmhu,ir_display),'r');
        faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
        text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,'mhu = 1');
        xlabel('v/vth-ref');ylabel('Vr (nhu-ref*psia_apRp)');title('Radial convection coefficient ');drawnow
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
        ylabel('Maximum value (nhu-ref*psia_apRp*psia_apRp)');
        title('Radial diffusion');
        subplot(122),plot(xrho,xmaxVpsi,'r-o');grid on;zoom on;
        if sum(xmaxVpsi) ~= 0,axis([0,1,0,1.1*max(xmaxVpsi)]);end
        xlabel('rho');
        ylabel('Maximum value (nhu-ref*psia_apRp)');
        title('Radial convection');drawnow
    end
    % 
    xdpsinmm = [0,xdpsin(1:nr-1)];
    xdpsinpp = [xdpsin(2:nr),0];
    %
    XXdpsin = reshape(repmat(xdpsin,npn*nmhu,1),[npn,nmhu,nr]);   
    XXdpsinm = reshape(repmat(xdpsinm,npn*nmhu,1),[npn,nmhu,nr]); 
    XXdpsinp = reshape(repmat(xdpsinp,npn*nmhu,1),[npn,nmhu,nr]); 
    XXdpsinmm = reshape(repmat(xdpsinmm,npn*nmhu,1),[npn,nmhu,nr]);   
    XXdpsinpp = reshape(repmat(xdpsinpp,npn*nmhu,1),[npn,nmhu,nr]);
    %
    XXdeltalp = XXdpsinpp./(XXdpsinpp + XXdpsin);%Grid interpolation coefficients
    XXdeltalm = XXdpsin./(XXdpsinmm + XXdpsin);%Grid interpolation coefficients
    %
    XXDpsimm = zeros(npn,nmhu,nr);
    XXDpsimm(:,:,2:nr) = XXDpsi(:,:,1:nr-1);
    XXDpsipp = zeros(npn,nmhu,nr);
    XXDpsipp(:,:,1:nr-1) = XXDpsi(:,:,2:nr);
    %
    XXVpsimm = zeros(npn,nmhu,nr);
    XXVpsimm(:,:,2:nr) = XXVpsi(:,:,1:nr-1);
    XXVpsipp = zeros(npn,nmhu,nr);
    XXVpsipp(:,:,1:nr-1) = XXVpsi(:,:,2:nr);
    %
    % Terms from Spsi at (i+1/2,j+1/2) (Notations: _lm -> (l);_lp -> (l+1);
    %
    ZXXD_a.rr_lm = (1 - XXdeltalm).*XXDpsi + XXdeltalm.*XXDpsimm;%Evaluation of the radial diffusion rate on the flux grid (linear interpolation)
    ZXXD_a.rr_lp = (1 - XXdeltalp).*XXDpsipp + XXdeltalp.*XXDpsi;%Evaluation of the radial diffusion rate on the flux grid (linear interpolation)
    ZXXF_a.r_lm = (1 - XXdeltalm).*XXVpsi + XXdeltalm.*XXVpsimm;%Evaluation of the radial convection on the flux grid (linear interpolation)
    ZXXF_a.r_lp = (1 - XXdeltalp).*XXVpsipp + XXdeltalp.*XXVpsi;%Evaluation of the radial convection on the flux grid (linear interpolation)
end


