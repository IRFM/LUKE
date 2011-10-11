function [PSI_fit1,Xf0_fit] = testf0struct_yp(dke_out,momentumDKE,equilDKE,mksa,f0struct,rho,theta,pn,mhu)
%
% Test the interpolated distribution function and PSI =  B/B0 where B0 is
% the minimum of B on a magnetic flux surface
%
% INPUT
     
%    - pn: momentum normalized to pth_ref (betath_ref) [1,1]
%      (default = 4)
%    - mhu: pitch-angle (-1 -> 1) [1,1]
%      (default = 0.5)
%    - rho: normalized minor radius [1,1]
%      (default = 0.25)
%    - theta: poloidal angle (rad) [1,1]
%      (default = 0.2)
%
% OUTPUT:
%    - PSI: B/B0 where B0 is the minimum of B on a magnetic flux surface [1,1]
%    - Xf0: distribution function at B0(rho) [npn,nmhu]
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
if nargin < 5,
    error('Wrong number of input arguments in testf0struct_yp.m');
end
%
if nargin < 6,%Output for comparison with C raytracing_yp.c
   rho = 0.25;
   theta = 0.2;
   pn = 4;
   mhu = 0.5;
end
%
if nargin < 7,
   theta = 0.2;
   pn = 4;
   mhu = 0.5;
end
%
if nargin < 8,
   pn = 4;
   mhu = 0.5;
end
%
if nargin < 9,
   mhu = 0.5;
end
%
ipn = max(find(f0struct.pn <= pn));
jmhu = max(find(f0struct.mhu <= mhu));
pnd = f0struct.pn(ipn);
mhud = f0struct.mhu(jmhu);
%
B = sqrt(equilDKE.XBx.*equilDKE.XBx + equilDKE.XBy.*equilDKE.XBy + equilDKE.XBphi.*equilDKE.XBphi);%Module of the total magnetic field
PSI = B./(B(:,1)*ones(1,length(equilDKE.mtheta)));%Module of the total magnetic field at theta = 0 (where it is minimum)
%
if nargin < 6, 
    close all;
    %
    ir = 4;%resampling factor
    %
    rho_fit = sort(resample(equilDKE.xrho,ir,1)');
    for ir = 1:length(equilDKE.xrho),
        index_rho(ir) = find(rho_fit == equilDKE.xrho(ir));
    end
    theta_fit = equilDKE.mtheta';
    %
    PSI_a0_fit = ppval(f0struct.PSI_fit.pp_a0,rho_fit);
    PSI_an_fit = ppval(f0struct.PSI_fit.pp_an,rho_fit);
    PSI_bn_fit = ppval(f0struct.PSI_fit.pp_bn,rho_fit);
    PSI_da0drho_fit = ppval(f0struct.PSI_fit.pp_da0drho,rho_fit);
    PSI_dandrho_fit = ppval(f0struct.PSI_fit.pp_dandrho,rho_fit);
    PSI_dbndrho_fit = ppval(f0struct.PSI_fit.pp_dbndrho,rho_fit);
    %
    PSI_a0_fit1 = ppval_yp(f0struct.PSI_fit.pp_a0,rho_fit);
    PSI_an_fit1 = ppval_yp(f0struct.PSI_fit.pp_an,rho_fit);
    PSI_bn_fit1 = ppval_yp(f0struct.PSI_fit.pp_bn,rho_fit);
    PSI_da0drho_fit1 = ppval_yp(f0struct.PSI_fit.pp_da0drho,rho_fit);
    PSI_dandrho_fit1 = ppval_yp(f0struct.PSI_fit.pp_dandrho,rho_fit);
    PSI_dbndrho_fit1 = ppval_yp(f0struct.PSI_fit.pp_dbndrho,rho_fit);
    %
    % Build interpolated quantities
    %
    PSI_fit = zeros(length(rho_fit),length(theta_fit));
    dPSIdtheta_fit = zeros(length(rho_fit),length(theta_fit));
    d2PSIdtheta2_fit = zeros(length(rho_fit),length(theta_fit));
    dPSIdrho_fit = zeros(length(rho_fit),length(theta_fit));
    d2PSIdthetadrho_fit = zeros(length(rho_fit),length(theta_fit));
    %
    PSI_fit1 = zeros(length(rho_fit),length(theta_fit));
    dPSIdtheta_fit1 = zeros(length(rho_fit),length(theta_fit));
    d2PSIdtheta2_fit1 = zeros(length(rho_fit),length(theta_fit));
    dPSIdrho_fit1 = zeros(length(rho_fit),length(theta_fit));
    d2PSIdthetadrho_fit1 = zeros(length(rho_fit),length(theta_fit));
    %
    for ii = 1:length(theta_fit), 
        [PSI_fit(:,ii)] = calcval_yp(f0struct.PSI_fit,theta_fit(ii),PSI_a0_fit(:),PSI_an_fit,PSI_bn_fit,PSI_da0drho_fit(:),PSI_dandrho_fit,PSI_dbndrho_fit);
        [PSI_fit1(:,ii)] = calcval_yp(f0struct.PSI_fit,theta_fit(ii),PSI_a0_fit1(:),PSI_an_fit1,PSI_bn_fit1,PSI_da0drho_fit1(:),PSI_dandrho_fit1,PSI_dbndrho_fit1);
    end
    %
    figure('Name','PSI'),
    [ax] = graph1D_jd(theta_fit,PSI_fit(index_rho,:),0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
    [ax] = graph1D_jd(theta_fit,PSI_fit1(index_rho,:),0,0,'','','',NaN,NaN,NaN,'-','none','c',1);    
    [ax] = graph1D_jd(equilDKE.mtheta,PSI,0,0,'\theta (rd)','\Psi','\Psi(\rho,\theta) = B(\rho,\theta)/B_{0}(\rho)',NaN,[0,2*pi],NaN,'--','none','r',1);
    legend('Matlab interp. (blue)','LUKE interp. (cyan)','LUKE (red)')
    %
    Xf0_fit = reshape(ppval(f0struct.XXf0_fit.pp_f,rho_fit)',length(f0struct.pn),length(f0struct.mhu),length(rho_fit));
    ipn = max(find(f0struct.pn <= pn));
    %
    ne_fit = interp1(equilDKE.xrho,equilDKE.xne,rho_fit)/mksa.ne_ref;%interpolation fo the electron density profile
    %
    Xpn2_fit = (f0struct.pn(:).^2)*ones(1,length(f0struct.mhu));
    for ir = 1:length(rho_fit)
        normXf0_fit(ir) = 2*pi*integral_dke_jd(momentumDKE.dmhu,integral_dke_jd(momentumDKE.dpn,Xf0_fit(:,:,ir).*Xpn2_fit,1),1)';
    end
    %
    figure('Name','f0'),
    [ax] = graph1D_jd(rho_fit,squeeze(Xf0_fit(ipn,jmhu,:)),0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
    [ax] = graph1D_jd(equilDKE.xrho,squeeze(dke_out.XXf0(ipn,jmhu,:)),0,0,'\rho','f_{0}',['@ p_{n} = ',num2str(pnd),', \xi_{0} = ',num2str(mhud)],NaN,[0,1],NaN,'none','+','r',2);
    legend('Fit','LUKE')
    %
    figure('Name','Norm. f0'),
    [ax] = graph1D_jd(rho_fit,normXf0_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
    [ax] = graph1D_jd(rho_fit,ne_fit,0,0,'\rho','','',NaN,NaN,NaN,'-','none','r',1);
    [ax] = graph1D_jd(equilDKE.xrho,equilDKE.xne/mksa.ne_ref,0,0,'\rho','Normalized electron density','',NaN,[0,1],NaN,'none','+','r',2);
    legend('Fit of f_{0}','Fit of n_{e}','n_{e}')
else
    %
    PSI_a0_fit1 = ppval_yp(f0struct.PSI_fit.pp_a0,rho);
    PSI_an_fit1 = ppval_yp(f0struct.PSI_fit.pp_an,rho);
    PSI_bn_fit1 = ppval_yp(f0struct.PSI_fit.pp_bn,rho);
    PSI_da0drho_fit1 = ppval_yp(f0struct.PSI_fit.pp_da0drho,rho);
    PSI_dandrho_fit1 = ppval_yp(f0struct.PSI_fit.pp_dandrho,rho);
    PSI_dbndrho_fit1 = ppval_yp(f0struct.PSI_fit.pp_dbndrho,rho);
    %
    [PSI_fit1] = calcval_yp(f0struct.PSI_fit,theta,PSI_a0_fit1(:),PSI_an_fit1,PSI_bn_fit1,PSI_da0drho_fit1(:),PSI_dandrho_fit1,PSI_dbndrho_fit1);
    %
    Xf0_fit = reshape(ppval(f0struct.XXf0_fit.pp_f,rho)',length(f0struct.pn),length(f0struct.mhu),length(rho));
    ne_fit = interp1(equilDKE.xrho,equilDKE.xne,rho)/mksa.ne_ref;%interpolation fo the electron density profile
    %
    Xpn2_fit = (f0struct.pn(:).^2)*ones(1,length(f0struct.mhu));
    normXf0_fit = 2*pi*integral_dke_jd(momentumDKE.dmhu,integral_dke_jd(momentumDKE.dpn,Xf0_fit.*Xpn2_fit,1),1)';
    %
    disp('---------------------------------');
    disp(['XXf0_fit.pp_f.coefs(1) = ',num2str(f0struct.XXf0_fit.pp_f.coefs(1))]);
    disp(['XXf0_fit.pp_dfdrho.coefs(1) = ',num2str(f0struct.XXf0_fit.pp_dfdrho.coefs(1))]);
    disp(['XXf0_fit.pp_d2fdrho2.coefs(1) = ',num2str(f0struct.XXf0_fit.pp_d2fdrho2.coefs(1))]);
    disp('--------------');        
    disp(['Xf0_fit(',num2str(pnd),',',num2str(mhud),',',num2str(rho),') = ',num2str(squeeze(Xf0_fit(ipn,jmhu)))]);
    disp(['ne/ne_ref(',num2str(rho),') = ',num2str(ne_fit)]);
    disp(['norm_Xf0_fit(',num2str(rho),') = ',num2str(normXf0_fit)]);
    disp('---------------------------------');      
    disp(['PSI_fit.n = ',num2str(f0struct.PSI_fit.n(end))]);
    disp(['PSI_fit.pp_bn.coefs(1) = ',num2str(f0struct.PSI_fit.pp_bn.coefs(1))]);
    disp(['PSI_fit.pp_dbndrho.coefs(1) = ',num2str(f0struct.PSI_fit.pp_dbndrho.coefs(1))]);
    disp('--------------');
    disp(['PSI(',num2str(rho),',',num2str(theta),') = ',num2str(PSI_fit1)]);
    disp('---------------------------------');   
end

