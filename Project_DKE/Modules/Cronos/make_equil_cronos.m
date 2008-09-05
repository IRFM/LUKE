function equil = make_equil_cronos(shot,equi,gene,prof,compo,impur);
%
% This function creates the equil structure used by LUKE from various
% cronos structures.
%
% by Joan Decker (joan.decker@cea.fr) and Yves Peysson (yves.peysson@cea.fr)
%
equil.id = ['CRONOS_',int2str(shot),'_k',int2str(gene.k)];%gene.k is the time slice
equil.Rp = double(equi.R(1,1,1));
equil.Zp = double(equi.Z(1,1,1));
equil.ptx = squeeze(double(equi.R)) - equil.Rp;
equil.pty = squeeze(double(equi.Z)) - equil.Zp;
equil.ap = equil.ptx(end,1);
equil.psi_apRp = (-equi.psiRZ+equi.psiRZ(1))*equil.ap/equil.Rp;%Match already the defintion of ppsi in DKE (psi(helena)/2/pi))
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
equil.pTe = prof.te/1000;%en keV
equil.pne = prof.ne;
%
zH = find(compo.a == 1);
zD = find(compo.a == 2 & compo.z == 1);
zT = find(compo.a == 3 & compo.z == 1);
zimp = find(compo.z > 1);
%
% profil de densite electronique (m-3)
%wavestructs
pzni = zeros((3+length(zimp)),length(prof.ne));
pzTi = ones((3+length(zimp)),1)*prof.ti/1000;%All impurities have the same ion temperature
if ~isempty(zH),pzni(1,:) = squeeze(impur.impur(1,:,zH));end
if ~isempty(zD),pzni(2,:) = squeeze(impur.impur(1,:,zD));end
if ~isempty(zT),pzni(3,:) = squeeze(impur.impur(1,:,zT));end
%
pzni(4:(3+length(zimp)),:) = squeeze(impur.impur(1,:,zimp))';
pzTi(4:(3+length(zimp)),:) = repmat(prof.ti/1000,length(zimp),1);%en keV
zZi = [1,1,1,compo.z(zimp)];
zmi = [1,2,3,compo.a(zimp)];
%
equil.pzTi = pzTi;
equil.pzni = pzni;
equil.zZi = zZi;
equil.zmi = zmi;
