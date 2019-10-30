function ff = formfactor_yp(a,q,N,nff)
%
%	Atomic form factor
%
%	Input:
%
%       - a: normalized ion radius (2*a/alpha) where alpha is the fine structure constant and a the ion radius in Bohr radius (a0) units [1,1]
%		- q: transfered momentum in relativistic units [1,m] 
%		- N: number of bound electrons of the ion [1,1]
%       - nff: power that depends of the atomic model (3/2: Thomas-Fermi, 2: Yukawa)
%
%	Output: 
%
%		- ff: form factor (between 0 and N) [1,m]
%
% by Y.Peysson CEA-DRFC <yves.peysson@cea.fr>, K.Krol PAN-IFJ <krzysztof.krol@ifj.edu.pl> and  A.Jardin PAN-IFJ <axel.jardin@ifj.edu.pl>
%
ff = N./(1 + (q.*a).^(nff));
%
end

