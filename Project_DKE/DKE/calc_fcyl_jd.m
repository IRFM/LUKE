function [XXf_cyl,xXFpar_cyl,ppar_cyl,xXFperp_cyl,pperp_cyl] = calc_fcyl_jd(XXf,betath_ref,pn,mhu,dp_cyl,ir_list,iir_display,pnmax_disp,XXmask,pmhucrit,ifig)
%
% this function transforms the distribution into cylindrical momentum space
% and calculates the parallel distribution function
%
% here the momentum grid pn is normalized to the reference thermal momentum
%
if nargin < 9,
    ifig = [1,2,3];
end
%
if nargin < 8,
    pnmax_disp = [];
end
%
if nargin < 7,
    iir_display = [];
end
%
if nargin < 6,
    ir_list = 1:size(XXf,3);
end
%
if nargin < 5,
    dp_cyl = 0.1;
end
%
if nargin < 4,
    error('Not enough input arguments');
end
%
nr = length(ir_list);
%
% Cylindrical grid (also see s2c_dke_yp)
%
pnmask = pn <= pnmax_disp;
pn = pn(pnmask);
XXf = XXf(pnmask,:,:);
XXmask = XXmask(pnmask,:,:);
%
pmax = max(pn) + max(diff(pn));
np_cyl = ceil(pmax/dp_cyl);
ppar_cyl = linspace(-pmax,pmax,2*np_cyl + 1);
pperp_cyl = linspace(0,pmax,np_cyl + 1);
%
XXf_cyl = NaN(np_cyl + 1,2*np_cyl + 1,nr);
XXmask_cyl = NaN(np_cyl + 1,2*np_cyl + 1,nr);
%
np = length(pn);
Xxmhu_crit = NaN(np,nr);
%
% XXf(XXf <= 0) = 0;
%XXf(XXf <= eps) = 0;
%
for iir = 1:nr, 
    %
    % spherical to cylindrical transformation
    %
    logXf_cyl = s2c_dke_yp(log(XXf(:,:,ir_list(iir))),pn,mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
    Xf_cyl = exp(logXf_cyl);%For accurate representation in figures 
    %
    Xmask_cyl = s2c_dke_yp(double(XXmask(:,:,ir_list(iir))),pn,mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
    %
    Xppar_cyl = repmat(ppar_cyl,[np_cyl + 1,1]);%Grid for the distribution functions only
    Xpperp_cyl = repmat(pperp_cyl.',[1,2*np_cyl + 1]);
    Xp_cyl = sqrt(Xppar_cyl.*Xppar_cyl + Xpperp_cyl.*Xpperp_cyl);
    %
%     Xf_cyl(Xf_cyl <= 0) = 0;%Remove negative values and values less than computer accuracy
    Xf_cyl(Xf_cyl <= eps) = 0;%Remove negative values and values less than computer accuracy
    Xf_cyl(Xp_cyl > pmax) = 0;%Remove values above max(ppar)
    Xf_cyl(isnan(Xf_cyl)) = 0;%Remove NaN values
    %
    XXf_cyl(:,:,iir) = Xf_cyl;
    XXmask_cyl(:,:,iir) = Xmask_cyl;
    %
    for ipn = 1:np,
        Xxmhu_crit(ipn,ir_list(iir)) = min([1,mhu(XXmask(ipn,:,ir_list(iir)))]);
    end
    %
end
%
% parallel distribution
%
XXfh_perp_cyl = (XXf_cyl(1:np_cyl,:,:) + XXf_cyl(2:np_cyl + 1,:,:))/2;
XXfh_par_cyl = (XXf_cyl(:,1:2*np_cyl,:) + XXf_cyl(:,2:2*np_cyl + 1,:))/2;
XXpperph_cyl = repmat((pperp_cyl(1:np_cyl) + pperp_cyl(2:np_cyl + 1)).'/2,[1,2*np_cyl + 1,nr]);
dpperp_cyl = diff(pperp_cyl);
dppar_cyl = diff(ppar_cyl);
%
xXFpar_cyl = 2*pi*integral_dke_jd(dpperp_cyl,XXpperph_cyl.*XXfh_perp_cyl,1);
xXFperp_cyl = 2*pi*integral_dke_jd(dppar_cyl,XXfh_par_cyl,2);
%
if isempty(iir_display), 
    inter = 1;
    iir_display = input_dke_yp(['Select radial location index (1:',num2str(nr),'). Enter 0 to exit. '],1,0:nr);
else
    inter = 0;
end
%
while iir_display > 0,
    %
    Xf_cyl = XXf_cyl(:,:,iir_display);
    Xmask_cyl = XXmask_cyl(:,:,iir_display);
    Fpar_cyl = xXFpar_cyl(:,iir_display);
    Fperp_cyl = xXFperp_cyl(:,iir_display);
    %
    if isempty(pnmax_disp),
        pnmax = pmax;
    elseif isnan(pnmax_disp),
        pnmax = min([pmax,min(min(Xp_cyl(Xf_cyl == 0)))]);
    else
        pnmax = pnmax_disp;
    end
    %
    Xf_cyl(Xp_cyl > pnmax) = 0;
    %
%     x1 = ppar_cyl;
%     xlab1 = 'p_{||}/p_{Te}';
%     xlim1 = [-pnmax,pnmax];
    x1 = ppar_cyl*betath_ref;
    xlab1 = 'p_{||}';%/(mc)
    xlim1 = [-pnmax,pnmax]*betath_ref;
    %
%     x2 = pperp_cyl;
%     xlab2 = 'p_{\perp}/p_{Te}';
%     xlim2 = [0,pnmax];
    x2 = pperp_cyl*betath_ref;
    xlab2 = 'p_{\perp}';%/(mc)
    xlim2 = [0,pnmax]*betath_ref;
    %
    y2 = sqrt(pnmax^2 - ppar_cyl.^2)*betath_ref;
    %
    if isempty(pmhucrit) || all(isnan(pmhucrit)),
        pmhucrit = Xxmhu_crit(:,iir_display).';
    else
        pmhucrit = pmhucrit(pnmask);
    end
    x4 = pn*betath_ref.*pmhucrit;
    y4 = pn*betath_ref.*sqrt(1 - pmhucrit.^2);
    %
    % ---------- 2D distribution function -----------
    %
    if ifig(1) > 0,
        figure(ifig(1)),clf,set(ifig(1),'Name',['2-D contour of f, iir = ',num2str(iir_display)])
        %figure(ifig(1)),hold on,set(1,'Name',['2-D contour of f, iir = ',num2str(iir_display)])
        %
        y1 = Xf_cyl;
        y3 = Xmask_cyl;
        %
        graph2D_jd(x1,x2,y1.','','','',xlim1,xlim2,0,betath_ref,0:0.2:40,0,'-','k',0.5,20,1,max(max(y1)));hold on
%         graph2D_jd(x1,x2,y3.','','','',xlim1,xlim2,0,NaN,0.5,0,'-','k',2,20);
        graph1D_jd(x4,y4,0,0,'','','',NaN,xlim1,xlim2,'--','none','k',0.5,20);
        %
        graph1D_jd(x1,y2,0,0,xlab1,xlab2,'',NaN,xlim1,xlim2,'--','none','k',2,20,gca,0.9,0.7,0.8);
        %
        axis('equal');axis([xlim1,xlim2]);
    end
    %
    % ---------- 1D par distribution function -----------
    %
    if ifig(2) > 0,
        figure(ifig(2)),clf,set(ifig(2),'Name',['F//, iir = ',num2str(iir_display)])
        %
        y = Fpar_cyl;
        ylab = 'F_{||}';
        ylim = [eps,1];
        %
        graph1D_jd(x1,y,0,1,xlab1,ylab,'',NaN,xlim1,ylim,'-','none','r',2,20,gca,0.9,0.7,0.7);
        %
        set(gca,'ytick',10.^(-16:2:0))
    end
    %
    %
    % ---------- 1D perp distribution function -----------
    %
    if ifig(3) > 0,
        figure(ifig(3)),clf,set(ifig(3),'Name',['Fperp, iir = ',num2str(iir_display)])
        %
        y = Fperp_cyl;
        ylab = 'F_{\perp}';
        ylim = [eps,1];
        %
        graph1D_jd(x2,y,0,1,xlab2,ylab,'',NaN,xlim2,ylim,'-','none','r',2,20,gca,0.9,0.7,0.7);
        %
        set(gca,'ytick',10.^(-16:2:0))
        %
        if inter == 1,
            iir_display = input_dke_yp(['Select radial location index (1:',num2str(nr),'). Enter 0 to exit. '],0,0:nr);
        end
    end
    %
    if inter == 0,
        iir_display = 0;
    end
    %
end
