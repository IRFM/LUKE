function [eff] = absx_dke_yp(k,lc,lf,ef,tf,ea,ta,ec,tc,ed,td)
%
%Calculation of the hard X-ray absorption by a set of materials between 10 and 1000 keV
%
%	Input:
%
%		- k: photon energy (keV) [1,m]
%		- lc: distance between the diaphragms 1 and 2 (mm) [1,1]
%		- lf: distance between diaphragm 1 and the vacuum window (mm) [1,1]
%		- ef: thickness of the vacuum window (mm) [m,1]
%		- tf: type of material for the vacuum window (Al ou Be) [m,1]
%		- ea: thickness of the absorber (mm) [m,1]
%		- ta: type of material for the absorber (Al,Fe,Ge,Be ou Pb) [1,1]
%		- ec: thickness of the detector's shield (mm) [1,1]
%		- tc: type of material for the detector's shield (Al ou Be) [1,1]
%		- ed: thickness of the detector (mm) [1,1]
% 		- td: type of material for the detector (BGO,CsI,NaI ou Ge) [1,1] 
%
%	Output: 
%
%		- eff: stopping efficiency [1,m]
%
%by Y.PEYSSON CEA-DRFC 14/06/1991 <peysson@fedv09.cad.cea.fr>
%revised for MatLab 4.1 (19/08/1994) 
%
if nargin < 11,
	infoyp(2,'Wrong number of input arguments for absx_dke_yp');
	return;
end
%
%air...
%
attlinair = attlin_dke_yp(1,k);
transair = exp(-attlinair(1,:)*(lc+lf)*0.1);
%
%vacuum window...
%
if strcmp(tf,'Al')==1,
 	attlinfen = attlin_dke_yp(4,k);
elseif strcmp(tf,'Be')==1,
 	attlinfen = attlin_dke_yp(5,k);
elseif strcmp(tf,'In')==1,
 	attlinfen = attlin_dke_yp(13,k);
elseif strcmp(tf,'**')==1,
 	attlinfen = zeros(size(k));
end
transfen=exp(-attlinfen(1,:)*ef*0.1);
%
%absorber...
%
if (strcmp(ta,'Ge') == 1) | (strcmp(ta,'Ger') == 1),
 	attlinabs = attlin_dke_yp(2,k);
elseif strcmp(ta,'Fe')==1,
 	attlinabs = attlin_dke_yp(3,k);
elseif strcmp(ta,'Al')==1,
 	attlinabs = attlin_dke_yp(4,k);
elseif strcmp(ta,'Be')==1,
	attlinabs = attlin_dke_yp(5,k);
elseif strcmp(ta,'Pb')==1,
 	attlinabs = attlin_dke_yp(6,k);
elseif strcmp(ta,'Cu')==1,
 	attlinabs = attlin_dke_yp(11,k);
elseif strcmp(ta,'Ni')==1,
 	attlinabs = attlin_dke_yp(12,k);
elseif strcmp(ta,'In')==1,
 	attlinabs = attlin_dke_yp(13,k);
elseif strcmp(ta,'**')==1,
 	attlinabs = zeros(size(k));
end
transabs = exp(-attlinabs(1,:)*ea*0.1);
%
%detector's shield...
%
if strcmp(tc,'Al')==1,
 	attlincap = attlin_dke_yp(4,k);
elseif strcmp(tc,'Be')==1,
 	attlincap = attlin_dke_yp(5,k);
elseif strcmp(tc,'**')==1,
 	attlincap = zeros(size(k));
end
transcap = exp(-attlincap(1,:)*ec*0.1);
%
%detector...
%
if (strcmp(td,'Ge') == 1) | (strcmp(td,'Ger') == 1) | (strcmp(td,'Ger ') == 1),
 	attlindec = attlin_dke_yp(2,k);
elseif strcmp(td,'BGO') | (strcmp(td,'BGO ') == 1),
 	attlindec = attlin_dke_yp(7,k);
elseif strcmp(td,'CsI') | (strcmp(td,'CsI ') == 1),
 	attlindec = attlin_dke_yp(8,k);
elseif strcmp(td,'NaI') | (strcmp(td,'NaI ') == 1),
 	attlindec = attlin_dke_yp(9,k);
elseif strcmp(td,'CdTe')==1,
 	attlindec = attlin_dke_yp(14,k);
elseif strcmp(td,'**')==1,
 	attlindec = zeros(size(k));	
end
absdec = 1-exp(-attlindec(1,:)*ed*0.1);
%
eff = transair.*(transfen.*(transabs.*(transcap.*absdec)));

