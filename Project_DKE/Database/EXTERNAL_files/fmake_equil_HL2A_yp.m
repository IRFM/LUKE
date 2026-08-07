% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function equil = fmake_equil_HL2A_yp(workdir,shotnum,shotime)
%
if nargin < 3,error('Not enough input arguments in fmake_equil_HL2A_yp.m');end
%
external = load_externaldata_EAST(workdir,shotnum,shotime,'','',0,'');
%
display_mode = 0;
p_opt = -1;
basestr = 'HL2A';
%
equil_id =  [basestr,'_',shotnum,'_',shotime];
dispname = [basestr,' #',shotnum,'; t = ',shotime,' s'];
savename = equil_id;
%
% magnetic equil
%
keyboard
[equil_magnetic,prho1,pspsin1,pspsinT1] = equil_magnetic_EFIT_jd(external.equil.magnetic.eqdsk,display_mode,p_opt,dispname,savename);
%
% profiles
%
Zeff = external.equil.prof.species.Zeff;
prho = external.equil.prof.rho;
pne = external.equil.prof.ne;
pTe = external.equil.prof.Te;
pTi = pTe/external.equil.prof.TeTi;
frac_H = external.equil.prof.species.frac_H;
frac_D = external.equil.prof.species.frac_D;
Zimp = external.equil.prof.species.Zimp;
Aimp = external.equil.prof.species.Aimp;
%
% sign management as most equilibrium codes do not account for these.
%
if strcmp(external.equil.jbdirections.Ip,'clockwise')
    signs.Ip = 1;
else
    signs.Ip = -1;
end
%
if strcmp(external.equil.jbdirections.Bt,'clockwise')
    signs.Bt = 1;
else
    signs.Bt = -1;
end
%
if signs.Ip*equil_magnetic.psi_apRp(end) < 0,
    equil_magnetic.psi_apRp = -equil_magnetic.psi_apRp;
    equil_magnetic.ptBx = -equil_magnetic.ptBx;
    equil_magnetic.ptBy = -equil_magnetic.ptBy;
end
%
if signs.Bt*equil_magnetic.ptBPHI(1,1) < 0,
    equil_magnetic.ptBPHI = -equil_magnetic.ptBPHI;
end
%
save([savename,'.prof'],'prho','pne','pTe','pTi','frac_H','frac_D','Zimp','Aimp','Zeff','-mat');
equil_prof = equil_prof_jd([savename,'.prof'],1.4,prho1,pspsin1,pspsinT1,display_mode,p_opt,dispname,savename,Zeff);
delete([savename,'.prof']);
%
equil = conc_struct_jd(equil_magnetic,equil_prof);
%
equil.id = savename;
%
equil = equilconsistency_yp(equil,'',1);
%
save(['EQUIL_',savename,'.mat'],'equil');





