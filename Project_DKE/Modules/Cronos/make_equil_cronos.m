function equil = make_equil_cronos(equil_id,equi,gene,prof,compo,impur)
%
% This function creates the equil structure used by LUKE from various
% cronos structures.
%
% by Joan Decker (joan.decker@cea.fr) and Yves Peysson (yves.peysson@cea.fr)
method = 'spline';
%
% protection pour des flux non monotones 
% convention : equi.psiRZ(end) - equi.psiRZ(1) < 0
%
rhon_RZ = double(equi.rhoRZ/equi.rhoRZ(end));
dpsi_RZ = diff(double(equi.psiRZ));
%
dpsi_RZ_min = max(dpsi_RZ(dpsi_RZ < 0));
%
dpsi_RZ(dpsi_RZ > 0) = dpsi_RZ_min;
%
psiRZ = cumsum([0,dpsi_RZ]);
%
equil.id = equil_id;%gene.k is the time slice
%
if any(imag(equi.R(:)) ~= 0) || any(imag(equi.Z(:)) ~= 0),
	disp('WARNING : imaginary data from Helena equilibrium, discarded in LUKE');
end
%
equil.Rp = double(real(equi.R(1,1,1)));
equil.Zp = double(real(equi.Z(1,1,1)));
equil.ptx = squeeze(double(real(equi.R))) - equil.Rp;
equil.pty = squeeze(double(real(equi.Z))) - equil.Zp;
equil.ap = equil.ptx(end,1);
equil.psi_apRp = -psiRZ*equil.ap/equil.Rp;%Match already the defintion of ppsi in DKE (psi(helena)/2/pi))
equil.theta = linspace(0,2*pi,size(equi.R,3));
equil.ptBx = squeeze(double(equi.BR));
equil.ptBy = squeeze(double(equi.BZ));
equil.ptBPHI = squeeze(double(equi.BPHI));
%
equil.ptBPHI = -gene.signe.b0*equil.ptBPHI;%Bphi is counter-clockwise in TS (WARNING: in rtluke, Ip > 0 and Bphi > 0 when clockwise from the top view of the tokamak, opposite from CRONOS def)
equil.ptBx = -gene.signe.ip*equil.ptBx;%Ip is counter-clockwise in TS
equil.ptBy = -gene.signe.ip*equil.ptBy;%Ip is counter-clockwise in TS
equil.psi_apRp = -gene.signe.ip*equil.psi_apRp;%Ip is counter-clockwise in TS
%
equil.pTe = interp1(gene.x,prof.te/1000,rhon_RZ,method);%en keV
equil.pne = interp1(gene.x,prof.ne,rhon_RZ,method);% m-3
%
zH = find(compo.a == 1);
zD = find(compo.a == 2 & compo.z == 1);
zT = find(compo.a == 3 & compo.z == 1);
zimp = find(compo.z > 1);
%
% profil de densite electronique (m-3)
%wavestructs
pzni = zeros((3+length(zimp)),length(prof.ne));
pTi = interp1(gene.x,prof.ti/1000,rhon_RZ,method);
pzTi = ones((3+length(zimp)),1)*pTi;%All impurities have the same ion temperature
if ~isempty(zH),
    pzni(1,:) = interp1(gene.x,squeeze(impur.impur(1,:,zH)),rhon_RZ,method);
end
if ~isempty(zD),
    pzni(2,:) = interp1(gene.x,squeeze(impur.impur(1,:,zD)),rhon_RZ,method);
end
if ~isempty(zT),
    pzni(3,:) = interp1(gene.x,squeeze(impur.impur(1,:,zT)),rhon_RZ,method);
end
%
pzni(4:(3+length(zimp)),:) = squeeze(impur.impur(1,:,zimp))';
pzTi(4:(3+length(zimp)),:) = repmat(pTi,length(zimp),1);%en keV
zZi = [1,1,1,compo.z(zimp)];
zmi = [1,2,3,compo.a(zimp)];
%
equil.pzTi = pzTi;
equil.pzni = pzni;
equil.zZi = zZi;
equil.zmi = zmi;
%
if sum(equil.ptBy(:,end)-equil.ptBy(:,1)) ~= 0
    disp('equilibrium warning, By(:,theta=0) ~= By(:,theta=pi)')
    equil.ptBy(:,end) = equil.ptBy(:,1);
end
if sum(equil.ptBx(:,end)-equil.ptBx(:,1)) ~= 0
    disp('equilibrium warning, Bx(:,theta=0) ~= Bx(:,theta=pi)')
    equil.ptBx(:,end) = equil.ptBx(:,1);
end
if sum(equil.ptBPHI(:,end)-equil.ptBPHI(:,1)) ~= 0
    disp('equilibrium warning, Bphi(:,theta=0) ~= Bphi(:,theta=pi)')
    equil.ptBPHI(:,end) = equil.ptBPHI(:,1);
end

