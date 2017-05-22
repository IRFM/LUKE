function [equil,prho,pspsin] = equil_magnetic_AUG_jd(external,opt)
%
if nargin < 2 || ~isstruct(opt),
    opt = struct;
end
%
if ~isfield(opt,'nlev'),
    opt.nlev = 100;
end
if ~isfield(opt,'axis'),
    opt.axis = true;%recalculatethe axis position
end
if ~isfield(opt,'np'),
    opt.np = 100;
end
if ~isfield(opt,'nt'),
    opt.nt = 65;
end
%
%
R = external.R;
Z = external.Z;
BR = external.BR;
BZ = external.BZ;
Bphi = external.Bphi;
psi = external.psi;
%
if all(isfield(external,{'Rp','Zp','psi0','psia'})),
    Rp = external.Rp;
    Zp = external.Zp;
    psip = external.psi0;
    psia = external.psia;
else
    %
    [Rc,Zc,~,lev] = contlimit_jd(R,Z,psi.',opt.nlev);
    %
    nc = length(lev);
    lc = zeros(1,nc);
    le = zeros(1,nc);
    for ic = 1:nc,
        lc(ic) = sum(sqrt((Rc{ic}(2:end) - Rc{ic}(1:end-1)).^2 + (Zc{ic}(2:end) - Zc{ic}(1:end-1)).^2));
        la(ic) = (max(Rc{ic}) - min(Rc{ic})).*(max(Zc{ic}) - min(Zc{ic}));
        le(ic) = sqrt((Rc{ic}(1) - Rc{ic}(end)).^2 + (Zc{ic}(1) - Zc{ic}(end)).^2);
    end
    %
    icmask = find(lc > 0 & la > 0 & le == 0);
    %
    % figure
    % for iic = 1:length(icmask),
    %     plot(Rc{icmask(iic)},Zc{icmask(iic)}),hold on
    % end
    % axis('equal')
    ic_lcfs = icmask(lc(icmask) == max(lc(icmask)));
    psia = lev(ic_lcfs);
    %
    Rmin_lcfs = min(Rc{ic_lcfs});
    Rmax_lcfs = max(Rc{ic_lcfs});
    Zmin_lcfs = min(Zc{ic_lcfs});
    Zmax_lcfs = max(Zc{ic_lcfs});
    %
    % reject contours outside of lcf
    for iic = length(icmask):-1:1,
        Rav = mean(Rc{icmask(iic)});
        Zav = mean(Zc{icmask(iic)});
        if Rav < Rmin_lcfs || Rav > Rmax_lcfs || Zav < Zmin_lcfs || Zav > Zmax_lcfs,
            icmask(iic) = [];
        end
    end
    %
    ic_ifs = icmask(lc(icmask) == min(lc(icmask)));
    psi_ifs = lev(ic_ifs);
    %
    Rmin_ifs = min(Rc{ic_ifs});
    Rmax_ifs = max(Rc{ic_ifs});
    Zmin_ifs = min(Zc{ic_ifs});
    Zmax_ifs = max(Zc{ic_ifs});
    %
    icext = find((lc == 0 | la == 0) & le == 0);
    %
    next = length(icext);
    mask_ext = false(1,next);
    mask_lcfs = false(1,next);
    %
    for iic = 1:next,
        Rcext = mean(Rc{icext(iic)});
        Zcext = mean(Zc{icext(iic)});
        mask_ext(iic) = Rcext < Rmax_ifs && Rcext > Rmin_ifs && Zcext < Zmax_ifs && Zcext > Zmin_ifs;
        mask_lcfs(iic) = Rcext < Rmax_lcfs && Rcext > Rmin_lcfs && Zcext < Zmax_lcfs && Zcext > Zmin_lcfs;
    end
    %
    if sum(mask_lcfs) == 0,%no point represent plasma center
        %
        psip_orig = psi_ifs;
        Rp_orig = (Rmin_ifs + Rmax_ifs)/2;
        Zp_orig = (Zmin_ifs + Zmax_ifs)/2;
        %
    else
        %
        if sum(mask_ext) == 1,
            %
            psip_orig = lev(icext(mask_ext));
            Rp_orig =  mean(Rc{icext(mask_ext)});
            Zp_orig =  mean(Zc{icext(mask_ext)});
            %
        else
            error('cannot identify plasma major radius')
            %
        end
    end
    if opt.axis,
        sR = linspace(Rmin_ifs,Rmax_ifs,101);
        sZ = linspace(Zmin_ifs,Zmax_ifs,111);
        %
        spsi = interp2(R,Z,psi.',sR.',sZ,'spline').';
        %
        sigma = sign(psia - psi_ifs);
        %
        [isR,isZ] = find(sigma*spsi == min(min(sigma*spsi)));
        Rp = sR(isR);
        Zp = sZ(isZ);
        psip = spsi(isR,isZ);
        %
        disp(['Old value of psip: ',num2str(psip_orig),', new value: ',num2str(psip)])
        disp(['Old value of Rp: ',num2str(Rp_orig),', new value: ',num2str(Rp)])
        disp(['Old value of Zp: ',num2str(Zp_orig),', new value: ',num2str(Zp)])
    else
        Rp = Rp_orig;
        Zp = Zp_orig;
        psip = psip_orig;
    end
end
%
x = R - Rp;
y = Z - Zp;
%
psi = psi - psip;
psia = psia - psip;
xypsin = psi/psia;
%
[ptx,pty,~,~,psin,theta] = rz2pt_jd(x,y,xypsin,opt.np,opt.nt,'spline',0);
%
ap = ptx(opt.np,1);%Plasma minor radius on the LFS midplane
psi_apRp = psin*psia*ap/Rp;%The poloidal flux coordinate is normalized by the aspect ratio 
%
ptBx = interp2(x,y,BR.',ptx,pty,'spline');
ptBy = interp2(x,y,BZ.',ptx,pty,'spline');
ptBPHI = interp2(x,y,Bphi.',ptx,pty,'spline');
%
prho = ptx(:,1).'/ap;
pspsin = sqrt(psin);
%
equil.psi_apRp = psi_apRp;
equil.theta = theta;
equil.ptx = ptx;
equil.pty = pty;
equil.ptBx = ptBx;
equil.ptBy = ptBy;
equil.ptBPHI = ptBPHI;
equil.Rp = Rp;
equil.Zp = Zp;
equil.equi_src = external;
%


