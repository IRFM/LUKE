function [XXf_cyl,xXFpar_cyl,ppar_cyl,pperp_cyl] = calc_fcyl_jd(XXf,betath_ref,pn,mhu,dp_cyl,ir_list,iir_display,pnmax_disp)
%
% this function transforms the distribution into cylindrical momentum space
% and calculates the parallel distribution function
%
% here the momentum grid pn is normalized to the reference thermal momentum
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
pmax = max(pn) + max(diff(pn));
np_cyl = ceil(pmax/dp_cyl);
ppar_cyl = linspace(-pmax,pmax,2*np_cyl + 1);
pperp_cyl = linspace(0,pmax,np_cyl + 1);
%
XXf_cyl = NaN(np_cyl + 1,2*np_cyl + 1,nr);
%
for iir = 1:nr, 
    %
    % spherical to cylindrical transformation
    %
    logXf_cyl = s2c_dke_yp(log(XXf(:,:,ir_list(iir))),pn,mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
    Xf_cyl = exp(logXf_cyl);%For accurate representation in figures 
    %
    Xppar_cyl = repmat(ppar_cyl,[np_cyl + 1,1]);%Grid for the distribution functions only
    Xpperp_cyl = repmat(pperp_cyl.',[1,2*np_cyl + 1]);
    Xp_cyl = sqrt(Xppar_cyl.*Xppar_cyl + Xpperp_cyl.*Xpperp_cyl);
    %
    Xf_cyl(Xf_cyl < eps) = 0;%Remove negative values and values less than computer accuracy
    Xf_cyl(Xp_cyl > pmax) = 0;%Remove values above max(ppar)
    Xf_cyl(isnan(Xf_cyl)) = 0;%Remove NaN values
    %
    XXf_cyl(:,:,iir) = Xf_cyl;
    %
end
%
% parallel distribution
%
XXfh_cyl = (XXf_cyl(1:np_cyl,:,:) + XXf_cyl(2:np_cyl + 1,:,:))/2;
XXpperph_cyl = repmat((pperp_cyl(1:np_cyl) + pperp_cyl(2:np_cyl + 1)).'/2,[1,2*np_cyl + 1,nr]);
dpperp_cyl = diff(pperp_cyl);
%
xXFpar_cyl = 2*pi*integral_dke_jd(dpperp_cyl,XXpperph_cyl.*XXfh_cyl,1);
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
    Fpar_cyl = xXFpar_cyl(:,iir_display);
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
    % ---------- 2D distribution function -----------
    %
    figure(1),clf,set(1,'Name',['2-D contour of f, iir = ',num2str(iir_display)])
    %
    x1 = ppar_cyl;
    xlab1 = 'p_{||}/p_{Te}';
    xlim1 = [-pnmax,pnmax];
    %
    x2 = pperp_cyl;
    xlab2 = 'p_{\perp}/p_{Te}';
    xlim2 = [0,pnmax];
    %
    y1 = Xf_cyl;
    %
    y2 = sqrt(pnmax^2 - ppar_cyl.^2);
    %
    graph2D_jd(x1,x2,y1.','','','',xlim1,xlim2,0,betath_ref,0:0.5:40,0,'-','r',2,20,1,max(max(y1)));
    %
    graph1D_jd(x1,y2,0,0,xlab1,xlab2,'',NaN,xlim1,xlim2,'--','none','k',2,20,gca,0.9,0.7,0.7);
    %
    axis('equal');axis([xlim1,xlim2]);
    %
    % ---------- 1D distribution function -----------
    %
    figure(2),clf,set(1,'Name',['1-D contour of f, iir = ',num2str(iir_display)])
    %
    y = Fpar_cyl;
    ylab = 'F_{||}';
    ylim = [eps,1];
    %
    graph1D_jd(x1,y,0,1,xlab1,ylab,'',NaN,xlim1,ylim,'-','none','r',2,20,gca,0.9,0.7,0.7);
    %
    set(gca,'ytick',10.^(-16:2:0))
    %
    if inter == 1,
        iir_display = input_dke_yp(['Select radial location index (1:',num2str(nr),'). Enter 0 to exit. '],0,0:nr);
    end
    %
end
