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
function proc_LUKE_forMHD(filestr)
%
filename = ['LUKE_DATA_',filestr,'.mat'];
%
if exist(filename,'file'),
    load(filename,'output');
else
    filename = ['LUKE_RESULTS_',filestr,'.mat'];
    output = load(filename,'dke_out','equilDKE','momentumDKE','Zbouncecoef','mksa','dkeparam');
end
%
[qe,me] = pc_dke_yp;
%
if isfield(dke_out,'dkeparam')
	dkeparam = dke_out.dkeparam;
end
%
mhd.luke_simul = output.dke_out.simul;
%
if ~isfield(dke_out,'XXf0'),
    mhd.Xf0 = legendre2f_yp(dkeparam,momentumDKE,dke_out.XXf0_interp);%restore the distribution from its projection on the Legendre polynomial basis
else
    mhd.XF0 = output.dke_out.XXf0;
end
%
if ~isfield(dke_out,'XXfM'),
    mhd.XfM = legendre2f_yp(dkeparam,momentumDKE,dke_out.XXfM_interp);%restore the distribution from its projection on the Legendre polynomial basis
else
    mhd.XFM = output.dke_out.XXfM;
end
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
locstr = input('Enter an optional string to add to the MHD filename (or leave empty) : ','s');
%
if ~isempty(locstr),
    locstr = ['_',locstr];
end
%
mhdstr = ['MHD_DATA_',filestr,locstr,'.mat'];
%
save(mhdstr,'mhd')




