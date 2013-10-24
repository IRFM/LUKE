function [delta,ntargetsh] = delta_wave_optim_jd(wave,equil_fit,ntargets)
%
ray = wave.rays{1};
Ph_2piRp_lin = (ray.P0_2piRp + ray.sP_2piRp_lin(end))/2;
%
smask = 1 + [0,find(diff(ray.sP_2piRp_lin) < 0)];% monotonic evolution
%
rhoh = interp1(ray.sP_2piRp_lin(smask),sqrt(ray.spsin(smask)),Ph_2piRp_lin);
thetah = interp1(ray.sP_2piRp_lin(smask),ray.stheta(smask),Ph_2piRp_lin);
nparh = interp1(ray.sP_2piRp_lin(smask),ray.sNpar(smask),Ph_2piRp_lin);
%
% xh = interp1(ray.sP_2piRp_lin(smask),ray.sx(smask),Ph_2piRp_lin);
% yh = interp1(ray.sP_2piRp_lin(smask),ray.sy(smask),Ph_2piRp_lin);
%
x_a0h = ppval_yp(equil_fit.x_fit.pp_a0,rhoh);
x_anh = ppval_yp(equil_fit.x_fit.pp_an,rhoh);
x_bnh = ppval_yp(equil_fit.x_fit.pp_bn,rhoh);
%
y_a0h = ppval_yp(equil_fit.y_fit.pp_a0,rhoh);
y_anh = ppval_yp(equil_fit.y_fit.pp_an,rhoh);
y_bnh = ppval_yp(equil_fit.y_fit.pp_bn,rhoh);
%
xh = x_a0h + x_anh*cos(equil_fit.x_fit.n*thetah) + x_bnh*sin(equil_fit.x_fit.n*thetah);
yh = y_a0h + y_anh*cos(equil_fit.y_fit.n*thetah) + y_bnh*sin(equil_fit.y_fit.n*thetah);
%
ntargetsh(1) = rhoh;
ntargetsh(2) = thetah;
ntargetsh(3) = nparh;
%
if ~isempty(ntargets),
    %
    if ~isnan(ntargets(1)),
        rho = ntargets(1);
    else
        rho = rhoh;
    end
    %
    if ~isnan(ntargets(2)),
        theta = ntargets(2);
    else
        theta = thetah;
    end
    %
    if ~isnan(ntargets(3)),
        npar = ntargets(3);
    else
        npar = nparh;
    end
    %
    x_a0 = ppval_yp(equil_fit.x_fit.pp_a0,rho);
    x_an = ppval_yp(equil_fit.x_fit.pp_an,rho);
    x_bn = ppval_yp(equil_fit.x_fit.pp_bn,rho);
    %
    y_a0 = ppval_yp(equil_fit.y_fit.pp_a0,rho);
    y_an = ppval_yp(equil_fit.y_fit.pp_an,rho);
    y_bn = ppval_yp(equil_fit.y_fit.pp_bn,rho);
    %
    x = x_a0 + x_an*cos(equil_fit.x_fit.n*theta) + x_bn*sin(equil_fit.x_fit.n*theta);
    y = y_a0 + y_an*cos(equil_fit.y_fit.n*theta) + y_bn*sin(equil_fit.y_fit.n*theta);
    %
    delta = sqrt((x - xh).^2 + (y - yh).^2 + (npar - nparh).^2);
    %
else
    delta = [];
end
