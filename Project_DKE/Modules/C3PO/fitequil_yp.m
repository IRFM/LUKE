function [equil_out] = fitequil_yp(equil_in,mode,method,ngrid,nharm)
% C3PO - Build vectorial tokamak magnetic equilibrium from its numerical counterpart
%
% Build vectorial tokamak magnetic equilibrium from its numerical counterpart
%
% Two operating modes :
% 1) Spline-Fourier description for (psi,theta) magnetic equilibrium (HELENA for example)
%
%    1-D: use interp1.m MatLab built-in function (Hermite polynomials (pchip), spline, linear,  nearest,...)
%    2-D: use Fourier series expansion for the poloidal dependence and the
%    interp1.m for the Fourier series coefficients (Hermite polynomials (pchip), spline, linear,
%    nearest,...)
%
% 2) Spline-Spline description for (x,y) magnetic equilibrium (EFIT for example, or for TORPEX case)
%
%    1-D: use interp1.m MatLab built-in function (Hermite polynomials (pchip), spline, linear, nearest,...)
%    2-D: use interp1.m for the x-direction and the interp1.m again for the coefficients of the 
%    previous spline (Hermite polynomials (pchip), spline, bi-cubic, linear, nearest,...)
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
if nargin == 1, 
    mode = 1;%Spline-Fourier case
    method = 'spline';
    ngrid = 1001;
    nharm = [];
end
if nargin == 2, 
    method = 'spline';
    ngrid = 1001;
    nharm = [];
end
if nargin == 3, 
    ngrid = 1001;  
    nharm = [];
end
if nargin == 4, 
    nharm = [];%For Spline-Fourier case only
end
%
if isfield(equil_in,'pzni') && isfield(equil_in,'pzTi') && isfield(equil_in,'zZi') && isfield(equil_in,'pne') && isfield(equil_in,'pTe')
    %
    equil_in = ionization_model_yp(equil_in);%impurity ionization model
    %
    if ~isempty(equil_in.zZi),equil_out.zZi = equil_in.zZi;else equil_out.zZi = [0,0,0];end
    if ~isempty(equil_in.zmi),equil_out.zmi = equil_in.zmi;else equil_out.zmi = [1,1,1];end
end
%
equil_out.id = equil_in.id;
equil_out.method = method;
%
equil_out.Rp = equil_in.Rp;
equil_out.Zp = equil_in.Zp;
%
if mode == 1,%Spline-Fourier case: (psi,theta) magnetic equilibrium   
    %
    ap = equil_in.ptx(end,1);
    psi_apRp = equil_in.psi_apRp;
    psia_apRp = equil_in.psi_apRp(end);
    %
    sigmaIp =  sign(psia_apRp);%Sign of the plasma current (> 0 if Ip is clock-wise when the tokamak in viewed from the top)
    %
    %Resampling on a finer mesh close to psi_apRp = 0 before Hermite-Fourier calculations. 
    %
    srho = linspace(0,1,ngrid).^2;
    %
    [rho] = psi2rho_jd(equil_in,psi_apRp/psia_apRp,method);
    %
    spsin = interp1(rho,psi_apRp/psia_apRp,srho,method);
    %
    if isfield(equil_in,'pzni') && isfield(equil_in,'pzTi') && isfield(equil_in,'zZi') && isfield(equil_in,'pne') && isfield(equil_in,'pTe') 
        if ~isempty(equil_in.pTe),sTe = interp1(rho,equil_in.pTe,srho,method);end
        if ~isempty(equil_in.pne),sne = interp1(rho,equil_in.pne,srho,method);end
        if ~isempty(equil_in.pzTi),szTi = interp1(rho,equil_in.pzTi',srho',method)';end
        if ~isempty(equil_in.pzni),szni = interp1(rho,equil_in.pzni',srho',method)';end
    end
    %
    sBx = interp1(rho,equil_in.ptBx,srho,method);%Bx field component
    sBy = interp1(rho,equil_in.ptBy,srho,method);%By field component
    sBz = interp1(rho,equil_in.ptBPHI,srho,method);%PHI field component
    %
    sBx(:,end) = sBx(:,1);
    sBy(:,end) = sBy(:,1);
    sBz(:,end) = sBz(:,1);
    %
    sx = interp1(rho,equil_in.ptx,srho,method);%x coordinate
    sy = interp1(rho,equil_in.pty,srho,method);%y coordinate
    %
    sx(:,end) = sx(:,1);
    sy(:,end) = sy(:,1);
    %
    sr = sqrt(sx.*sx + sy.*sy);%r
    %
    sBP = sqrt(sBx.*sBx + sBy.*sBy);%BP field 
    sB = sqrt(sBx.*sBx +sBy.*sBy + sBz.*sBz);%B field
    %
    scalpha = (sx.*sBy - sy.*sBx)./sBP./sr;%cos(alpha)
    ssalpha = sigmaIp*(sx.*sBx + sy.*sBy)./sBP./sr;%sin(alpha)
    %
    scalpha(1,:) = scalpha(2,:);%to avoid singularity at r = 0
    ssalpha(1,:) = ssalpha(2,:);%to avoid singularity at r = 0
    %
    if isinf(equil_in.Rp),
        sUpsilon = 1;
    else
        sUpsilon = 1 + sx/equil_in.Rp;
    end
    %
    sdpsin = gradient(spsin(:));
    sdxstardpsin = gradient(sx(:,1))./sdpsin(:);
    %
    sgradrho = sUpsilon.*sBP.*(sdxstardpsin*ones(1,size(sx,2)))/abs(equil_in.psi_apRp(end));
    sgradrho(1,:) = sgradrho(2,:);
    sgradrho(:,end) = sgradrho(:,1);
    %
    % Calculation of the vectorial magnetic equilibrium
    %
    equil_out.psin_fit = interpequilpt_yp(method,spsin,srho);
    %
    sxstar_psin_fit = interpequilpt_yp(method,sx(:,1),spsin);%xstar = x(:,theta=0)
    sdxstardpsin_psin = ppval_yp(sxstar_psin_fit.pp_dfdrho,spsin);
    equil_out.dxstardpsin_fit = interpequilpt_yp(method,sdxstardpsin_psin,srho);
    %
    if isfield(equil_in,'pzni') && isfield(equil_in,'pzTi') && isfield(equil_in,'zZi') && isfield(equil_in,'pne') && isfield(equil_in,'pTe') 
        if ~isempty(equil_in.pTe),equil_out.Te_fit = interpequilpt_yp(method,sTe,srho);end
        if ~isempty(equil_in.pne),equil_out.ne_fit = interpequilpt_yp(method,sne,srho);end
        if ~isempty(equil_in.pzTi),equil_out.zTi_fit = interpequilpt_yp(method,szTi,srho);end
        if ~isempty(equil_in.pzni),equil_out.zni_fit = interpequilpt_yp(method,szni,srho);end
    end
    %
    if isempty(nharm) || isinf(nharm) || isnan(nharm) ,nharm = length(equil_in.theta) - 1;end
    %
    equil_out.Bx_fit = interpequilpt_yp(method,sBx,srho,equil_in.theta,nharm);%Bx field component
    equil_out.By_fit = interpequilpt_yp(method,sBy,srho,equil_in.theta,nharm);%By field component
    equil_out.Bz_fit = interpequilpt_yp(method,sBz,srho,equil_in.theta,nharm);%Bz field component
    equil_out.BP_fit = interpequilpt_yp(method,sBP,srho,equil_in.theta,nharm);%BP field 
    equil_out.B_fit = interpequilpt_yp(method,sB,srho,equil_in.theta,nharm);%B field 
    equil_out.x_fit = interpequilpt_yp(method,sx,srho,equil_in.theta,nharm);%x coordinate
    equil_out.y_fit = interpequilpt_yp(method,sy,srho,equil_in.theta,nharm);%y coordinate
    equil_out.r_fit = interpequilpt_yp(method,sr,srho,equil_in.theta,nharm);%y coordinate
    equil_out.calpha_fit = interpequilpt_yp(method,scalpha,srho,equil_in.theta,nharm);%cos(alpha)
    equil_out.salpha_fit = interpequilpt_yp(method,ssalpha,srho,equil_in.theta,nharm);%sin(alpha)
    equil_out.gradrho_fit = interpequilpt_yp(method,sgradrho,srho,equil_in.theta,nharm);%sin(alpha)
    %
    if psi_apRp(1) == 0,
        equil_out.ap = ap;
        equil_out.psia_apRp = psia_apRp;
    else
        error('equil_out.psi_apRp(1) must be equal to zero !');
    end
    %
elseif mode == 2,%Spline-Spline description for (x,y) magnetic equilibrium
    %
    method = 'cubic';
    equil_out.method = method;
    %
    sxyx = linspace(min(equil_in.xyx),max(equil_in.xyx),ngrid);sxydx = sxyx(2) - sxyx(1);
    sxyy = linspace(max(equil_in.xyy),min(equil_in.xyy),ngrid);sxydy = sxyy(2) - sxyy(1);
    %
    [X,Y] = meshgrid(equil_in.xyx,equil_in.xyy);
    [sX,sY] = meshgrid(sxyx,sxyy);
    %
    sX_ij = sX(1:size(sX,1)-1,1:size(sX,2)-1);
    sX_ipj = sX(2:size(sX,1),1:size(sX,2)-1);
    sX_ijp = sX(1:size(sX,1)-1,2:size(sX,2));
    sX_ipjp = sX(1:size(sX,1)-1,2:size(sX,2));
    %
    sY_ij = sY(1:size(sY,1)-1,1:size(sY,2)-1);
    sY_ipj = sY(2:size(sY,1),1:size(sY,2)-1);
    sY_ijp = sY(1:size(sY,1)-1,2:size(sY,2));
    sY_ipjp = sY(1:size(sY,1)-1,2:size(sY,2));
    %
    equil_out.XX = [sX_ipj(:),sX_ipjp(:),sX_ijp(:),sX_ij(:)];
    equil_out.YY = [sY_ipj(:),sY_ipjp(:),sY_ijp(:),sY_ij(:)];
    %
    sxyne = interp2(X,Y,equil_in.xyne,sX,sY,method);
    [sxydnedx,sxydnedy] = gradient(sxyne,sxydx,sxydy);
    [sxyd2nedxdx,sxyd2nedxdy] = gradient(sxydnedx,sxydx,sxydy);
    [sxyd2nedydx,sxyd2nedydy] = gradient(sxydnedy,sxydx,sxydy);
    sxyd2nedxdy = (sxyd2nedxdy + sxyd2nedydx)/2;
    %
    sxyTe = interp2(X,Y,equil_in.xyTe,sX,sY,method);
    [sxydTedx,sxydTedy] = gradient(sxyTe,sxydx,sxydy);
    [sxyd2Tedxdx,sxyd2Tedxdy] = gradient(sxydTedx,sxydx,sxydy);
    [sxyd2Tedydx,sxyd2Tedydy] = gradient(sxydTedy,sxydx,sxydy);
    sxyd2Tedxdy = (sxyd2Tedxdy + sxyd2Tedydx)/2;
    %
    N = size(equil_in.xyne,1);
    sN = size(sxyne,1);
    %
    for iz = 1:length(equil_in.zZi),
        sxyzni(sN*(iz-1)+1:sN*iz,:) = interp2(X,Y,equil_in.xyzni(N*(iz-1)+1:N*iz,:),sX,sY,method);
        [sxyzdnidx(sN*(iz-1)+1:sN*iz,:),sxyzdnidy(sN*(iz-1)+1:sN*iz,:)] = gradient(sxyzni(sN*(iz-1)+1:sN*iz,:),sxydx,sxydy);
        [sxyzd2nidxdx(sN*(iz-1)+1:sN*iz,:),sxyzd2nidxdy(sN*(iz-1)+1:sN*iz,:)] = gradient(sxyzdnidx(sN*(iz-1)+1:sN*iz,:),sxydx,sxydy);
        [sxyzd2nidydx(sN*(iz-1)+1:sN*iz,:),sxyzd2nidydy(sN*(iz-1)+1:sN*iz,:)] = gradient(sxyzdnidy(sN*(iz-1)+1:sN*iz,:),sxydx,sxydy);
        sxyzd2nidxdy(sN*(iz-1)+1:sN*iz,:) = (sxyzd2nidxdy(sN*(iz-1)+1:sN*iz,:) + sxyzd2nidydx(sN*(iz-1)+1:sN*iz,:))/2;
        %
        sxyzTi(sN*(iz-1)+1:sN*iz,:) = interp2(X,Y,equil_in.xyzTi(N*(iz-1)+1:N*iz,:),sX,sY,method);
        [sxyzdTidx(sN*(iz-1)+1:sN*iz,:),sxyzdTidy(sN*(iz-1)+1:sN*iz,:)] = gradient(sxyzTi(sN*(iz-1)+1:sN*iz,:),sxydx,sxydy);
        [sxyzd2Tidxdx(sN*(iz-1)+1:sN*iz,:),sxyzd2Tidxdy(sN*(iz-1)+1:sN*iz,:)] = gradient(sxyzdTidx(sN*(iz-1)+1:sN*iz,:),sxydx,sxydy);
        [sxyzd2Tidydx(sN*(iz-1)+1:sN*iz,:),sxyzd2Tidydy(sN*(iz-1)+1:sN*iz,:)] = gradient(sxyzdTidy(sN*(iz-1)+1:sN*iz,:),sxydx,sxydy);
        sxyzd2Tidxdy(sN*(iz-1)+1:sN*iz,:) = (sxyzd2Tidxdy(sN*(iz-1)+1:sN*iz,:) + sxyzd2Tidydx(sN*(iz-1)+1:sN*iz,:))/2;
     end
    %
    sxyBx = interp2(X,Y,equil_in.xyBx,sX,sY,method);
    [sxydBxdx,sxydBxdy] = gradient(sxyBx,sxydx,sxydy);
    [sxyd2Bxdxdx,sxyd2Bxdxdy] = gradient(sxydBxdx,sxydx,sxydy);
    [sxyd2Bxdydx,sxyd2Bxdydy] = gradient(sxydBxdy,sxydx,sxydy);
    sxyd2Bxdxdy = (sxyd2Bxdxdy + sxyd2Bxdydx)/2;
    %
    sxyBy = interp2(X,Y,equil_in.xyBy,sX,sY,method);
    [sxydBydx,sxydBydy] = gradient(sxyBy,sxydx,sxydy);
    [sxyd2Bydxdx,sxyd2Bydxdy] = gradient(sxydBydx,sxydx,sxydy);
    [sxyd2Bydydx,sxyd2Bydydy] = gradient(sxydBydy,sxydx,sxydy);
    sxyd2Bydxdy = (sxyd2Bydxdy + sxyd2Bydydx)/2;
    %
    sxyBz = interp2(X,Y,equil_in.xyBz,sX,sY,method);
    [sxydBzdx,sxydBzdy] = gradient(sxyBz,sxydx,sxydy);
    [sxyd2Bzdxdx,sxyd2Bzdxdy] = gradient(sxydBzdx,sxydx,sxydy);
    [sxyd2Bzdydx,sxyd2Bzdydy] = gradient(sxydBzdy,sxydx,sxydy);
    sxyd2Bzdxdy = (sxyd2Bzdxdy + sxyd2Bzdydx)/2;
    %
	equil_out.ne_fit = interpequilxy_yp(sxyne,sxydnedx,sxydnedy,sxyd2nedxdy);
    equil_out.Te_fit = interpequilxy_yp(sxyTe,sxydTedx,sxydTedy,sxyd2Tedxdy);
    %
	equil_out.zni_fit = interpequilxy_yp(sxyzni,sxyzdnidx,sxyzdnidy,sxyzd2nidxdy);
    equil_out.zTi_fit = interpequilxy_yp(sxyzTi,sxyzdTidx,sxyzdTidy,sxyzd2Tidxdy);
    %
    equil_out.Bx_fit = interpequilxy_yp(sxyBx,sxydBxdx,sxydBxdy,sxyd2Bxdxdy);%Bx field component
    equil_out.By_fit = interpequilxy_yp(sxyBy,sxydBydx,sxydBydy,sxyd2Bydxdy);%By field component
    equil_out.Bz_fit = interpequilxy_yp(sxyBz,sxydBzdx,sxydBzdy,sxyd2Bzdxdy);%Bz (BPHI) field component
    %
else
    error('Error: this option is not yet implemented in fitequil_yp.m');
end
%



