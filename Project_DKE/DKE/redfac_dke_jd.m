function xyredfac = redfac_dke_jd(waveparam,xyD0_rf_mod,betath_ref,limit_dql);
%
%
Nparmin = -10;
Nparmax = 10;
nz = 1000;
%
tol = 1e-10;
%
[nr,nb] = size(xyD0_rf_mod);
%
xyredfac = ones(nr,nb);
%
for ir = 1:nr,
%
    ydNpar = waveparam(ir,:,8);
    yNpar0 = waveparam(ir,:,7);
    yepolz = waveparam(ir,:,12);
    yD0_rf_mod = xyD0_rf_mod(ir,:);
%
    yalphab = betath_ref*abs(yepolz).^2.*abs(yNpar0).*yD0_rf_mod./ydNpar/sqrt(pi);
    zNpar = linspace(Nparmin,Nparmax,nz);
%
    zyalphab = repmat(yalphab,[nz,1]);
    zyNpar = repmat(zNpar',[1,nb]);
    zydNpar = repmat(ydNpar,[nz,1]);
    zyNpar0 = repmat(yNpar0,[nz,1]);
%
    zyDparparb = zyalphab.*exp(-(zyNpar - zyNpar0).^2./zydNpar.^2);
%
    yredfac = ones(1,nb);
%
    while 1,
    %
        zyredfac = repmat(yredfac,[nz,1]);
        zyDparparb_mod = zyDparparb./zyredfac;
        zDparpar = sum(zyDparparb_mod,2);
        Dmax = max(zDparpar);
        if Dmax - limit_dql < tol,
            break
        end
        izmax = min(find(Dmax == zDparpar));
        Dmaxmax = max(zyDparparb_mod(izmax,:));
        iymax = find(abs(zyDparparb_mod(izmax,:) - Dmaxmax) < tol);
        iymin = find(abs(zyDparparb_mod(izmax,:) - Dmaxmax) >= tol);
        if ~isempty(iymin);
            Dmaxmin = max(zyDparparb_mod(izmax,iymin));
            if sum(zyDparparb_mod(izmax,iymin),2) + Dmaxmin*length(iymax) > limit_dql,
                Dmaxnew = Dmaxmin;
            else
                Dmaxnew = (limit_dql - sum(zyDparparb_mod(izmax,iymin),2))/length(iymax);
            end
        else
            Dmaxnew = limit_dql/nb;
        end
        yredfac(iymax) = yredfac(iymax).*zyDparparb_mod(izmax,iymax)/Dmaxnew;
    end
    xyredfac(ir,:) = yredfac;
end
    















