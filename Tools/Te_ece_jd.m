function [tTe0,tTea,teTe1,teTe2] = Te_ece_jd(equil,cR,ctece,display_mode)
%
% initial guess
%
if nargin < 4,
    display_mode = 0;
end
%
nt = size(ctece,2);
%
ap = equil.ptx(end,1);
rho = equil.ptx(:,1)/ap;
%
if mean(cR(~isnan(cR))) > equil.Rp,% LFS measurements
    crho0 = (cR - equil.Rp)/ap;
    cmask0 = crho0 >= 0 & crho0 <= 1;% HFS measurements
else
    crho0 = interp1(equil.ptx(:,(end+1)/2),rho,cR - equil.Rp,'linear','extrap');
    cmask0 = crho0 >= 0 & crho0 <= 1;% HFS measurements
end    
%
for it = 1:nt,
    %
    cece = ctece(:,it);
    %
    cmask = cmask0 & cece > 0; 
    %
    crho = crho0(cmask);
    cece = cece(cmask);
    %
    [crho,ic] = sort(crho);
    cece = cece(ic);
    %
    Te0 = max(cece,[],1);
    Tea = min(cece,[],1);
    %
    eTe1 = 2;
    eTe2 = 2;
    %
    crho = [0;crho;1];
    cece = [Te0;cece;Tea];
    %
    %plot(crho,cece,'ro'); hold on; h = plot(crho,cece,'b'); hold off;
    %
    start = [Te0,Tea,eTe1,eTe2];
    %outputFcn = @(x,optimvalues,state) fitoutputfun(x,optimvalues,state,crho,cece);
    %options = optimset('OutputFcn',outputFcn,'TolX',0.1);
    options = optimset('TolX',0.1);
    %
    y = fminsearch(@(x)err_Tenefit_jd(x,crho,cece),start,options);
    tTe0(it) = y(1);
    tTea(it) = y(2);
    teTe1(it) = y(3);
    teTe2(it) = y(4);
    %
    if display_mode >= 2,
        %
        rho = 0:0.001:1;
        figure(it),clf
        plot(crho,cece,'ro',rho,Tenefit_jd(rho,tTe0(it),tTea(it),teTe1(it),teTe2(it)),'b-')
        %
    end
    %    
end
%


%