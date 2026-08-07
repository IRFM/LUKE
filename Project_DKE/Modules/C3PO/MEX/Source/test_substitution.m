% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
%Script testing the stability and the fastness of the change of variable from cartesian to flux coordinates for a chosen cartesian couple and on average for a cartesian grid
%By Guillaume Brochard (CEA-DRFC, guillaume.brochard@cea.fr)

nharm = 20;%Harmonic number for the spline/pchip interpolation
x0=0.05;%Set the wanted x coordinate
y0=0.01;%Set the wanted y coordinate
x1=x0;
y1=y0;
load('EQUIL_JETliketest.mat');%Load discrete equilibrium
equil_fit = fitequil_yp(equil,1,'spline',1001,nharm);%Fit vectorial equilibrium
rayparam.dS = 1.e-4;
equilparam.ap = 0.95;

N=1;%Set the wanted number of change of variable
for i=0:N
t=cputime;%
[rho,theta] = xy2rhotheta_gb(equil_fit,rayparam,equilparam,x1,y1);
e=cputime - t;%Elapsed time for the (x,y)->(rho,theta) operation
[x1,y1] = rhotheta2xy_gb(equil_fit,rayparam,equilparam,rho,theta);
end
error = sqrt((x0-x1)*(x0-x1) + (y0-y1)*(y0-y1));%Precision of the change of variable
disp('Execution time for the chosen cartesian couple');
disp(e);
disp('Precision for the chosen cartesian couple');
disp(error);

%ngrid = 30;%Grid points number on a side of the square grid
%length = 0.02;%Grid's length

%data = test_grid_substitution(equil_fit,rayparam,equilparam,ngrid,length);%Output matrix
%disp('Mean precision for the chosen grid');
%disp(data(1));
%disp('Mean deviation for the chosen grid');
%disp(data(2));
%disp('Mean execution time for the chosen grid');
%disp(data(3));