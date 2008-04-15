%
%   This script generates the data file of an ideal circular equilibrium based on
%   equilibrium profile parameters
%
%   By J. Decker <jodecker@alum.mit.edu> and Y. Peysson <yves.peysson@cea.fr>
%   Created Feb. 17, 2004
%
clear all
close all
%
helmex77param.id = 'JETh77';% scenario identification
%
helmex77param.id_path = '';%For all paths used by DKE solver
helmex77param.path_path = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
% Equilibrium parameters
%
helmex77param.ap_guess = 0.9;%  Plasma minor radius on LFS midplane (m)
helmex77param.Rp_guess = 3.0;%  Plasma major radius on axis (m)
helmex77param.Zp_guess = 0;%  Global plasma vertical shift (m)
%
helmex77param.xpoint(1) = 1.687;%Vertical position of the top X point
helmex77param.xpoint(2) = 0.466;%Horizontal position of the top X point
helmex77param.xpoint(3) = 0;%Angle between the separatrix and the horizontal plane for the top X point (degree)
helmex77param.xpoint(4) = 0;%Angle between the separatrix and the horizontal plane for the top X point (degree)
helmex77param.xpoint(5) = 2.001;%Vertical position of the bottom X point (always positive value)
helmex77param.xpoint(6) = 0.568;%Horizontal position of the bottom X point
helmex77param.xpoint(7) = 22.46;%Angle between the separatrix and the horizontal plane for the bottom X point (degree)
helmex77param.xpoint(8) = 67.92;%Angle between the separatrix and the horizontal plane for the bottom X point (degree)
%
helmex77param.npsi_guess = 201;%For initial profile calculations
helmex77param.ntheta_guess = 201;%Number of poloidal positions for the guessed separatrix
helmex77param.npsi = 101;%ONLY 101 radial profile grid points for HELMEX77
helmex77param.ntheta = 65;%ONLY 65 poloidal grid points for HELMEX77
%
helmex77param.Ip = 2;%  Plasma current (MA)  
%
helmex77param.qmin = 1;%  Safety factor q0 at plasma center
helmex77param.eq = 3;%  Exponent for q radial profile (q = (qmax - qmin)*(r/a).^eq + qmin, qmax calaculated by the Ampere's theorem at the plasma edge with a circular plasma cross-section)
helmex77param.qopt = 1;%Option for q profile. (0): constant (default, uniform current, psi=rho^2), (1): from qmin and eq 
%
helmex77param.Bt = 3.5;%  Toroidal magnetic field on the magnetic axis (T) 
%
helmex77param.Zi =  [1,1,1,6];%  Ion types: (1) H/D/T, (2) He, ..., (6) C [1,p] (WARNING: Zi must be [1,1,1,imp1,imp2] for hydrogen plasmas)
helmex77param.mi =  [1,2,3,12];%  Ion mass (uma) [1,p] (WARNING: Zi must be [1,2,3,mimp1,mimp2] for hydrogen plasmas)
helmex77param.fi =  [0,1,0];%  Hydrogen isotopic fraction (H/D/T) [1,3] (WARNING: only used when hydrogen plasmas are considered)
%
helmex77param.Te0 = 5;%  Core electron temperature (keV)
helmex77param.dTea = 0.1;%  Edge electron temperature parameter
helmex77param.eTe1 = 2;%  Exponent #1 for Te profile 
helmex77param.eTe2 = 2;%  Exponent #1 for Te profile 
%
helmex77param.ne0 = 2.0e19;%  Core electron density (m-3)
helmex77param.dnea = 0.01;%  Edge electron density parameter
helmex77param.ene1 = 2;%  Exponent #1 for ne profile 
helmex77param.ene2 = 0.5;%  Exponent #2 for ne profile
%
helmex77param.Ti0 = 2;%  Core ion temperature (keV)
helmex77param.dTia = 0.1;%  Edge ion temperature (keV)
helmex77param.eTi1 = 2;%  Exponent #1 for Ti profile
helmex77param.eTi2 = 2;%  Exponent #1 for Ti profile
%
helmex77param.Zeff0 = 1.5;%  Core effective charge (a.u.)
helmex77param.Zeffa = 1.5;%  Edge effective charge (a.u.)
helmex77param.eZeff = 0;%  Define the slope at the radial point where the derivative is maximum (must be >> 1)
helmex77param.xZeff = 0.5;%Radial normalized position at which the derivative is maximum
%
%**************************************************************************************************
%
%
[equil] = make_equil_helmex77_yp(helmex77param,1);
%
eval(['save EQUIL_',helmex77param.id,'.mat equil']);




