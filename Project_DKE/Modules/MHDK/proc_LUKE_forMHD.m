function proc_LUKE_forMHD(filestr)
%
filename = ['LUKE_DATA_',filestr,'.mat'];
%
load(filename,'output');
%
[qe,me] = pc_dke_yp;
%
mhd.XF0 = output.dke_out.XXf0;
mhd.XFM = output.dke_out.XXfinit;
%
mhd.equil.Rp = output.equilDKE.Rp;
mhd.equil.ap = output.equilDKE.ap;
mhd.equil.Bt = output.equilDKE.Bax;
mhd.equil.xrho = output.equilDKE.xrho;
mhd.equil.xdV_2piRp_dke = output.equilDKE.xdV_2piRp_dke;
mhd.equil.xBp0 = output.equilDKE.xBp0;
mhd.equil.Bax = output.equilDKE.Bax;
%
mhd.equil.xTe = output.equilDKE.xTe;
mhd.equil.xne = output.equilDKE.xne;
mhd.equil.xzTi = output.equilDKE.xzTi;
mhd.equil.xzni = output.equilDKE.xzni;
mhd.equil.zZi = output.equilDKE.zZi;
%
mhd.equil.pn = output.momentumDKE.pn;
mhd.equil.mhu = output.momentumDKE.mhu;
%
mhd.equil.xq = output.Zbouncecoef.xq*output.equilDKE.ap/output.equilDKE.Rp;
%
mhd.equil.E_ref = output.mksa.Te_ref*1e3*qe/me;
mhd.equil.n_ref = output.mksa.ne_ref;
%
mhdstr = ['MHD_DATA_',filestr,'.mat'];
%
save(mhdstr,'mhd')




