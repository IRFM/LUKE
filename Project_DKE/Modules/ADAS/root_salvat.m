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
function y = root_salvat(R)
%
% Determine the solution of the Salvat's equations for one to four Yukawa potentials
% 
% Various atomic models. Data are saved in a substructure dft.salvat.
%
%	Input:
%
%		- R: normalized moments of the atomic charge density R(2) = 1 by construction [1,2], [1,4], [1,6], [1,8] if one, two, three or four Yukawa potentials are considered
%
%	Output: 
%
%		- y: solutions -> [A1,A2,A3,A4,lamba1,lamba2,lamba3,lamba4] or [A1,A2,A3,lamba1,lamba2,lamba3] or [A1,A2,lamba1,lamba2] or [A1,lamba1] 
%
% by Y.Peysson CEA-DRFC <yves.peysson@cea.fr>
%
jmax = length(R)/2;
y = zeros(size(R));
%
if jmax == 4%four Yukawa potentials
    %
    Y = [R(1);R(2);R(3);R(4)];
    A1 = [R(2),-R(3),R(4),-R(5);R(3),-R(4),R(5),-R(6);R(4),-R(5),R(6),-R(7);R(5),-R(6),R(7),-R(8)];
    X = A1\Y;%find 4th degree polynomial equation
    %
    y(jmax+1:end) = roots([1 -X(1) X(2) -X(3) X(4)]);%solve 4th degree polynomial equation
    %
    A2 = [y(5),y(6),y(7),y(8);1,1,1,1;1/y(5),1/y(6),1/y(7),1/y(8);1/y(5)^2,1/y(6)^2,1/y(7)^2,1/y(8)^2];
    y(1:jmax) = (A2\Y)';
    %
    if real(y(5)) > 0 && real(y(6)) > 0 && real(y(7)) > 0 && real(y(8)) > 0 && imag(y(5)) == 0 && imag(y(6)) == 0 && imag(y(7)) == 0 && imag(y(8)) == 0 
        %
        return
        %
    else
        %
        R = [R(1),R(2),R(3),R(4),R(5),R(6)];
        jmax = length(R)/2;
        y = zeros(size(R));
        %
    end
    %
end
%
if jmax == 3%three Yukawa potentials
    %
    Y = [R(1);R(2);R(3)];
    A1 = [R(2),-R(3),R(4);R(3),-R(4),R(5);R(4),-R(5),R(6)];
    X = A1\Y;%find 3rd degree polynomial equation
    %
    y(jmax+1:end) = roots([1 -X(1) X(2) -X(3)]);%solve 3rd degree polynomial equation
    %
    A2 = [y(4),y(5),y(6);1,1,1;1/y(4),1/y(5),1/y(6)];
    y(1:jmax) = (A2\Y)';
    %
    if real(y(4)) > 0 && real(y(5)) > 0  && real(y(6)) > 0 && imag(y(4)) == 0 && imag(y(5)) == 0 && imag(y(6)) == 0 
        %
        return
        %
    else
        %
        R = [R(1),R(2),R(3),R(4)];
        jmax = length(R)/2;
        y = zeros(size(R));
        %
    end
    %
end
%
if jmax == 2%two Yukawa potentials
    %{
    Y = [R(1);R(2)];
    A1 = [R(2),-R(3);R(3),-R(4)];
    X = A1\Y;%find 3rd degree polynomial equation
    %
    y(jmax+1:end) = roots([1 -X(1) X(2)]);%solve 2nd degree polynomial equation
    %
    A2 = [y(3),y(4);1,1];
    y(1:jmax) = (A2\Y)';
    %}
    y(jmax+1:end) = roots([R(4) - R(3)^2,R(3)-R(1)*R(4),R(1)*R(3)-1]);%solve 2nd degree polynomial equation
    y(1:jmax) = [(R(1) - y(4))/(y(3) - y(4)),1 - (R(1) - y(4))/(y(3) - y(4))];
    %
    if real(y(3)) > 0 && real(y(4)) > 0 && imag(y(3)) == 0 && imag(y(4)) == 0 
        %
        return
        %
    else
        %
        R = [R(1),R(2)];
        jmax = length(R)/2;
        y = zeros(size(R));
        %
    end
    %
end
%
if jmax == 1%one Yukawa potential
    %
    y(1) = R(2);
    y(2) = R(1);
    %
end
