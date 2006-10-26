function [att] = attlin_dke_yp(mat,k)
%
%	Calculation of the lineic attenuation of hard X-rays between 10 and 1100 keV
%	Data are calculated using parameters given in reference
%	McMaster et al. compilation of x-ray cross sections
%  	UCRL-50174,sect.II,rev. 1(1969).
%	
%	Input:
%
%		- mat: type of material [1,1]
%			1: Air
%			2: Germanium
%			3: Iron
%			4: Aluminium
%			5: Beryllium
%			6: Lead
%			7: BGO
%			8: CsI
%			9: NaI
%			10: Carbon
%			11: Copper
%			12: Nickel
%			13: Inconel
%			14: CdTe
%		- k: photon energy (keV) [4,m]
%			(total,photoelectric,rayleigh,compton)
%
%	Output: 
%
%		- att: lineic attenuation (cm-1) [1,m]
%
%by Y.PEYSSON CEA-DRFC <yves.peysson@cea.fr>
%
if nargin < 2,
	info_dke_yp(2,'Wrong number of input arguments for attlin_dke_yp');
	return;
end
if length(find(k>1100 | k<10))~=0,
	info_dke_yp(2,'Warning: some energy values are outside of the range of validity !');
end
%
sk = size(k);
mhup = 0.0*ones(size(k));mhuc=0.0*ones(size(k));mhur=0.0*ones(size(k));
if mat==1,
%
%Air...
%
 	para1 = [1.293e-3,1.25e-3,1.43e-3,1.78e-3];%dens,densazote,densoxy,densargon
 	para2 = [0.7804,0.2102,0.0094];%pazote,poxy,pargon
%
%nitrogen...
%
 	para = [1.25e-3,14.0,6.023e+23,1.0e-24];%dens,pa,avo,barn
 	p = [11.2765,-2.65400,-0.200445,0.0200765];%ap0 -> ap3 (photoelectric)
	c = [-1.23693,1.74510,-0.354660,0.0198705];%ac0 -> ac3 (compton)
 	r = [3.47760,-0.215762,-0.288874,0.0151312];%ar0 -> ar3 (rayleigh)
 	for i=1:sk(2),
  		if (k(i) >= 3.20) & (k(i) <= 1100.0),
   			mhup(i) = exp(p(1)+p(2)*log(k(i))+p(3)*log(k(i)).^2+p(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		end
 	end
 	mhu0 = para(1)*para(3)*para(4)/para(2);
 	mhuph = mhu0*mhup;mhuco = mhu0*mhuc;mhura = mhu0*mhur;
 	mhutot = mhuco+mhuph+mhura;attazote = [mhutot;mhuph;mhura;mhuco];
%
%oxygen...
%
 	para = [1.43e-3,16.00,6.023e+23,1.0e-24];%dens,pa,avo,barn
 	p = [11.7130,-2.57229,-0.205893,0.0199244];%ap0 -> ap3 (photoelectric)
 	c = [-1.73679,2.17686,-0.449050,0.0264733];%ac0 -> ac3 (compton)
 	r = [3.77239,-0.148539,-0.307124,0.0167303];%ar0 -> ar3 (rayleigh)
 	for i=1:sk(2),
  		if (k(i) >= 7.11) & (k(i) <= 1100.0),
   			mhup(i) = exp(p(1)+p(2)*log(k(i))+p(3)*log(k(i)).^2+p(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		end
 	end
 	mhu0 = para(1)*para(3)*para(4)/para(2);
 	mhuph = mhu0*mhup;mhuco = mhu0*mhuc;mhura = mhu0*mhur;
 	mhutot = mhuco+mhuph+mhura;attoxy = [mhutot;mhuph;mhura;mhuco];
%
%argon...
%
 	para = [1.78e-3,39.95,6.023e+23,1.0e-24];%dens,pa,avo,barn
 	p = [13.9491,-1.82276,-0.328827,0.0274382];%ap0 -> ap3 (photoelectric)
 	c = [-0.682105,1.74279,-0.317646,0.0156467];%ac0 -> ac3 (compton)
 	r = [5.21079,0.135618,-0.347214,0.0184333];%ar0 -> ar3 (rayleigh)
 	for i=1:sk(2),
  		if (k(i) >= 3.20) & (k(i) <= 1100.0),
   			mhup(i) = exp(p(1)+p(2)*log(k(i))+p(3)*log(k(i)).^2+p(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		end
 	end
 	mhu0 = para(1)*para(3)*para(4)/para(2);
 	mhuph = mhu0*mhup;mhuco = mhu0*mhuc;mhura = mhu0*mhur;
 	mhutot = mhuco+mhuph+mhura;attargon = [mhutot;mhuph;mhura;mhuco];
%
 	att = attazote*para2(1)*para1(2)/para1(1);
 	att = att+attoxy*para2(2)*para1(3)/para1(1);
 	att = att+attargon*para2(3)*para1(4)/para1(1);
elseif mat==2,
%
%Germanium...
%
 	para = [5.32,72.6,6.023e+23,1.0e-24];%dens,pa,avo,barn
 	p1 = [14.6813,-2.59285,-0.0208355,0.0];%ap10 -> ap13 (photoelectric)
 	p2 = [13.9288,-0.479613,-0.572897,0.0431277];%ap20 -> ap23 (photoelectric)
 	c = [ -0.334383,1.60237,-0.245555,0.00871239];%ac0 -> ac3 (compton)
 	r = [6.33896,0.291512,-0.365643,0.0192896];%ar0 -> ar3 (rayleigh)
 	for i=1:sk(2),
  		if (k(i) < 11.10),
   			mhup(i) = exp(p1(1)+p1(2)*log(k(i))+p1(3)*log(k(i)).^2+p1(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		elseif (k(i) >= 11.10) & (k(i) <=1100),
   			mhup(i) = exp(p2(1)+p2(2)*log(k(i))+p2(3)*log(k(i)).^2+p2(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		end
 	end
 	mhu0 = para(1)*para(3)*para(4)/para(2);
 	mhuph = mhu0*mhup;mhuco = mhu0*mhuc;mhura = mhu0*mhur;
 	mhutot = mhuco+mhuph+mhura;att = [mhutot;mhuph;mhura;mhuco];
elseif mat==3,
%
%Iron...
%
 	para = [7.86,55.85,6.023e+23,1.0e-24];%dens,pa,avo,barn
 	p = [14.3456,-1.23491,-0.418785,0.0321662];%ap0 -> ap3 (photoelectric)
 	c = [-0.342379,1.57245,-0.253198,0.00985822];%ac0 -> ac3 (compton)
 	r = [5.93292,0.225038,-0.361748,0.0193024];%ar0 -> ar3 (rayleigh)
 	for i=1:sk(2),
  		if (k(i) >= 7.11) & (k(i) <=1100),
   			mhup(i) = exp(p(1)+p(2)*log(k(i))+p(3)*log(k(i)).^2+p(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		end
 	end
 	mhu0 = para(1)*para(3)*para(4)/para(2);
 	mhuph = mhu0*mhup;mhuco = mhu0*mhuc;mhura = mhu0*mhur;
 	mhutot = mhuco+mhuph+mhura;att = [mhutot;mhuph;mhura;mhuco];
elseif mat==4,
%
%Aluminium...
%
 	para = [2.70,26.97,6.023e+23,1.0e-24];%dens,pa,avo,barn
 	p = [13.1738,-2.18203,-0.258960,0.022284];%ap0 -> ap3 (photoelectric)
 	c = [-0.439322,1.30867,-0.211648,0.00754210];%ac0 -> ac3 (compton)
 	r = [4.51995,0.140549,-0.352441,0.0193692];%ar0 -> ar3 (rayleigh)
 	for i=1:sk(2),
  		if (k(i) >= 1.56) & (k(i) <=1100),
   			mhup(i) = exp(p(1)+p(2)*log(k(i))+p(3)*log(k(i)).^2+p(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		end
 	end
 	mhu0 = para(1)*para(3)*para(4)/para(2);
 	mhuph = mhu0*mhup;mhuco = mhu0*mhuc;mhura = mhu0*mhur;
 	mhutot = mhuco+mhuph+mhura;att = [mhutot;mhuph;mhura;mhuco];
elseif mat==5,
%
%Beryllium...
%
 	para  =[1.85,9.01,6.023e+23,1.0e-24];%dens,pa,avo,barn
 	p = [9.04511,-2.83487,-0.210021,0.0229526];%ap0 -> ap3 (photoelectric)
 	c = [-0.690079,0.946448,-0.171142,0.00651413];%ac0 -> ac3 (compton)
 	r = [2.00860,-0.046192,-0.337018,0.0186939];%ar0 -> ar3 (rayleigh)
 	for i=1:sk(2),
  		if (k(i) >= 0.11) & (k(i) <=1100),
   			mhup(i) = exp(p(1)+p(2)*log(k(i))+p(3)*log(k(i)).^2+p(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		end
 	end
 	mhu0 = para(1)*para(3)*para(4)/para(2);
 	mhuph = mhu0*mhup;mhuco = mhu0*mhuc;mhura = mhu0*mhur;
 	mhutot = mhuco+mhuph+mhura;att = [mhutot;mhuph;mhura;mhuco];
elseif mat==6,
%
%Lead...
%
 	para = [11.35,207.21,6.023e+23,1.0e-24];%dens,pa,avo,barn
 	p1 = [16.7131,-2.61538,0.0,0.0];%ap10 -> ap13 (photoelectric)
 	p2 = [17.7963,-2.37691,-0.045883,0.0];%ap20 -> ap23 (photoelectric)
 	p3 = [8.63374,3.69400,-1.21312,0.0774601];%ap30 -> ap33 (photoelectric)
 	c = [0.182167,1.54661,-0.195793,0.00390772];%ac0 -> ac3 (compton)
 	r = [8.15996,0.418031,-0.352330,0.0164660];%ar0 -> ar3 (rayleigh)
 	for i=1:sk(2),
 		if (k(i) >= 3.85) & (k(i) < 15.86),
   			mhup(i) = exp(p1(1)+p1(2)*log(k(i))+p1(3)*log(k(i)).^2+p1(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		elseif (k(i) >= 15.86) & (k(i) < 88.00),
   			mhup(i) = exp(p2(1)+p2(2)*log(k(i))+p2(3)*log(k(i)).^2+p2(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		elseif (k(i) >= 88.00) & (k(i) <= 1100.00),
   			mhup(i) = exp(p3(1)+p3(2)*log(k(i))+p3(3)*log(k(i)).^2+p3(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		end
 	end
 	mhu0 = para(1)*para(3)*para(4)/para(2);
 	mhuph = mhu0*mhup;mhuco = mhu0*mhuc;mhura = mhu0*mhur;
 	mhutot = mhuco+mhuph+mhura;att = [mhutot;mhuph;mhura;mhuco];
elseif mat==7,
%
%BGO (Bi4Ge3O12)...
%
 	para1 = [7.13,9.8,5.32,1.43e-3];%dens,densbismu,densgerma,densoxy
 	para2 = [0.671,0.175,0.154];%pbismu,pgerma,poxy
%
%Bismuth...
%
 	para = [9.8,209.00,6.023e+23,1.0e-24];%dens,pa,avo,barn
 	p1 = [16.7078,-2.58648,0.0,0.0];%ap10 -> ap13 (photoelectric)
 	p2 = [17.5348,-2.23353,-0.0596161,0.0];%ap20 -> ap23 (photoelectric)
 	p3 = [9.44293,3.44965,-1.19886,0.0783484];%ap30 -> ap33 (photoelectric)
 	c = [0.189860,1.56125,-0.200932,0.00436768];%ac0 -> ac3 (compton)
 	r = [8.17489,0.427916,-0.355068,0.0166601];%ar0 -> ar3 (rayleigh)
 	for i=1:sk(2),
  		if (k(i) < 16.39),
   			mhup(i) = exp(p1(1)+p1(2)*log(k(i))+p1(3)*log(k(i)).^2+p1(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		elseif (k(i) >= 16.39) & (k(i) < 90.53),
   			mhup(i) = exp(p2(1)+p2(2)*log(k(i))+p2(3)*log(k(i)).^2+p2(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		elseif (k(i) >= 11.10) & (k(i) <=1100),
   			mhup(i) = exp(p3(1)+p3(2)*log(k(i))+p3(3)*log(k(i)).^2+p3(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		end
 	end
 	mhu0 = para(1)*para(3)*para(4)/para(2);
 	mhuph = mhu0*mhup;mhuco = mhu0*mhuc;mhura = mhu0*mhur;
 	mhutot = mhuco+mhuph+mhura;attbismu = [mhutot;mhuph;mhura;mhuco];
%
%Germanium...
%
 	para = [5.32,72.6,6.023e+23,1.0e-24];%dens,pa,avo,barn
 	p1 = [14.6813,-2.59285,-0.0208355,0.0];%ap10 -> ap13 (photoelectric)
 	p2 = [13.9288,-0.479613,-0.572897,0.0431277];%ap20 -> ap23 (photoelectric)
 	c = [ -0.334383,1.60237,-0.245555,0.00871239];%ac0 -> ac3 (compton)
 	r = [6.33896,0.291512,-0.365643,0.0192896];%ar0 -> ar3 (rayleigh)
 	for i=1:sk(2),
  		if (k(i) < 11.10),
   			mhup(i) = exp(p1(1)+p1(2)*log(k(i))+p1(3)*log(k(i)).^2+p1(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		elseif (k(i) >= 11.10) & (k(i) <=1100),
   			mhup(i) = exp(p2(1)+p2(2)*log(k(i))+p2(3)*log(k(i)).^2+p2(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		end
 	end
 	mhu0 = para(1)*para(3)*para(4)/para(2);
 	mhuph = mhu0*mhup;mhuco  =mhu0*mhuc;mhura = mhu0*mhur;
 	mhutot = mhuco+mhuph+mhura;attgerma = [mhutot;mhuph;mhura;mhuco];
%
%Oxygen...
%
 	para = [1.43e-3,16.00,6.023e+23,1.0e-24];%dens,pa,avo,barn
 	p = [11.7130,-2.57229,-0.205893,0.0199244];%ap0 -> ap3 (photoelectric)
 	c = [-1.73679,2.17686,-0.449050,0.0264733];%ac0 -> ac3 (compton)
 	r = [3.77239,-0.148539,-0.307124,0.0167303];%ar0 -> ar3 (rayleigh)
 	for i=1:sk(2),
  		if (k(i) >= 7.11) & (k(i) <= 1100.0),
   			mhup(i) = exp(p(1)+p(2)*log(k(i))+p(3)*log(k(i)).^2+p(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		end
 	end
 	mhu0 = para(1)*para(3)*para(4)/para(2);
 	mhuph = mhu0*mhup;mhuco = mhu0*mhuc;mhura = mhu0*mhur;
 	mhutot = mhuco+mhuph+mhura;attoxy = [mhutot;mhuph;mhura;mhuco];
%
 	att = attbismu*para2(1)*para1(1)/para1(2);
 	att = att+attgerma*para2(2)*para1(1)/para1(3);
 	att = att+attoxy*para2(3)*para1(1)/para1(4);
elseif mat==8,
%
%CsI...
%
 	para1 = [4.51,1.873,4.94];%dens,densCs,densI
 	para2 = [0.5115,0.4885];%pCs,pI
%
%Cesium...
%
 	para = [1.873,132.91,6.023e+23,1.0e-24];%dens,pa,avo,barn
 	p1 = [16.5418,-2.46363,-0.0542849,0.0];%ap10 -> ap13 (photoelectric)
 	p2 = [11.3757,1.94161,-0.983232,0.0671986];%ap20 -> ap23 (photoelectric)
 	c = [0.184861,1.50030,-0.213333,0.00624264];%ac0 -> ac3 (compton)
 	r = [7.33490,0.376825,-0.365713,0.0181843];%ar0 -> ar3 (rayleigh)
 	for i=1:sk(2),
  		if (k(i) < 35.985),
   			mhup(i) = exp(p1(1)+p1(2)*log(k(i))+p1(3)*log(k(i)).^2+p1(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		elseif (k(i) >= 35.985) & (k(i) <=1100),
   			mhup(i) = exp(p2(1)+p2(2)*log(k(i))+p2(3)*log(k(i)).^2+p2(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		end
 	end
 	mhu0 = para(1)*para(3)*para(4)/para(2);
 	mhuph = mhu0*mhup;mhuco = mhu0*mhuc;mhura = mhu0*mhur;
 	mhutot = mhuco+mhuph+mhura;attCs = [mhutot;mhuph;mhura;mhuco];
%
%Iode...
%
 	para = [4.94,126.91,6.023e+23,1.0e-24];%dens,pa,avo,barn
 	p1 = [16.4086,-2.48214,-0.0507179,0.0];%ap10 -> ap13 (photoelectric)
 	p2 = [12.1075,1.43635,-0.882038,0.0603575];%ap20 -> ap23 (photoelectric)
 	c = [-0.0404420,1.65596,-0.251067,0.00904874];%ac0 -> ac3 (compton)
 	r = [7.27415,0.377223,-0.369728,0.0186280];%ar0 -> ar3 (rayleigh)
 	for i=1:sk(2),
  		if (k(i) < 33.169),
   			mhup(i) = exp(p1(1)+p1(2)*log(k(i))+p1(3)*log(k(i)).^2+p1(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		elseif (k(i) >= 33.169) & (k(i) <=1100),
   			mhup(i) = exp(p2(1)+p2(2)*log(k(i))+p2(3)*log(k(i)).^2+p2(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		end
 	end
 	mhu0 = para(1)*para(3)*para(4)/para(2);
 	mhuph = mhu0*mhup;mhuco = mhu0*mhuc;mhura = mhu0*mhur;
 	mhutot = mhuco+mhuph+mhura;attIo = [mhutot;mhuph;mhura;mhuco];
%
 	att = attCs*para2(1)*para1(1)/para1(2);
 	att = att+attIo*para2(2)*para1(1)/para1(3);
elseif mat==9,
%
%NaI...
%
 	para1 = [3.67,0.97,4.94];%dens,densNa,densIo
 	para2 = [0.1534,0.8466];%pNa,pIo
%
%Sodium (Na)...
%
 	para = [0.97,22.997,6.023e+23,1.0e-24];%dens,pa,avo,barn
 	p = [12.6777,-2.24521,-0.274873,0.02507];%ap10 -> ap13 (photoelectric)
 	c = [-0.967717,1.61794,-0.287191,0.0131526];%ac0 -> ac3 (compton)
 	r = [4.26374,0.134662,-0.370080,0.0214467];%ar0 -> ar3 (rayleigh)
 	for i=1:sk(2),
  		if (k(i) >= 5.198) & (k(i) <=1100),
   			mhup(i) = exp(p(1)+p(2)*log(k(i))+p(3)*log(k(i)).^2+p(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		end
 	end
 	mhu0 = para(1)*para(3)*para(4)/para(2);
 	mhuph = mhu0*mhup;mhuco = mhu0*mhuc;mhura = mhu0*mhur;
 	mhutot = mhuco+mhuph+mhura;attNa = [mhutot;mhuph;mhura;mhuco];
%
%Iode...
%
 	para = [4.94,126.91,6.023e+23,1.0e-24];%dens,pa,avo,barn
 	p1 = [16.4086,-2.48214,-0.0507179,0.0];%ap10 -> ap13 (photoelectric)
 	p2 = [12.1075,1.43635,-0.882038,0.0603575];%ap20 -> ap23 (photoelectric)
 	c = [-0.0404420,1.65596,-0.251067,0.00904874];%ac0 -> ac3 (compton)
 	r = [7.27415,0.377223,-0.369728,0.0186280];%ar0 -> ar3 (rayleigh)
 	for i=1:sk(2),
  		if (k(i) < 33.169),
   			mhup(i) = exp(p1(1)+p1(2)*log(k(i))+p1(3)*log(k(i)).^2+p1(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		elseif (k(i) >= 33.169) & (k(i) <=1100),
   			mhup(i) = exp(p2(1)+p2(2)*log(k(i))+p2(3)*log(k(i)).^2+p2(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		end
 	end
 	mhu0 = para(1)*para(3)*para(4)/para(2);
 	mhuph = mhu0*mhup;mhuco = mhu0*mhuc;mhura = mhu0*mhur;
 	mhutot = mhuco+mhuph+mhura;attIo = [mhutot;mhuph;mhura;mhuco];
%
 	att = attNa*para2(1)*para1(1)/para1(2);
 	att = att+attIo*para2(2)*para1(1)/para1(3);
elseif mat==10,
%
%Carbon...
%
 	para = [1.80,12.01,6.023e+23,1.0e-24];%dens,pa,avo,barn
 	p = [1.06879e+01,-2.714,-2.00530e-01,2.07248e-2];%ap0 -> ap3 (photoelectric)
 	c = [-9.82878e-1,1.46693,-2.93743e-1,1.56005e-2];%ac0 -> ac3 (compton)
 	r = [3.10861,-2.60580e-1,-2.71974e-1,1.35181e-2];%ar0 -> ar3 (rayleigh)
 	for i=1:sk(2),
  		if (k(i) >= 0.284) & (k(i) <=1100),
   			mhup(i) = exp(p(1)+p(2)*log(k(i))+p(3)*log(k(i)).^2+p(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		end
 	end
 	mhu0 = para(1)*para(3)*para(4)/para(2);
 	mhuph = mhu0*mhup;mhuco = mhu0*mhuc;mhura = mhu0*mhur;
 	mhutot = mhuco+mhuph+mhura;att = [mhutot;mhuph;mhura;mhuco];
elseif mat==11,
%
%Copper...
%
 	para = [8.94,63.54,6.023e+23,1.0e-24];%dens,pa,avo,barn
 	p = [14.5808,-1.18375,-0.413850,0.0312088];%ap0 -> ap3 (photoelectric)
 	c = [-0.570210,1.75042,-0.284555,0.0116930];%ac0 -> ac3 (compton)
 	r = [6.17739,0.273123,-0.372360,0.0201638];%ar0 -> ar3 (rayleigh)
 	for i=1:sk(2),
  		if (k(i) >= 8.979) & (k(i) <=1100),
   			mhup(i) = exp(p(1)+p(2)*log(k(i))+p(3)*log(k(i)).^2+p(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		end
 	end
 	mhu0 = para(1)*para(3)*para(4)/para(2);
 	mhuph = mhu0*mhup;mhuco = mhu0*mhuc;mhura = mhu0*mhur;
 	mhutot = mhuco+mhuph+mhura;att = [mhutot;mhuph;mhura;mhuco];
elseif mat==12,
%
%Nickel...
%
 	para = [8.90,58.69,6.023e+23,1.0e-24];%dens,pa,avo,barn
 	p = [14.2388,-0.967736,-0.47807,0.0366138];%ap0 -> ap3 (photoelectric)
 	c = [-0.50436,1.70040,-0.276443,0.0112628];%ac0 -> ac3 (compton)
 	r = [6.09204,0.252277,-0.366568,0.0196586];%ar0 -> ar3 (rayleigh)
 	for i=1:sk(2),
  		if (k(i) >= 8.333) & (k(i) <=1100),
   			mhup(i) = exp(p(1)+p(2)*log(k(i))+p(3)*log(k(i)).^2+p(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		end
 	end
 	mhu0 = para(1)*para(3)*para(4)/para(2);
 	mhuph = mhu0*mhup;mhuco = mhu0*mhuc;mhura = mhu0*mhur;
 	mhutot = mhuco+mhuph+mhura;att = [mhutot;mhuph;mhura;mhuco];
elseif mat==13,
%
%Inconel...
%
	pFe = 0.424;
 	para1 = [7.86*pFe+8.9*(1-pFe),7.86,8.9];%dens,densFe,densNi
 	para2 = [pFe,1-pFe];%pFe,pNi
%
%Iron...
%
 	para = [7.86,55.85,6.023e+23,1.0e-24];%dens,pa,avo,barn
 	p = [14.3456,-1.23491,-0.418785,0.0321662];%ap0 -> ap3 (photoelectric)
 	c = [-0.342379,1.57245,-0.253198,0.00985822];%ac0 -> ac3 (compton)
 	r = [5.93292,0.225038,-0.361748,0.0193024];%ar0 -> ar3 (rayleigh)
 	for i=1:sk(2),
  		if (k(i) >= 7.11) & (k(i) <=1100),
   			mhup(i) = exp(p(1)+p(2)*log(k(i))+p(3)*log(k(i)).^2+p(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		end
 	end
 	mhu0 = para(1)*para(3)*para(4)/para(2);
 	mhuph = mhu0*mhup;mhuco = mhu0*mhuc;mhura = mhu0*mhur;
 	mhutot = mhuco+mhuph+mhura;attFe = [mhutot;mhuph;mhura;mhuco];
%
%Nickel...
%
 	para = [8.90,58.69,6.023e+23,1.0e-24];%dens,pa,avo,barn
 	p = [14.2388,-0.967736,-0.47807,0.0366138];%ap0 -> ap3 (photoelectric)
 	c = [-0.50436,1.70040,-0.276443,0.0112628];%ac0 -> ac3 (compton)
 	r = [6.09204,0.252277,-0.366568,0.0196586];%ar0 -> ar3 (rayleigh)
 	for i=1:sk(2),
  		if (k(i) >= 8.333) & (k(i) <=1100),
   			mhup(i) = exp(p(1)+p(2)*log(k(i))+p(3)*log(k(i)).^2+p(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		end
 	end
 	mhu0 = para(1)*para(3)*para(4)/para(2);
 	mhuph = mhu0*mhup;mhuco = mhu0*mhuc;mhura = mhu0*mhur;
 	mhutot = mhuco+mhuph+mhura;attNi = [mhutot;mhuph;mhura;mhuco];
%
 	att = attFe*para2(1)*para1(1)/para1(2);
 	att = att+attNi*para2(2)*para1(1)/para1(3);	
elseif mat==14,
%
%CdTe...
%
 	para1 = [5.856,8.65,6.24];%dens,densCd,densTe
 	para2 = [0.468,0.532];%pCd,pTe
%
%Cadmium...
%
 	para = [8.65,112.41,6.023e+23,1.0e-24];%dens,pa,avo,barn
 	p1 = [15.9668,-2.38363,-0.0801104,0];%ap10 -> ap13 (photoelectric)
 	p2 = [11.5254,1.07714,-0.831424,0.0579120];%ap20 -> ap23 (photoelectric)
 	c = [-0.0516701,1.57426,-0.227646,0.0070565];%ac0 -> ac3 (compton)
 	r = [7.09856,0.372199,-0.375345,0.0193481];%ar0 -> ar3 (rayleigh)
 	for i=1:sk(2),
  		if (k(i) < 26.711),
   			mhup(i) = exp(p1(1)+p1(2)*log(k(i))+p1(3)*log(k(i)).^2+p1(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		elseif (k(i) >= 26.711) & (k(i) <=1100),
   			mhup(i) = exp(p2(1)+p2(2)*log(k(i))+p2(3)*log(k(i)).^2+p2(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		end
 	end
 	mhu0 = para(1)*para(3)*para(4)/para(2);
 	mhuph = mhu0*mhup;mhuco = mhu0*mhuc;mhura = mhu0*mhur;
 	mhutot = mhuco+mhuph+mhura;attCd = [mhutot;mhuph;mhura;mhuco];
%
%Tellurium...
%
 	para = [6.24,127.6,6.023e+23,1.0e-24];%dens,pa,avo,barn
 	p1 = [16.1087,-2.27876,-0.0929405,0];%ap10 -> ap13 (photoelectric)
 	p2 = [11.6656,1.71052,-0.948281,0.0653213];%ap20 -> ap23 (photoelectric)
 	c = [-0.0407579,1.64267,-0.247897,0.00880567];%ac0 -> ac3 (compton)
 	r = [7.23464,0.382493,-0.372715,0.0189194];%ar0 -> ar3 (rayleigh)
 	for i=1:sk(2),
  		if (k(i) < 31.813),
   			mhup(i) = exp(p1(1)+p1(2)*log(k(i))+p1(3)*log(k(i)).^2+p1(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		elseif (k(i) >= 31.813) & (k(i) <=1100),
   			mhup(i) = exp(p2(1)+p2(2)*log(k(i))+p2(3)*log(k(i)).^2+p2(4)*log(k(i)).^3);
   			mhuc(i) = exp(c(1)+c(2)*log(k(i))+c(3)*log(k(i)).^2+c(4)*log(k(i)).^3);
   			mhur(i) = exp(r(1)+r(2)*log(k(i))+r(3)*log(k(i)).^2+r(4)*log(k(i)).^3);
  		end
 	end
 	mhu0 = para(1)*para(3)*para(4)/para(2);
 	mhuph = mhu0*mhup;mhuco = mhu0*mhuc;mhura = mhu0*mhur;
 	mhutot = mhuco+mhuph+mhura;attTe = [mhutot;mhuph;mhura;mhuco];
%
 	att = attCd*para2(1)*para1(1)/para1(2);
 	att = att+attTe*para2(2)*para1(1)/para1(3);	
	
end

