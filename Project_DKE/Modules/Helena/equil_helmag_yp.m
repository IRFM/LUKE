function [varargout] = equil_helmag_yp(filename)
%
% Read HELENA magnetic equilibrium solver output data for C3PO/LUKE calculations
%
% INPUT:
%   
%   - filename: input filename from modified HELENA code for LUKE/C3PO
%
% OUTPUT:
%
%   - equil: magnetic equilibrium LUKE structure (magnetic part only)
%   - sep: magnetic equilibrium seperatrix (for benchmarking purposes)
%     (optional)
%
% by Y. PEYSSON, CEA-DRFC (yves.peysson@cea.fr) and J. DECKER (joan.decke@cea.fr) 
%
fid = fopen(filename);
str_intro = fscanf(fid,'%s',4);%File header
ias = fscanf(fid,'%e',1);%Number of magnetic flux surfaces
npsi = fscanf(fid,'%e',1);%Number of magnetic flux surfaces
ntheta = fscanf(fid,'%e',1);%Number of poloidal angles
R = fscanf(fid,'%e',[npsi,ntheta]);%Major radius (m)
Z = fscanf(fid,'%e',[npsi,ntheta]);%Minor radius (m)
PSIPOL = fscanf(fid,'%e',[npsi,ntheta]);%Poloidal magnetic flux (T.m2)
BR = fscanf(fid,'%e',[npsi,ntheta]);%Horizontal magnetic field (T)
BZ = fscanf(fid,'%e',[npsi,ntheta]);%Vertical magnetic field (T)
RBPHI = fscanf(fid,'%e',npsi);%R*BPHI where BPHI is the gtoroidal magnetic field
fclose(fid);
%
equil.Rp = R(1,1);
equil.Zp = Z(1,1);
%
if ias,%non up/down symmetric poloidal section
    equil.theta = linspace(0,2*pi,ntheta);
    equil.ptx = R - equil.Rp;
    equil.pty = Z - equil.Zp;
    equil.ptBx = BR;
    equil.ptBy = BZ;
    equil.psi_apRp = PSIPOL(:,1)*equil.ptx(end,1)/equil.Rp;
else,%up/down symmetric poloidal section
    ntheta =  2*ntheta;
    equil.theta = linspace(0,2*pi,ntheta);
    equil.ptx = [R,fliplr(R(:,1:end)),] - equil.Rp;
    equil.pty = [Z,-fliplr(Z(:,1:end))] - equil.Zp;
    equil.ptBx = [BR,-fliplr(BR(:,1:end))];
    equil.ptBy = [BZ,fliplr(BZ(:,1:end))]; 
    equil.psi_apRp = [PSIPOL,fliplr(PSIPOL(:,1:end))]*equil.ptx(end,1)/equil.Rp;      
end 
%
equil.ptBPHI = (RBPHI*ones(1,ntheta))./(equil.ptx + equil.Rp);
%
x_eq = [flipud(equil.ptx(:,round((ntheta-1)/2) + 1));equil.ptx(:,1)];
BPHI_eq = [flipud(equil.ptBPHI(:,round((ntheta-1)/2) + 1));equil.ptBPHI(:,1)];
BP = sqrt(equil.ptBx.^2 + equil.ptBy.^2);
BP_eq = [flipud(BP(:,round((ntheta-1)/2) + 1));BP(:,1)];
B_eq = sqrt(BP_eq.^2 + BPHI_eq.^2);
%
figure(2),graph1D_jd(equil.ptx' + equil.Rp,equil.pty' + equil.Zp,0,0,'','','',NaN,'','','-','non','b',1,20,gca,1,0.6,0.6);hold on,
graph1D_jd(equil.ptx + equil.Rp,equil.pty + equil.Zp,0,0,'R(m)','Z(m)','HELENA magnetic equilibrium',NaN,'','','-','non','r',1,20,gca,1,0.6,0.6);
axis('equal');hold off;grid on
drawnow
%
figure(3),graph1D_jd(x_eq + equil.Rp,BPHI_eq,0,0,'','','',NaN,'','','-','non','r',2,20,gca,1,0.6,0.6);hold on,
graph1D_jd(x_eq + equil.Rp,BP_eq,0,0,'R(m)','Magnetic field (T)','HELENA magnetic equilibrium',NaN,'','','-','non','b',2,20,gca,1,0.6,0.6);
graph1D_jd(x_eq + equil.Rp,B_eq,0,0,'R(m)','Magnetic field (T)','HELENA magnetic equilibrium',NaN,'','','-','non','g',2,20,gca,1,0.6,0.6);
legend('Toroidal','Poloidal','Total');
graph1D_jd(equil.Rp,equil.ptBPHI(1,1),0,0,'R(m)','Magnetic field (T)','HELENA magnetic equilibrium',NaN,'','','none','+','k',2,20,gca,1,0.6,0.6);
hold off;grid on
drawnow
%
if nargout >= 1, varargout{1} = equil;end
if nargout >= 2,% Calculate the separatrix for testing routines between LUKE and HELENA
%
   theta_equil = atan(equil.pty(end,:)./equil.ptx(end,:));
   ntheta = length(theta_equil);
   ii = find(diff(theta_equil)< 0);
   theta_equil(ii(1)+1:ii(2)) = theta_equil(ii(1)+1:ii(2)) + pi;
   theta_equil(ii(2)+1:end) = theta_equil(ii(2)+1:end) + 2*pi;
%
   Zs = equil.pty(1,1);
   Rs = (equil.ptx((ntheta + 1)/2) + equil.ptx(1))/2;
   thetas = atan((equil.pty(end,:) - Zs)./(equil.ptx(end,:) - Rs));
   ii = find(diff(thetas)< 0);
   thetas(ii(1)+1:ii(2)) = thetas(ii(1)+1:ii(2)) + pi;
   thetas(ii(2)+1:end) = thetas(ii(2)+1:end) + 2*pi;
   figure(3),plot([1:ntheta],theta_equil,'r-',[1:ntheta],thetas,'b-')
   figure(4),plot([1:ntheta],gradient(theta_equil),'r-',[1:ntheta],gradient(thetas),'b-')
%
   Ysep = interp1(thetas,equil.pty(end,:),theta_equil);
   Xsep = interp1(thetas,equil.ptx(end,:),theta_equil);
   figure(5),plot(thetas,equil.pty(end,:),'r+',theta_equil,Ysep,'bx');
   figure(6),plot(thetas,equil.ptx(end,:),'r+',theta_equil,Xsep,'bx')
%
   sep = [theta_equil(:),Xsep(:) + equil.Rp,Ysep(:) + equil.Zp];
   save iter20_99sep.txt sep -tabs -ascii
%
   varargout{2} = sep;    
end





