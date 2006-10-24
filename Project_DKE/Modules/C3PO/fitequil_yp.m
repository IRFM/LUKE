function [equil_out] = fitequil_yp(equil_in,mode,method,ngrid,nharm)
%
% Build vectorial tokamak magnetic equilibrium from its numerical counterpart
% Two operating modes :
% 1) Spline-Fourier description for (psi,theta) magnetic equilibrium (HELENA for example)
%
%    1-D: use interp1.m MatLab built-in function (spline, bi-cubic, linear,  nearest,...)
%    2-D: use Fourier series expansion for the poloidal dependence and the
%    interp1.m for the Fourier series coefficients (spline, bi-cubic, linear,
%    nearest,...)
%
% 2) Spline-Spline description for (x,y) magnetic equilibrium (EFIT for example)
%
%    1-D: use interp1.m MatLab built-in function (spline, bi-cubic, linear, nearest,...)
%    2-D: use interp1.m for the x-direction and the interp1.m again for the coefficients of the 
%    previous spline (spline, bi-cubic, linear, nearest,...)
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
if nargin == 1, 
    mode = 1;%Spline-Fourier case
    method = 'spline';
    ngrid = 2000;
    nharm = [];
end
if nargin == 2, 
    method = 'spline';
    ngrid = 2000;
    nharm = [];
end
if nargin == 3, 
    ngrid = 2000;  
    nharm = [];
end
if nargin == 4, 
    nharm = [];%For Spline-Fourier case only
end
%
equil_out.id = equil_in.id;
equil_out.method = method;
if ~isempty(equil_in.zZi),equil_out.zZi = equil_in.zZi;else equil_out.zZi = [0,0,0];end
if ~isempty(equil_in.zmi),equil_out.zmi = equil_in.zmi;else equil_out.zmi = [1,1,1];end
psia = equil_in.psi(end);
%
if mode == 1,
   [rho] = psi2rho_jd(equil_in,equil_in.psi/psia,method);
%
%Resampling on a finer mesh close to psi = 0 before spline-Fourier calculations. 
%
   srho = linspace(0,1,ngrid).^2;
   spsin = interp1(rho,equil_in.psi/psia,srho,method);
%
   if ~isempty(equil_in.pTe),sTe = interp1(rho,equil_in.pTe,srho,method);end
   if ~isempty(equil_in.pne),sne = interp1(rho,equil_in.pne,srho,method);end
   if ~isempty(equil_in.pzTi),szTi = interp1(rho,equil_in.pzTi',srho',method)';end
   if ~isempty(equil_in.pzni),szni = interp1(rho,equil_in.pzni',srho',method)';end
%
   sBx = interp1(rho,equil_in.ptBx,srho,method);%Bx field component
   sBy = interp1(rho,equil_in.ptBy,srho,method);%By field component
   sBPHI = interp1(rho,equil_in.ptBPHI,srho,method);%PHI field component
   sx = interp1(rho,equil_in.ptx,srho,method);%x coordinate
   sy = interp1(rho,equil_in.pty,srho,method);%y coordinate
%
% Calculation of the vectorial magnetic equilibrium
%
   equil_out.psin_fit = interpequilpt_yp(method,spsin,srho);
%
   sxstar_psin_fit = interpequilpt_yp(method,sx(:,1),spsin);%xstar = x(:,theta=0)
   sdxstardpsin_psin = ppval(sxstar_psin_fit.pp_dfdrho,spsin);
   equil_out.dxstardpsin_fit = interpequilpt_yp(method,sdxstardpsin_psin,srho);
%
   if ~isempty(equil_in.pTe),equil_out.Te_fit = interpequilpt_yp(method,sTe,srho);end
   if ~isempty(equil_in.pne),equil_out.ne_fit = interpequilpt_yp(method,sne,srho);end
   if ~isempty(equil_in.pzTi),equil_out.zTi_fit = interpequilpt_yp(method,szTi,srho);end
   if ~isempty(equil_in.pzni),equil_out.zni_fit = interpequilpt_yp(method,szni,srho);end
%
   if isempty(nharm),nharm = length(equil_in.theta) - 1;end
%
   equil_out.Bx_fit = interpequilpt_yp(method,sBx,srho,equil_in.theta,nharm);%Bx field component
   equil_out.By_fit = interpequilpt_yp(method,sBy,srho,equil_in.theta,nharm);%By field component
   equil_out.BPHI_fit = interpequilpt_yp(method,sBPHI,srho,equil_in.theta,nharm);%PHI field component
   equil_out.x_fit = interpequilpt_yp(method,sx,srho,equil_in.theta,nharm);%x coordinate
   equil_out.y_fit = interpequilpt_yp(method,sy,srho,equil_in.theta,nharm);%y coordinate
else
   if ~isempty(equil_in.pTe),xyTe = interp1(equil_in.psi,equil_in.pTe,equil_in.xypsi,method);end
   if ~isempty(equil_in.pne),xyne = interp1(equil_in.psi,equil_in.pne,equil_in.xypsi,method);end
   for ii = 1:length(equil_in.zZi),
      if ~isempty(equil_in.pzTi),xyzTi(:,:,ii) = interp1(equil_in.psi,equil_in.pzTi(ii,:),equil_in.xypsi,method);end
      if ~isempty(equil_in.pzni),xyzni(:,:,ii) = interp1(equil_in.psi,equil_in.pzni(ii,:),equil_in.xypsi,method);end
   end
%
   if ~isempty(equil_in.pTe),equil_out.Te_fit = interpequilxy_yp(method,xyTe,equil_in.x,equil_in.y);end
   if ~isempty(equil_in.pne),equil_out.ne_fit = interpequilxy_yp(method,xyne,equil_in.x,equil_in.y);end
   if ~isempty(equil_in.pzTi),equil_out.zTi_fit = interpequilxy_yp(method,xyzTi,equil_in.x,equil_in.y);end
   if ~isempty(equil_in.pzni),equil_out.zni_fit = interpequilxy_yp(method,xyzni,equil_in.x,equil_in.y);end
%
  xyF = interp1(equil_in.ppsi,equil_in.pF,equil_in.xypsi,method);
  [xydpsidy,xydpsidx] = gradient(equil_in.xypsi,equil_in.x,equil_in.y);
  xyx = equil_in.x(:)*ones(1,length(equil_in.y));
  xyy = ones(length(equil_in.x),1)*equil_in.y;
%
  xyBx = xydpsidy./xyx;
  xyBy = -xydpsidx./xyx;
  xyBPHI = xyF./xyx;
%
  equil_out.psin_fit = interpequilxy_yp(method,equil_in.xypsi,equil_in.x,equil_in.y);%poloidal magnetic field
  equil_out.Bx_fit = interpequilxy_yp(method,xyBx,equil_in.x,equil_in.y);%Bx field component
  equil_out.By_fit = interpequilxy_yp(method,xyBy,equil_in.x,equil_in.y);%By field component
  equil_out.BPHI_fit = interpequilxy_yp(method,xyBPHI,equil_in.x,equil_in.y);%PHI field component
  equil_out.x_fit = interpequilxy_yp(method,equil_in.x,equil_in.x);%x coordinate
  equil_out.y_fit = interpequilxy_yp(method,equil_in.y,equil_in.y);%y coordinate
end
%
if equil_in.psi(1) == 0,
   equil_out.Rp = equil_in.Rp;
   equil_out.Zp = equil_in.Zp;
   equil_out.ap = equil_in.ptx(end,1);
   equil_out.psia = psia;
else
   error('equil_out.psi(1) must be equal to zero !');
end


