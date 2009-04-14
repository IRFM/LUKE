function [Zbouncecoef] = bouncecoeffbuilder_dke_yp(dkeparam,dkedisplay,equilDKE,gridDKE)
%
%   Calculate bounce averaged coefficients for the 3D electron relativistic drift kinetic solver.
%
%   by Y. Peysson (CEA-DRFC) (yves.peysson@cea.fr) and J. Decker (CEA-DRFC) (joan.decker@cea.fr)
%
bounce_mode = dkeparam.bounce_mode;
dke_mode = dkeparam.dke_mode;
equil_mode = dkeparam.equil_mode;
%
display_mode = dkedisplay.display_mode;
%
mhu = gridDKE.mhu;
mhum = gridDKE.mhum;
mhup = gridDKE.mhup;
nr = gridDKE.nr;
nmhu = gridDKE.nmhu;
npn = gridDKE.npn;
nr_dke = gridDKE.nr_dke;
rdke = gridDKE.rdke;
%
%
%Bounce average coefficients
%
[xq,xqtilde,xqbar,xqhat,xqcronos,...
     XXheaviside,XXheaviside_p,XXheaviside_m,...
     Xxlambda,Xxlambda_p,Xxlambda_m,...
     XXlambda,XXRlambda_m,XXRlambda_p,...
     XXlambda_p2m1,XXRlambda_p2m1_m,XXRlambda_p2m1_p,...
     XXlambda_p2m2p2,...
     XXRlambda_b_p1p1,...
     XXlambda_b_p1m1p2,XXRlambda_b_p1m1p2,XXRlambda_b_p1m1p2_m,XXRlambda_b_p1m1p2_p,...
     XXlambda_b_p1m1,XXRlambda_b_p1m1,XXRlambda_b_p1m1_m,XXRlambda_b_p1m1_p,...
     XXRlambda_b_p1m2_m,XXRlambda_b_p1m2_p,...
     XXlambda_b_p2m2p2,XXRlambda_b_p2m2p2,XXRlambda_b_p2m2p2_m,XXRlambda_b_p2m2p2_p,...
     XXlambda_b_p3m2,XXRlambda_b_p3m2_m,XXRlambda_b_p3m2_p,...
     XXlambda_b_p2,...
     XXlambda_b_p1m3p4,XXlambda_b_p1m2p2]...
=  bounceparam_dke_yp(bounce_mode,equil_mode,display_mode,...
     mhu,mhum,mhup,npn,equilDKE);
%
sm_f = zeros(1,nr+1);
sm_T_f = zeros(1,nr+1);
%
for ir = 1:nr,
    if bounce_mode == 1,
        Zmask_f0_P{ir} = logical(XXheaviside(1,:,ir));%Passing electrons are selected
        Zmask_f0_Tm{ir} = logical(~XXheaviside(1,:,ir)) & (mhu < 0);%Trapped electrons with mhu>0 are selected                          
        Zmask_f0_Tp{ir} = logical(~XXheaviside(1,:,ir)) & (mhu > 0);%Trapped electrons with mhu<0 are selected  
        Zmask_f0_t{ir} = (Zmask_f0_P{ir} + Zmask_f0_Tp{ir}) > 0;%Passing and half of trapped electrons are selected
        Zmask_f0_t_P{ir} = Zmask_f0_P{ir}(Zmask_f0_t{ir});%For matrix symmetrization
        Zmask_f0_t_Tp{ir} = Zmask_f0_Tp{ir}(Zmask_f0_t{ir});%For matrix symmetrization  
        jmhut_min(ir) = min(find(Zmask_f0_Tm{ir})); 
        jmhut_max(ir) = max(find(Zmask_f0_Tp{ir})); 
        djmhut(ir) = (jmhut_max(ir) - jmhut_min(ir) + 1)/2;
        ns_f(ir) = djmhut(ir);
        if djmhut(ir) <= 3,
           error(['WARNING: Not enough pitch-angle grid points in the bounce region for accurate bounce-averaged calculations (increasing nmhu may solve the problem) !'])
        end
    else
        Zmask_f0_t{ir} = logical(ones(1,nmhu));%All electrons are selected
        ns_f(ir) = 0;%Number of mhu values that are removed for implicit bounce averaged calculations       
    end
%
    blocksize_f_t(ir) = (nmhu-ns_f(ir))*npn;%For supermatrix construction
    blocksize_T_f_t(ir) = (nmhu-ns_f(ir))*npn;%For supermatrix construction
end
%
if dke_mode == 1,
    for ir_dke = 1:nr_dke,
        jr2 = rdke(ir_dke);
        Zmask_g{ir_dke} = Zmask_f0_P{jr2};%Passing electrons are selected
        ns_g(ir_dke)= max(find(~Zmask_g{ir_dke})) - min(find(~Zmask_g{ir_dke})) + 1;%number of mhu values that are removed
%
        blocksize_tp(ir_dke) = nmhu*npn;    
        blocksize_g_t(ir_dke) = (nmhu-ns_g(ir_dke))*npn;
    end
%
    nMMXP_tp = max(cumsum(blocksize_tp));
    nMMH_tp = npn*nmhu*nr;
    nMMXP_g_t = max(cumsum(blocksize_g_t));
%
    MMXP_tp = [];
    MMH_tp = sparse(nMMH_tp,nMMH_tp);
    MMXP_g_t = [];
%
    sm_tp = zeros(1,nr_dke+1);
    sm_g = zeros(1,nr_dke+1);
end
%
if bounce_mode == 1,
   Zbouncecoef.Zmask_f0_P = Zmask_f0_P;
   Zbouncecoef.Zmask_f0_Tm = Zmask_f0_Tm;
   Zbouncecoef.Zmask_f0_Tp = Zmask_f0_Tp;
   Zbouncecoef.Zmask_f0_t_P = Zmask_f0_t_P;
   Zbouncecoef.Zmask_f0_t_Tp = Zmask_f0_t_Tp;
   Zbouncecoef.jmhut_min = jmhut_min;
   Zbouncecoef.jmhut_max = jmhut_max;
   Zbouncecoef.djmhut = djmhut;
else
   Zbouncecoef.Zmask_f0_P = [];
   Zbouncecoef.Zmask_f0_Tm = [];
   Zbouncecoef.Zmask_f0_Tp =[];
   Zbouncecoef.Zmask_f0_t_P = [];
   Zbouncecoef.Zmask_f0_t_Tp = [];
   Zbouncecoef.jmhut_min = [];
   Zbouncecoef.jmhut_max = [];
   Zbouncecoef.djmhut = [];  
end
%
Zbouncecoef.sm_f = sm_f;
Zbouncecoef.sm_T_f = sm_T_f;
Zbouncecoef.Zmask_f0_t = Zmask_f0_t;
Zbouncecoef.ns_f = ns_f;
%
if dke_mode == 1,
    Zbouncecoef.Zmask_g = Zmask_g;%Passing electrons are selected
    Zbouncecoef.ns_g = ns_g;%number of mhu values that are removed
%
    Zbouncecoef.blocksize_tp = blocksize_tp;    
    Zbouncecoef.blocksize_g_t = blocksize_g_t;
%
    Zbouncecoef.nMMXP_tp = nMMXP_tp;
    Zbouncecoef.nMMH_tp = nMMH_tp;
    Zbouncecoef.nMMXP_g_t = nMMXP_g_t;
%
    Zbouncecoef.MMXP_tp = MMXP_tp;
    Zbouncecoef.MMH_tp = MMH_tp;
    Zbouncecoef.MMXP_g_t = MMXP_g_t;
%
    Zbouncecoef.sm_tp = sm_tp;
    Zbouncecoef.sm_g = sm_g;
else
    Zbouncecoef.Zmask_g = [];
    Zbouncecoef.ns_g = [];
%
    Zbouncecoef.blocksize_tp = [];    
    Zbouncecoef.blocksize_g_t = [];
%
    Zbouncecoef.nMMXP_tp = [];
    Zbouncecoef.nMMH_tp = [];
    Zbouncecoef.nMMXP_g_t = [];
%
    Zbouncecoef.MMXP_tp = [];
    Zbouncecoef.MMH_tp = [];
    Zbouncecoef.MMXP_g_t = [];
%
    Zbouncecoef.sm_tp = [];
    Zbouncecoef.sm_g = [];
end
%
Zbouncecoef.blocksize_f_t = blocksize_f_t;
Zbouncecoef.blocksize_T_f_t = blocksize_T_f_t;
%
Zbouncecoef.xq = xq;
Zbouncecoef.xqtilde = xqtilde;
Zbouncecoef.xqbar = xqbar;
Zbouncecoef.xqhat = xqhat;
Zbouncecoef.xqcronos = xqcronos;
%
Zbouncecoef.XXheaviside = XXheaviside;
Zbouncecoef.XXheaviside_p = XXheaviside_p;
Zbouncecoef.XXheaviside_m = XXheaviside_m;
Zbouncecoef.Xxlambda = Xxlambda;
Zbouncecoef.Xxlambda_p = Xxlambda_p;
Zbouncecoef.Xxlambda_m = Xxlambda_m;
Zbouncecoef.XXlambda = XXlambda;
Zbouncecoef.XXRlambda_m = XXRlambda_m;
Zbouncecoef.XXRlambda_p = XXRlambda_p;
Zbouncecoef.XXlambda_p2m1 = XXlambda_p2m1;
Zbouncecoef.XXRlambda_p2m1_m = XXRlambda_p2m1_m;
Zbouncecoef.XXRlambda_p2m1_p = XXRlambda_p2m1_p;
Zbouncecoef.XXlambda_p2m2p2 = XXlambda_p2m2p2;
Zbouncecoef.XXRlambda_b_p1p1 = XXRlambda_b_p1p1;
Zbouncecoef.XXlambda_b_p1m1p2 = XXlambda_b_p1m1p2;
Zbouncecoef.XXRlambda_b_p1m1p2 = XXRlambda_b_p1m1p2;
Zbouncecoef.XXRlambda_b_p1m1p2_m = XXRlambda_b_p1m1p2_m;
Zbouncecoef.XXRlambda_b_p1m1p2_p = XXRlambda_b_p1m1p2_p;
Zbouncecoef.XXlambda_b_p1m1 = XXlambda_b_p1m1;
Zbouncecoef.XXRlambda_b_p1m1 = XXRlambda_b_p1m1;
Zbouncecoef.XXRlambda_b_p1m1_m = XXRlambda_b_p1m1_m;
Zbouncecoef.XXRlambda_b_p1m1_p = XXRlambda_b_p1m1_p;
Zbouncecoef.XXRlambda_b_p1m2_m = XXRlambda_b_p1m2_m;
Zbouncecoef.XXRlambda_b_p1m2_p = XXRlambda_b_p1m2_p;
Zbouncecoef.XXlambda_b_p2m2p2 = XXlambda_b_p2m2p2;
Zbouncecoef.XXRlambda_b_p2m2p2 = XXRlambda_b_p2m2p2;
Zbouncecoef.XXRlambda_b_p2m2p2_m = XXRlambda_b_p2m2p2_m;
Zbouncecoef.XXRlambda_b_p2m2p2_p = XXRlambda_b_p2m2p2_p;
Zbouncecoef.XXlambda_b_p3m2 = XXlambda_b_p3m2;
Zbouncecoef.XXRlambda_b_p3m2_m = XXRlambda_b_p3m2_m;
Zbouncecoef.XXRlambda_b_p3m2_p = XXRlambda_b_p3m2_p;
Zbouncecoef.XXlambda_b_p2 = XXlambda_b_p2;
Zbouncecoef.XXlambda_b_p1m3p4 = XXlambda_b_p1m3p4;
Zbouncecoef.XXlambda_b_p1m2p2 = XXlambda_b_p1m2p2;








