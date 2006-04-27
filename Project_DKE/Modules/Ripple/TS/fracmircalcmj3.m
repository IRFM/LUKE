% Calcul de la fraction restant dans les miroirs en fonction de l'energie :
% E = energie initiale en keV de la particule piegee 

function f=fracmircalcmj3(E,delta,ne,zeff,a,R0,B0,NBOB);

n=5000;
rho1=rhocalcmj3(E,delta,ne,zeff,a,R0,B0,NBOB);
nume=(rho1/2)*(1+erf(sqrt(n/2)*rho1))+(1/sqrt(2*pi*n))*exp((-1)*n*rho1^2/2);
deno=(rho1/2)*(1+erf(sqrt(1/2)*rho1))+(1/sqrt(2*pi))*exp((-1)*rho1^2/2);
f=nume/deno;
