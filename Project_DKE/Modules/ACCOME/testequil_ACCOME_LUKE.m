close all
filename_equil = dir('EQUIL_*.mat');
load(filename_equil.name);
load test_ACCOME.mat
%
disp('*************************************************************************************************************');
disp('WARNING: for full consistency between ACCOME and LUKE concerning magnetic equilibrium and LH ray propagation,');
disp('         the sign of the poloidal flux, of BR and BZ of ACCOME are changed before being used by LUKE');
disp('*************************************************************************************************************');
%
%psi @ Z=Zp
%
itheta = find(equil.theta==pi);
R_luke = [flipud(equil.ptx(:,itheta));equil.ptx(2:end,1)]+equil.Rp;
figure(1),graph1D_jd(R_luke,-[fliplr(equil.psi_apRp),equil.psi_apRp(2:end)]*equil.Rp/equil.ptx(end,1),0,0,'R','\psi',['COMPASS - ',strrep(equil.id,'_','-'),' (\psi -> -\psi)'],NaN,'','','-','none','r',2);drawnow
%
iZp = min(find(Z>=Zp));iZm = iZp - 1;
xypsifit = xypsi(:,iZm) + (xypsi(:,iZp) - xypsi(:,iZm))*(Zp - Z(iZm))/(Z(iZp) - Z(iZm));%linear interpolation
graph1D_jd(R,xypsifit,0,0,'R','\psi',['COMPASS,',strrep(equil.id,'_','-'),' (\psi -> -\psi)'],NaN,'','','none','.','g',2);drawnow
h = line([min(R_luke),max(R_luke)],[psia,psia]);%Poloidal flux at the separatrix
set(h,'Color','blue','linestyle','--','linewidth',2)  
legend('LUKE','ACCOME');
%
%psi @ R=Rp
%
ipis2 = find(equil.theta == pi/2);
ipis3s2 = find(equil.theta == 3*pi/2);
Z_luke = [flipud(equil.pty(:,ipis3s2));equil.pty(2:end,ipis2)]+equil.Zp;
figure(2),graph1D_jd(Z_luke,-[fliplr(equil.psi_apRp),equil.psi_apRp(2:end)]*equil.Rp/equil.ptx(end,1),0,0,'Z','\psi',['COMPASS - ',strrep(equil.id,'_','-'),' (\psi -> -\psi)'],NaN,'','','-','none','r',2);drawnow
iRp = min(find(R>=Rp));iRm = iRp - 1;
xypsifit = xypsi(iRm,:) + (xypsi(iRp,:) - xypsi(iRm,:))*(Rp - R(iRm))/(R(iRp) - R(iRm));%linear interpolation
graph1D_jd(Z,xypsifit,0,0,'Z','\psi',['COMPASS,',strrep(equil.id,'_','-'),' (\psi -> -\psi)'],NaN,'','','none','.','g',2);drawnow
h = line([min(Z_luke),max(Z_luke)],[psia,psia]);%Poloidal flux at the separatrix
set(h,'Color','blue','linestyle','--','linewidth',2)  
legend('LUKE','ACCOME');
%
%BPHI @ Z=Zp
%
itheta = find(equil.theta==pi);
R_luke = [flipud(equil.ptx(:,itheta));equil.ptx(2:end,1)]+equil.Rp;
figure(3),graph1D_jd(R_luke,[flipud(equil.ptBPHI(:,itheta));equil.ptBPHI(2:end,1)],0,0,'R','B_{\phi}',['COMPASS - ',strrep(equil.id,'_','-'),''],NaN,'','','-','none','r',2);drawnow
%
iZp = min(find(Z>=Zp));iZm = iZp - 1;
xyBPHIfit = xyBPHI(:,iZm) + (xyBPHI(:,iZp) - xyBPHI(:,iZm))*(Zp - Z(iZm))/(Z(iZp) - Z(iZm));%linear interpolation
graph1D_jd(R,xyBPHIfit,0,0,'R','B_{\phi}',['COMPASS,',strrep(equil.id,'_','-'),''],NaN,'','','none','.','g',2);drawnow
legend('LUKE','ACCOME');
%
%BPHI @ R=Rp
%
ipis2 = find(equil.theta == pi/2);
ipis3s2 = find(equil.theta == 3*pi/2);
Z_luke = [flipud(equil.pty(:,ipis3s2));equil.pty(2:end,ipis2)]+equil.Zp;
figure(4),graph1D_jd(Z_luke,[flipud(equil.ptBPHI(:,ipis3s2));equil.ptBPHI(2:end,ipis2)],0,0,'Z','B_{\phi}',['COMPASS - ',strrep(equil.id,'_','-'),''],NaN,'','','-','none','r',2);drawnow
%
iRp = min(find(R>=Rp));iRm = iRp - 1;
xyBPHIfit = xyBPHI(iRm,:) + (xyBPHI(iRp,:) - xyBPHI(iRm,:))*(Rp - R(iRm))/(R(iRp) - R(iRm));%linear interpolation
graph1D_jd(Z,xyBPHIfit,0,0,'Z','B_{\phi}',['COMPASS,',strrep(equil.id,'_','-'),''],NaN,'','','none','.','g',2);drawnow
legend('LUKE','ACCOME');
%
%BR @ Z=Zp
%
itheta = find(equil.theta==pi);
R_luke = [flipud(equil.ptx(:,itheta));equil.ptx(2:end,1)]+equil.Rp;
figure(5),graph1D_jd(R_luke,-[flipud(equil.ptBx(:,itheta));equil.ptBx(2:end,1)],0,0,'R','BR',['COMPASS - ',strrep(equil.id,'_','-'),' (BR -> -BR)'],NaN,'','','-','none','r',2);drawnow
%
[xygradxpsi,xygradypsi] = gradient(xypsi',R(2)-R(1),Z(2)-Z(1));
xyBR1 = -xygradypsi'./(R*ones(1,size(xygradypsi',2)));
iZp = min(find(Z>=Zp));iZm = iZp - 1;
xyBRfit1 = xyBR1(:,iZm) + (xyBR1(:,iZp) - xyBR1(:,iZm))*(Zp - Z(iZm))/(Z(iZp) - Z(iZm));%linear interpolation
graph1D_jd(R,xyBRfit1,0,0,'R','BR',['COMPASS,',strrep(equil.id,'_','-'),' (BR -> -BR)'],NaN,'','','none','x','b',2);drawnow
%
if ~isempty(xyBR) & ~isempty(xyBZ),
	xyBRfit = xyBR(:,iZm) + (xyBR(:,iZp) - xyBR(:,iZm))*(Zp - Z(iZm))/(Z(iZp) - Z(iZm));%linear interpolation
	graph1D_jd(R,xyBRfit,0,0,'R','BR',['COMPASS,',strrep(equil.id,'_','-'),' (BR -> -BR)'],NaN,'','','none','.','g',2);drawnow
	legend('LUKE','ACCOME-PSI-FIT','ACCOME');
else
	legend('LUKE','ACCOME-PSI-FIT');
end
%
%BR @ R=Rp
%
ipis2 = find(equil.theta == pi/2);
ipis3s2 = find(equil.theta == 3*pi/2);
Z_luke = [flipud(equil.pty(:,ipis3s2));equil.pty(2:end,ipis2)]+equil.Zp;
figure(6),graph1D_jd(Z_luke,-[flipud(equil.ptBx(:,ipis3s2));equil.ptBx(2:end,ipis2)],0,0,'Z','BR (BR -> -BR)',['COMPASS - ',strrep(equil.id,'_','-'),''],NaN,'','','-','none','r',2);drawnow
%
iRp = min(find(R>=Rp));iRm = iRp - 1;
[xygradxpsi,xygradypsi] = gradient(xypsi',R(2)-R(1),Z(2)-Z(1));
xyBR1 = -xygradypsi'./(R*ones(1,size(xygradypsi',2)));
xyBRfit1 = xyBR1(iRm,:) + (xyBR1(iRp,:) - xyBR1(iRm,:))*(Rp - R(iRm))/(R(iRp) - R(iRm));%linear interpolation
graph1D_jd(Z,xyBRfit1,0,0,'Z','BR',['COMPASS,',strrep(equil.id,'_','-'),' (BR -> -BR)'],NaN,'','','none','x','b',2);drawnow
%
if ~isempty(xyBR) & ~isempty(xyBZ),
	xyBRfit = xyBR(iRm,:) + (xyBR(iRp,:) - xyBR(iRm,:))*(Rp - R(iRm))/(R(iRp) - R(iRm));%linear interpolation
	graph1D_jd(Z,xyBRfit,0,0,'Z','BR',['COMPASS,',strrep(equil.id,'_','-'),' (BR -> -BR)'],NaN,'','','none','.','g',2);drawnow
	legend('LUKE','ACCOME-PSI-FIT','ACCOME');
else
	legend('LUKE','ACCOME-PSI-FIT');
end
%
%BZ @ Z=Zp
%
itheta = find(equil.theta==pi);
R_luke = [flipud(equil.ptx(:,itheta));equil.ptx(2:end,1)]+equil.Rp;
figure(7),graph1D_jd(R_luke,-[flipud(equil.ptBy(:,itheta));equil.ptBy(2:end,1)],0,0,'R','BZ (BZ -> -BZ)',['COMPASS - ',strrep(equil.id,'_','-'),''],NaN,'','','-','none','r',2);drawnow
%
[xygradxpsi,xygradypsi] = gradient(xypsi',R(2)-R(1),Z(2)-Z(1));
xyBZ1 = xygradxpsi'./(R*ones(1,size(xygradxpsi',2)));
iZp = min(find(Z>=Zp));iZm = iZp - 1;
xyBZfit1 = xyBZ1(:,iZm) + (xyBZ1(:,iZp) - xyBZ1(:,iZm))*(Zp - Z(iZm))/(Z(iZp) - Z(iZm));%linear interpolation
graph1D_jd(R,xyBZfit1,0,0,'R','BZ',['COMPASS,',strrep(equil.id,'_','-'),' (BZ -> -BZ)'],NaN,'','','none','x','b',2);drawnow
%
if ~isempty(xyBR) & ~isempty(xyBZ),
	xyBZfit = xyBZ(:,iZm) + (xyBZ(:,iZp) - xyBZ(:,iZm))*(Zp - Z(iZm))/(Z(iZp) - Z(iZm));%linear interpolation
	graph1D_jd(R,xyBZfit,0,0,'R','BZ',['COMPASS,',strrep(equil.id,'_','-'),' (BZ -> -BZ)'],NaN,'','','none','.','g',2);drawnow
	legend('LUKE','ACCOME-PSI-FIT','ACCOME');
else
	legend('LUKE','ACCOME-PSI-FIT');
end
%
%BZ @ R=Rp
%
ipis2 = find(equil.theta == pi/2);
ipis3s2 = find(equil.theta == 3*pi/2);
Z_luke = [flipud(equil.pty(:,ipis3s2));equil.pty(2:end,ipis2)]+equil.Zp;
figure(8),graph1D_jd(Z_luke,-[flipud(equil.ptBy(:,ipis3s2));equil.ptBy(2:end,ipis2)],0,0,'Z','BZ',['COMPASS - ',strrep(equil.id,'_','-'),' (BZ -> -BZ)'],NaN,'','','-','none','r',2);drawnow
%
iRp = min(find(R>=Rp));iRm = iRp - 1;
[xygradxpsi,xygradypsi] = gradient(xypsi',R(2)-R(1),Z(2)-Z(1));
xyBZ1 = xygradxpsi'./(R*ones(1,size(xygradxpsi',2)));
xyBZfit1 = xyBZ1(iRm,:) + (xyBZ1(iRp,:) - xyBZ1(iRm,:))*(Rp - R(iRm))/(R(iRp) - R(iRm));%linear interpolation
graph1D_jd(Z,xyBZfit1,0,0,'Z','BZ',['COMPASS,',strrep(equil.id,'_','-'),' (BZ -> -BZ)'],NaN,'','','none','x','b',2);drawnow
%
if ~isempty(xyBR) & ~isempty(xyBZ),
	xyBZfit = xyBZ(iRm,:) + (xyBZ(iRp,:) - xyBZ(iRm,:))*(Rp - R(iRm))/(R(iRp) - R(iRm));%linear interpolation
	graph1D_jd(Z,xyBZfit,0,0,'Z','BZ',['COMPASS,',strrep(equil.id,'_','-'),' (BZ -> -BZ)'],NaN,'','','none','.','g',2);drawnow
	legend('LUKE','ACCOME-PSI-FIT','ACCOME');
else
	legend('LUKE','ACCOME-PSI-FIT');
end
