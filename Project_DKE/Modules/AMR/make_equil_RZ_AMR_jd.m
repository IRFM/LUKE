function make_equil_RZ_AMR_jd(equil,extfac)
%
% This function calculates and exports RZ equilibrium compatible with ARM
% code
%
equil_RZ = pt2rz_jd(equil,extfac);
%
id = equil_RZ.id(find(equil_RZ.id == '_',1,'first') + 1:end);
%
psi = equil_RZ.psi_apRp.'*equil_RZ.Rp/equil_RZ.ap;
pTe = equil_RZ.pTe.';
pne = equil_RZ.pne.';
%
R = equil_RZ.x.' + equil_RZ.Rp;
Z = equil_RZ.y.' + equil_RZ.Zp;
xyPsi = equil_RZ.xypsi_apRp.'*equil_RZ.Rp/equil_RZ.ap;
xyF = equil_RZ.xyBPHI.'.*repmat(R.',[length(Z),1]);
%
save(['m_profs_',id,'_Psi.dat'],'psi','-ascii');
save(['m_profs_',id,'_Te.dat'],'pTe','-ascii');
save(['m_profs_',id,'_ne.dat'],'pne','-ascii');
%
save(['m_equil_',id,'_R.dat'],'R','-ascii');
save(['m_equil_',id,'_Z.dat'],'Z','-ascii');
save(['m_equil_',id,'_Psi.dat'],'xyPsi','-ascii');
save(['m_equil_',id,'_F.dat'],'xyF','-ascii');
%
