function testfitfluct_yp(equil_fit,fluct,fluct_fit,rho,theta,mode)
%
% Test the interpolated fluctuation spectrum
%
% INPUT
%    - equil_fit: interpolated magnetic equilibrium structure
%    - fluct: numerical plasma fluctuations structure
%    - fluct_fit: interpolated plasma fluctuations structure
%    - rho: normalized minor radius [m,1]
%    - theta: poloidal angle (rad) [1,n]
%    - mode: (1) -> (rho,theta), (2) -> (x,y) [1,1]
%      (default = 1)
%
% OUTPUT: none
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
if nargin < 4,
    rho = fluct.prho;
    dprho = gradient(fluct.prho(:));
    theta = fluct.theta;
    dtheta = gradient(fluct.theta);
end
%
nrho = 1001;
ntheta = 40001;
%
if nargin == 4, theta = [];end
%
if nargin < 6,mode = 1;end
%
if isempty(rho),rho = linspace(0,1,nrho);end
if isempty(theta),theta = linspace(0,2*pi,ntheta);end
%
rho(abs(rho) > 1) = 1;%rho must be less than 1
rho(rho < 0) = abs(rho(rho < 0));%rho must be positive
%
close all;
%
field_name = fieldnames(fluct_fit);
%
if (nargin >= 4) & (length(rho) == 1) & length(theta) > 1,%Calculation of the local magnetic equilibrium from equil_fit for the statistical analysis of the fluctuation spectrum
    x_a0_fit = ppval(equil_fit.x_fit.pp_a0,rho);
    x_an_fit = ppval(equil_fit.x_fit.pp_an,rho);
    x_bn_fit = ppval(equil_fit.x_fit.pp_bn,rho);
    x_da0drho_fit = ppval(equil_fit.x_fit.pp_da0drho,rho);
    x_dandrho_fit = ppval(equil_fit.x_fit.pp_dandrho,rho);
    x_dbndrho_fit = ppval(equil_fit.x_fit.pp_dbndrho,rho);
    %
    y_a0_fit = ppval(equil_fit.y_fit.pp_a0,rho);
    y_an_fit = ppval(equil_fit.y_fit.pp_an,rho);
    y_bn_fit = ppval(equil_fit.y_fit.pp_bn,rho);
    y_da0drho_fit = ppval(equil_fit.y_fit.pp_da0drho,rho);
    y_dandrho_fit = ppval(equil_fit.y_fit.pp_dandrho,rho);
    y_dbndrho_fit = ppval(equil_fit.y_fit.pp_dbndrho,rho);
    %
    Bx_a0_fit = ppval(equil_fit.Bx_fit.pp_a0,rho);
    Bx_an_fit = ppval(equil_fit.Bx_fit.pp_an,rho);
    Bx_bn_fit = ppval(equil_fit.Bx_fit.pp_bn,rho);
    Bx_da0drho_fit = ppval(equil_fit.Bx_fit.pp_da0drho,rho);
    Bx_dandrho_fit = ppval(equil_fit.Bx_fit.pp_dandrho,rho);
    Bx_dbndrho_fit = ppval(equil_fit.Bx_fit.pp_dbndrho,rho);
    %
    By_a0_fit = ppval(equil_fit.By_fit.pp_a0,rho);
    By_an_fit = ppval(equil_fit.By_fit.pp_an,rho);
    By_bn_fit = ppval(equil_fit.By_fit.pp_bn,rho);
    By_da0drho_fit = ppval(equil_fit.By_fit.pp_da0drho,rho);
    By_dandrho_fit = ppval(equil_fit.By_fit.pp_dandrho,rho);
    By_dbndrho_fit = ppval(equil_fit.By_fit.pp_dbndrho,rho);
    %
    BPHI_a0_fit = ppval(equil_fit.BPHI_fit.pp_a0,rho);
    BPHI_an_fit = ppval(equil_fit.BPHI_fit.pp_an,rho);
    BPHI_bn_fit = ppval(equil_fit.BPHI_fit.pp_bn,rho);
    BPHI_da0drho_fit = ppval(equil_fit.BPHI_fit.pp_da0drho,rho);
    BPHI_dandrho_fit = ppval(equil_fit.BPHI_fit.pp_dandrho,rho);
    BPHI_dbndrho_fit = ppval(equil_fit.BPHI_fit.pp_dbndrho,rho);
    %
    for ii = 1:length(theta), 
        [R_fit(:,ii),dRdtheta_fit(:,ii),d2Rdtheta2_fit(:,ii),dRdrho_fit(:,ii),d2Rdthetadrho_fit(:,ii)] = calcval_yp(equil_fit.x_fit,theta(ii),x_a0_fit(:),x_an_fit,x_bn_fit,x_da0drho_fit(:),x_dandrho_fit,x_dbndrho_fit);
        R_fit(:,ii) = R_fit(:,ii) + equil_fit.Rp;
        [Z_fit(:,ii),dZdtheta_fit(:,ii),d2Zdtheta2_fit(:,ii),dZdrho_fit(:,ii),d2Zdthetadrho_fit(:,ii)] = calcval_yp(equil_fit.y_fit,theta(ii),y_a0_fit(:),y_an_fit,y_bn_fit,y_da0drho_fit(:),y_dandrho_fit,y_dbndrho_fit);
        Z_fit(:,ii) = Z_fit(:,ii) + equil_fit.Zp;
        %  
        r_fit(:,ii) = sqrt((R_fit(:,ii) - equil_fit.Rp).^2 + (Z_fit(:,ii) - equil_fit.Zp).^2);
        if (r_fit(1,ii) == 0), r_fit(1,ii) = prec; end
        drdtheta_fit(:,ii) = (dRdtheta_fit(:,ii).*(R_fit(:,ii) - equil_fit.Rp) + dZdtheta_fit(:,ii).*(Z_fit(:,ii) - equil_fit.Zp))./r_fit(:,ii);
        drdrho_fit(:,ii) = (dRdrho_fit(:,ii).*(R_fit(:,ii) - equil_fit.Rp) + dZdrho_fit(:,ii).*(Z_fit(:,ii) - equil_fit.Zp))./r_fit(:,ii);
        %
        salpha_fit(:,ii) = ((R_fit(:,ii) - equil_fit.Rp).*dRdtheta_fit(:,ii) + (Z_fit(:,ii) - equil_fit.Zp).*dZdtheta_fit(:,ii))./r_fit(:,ii)./sqrt(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2);
        dsalphadtheta_fit(:,ii) = ...
            sqrt(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2)./r_fit(:,ii) ...
            +((R_fit(:,ii) - equil_fit.Rp).*d2Rdtheta2_fit(:,ii) + (Z_fit(:,ii) - equil_fit.Zp).*d2Zdtheta2_fit(:,ii))./r_fit(:,ii)./sqrt(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2) ...
            -drdtheta_fit(:,ii).*((R_fit(:,ii) - equil_fit.Rp).*dRdtheta_fit(:,ii) + (Z_fit(:,ii) - equil_fit.Zp).*dZdtheta_fit(:,ii))./r_fit(:,ii).^2./sqrt(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2) ...
            -(dRdtheta_fit(:,ii).*d2Rdtheta2_fit(:,ii) + dZdtheta_fit(:,ii).*d2Zdtheta2_fit(:,ii)).*((R_fit(:,ii) - equil_fit.Rp).*dRdtheta_fit(:,ii) + (Z_fit(:,ii) - equil_fit.Zp).*dZdtheta_fit(:,ii))./r_fit(:,ii)./sqrt(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2)./(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2);     
        dsalphadrho_fit(:,ii) = ...
            (dRdtheta_fit(:,ii).*dRdrho_fit(:,ii) + dZdtheta_fit(:,ii).*dZdrho_fit(:,ii))./r_fit(:,ii)./sqrt(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2)...
            +((R_fit(:,ii) - equil_fit.Rp).*d2Rdthetadrho_fit(:,ii) + (Z_fit(:,ii) - equil_fit.Zp).*d2Zdthetadrho_fit(:,ii))./r_fit(:,ii)./sqrt(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2) ...
            -drdrho_fit(:,ii).*((R_fit(:,ii) - equil_fit.Rp).*dRdtheta_fit(:,ii) + (Z_fit(:,ii) - equil_fit.Zp).*dZdtheta_fit(:,ii))./r_fit(:,ii).^2./sqrt(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2) ...
            -(dRdtheta_fit(:,ii).*d2Rdthetadrho_fit(:,ii) + dZdtheta_fit(:,ii).*d2Zdthetadrho_fit(:,ii)).*((R_fit(:,ii) - equil_fit.Rp).*dRdtheta_fit(:,ii) + (Z_fit(:,ii) - equil_fit.Zp).*dZdtheta_fit(:,ii))./r_fit(:,ii)./sqrt(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2)./(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2);
        %
        calpha_fit(:,ii) = sqrt(1.0 - salpha_fit(:,ii).^2);
        if (calpha_fit(1,ii)== 0), calpha_fit(1,ii) = prec; end
        dcalphadtheta_fit(:,ii) = -salpha_fit(:,ii).*dsalphadtheta_fit(:,ii)./calpha_fit(:,ii);
        dcalphadrho_fit(:,ii) = -salpha_fit(:,ii).*dsalphadrho_fit(:,ii)./calpha_fit(:,ii);;
        %
        [BR_fit(:,ii),dBRdtheta_fit(:,ii),dummy,dBRdrho_fit(:,ii),dummy] = calcval_yp(equil_fit.Bx_fit,theta(ii),Bx_a0_fit(:),Bx_an_fit,Bx_bn_fit,Bx_da0drho_fit(:),Bx_dandrho_fit,Bx_dbndrho_fit);
        [BZ_fit(:,ii),dBZdtheta_fit(:,ii),dummy,dBZdrho_fit(:,ii),dummy] = calcval_yp(equil_fit.By_fit,theta(ii),By_a0_fit(:),By_an_fit,By_bn_fit,By_da0drho_fit(:),By_dandrho_fit,By_dbndrho_fit);
        [BPHI_fit(:,ii),dBPHIdtheta_fit(:,ii),dummy,dBPHIdrho_fit(:,ii),dummy] = calcval_yp(equil_fit.BPHI_fit,theta(ii),BPHI_a0_fit(:),BPHI_an_fit,BPHI_bn_fit,BPHI_da0drho_fit(:),BPHI_dandrho_fit,BPHI_dbndrho_fit);
        %
        BP_fit(:,ii) = sqrt(BR_fit(:,ii).^2 + BZ_fit(:,ii).^2);
        dBPdtheta_fit(:,ii) = (BR_fit(:,ii).*dBRdtheta_fit(:,ii) + BZ_fit(:,ii).*dBZdtheta_fit(:,ii))./BP_fit(:,ii);
        dBPdrho_fit(:,ii) = (BR_fit(:,ii).*dBRdrho_fit(:,ii) + BZ_fit(:,ii).*dBZdrho_fit(:,ii))./BP_fit(:,ii);
        %
        B_fit(:,ii) = sqrt(BR_fit(:,ii).^2 + BZ_fit(:,ii).^2 + BPHI_fit(:,ii).^2);
        dBdtheta_fit(:,ii) = (BR_fit(:,ii).*dBRdtheta_fit(:,ii) + BZ_fit(:,ii).*dBZdtheta_fit(:,ii) + BPHI_fit(:,ii).*dBPHIdtheta_fit(:,ii))./B_fit(:,ii);
        dBdrho_fit(:,ii) = (BR_fit(:,ii).*dBRdrho_fit(:,ii) + BZ_fit(:,ii).*dBZdrho_fit(:,ii) + BPHI_fit(:,ii).*dBPHIdrho_fit(:,ii))./B_fit(:,ii);
    end
    %
    P_fit = sign(equil_fit.psia)*BP_fit./B_fit;%With the sign of the plasma current (only valid for tokamak, not for RFP !)
    T_fit = BPHI_fit./B_fit;
%
	a0_fit = ppval(fluct_fit.cm_fit.pp_a0,rho);
	an_fit = ppval(fluct_fit.cm_fit.pp_an,rho);
    bn_fit = ppval(fluct_fit.cm_fit.pp_bn,rho);
    da0drho_fit = ppval(fluct_fit.cm_fit.pp_da0drho,rho);
    dandrho_fit = ppval(fluct_fit.cm_fit.pp_dandrho,rho);
    dbndrho_fit = ppval(fluct_fit.cm_fit.pp_dbndrho,rho);
    %
    for ii = 1:length(theta),
        [cm_fit(:,ii)] = calcval_yp(fluct_fit.cm_fit,theta(ii),a0_fit(:),an_fit,bn_fit,da0drho_fit(:),dandrho_fit,dbndrho_fit);
        [int02theta_cm_fit(:,ii)] = intval_yp(fluct_fit.cm_fit,theta(ii),a0_fit(:),an_fit,bn_fit);%For the fluctuation phase calculation
    end
    %
	a0_fit = ppval(fluct_fit.cn_fit.pp_a0,rho);
	an_fit = ppval(fluct_fit.cn_fit.pp_an,rho);
    bn_fit = ppval(fluct_fit.cn_fit.pp_bn,rho);
    da0drho_fit = ppval(fluct_fit.cn_fit.pp_da0drho,rho);
    dandrho_fit = ppval(fluct_fit.cn_fit.pp_dandrho,rho);
    dbndrho_fit = ppval(fluct_fit.cn_fit.pp_dbndrho,rho);
    %
    for ii = 1:length(theta),
        [cn_fit(:,ii)] = calcval_yp(fluct_fit.cn_fit,theta(ii),a0_fit(:),an_fit,bn_fit,da0drho_fit(:),dandrho_fit,dbndrho_fit);
    end 
%
	for i = 1:length(field_name),
    	if isfield(fluct_fit,field_name(i)),
        	if isstruct(fluct_fit.(char(field_name(i)))) & ~isempty(strfind(char(field_name(i)),'_fit')) & isempty(strfind(char(field_name(i)),'cm')) & isempty(strfind(char(field_name(i)),'cn')),
            	for ifield = 1:length(fluct_fit.(char(field_name(i)))),
                    subfield_name = fieldnames(fluct_fit.(char(field_name(i))));
                	v = regexprep(char(field_name(i)),'_fit','');
                    if fluct_fit.(char(field_name(i)))(ifield).model > 0,
                        kperp = fluct_fit.(char(field_name(i)))(ifield).kp;
                        nkperp = length(kperp);
                        phaseinit = fluct_fit.(char(field_name(i)))(ifield).phase;
                        %
                        j = 1;
                        for isubfield = 1:length(subfield_name),
                            if mode == 1,
                                %
                                % calculation at all radial positions of all coefficients for the Fourier series
                                %
                                if strfind(char(subfield_name(isubfield)),'_fit');
                                    a0_fit = ppval(fluct_fit.(char(field_name(i)))(ifield).([char(subfield_name(isubfield))]).pp_a0,rho);
                                    an_fit = ppval(fluct_fit.(char(field_name(i)))(ifield).([char(subfield_name(isubfield))]).pp_an,rho);
                                    bn_fit = ppval(fluct_fit.(char(field_name(i)))(ifield).([char(subfield_name(isubfield))]).pp_bn,rho);
                                    da0drho_fit = ppval(fluct_fit.(char(field_name(i)))(ifield).([char(subfield_name(isubfield))]).pp_da0drho,rho);
                                    dandrho_fit = ppval(fluct_fit.(char(field_name(i)))(ifield).([char(subfield_name(isubfield))]).pp_dandrho,rho);
                                    dbndrho_fit = ppval(fluct_fit.(char(field_name(i)))(ifield).([char(subfield_name(isubfield))]).pp_dbndrho,rho);
                                    %
                                    % calculation of the value at all poloidal angles
                                    %
                                    for ii = 1:length(theta),
                                        [w_fit{j}(:,ii)] = calcval_yp(fluct_fit.(char(field_name(i)))(ifield).([char(subfield_name(isubfield))]),theta(ii),a0_fit(:),an_fit,bn_fit);
                                    end
                                    %
                                    j = j + 1;
                                end
                            else
                                error('Mode 2 (x,y) not yet implemented in fitfluct_yp.m');
                            end
                        end
                        %
                        if 20*max(kperp)*max(r_fit./T_fit./T_fit./sqrt(1 + calpha_fit.*calpha_fit.*P_fit.*P_fit./T_fit./T_fit))/equil_fit.ap > ntheta,
                            disp(['WARNING: The number of theta points is undestimated for a correct plot of the fluctuations. Please relaunch the test with ntheta > ',int2str(round(20*max(kperp)*max(r_fit./T_fit./T_fit./sqrt(1 + calpha_fit.*calpha_fit.*P_fit.*P_fit./T_fit./T_fit))/equil_fit.ap)),'.']);
                        end
                        %
                        dkperp = kperp(2) - kperp(1);%Uniform kperp grid assumed
                        %
                        if fluct_fit.(char(field_name(i)))(ifield).model == 1,%Gaussian model     	
                            %
                            phase = zeros(nkperp,length(theta));
                            %
                            phi = -theta.*P_fit.*r_fit./T_fit./R_fit./calpha_fit;%Phi is here chosen such that direction is perpendicular to the magnetic field line
                            %
                            for ikperp = 1:nkperp,
                                phase(ikperp,:) = (int02theta_cm_fit + cn_fit(:,1).*phi)*kperp(ikperp) + phaseinit(ikperp);%toroidal angle phi is here chosen such that direction is perpendicular to the magnetic field line
                            end
                            %
                            if length(w_fit) == 3,
                                df = zeros(nkperp,length(theta));
                                %
                                for ikperp = 1:nkperp,
                                    df(ikperp,:) = w_fit{1}.*cos(phase(ikperp,:)).*sqrt(2.*dkperp./w_fit{2}).*exp(-(kperp(ikperp) - w_fit{3}).^2./w_fit{2}./w_fit{2}./4)/(2*pi)^(0.25);
                                end
                            else
                                dfx = zeros(nkperp,length(theta));
                                dfy = zeros(nkperp,length(theta));
                                dfz = zeros(nkperp,length(theta));
                                %
                                for ikperp = 1:nkperp,
                                    dfx(ikperp,:) = w_fit{1}.*cos(phase(ikperp,:)).*sqrt(2.*dkperp./w_fit{4}).*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25);
                                    dfy(ikperp,:) = w_fit{2}.*cos(phase(ikperp,:)).*sqrt(2.*dkperp./w_fit{4}).*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25);
                                    dfz(ikperp,:) = w_fit{3}.*cos(phase(ikperp,:)).*sqrt(2.*dkperp./w_fit{4}).*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25);
                                end
                                %
                                df = sqrt(dfx.^2 + dfy.^2 + dfz.^2).*sign(dfz);
                            end
                            %
                            f = sum(df,1);
                            %
                            figure('Name',[v,'[',int2str(ifield),']']);
                            plot(theta,f,'r');
                            xlabel('\theta');ylabel([v,'[',int2str(ifield),']']);
                            title(['@ \rho = ',num2str(rho)]);
                            %
                            [h0,hx] = hist(f,max([11,round(ntheta/100)]));
                            h1 = h0/ntheta;
                            if length(w_fit) == 3,
                                hm = (hx(2)-hx(1))*exp(-hx.*hx/2/w_fit{1}(1,1)^2)/sqrt(2*pi)/w_fit{1}(1,1);
                            else
                                hm = (hx(2)-hx(1))*exp(-hx.*hx/2/(w_fit{1}(1,1)^2+w_fit{2}(1,1)^2+w_fit{3}(1,1)^2))/sqrt(2*pi)/sqrt((w_fit{1}(1,1)^2+w_fit{2}(1,1)^2+w_fit{3}(1,1)^2));
                            end
                            figure('Name',[v,'[',int2str(ifield),']']);
                            plot(hx,h1,'b',hx,hm,'r');
                            xlabel([v,'[',int2str(ifield),']']);
                            ylabel(['f(',v,'[',int2str(ifield),'])']);
                            title(['@ \rho = ',num2str(rho)]);
                            legend('Numerical distribution','1-D Maxwellian distribution');
                            drawnow;
                        end
                    else
                        disp('WARNING: no results for magnetic ripple.');
                    end    
                end
            end
        end
    end
else
	for i = 1:length(field_name)-1,
	    if isfield(fluct_fit,field_name(i)),
	        if isstruct(fluct_fit.(char(field_name(i)))) & ~isempty(strfind(char(field_name(i)),'_fit')),
	            for ifield = 1:length(fluct_fit.(char(field_name(i)))),
	                v = regexprep(char(field_name(i)),'_fit','');
					subfield_name = fieldnames(fluct_fit.(char(field_name(i))));
					if strfind(subfield_name{2},'pp_'),
						if mode == 1,
			                %
			                % calculation at all radial positions of all coefficients for the Fourier series
			                %
			                a0_fit = ppval(fluct_fit.(char(field_name(i))).pp_a0,rho);
			                an_fit = ppval(fluct_fit.(char(field_name(i))).pp_an,rho);
			                bn_fit = ppval(fluct_fit.(char(field_name(i))).pp_bn,rho);
			                da0drho_fit = ppval(fluct_fit.(char(field_name(i))).pp_da0drho,rho);
			                dandrho_fit = ppval(fluct_fit.(char(field_name(i))).pp_dandrho,rho);
			                dbndrho_fit = ppval(fluct_fit.(char(field_name(i))).pp_dbndrho,rho);
			                %
			                % calculation of the value at all poloidal angles
			                %
			                for ii = 1:length(theta),
			                    [v_fit(:,ii),dvdtheta_fit(:,ii),d2vdtheta2_fit(:,ii),dvdrho_fit(:,ii),d2vdthetadrho_fit(:,ii)] = calcval_yp(fluct_fit.(char(field_name(i))),theta(ii),a0_fit(:),an_fit,bn_fit,da0drho_fit(:),dandrho_fit,dbndrho_fit);
                                %
                                if strfind(char(field_name(i)),'cm') & (length(rho) == 1) & length(theta) == 1,%for the fluctuation phase
                                    [iv_fit(:,ii),idvdrho_fit(:,ii)] = intval_yp(fluct_fit.(char(field_name(i))),theta(ii),a0_fit(:),an_fit,bn_fit,da0drho_fit(:),dandrho_fit,dbndrho_fit);
                                end
                            end
	                        %
	                        if nargin < 4,
		                    	%                                       
			                    v0 = fluct.(regexprep(char(field_name(i)),'_fit',''));
			                    %
			                    [dvdtheta,dvdrho] = gradient(v0);
			                    dvdtheta = dvdtheta./(ones(length(dprho),1)*dtheta);
			                    dvdrho = dvdrho./(dprho(:)*ones(1,length(dtheta)));
			                    %
			                    [d2vdtheta2,d2vdthetadrho] = gradient(dvdtheta);
			                    d2vdtheta2 = d2vdtheta2./(ones(length(dprho),1)*dtheta);
			                    d2vdthetadrho = d2vdthetadrho./(dprho(:)*ones(1,length(dtheta)));
			                    %
			                    [d2vdrhodtheta,d2vdrho2] = gradient(dvdrho);
			                    d2vdrhodtheta = d2vdrhodtheta./(ones(length(dprho),1)*dtheta);
			                    d2vdrho2 = d2vdrho2./(dprho(:)*ones(1,length(dtheta)));
			                    %
			                    figure('Name',v);
			                    subplot(1,2,1),plot(rho,v0,'b+-',rho,v_fit,'r-');ylabel(v);xlabel('\rho');
			                    subplot(1,2,2),plot(theta/2/pi,v0,'b+-',theta/2/pi,v_fit,'r-');xlabel('\theta/2\pi');
			                    %
			                   	figure('Name',['d',v,'/drho']);
			                    subplot(1,2,1),plot(rho,dvdrho,'b+-',rho,dvdrho_fit,'r-');ylabel(['d',v,'/drho']);xlabel('\rho');
			                    subplot(1,2,2),plot(theta/2/pi,dvdrho,'b+-',theta/2/pi,dvdrho_fit,'r-');xlabel('\theta/2\pi');
			                    %
			                    figure('Name',['d',v,'/dtheta']);
			                    subplot(1,2,1),plot(rho,dvdtheta,'b+-',rho,dvdtheta_fit,'r-');ylabel(['d',v,'/dtheta']);xlabel('\rho');
			                    subplot(1,2,2),plot(theta/2/pi,dvdtheta,'b+-',theta/2/pi,dvdtheta_fit,'r-');xlabel('\theta/2\pi');
			                    %
			                    figure('Name',['d2',v,'/dtheta2']);
			                    subplot(1,2,1),plot(rho,d2vdtheta2,'b+-',rho,d2vdtheta2_fit,'r-');ylabel(['d2',v,'/dtheta2']);xlabel('\rho');
			                    subplot(1,2,2),plot(theta/2/pi,d2vdtheta2,'b+-',theta/2/pi,d2vdtheta2_fit,'r-');xlabel('\theta/2\pi');
			                    %
			                    figure('Name',['d2',v,'/dthetadrho']);
			                    subplot(1,2,1),plot(rho,d2vdthetadrho,'b+-',rho,d2vdthetadrho_fit,'r-');ylabel(['d2',v,'/dthetadrho']);xlabel('\rho');
			                    subplot(1,2,2),plot(theta/2/pi,d2vdthetadrho,'b+-',theta/2/pi,d2vdthetadrho_fit,'r-');xlabel('\theta/2\pi');
							else
	                            if (length(rho) > 1) & (length(theta) > 1),
	                                figure('Name',[v,'[',int2str(ifield),'] - ',char(field_name(i))]);
	                                subplot(1,2,1),plot(rho,v_fit,'r-');ylabel([char(field_name(i))]);xlabel('\rho');
	                                subplot(1,2,2),plot(theta/2/pi,v_fit,'r-');xlabel('\theta/2\pi');
	                                %
	                                figure('Name',[v,'[',int2str(ifield),']: d',char(field_name(i)),'/drho']);
	                                subplot(1,2,1),plot(rho,dvdrho_fit,'r-');ylabel(['d',char(subfield_name(isubfield)),'/drho']);xlabel('\rho');
	                                subplot(1,2,2),plot(theta/2/pi,dvdrho_fit,'r-');xlabel('\theta/2\pi');
	                                %
	                                figure('Name',[v,'[',int2str(ifield),'] d',char(field_name(i)),'/dtheta']);
	                                subplot(1,2,1),plot(rho,dvdtheta_fit,'r-');ylabel(['d',char(subfield_name(isubfield)),'/dtheta']);xlabel('\rho');
	                                subplot(1,2,2),plot(theta/2/pi,dvdtheta_fit,'r-');xlabel('\theta/2\pi');
	                                %
	                                figure('Name',[v,'[',int2str(ifield),'] d2',char(field_name(i)),'/dtheta2']);
	                                subplot(1,2,1),plot(rho,d2vdtheta2_fit,'r-');ylabel(['d2',char(subfield_name(isubfield)),'/dtheta2']);xlabel('\rho');
	                                subplot(1,2,2),plot(theta/2/pi,d2vdtheta2_fit,'r-');xlabel('\theta/2\pi');
	                                %
	                                figure('Name',[v,'[',int2str(ifield),'] d2',char(field_name(i)),'/dthetadrho']);
	                                subplot(1,2,1),plot(rho,d2vdthetadrho_fit,'r-');ylabel(['d2',char(subfield_name(isubfield)),'/dthetadrho']);xlabel('\rho');
	                                subplot(1,2,2),plot(theta/2/pi,d2vdthetadrho_fit,'r-');xlabel('\theta/2\pi');
	                                %                                    
	                            elseif (length(rho) == 1) & length(theta) == 1,
	                            	disp(['-------------- @ (rho = ',num2str(rho),',theta = ',num2str(theta),') --------------']);
	
	                                disp([char(field_name(i)),' = ',num2str(v_fit)]);
	                                disp(['d',char(field_name(i)),'/drho = ',num2str(dvdrho_fit)]);
	                                disp(['d',char(field_name(i)),'/dtheta = ',num2str(dvdtheta_fit)]);
	                                % disp(['d2',char(field_name(i)),'/drho2 = ',num2str()]);
	                                disp(['d2',char(field_name(i)),'/dtheta2 = ',num2str(d2vdtheta2_fit)]);
	                                disp(['d2',char(field_name(i)),'/dthetadrho = ',num2str(d2vdthetadrho_fit)]);
                                    %
                                    if strfind(char(field_name(i)),'cm'),%for the fluctuation phase
                                        disp(['i',char(field_name(i)),' = ',num2str(iv_fit)]);
                                        disp(['id',char(field_name(i)),'/drho = ',num2str(idvdrho_fit)]);
                                    end
                                end
			            	end    
		                else
		                	error('Mode 2 (x,y) not yet implemented in fitfluct_yp.m');
		                end
                    else
		                for isubfield = 3:length(subfield_name)-1,
			                if mode == 1,
			                    %
			                    % calculation at all radial positions of all coefficients for the Fourier series
			                    %
			                    a0_fit = ppval(fluct_fit.(char(field_name(i)))(ifield).([char(subfield_name(isubfield))]).pp_a0,rho);
			                    an_fit = ppval(fluct_fit.(char(field_name(i)))(ifield).([char(subfield_name(isubfield))]).pp_an,rho);
			                    bn_fit = ppval(fluct_fit.(char(field_name(i)))(ifield).([char(subfield_name(isubfield))]).pp_bn,rho);
			                    da0drho_fit = ppval(fluct_fit.(char(field_name(i)))(ifield).([char(subfield_name(isubfield))]).pp_da0drho,rho);
			                    dandrho_fit = ppval(fluct_fit.(char(field_name(i)))(ifield).([char(subfield_name(isubfield))]).pp_dandrho,rho);
			                    dbndrho_fit = ppval(fluct_fit.(char(field_name(i)))(ifield).([char(subfield_name(isubfield))]).pp_dbndrho,rho);
		                        %
		                        % calculation of the value at all poloidal angles
		                        %
		                        for ii = 1:length(theta),
		                            [v_fit(:,ii),dvdtheta_fit(:,ii),d2vdtheta2_fit(:,ii),dvdrho_fit(:,ii),d2vdthetadrho_fit(:,ii)] = calcval_yp(fluct_fit.(char(field_name(i)))(ifield).([char(subfield_name(isubfield))]),theta(ii),a0_fit(:),an_fit,bn_fit,da0drho_fit(:),dandrho_fit,dbndrho_fit);
		                        end
		                        %
		                        if nargin < 4,
			                    	%                                       
				                    v0 = fluct.(regexprep(char(field_name(i)),'_fit',''))(ifield).(regexprep(char(subfield_name(isubfield)),'_fit',''));
				                    %
				                    [dvdtheta,dvdrho] = gradient(v0);
				                    dvdtheta = dvdtheta./(ones(length(dprho),1)*dtheta);
				                    dvdrho = dvdrho./(dprho(:)*ones(1,length(dtheta)));
				                    %
				                    [d2vdtheta2,d2vdthetadrho] = gradient(dvdtheta);
				                    d2vdtheta2 = d2vdtheta2./(ones(length(dprho),1)*dtheta);
				                    d2vdthetadrho = d2vdthetadrho./(dprho(:)*ones(1,length(dtheta)));
				                    %
				                    [d2vdrhodtheta,d2vdrho2] = gradient(dvdrho);
				                    d2vdrhodtheta = d2vdrhodtheta./(ones(length(dprho),1)*dtheta);
				                    d2vdrho2 = d2vdrho2./(dprho(:)*ones(1,length(dtheta)));
				                    %
				                    figure('Name',[v,'[',int2str(ifield),'] - ',char(subfield_name(isubfield))]);
				                    subplot(1,2,1),plot(rho,v0,'b+-',rho,v_fit,'r-');ylabel([char(subfield_name(isubfield))]);xlabel('\rho');
				                    subplot(1,2,2),plot(theta/2/pi,v0,'b+-',theta/2/pi,v_fit,'r-');xlabel('\theta/2\pi');
				                    %
				                   	figure('Name',[v,'[',int2str(ifield),']: d',char(subfield_name(isubfield)),'/drho']);
				                    subplot(1,2,1),plot(rho,dvdrho,'b+-',rho,dvdrho_fit,'r-');ylabel(['d',char(subfield_name(isubfield)),'/drho']);xlabel('\rho');
				                    subplot(1,2,2),plot(theta/2/pi,dvdrho,'b+-',theta/2/pi,dvdrho_fit,'r-');xlabel('\theta/2\pi');
				                    %
				                    figure('Name',[v,'[',int2str(ifield),'] d',char(subfield_name(isubfield)),'/dtheta']);
				                    subplot(1,2,1),plot(rho,dvdtheta,'b+-',rho,dvdtheta_fit,'r-');ylabel(['d',char(subfield_name(isubfield)),'/dtheta']);xlabel('\rho');
				                    subplot(1,2,2),plot(theta/2/pi,dvdtheta,'b+-',theta/2/pi,dvdtheta_fit,'r-');xlabel('\theta/2\pi');
				                    %
				                    figure('Name',[v,'[',int2str(ifield),'] d2',char(subfield_name(isubfield)),'/dtheta2']);
				                    subplot(1,2,1),plot(rho,d2vdtheta2,'b+-',rho,d2vdtheta2_fit,'r-');ylabel(['d2',char(subfield_name(isubfield)),'/dtheta2']);xlabel('\rho');
				                    subplot(1,2,2),plot(theta/2/pi,d2vdtheta2,'b+-',theta/2/pi,d2vdtheta2_fit,'r-');xlabel('\theta/2\pi');
				                    %
				                    figure('Name',[v,'[',int2str(ifield),'] d2',char(subfield_name(isubfield)),'/dthetadrho']);
				                    subplot(1,2,1),plot(rho,d2vdthetadrho,'b+-',rho,d2vdthetadrho_fit,'r-');ylabel(['d2',char(subfield_name(isubfield)),'/dthetadrho']);xlabel('\rho');
				                    subplot(1,2,2),plot(theta/2/pi,d2vdthetadrho,'b+-',theta/2/pi,d2vdthetadrho_fit,'r-');xlabel('\theta/2\pi');
								else
		                            if (length(rho) > 1) & (length(theta) > 1),
		                                figure('Name',[v,'[',int2str(ifield),'] - ',char(subfield_name(isubfield))]);
		                                subplot(1,2,1),plot(rho,v_fit,'r-');ylabel([char(subfield_name(isubfield))]);xlabel('\rho');
		                                subplot(1,2,2),plot(theta/2/pi,v_fit,'r-');xlabel('\theta/2\pi');
		                                %
		                                figure('Name',[v,'[',int2str(ifield),']: d',char(subfield_name(isubfield)),'/drho']);
		                                subplot(1,2,1),plot(rho,dvdrho_fit,'r-');ylabel(['d',char(subfield_name(isubfield)),'/drho']);xlabel('\rho');
		                                subplot(1,2,2),plot(theta/2/pi,dvdrho_fit,'r-');xlabel('\theta/2\pi');
		                                %
		                                figure('Name',[v,'[',int2str(ifield),'] d',char(subfield_name(isubfield)),'/dtheta']);
		                                subplot(1,2,1),plot(rho,dvdtheta_fit,'r-');ylabel(['d',char(subfield_name(isubfield)),'/dtheta']);xlabel('\rho');
		                                subplot(1,2,2),plot(theta/2/pi,dvdtheta_fit,'r-');xlabel('\theta/2\pi');
		                                %
		                                figure('Name',[v,'[',int2str(ifield),'] d2',char(subfield_name(isubfield)),'/dtheta2']);
		                                subplot(1,2,1),plot(rho,d2vdtheta2_fit,'r-');ylabel(['d2',char(subfield_name(isubfield)),'/dtheta2']);xlabel('\rho');
		                                subplot(1,2,2),plot(theta/2/pi,d2vdtheta2_fit,'r-');xlabel('\theta/2\pi');
		                                %
		                                figure('Name',[v,'[',int2str(ifield),'] d2',char(subfield_name(isubfield)),'/dthetadrho']);
		                                subplot(1,2,1),plot(rho,d2vdthetadrho_fit,'r-');ylabel(['d2',char(subfield_name(isubfield)),'/dthetadrho']);xlabel('\rho');
		                                subplot(1,2,2),plot(theta/2/pi,d2vdthetadrho_fit,'r-');xlabel('\theta/2\pi');
		                                %                                    
		                            elseif (length(rho) == 1) & length(theta) == 1,
		                            	disp(['-------------- ',v,'[',int2str(ifield),']  @ (rho = ',num2str(rho),',theta = ',num2str(theta),') --------------']);
		                                disp([char(subfield_name(isubfield)),'  = ',num2str(v_fit)]);
		                                disp(['d',char(subfield_name(isubfield)),'/drho = ',num2str(dvdrho_fit)]);
		                                disp(['d',char(subfield_name(isubfield)),'/dtheta = ',num2str(dvdtheta_fit)]);
		                                % disp(['d2',char(subfield_name(isubfield)),'/drho2 = ',num2str()]);
		                                disp(['d2',char(subfield_name(isubfield)),'/dtheta2 = ',num2str(d2vdtheta2_fit)]);
		                                disp(['d2',char(subfield_name(isubfield)),'/dthetadrho = ',num2str(d2vdthetadrho_fit)]);
		                            end
								end
							else
								error('Mode 2 (x,y) not yet implemented in fitfluct_yp.m');
							end
						end
					end
				end
			end				
		end				
	end
end
