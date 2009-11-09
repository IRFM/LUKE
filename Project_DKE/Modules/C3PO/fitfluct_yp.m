function [fluct_out] = fitfluct_yp(fluct_in,mode,method,ngrid)
%
% Build vectorial plasma fluctuation profiles from its numerical counterpart
% Two operating modes :
% 1) Spline-Fourier description for (psi,theta) magnetic equilibrium (HELENA for example)
%
%    1-D: use interp1.m MatLab built-in function (Hermite polynomials (pchip), spline, bi-cubic, linear,  nearest,...)
%    2-D: use Fourier series expansion for the poloidal dependence and the
%    interp1.m for the Fourier series coefficients (Hermite polynomials (pchip), spline, bi-cubic, linear,
%    nearest,...)
%
% 2) Spline-Spline description for (x,y) magnetic equilibrium (EFIT for example)
%
%    1-D: use interp1.m MatLab built-in function (Hermite polynomials (pchip), spline, bi-cubic, linear, nearest,...)
%    2-D: use interp1.m for the x-direction and the interp1.m again for the coefficients of the 
%    previous spline (Hermite polynomials (pchip), spline, bi-cubic, linear, nearest,...)
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
if nargin == 1, 
    mode = 1;%Spline-Fourier case
    method = 'pchip';
    ngrid = 2000;
end
if nargin == 2, 
    method = 'pchip';
    ngrid = 2000;
end
if nargin == 3, 
    ngrid = 2000;  
end
%
fluct_out.id = fluct_in.id;
fluct_out.method = method;
%
fluct_out.ns0 = fluct_in.ns0;
fluct_out.xreset0 = fluct_in.xreset0;
fluct_out.nkperproots = fluct_in.nkperproots; 
fluct_out.betagridsize = fluct_in.betagridsize;
fluct_out.dtfac = fluct_in.dtfac;
%
fluct_out.dfcl = fluct_in.dfcl;
fluct_out.fnkperpspec = fluct_in.fnkperpspec;
fluct_out.mffcl = fluct_in.mffcl;
fluct_out.fbkperpspec = fluct_in.fbkperpspec;
%
if mode == 1,    
%
%Resampling on a finer mesh close to psi = 0 before Hermite-Fourier calculations. 
%
   srho = linspace(0,1,ngrid).^2;   
%
   fluct_out.fn_fit = interpequilpt_yp(method,interp1(fluct_in.prho,fluct_in.pfn,srho,method),srho);
   fluct_out.fb_fit = interpequilpt_yp(method,interp1(fluct_in.prho,fluct_in.pfb,srho,method),srho);
else

    
    
end
%



