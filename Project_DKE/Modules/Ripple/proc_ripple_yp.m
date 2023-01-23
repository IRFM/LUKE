function ripple = proc_ripple_yp(equil,mksa,output,opt)
%
ripple.opt = opt;
ripple.Zmripple = output.Zmripple;
ripple.equil = equil;
ripple.mksa = mksa;
%
ripple.XXf0 = output.dke_out.XXf0{1};
ripple.psin = output.radialDKE.xpsin_f;
ripple.dpsin = output.radialDKE.xdpsin_f_dke;
ripple.mhu = output.momentumDKE.mhu;
ripple.pn = output.momentumDKE.pn;
ripple.mksa = output.mksa;
%
ripple.pn2dpn = output.momentumDKE.pn(:).*output.momentumDKE.pn(:).*output.momentumDKE.dpn(:);
%
ripple.ntheta = 71;
%
ripple.ripple = bananatip_yp(ripple.ntheta,ripple.psin,ripple.dpsin,ripple.pn,ripple.mhu,ripple.equil,ripple.XXf0,ripple.pn2dpn,ripple.mksa);
%
