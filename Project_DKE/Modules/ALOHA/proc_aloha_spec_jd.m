function [yN,ydN,yP,zyfac] = proc_aloha_spec_jd(zN,zdN,zdP,zredfac,param,opt_optim,display_mode)
	%
	if nargin < 7,
    	display_mode = 0;
	end
	%
	if nargin < 6,
    	opt_optim = 0;
    end
    %
	if nargin < 5,
    	param = 2+2i;
    end
    %
    if opt_optim == 1 && exist('lsqnonlin') ~= 2,
        opt_optim = 0;
    end
	%
	zdP = zdP(:).'*zredfac;
	zdN = zdN(:).';
	zN = zN(:).';
	%
	if min(zdP) < 0,
	    disp('warning: min(zdP) < 0, correcting')
	    zdP = zdP - min(zdP);
    end
    %
    Pmindisp = 10^(floor(mean(log10(zdP(find(zdP > 0))))) - 2); 
    Pmaxdisp = 10^(ceil(log10(max(zdP))) + 1); 
	%
	global zx zf
	%
	if length(zdN) == 1 && isnan(zdN),
	    zN_S = [zN(1) - (zN(2)-zN(1))/2, (zN(1:end-1) + zN(2:end))/2, zN(end) + (zN(end)-zN(end-1))/2];
	    zdN = diff(zN_S);
	end
	%
	Ptot = sum(zdP.*zdN);
	%
	nz = length(zdP);
	%
	zppdP = [0,zdP,0];
	%
	zptrend = sign(diff(zppdP));
	%
	if any(zptrend == 0),
    error('case of successive points with equal power density not yet treated.')
	end
	%
	zvar = diff(zptrend);
	%
	ilim = [1,find(zvar == 2),nz]; 
%
%
% 
% ilim = 1;
% ipeak = [];
%
% Prefm = zP(1);
% evol = 1;
% %
% for iz = 1:nz,
%     %
%     Rrefp = zP(iz+1);
%     %
%     if (Rrefp - Prefm)*evol < 0,% inversing trend
%         %
%         if evol == 1,% peak is passed
%             %
%             ipeak = [ipeak,iz];
%             %
%         else% low is passed
%             %
%             ilim = [ilim,iz];
%             %
%         end
%         %
%         evol = -evol;
%         %
%     end
%     %
%     Prefm = Prefp;  
%     %
% end
%
% clear Prefm Prefp iz evol
%
	ny = length(ilim) - 1;
	%
	if real(param) == 0,% Peak position and height are maintained, dNpar is adjusted
        if imag(param) < 1,
            Pfacmin = imag(param);
            nlobesmax = ny;
        else
            Pfacmin = 0;
            nlobesmax = imag(param);
        end        
        %
        nlobespro = 0;
        opt_peak = 0;
        %
    else % Peak position and height are varied for non-protected peaks
        if real(param) < 1,
            Pfacmin = real(param);
            nlobesmax = ny;
        else
            Pfacmin = 0;
            nlobesmax = real(param);
        end
        %
        % a number of (main) peaks can be protected (they keep the original N, P and dN)
        %
        % they are not accounted for in nlobesmax (nlobes = nlobesmax + nlobespro). 
        % if Pfacmin is used, the fraction is calculated on the remaining power
        %
        nlobespro = fix(imag(param));
        opt_peak = 1;
        %
    end
	%
	zydP = repmat(zdP.',[1,ny]);
	zydN = repmat(zdN.',[1,ny]);
	zyN = repmat(zN.',[1,ny]);
	%
	zyind = (1:nz).'*ones(1,ny);
	zyilimm = repmat(ilim(1:end-1),[nz,1]);
	zyilimp = repmat(ilim(2:end),[nz,1]);
	%
	zyfac = zeros(nz,ny);
	zyfac(zyind > zyilimm & zyind < zyilimp) = 1;
	zyfac(zyind == zyilimm | zyind == zyilimp) = 1/2;%half power belongs to lobe at separation points
	zyfac(zyind == 1 | zyind == nz) = 2*zyfac(zyind == 1 | zyind == nz);%full power belongs to lobe at end points
	%
	yP = sum(zydP.*zydN.*zyfac);
    %
    if opt_peak == 1,
        %
        yN = sum(zydP.*zydN.*zyfac.*zyN)./yP;
        ydN = sqrt(2*sum(zydP.*zydN.*zyfac.*(zyN - repmat(yN,[nz,1])).^2)./yP);
        if opt_optim,
            for iy = 1:ny,
                zx = zN - yN(iy);
                zf = zdP.*zyfac(:,iy).'/yP(iy);
                ydN(iy) = lsqnonlin(@gauss_squares_jd,ydN(iy));
            end
        end
        %
    else
        %
        ipeak = find(zvar == -2);
        yN = zN(ipeak);
        ydN = yP/sqrt(pi)./zdP(ipeak);        
        %
    end
	%
	if abs(sum(yP) - Ptot)/Ptot > eps('double')*nz,
	    error('Power was not conserved')
	end
    %
    if nlobespro > 0 && ny > nlobespro,
	    %
        [yPsort,iysort] = sort(yP);
        %
        iypro = iysort(ny + 1 - nlobespro:ny);
        %
        yNpro = yN(iypro);
        ydNpro = ydN(iypro);
        yPpro = yP(iypro);
        zyfacpro = zyfac(:,iypro);
        %
        yN(iypro) = [];
        ydN(iypro) = [];
        yP(iypro) = [];
        zyfac(:,iypro) = [];
        %
        Ptot = Ptot - sum(yPpro);
        %
        ny = ny - nlobespro;
        %
    else
        %
        yNpro = yN([]);
        ydNpro = ydN([]);
        yPpro = yP([]);
        zyfacpro = zyfac(:,[]);
        %
    end
	%
    yP0 = yP;
    %
	while ny > nlobesmax || min(yP)/Ptot < Pfacmin,
        %
        iy = find(yP == min(yP),1,'first');
        %
	    if iy == 1,
	        %
	        iyp = 2;
	        zyfac(:,iyp) = zyfac(:,iyp) + zyfac(:,iy);
            yP(iyp) = sum(zdP.*zdN.*zyfac(:,iyp).');
            %
            if opt_peak == 1,
                yN(iyp) = sum(zdP.*zdN.*zyfac(:,iyp).'.*zN)./yP(iyp);
                ydN(iyp) = sqrt(2*sum(zdP.*zdN.*zyfac(:,iyp).'.*(zN - yN(iyp)).^2)/yP(iyp));
                if opt_optim,
                    zx = zN - yN(iyp);
                    zf = zdP.*zyfac(:,iyp).'/yP(iyp);
                    ydN(iyp) = lsqnonlin(@gauss_squares_jd,ydN(iyp));
                end
            end
	        %
	    elseif iy == ny,
	        %
	        iym = ny - 1;
	        zyfac(:,iym) = zyfac(:,iym) + zyfac(:,iy);
            yP(iym) = sum(zdP.*zdN.*zyfac(:,iym).');
            %
            if opt_peak == 1,
                yN(iym) = sum(zdP.*zdN.*zyfac(:,iym).'.*zN)./yP(iym);
                ydN(iym) = sqrt(2*sum(zdP.*zdN.*zyfac(:,iym).'.*(zN - yN(iym)).^2)/yP(iym));
                if opt_optim,
                    zx = zN - yN(iym);
                    zf = zdP.*zyfac(:,iym).'/yP(iym);
                    ydN(iym) = lsqnonlin(@gauss_squares_jd,ydN(iym));
                end
            end
	        %
	    else
	        %
	        iym = iy - 1;
	        iyp = iy + 1;
	        %
	        Nlim = (yN(iym) + yN(iyp))/2;
	        izlimm = find(zN_S < Nlim,1,'last');
	        %
	        zyfac(1:izlimm-1,iym) = zyfac(1:izlimm-1,iym) + zyfac(1:izlimm-1,iy);
	        zyfac(izlimm+1:end,iyp) = zyfac(izlimm+1:end,iyp) + zyfac(izlimm+1:end,iy);
	        %
	        zyfac(izlimm,iym) = zyfac(izlimm,iym) + zyfac(izlimm,iy)*(Nlim - zN_S(izlimm))/zdN(izlimm);
	        zyfac(izlimm,iyp) = zyfac(izlimm,iyp) + zyfac(izlimm,iy)*(zN_S(izlimm + 1) - Nlim)/zdN(izlimm);
	        %
            yP(iym) = sum(zdP.*zdN.*zyfac(:,iym).');
            yP(iyp) = sum(zdP.*zdN.*zyfac(:,iyp).');
            %
            if opt_peak == 1,
                yN(iym) = sum(zdP.*zdN.*zyfac(:,iym).'.*zN)./yP(iym);
                ydN(iym) = sqrt(2*sum(zdP.*zdN.*zyfac(:,iym).'.*(zN - yN(iym)).^2)/yP(iym));
                if opt_optim,
                    zx = zN - yN(iym);
                    zf = zdP.*zyfac(:,iym).'/yP(iym);
                    ydN(iym) = lsqnonlin(@gauss_squares_jd,ydN(iym));
                end
                %
                yN(iyp) = sum(zdP.*zdN.*zyfac(:,iyp).'.*zN)./yP(iyp);
                ydN(iyp) = sqrt(2*sum(zdP.*zdN.*zyfac(:,iyp).'.*(zN - yN(iyp)).^2)/yP(iyp));
                if opt_optim,
                    zx = zN - yN(iyp);
                    zf = zdP.*zyfac(:,iyp).'/yP(iyp);
                    ydN(iyp) = lsqnonlin(@gauss_squares_jd,ydN(iyp));
                end
            end
	        %
	    end
	    %
	    yP0(iy) = [];
        yP(iy) = [];
	    yN(iy) = [];
	    ydN(iy) = [];
	    zyfac(:,iy) = [];
	    %
	    ny = ny - 1;    
	    %
    end
    %
    if opt_peak == 0,
        %
        ydN = ydN.*yP./yP0;
        %
    end
    %
    yN = [yNpro,yN];
    ydN = [ydNpro,ydN];
    yP = [yPpro,yP];
    zyfac = [zyfacpro,zyfac];
    %
    [yN,iy] = sort(yN);
    ydN = ydN(iy);
    yP = yP(iy);
    zyfac = zyfac(:,iy);
    %
    ny = ny + nlobespro;
    %
	if display_mode >= 2,
	    %
	    dx = min(ydN)/10;
	    x = (min(yN) - 4*max(ydN)):dx:(max(yN) + 4*max(ydN));
	    nx = length(x);
	    %
	    xyN = repmat(yN,[nx,1]);
	    xyP = repmat(yP,[nx,1]);
	    xydN = repmat(ydN,[nx,1]);
	    xy = repmat(x.',[1,ny]);
	    %
	    xyf = xyP.*exp(-(xy - xyN).^2./xydN.^2)./sqrt(pi)./xydN;
	    xf = sum(xyf,2);
	    %
        ylim = [Pmindisp,Pmaxdisp];
        %
		figure('Name','Gaussian fit calculation'),
		leg = {'Gaussian','Fit'};
		graph1D_jd(xy(:),xyf(:)/1e6,0,1,'n_z','dP/dn_z (MW)','',NaN,'',ylim/1e6,'-','none','b',2,20,gca,0.9,0.7,0.7);
		graph1D_jd(x,xf/1e6,0,1,'','','',leg,'',ylim/1e6,'--','none','r',2);
	    %
	    figure('Name','Gaussian fit vs. ALOHA'),
	    leg = {'ALOHA','Gaussian fit','Location','NorthWest'};
		graph1D_jd(zN,zdP/1e6,0,1,'n_z','dP/dn_z (MW)','',NaN,'',ylim/1e6,'-','none','b',2,20,gca,0.9,0.7,0.7);
		graph1D_jd(x,xf/1e6,0,1,'','','',leg,'',ylim/1e6,'--','none','r',2);
	    %    
    end
    %
end       
%
function [zdf] = gauss_squares_jd(dN)
	% 
	global zx zf
	%
	zdf = zf - exp(-zx.^2/dN^2)/sqrt(pi)/dN;
	%
end






    