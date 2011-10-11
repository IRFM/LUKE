function [fluctval] = fluctval_yp(equil_fit,fluct_fit,rho,theta,phi,theta0,phi0,mode)
%
% This function calculates the local perturbation of the magnetic equilibrium at any position in the plasma
%
%   INPUT :
%
%       - equil_fit: fitted axisymmetric magnetic equilibrium structure
%       - fluct_fit: structure of the magnetic equilibrium fluctuations (including magnetic ripple)
%       - rho: normalized minor radius (a.u.) [1,1]
%       - theta: poloidal angle (rad) [1,1]
%       - phi: toroidal angle (rad) [1,1]
%       - theta0: reference of the initial poloidal angle for some fluctuation models (rad) [1,1]
%       - phi0: reference of the initial toroidal angle for some fluctuation models (rad) [1,1]
%       - mode: coordinate system for the magnetic equilibrium (1) -> (rho or psi,theta), (2) -> (x,y) [1,1]
%         (optional, default value : 1)
%
%   OUTPUT :
%
%       - fluctval: structure of the values of the magnetic equilibrium fluctuations at (rho, theta, phi)
%
% by Y. Peysson DRFC-CEA <yves.peysson@cea.fr> and J. Decker DRFC-CEA <joan.decker@cea.fr> 
%
if nargin < 5,
    error('Not enough input arguments in fluctval_yp.m')
end
%
if nargin == 5,
    theta0 = theta;
    phi0 = phi;
    mode = 1;
end
%
if nargin == 6,
    phi0 = phi;
    mode = 1;
end
%
if nargin == 7,
    mode = 1;
end
%
[Te,dTedrho,dummy,ne,dnedrho,dummy,zTi,dzTidrho,dummy,zni,dznidrho,dummy,...
R,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,...
r,dummy,dummy,salpha,dsalphadtheta,dsalphadrho,calpha,dcalphadtheta,dcalphadrho,...
dummy,dummy,dummy,dummy,dummy,...
dummy,dummy,dummy,dummy,dummy,...
BPHI,dBPHIdtheta,dummy,dBPHIdrho,dummy,...
BP,dummy,dummy,B,dBdtheta,dBdrho,...
gradrho,dgradrhodtheta,dgradrhodrho] = equilval_yp(equil_fit,rho,theta,mode);%axisymmetric magnetic equilibrium
%
fluctval.ner = 0;
fluctval.dnerdrho = 0;
fluctval.dnerdtheta = 0;
fluctval.dnerdphi = 0;
%
fluctval.Ter = 0;
fluctval.dTerdrho = 0;
fluctval.dTerdtheta = 0;
fluctval.dTerdphi = 0;
%
fluctval.znir = zeros(size(zni'));
fluctval.dznirdrho = zeros(size(zni'));
fluctval.dznirdtheta = zeros(size(zni'));
fluctval.dznirdphi = zeros(size(zni'));
%
fluctval.zTir = zeros(size(zTi'));
fluctval.dzTirdrho = zeros(size(zTi'));
fluctval.dzTirdtheta = zeros(size(zTi'));
fluctval.dzTirdphi = zeros(size(zTi'));
%
fluctval.Bxr = 0;
fluctval.dBxrdrho = 0;
fluctval.dBxrdtheta = 0;
fluctval.dBxrdphi = 0;
%
fluctval.Byr = 0;
fluctval.dByrdrho = 0;
fluctval.dByrdtheta = 0;
fluctval.dByrdphi = 0;
%
fluctval.Bzr = 0;
fluctval.dBzrdrho = 0;
fluctval.dBzrdtheta = 0;
fluctval.dBzrdphi = 0;
%
field_name = fieldnames(fluct_fit);
%
L_rho = fluct_fit.L_rho;
dL_rhodrho = 0;
dL_rhodtheta = 0;
dL_rhodphi = 0;
%
xq_fit = ppval(fluct_fit.xq_fit.pp_f,rho);
dxqdrho_fit = ppval(fluct_fit.xq_fit.pp_dfdrho,rho);
dxqdtheta_fit = 0;
dxqdphi_fit = 0;
%
xL_theta_fit = ppval(fluct_fit.xL_theta_fit.pp_f,rho);
dxL_thetadrho_fit = ppval(fluct_fit.xL_theta_fit.pp_dfdrho,rho);
dxL_thetadtheta_fit = 0;
dxL_thetadphi_fit = 0; 
%
xL_perp_fit = ppval(fluct_fit.xL_perp_fit.pp_f,rho);
dxL_perpdrho_fit = ppval(fluct_fit.xL_perp_fit.pp_dfdrho,rho);
dxL_perpdtheta_fit = 0;
dxL_perpdphi_fit = 0;
%
a0_fit = ppval(fluct_fit.XL_phi_fit.pp_a0,rho);
an_fit = ppval(fluct_fit.XL_phi_fit.pp_an,rho);
bn_fit = ppval(fluct_fit.XL_phi_fit.pp_bn,rho);
da0drho_fit = ppval(fluct_fit.XL_phi_fit.pp_da0drho,rho);
dandrho_fit = ppval(fluct_fit.XL_phi_fit.pp_dandrho,rho);
dbndrho_fit = ppval(fluct_fit.XL_phi_fit.pp_dbndrho,rho);
%
for ii = 1:length(theta),
	[XL_phi_fit(:,ii),dXL_phidtheta_fit(:,ii),dummy,dXL_phidrho_fit(:,ii)] = calcval_yp(fluct_fit.XL_phi_fit,theta(ii),a0_fit(:),an_fit,bn_fit,da0drho_fit(:),dandrho_fit,dbndrho_fit);
end
dXL_phidphi_fit = 0;
%
a0_fit = ppval(fluct_fit.Xcm_fit.pp_a0,rho);
an_fit = ppval(fluct_fit.Xcm_fit.pp_an,rho);
bn_fit = ppval(fluct_fit.Xcm_fit.pp_bn,rho);
da0drho_fit = ppval(fluct_fit.Xcm_fit.pp_da0drho,rho);
dandrho_fit = ppval(fluct_fit.Xcm_fit.pp_dandrho,rho);
dbndrho_fit = ppval(fluct_fit.Xcm_fit.pp_dbndrho,rho);
%
for ii = 1:length(theta),
	[Xcm_fit(:,ii),dXcmdtheta_fit(:,ii),dummy,dXcmdrho_fit(:,ii)] = calcval_yp(fluct_fit.Xcm_fit,theta(ii),a0_fit(:),an_fit,bn_fit,da0drho_fit(:),dandrho_fit,dbndrho_fit);%For the fluctuation phase calculation (model 5)
    [Xicm_fit(:,ii),dXicmdrho_fit(:,ii)] = intval_yp(fluct_fit.Xcm_fit,theta0,theta(ii),a0_fit(:),an_fit,bn_fit,da0drho_fit(:),dandrho_fit,dbndrho_fit);%For the fluctuation phase calculation (model 5)
end
dXcmdphi_fit = 0;
%
a0_fit = ppval(fluct_fit.Xcn_fit.pp_a0,rho);
an_fit = ppval(fluct_fit.Xcn_fit.pp_an,rho);
bn_fit = ppval(fluct_fit.Xcn_fit.pp_bn,rho);
da0drho_fit = ppval(fluct_fit.Xcn_fit.pp_da0drho,rho);
dandrho_fit = ppval(fluct_fit.Xcn_fit.pp_dandrho,rho);
dbndrho_fit = ppval(fluct_fit.Xcn_fit.pp_dbndrho,rho);
%
[Xcn0_fit(:,ii),dXcn0dtheta_fit(:,ii),dummy,dXcn0drho_fit(:,ii)] = calcval_yp(fluct_fit.Xcn_fit,theta0,a0_fit(:),an_fit,bn_fit,da0drho_fit(:),dandrho_fit,dbndrho_fit);%For the fluctuation phase calculation (model 5)
dXcn0dphi_fit = 0;
%
for i = 1:length(field_name),
    if isfield(fluct_fit,field_name(i)),
        if isstruct(fluct_fit.(char(field_name(i)))) && (strcmp(char(field_name(i)),'B_fit') || strcmp(char(field_name(i)),'ne_fit')),   
            for ifield = 1:length(fluct_fit.(char(field_name(i)))),
                subfield_name = fieldnames(fluct_fit.(char(field_name(i))));
                v = regexprep(char(field_name(i)),'_fit','');
                %
                sigmar_max = fluct_fit.(char(field_name(i)))(ifield).sigmar_max;
                sigmar_hwhm = fluct_fit.(char(field_name(i)))(ifield).sigmar_hwhm;
                sigmar_rho = fluct_fit.(char(field_name(i)))(ifield).sigmar_rho;
                polmode = fluct_fit.(char(field_name(i)))(ifield).polmode;
                epsi_rho = fluct_fit.(char(field_name(i)))(ifield).epsi_rho;
                epsi_theta = fluct_fit.(char(field_name(i)))(ifield).epsi_theta;
                epsi_phi = fluct_fit.(char(field_name(i)))(ifield).epsi_phi;
                lmin = fluct_fit.(char(field_name(i)))(ifield).lmin;
                mmin = fluct_fit.(char(field_name(i)))(ifield).mmin;
                nmin = fluct_fit.(char(field_name(i)))(ifield).nmin;
                lmax = fluct_fit.(char(field_name(i)))(ifield).lmax;
                mmax = fluct_fit.(char(field_name(i)))(ifield).mmax;
                nmax = fluct_fit.(char(field_name(i)))(ifield).nmax;            
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
                                [w_fit{j}(:,ii),dwdtheta_fit{j}(:,ii),d2wdtheta2_fit{j}(:,ii),dwdrho_fit{j}(:,ii),d2wdthetadrho_fit{j}(:,ii)] = calcval_yp(fluct_fit.(char(field_name(i)))(ifield).([char(subfield_name(isubfield))]),theta(ii),a0_fit(:),an_fit,bn_fit,da0drho_fit(:),dandrho_fit,dbndrho_fit);
                            end
                            %
                            j = j + 1;
                        end
                    else
                        error('Mode 2 (x,y) not yet implemented in fitfluct_yp.m');
                    end
                end
                %
                if fluct_fit.(char(field_name(i)))(ifield).model == 7,%(1) -> 2-D Gaussian drift-wave like model local (rho,lperp), absolute epsi values (m)
                    if strcmp(char(field_name(i)),'ne_fit'),

                    elseif strcmp(char(field_name(i)),'B_fit'),
                        
                        
                        
                        
                    end
                elseif fluct_fit.(char(field_name(i)))(ifield).model == 6,%(1) -> 2-D Gaussian drift-wave like model local (rho,cn,cm), absolute epsi values (m)
                    if strcmp(char(field_name(i)),'ne_fit'),
                        %
                        [l,m] = build_tensor_yp(lmin:lmax,mmin:mmax);
                        %
                        u_l = pi*epsi_rho*[lmin:lmax]/L_rho;
                        u_m = pi*epsi_theta*[mmin:mmax]/xL_perp_fit;%here, epsi_perp = epsi_theta
                        %
                        du_ldrho = -u_l/L_rho*dL_rhodrho;
                        du_mdrho = -u_m/xL_perp_fit*dxL_perpdrho_fit;
                        %
                        du_ldtheta = -u_l/L_rho*dL_rhodtheta;
                        du_mdtheta = -u_m/xL_perp_fit*dxL_perpdtheta_fit;
                        %
                        du_ldphi = -u_l/L_rho*dL_rhodphi;
                        du_mdphi = -u_m/xL_perp_fit*dxL_perpdphi_fit;
                        %
                        expu_l = exp(-u_l.^2/2);
                        expu_m = exp(-u_m.^2/2);
                        %
                        [al,am] = build_tensor_yp(expu_l,expu_m);
                        alm = al.*am;
                        %
                        dexpu_ldrho = -expu_l.*u_l.*du_ldrho;
                        dexpu_mdrho = -expu_m.*u_m.*du_mdrho;
                        %
                        [daldrho,damdrho] = build_tensor_yp(dexpu_ldrho,dexpu_mdrho);
                        dalmdrho = daldrho.*am + al.*damdrho;
                        %
                        dexpu_ldtheta = -expu_l.*u_l.*du_ldtheta;
                        dexpu_mdtheta = -expu_m.*u_m.*du_mdtheta;
                        %
                        [daldtheta,damdtheta] = build_tensor_yp(dexpu_ldtheta,dexpu_mdtheta);
                        dalmdtheta = daldtheta.*am + al.*damdtheta;                        
                        %
                        dexpu_ldphi = -expu_l.*u_l.*du_ldphi;
                        dexpu_mdphi = -expu_m.*u_m.*du_mdphi;
                        %
                        [daldphi,damdphi] = build_tensor_yp(dexpu_ldphi,dexpu_mdphi);
                        dalmdphi = daldphi.*am + al.*damdphi;
                        %
                        kperp = 2*pi*m./xL_perp_fit;
                        dkperpdrho = -kperp./xL_perp_fit.*dxL_perpdrho_fit;
                        dkperpdtheta = 0;
                        dkperpdphi = 0;
                        %                                  
                        phase = 2*pi*l*rho + (Xicm_fit + Xcn0_fit*(phi-phi0))*kperp + reshape(phaseinit,length(lmin:lmax),length(mmin:mmax));
                        dphasedrho = 2*pi*l + (dXicmdrho_fit + dXcn0drho_fit*(phi-phi0))*kperp + (Xicm_fit + Xcn0_fit*(phi-phi0))*dkperpdrho;
                        dphasedtheta = Xcm_fit*kperp + (Xicm_fit + Xcn0_fit*(phi-phi0))*dkperpdtheta;
                        dphasedphi = Xcn0_fit*kperp + (Xicm_fit + Xcn0_fit*(phi-phi0))*dkperpdphi;
                        %
                        Flambda = (1.0 + polmode + (1.0 - polmode)*cos(theta))/2.0;
                        dFlambdadrho = 0;
                        dFlambdadtheta = -(1.0 - polmode)*sin(theta)/2.0;
                        dFlambdadphi = 0;
                        %
                        Fdelta = exp(-log(2.0)*(rho - sigmar_rho)^2.0/sigmar_hwhm^2);
                        dFdeltadrho = -Fdelta*2.0*log(2.0)*(rho - sigmar_rho)/sigmar_hwhm^2;
                        dFdeltadtheta = 0;
                        dFdeltadphi = 0;
                        %
                        ac = 2*sqrt(2*pi)*sigmar_max*sqrt(epsi_rho*epsi_theta/L_rho/xL_perp_fit);
                        dacdrho = -0.5*ac*(dL_rhodrho/L_rho + dxL_perpdrho_fit/xL_perp_fit);
                        dacdtheta = -0.5*ac*(dL_rhodtheta/L_rho + dxL_perpdtheta_fit/xL_perp_fit);
                        dacdphi = -0.5*ac*(dL_rhodphi/L_rho + dxL_perpdphi_fit/xL_perp_fit);                        
                        %     
                        [ht,dht] = halftanh(ac*Flambda*Fdelta*sum(sum(alm.*sin(phase),2),1));
                        %
                        fluctval.([char(v),'r']) = ht;
                        %
                        fluctval.(['d',char(v),'rdrho']) = dht*dacdrho*Flambda*Fdelta*sum(sum(alm.*sin(phase),2),1)...
                                                         + dht*ac*dFlambdadrho*Fdelta*sum(sum(alm.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*dFdeltadrho*sum(sum(alm.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*Fdelta*sum(sum(dalmdrho.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*Fdelta*sum(sum(alm.*cos(phase).*dphasedrho,2),1);
                        %
                        fluctval.(['d',char(v),'rdtheta']) = dht*dacdtheta*Flambda*Fdelta*sum(sum(alm.*sin(phase),2),1)...
                                                         + dht*ac*dFlambdadtheta*Fdelta*sum(sum(alm.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*dFdeltadtheta*sum(sum(alm.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*Fdelta*sum(sum(dalmdtheta.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*Fdelta*sum(sum(alm.*cos(phase).*dphasedtheta,2),1);
                        %
                        fluctval.(['d',char(v),'rdphi']) = dht*dacdphi*Flambda*Fdelta*sum(sum(alm.*sin(phase),2),1)...
                                                         + dht*ac*dFlambdadphi*Fdelta*sum(sum(alm.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*dFdeltadphi*sum(sum(alm.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*Fdelta*sum(sum(dalmdphi.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*Fdelta*sum(sum(alm.*cos(phase).*dphasedphi,2),1);
                        %                        

                    elseif strcmp(char(field_name(i)),'B_fit'),
                        
                        
                        
                        
                    end
                elseif fluct_fit.(char(field_name(i)))(ifield).model == 5,%(1) -> 1-D Gaussian drift-wave like model local (cn,cm), absolute epsi values (m)
                    if strcmp(char(field_name(i)),'ne_fit'),
                        m = [mmin:mmax];
                        %
                        u_m = pi*epsi_theta*[mmin:mmax]/xL_perp_fit;%here, epsi_perp = epsi_theta
                        %
                        du_mdrho = -u_m/xL_perp_fit*dxL_perpdrho_fit;
                        %
                        du_mdtheta = -u_m/xL_perp_fit*dxL_perpdtheta_fit;
                        %
                        du_mdphi = -u_m/xL_perp_fit*dxL_perpdphi_fit;
                        %
                        expu_m = exp(-u_m.^2/2);
                        am = expu_m;
                        %
                        damdrho = -expu_m.*u_m.*du_mdrho;
                        %
                        damdtheta = -expu_m.*u_m.*du_mdtheta;                 
                        %
                        damdphi = -expu_m.*u_m.*du_mdphi;
                        %
                        kperp = 2*pi*[mmin:mmax]/xL_perp_fit;
                        dkperpdrho = -kperp/xL_perp_fit*dxL_perpdrho_fit;
                        dkperpdtheta = 0;
                        dkperpdphi = 0;
                        %
                        phase = (Xicm_fit + Xcn0_fit*(phi-phi0))*kperp + reshape(phaseinit,1,length(mmin:mmax));
                        dphasedrho = (dXicmdrho_fit + dXcn0drho_fit*(phi-phi0))*kperp + (Xicm_fit + Xcn0_fit*(phi-phi0))*dkperpdrho;
                        dphasedtheta = Xcm_fit*kperp + (Xicm_fit + Xcn0_fit*(phi-phi0))*dkperpdtheta;
                        dphasedphi = Xcn0_fit*kperp + (Xicm_fit + Xcn0_fit*(phi-phi0))*dkperpdphi;
                        %
                        Flambda = (1.0 + polmode + (1.0 - polmode)*cos(theta))/2.0;
                        dFlambdadrho = 0;
                        dFlambdadtheta = -(1.0 - polmode)*sin(theta)/2.0;
                        dFlambdadphi = 0;
                        %
                        Fdelta = exp(-log(2.0)*(rho - sigmar_rho)^2.0/sigmar_hwhm^2);
                        dFdeltadrho = -Fdelta*2.0*log(2.0)*(rho - sigmar_rho)/sigmar_hwhm^2;
                        dFdeltadtheta = 0;
                        dFdeltadphi = 0;
                        %
                        ac = 2*sqrt(sqrt(pi))*sigmar_max*sqrt(epsi_theta/xL_perp_fit);
                        dacdrho = -0.5*ac*dxL_perpdrho_fit/xL_perp_fit;
                        dacdtheta = -0.5*ac*dxL_perpdtheta_fit/xL_perp_fit;
                        dacdphi = -0.5*ac*dxL_perpdphi_fit/xL_perp_fit;
                        %     
                        [ht,dht] = halftanh(ac*Flambda*Fdelta*sum(sum(am.*sin(phase),2),1));
                        %
                        fluctval.([char(v),'r']) = ht;
                        %
                        fluctval.(['d',char(v),'rdrho']) = dht*dacdrho*Flambda*Fdelta*sum(sum(am.*sin(phase),2),1)...
                                                         + dht*ac*dFlambdadrho*Fdelta*sum(sum(am.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*dFdeltadrho*sum(sum(am.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*Fdelta*sum(sum(damdrho.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*Fdelta*sum(sum(am.*cos(phase).*dphasedrho,2),1);
                        %
                        fluctval.(['d',char(v),'rdtheta']) = dht*dacdtheta*Flambda*Fdelta*sum(sum(am.*sin(phase),2),1)...
                                                         + dht*ac*dFlambdadtheta*Fdelta*sum(sum(am.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*dFdeltadtheta*sum(sum(am.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*Fdelta*sum(sum(damdtheta.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*Fdelta*sum(sum(am.*cos(phase).*dphasedtheta,2),1);
                        %
                        fluctval.(['d',char(v),'rdphi']) = dht*dacdphi*Flambda*Fdelta*sum(sum(am.*sin(phase),2),1)...
                                                         + dht*ac*dFlambdadphi*Fdelta*sum(sum(am.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*dFdeltadphi*sum(sum(am.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*Fdelta*sum(sum(damdphi.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*Fdelta*sum(sum(am.*cos(phase).*dphasedphi,2),1);
                        %                        
                    elseif strcmp(char(field_name(i)),'B_fit'),
                        
                        
                        
                        
                    end                    
                 elseif fluct_fit.(char(field_name(i)))(ifield).model == 4,%(1) -> 1-D Gaussian drift-wave like model global (rho,curtheta), absolute epsi values (m)
                	%
                    if strcmp(char(field_name(i)),'ne_fit'),
                        
                        m = [mmin:mmax];
                        %
                        u_m = pi*epsi_theta*[mmin:mmax]/xL_perp_fit;%here, epsi_perp = epsi_theta
                        %
                        du_mdrho = -u_m/xL_perp_fit*dxL_perpdrho_fit;
                        %
                        du_mdtheta = -u_m/xL_perp_fit*dxL_perpdtheta_fit;
                        %
                        du_mdphi = -u_m/xL_perp_fit*dxL_perpdphi_fit;
                        %
                        expu_m = exp(-u_m.^2/2);
                        am = expu_m;
                        %
                        damdrho = -expu_m.*u_m.*du_mdrho;
                        %
                        damdtheta = -expu_m.*u_m.*du_mdtheta;                 
                        %
                        damdphi = -expu_m.*u_m.*du_mdphi;
                        %
                        curtheta = xq_fit*(theta - theta0) - (phi - phi0);
                        dcurthetadrho = dxqdrho_fit*(theta - theta0);
                        dcurthetadtheta = xq_fit;
                        dcurthetadphi = -1;                    
                        %
                        phase = m*curtheta + reshape(phaseinit,1,length(mmin:mmax));
                        dphasedrho = m*dcurthetadrho;
                        dphasedtheta = m*dcurthetadtheta;
                        dphasedphi = m*dcurthetadphi;
                        %
                        Flambda = (1.0 + polmode + (1.0 - polmode)*cos(theta))/2.0;
                        dFlambdadrho = 0;
                        dFlambdadtheta = -(1.0 - polmode)*sin(theta)/2.0;
                        dFlambdadphi = 0;
                        %
                        Fdelta = exp(-log(2.0)*(rho - sigmar_rho)^2.0/sigmar_hwhm^2);
                        dFdeltadrho = -Fdelta*2.0*log(2.0)*(rho - sigmar_rho)/sigmar_hwhm^2;
                        dFdeltadtheta = 0;
                        dFdeltadphi = 0;
                        %
                        ac = 2*sqrt(sqrt(pi))*sigmar_max*sqrt(epsi_theta/xL_perp_fit);
                        dacdrho = -0.5*ac*dxL_perpdrho_fit/xL_perp_fit;
                        dacdtheta = -0.5*ac*dxL_perpdtheta_fit/xL_perp_fit;
                        dacdphi = -0.5*ac*dxL_perpdphi_fit/xL_perp_fit;
                        %     
                        [ht,dht] = halftanh(ac*Flambda*Fdelta*sum(sum(am.*sin(phase),2),1));
                        %
                        fluctval.([char(v),'r']) = ht;
                        %
                        fluctval.(['d',char(v),'rdrho']) = dht*dacdrho*Flambda*Fdelta*sum(sum(am.*sin(phase),2),1)...
                                                         + dht*ac*dFlambdadrho*Fdelta*sum(sum(am.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*dFdeltadrho*sum(sum(am.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*Fdelta*sum(sum(damdrho.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*Fdelta*sum(sum(am.*cos(phase).*dphasedrho,2),1);
                        %
                        fluctval.(['d',char(v),'rdtheta']) = dht*dacdtheta*Flambda*Fdelta*sum(sum(am.*sin(phase),2),1)...
                                                         + dht*ac*dFlambdadtheta*Fdelta*sum(sum(am.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*dFdeltadtheta*sum(sum(am.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*Fdelta*sum(sum(damdtheta.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*Fdelta*sum(sum(am.*cos(phase).*dphasedtheta,2),1);
                        %
                        fluctval.(['d',char(v),'rdphi']) = dht*dacdphi*Flambda*Fdelta*sum(sum(am.*sin(phase),2),1)...
                                                         + dht*ac*dFlambdadphi*Fdelta*sum(sum(am.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*dFdeltadphi*sum(sum(am.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*Fdelta*sum(sum(damdphi.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*Fdelta*sum(sum(am.*cos(phase).*dphasedphi,2),1);
                        %                                
                    elseif strcmp(char(field_name(i)),'B_fit'),
                        
                        
                        
                        
                    end                  


                elseif fluct_fit.(char(field_name(i)))(ifield).model == 3,%(1) -> 2-D Gaussian drift-wave like model global (rho,curtheta), absolute epsi values (m)
                	%
                    if strcmp(char(field_name(i)),'ne_fit'),
                        %
                        [l,m] = build_tensor_yp(lmin:lmax,mmin:mmax);
                        %
                        u_l = pi*epsi_rho*[lmin:lmax]/L_rho;
                        u_m = pi*epsi_theta*[mmin:mmax]/xL_perp_fit;%here, epsi_perp = epsi_theta
                        %
                        du_ldrho = -u_l/L_rho*dL_rhodrho;
                        du_mdrho = -u_m/xL_perp_fit*dxL_perpdrho_fit;
                        %
                        du_ldtheta = -u_l/L_rho*dL_rhodtheta;
                        du_mdtheta = -u_m/xL_perp_fit*dxL_perpdtheta_fit;
                        %
                        du_ldphi = -u_l/L_rho*dL_rhodphi;
                        du_mdphi = -u_m/xL_perp_fit*dxL_perpdphi_fit;
                        %
                        expu_l = exp(-u_l.^2/2);
                        expu_m = exp(-u_m.^2/2);
                        %
                        [al,am] = build_tensor_yp(expu_l,expu_m);
                        alm = al.*am;
                        %
                        dexpu_ldrho = -expu_l.*u_l.*du_ldrho;
                        dexpu_mdrho = -expu_m.*u_m.*du_mdrho;
                        %
                        [daldrho,damdrho] = build_tensor_yp(dexpu_ldrho,dexpu_mdrho);
                        dalmdrho = daldrho.*am + al.*damdrho;
                        %
                        dexpu_ldtheta = -expu_l.*u_l.*du_ldtheta;
                        dexpu_mdtheta = -expu_m.*u_m.*du_mdtheta;
                        %
                        [daldtheta,damdtheta] = build_tensor_yp(dexpu_ldtheta,dexpu_mdtheta);
                        dalmdtheta = daldtheta.*am + al.*damdtheta;                        
                        %
                        dexpu_ldphi = -expu_l.*u_l.*du_ldphi;
                        dexpu_mdphi = -expu_m.*u_m.*du_mdphi;
                        %
                        [daldphi,damdphi] = build_tensor_yp(dexpu_ldphi,dexpu_mdphi);
                        dalmdphi = daldphi.*am + al.*damdphi;
                        %
                        curtheta = xq_fit*theta - phi;
                        dcurthetadrho = dxqdrho_fit*theta;
                        dcurthetadtheta = xq_fit;
                        dcurthetadphi = -1;                    
                        %
                        phase = 2*pi*l*rho + m*curtheta + reshape(phaseinit,length(lmin:lmax),length(mmin:mmax));
                        dphasedrho = 2*pi*l + m*dcurthetadrho;
                        dphasedtheta = m*dcurthetadtheta;
                        dphasedphi = m*dcurthetadphi;
                        %
                        Flambda = (1.0 + polmode + (1.0 - polmode)*cos(theta))/2.0;
                        dFlambdadrho = 0;
                        dFlambdadtheta = -(1.0 - polmode)*sin(theta)/2.0;
                        dFlambdadphi = 0;
                        %
                        Fdelta = exp(-log(2.0)*(rho - sigmar_rho)^2.0/sigmar_hwhm^2);
                        dFdeltadrho = -Fdelta*2.0*log(2.0)*(rho - sigmar_rho)/sigmar_hwhm^2;
                        dFdeltadtheta = 0;
                        dFdeltadphi = 0;
                        %
                        ac = 2*sqrt(2*pi)*sigmar_max*sqrt(epsi_rho*epsi_theta/L_rho/xL_perp_fit);
                        dacdrho = -0.5*ac*(dL_rhodrho/L_rho + dxL_perpdrho_fit/xL_perp_fit);
                        dacdtheta = -0.5*ac*(dL_rhodtheta/L_rho + dxL_perpdtheta_fit/xL_perp_fit);
                        dacdphi = -0.5*ac*(dL_rhodphi/L_rho + dxL_perpdphi_fit/xL_perp_fit);
                        %      
                        [ht,dht] = halftanh(ac*Flambda*Fdelta*sum(sum(alm.*sin(phase),2),1));
                        %
                        fluctval.([char(v),'r']) = ht;
                        %
                        fluctval.(['d',char(v),'rdrho']) = dht*dacdrho*Flambda*Fdelta*sum(sum(alm.*sin(phase),2),1)...
                                                         + dht*ac*dFlambdadrho*Fdelta*sum(sum(alm.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*dFdeltadrho*sum(sum(alm.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*Fdelta*sum(sum(dalmdrho.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*Fdelta*sum(sum(alm.*cos(phase).*dphasedrho,2),1);
                        %
                        fluctval.(['d',char(v),'rdtheta']) = dht*dacdtheta*Flambda*Fdelta*sum(sum(alm.*sin(phase),2),1)...
                                                         + dht*ac*dFlambdadtheta*Fdelta*sum(sum(alm.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*dFdeltadtheta*sum(sum(alm.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*Fdelta*sum(sum(dalmdtheta.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*Fdelta*sum(sum(alm.*cos(phase).*dphasedtheta,2),1);
                        %
                        fluctval.(['d',char(v),'rdphi']) = dht*dacdphi*Flambda*Fdelta*sum(sum(alm.*sin(phase),2),1)...
                                                         + dht*ac*dFlambdadphi*Fdelta*sum(sum(alm.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*dFdeltadphi*sum(sum(alm.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*Fdelta*sum(sum(dalmdphi.*sin(phase),2),1)...
                                                         + dht*ac*Flambda*Fdelta*sum(sum(alm.*cos(phase).*dphasedphi,2),1);
                        %
                    elseif strcmp(char(field_name(i)),'B_fit'),
                        
                        
                        
                        
                    end                  
                elseif fluct_fit.(char(field_name(i)))(ifield).model == 2,%(1) -> 3-D Gaussian model (rho,theta,phi), absolute epsi values (benchmark of C3PO)
                	%
                    if strcmp(char(field_name(i)),'ne_fit'),
                        %
                        [l,m,n] = build_tensor_yp(lmin:lmax,mmin:mmax,nmin:nmax);
                        %
                        u_l = pi*epsi_rho*[lmin:lmax]/L_rho;
                        u_m = pi*epsi_theta*[mmin:mmax]/xL_theta_fit;
                        u_n = pi*epsi_phi*[nmin:nmax]/XL_phi_fit;
                        %
                        du_ldrho = -u_l/L_rho*dL_rhodrho;
                        du_mdrho = -u_m/xL_theta_fit*dxL_thetadrho_fit;
                        du_ndrho = -u_n/XL_phi_fit*dXL_phidrho_fit;
                        %
                        du_ldtheta = -u_l/L_rho*dL_rhodtheta;
                        du_mdtheta = -u_m/xL_theta_fit*dxL_thetadtheta_fit;
                        du_ndtheta = -u_n/XL_phi_fit*dXL_phidtheta_fit;
                        %
                        du_ldphi = -u_l/L_rho*dL_rhodphi;
                        du_mdphi = -u_m/xL_theta_fit*dxL_thetadphi_fit;
                        du_ndphi = -u_n/XL_phi_fit*dXL_phidphi_fit;
                        %
                        expu_l = exp(-u_l.^2/2);
                        expu_m = exp(-u_m.^2/2);
                        expu_n = exp(-u_n.^2/2);
                        %
                        [al,am,an] = build_tensor_yp(expu_l,expu_m,expu_n);
                        almn = al.*am.*an;
                        %
                        dexpu_ldrho = -expu_l.*u_l.*du_ldrho;
                        dexpu_mdrho = -expu_m.*u_m.*du_mdrho;
                        dexpu_ndrho = -expu_n.*u_n.*du_ndrho;
                        %
                        [daldrho,damdrho,dandrho] = build_tensor_yp(dexpu_ldrho,dexpu_mdrho,dexpu_ndrho);
                        dalmndrho = daldrho.*am.*an + al.*damdrho.*an + al.*am.*dandrho;
                        %
                        dexpu_ldtheta = -expu_l.*u_l.*du_ldtheta;
                        dexpu_mdtheta = -expu_m.*u_m.*du_mdtheta;
                        dexpu_ndtheta = -expu_n.*u_n.*du_ndtheta; 
                        %
                        [daldtheta,damdtheta,dandtheta] = build_tensor_yp(dexpu_ldtheta,dexpu_mdtheta,dexpu_ndtheta);
                        dalmndtheta = daldtheta.*am.*an + al.*damdtheta.*an + al.*am.*dandtheta;                        
                        %
                        dexpu_ldphi = -expu_l.*u_l.*du_ldphi;
                        dexpu_mdphi = -expu_m.*u_m.*du_mdphi;
                        dexpu_ndphi = -expu_n.*u_n.*du_ndphi;
                        %
                        [daldphi,damdphi,dandphi] = build_tensor_yp(dexpu_ldphi,dexpu_mdphi,dexpu_ndphi);
                        dalmndphi = daldphi.*am.*an + al.*damdphi.*an + al.*am.*dandphi;
                        %
                        phase = 2*pi*l*rho + m*theta + n*phi + reshape(phaseinit,length(lmin:lmax),length(mmin:mmax),length(nmin:nmax));
                        dphasedrho = 2*pi*l;
                        dphasedtheta = m;
                        dphasedphi = n;
                        %
                        Flambda = (1.0 + polmode + (1.0 - polmode)*cos(theta))/2.0;
                        dFlambdadrho = 0;
                        dFlambdadtheta = -(1.0 - polmode)*sin(theta)/2.0;
                        dFlambdadphi = 0;
                        %
                        Fdelta = exp(-log(2.0)*(rho - sigmar_rho)^2.0/sigmar_hwhm^2);
                        dFdeltadrho = -Fdelta*2.0*log(2.0)*(rho - sigmar_rho)/sigmar_hwhm^2;
                        dFdeltadtheta = 0;
                        dFdeltadphi = 0;
                        %
                        ac = 4*pi^0.75*sigmar_max*sqrt(epsi_rho*epsi_theta*epsi_phi/L_rho/xL_theta_fit/XL_phi_fit);
                        dacdrho = -0.5*ac*(dL_rhodrho/L_rho + dxL_thetadrho_fit/xL_theta_fit + dXL_phidrho_fit/XL_phi_fit);
                        dacdtheta = -0.5*ac*(dL_rhodtheta/L_rho + dxL_thetadtheta_fit/xL_theta_fit + dXL_phidtheta_fit/XL_phi_fit);
                        dacdphi = -0.5*ac*(dL_rhodphi/L_rho + dxL_thetadphi_fit/xL_theta_fit +  dXL_phidphi_fit/XL_phi_fit);
                        %                   
                        [ht,dht] = halftanh(ac*Flambda*Fdelta*sum(sum(sum(almn.*sin(phase),3),2),1));
                        %
                        fluctval.([char(v),'r']) = ht;
                        %
                        fluctval.(['d',char(v),'rdrho']) = dht*dacdrho*Flambda*Fdelta*sum(sum(sum(almn.*sin(phase),3),2),1)...
                                                         + dht*ac*dFlambdadrho*Fdelta*sum(sum(sum(almn.*sin(phase),3),2),1)...
                                                         + dht*ac*Flambda*dFdeltadrho*sum(sum(sum(almn.*sin(phase),3),2),1)...
                                                         + dht*ac*Flambda*Fdelta*sum(sum(sum(dalmndrho.*sin(phase),3),2),1)...
                                                         + dht*ac*Flambda*Fdelta*sum(sum(sum(almn.*cos(phase).*dphasedrho,3),2),1);
                        %
                        fluctval.(['d',char(v),'rdtheta']) = dht*dacdtheta*Flambda*Fdelta*sum(sum(sum(almn.*sin(phase),3),2),1)...
                                                         + dht*ac*dFlambdadtheta*Fdelta*sum(sum(sum(almn.*sin(phase),3),2),1)...
                                                         + dht*ac*Flambda*dFdeltadtheta*sum(sum(sum(almn.*sin(phase),3),2),1)...
                                                         + dht*ac*Flambda*Fdelta*sum(sum(sum(dalmndtheta.*sin(phase),3),2),1)...
                                                         + dht*ac*Flambda*Fdelta*sum(sum(sum(almn.*cos(phase).*dphasedtheta,3),2),1);
                        %
                        fluctval.(['d',char(v),'rdphi']) = dht*dacdphi*Flambda*Fdelta*sum(sum(sum(almn.*sin(phase),3),2),1)...
                                                         + dht*ac*dFlambdadphi*Fdelta*sum(sum(sum(almn.*sin(phase),3),2),1)...
                                                         + dht*ac*Flambda*dFdeltadphi*sum(sum(sum(almn.*sin(phase),3),2),1)...
                                                         + dht*ac*Flambda*Fdelta*sum(sum(sum(dalmndphi.*sin(phase),3),2),1)...
                                                         + dht*ac*Flambda*Fdelta*sum(sum(sum(almn.*cos(phase).*dphasedphi,3),2),1);
                        %
                    elseif strcmp(char(field_name(i)),'B_fit'),
                        
                        
                        
                        
                    end
                elseif fluct_fit.(char(field_name(i)))(ifield).model == 1,%(1) -> 3-D Gaussian model (rho,theta,phi), relative epsi values (benchmark of C3PO)
                	%
                    %dkperp = kperp(2) - kperp(1);%Uniform kperp grid assumed
                    %
                    %keyboard
                    if strcmp(char(field_name(i)),'ne_fit'),

                        [l,m,n] = build_tensor_yp(lmin:lmax,mmin:mmax,nmin:nmax);
                        %
                        u_l = pi*epsi_rho*[lmin:lmax];
                        u_m = pi*epsi_theta*[mmin:mmax];
                        u_n = pi*epsi_phi*[nmin:nmax];
                        %
                        expu_l = exp(-u_l.^2/2);
                        expu_m = exp(-u_m.^2/2);
                        expu_n = exp(-u_n.^2/2);
                        %
                        [al,am,an] = build_tensor_yp(expu_l,expu_m,expu_n);
                        almn = al.*am.*an;                        
                        %
                        phase = 2*pi*l*rho + m*theta + n*phi + reshape(phaseinit,length(lmin:lmax),length(mmin:mmax),length(nmin:nmax));
                        dphasedrho = 2*pi*l;
                        dphasedtheta = m;
                        dphasedphi = n;
                        %
                        Flambda = (1.0 + polmode + (1.0 - polmode)*cos(theta))/2.0;
                        dFlambdadtheta = -(1.0 - polmode)*sin(theta)/2.0;
                        %
                        Fdelta = exp(-log(2.0)*(rho - sigmar_rho)^2.0/sigmar_hwhm^2);
                        dFdeltadrho = -Fdelta*2.0*log(2.0)*(rho - sigmar_rho)/sigmar_hwhm^2;
                        %
                        ac = 4*pi^0.75*sigmar_max*sqrt(epsi_rho*epsi_theta*epsi_phi);
                        %                                                
                        [ht,dht] = halftanh(ac*Flambda*Fdelta*sum(sum(sum(almn.*sin(phase),3),2),1));
                        %
                        fluctval.([char(v),'r']) = ht;
                        %
                        fluctval.(['d',char(v),'rdrho']) = dht*ac*Flambda*Fdelta*sum(sum(sum(almn.*cos(phase).*dphasedrho,3),2),1)...
                                                         + dht*ac*Flambda*dFdeltadrho*sum(sum(sum(almn.*sin(phase),3),2),1);
                        %
                        fluctval.(['d',char(v),'rdtheta']) = dht*ac*Flambda*Fdelta*sum(sum(sum(almn.*cos(phase).*dphasedtheta,3),2),1)...
                                                           + dht*ac*dFlambdadtheta*Fdelta*sum(sum(sum(almn.*sin(phase),3),2),1);
                        %
                        fluctval.(['d',char(v),'rdphi']) = dht*ac*Flambda*Fdelta*sum(sum(sum(almn.*cos(phase).*dphasedphi,3),2),1);
                                             
                        %
                        %for ikperp = 1:nkperp,
                            %
                       %     phase = gphase*kperp(ikperp) + phaseinit(ikperp);
                        %    dphasedrho = dgphasedrho.*kperp(ikperp);
                       %     dphasedtheta = dgphasedtheta.*kperp(ikperp);
                       %     dphasedphi = dgphasedphi.*kperp(ikperp);
                       %     %
                       %     df(ikperp,:) = w_fit{1}.*cos(phase).*sqrt(2.*dkperp./w_fit{2}).*exp(-(kperp(ikperp) - w_fit{3}).^2./w_fit{2}./w_fit{2}./4)/(2*pi)^(0.25);
                            %
                       %     ddfdrho(ikperp,:) = dwdrho_fit{1}.*cos(phase).*sqrt(2.*dkperp./w_fit{2}).*exp(-(kperp(ikperp) - w_fit{3}).^2./w_fit{2}./w_fit{2}./4)/(2*pi)^(0.25)...
                       %                         - w_fit{1}.*dphasedrho.*sin(phase).*sqrt(2.*dkperp./w_fit{2}).*exp(-(kperp(ikperp) - w_fit{3}).^2./w_fit{2}./w_fit{2}./4)/(2*pi)^(0.25)...
                       %                         - 0.5*w_fit{1}.*cos(phase).*dwdrho_fit{2}.*sqrt(2.*dkperp./w_fit{2})./w_fit{2}.*exp(-(kperp(ikperp) - w_fit{3}).^2./w_fit{2}./w_fit{2}./4)/(2*pi)^(0.25)...
                       %                         + w_fit{1}.*cos(phase).*sqrt(2.*dkperp./w_fit{2}).*exp(-(kperp(ikperp) - w_fit{3}).^2./w_fit{2}./w_fit{2}./4)/(2*pi)^(0.25).*(dwdrho_fit{3}.*w_fit{2} + (kperp(ikperp) - w_fit{3}).*dwdrho_fit{2}).*(kperp(ikperp) - w_fit{3})./w_fit{2}.^3./2;
                            %
                       %     ddfdtheta(ikperp,:) = dwdtheta_fit{1}.*cos(phase).*sqrt(2.*dkperp./w_fit{2}).*exp(-(kperp(ikperp) - w_fit{3}).^2./w_fit{2}./w_fit{2}./4)/(2*pi)^(0.25)...
                       %                         - w_fit{1}.*dphasedtheta.*sin(phase).*sqrt(2.*dkperp./w_fit{2}).*exp(-(kperp(ikperp) - w_fit{3}).^2./w_fit{2}./w_fit{2}./4)/(2*pi)^(0.25)...
                       %                         - 0.5*w_fit{1}.*cos(phase).*dwdtheta_fit{2}.*sqrt(2.*dkperp./w_fit{2})./w_fit{2}.*exp(-(kperp(ikperp) - w_fit{3}).^2./w_fit{2}./w_fit{2}./4)/(2*pi)^(0.25)...
                        %                        + w_fit{1}.*cos(phase).*sqrt(2.*dkperp./w_fit{2}).*exp(-(kperp(ikperp) - w_fit{3}).^2./w_fit{2}./w_fit{2}./4)/(2*pi)^(0.25).*(dwdtheta_fit{3}.*w_fit{2} + (kperp(ikperp) - w_fit{3}).*dwdtheta_fit{2}).*(kperp(ikperp) - w_fit{3})./w_fit{2}.^3./2;
                            %
                        %    ddfdphi(ikperp,:) = -w_fit{1}.*dphasedphi.*sin(phase).*sqrt(2.*dkperp./w_fit{2}).*exp(-(kperp(ikperp) - w_fit{3}).^2./w_fit{2}./w_fit{2}./4)/(2*pi)^(0.25);                                                      
                        %end
                        %
                        %fluctval.([char(v),'r']) = fluctval.([char(v),'r']) + sum(df,1);
                        %fluctval.(['d',char(v),'rdrho']) = fluctval.(['d',char(v),'rdrho']) + sum(ddfdrho,1);
                        %fluctval.(['d',char(v),'rdtheta']) = fluctval.(['d',char(v),'rdtheta']) + sum(ddfdtheta,1);
                        %fluctval.(['d',char(v),'rdphi']) = fluctval.(['d',char(v),'rdphi']) + sum(ddfdphi,1);
                        %

                        %
                    elseif strcmp(char(field_name(i)),'B_fit')
                        dfx = zeros(nkperp,length(theta));
                        ddfxdrho = zeros(nkperp,length(theta));
                        ddfxdtheta = zeros(nkperp,length(theta));
                        dfxdphi = zeros(nkperp,length(theta));
                        %
                        dfy = zeros(nkperp,length(theta));
                        ddfydrho = zeros(nkperp,length(theta));
                        ddfydtheta = zeros(nkperp,length(theta));
                        dfydphi = zeros(nkperp,length(theta));
                        %
                        dfz = zeros(nkperp,length(theta));
                        ddfzdrho = zeros(nkperp,length(theta));
                        ddfzdtheta = zeros(nkperp,length(theta));
                        dfzdphi = zeros(nkperp,length(theta));
                        %
                        %for ikperp = 1:nkperp,
                            %
                        %    phase = gphase*kperp(ikperp) + phaseinit(ikperp);
                         %   dphasedrho = dgphasedrho.*kperp(ikperp);
                        %    dphasedtheta = dgphasedtheta.*kperp(ikperp);
                        %    dphasedphi = dgphasedphi.*kperp(ikperp);
                            %
                        %    dfx(ikperp,:) = w_fit{1}.*cos(phase).*sqrt(2.*dkperp./w_fit{4}).*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25);
                            %
                         %   ddfxdrho(ikperp,:) = dwdrho_fit{1}.*cos(phase).*sqrt(2.*dkperp./w_fit{4}).*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25)...
                          %                      - w_fit{1}.*dphasedrho.*sin(phase).*sqrt(2.*dkperp./w_fit{4}).*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25)...
                         %                       - 0.5*w_fit{1}.*cos(phase).*dwdrho_fit{2}.*sqrt(2.*dkperp./w_fit{4})./w_fit{4}.*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25)...
                         %                       + w_fit{1}.*cos(phase).*sqrt(2.*dkperp./w_fit{4}).*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25).*(dwdrho_fit{3}.*w_fit{4} + (kperp(ikperp) - w_fit{5}).*dwdrho_fit{2}).*(kperp(ikperp) - w_fit{5})./w_fit{4}.^3./2;
                            %
                         %   ddfxdtheta(ikperp,:) = dwdtheta_fit{1}.*cos(phase).*sqrt(2.*dkperp./w_fit{4}).*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25)...
                          %                      - w_fit{1}.*dphasedtheta.*sin(phase).*sqrt(2.*dkperp./w_fit{4}).*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25)...
                          %                      - 0.5*w_fit{1}.*cos(phase).*dwdtheta_fit{2}.*sqrt(2.*dkperp./w_fit{4})./w_fit{4}.*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25)...
                           %                     + w_fit{1}.*cos(phase).*sqrt(2.*dkperp./w_fit{4}).*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25).*(dwdtheta_fit{3}.*w_fit{4} + (kperp(ikperp) - w_fit{5}).*dwdtheta_fit{2}).*(kperp(ikperp) - w_fit{5})./w_fit{4}.^3./2;
                            %
                          %  ddfxdphi(ikperp,:) = -w_fit{1}.*dphasedphi.*sin(phase).*sqrt(2.*dkperp./w_fit{4}).*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25);                                                      
                            %
                          %  dfy(ikperp,:) = w_fit{2}.*cos(phase).*sqrt(2.*dkperp./w_fit{4}).*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25);
                            %
                          %  ddfydrho(ikperp,:) = dwdrho_fit{1}.*cos(phase).*sqrt(2.*dkperp./w_fit{4}).*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25)...
                           %                     - w_fit{2}.*dphasedrho.*sin(phase).*sqrt(2.*dkperp./w_fit{4}).*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25)...
                          %                      - 0.5*w_fit{2}.*cos(phase).*dwdrho_fit{2}.*sqrt(2.*dkperp./w_fit{4})./w_fit{4}.*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25)...
                           %                     + w_fit{2}.*cos(phase).*sqrt(2.*dkperp./w_fit{4}).*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25).*(dwdrho_fit{3}.*w_fit{4} + (kperp(ikperp) - w_fit{5}).*dwdrho_fit{2}).*(kperp(ikperp) - w_fit{5})./w_fit{4}.^3./2;
                            %
                           % ddfydtheta(ikperp,:) = dwdtheta_fit{1}.*cos(phase).*sqrt(2.*dkperp./w_fit{4}).*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25)...
                           %                     - w_fit{2}.*dphasedtheta.*sin(phase).*sqrt(2.*dkperp./w_fit{4}).*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25)...
                           %                     - 0.5*w_fit{2}.*cos(phase).*dwdtheta_fit{2}.*sqrt(2.*dkperp./w_fit{4})./w_fit{4}.*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25)...
                           %                     + w_fit{2}.*cos(phase).*sqrt(2.*dkperp./w_fit{4}).*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25).*(dwdtheta_fit{3}.*w_fit{4} + (kperp(ikperp) - w_fit{5}).*dwdtheta_fit{2}).*(kperp(ikperp) - w_fit{5})./w_fit{4}.^3./2;
                            %
                           % ddfydphi(ikperp,:) = -w_fit{2}.*dphasedphi.*sin(phase).*sqrt(2.*dkperp./w_fit{4}).*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25);                                                      
                            %
                            %
                           % dfz(ikperp,:) = w_fit{3}.*cos(phase).*sqrt(2.*dkperp./w_fit{4}).*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25);
                            %
                           % ddfzdrho(ikperp,:) = dwdrho_fit{1}.*cos(phase).*sqrt(2.*dkperp./w_fit{4}).*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25)...
                           %                     - w_fit{3}.*dphasedrho.*sin(phase).*sqrt(2.*dkperp./w_fit{4}).*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25)...
                           %                     - 0.5*w_fit{3}.*cos(phase).*dwdrho_fit{2}.*sqrt(2.*dkperp./w_fit{4})./w_fit{4}.*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25)...
                           %                     + w_fit{3}.*cos(phase).*sqrt(2.*dkperp./w_fit{4}).*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25).*(dwdrho_fit{3}.*w_fit{4} + (kperp(ikperp) - w_fit{5}).*dwdrho_fit{2}).*(kperp(ikperp) - w_fit{5})./w_fit{4}.^3./2;
                            %
                           % ddfzdtheta(ikperp,:) = dwdtheta_fit{1}.*cos(phase).*sqrt(2.*dkperp./w_fit{4}).*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25)...
                           %                     - w_fit{3}.*dphasedtheta.*sin(phase).*sqrt(2.*dkperp./w_fit{4}).*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25)...
                           %                     - 0.5*w_fit{3}.*cos(phase).*dwdtheta_fit{2}.*sqrt(2.*dkperp./w_fit{4})./w_fit{4}.*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25)...
                           %                     + w_fit{3}.*cos(phase).*sqrt(2.*dkperp./w_fit{4}).*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25).*(dwdtheta_fit{3}.*w_fit{4} + (kperp(ikperp) - w_fit{5}).*dwdtheta_fit{2}).*(kperp(ikperp) - w_fit{5})./w_fit{4}.^3./2;
                            %
                           % ddfzdphi(ikperp,:) = -w_fit{3}.*dphasedphi.*sin(phase).*sqrt(2.*dkperp./w_fit{4}).*exp(-(kperp(ikperp) - w_fit{5}).^2./w_fit{4}./w_fit{4}./4)/(2*pi)^(0.25);                                                      
                            %                            
                        %end
                        %
                        %fluctval.([char(v),'xr']) = fluctval.([char(v),'xr']) + sum(dfx,1);
                        %fluctval.(['d',char(v),'xrdrho']) = fluctval.(['d',char(v),'xrdrho']) + sum(ddfxdrho,1);
                        %fluctval.(['d',char(v),'xrdtheta']) = fluctval.(['d',char(v),'xrdtheta']) + sum(ddfxdtheta,1);
                        %fluctval.(['d',char(v),'xrdphi']) = fluctval.(['d',char(v),'xrdphi']) + sum(ddfxdphi,1);
                        %
                        %fluctval.([char(v),'yr']) = fluctval.([char(v),'yr']) + sum(dfy,1);
                        %fluctval.(['d',char(v),'yrdrho']) = fluctval.(['d',char(v),'yrdrho']) + sum(ddfydrho,1);
                        %fluctval.(['d',char(v),'yrdtheta']) = fluctval.(['d',char(v),'yrdtheta']) + sum(ddfydtheta,1);
                        %fluctval.(['d',char(v),'yrdphi']) = fluctval.(['d',char(v),'yrdphi']) + sum(ddfydphi,1);
                        %
                        %fluctval.([char(v),'zr']) = fluctval.([char(v),'zr']) + sum(dfz,1);
                        %fluctval.(['d',char(v),'zrdrho']) = fluctval.(['d',char(v),'zrdrho']) + sum(ddfzdrho,1);
                        %fluctval.(['d',char(v),'zrdtheta']) = fluctval.(['d',char(v),'zrdtheta']) + sum(ddfzdtheta,1);
                        %fluctval.(['d',char(v),'zrdphi']) = fluctval.(['d',char(v),'zrdphi']) + sum(ddfzdphi,1);
                        %
                        fluctval.([char(v),'xr']) = fluctval.([char(v),'xr']) + sum(dfx,1);
                        fluctval.(['d',char(v),'xrdrho']) = fluctval.(['d',char(v),'xrdrho']) + sum(ddfxdrho,1);
                        fluctval.(['d',char(v),'xrdtheta']) = fluctval.(['d',char(v),'xrdtheta']) + sum(ddfxdtheta,1);
                        fluctval.(['d',char(v),'xrdphi']) = fluctval.(['d',char(v),'xrdphi']) + sum(ddfxdphi,1);
                        %
                        fluctval.([char(v),'yr']) = fluctval.([char(v),'yr']) + sum(dfy,1);
                        fluctval.(['d',char(v),'yrdrho']) = fluctval.(['d',char(v),'yrdrho']) + sum(ddfydrho,1);
                        fluctval.(['d',char(v),'yrdtheta']) = fluctval.(['d',char(v),'yrdtheta']) + sum(ddfydtheta,1);
                        fluctval.(['d',char(v),'yrdphi']) = fluctval.(['d',char(v),'yrdphi']) + sum(ddfydphi,1);
                        %
                        fluctval.([char(v),'zr']) = fluctval.([char(v),'zr']) + sum(dfz,1);
                        fluctval.(['d',char(v),'zrdrho']) = fluctval.(['d',char(v),'zrdrho']) + sum(ddfzdrho,1);
                        fluctval.(['d',char(v),'zrdtheta']) = fluctval.(['d',char(v),'zrdtheta']) + sum(ddfzdtheta,1);
                        fluctval.(['d',char(v),'zrdphi']) = fluctval.(['d',char(v),'zrdphi']) + sum(ddfzdphi,1);
                        %
                    end
                elseif fluct_fit.(char(field_name(i)))(ifield).model == 0,%Magnetic ripple model
                    
                    % Magnetic field 
                                	
                    dfx = zeros(1,length(theta));
                    ddfxdrho = zeros(1,length(theta));
                    ddfxdtheta = zeros(1,length(theta));
                    dfxdphi = zeros(1,length(theta));
                    %
                    dfy = zeros(1,length(theta));
                    ddfydrho = zeros(1,length(theta));
                    ddfydtheta = zeros(1,length(theta));
                    dfydphi = zeros(1,length(theta));
                    %
                    dfz = zeros(1,length(theta));
                    ddfzdrho = zeros(1,length(theta));
                    ddfzdtheta = zeros(1,length(theta));
                    dfzdphi = zeros(1,length(theta));
                    %
                    dfx(1) = w_fit{1}.*sin(nmin*phi);
                    ddfxdrho(1) = dwdrho_fit{1}.*sin(nmin*phi);                  
                    ddfxdtheta(1) = dwdtheta_fit{1}.*sin(nmin*phi);                  
                    ddfxdphi(1) = w_fit{1}.*cos(nmin*phi).*nmin; 
                    %
                    dfy(1) = w_fit{2}.*sin(nmin*phi);
                    ddfydrho(1) = dwdrho_fit{2}.*sin(nmin*phi);                  
                    ddfydtheta(1) = dwdtheta_fit{2}.*sin(nmin*phi);                  
                    ddfydphi(1) = w_fit{2}.*cos(nmin*phi).*nmin; 
                    %
                    dfz(1) = w_fit{3}.*cos(nmin*phi);
                    ddfzdrho(1) = dwdrho_fit{3}.*cos(nmin*phi);                  
                    ddfzdtheta(1) = dwdtheta_fit{3}.*cos(nmin*phi);                  
                    ddfzdphi(1) = -w_fit{3}.*sin(nmin*phi).*nmin; 
                    %
                    fluctval.([char(v),'xr']) = fluctval.([char(v),'xr']) + dfx;
                    fluctval.(['d',char(v),'xrdrho']) = fluctval.(['d',char(v),'xrdrho']) + ddfxdrho;
                    fluctval.(['d',char(v),'xrdtheta']) = fluctval.(['d',char(v),'xrdtheta']) + ddfxdtheta;
                    fluctval.(['d',char(v),'xrdphi']) = fluctval.(['d',char(v),'xrdphi']) + ddfxdphi;
                    %
                    fluctval.([char(v),'yr']) = fluctval.([char(v),'yr']) + dfy;
                    fluctval.(['d',char(v),'yrdrho']) = fluctval.(['d',char(v),'yrdrho']) + ddfydrho;
                    fluctval.(['d',char(v),'yrdtheta']) = fluctval.(['d',char(v),'yrdtheta']) + ddfydtheta;
                    fluctval.(['d',char(v),'yrdphi']) = fluctval.(['d',char(v),'yrdphi']) + ddfydphi;
                    %
                    fluctval.([char(v),'zr']) = fluctval.([char(v),'zr']) + dfz;
                    fluctval.(['d',char(v),'zrdrho']) = fluctval.(['d',char(v),'zrdrho']) + ddfzdrho;
                    fluctval.(['d',char(v),'zrdtheta']) = fluctval.(['d',char(v),'zrdtheta']) + ddfzdtheta;
                    fluctval.(['d',char(v),'zrdphi']) = fluctval.(['d',char(v),'zrdphi']) + ddfzdphi;
                    %
                    % Calculations for density, temperature modulations by magnetic ripple
                    %
                    cta = cos(theta)*calpha + sin(theta)*salpha;%for (Bx,By) -> (Brho,Bs) calculations
                    sta = -cos(theta)*salpha + sin(theta)*calpha;%for (Bx,By) -> (Brho,Bs) calculations
                    %
                    dctadrho = cos(theta)*dcalphadrho + sin(theta)*dsalphadrho;
                    dctadtheta = -sta + cos(theta)*dcalphadtheta + sin(theta)*dsalphadtheta;
                    %
                    dstadrho = -cos(theta)*dsalphadrho + sin(theta)*dcalphadrho;
                    dstadtheta = cta - cos(theta)*dsalphadtheta + sin(theta)*dcalphadtheta;
                    %
                    Brho0 = B*(cta*w_fit{1} + sta*w_fit{2});
                    dBrho0drho = dBdrho*(cta*w_fit{1} + sta*w_fit{2}) + B*(dctadrho*w_fit{1} + cta*dwdrho_fit{1} + dstadrho*w_fit{2} + sta*dwdrho_fit{2});
                    dBrho0dtheta = dBdtheta*(cta*w_fit{1} + sta*w_fit{2}) + B*(dctadtheta*w_fit{1} + cta*dwdtheta_fit{1} + dstadtheta*w_fit{2} + sta*dwdtheta_fit{2});
                    %
                    lambda = Brho0*gradrho*equil_fit.Rp/BPHI/nmin;
                    dlambdadrho = (dBrho0drho*gradrho + Brho0*dgradrhodrho - Brho0*gradrho*dBPHIdrho/BPHI)*equil_fit.Rp/BPHI/nmin;
                    dlambdadtheta = (dBrho0dtheta*gradrho + Brho0*dgradrhodtheta - Brho0*gradrho*dBPHIdtheta/BPHI)*equil_fit.Rp/BPHI/nmin;
                    %
                    rho_rip = rho + lambda*cos(nmin*phi); 
                    drhodrho_rip = 1 + dlambdadrho*cos(nmin*phi); 
                    drhodtheta_rip = dlambdadtheta*cos(nmin*phi);
                    drhodphi_rip = -nmin*lambda*sin(nmin*phi);
                    %
                    % Electron density
                    %
                    ne_sep = ppval_yp(equil_fit.ne_fit.pp_f,1);%value at the separatrix
                    dnedrho_sep = ppval_yp(equil_fit.ne_fit.pp_dfdrho,1);
                    %
                    if dnedrho_sep == 0,
                        rho_neeq0 = Inf;
                    else 
                        rho_neeq0 = - ne_sep/dnedrho_sep + 1;
                    end
                    %
                    if rho_rip <= 1,
                        ne_rip = ppval_yp(equil_fit.ne_fit.pp_f,rho_rip);%new value of the electron density that accounts for the flux surface modulation inside the separatrix
                        dnedrho_rip = ppval_yp(equil_fit.ne_fit.pp_dfdrho,rho_rip)*drhodrho_rip;
                        dnedtheta_rip = ppval_yp(equil_fit.ne_fit.pp_dfdrho,rho_rip)*drhodtheta_rip;
                        dnedphi_rip = ppval_yp(equil_fit.ne_fit.pp_dfdrho,rho_rip)*drhodphi_rip;
                    elseif (rho_rip > 1) & (rho_rip <= rho_neeq0),
                        ne_rip = ne_sep + dnedrho_sep*(rho_rip - 1);%SOL
                        dnedrho_rip = dnedrho_sep*drhodrho_rip;
                        dnedtheta_rip = dnedrho_sep*drhodtheta_rip;
                        dnedphi_rip = dnedrho_sep*drhodphi_rip;
                    else
                        ne_rip = 0;%vacuum
                        dnedrho_rip = 0;
                        dnedtheta_rip = 0;
                        dnedphi_rip = 0;
                    end
                    %
                    ne_tilde = ne_rip - ne;
                    dnedrho_tilde = dnedrho_rip - dnedrho;
                    dnedtheta_tilde = dnedtheta_rip;
                    dnedphi_tilde = dnedphi_rip;
                    %
                    ner_tilde = ne_tilde/ne;
                    dnerdrho_tilde = dnedrho_tilde/ne - ne_tilde*dnedrho/ne/ne;
                    dnerdtheta_tilde = dnedtheta_tilde/ne;
                    dnerdphi_tilde = dnedphi_tilde/ne;
                    %
                    fluctval.ner = fluctval.ner + ner_tilde;
                    fluctval.dnerdrho = fluctval.dnerdrho + dnerdrho_tilde;
                    fluctval.dnerdtheta = fluctval.dnerdtheta + dnerdtheta_tilde;
                    fluctval.dnerdphi = fluctval.dnerdphi + dnerdphi_tilde;
                    %
                    % Electron temperature
                    %
                    Te_sep = ppval_yp(equil_fit.Te_fit.pp_f,1);%value at the separatrix
                    dTedrho_sep = ppval_yp(equil_fit.Te_fit.pp_dfdrho,1);
                    %
                    if dTedrho_sep == 0,
                        rho_Teeq0 = Inf;
                    else 
                        rho_Teeq0 = - Te_sep/dTedrho_sep + 1;
                    end
                    %
                    if rho_rip <= 1,
                        Te_rip = ppval_yp(equil_fit.Te_fit.pp_f,rho_rip);%new value of the electron temperature that accounts for the flux surface modulation inside the separatrix
                        dTedrho_rip = ppval_yp(equil_fit.Te_fit.pp_dfdrho,rho_rip)*drhodrho_rip;
                        dTedtheta_rip = ppval_yp(equil_fit.Te_fit.pp_dfdrho,rho_rip)*drhodtheta_rip;
                        dTedphi_rip = ppval_yp(equil_fit.Te_fit.pp_dfdrho,rho_rip)*drhodphi_rip;
                    elseif (rho_rip > 1) & (rho_rip <= rho_Teeq0),
                        Te_rip = Te_sep + dTedrho_sep*(rho_rip - 1);%SOL
                        dTedrho_rip = dTedrho_sep*drhodrho_rip;
                        dTedtheta_rip = dTedrho_sep*drhodtheta_rip;
                        dTedphi_rip = dTedrho_sep*drhodphi_rip;
                    else
                        Te_rip = 0;%vacuum
                        dTedrho_rip = 0;
                        dTedtheta_rip = 0;
                        dTedphi_rip = 0;
                    end
                    %
                    Te_tilde = Te_rip - Te;
                    dTedrho_tilde = dTedrho_rip - dTedrho;
                    dTedtheta_tilde = dTedtheta_rip;
                    dTedphi_tilde = dTedphi_rip;
                    %
                    Ter_tilde = Te_tilde/Te;
                    dTerdrho_tilde = dTedrho_tilde/Te - Te_tilde*dTedrho/Te/Te;
                    dTerdtheta_tilde = dTedtheta_tilde/Te;
                    dTerdphi_tilde = dTedphi_tilde/Te;
                    %
                    fluctval.Ter = fluctval.Ter + Ter_tilde;
                    fluctval.dTerdrho = fluctval.dTerdrho + dTerdrho_tilde;
                    fluctval.dTerdtheta = fluctval.dTerdtheta + dTerdtheta_tilde;
                    fluctval.dTerdphi = fluctval.dTerdphi + dTerdphi_tilde;
                    %                    
                    % ion densities
                    %
                    zni_sep = ppval_yp(equil_fit.zni_fit.pp_f,1);%value at the separatrix
                    dznidrho_sep = ppval_yp(equil_fit.zni_fit.pp_dfdrho,1);
                    %
                    for ii = 1:length(equil_fit.zZi),
                        if dznidrho_sep(ii) == 0,
                            rho_znieq0(ii) = Inf;
                        else 
                            rho_znieq0(ii) = - zni_sep(ii)/dznidrho_sep(ii) + 1;
                        end
                    end
                    %
                    if rho_rip <= 1,
                        zni_rip = ppval_yp(equil_fit.zni_fit.pp_f,rho_rip);%new values of the ion densities that accounts for the flux surface modulation inside the separatrix
                        dznidrho_rip = ppval_yp(equil_fit.zni_fit.pp_dfdrho,rho_rip)*drhodrho_rip;
                        dznidtheta_rip = ppval_yp(equil_fit.zni_fit.pp_dfdrho,rho_rip)*drhodtheta_rip;
                        dznidphi_rip = ppval_yp(equil_fit.zni_fit.pp_dfdrho,rho_rip)*drhodphi_rip;
                    end
                    %
                    for ii = 1:length(equil_fit.zZi),    
                        if (rho_rip > 1) & (rho_rip <= rho_znieq0(ii)),
                            zni_rip(ii) = zni_sep(ii) + dznidrho_sep(ii)*(rho_rip - 1);%SOL
                            dznidrho_rip(ii) = dznidrho_sep(ii)*drhodrho_rip;
                            dznidtheta_rip(ii) = dznidrho_sep(ii)*drhodtheta_rip;
                            dznidphi_rip(ii) = dznidrho_sep(ii)*drhodphi_rip;
                        elseif (rho_rip > rho_znieq0(ii)),
                            zni_rip(ii) = 0;%vacuum
                            dznidrho_rip(ii) = 0;
                            dznidtheta_rip(ii) = 0;
                            dznidphi_rip(ii) = 0;
                        end
                    end
                    %
                    zni_tilde = zni_rip - zni;
                    dznidrho_tilde = dznidrho_rip - dznidrho;
                    dznidtheta_tilde = dznidtheta_rip;
                    dznidphi_tilde = dznidphi_rip;
                    %
                    znir_tilde = zni_tilde./zni;
                    dznirdrho_tilde = dznidrho_tilde./zni - zni_tilde.*dznidrho./zni./zni;
                    dznirdtheta_tilde = dznidtheta_tilde./zni;
                    dznirdphi_tilde = dznidphi_tilde./zni;
                    %
                    znir_tilde(isnan(znir_tilde)) = 0;
                    dznirdrho_tilde(isnan(dznirdrho_tilde)) = 0;
                    dznirdtheta_tilde(isnan(dznirdtheta_tilde)) = 0;
                    dznirdphi_tilde(isnan(dznirdphi_tilde)) = 0;
                    %
                    fluctval.znir = fluctval.znir + znir_tilde';
                    fluctval.dznirdrho = fluctval.dznirdrho + dznirdrho_tilde';
                    fluctval.dznirdtheta = fluctval.dznirdtheta + dznirdtheta_tilde';
                    fluctval.dznirdphi = fluctval.dznirdphi + dznirdphi_tilde';
                    %                    
                    % ion temperatures
                    %
                    zTi_sep = ppval_yp(equil_fit.zTi_fit.pp_f,1);%value at the separatrix
                    dzTidrho_sep = ppval_yp(equil_fit.zTi_fit.pp_dfdrho,1);
                    %
                    for ii = 1:length(equil_fit.zZi),
                        if dzTidrho_sep(ii) == 0,
                            rho_zTieq0(ii) = Inf;
                        else 
                            rho_zTieq0(ii) = - zTi_sep(ii)/dzTidrho_sep(ii) + 1;
                        end
                    end
                    %
                    if rho_rip <= 1,
                        zTi_rip = ppval_yp(equil_fit.zTi_fit.pp_f,rho_rip);%new values of the ion temperatures that accounts for the flux surface modulation inside the separatrix
                        dzTidrho_rip = ppval_yp(equil_fit.zTi_fit.pp_dfdrho,rho_rip)*drhodrho_rip;
                        dzTidtheta_rip = ppval_yp(equil_fit.zTi_fit.pp_dfdrho,rho_rip)*drhodtheta_rip;
                        dzTidphi_rip = ppval_yp(equil_fit.zTi_fit.pp_dfdrho,rho_rip)*drhodphi_rip;
                    end
                    %
                    for ii = 1:length(equil_fit.zZi),    
                        if (rho_rip > 1) & (rho_rip <= rho_zTieq0(ii)),
                            zTi_rip(ii) = zTi_sep(ii) + dzTidrho_sep(ii)*(rho_rip - 1);%SOL
                            dzTidrho_rip(ii) = dzTidrho_sep(ii)*drhodrho_rip;
                            dzTidtheta_rip(ii) = dzTidrho_sep(ii)*drhodtheta_rip;
                            dzTidphi_rip(ii) = dzTidrho_sep(ii)*drhodphi_rip;
                        elseif (rho_rip > rho_zTieq0(ii)),
                            zTi_rip(ii) = 0;%vacuum
                            dzTidrho_rip(ii) = 0;
                            dzTidtheta_rip(ii) = 0;
                            dzTidphi_rip(ii) = 0;
                        end
                    end
                    %
                    zTi_tilde = zTi_rip - zTi;
                    dzTidrho_tilde = dzTidrho_rip - dzTidrho;
                    dzTidtheta_tilde = dzTidtheta_rip;
                    dzTidphi_tilde = dzTidphi_rip;
                    %
                    zTir_tilde = zTi_tilde./zTi;
                    dzTirdrho_tilde = dzTidrho_tilde./zTi - zTi_tilde.*dzTidrho./zTi./zTi;
                    dzTirdtheta_tilde = dzTidtheta_tilde./zTi;
                    dzTirdphi_tilde = dzTidphi_tilde./zTi;
                    %
                    zTir_tilde(isnan(zTir_tilde)) = 0;
                    dzTirdrho_tilde(isnan(dzTirdrho_tilde)) = 0;
                    dzTirdtheta_tilde(isnan(dzTirdtheta_tilde)) = 0;
                    dzTirdphi_tilde(isnan(dzTirdphi_tilde)) = 0;
                    %
                    fluctval.zTir = fluctval.zTir + zTir_tilde';
                    fluctval.dzTirdrho = fluctval.dzTirdrho + dzTirdrho_tilde';
                    fluctval.dzTirdtheta = fluctval.dzTirdtheta + dzTirdtheta_tilde';
                    fluctval.dzTirdphi = fluctval.dzTirdphi + dzTirdphi_tilde';
                end
            end
        end
    end
end
%


