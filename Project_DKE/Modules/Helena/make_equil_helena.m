%
%   This script generates a magnetic equilibrium for LUKE using HELENA
%
%
%   Y. Peysson (CEA-DRFC) <yves.peysson@cea.fr> and J. Decker (CEA-DRFC) <joan.decker@cea.fr>
%
clear all
close all
%
dkepath = path_LUKE_LOCAL;
if ~strcmp(dkepath.path_id,'LOCAL'),
    dkepath.mex = [dkepath.temppath,'/MEX'];    
	mex_compile_luke(dkepath.luke_root,dkepath.mex);
end
setpath_luke_jd(dkepath.luke_root,dkepath);
%
id = 'test_helena';% scenario identification
%
% Separatrix shape parameters (3 methods)
%
sepparam.mode = 3;%Operating mode: (1) create separatrix from ellipticity, triangularity, ..., (2) -> create separatrix from two X points, (3) -> load separatrix from a text file
%
if sepparam.mode == 1,%create separatrix from ellipticity, triangularity
%
	sepparam.as = 1;%Geometrical minor radius of the separatrix (@ poloidal angle = 0 and pi) (m)
    sepparam.Rs = 2.39;%Geometrical major radius of the separatrix (@ poloidal angle = 0 and pi) (m)
    sepparam.Zs = 0.00;%Global plasma vertical shift (@ poloidal angle = 0 and pi) (m)
%    
    sepparam.ellipticity = 1.5;%Plasma ellipticity (1.0: circular plasma)
    sepparam.triangularity= 0.0;%Plasma triangularity (0.0: circular plasma)
    sepparam.quadrangularity = 0.0;%Plasma quadrangularity (0.0: circular plasma)
%
    sepparam.ntheta = 129;%Number of poloidal positions for the guessed separatrix
elseif sepparam.mode == 2,%create separatrix from two X points
%
    sepparam.as = 0.2;%Geometrical minor radius of the separatrix (@ poloidal angle = 0 and pi) (m)
    sepparam.Rs = 0.547;%Geometrical major radius of the separatrix (@ poloidal angle = 0 and pi) (m)
    sepparam.Zs = 0.03;%Global plasma vertical shift (@ poloidal angle = 0 and pi) (m)
%
    sepparam.xpoint(1) = 1.06;%Vertical position of the top X point
    sepparam.xpoint(2) = 0.05;%Horizontal position of the top X point
    sepparam.xpoint(3) = 0;%Angle between the separatrix and the horizontal plane for the top X point (degree)
    sepparam.xpoint(4) = 0;%Angle between the separatrix and the horizontal plane for the top X point (degree)
    sepparam.xpoint(5) = 1.68;%Vertical position of the bottom X point (always positive value)
    sepparam.xpoint(6) = 0.30;%Horizontal position of the bottom X point
    sepparam.xpoint(7) = 30.00;%Angle between the separatrix and the horizontal plane for the bottom X point (degree)
    sepparam.xpoint(8) = 80;%Angle between the separatrix and the horizontal plane for the bottom X point (degree)
%
    sepparam.ntheta = 129;%Number of poloidal positions for the guessed separatrix
%
elseif sepparam.mode == 3,%load separatrix from a text file (tabs delimited text file: theta,R,Z)
%
%WARNING: the separatrix is defined according to the follwing rule: as = R(theta = 0) - Rs = Rs - R(theta = pi),
%while Zs = Z(theta = 0) = Z(theta = pi). Furthermore, theta(1) = 0, theta(end)  = 2*pi, R(1) = R(end), Z(1) = Z(end)
%
    sepparam.filename = 'testsep.txt';
end
%
% Current and pressure profiles parameters
%
profparam.nr = 101;%Number of radial points for current and pressure profiles
profparam.gridtype = 1;%Grid type for profile definition: (0) -> equidistant points in poloidal psi grid, (1) -> equidistant points in sqrt(poloidal psi)~rho grid but not exactly
%
profparam.j0 = 0.6;%Core toroidal curent density (MA/m2) [1,1]
profparam.ja = 0;%Edge toroidal curent density (MA/m2) [1,1]
profparam.ej = 2;%Exponent for j profile -> j(psin) = (j0-ja)*(1-(psin)^2)^ej + ja) [1,1]
%
profparam.Zi = [1,1,1,6];%Ion types: (1) H/D/T, (2) He, ..., (6) C [1,p] (WARNING: Zi must be [1,1,1,imp1,imp2] for hydrogen plasmas)
profparam.mi = [1,2,3,12];%Ion mass (uma) [1,p] (WARNING: Zi must be [1,2,3,mimp1,mimp2] for hydrogen plasmas)
profparam.fi = [0,1,0];%Hydrogen isotopic fraction (H/D/T) [1,3] (WARNING: only used when hydrogen plasmas are considered)
%
profparam.Te0 = 4.7;%Core electron temperature (keV), Te(x) = (Te0-Tea)*(1-x^eTe1)^eTe2 + Tea
profparam.Tea = 0.47;%Edge electron temperature parameter 
profparam.eTe1 = 2;%Exponent #1 for Te profile 
profparam.eTe2 = 1.1;%Exponent #2 for Te profile 
%
profparam.ne0 = 2.0e+19;%Core electron density (m-3), ne(x) = (ne0-nea)*(1-x^ene1)^ene2 + nea
profparam.nea = 0.48e+19;%Edge electron density parameter
profparam.ene1 = 2;%Exponent #1 for ne profile 
profparam.ene2 = 1.3;%Exponent #2 for ne profile
%
profparam.Ti0 = 3.0;%Core ion temperature (keV), Ti(x) = (Ti0-Tia)*(1-x^eTi1)^eTi2 + Tia
profparam.Tia = 0.3;%Edge ion temperature (keV)
profparam.eTi1 = 2;%Exponent #1 for Ti profile
profparam.eTi2 = 1.1;%Exponent #2 for Ti profile
%
profparam.Zeff0 = 1.5;%Core effective charge (a.u.)
profparam.Zeffa = 1.5;%Edge effective charge (a.u.)
profparam.eZeff = 10;%Define the slope at the radial point where the derivative is maximum (must be >> 1)
profparam.xZeff = 0.5;%Radial normalized position at which the derivative is maximum
%
% HELENA control parameters
%
helparam.shape.mfm = 128;%Number of harmonics in Fourier series of the separatrix
helparam.shape.mharm = 64;%number of harmonics for grid generation (if not defined, MFM/2)
helparam.shape.imesh = 0;%(0) -> equidistant radial grid, (2) -> Gaussian distribution of radial grid
%helparam.shape.xr1 = 0.98;%position of radial grid accumulation (used if imesh = 2)
%helparam.shape.sig1 = 0.05;%width of radial grid accumulation (used if imesh = 2)
%
helparam.phys.eps = 0.33;%inverse aspect ratio a/R @ Rvac
helparam.phys.B = 2.274;%mu0 p'(0)/FF'(0)
%helparam.phys.betap = 0;%poloidal beta; betap has precedence over B (if icur not equal to zero)
%helparam.phys.alfa = 1.708;%normalised poloidal flux, a^2B0/psi1 
helparam.phys.xiab = 0.5;%normalised total current = mu0I / (a B) ; precedence over helparam.phys.alfa
%helparam.phys.q95 = 3;%safety factor at r/a = 0.95. Has precedence over helparam.phys.xiab and helparam.phys.alfa
helparam.phys.Bvac = 3.65;%toroidal vacuum magnetic field @ Rvac [T]
%
helparam.num.nr = 101;%number of radial grid points
helparam.num.np = 101;%number of poloidal grid points
helparam.num.nrmap = 101;%number of radial grid points in mapping to flux surface grid
helparam.num.npmap = 65;%number of poloidal grid points in mapping 
helparam.num.nchi = 64;%number of poloidal grid points in mapping 
helparam.num.nrcur = 101;%number of radial grid points for iteration current profile
helparam.num.npcur = 55;%number of poloidal grid points 
helparam.num.errcur = 1e-4;%error allowed at end of iteration current profile
helparam.num.nmesh = 5;%maximum number of iterations current profile
helparam.num.niter = 5;%maximum number of iterations
helparam.num.amix = 0.0;%parameter for control of main iteration of Grad-Shafranov equation
%
% Create HELENA input file and run helena
%
[equil,separatrix,profile] = run_helena_yp(sepparam,profparam,helparam,dkepath);%Calculation of the magnetic equilibrium
return
%
if ~isempty(equil),%Load HELENA output file and build corresponding LUKE magnetic equilibrium structure
    equil.id = filename;
    save(['EQUIL_',filename,'.mat'],'equil');
else
    error('HELENA magnetic equilibrium solver has not converged correctly.');
end


