function [R0,xBmin,xRBmin,xBTBmin,xq,xqtilde,xqbar,xqhat,...
xmhu0T2,XXheaviside,...
Xxlambda,Xxlambda_p,Xxlambda_m,...
XXlambda,XXRlambda_m,XXRlambda_p,...
XXRlambda_p2m1_m,XXRlambda_p2m1_p,...
XXRlambda_b_p1p1,...
XXlambda_b_p1m1p2,XXRlambda_b_p1m1p2,XXRlambda_b_p1m1p2_m,XXRlambda_b_p1m1p2_p,...
XXRlambda_b_p1m1,XXRlambda_b_p1m1_m,XXRlambda_b_p1m1_p,...
XXRlambda_b_p1m2_m,XXRlambda_b_p1m2_p,...
XXlambda_b_p2m2p2,XXRlambda_b_p2m2p2_m,XXRlambda_b_p2m2p2_p,...
XXRlambda_b_p3m2_m,XXRlambda_b_p3m2_p,...
XXlambda_p2p0,XXlambda_p2p0_p,XXlambda_p2p0_m] = bounceparam_dke_yp(tokamak,bounce_mode,xia,delta,Nq,mhu,mhum,mhup,Xmhu,Xmhum,Xmhup)
%
%by Y.Peysson <yves.peysson@cea.fr> (CEA-DRFC) and J. Decker <jodecker@mit.edu> (MIT/RLE)
%
nr = length(xia);
[npn,nmhu] = size(Xmhu);
%
if bounce_mode == 1,	
	[R0,xBmin,xRBmin,xBTBmin,xq,xqtilde,xqbar,xqhat,xylambda,xylambda_p2m1,xylambda_b_p1p1,xylambda_b_p1m1p2,xylambda_b_p1m1,xylambda_b_p1m2,xylambda_b_p2m2p2,xylambda_b_p3m2,xylambda_p2p0,xymaskT,xmhu0T2] = bounce_dke_jd(tokamak,xia,mhu);
	[R0,xBmin,xRBmin,xBTBmin,xq,xqtilde,xqbar,xqhat,xylambda_p,xylambda_p2m1_p,xylambda_b_p1p1_p,xylambda_b_p1m1p2_p,xylambda_b_p1m1_p,xylambda_b_p1m2_p,xylambda_b_p2m2p2_p,xylambda_b_p3m2_p,xylambda_p2p0_p,xymaskTp,xmhu0T2p] = bounce_dke_jd(tokamak,xia,mhup);
	[R0,xBmin,xRBmin,xBTBmin,xq,xqtilde,xqbar,xqhat,xylambda_m,xylambda_p2m1_m,xylambda_b_p1p1_m,xylambda_b_p1m1p2_m,xylambda_b_p1m1_m,xylambda_b_p1m2_m,xylambda_b_p2m2p2_m,xylambda_b_p3m2_m,xylambda_p2p0_m,xymaskTm,xmhu0T2m] = bounce_dke_jd(tokamak,xia,mhum);
%
	XXheaviside = repmat(reshape(~xymaskT',[1,nmhu,nr]),[npn,1,1]);%For selecting the circulating population only
%
	XXlambda = repmat(reshape(xylambda',[1,nmhu,nr]),[npn,1,1]);
	XXlambda_p = repmat(reshape(xylambda_p',[1,nmhu,nr]),[npn,1,1]);
	XXlambda_m = repmat(reshape(xylambda_m',[1,nmhu,nr]),[npn,1,1]);
	XXRlambda_p = XXlambda_p./XXlambda;
	XXRlambda_m = XXlambda_m./XXlambda;	
%
	Xxlambda = xylambda';
	Xxlambda_p = xylambda_p';
	Xxlambda_m = xylambda_m'; 
%
%Fokker-Planck terms
%
	XXlambda_p2m1_p = repmat(reshape(xylambda_p2m1_p',[1,nmhu,nr]),[npn,1,1]);
	XXlambda_p2m1_m = repmat(reshape(xylambda_p2m1_m',[1,nmhu,nr]),[npn,1,1]);
	XXRlambda_p2m1_p = XXlambda_p2m1_p./XXlambda_p;%***********Check that it is correct to divide by XXlambda_p instead of XXlambda ************
	XXRlambda_p2m1_m = XXlambda_p2m1_m./XXlambda_m;%***********Check that it is correct to divide by XXlambda_m instead of XXlambda ************
%
	XXlambda_b_p1p1 = repmat(reshape(xylambda_b_p1p1',[1,nmhu,nr]),[npn,1,1]);
	XXRlambda_b_p1p1 = XXlambda_b_p1p1./XXlambda;	
%
	XXlambda_b_p1m1p2 = repmat(reshape(xylambda_b_p1m1p2',[1,nmhu,nr]),[npn,1,1]);
	XXlambda_b_p1m1p2_p = repmat(reshape(xylambda_b_p1m1p2_p',[1,nmhu,nr]),[npn,1,1]);
	XXlambda_b_p1m1p2_m = repmat(reshape(xylambda_b_p1m1p2_m',[1,nmhu,nr]),[npn,1,1]);
	XXRlambda_b_p1m1p2 = XXlambda_b_p1m1p2./XXlambda;	
	XXRlambda_b_p1m1p2_p = XXlambda_b_p1m1p2_p./XXlambda_p;%*********Idem*********
	XXRlambda_b_p1m1p2_m = XXlambda_b_p1m1p2_m./XXlambda_m;%*********Idem*********
%
%Drift kinetic terms
%
	XXlambda_b_p1m1 = repmat(reshape(xylambda_b_p1m1',[1,nmhu,nr]),[npn,1,1]);
	XXlambda_b_p1m1_p = repmat(reshape(xylambda_b_p1m1_p',[1,nmhu,nr]),[npn,1,1]);
	XXlambda_b_p1m1_m = repmat(reshape(xylambda_b_p1m1_m',[1,nmhu,nr]),[npn,1,1]);
	XXRlambda_b_p1m1 = XXlambda_b_p1m1./XXlambda;%*********Idem*********
	XXRlambda_b_p1m1_p = XXlambda_b_p1m1_p./XXlambda_p;%*********Idem*********
	XXRlambda_b_p1m1_m = XXlambda_b_p1m1_m./XXlambda_m;%*********Idem*********
%
	XXlambda_b_p1m2 = repmat(reshape(xylambda_b_p1m2',[1,nmhu,nr]),[npn,1,1]);
	XXlambda_b_p1m2_p = repmat(reshape(xylambda_b_p1m2_p',[1,nmhu,nr]),[npn,1,1]);
	XXlambda_b_p1m2_m = repmat(reshape(xylambda_b_p1m2_m',[1,nmhu,nr]),[npn,1,1]);
	XXRlambda_b_p1m2_p = XXlambda_b_p1m2_p./XXlambda_p;%*********Idem*********
	XXRlambda_b_p1m2_m = XXlambda_b_p1m2_m./XXlambda_m;%*********Idem*********
%
	XXlambda_b_p2m2p2 = repmat(reshape(xylambda_b_p2m2p2',[1,nmhu,nr]),[npn,1,1]);
	XXlambda_b_p2m2p2_p = repmat(reshape(xylambda_b_p2m2p2_p',[1,nmhu,nr]),[npn,1,1]);
	XXlambda_b_p2m2p2_m = repmat(reshape(xylambda_b_p2m2p2_m',[1,nmhu,nr]),[npn,1,1]);
	XXRlambda_b_p2m2p2_p = XXlambda_b_p2m2p2_p./XXlambda_p;%*********Idem*********
	XXRlambda_b_p2m2p2_m = XXlambda_b_p2m2p2_m./XXlambda_m;%*********Idem*********
%
	XXlambda_b_p3m2 = repmat(reshape(xylambda_b_p3m2',[1,nmhu,nr]),[npn,1,1]);
	XXlambda_b_p3m2_p = repmat(reshape(xylambda_b_p3m2_p',[1,nmhu,nr]),[npn,1,1]);
	XXlambda_b_p3m2_m = repmat(reshape(xylambda_b_p3m2_m',[1,nmhu,nr]),[npn,1,1]);
	XXRlambda_b_p3m2_p = XXlambda_b_p3m2_p./XXlambda_p;%*********Idem*********
	XXRlambda_b_p3m2_m = XXlambda_b_p3m2_m./XXlambda_m;%*********Idem*********
%
	XXlambda_p2p0 = repmat(reshape(xylambda_p2p0',[1,nmhu,nr]),[npn,1,1]);
   XXlambda_p2p0_p = repmat(reshape(xylambda_p2p0_p',[1,nmhu,nr]),[npn,1,1]);
   XXlambda_p2p0_m = repmat(reshape(xylambda_p2p0_m',[1,nmhu,nr]),[npn,1,1]);
%
%Non-axisymmetric corrections as done by M. Ju et al. in Phys. Plasmas, 9 (2002) 493 (to be used only with FP calculations, and tested for TORE SUPRA only)
%may be inserted here. Work to be done...
%
else  
   R0 = 1;
   xBmin = ones(1,nr);
   xRBmin = ones(1,nr);
   xBTBmin = ones(1,nr);
   xq = ones(1,nr);
   xqtilde = ones(1,nr);
   xqbar = ones(1,nr);
   xqhat = ones(1,nr);
%
	xmhu0T2 = zeros(1,nr);
	XXheaviside = ones(npn,nmhu,nr);
%
	XXlambda = ones(npn,nmhu,nr);
	Xxlambda = ones(nmhu,nr);
	Xxlambda_p = ones(nmhu,nr);
	Xxlambda_m = ones(nmhu,nr);
%	
	XXRlambda_m = ones(npn,nmhu,nr);
	XXRlambda_p = ones(npn,nmhu,nr);	
%
	XXlambda_p2m1_p = ones(npn,nmhu,nr);
	XXlambda_p2m1_m = ones(npn,nmhu,nr);
	XXRlambda_p2m1_p = ones(npn,nmhu,nr);
	XXRlambda_p2m1_m = ones(npn,nmhu,nr);
%
	XXRlambda_b_p1p1 = ones(npn,nmhu,nr);
%
	XXlambda_b_p1m1p2 = ones(npn,nmhu,nr);
	XXlambda_b_p1m1p2_p = ones(npn,nmhu,nr);
	XXlambda_b_p1m1p2_m = ones(npn,nmhu,nr);
	XXRlambda_b_p1m1p2 = ones(npn,nmhu,nr);
	XXRlambda_b_p1m1p2_p = ones(npn,nmhu,nr);
	XXRlambda_b_p1m1p2_m = ones(npn,nmhu,nr);
%
	XXlambda_b_p1m1 = ones(npn,nmhu,nr);
	XXlambda_b_p1m1_p = ones(npn,nmhu,nr);
	XXlambda_b_p1m1_m = ones(npn,nmhu,nr);
	XXRlambda_b_p1m1 = ones(npn,nmhu,nr);
	XXRlambda_b_p1m1_p = ones(npn,nmhu,nr);
	XXRlambda_b_p1m1_m = ones(npn,nmhu,nr);
%
	XXlambda_b_p1m2 = ones(npn,nmhu,nr);
	XXlambda_b_p1m2_p = ones(npn,nmhu,nr);
	XXlambda_b_p1m2_m = ones(npn,nmhu,nr);
	XXRlambda_b_p1m2_p = ones(npn,nmhu,nr);
	XXRlambda_b_p1m2_m = ones(npn,nmhu,nr);
%	
	XXlambda_b_p2m2p2 = ones(npn,nmhu,nr);
	XXlambda_b_p2m2p2_p = ones(npn,nmhu,nr);
	XXlambda_b_p2m2p2_m = ones(npn,nmhu,nr);
	XXRlambda_b_p2m2p2_p = ones(npn,nmhu,nr);
	XXRlambda_b_p2m2p2_m = ones(npn,nmhu,nr);		
%
	XXlambda_b_p3m2 = ones(npn,nmhu,nr);
	XXlambda_b_p3m2_p = ones(npn,nmhu,nr);
	XXlambda_b_p3m2_m = ones(npn,nmhu,nr);
	XXRlambda_b_p3m2_p = ones(npn,nmhu,nr);
	XXRlambda_b_p3m2_m = ones(npn,nmhu,nr);
%
	XXlambda_p2p0 = ones(npn,nmhu,nr);
	XXlambda_p2p0_p = ones(npn,nmhu,nr);
	XXlambda_p2p0_m = ones(npn,nmhu,nr);
end

