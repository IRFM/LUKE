function [XXthetastar1,XXthetastar2,XXalpha] = thetastar_dke_en(dkepath,dkeparam,dkedisplay,equilDKE,gridDKE,Zmomcoef,ohm,radialDKE)
%
% Calculation of the critical poloidal angle value theta_star for runaway avalanches
%
% INPUT:
%
%   - equil: magnetic equilibrium structure
%   - gridDKE: grid structure
%   - Zmomcoef: momentum dynamics structure
%   - radialDKE: radial grid structure
%
% OUTPUT:
%
%   - XXthetastar1: poloidal angle value theta_star between 0 and pi
%       [np,nmhu,nr] on each flux surface ie [np,nmhu,length(B)]
%   - XXthetastar2: poloidal angle value theta_star between pi and 2*pi
%   -the sum sig [npn,nmhu,l]
%
% By E. Nilsson (CEA-IRFM, emelie.nilsson@cea.fr) Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker
% (CEA-DRFC, joan.decker@cea.fr) 
%
ntheta = length(equilDKE.mtheta);
%
jj = 1;
%
for ir = 1:gridDKE.nr*0+1,
    for ipn = 1:gridDKE.npn,
        for imhu = 1:gridDKE.nmhu,
            grid_index(jj).ir = ir;
            grid_index(jj).ipn = ipn;
            grid_index(jj).imhu = imhu;
            jj = jj + 1;
        end
    end
end
%
%clustermode.ftest_mdce.scheduler.mode = real(mdce_mode);
%if ~isreal(mdce_mode),
%    clustermode.ftest_mdce.scheduler.gpu = imag(mdce_mode);
%else
%    clustermode.ftest_mdce.scheduler.gpu = 0;
%end
%clustermode.ftest_mdce.scheduler.clustersize = mdce_size;
%clustermode.ftest_mdce.scheduler.memory = mdce_memory;
%clustermode.ftest_mdce.scheduler.enforce = mdce_enforce;
%
%clustermode.ftest_mdce.scheduler.display = 1;
%
%dkecluster =
%clustermode_luke(clustermode,'ftest_mdce',dkepath,schedulertype,mdce_remnum);
[dkecluster] = clustermode_luke(dkeparam.clustermode,'loop_thetastar_dke_en',dkepath,'local',3);

dkecluster.scheduler.mode = 0;
tic
if isfield(dkeparam,'options_fzero'),
    options_fzero = dkeparam.options_fzero;
else
    options_fzero = [];
end
%
[flag,XXalpha,XXthetastar1,XXthetastar2] = mdce_luke(@loop_thetastar_dke_en,{NaN,grid_index,equilDKE.xrho,equilDKE.equil_fit,equilDKE.xB0,gridDKE.mhu,Zmomcoef.gamma,options_fzero},1,1:length(grid_index),dkecluster);
toc
XXalpha = cell2mat(reshape(XXalpha,gridDKE.nr,gridDKE.nmhu,gridDKE.npn));
XXthetastar1 = cell2mat(reshape(XXthetastar1,gridDKE.nr,gridDKE.nmhu,gridDKE.npn));
XXthetastar2 = cell2mat(reshape(XXthetastar2,gridDKE.nr,gridDKE.nmhu,gridDKE.npn));
% 
%keyboard
%check discrepancies between thetastar1 and 2
a=isnan(XXthetastar1(1,:,:));
b=isnan(XXthetastar2(1,:,:));
a=squeeze(a);
b=squeeze(b);
[I,J]=find(abs(a-b)>0)
% for k=1:length(I)
% k1(k)=XXthetastar1(1,I(k),J(k));
% k2(k)=XXthetastar2(1,I(k),J(k));
% f(k)=2.0/(1 - gridDKE.XXmhu(1,I(k)).^2)./(Zmomcoef.gamma(J(k))+ 1.0);
% end
% %
% for k=1:601
% theta(k)=(k-1)*2*pi/600;
% 
%     [dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,...
%     dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,...
%     dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,...
%     Bx1,dummy,dummy,dummy,dummy,...
%     By1,dummy,dummy,dummy,dummy,...
%     dummy,dummy,dummy,dummy,dummy,...
%     dummy,dummy,dummy,B,dB1dtheta,dummy,...
%     dummy,dummy,dummy] = equilval_yp(equilDKE.equil_fit,0.4,theta(k));
% Bstar(k)=B/equilDKE.xB0;
% dBdth(k)=dB1dtheta;
% Bfield(k)=B;
% 
% end

%
%figure
%hold on
%plot(theta,Bstar,'r')
% if(~isempty(k2))
% plot(k2,f,'ko')
% end
% %
%
%for igrid = 1:length(grid_index),
%    [XXalpha(igrid),XXthetastar1(igrid),XXthetastar2(igrid)] = loop_thetastar_dke_en(igrid,grid_index,equilDKE.xrho,equilDKE.equil_fit,equilDKE.xB0,gridDKE.mhu,Zmomcoef.gamma);
%igrid
% end
if 0,

%
for ipsi = 1:npsi,
    for ipn = 1:npn,
        for imhu = 1:nmhu,
            ymin = fthetastar_dke_en(0,equilDKE.xrho(ipsi),equilDKE.equil_fit,equilDKE.xB0(ipsi),gridDKE.mhu(imhu),Zmomcoef.gamma(ipn));
            ymax = fthetastar_dke_en(pi,equilDKE.xrho(ipsi),equilDKE.equil_fit,equilDKE.xB0(ipsi),gridDKE.mhu(imhu),Zmomcoef.gamma(ipn));
            if ymin*ymax <= 0,
                thetastar1 = fzero(@(theta) fthetastar_dke_en(theta,equilDKE.xrho(ipsi),equilDKE.equil_fit,equilDKE.xB0(ipsi),gridDKE.mhu(imhu),Zmomcoef.gamma(ipn)),pi);
                thetastar2 = fzero(@(theta) fthetastar_dke_en(theta,equilDKE.xrho(ipsi),equilDKE.equil_fit,equilDKE.xB0(ipsi),gridDKE.mhu(imhu),Zmomcoef.gamma(ipn)),pi/2 + pi);
                %
                if thetastar1 >= 0 && thetastar1 <= 2*pi,
                    XXthetastar1(ipn,imhu,ipsi) = thetastar1;
                    %
                    [dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,...
                    x1,dummy,dummy,dummy,dummy,y1,dummy,dummy,dummy,dummy,...
                    dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,...
                    Bx1,dummy,dummy,dummy,dummy,...
                    By1,dummy,dummy,dummy,dummy,...
                    dummy,dummy,dummy,dummy,dummy,...
                    dummy,dummy,dummy,dummy,dB1dtheta,dummy,...
                    dummy,dummy,dummy] = equilval_yp(equilDKE.equil_fit,equilDKE.xrho(ipsi),thetastar1);
                    %
                end
                %
                if thetastar2 >= 0 && thetastar2 <= 2*pi,
                    XXthetastar2(ipn,imhu,ipsi) = thetastar2;
                    %
                    [dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,...
                    x2,dummy,dummy,dummy,dummy,y2,dummy,dummy,dummy,dummy,...
                    dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,...
                    Bx2,dummy,dummy,dummy,dummy,...
                    By2,dummy,dummy,dummy,dummy,...
                    dummy,dummy,dummy,dummy,dummy,...
                    dummy,dummy,dummy,dummy,dB2dtheta,dummy,...
                    dummy,dummy,dummy] = equilval_yp(equilDKE.equil_fit,equilDKE.xrho(ipsi),thetastar2);
                    %
                end
                %
                if ~isnan(XXthetastar1(ipn,imhu,ipsi)) && ~isnan(XXthetastar2(ipn,imhu,ipsi)),
                    XXalpha(ipn,imhu,ipsi) = equilDKE.xB0(ipsi)*((x1*x1+y1*y1)/abs(-By1*x1+Bx1*y1)/abs(dB1dtheta) + (x2*x2+y2*y2)/abs(-By2*x2+Bx2*y2)/abs(dB2dtheta));
                end
                %
                disp([' - imhu: ',int2str(imhu),'/',int2str(nmhu),' - ipn: ',int2str(ipn),'/',int2str(npn),' - ipsi: ',int2str(ipsi),'/',int2str(npsi)])
            end
        end
    end
end
%
end
%

toc
%
%figure;graph2D_jd(gridDKE.XXmhu(1,:),gridDKE.pn(1,:),XXthetastar1(1,:,:),'p','mhu','theta^*_1',NaN,NaN,0,NaN,30); colorbar;
%figure;graph2D_jd(gridDKE.pn(:),gridDKE.XXmhu(1,:,1),XXthetastar2(1,:,:),'p','mhu','theta^*_2',NaN,NaN,0,NaN,30); colorbar;
%
%figure;graph2D_jd(gridDKE.pn(:),gridDKE.XXmhu(1,:,1),XXalpha(:,:,1),'p','mhu','alpha',NaN,NaN,0,NaN,30); colorbar;





end


function [alpha,thetastar1,thetastar2] = loop_thetastar_dke_en(igrid,grid_index,xrho,equil_fit,xB0,mhu,gamma,options_fzero)
    %
    ymin = fthetastar_dke_en(0,xrho(grid_index(igrid).ir),equil_fit,xB0(grid_index(igrid).ir),mhu(grid_index(igrid).imhu),gamma(grid_index(igrid).ipn));
    ymax = fthetastar_dke_en(pi,xrho(grid_index(igrid).ir),equil_fit,xB0(grid_index(igrid).ir),mhu(grid_index(igrid).imhu),gamma(grid_index(igrid).ipn));
    if ymin*ymax <= 0,
        %keyboard
        theta_guess = asin((2/(1-mhu(grid_index(igrid).imhu)^2)/(gamma(grid_index(igrid).ipn)+1)-1)./(4.077089236454936/xB0-1))+pi/2;
        thetastar1 = fzero(@(theta) fthetastar_dke_en(theta,xrho(grid_index(igrid).ir),equil_fit,xB0(grid_index(igrid).ir),mhu(grid_index(igrid).imhu),gamma(grid_index(igrid).ipn)),theta_guess,options_fzero);
        thetastar2 = fzero(@(theta) fthetastar_dke_en(theta,xrho(grid_index(igrid).ir),equil_fit,xB0(grid_index(igrid).ir),mhu(grid_index(igrid).imhu),gamma(grid_index(igrid).ipn)),2*pi-theta_guess,options_fzero);       
        %
        if thetastar1 >= 0 && thetastar1 <= 2*pi,
            %
            [dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,...
            x1,dummy,dummy,dummy,dummy,y1,dummy,dummy,dummy,dummy,...
            dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,...
            Bx1,dummy,dummy,dummy,dummy,...
            By1,dummy,dummy,dummy,dummy,...
            dummy,dummy,dummy,dummy,dummy,...
            dummy,dummy,dummy,dummy,dB1dtheta,dummy,...
            dummy,dummy,dummy] = equilval_yp(equil_fit,xrho(grid_index(igrid).ir),thetastar1);
        else
            thetastar1 = NaN;
        end
        %
        if thetastar2 >= 0 && thetastar2 <= 2*pi,
            %
            [dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,...
            x2,dummy,dummy,dummy,dummy,y2,dummy,dummy,dummy,dummy,...
            dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,...
            Bx2,dummy,dummy,dummy,dummy,...
            By2,dummy,dummy,dummy,dummy,...
            dummy,dummy,dummy,dummy,dummy,...
            dummy,dummy,dummy,dummy,dB2dtheta,dummy,...
            dummy,dummy,dummy] = equilval_yp(equil_fit,xrho(grid_index(igrid).ir),thetastar2);
        else
            thetastar2 = NaN;
        end
        %
        if ~isnan(thetastar1) && ~isnan(thetastar2),
            alpha = xB0(grid_index(igrid).ir)*((x1*x1+y1*y1)/abs(-By1*x1+Bx1*y1)/abs(dB1dtheta) + (x2*x2+y2*y2)/abs(-By2*x2+Bx2*y2)/abs(dB2dtheta));
        else
            alpha = NaN;
        end
    else
        thetastar1 = NaN;
        thetastar2 = NaN;
        alpha = NaN;
    end
end
%
