function [x,y,xypsin,psia,rpsin,xyBPHI,Rp,Zp] = accome_yp(filename,display_mode,p_opt,dispname,savename,Ns);
%
% This function reads the equilibrium parameters from file created
% by ACCOME and saved in the formatted text file "filename"
%
% by Y.PEYSSON (CEA-DRFC, yves.peysson@cea.fr)
%
if nargin < 6
    Ns = 1001;%magnetic axis recalculation supergrid factor 
end
if nargin < 5
    savename = filename;
end
if nargin < 4
    dispname = filename;
end
%
fid = fopen(filename);
%
fscanf(fid,'%s',5);
Rp = fscanf(fid,'%f',1);%major radius of magnetic axis
Zp = fscanf(fid,'%f',1);%vertical height of magnetic axis
%
fscanf(fid,'%s',6);
nxminmax = fscanf(fid,'%d',2);nx = nxminmax(2) - nxminmax(1) + 1;
nyminmax = fscanf(fid,'%d',2);ny = nyminmax(2) - nyminmax(1) + 1;
%
fscanf(fid,'%s',2);
R = fscanf(fid,'%f',nx);
x = R - Rp;
fscanf(fid,'%s',2);
Z = fscanf(fid,'%f',ny);
y = Z - Zp;
%
fscanf(fid,'%s',1);
xyBPHI = fscanf(fid,'%f',nx*ny);%Toroidal magnetic field (T)
xyBPHI = reshape(xyBPHI,nx,ny);
%
fscanf(fid,'%s',3);
xypsi = fscanf(fid,'%f',nx*ny);%Poloidal magnetic flux function
xypsi = reshape(xypsi,nx,ny);
%
fclose(fid);
%
%Automatic search of last closed magnetic flux surface and the magnetic
%flux values
%
psic = contourc(x,y,xypsi',Ns);
psi_offset = 1;
for ic = 1:Ns
    psi_level(ic) = psic(1,psi_offset);
    psi_index(ic) = psic(2,psi_offset);
%
%    psi_v = psic(:,psi_offset+1:psi_offset + psi_index(ic));
%    if (psi_v(1,1) == psi_v(1,end)) & (psi_v(2,1) == psi_v(2,end)), psi_status(ic) = 1;else psi_status(ic) = 0;end
%
    psi_offset = psi_index(ic) + psi_offset + 1;
end
%
psip = psi_level(1);%poloidal flux function value at the magnetic axis
%psia = psi_level(find(psi_status==0,1)-1);%poloidal flux function value at the last closed flux surface 
psia = psi_level(find(psi_level>=0,1)-1);%poloidal flux function value at the last closed flux surface 
%
if psip < psia, %IPHI is positive, PHI clockwise from top
    sigma = 1;
else %IPHI is negative, PHI clockwise from top
    sigma = -1;
end
%
xypsi = xypsi - psip;
psia = (psia - psip);
%
xypsin = xypsi/psia;
rpsin = linspace(0,1,nx);
%
% ACCOME sign treatment
%

