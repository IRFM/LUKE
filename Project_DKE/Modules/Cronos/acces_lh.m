

e     = 1.602176462000000e-19;
e2    = e*e;
me    = 9.109381880000001e-31;
mp    = 1.672648500000000e-27;
epsi0 = 8.854187817620391e-12;
x     = gene.x;
dens     = [equil.pne;equil.pzni];
Bfield   = prof.bphi;
omega_rf =  wavestructs{1}.launch.omega_rf;
ms       = [me;mp*equil.zmi(:)];
ns       = dens;
qs       = e*[-1;equil.zZi(:)];    
bphimax  = min(squeeze(equi.BPHI(1,:,:))');
bphi     = double(squeeze(equi.BPHI(1,:,:))');
br       = double(squeeze(equi.BR(1,:,:))');
bz       = double(squeeze(equi.BZ(1,:,:))');
bphi     = sqrt(bphi.^2 + br.^2 + bz.^2);
bphi     = bphi';
R        = double(squeeze(equi.R));
Z        = double(squeeze(equi.Z));
%

for k=1:length(x)
  wps(:,k) = sqrt(ns(:,k).*qs.^2/epsi0./ms);
  wcs(:,k) = qs*Bfield(k)./ms;
  wcsmax(:,k) = qs*bphimax(k)./ms;
  
  ps(:,k)  = wps(:,k)/omega_rf(1);
  ys(:,k)  = wcs(:,k)/omega_rf(1);
  val      = ys(:,k);
  val(val.^2 == 1) = val(val.^2 == 1) + eps;
  ys(:,k)  = val;
  ysmax(:,k)  = wcsmax(:,k)/omega_rf(1);
  val      = ysmax(:,k);
  val(val.^2 == 1) = val(val.^2 == 1) + eps;
  ysmax(:,k)  = val;
%
%   Dielectric tensor elements
%
  Kperp = 1 - sum(ps(:,k).^2./(1 - ys(:,k).^2));
  Kpar  = 1 - sum(ps(:,k).^2);
  Kxy   = sum(ps(:,k).^2.*ys(:,k)./(1 - ys(:,k).^2));
  Kperpmax = 1 - sum(ps(:,k).^2./(1 - ysmax(:,k).^2));
  Kparmax  = 1 - sum(ps(:,k).^2);
  Kxymax   = sum(ps(:,k).^2.*ysmax(:,k)./(1 - ysmax(:,k).^2));
%
%   Accessibility condition
%
  Npar(k) = sqrt(Kperp + (sqrt(4*Kperp*Kpar*Kxy^2*(Kxy^2 - (Kperp - Kpar)^2)) - Kxy^2*(Kperp + Kpar))/(Kperp - Kpar)^2);%warning: this solution is valid in the LH frequency range only
  Nparmax(k) = sqrt(Kperpmax + (sqrt(4*Kperpmax*Kparmax*Kxymax^2*(Kxymax^2 - (Kperpmax - Kparmax)^2)) - Kxymax^2*(Kperpmax + Kparmax))/(Kperpmax - Kparmax)^2);%warning: this solution is valid in the LH frequency range only
%
% etude en theta
%
  for m=1:65
     wcstheta(:,k)    = qs*bphi(k,m)./ms;
     ystheta(:,k)     = wcstheta(:,k)/omega_rf(1);
     val              = ystheta(:,k);
     val(val.^2 == 1) = val(val.^2 == 1) + eps;
     ystheta(:,k)     = val;
%
%   Dielectric tensor elements
%
     Kperpt   = 1 - sum(ps(:,k).^2./(1 - ystheta(:,k).^2));
     Kxyt     = sum(ps(:,k).^2.*ystheta(:,k)./(1 - ystheta(:,k).^2));
%
%   Accessibility condition
%
     Npart(k,m) = sqrt(Kperpt + (sqrt(4*Kperpt*Kpar*Kxyt^2*(Kxyt^2 - (Kperp - Kpar)^2)) - Kxyt^2*(Kperpt + Kpar))/(Kperpt - Kpar)^2);%warning: this solution is valid in the LH frequency range only
   end
end
if ~isstruct(cons) 
  npar0 = angle(cons);
  Plh   = abs(cons);
else
  npar0=angle(cons.lh_cons);
  Plh   = abs(cons.lh_cons);  
end
nlh = length(Plh);
acces = 1;
for k=1:nlh
  if Plh(k) > 0
    if sum(any((-Npart+npar0(k))<0))
      acces = acces-1;
    end
  end
end 
if acces < 1


  h = findobj(0,'type','figure','tag','acces_lh');
  if isempty(h)
       h=figure('tag','acces_lh');
  else
       figure(h);
  end   
  clf
  set(h,'defaultaxesfontsize',12,'defaultaxesfontweight','bold','defaultaxesfontname','times','defaultlinelinewidth',3,'color',[1 1 1])

  col=['r','b','k','m'];
  for k=1:nlh	
    if Plh(k) > 0
      subplot(1,nlh,k)
      contourf(R,Z,-Npart+npar0(k),0.01)
      colorbar
      title(['antenna ',int2str(k),' accessibility boundary, n// > nacc'])
      axis(['equal'])
    end	
  end	
  hold on
  plot(double(geo.R),double(geo.Z))
  hold off

  disp('warning : accessibility problem for the raytracing of LUKE')

end
