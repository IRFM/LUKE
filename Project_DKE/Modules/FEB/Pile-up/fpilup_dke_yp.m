function [ki,ko,kADC,kkADC,emp,kcode,khisto,khisto1,histoki,histoko,histokADC,histokcode] = fpilupyp(diag,nreset,Ni0,k0min,k0,ech,typspec,pur)
%
%	Study of of pile-up and dead-time for x-ray spectrometry at high counting rate
%	Global study based on Poisson statistics. Monte-Carlo simulation.
%
%	Input: 
%
%		- diag: diagnostic structure (string) [1,m]
%       - nreset: random number generator reset number
%		- Ni0: number of pulses [1,1]
%		  (default = 10000)
%		- kmin0: lower limit of the photon energy spectrum (keV) [1,1]
%		  (default = kmin (see the listing)
%		- k0: photon reference energy (keV) [1,1]
%		  (default = 70)
%		- ech: scaling factor to reduce Monte-Carlo calculation time [1,1]
%		  (default = 10)
%		- typespec: (1) line spectrum, (2) exponential spectrum [1,1]
%		  (default = 2)
%		- pur: (1) pile-up rejector on, or (0) off [1,1]
%		  (default = 1)
%
%	Output: 
%
%		- ki:
%		- ko:
%		- kADC:
%		- kkADC:
%		- emp:
%		- kcode:
%		- khisto: energy range (keV) [1,nenergy]
%		- khisto1: energy range (keV) [1,nenergy]
%		- histoki: input spectrum (plasma one) [1,nenergy]
%		- histoko: output spectrum (without ADC dead time) [1,nenergy]
%		- histokADC: output spectrum (with ADC dead time) [1,nenergy]
%		- histokcode: output spectrum (with or without pur) [1,nenergy]
%
%
%by Y.PEYSSON CEA-DRFC <yves.peysson@cea.fr>
%
%	Diagnostics parameters
%
tok = diag.tok;
namediag = diag.namediag;
theta = diag.theta;
tc0 = diag.tc0;
tpeak = diag.tpeak; 
tl0 = diag.tl0;
tp0 = diag.tp0;
beta = diag.beta;
kmin = diag.kmin;
kmin0 = diag.kmin0;
kmax = diag.kmax;
nhisto = diag.nhisto;
%
tp = tp0*theta*ech;
tl = tl0*theta*ech;
tc = tc0*ech;
tpeak = tpeak*ech;
Ni = Ni0/ech;
%
alpha = beta*tp/(tl-tp);
%
%	Energy spectrum
%
khisto = linspace(kmin,kmax,nhisto+1);
dk = khisto(2) - khisto(1);
khisto1 = linspace(kmin+dk/2,kmax-dk/2,nhisto);
%
if typspec==1,
 	ki = k0*ones(Ni,1);
    [histoki,dummy] = hist_dke_yp(ki,khisto);
    krefi = ki;
elseif typspec==2,
 	ki = kmin0-k0*log(rand(Ni,1));
 	[histoki,dummy] = hist_dke_yp(ki,khisto);
 	pfit = polyfit(khisto1,log(histoki),1);
 	krefi = -1/pfit(1);afiti = exp(pfit(2));
end
%
%	Temporal spectrum
%
tk = sort(rand(Ni,1))*1000000;
%
ko = ki;emp = zeros(size(ki));
for i = Ni:-1:1,
   for k = 1:i-1,
      if tk(i) - tk(i-k) < tl+tp,
         if tk(i) - tk(i-k) < tl - tp,
            a = ki(i-k)/((tp^(alpha+beta))*((beta/alpha)^beta));
      		t = tp+tk(i)-tk(i-k);
      		ko(i) = ko(i)+a*(t.^alpha).*((tl-t).^beta);
			if tk(i) - tk(i-k) < tp,
			   a = ki(i)/((tp^(alpha+beta))*((beta/alpha)^beta));
      		   t = tp-tk(i)+tk(i-k);
      		   ko(i-k) = ko(i-k)+a*(t.^alpha).*((tl-t).^beta);
			   if tk(i) - tk(i-k) < tpeak,
			      emp(i) = 2;
				  emp(i-k) = 1;
               else
				  emp(i) = 1;
				  emp(i-k) = 1;
               end
            else
		       emp(i) = 1;
			end
		else
			emp(i) = 1;
        end
      else
		 break;
      end
   end
end
%
[histoko,dummy] = hist_dke_yp(ko,khisto);%	Piled-up spectrum
%
kADC = ko;
if strcmp(tok,'JET'),%JET case only
   i = 1;
   while i <= Ni,
      tt = [];kk = [];
	  tt(1) = tk(i);
	  kk(1) = ki(i);
	  for j = i+1:Ni,
	     if tk(j) - tk(j-1) < tl,
		    tt(j-i+1) = tk(j);
		    kk(j-i+1) = ki(j);
         else
			 break;
         end
      end
	  npl = length(kk)-1;
	  kADC(i:1:i+npl) = jpilupyp(tt,kk,tl,tp,tc,kmin,kmax,nhisto,ko,i);
	  i = i + npl +1;
   end
else %Tore Supra case or other tokamaks
   i = 1;
   while i <= Ni,
      for j = i+1:Ni,
         if tk(j)-tk(i)<=tc+tp,
       	    kADC(j) = -1;
         else
       		 break;
         end
      end
      i = j+1;
   end
end
%
kkADC = kADC(kADC~=-1);
zz = kADC(find(kADC(:)>0));
[histokADC,dummy] = hist_dke_yp(zz,khisto); %Piled-up + dead time spectrum
%
if pur==0,%Pile-up rejection off
   kcode = kkADC;
   zz = kcode(find(kcode(:)>0));
   [histokcode,dummy] = hist_dke_yp(zz,khisto); % Measured spectrum
elseif pur==1,%Pile-up rejection on
   kcode = kADC((kADC~=-1) & (emp~=1));% Measured spectrum
   zz = kcode(find(kcode(:)>0));
   [histokcode,dummy] = hist_dke_yp(zz,khisto); 
end






