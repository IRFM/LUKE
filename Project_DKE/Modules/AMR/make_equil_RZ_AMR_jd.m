function make_equil_RZ_AMR_jd(equil,savepath,nprz,extfacR,extfacZ)
%
% This function calculates and exports RZ equilibrium compatible with AMR
% code
%
[np,nt] = size(equil.ptx);
%
if nargin < 5,
	extfacZ = 0;
end
%
if nargin < 4,
	extfacR = 0;
end
%
if nargin < 3,
	nprz = '';
end
%
if nargin < 2,
	savepath = [pwd,'/',];
end
%
method = 'cubic';
%
equil_RZ = pt2rz_jd(equil,extfacR,extfacZ,nprz,method);
%
id = equil_RZ.id(find(equil_RZ.id == '_',1,'first') + 1:end);
%
ptR = equil.ptx + equil_RZ.Rp;
R = ptR(:,1);
pTe = equil.pTe.';
pne = equil.pne.';
pZeff = sum(equil.pzni.*repmat(equil.zZi.',[1,length(pne)]).^2,1)./pne;
%
Psi = equil.psi_apRp.'*equil_RZ.Rp/equil_RZ.ap;
F =  - equil.ptBPHI(:,1).*R;
%
xyR = equil_RZ.x.' + equil_RZ.Rp;
xyZ = equil_RZ.y.' + equil_RZ.Zp;
xyPsi = equil_RZ.xypsi_apRp.'*equil_RZ.Rp/equil_RZ.ap;

values = [equil_RZ.Rp;equil_RZ.Zp;Psi(end);ptR(end,(nt+1)/2);ptR(end,1)];
%
save([savepath,'m_profs_',id,'_R.dat'],'R','-ascii');
save([savepath,'m_profs_',id,'_Te.dat'],'pTe','-ascii');
save([savepath,'m_profs_',id,'_ne.dat'],'pne','-ascii');
save([savepath,'m_profs_',id,'_Zeff.dat'],'pZeff','-ascii');
%
save([savepath,'m_equil_',id,'_R.dat'],'xyR','-ascii');
save([savepath,'m_equil_',id,'_Z.dat'],'xyZ','-ascii');
save([savepath,'m_equil_',id,'_PsiRZ.dat'],'xyPsi','-ascii');
save([savepath,'m_equil_',id,'_PsiF.dat'],'Psi','-ascii');
save([savepath,'m_equil_',id,'_F.dat'],'F','-ascii');
%
save([savepath,'m_equil_',id,'_values.dat'],'values','-ascii');
%
