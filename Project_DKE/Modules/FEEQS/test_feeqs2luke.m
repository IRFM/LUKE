%
Ip = 15e6;
R0 = 6.2;
a  = 2;
K  = 1.8;
theta = linspace(0,2.*pi);
LCFS = cat(1,R0 + a .* cos(theta),a .* K .* sin(theta)).';
gamma = 1.2;
beta  = 0.8;
plist = [];
plist.other = true;
plist.RB0 = 6.2 * 5.3; 
plist.verbose = 0;
plist.plotonoff = false;
plist.twoD_data     = true;  % can  be recomputed in inverse grid on  demand
plist.other     = true;  % can  be recomputed in inverse grid on  demand
plist.psi_bd = 0;
plist.p = 3;   % is sufficient for RAPTOR ? provide  smoother 2D grid
plist.match_li_beta = true;
%
feeqs2luke(LCFS,Ip,gamma,beta,1.2,plist);
%
