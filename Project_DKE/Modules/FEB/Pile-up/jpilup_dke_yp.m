function [flag] = jpilup_dke_yp(tt,kk,tl,tp,tc,kmin,kmax,nhisto,ko,i);
%
%	Dead-time and spectrum modification due to JET-FEB ADC coding system
%
%
%	Input:
%
%	Output:
%
%
%by Y.PEYSSON CEA-DRFC <yves.peysson@cea.fr>
%
%
beta = 5;
alpha = beta*tp/(tl-tp);
%
if length(tt) == 1,
	flag = ko(i);
	return;
else
	ttt = tt -min(tt) + tp; 
	flag = zeros(size(ttt))';
	tmin = 0;
	tmax = max(ttt) +tl -tp;
	t = linspace(tmin,tmax,(tmax -tmin)/tc);
	k = zeros(size(t));
	k(1) = 0;
	kdiag = linspace(kmin,kmax,nhisto+1);
 	mask = [];
	for j = 2:length(t),
		for jj = 1:length(ttt),
			if t(j) >= ttt(jj)-tp & t(j) < ttt(jj)+tl-tp,
				a = kk(jj)/((tp^(alpha+beta))*((beta/alpha)^beta));
      				tref = tp+t(j)-ttt(jj);
				k(j) = k(j) + a*(tref.^alpha).*((tl-tref).^beta);
			end
		end
		for jj = 1:nhisto+1,
			if k(j-1) < kdiag(jj) & k(j) >= kdiag(jj),
				mask = [mask;(t(j-1)+t(j))/2,kdiag(jj),1];
			elseif k(j-1) >= kdiag(jj) & k(j) < kdiag(jj),
				mask = [mask;(t(j-1)+t(j))/2,kdiag(jj),-1];
			end
		end
	end
%
	for j = 1:size(mask,1)-1,
		if mask(j,3) + mask(j+1,3) == 0 & mask(j,3) > mask(j+1,3) & mask(j,2) < max(kdiag),
			flag0 = 0;
			for jj = 1:length(ttt),
				if ttt(jj) > mask(j,1) & ttt(jj) <= mask(j+1,1) & flag0 == 0,
					flag(jj) = 1;
					flag0 =1;
				end
			end
		end
	end
%
	flag = flag.* ko(i:1:i+length(tt)-1);
	flag(find(flag == 0)) = -1 + flag(find(flag == 0));
end
