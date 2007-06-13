function [separatrix] = make_helsep_yp(sepparam,helparam)
%
% Calculate the separatrix for magnetic equilibrium calculations
%
% INPUT:
%
%   - sepparam: separatrix parameter structure
%   - helparam: input HELENA parameter structure
%
% OUTPUT:
%
%   - separatrix: separatrix structure
%
% by Y. PEYSSON (CEA/DRFC, yves.peysson@cea.fr) and J. DECKER (CEA/DRFC, joan.decker@cea.fr)
%
if isfield(sepparam,'ellipticity') & sepparam.mode == 1,
    theta_sep  = linspace(0,2*pi,sepparam.ntheta);%poloidal angle (uniform between 0 and 2*pi (for FFT)
    separatrix.R_sep = sepparam.as*cos(theta_sep + sepparam.triangularity*sin(theta_sep) + sepparam.quadrangularity*sin(2*theta_sep)) + sepparam.Rs;
    separatrix.Z_sep = sepparam.as*sepparam.ellipticity*sin(theta_sep) + sepparam.Zs;
elseif isfield(sepparam,'xpoint') & sepparam.mode == 2,
    lim_top = atan(0.5*sepparam.xpoint(1)/(1-sepparam.xpoint(2)))*180/pi;%In order to avoid convergence problem in sepparam MEX file
    if sepparam.xpoint(4) > lim_top,sepparam.xpoint(4) = lim_top - 0.1;end
    lim_bottom = atan(0.5*sepparam.xpoint(5)/(1-sepparam.xpoint(6)))*180/pi;%In order to avoid convergence problem in sepparam MEX file
    if sepparam.xpoint(8) > lim_bottom,sepparam.xpoint(8) = lim_bottom - 0.1;end
%
    [x1,y1] = separatrice(sepparam.xpoint,1);%The LCS is approximated by four ellipses (mode = 1)
%
    rr = x1*sepparam.as;
    zz = y1*sepparam.as;
    alpha  = unwrap(angle(rr + i.*zz));%poloidal angle
    if alpha(end) < -5,
        alpha = alpha - alpha(end);
    end
%
    theta_sep  = linspace(0,2*pi,sepparam.ntheta);% poloidal points
    ind = find(diff(alpha) == 0);
    alpha(ind) = [];
    rr(ind) = [];
    zz(ind) = [];
%    
    separatrix.R_sep = spline(alpha',rr',theta_sep) + sepparam.Rs;%resampling 
    separatrix.Z_sep = spline(alpha',zz',theta_sep) + sepparam.Zs;%resampling 
elseif isfield(sepparam,'filename') & sepparam.mode == 3,
    sep = load(sepparam.filename);
% 
    theta_sep = sep(:,1);
    separatrix.R_sep = sep(:,2);
    separatrix.Z_sep = sep(:,3);
end
%
Zvac = separatrix.Z_sep(1);
Rvac = (separatrix.R_sep((length(separatrix.R_sep) + 1)/2)+separatrix.R_sep(1))/2;
x = separatrix.R_sep - Rvac;
y = separatrix.Z_sep - Zvac;
r = sqrt(x.^2 + y.^2);
%
ixp = find(x >= 0);
i1 = find(diff(ixp)>1);
i2 = ixp(i1+1);
i3 = find(y == min(y));
i4 = find(y == max(y));
%
separatrix.Rvac = Rvac;
separatrix.Zvac = Zvac;
separatrix.as = r(1);
separatrix.bs = (y(i4) - y(i3))/2;
separatrix.cs = x(i2) - x(i3);
separatrix.ds = x(i1) - x(i3);
%
% Geometrical definitions of elongation and triangularity as defined in
% Wesson's book 'Tokamaks' p.741, 3rd Ed.
%
separatrix.elongation = separatrix.bs/separatrix.as;
separatrix.triangularity = (separatrix.cs + separatrix.ds)/separatrix.as/2;
%
figure(1),graph1D_jd(separatrix.R_sep,separatrix.Z_sep,0,0,'','','',NaN,[min(separatrix.R_sep)*0.9,max(separatrix.R_sep)*1.1],[min(separatrix.Z_sep)*1.1,max(separatrix.Z_sep)*1.1],'-','non','r',2,20,gca,1,0.6,0.6);hold on
graph1D_jd([Rvac,Rvac],[min(separatrix.Z_sep)*1.1,max(separatrix.Z_sep)*1.1],0,0,'','','',NaN,[min(separatrix.R_sep)*0.9,max(separatrix.R_sep)*1.1],[min(separatrix.Z_sep)*1.1,max(separatrix.Z_sep)*1.1],'-.','none','b',1,20,gca,1,0.6,0.6);
graph1D_jd([min(separatrix.R_sep)*0.9,max(separatrix.R_sep)*1.1],[Zvac,Zvac],0,0,'R(m)','Z(m)','Input separatrix for HELENA',NaN,[min(separatrix.R_sep)*0.9,max(separatrix.R_sep)*1.1],[min(separatrix.Z_sep)*1.1,max(separatrix.Z_sep)*1.1],'-.','none','b',1,20,gca,1,0.6,0.6);
axis('equal');grid on
drawnow
%
% Calculation of the Fourier series of r(theta)
%
rr = r/r(1);%Minor radius = 1 @ theta = 0 and theta = pi
fftrr = fft(rr(1:end-1));%on the monotonic part only
separatrix.fm = zeros(length(fftrr),1);
separatrix.fm(1) = 2*real(fftrr(1))/length(fftrr);
separatrix.fm(2) = -imag(fftrr(1))/length(fftrr);
for ii= 2:length(fftrr),
    separatrix.fm(2*ii-1) = real(fftrr(ii))/length(fftrr); 
    separatrix.fm(2*ii) = -imag(fftrr(ii))/length(fftrr);    
end
%
separatrix.theta = theta_sep;
separatrix.r = rr;
