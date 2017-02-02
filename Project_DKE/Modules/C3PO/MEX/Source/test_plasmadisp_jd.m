% test_plasmadisp_jd
%
clear all
close all
%
p_opt = -1;
%
nx = 101;
nx_as = 21;
x = linspace(-10,10,nx);
x_as = logspace(-10,10,nx_as);
NZ_list = [10,10,100,1000,10000];
NZn = length(NZ_list);
%
% Matlab function
%
Z_mat = NaN*ones(NZn,nx);
Zp_mat = NaN*ones(NZn,nx);
Zpp_mat = NaN*ones(NZn,nx);
time_mat = NaN*ones(1,NZn);
%
Z_as_mat = NaN*ones(NZn,nx_as);
Zp_as_mat = NaN*ones(NZn,nx_as);
Zpp_as_mat = NaN*ones(NZn,nx_as);
%
leg0 = {};
%
for iZ = 1:NZn,
    tic
    [Z_mat(iZ,:),Zp_mat(iZ,:),Zpp_mat(iZ,:)] = Zplasma(x,NZ_list(iZ));
    time_mat(iZ) = toc;
    [Z_as_mat(iZ,:),Zp_as_mat(iZ,:),Zpp_as_mat(iZ,:)] = Zplasma(x_as,NZ_list(iZ));
    leg0{iZ} = ['mat, N = ',num2str(NZ_list(iZ))];
end
%
leg0 = leg0(2:end);
%
% erfcc
%
tic
xx = [x,zeros(1,1024 - nx)];
%
[yr,yi] = erfcc(nx,real(xx),imag(xx));
%
Z_erf = sqrt(pi)*(i*yr(1:nx) - yi(1:nx));
Zp_erf = -2*(1 + x.*Z_erf);
Zpp_erf = -2*(Z_erf - 2*x.*(1 + x.*Z_erf));
%
time_erf = toc;
%
xx_as = [x_as,zeros(1,1024 - nx_as)];
%
[yr_as,yi_as] = erfcc(nx_as,real(xx_as),imag(xx_as));
%
Z_as_erf = sqrt(pi)*(i*yr_as(1:nx_as) - yi_as(1:nx_as));
Zp_as_erf = -2*(1 + x_as.*Z_as_erf);
Zpp_as_erf = -2*(Z_as_erf - 2*x_as.*(1 + x_as.*Z_as_erf));
%
% series
%
Z_as_ser = NaN*ones(1,nx_as);
Zp_as_ser = NaN*ones(1,nx_as);
Zpp_as_ser = NaN*ones(1,nx_as);
theory = NaN*ones(1,nx_as);
theoryp = NaN*ones(1,nx_as);
theorypp = NaN*ones(1,nx_as);
%
nx1 = (nx_as + 1)/2;
%
xpow_as = x_as(1:nx1-1);
%
Z_as_ser(1:nx1-1) = i*sqrt(pi)*exp(-xpow_as.^2) - 2*xpow_as.*...
    (1 - 2*xpow_as.^2/3 + 4*xpow_as.^4/15);% - 8*xpow_as.^6/105
Zp_as_ser(1:nx1-1) = -2*i*xpow_as*sqrt(pi).*exp(-xpow_as.^2) - 2.*...
    (1 - 2*xpow_as.^2 + 4*xpow_as.^4/3);% - 8*xpow_as.^6/15
Zpp_as_ser(1:nx1-1) = 2*i*sqrt(pi)*(2*xpow_as.^2 - 1).*exp(-xpow_as.^2) + 8*xpow_as.*...
    (1 - 4*xpow_as.^2/3);% + 4*xpow_as.^4/5
%
theory(1:nx1-1) = (16*xpow_as.^7/105)./(2*xpow_as);
theoryp(1:nx1-1) = (16*xpow_as.^6/15)./(2);
theorypp(1:nx1-1) = (32*xpow_as.^5/5)./(8*xpow_as);
%
theory(1:nx1-1) = max([theory(1:nx1-1);eps*ones(1,nx1-1)]);
theoryp(1:nx1-1) = max([theoryp(1:nx1-1);eps*ones(1,nx1-1)]);
theorypp(1:nx1-1) = max([theorypp(1:nx1-1);eps*ones(1,nx1-1)]);
%
xinv_as = 1./x_as(nx1+1:end);
%
Z_as_ser(nx1+1:end) = i*sqrt(pi)*exp(-1./xinv_as.^2) - xinv_as.*...
    (1 + xinv_as.^2/2 + 3*xinv_as.^4/4);% + 15*xinv_as.^6/8
Zp_as_ser(nx1+1:end) = -2*i./xinv_as*sqrt(pi).*exp(-1./xinv_as.^2) + xinv_as.^2.*...
    (1 + 3*xinv_as.^2/2 + 15*xinv_as.^4/4);% + 105*xinv_as.^6/8
Zpp_as_ser(nx1+1:end) = 2*i*sqrt(pi)*(2./xinv_as.^2 - 1).*exp(-1./xinv_as.^2) - 2*xinv_as.^3.*...
    (1 + 3*xinv_as.^2 + 45*xinv_as.^4/4);% + 105*xinv_as.^6/2
%
theory(nx1+1:end) = (15*xinv_as.^7/8)./(xinv_as);
theoryp(nx1+1:end) = (105*xinv_as.^8/8)./(xinv_as.^2);
theorypp(nx1+1:end) = (105*xinv_as.^9)./(2*xinv_as.^3);
%
theory(nx1+1:end) = max([theory(nx1+1:end);eps*ones(1,nx1-1)]);
theoryp(nx1+1:end) = max([theoryp(nx1+1:end);2*eps./xinv_as.^2]);
theorypp(nx1+1:end) = max([theorypp(nx1+1:end);4*eps./xinv_as.^4]);
%
Z_thei = sqrt(pi)*exp(-x.^2);
Zp_thei = -2*x*sqrt(pi).*exp(-x.^2);
Zpp_thei = 2*sqrt(pi)*(2*x.^2 - 1).*exp(-x.^2);
%
% figures
%
figure(1),clf
%
xlim = [-10,10];
ylim = NaN;
%
leg = ['erfcc',leg0,'theory'];
%
graph1D_jd(x,real(Z_erf),0,0,'x','Z(x)','',NaN,xlim,ylim,'-','none','k',2,20,gca,0.9,0.7,0.7);
graph1D_jd(x,real(Z_mat(2:end,:)).',0,0,'','','',NaN,xlim,ylim,'-','none',NaN,2);
graph1D_jd(x,Z_thei,0,0,'','','',leg,xlim,ylim,'-','none','m',2);
graph1D_jd(x,imag(Z_erf),0,0,'','','',NaN,xlim,ylim,'--','none','k',2);
graph1D_jd(x,imag(Z_mat(2:end,:)).',0,0,'','','',NaN,xlim,ylim,'-','none',NaN,0.5);
%
figure(2),clf
%
xlim = [1,100000];
ylim = NaN;
%
leg = {'erfcc','mat'};
%
graph1D_jd(xlim,time_erf*[1,1],1,1,'N','time (s)','',NaN,xlim,ylim,'--','none','k',2,20,gca,0.9,0.7,0.7);
graph1D_jd(NZ_list(2:end),time_mat(2:end),1,1,'','','',leg,xlim,ylim,'none','+','r',2);
%
figure(3),clf,
%
xlim = [1e-10,1e10];
ylim = NaN;%[1e-30,1];
%
leg = ['erfcc',leg0,'theory'];
%
graph1D_jd(x_as,abs(real(Z_as_erf) - real(Z_as_ser))./abs(real(Z_as_ser)),1,1,'x','Z(x)','',NaN,xlim,ylim,'none','o','k',2,20,gca,0.9,0.7,0.7);
graph1D_jd(x_as,(abs(real(Z_as_mat(2:end,:)) - repmat(real(Z_as_ser),[NZn-1,1]))./abs(repmat(real(Z_as_ser),[NZn-1,1]))).',1,1,'','','',NaN,xlim,ylim,'none','+',NaN,2);
graph1D_jd(x_as,theory,1,1,'','','',leg,xlim,ylim,'--','none',NaN,2);
%
figure(4),clf
%
xlim = [-10,10];
ylim = NaN;
%
leg = ['erfcc',leg0,'theory'];
%
graph1D_jd(x,real(Zp_erf),0,0,'x','Z''(x)','',NaN,xlim,ylim,'-','none','k',2,20,gca,0.9,0.7,0.7);
graph1D_jd(x,real(Zp_mat(2:end,:)).',0,0,'','','',NaN,xlim,ylim,'-','none',NaN,2);
graph1D_jd(x,Zp_thei,0,0,'','','',leg,xlim,ylim,'-','none','m',2);
graph1D_jd(x,imag(Zp_erf),0,0,'','','',NaN,xlim,ylim,'--','none','k',2);
graph1D_jd(x,imag(Zp_mat(2:end,:)).',0,0,'','','',NaN,xlim,ylim,'-','none',NaN,0.5);
%
figure(5),clf,
%
xlim = [1e-10,1e10];
ylim = NaN;%[1e-30,1];
%
leg = ['erfcc',leg0,'theory'];
%
graph1D_jd(x_as,abs(real(Zp_as_erf) - real(Zp_as_ser))./abs(real(Zp_as_ser)),1,1,'x','Z''(x)','',NaN,xlim,ylim,'none','o','k',2,20,gca,0.9,0.7,0.7);
graph1D_jd(x_as,(abs(real(Zp_as_mat(2:end,:)) - repmat(real(Zp_as_ser),[NZn-1,1]))./abs(repmat(real(Zp_as_ser),[NZn-1,1]))).',1,1,'','','',NaN,xlim,ylim,'none','+',NaN,2);
graph1D_jd(x_as,theoryp,1,1,'','','',leg,xlim,ylim,'--','none',NaN,2);
%
figure(6),clf
%
xlim = [-10,10];
ylim = NaN;
%
leg = ['erfcc',leg0,'theory'];
%
graph1D_jd(x,real(Zpp_erf),0,0,'x','Z''''(x)','',NaN,xlim,ylim,'-','none','k',2,20,gca,0.9,0.7,0.7);
graph1D_jd(x,real(Zpp_mat(2:end,:)).',0,0,'','','',NaN,xlim,ylim,'-','none',NaN,2);
graph1D_jd(x,Zpp_thei,0,0,'','','',leg,xlim,ylim,'-','none','m',2);
graph1D_jd(x,imag(Zpp_erf),0,0,'','','',NaN,xlim,ylim,'--','none','k',2);
graph1D_jd(x,imag(Zpp_mat(2:end,:)).',0,0,'','','',NaN,xlim,ylim,'-','none',NaN,0.5);
%
figure(7),clf,
%
xlim = [1e-10,1e10];
ylim = NaN;%[1e-30,1];
%
leg = ['erfcc',leg0,'theory'];
%
graph1D_jd(x_as,abs(real(Zpp_as_erf) - real(Zpp_as_ser))./abs(real(Zpp_as_ser)),1,1,'x','Z''''(x)','',NaN,xlim,ylim,'none','o','k',2,20,gca,0.9,0.7,0.7);
graph1D_jd(x_as,(abs(real(Zpp_as_mat(2:end,:)) - repmat(real(Zpp_as_ser),[NZn-1,1]))./abs(repmat(real(Zpp_as_ser),[NZn-1,1]))).',1,1,'','','',NaN,xlim,ylim,'none','+',NaN,2);
graph1D_jd(x_as,theorypp,1,1,'','','',leg,xlim,ylim,'--','none',NaN,2);
%
print_jd(p_opt,'Fig_Z',NaN,1);
print_jd(p_opt,'Fig_t',NaN,2);
print_jd(p_opt,'Fig_Zrel',NaN,3);
print_jd(p_opt,'Fig_Zp',NaN,4);
print_jd(p_opt,'Fig_Zprel',NaN,5);
print_jd(p_opt,'Fig_Zpp',NaN,6);
print_jd(p_opt,'Fig_Zpprel',NaN,7);
%



