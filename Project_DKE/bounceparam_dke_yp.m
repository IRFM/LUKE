function [xmhubounce2,...
Xxlambda,Xxlambdap,Xxlambdam,...
XXlambda,XXRlambdam,XXRlambdap,...
XXRlambda_p2m1_m,XXRlambda_p2m1_p,...
XXsssl,XXssslm,XXssslp,...
XXheaviside,...
XXsstar,...
XXlambda_p2p0,XXlambda_p2p0_p,XXlambda_p2p0_m] = bounceparam_dke_yp(tokamak,bounce_mode,xia,delta,Nq,mhu,mhum,mhup,Xmhu,Xmhum,Xmhup)
%
%by Y.Peysson CEA-DRFC 05/02/2003 <yves.peysson@cea.fr>
%
% modified j.d. 11/26/03 for arbitrary geometry
%
% Note: ripple corrections not yet revisited. 
%
nr = length(xia);
[npn,nmhu] = size(Xmhu);
%
%Xmhu2 = Xmhu.^2;
%Xmhu2m = Xmhum.^2;
%Xmhu2p = Xmhup.^2;
%
if bounce_mode == 1,
	[xylambda,xylambda_p2m1,xylambda_p2p0,xysstar,xymaskT,xmhubounce2] = bounce_dke_jd(tokamak,xia,mhu);
	[xylambdap,xylambda_p2m1_p,xylambda_p2p0_p,xysstarp,xymaskTp] = bounce_dke_jd(tokamak,xia,mhup);
	[xylambdam,xylambda_p2m1_m,xylambda_p2p0_m,xysstarm,xymaskTm] = bounce_dke_jd(tokamak,xia,mhum);
%
	XXlambda = repmat(reshape(xylambda',[1,nmhu,nr]),[npn,1,1]);
    XXlambdap = repmat(reshape(xylambdap',[1,nmhu,nr]),[npn,1,1]);
    XXlambdam = repmat(reshape(xylambdam',[1,nmhu,nr]),[npn,1,1]);
%
	XXRlambdap = XXlambdap./XXlambda;
	XXRlambdam = XXlambdam./XXlambda;
%	
	XXheaviside = repmat(reshape(~xymaskT',[1,nmhu,nr]),[npn,1,1]);
%    XXheavisidep = repmat(reshape(~xymaskTp',[1,nmhu,nr]),[npn,1,1]);
%    XXheavisidem = repmat(reshape(~xymaskTm',[1,nmhu,nr]),[npn,1,1]);
%
	Xxlambda = xylambda';
	Xxlambdap = xylambdap';
	Xxlambdam = xylambdam'; 
%
	XXsstar = repmat(reshape(xysstar',[1,nmhu,nr]),[npn,1,1]);%s*
    XXsstarp = repmat(reshape(xysstarp',[1,nmhu,nr]),[npn,1,1]);
    XXsstarm = repmat(reshape(xysstarm',[1,nmhu,nr]),[npn,1,1]);
%
	XXsssl = XXsstar./XXlambda;
	XXssslp = XXsstarp./XXlambdap;
	XXssslm = XXsstarm./XXlambdam;
%
%----- lambda_p2m1 (= 1-delta/mhu0^2) -----
%
%	XXlambda_p2m1 = repmat(reshape(xylambda_p2m1',[1,nmhu,nr]),[npn,1,1]);
    XXlambda_p2m1_p = repmat(reshape(xylambda_p2m1_p',[1,nmhu,nr]),[npn,1,1]);
    XXlambda_p2m1_m = repmat(reshape(xylambda_p2m1_m',[1,nmhu,nr]),[npn,1,1]);
%	
	XXRlambda_p2m1_p = XXlambda_p2m1_p./XXlambdap;
	XXRlambda_p2m1_m = XXlambda_p2m1_m./XXlambdam;
%
%---------------- s*_tilde ----------------
%
	XXlambda_p2p0 = repmat(reshape(xylambda_p2p0',[1,nmhu,nr]),[npn,1,1]);
    XXlambda_p2p0_p = repmat(reshape(xylambda_p2p0_p',[1,nmhu,nr]),[npn,1,1]);
    XXlambda_p2p0_m = repmat(reshape(xylambda_p2p0_m',[1,nmhu,nr]),[npn,1,1]);
%
%Non-axisymmetric corrections as done by M. Ju et al. in Phys. Plasmas, 9 (2002) 493 (to be used only with FP calculations, and tested for TORE SUPRA only)
%
%	for ir=1:nr,
%		if delta(ir) > 0,
%			XY = zeros(size(Xmhu));
%			XY(Xheaviside) = mhubounce2(ir)./Xmhu2(Xheaviside);
%			XY(~Xheaviside) = Xmhu2(~Xheaviside)/mhubounce2(ir);
%
%			XYm = zeros(size(Xmhum));
%			XYm(Xheavisidem) = mhubounce2(ir)./Xmhu2m(Xheavisidem);
%			XYm(~Xheavisidem) = Xmhu2m(~Xheavisidem)/mhubounce2(ir);
%
%			XYp = zeros(size(Xmhup));
%			XYp(Xheavisidep) = mhubounce2(ir)./Xmhu2p(Xheavisidep);
%			XYp(~Xheavisidep) = Xmhu2p(~Xheavisidep)/mhubounce2(ir);	
%			
%			Xlambda_rip = zeros(size(Xlambda));%Magnetic ripple correction
%			Xlambda_ripm = zeros(size(Xlambdam));%Magnetic ripple correction
%			Xlambda_ripp = zeros(size(Xlambdap));%Magnetic ripple correction
%			XDeltalambda_rip = zeros(size(Xlambda));%Magnetic ripple correction: <Delta>1*(lambda0+lambda1)
%			XDeltalambda_ripm = zeros(size(Xlambdam));%Magnetic ripple correction: <Delta>1*(lambda0+lambda1)
%			XDeltalambda_ripp = zeros(size(Xlambdap));%Magnetic ripple correction: <Delta>1*(lambda0+lambda1)
%
%			theta0 = acos(Xmhu);%Pitch angle
%			theta0m = acos(Xmhum);
%			theta0p = acos(Xmhup);;
%
%			thetaB = zeros(size(Xmhu));%Bounce angle	
%			thetaBm = zeros(size(Xmhum));
%			thetaBp = zeros(size(Xmhup));	
%			thetaB(Xheaviside) = pi;
%			thetaBm(Xheavisidem) = pi;
%			thetaBp(Xheavisidep) = pi;   
%			thetaBm(~Xheavisidem) = acos(1 - 2./(mhubounce2(ir)./cos(theta0m(~Xheavisidem)).^2));
%			thetaBp(~Xheavisidep) = acos(1 - 2./(mhubounce2(ir)./cos(theta0p(~Xheavisidep)).^2));
%			thetaBm(find(thetaBm == 0)) = eps;
%			thetaBp(find(thetaBp == 0)) = eps;
%
%			sstar_rip = -delta(ir)./sqrt(1 - mhubounce2(ir)).*((1 - sqrt(1 - mhubounce2(ir)))./sqrt(mhubounce2(ir))).^(2.*Nq(ir));
%			
%			Xsstar(Xheaviside) = Xsstar(Xheaviside) + sstar_rip;
%			Xsstarm(Xheavisidem) = Xsstarm(Xheavisidem) + sstar_rip;
%			Xsstarp(Xheavisidep) = Xsstarp(Xheavisidep) + sstar_rip;
%			
%			Xlambda_rip(Xheaviside) = -(delta(ir)/2).*tan(theta0(Xheaviside)).^2./sqrt(1 - XY(Xheaviside)).*((1 - sqrt(1 - XY(Xheaviside)))./sqrt(XY(Xheaviside))).^(2.*Nq(ir));
%			Xlambda_ripm(Xheavisidem) = -(delta(ir)/2).*tan(theta0m(Xheavisidem)).^2./sqrt(1 - XYm(Xheavisidem)).*((1 - sqrt(1 - XYm(Xheavisidem)))./sqrt(XYm(Xheavisidem))).^(2.*Nq(ir));
%			Xlambda_ripp(Xheavisidep) =  -(delta(ir)/2).*tan(theta0p(Xheavisidep)).^2./sqrt(1 - XYp(Xheavisidep)).*((1 - sqrt(1 - XYp(Xheavisidep)))./sqrt(XYp(Xheavisidep))).^(2.*Nq(ir));
%
%			Xlambda_rip(~Xheaviside) = sqrt(Nq(ir)/pi)*delta(ir).*tan(theta0(~Xheaviside)).^2.*((1 - cos(thetaB(~Xheaviside)))./sin(thetaB(~Xheaviside))).^(3/2).*sin(pi/4 - Nq(ir).*thetaB(~Xheaviside));
%			Xlambda_ripm(~Xheavisidem) = sqrt(Nq(ir)/pi)*delta(ir).*tan(theta0m(~Xheavisidem)).^2.*((1 - cos(thetaBm(~Xheavisidem)))./sin(thetaBm(~Xheavisidem))).^(3/2).*sin(pi/4 - Nq(ir).*thetaBm(~Xheavisidem));
%			Xlambda_ripp(~Xheavisidep) = sqrt(Nq(ir)/pi)*delta(ir).*tan(theta0p(~Xheavisidep)).^2.*((1 - cos(thetaBp(~Xheavisidep)))./sin(thetaBp(~Xheavisidep))).^(3/2).*sin(pi/4 - Nq(ir).*thetaBp(~Xheavisidep));
%
%			Xlambda = Xlambda + Xlambda_rip;
%			Xlambdam = Xlambdam + Xlambda_ripm;
%			Xlambdap = Xlambdap + Xlambda_ripp;		
%
%			XRlambdam = Xlambdam./Xlambda;
%			XRlambdap = Xlambdap./Xlambda;
%
%			Xsssl = Xsstar./Xlambda;
%			Xssslm = Xsstarm./Xlambdam;
%			Xssslp = Xsstarp./Xlambdap;
%
%			XDeltalambda_rip(Xheaviside) = 3/8*delta(ir)*mhubounce2(ir).*tan(theta0(Xheaviside)).^2./sqrt(1 - XY(Xheaviside)).*((1 - sqrt(1-XY(Xheaviside)))./sqrt(XY(Xheaviside))).^(2.*Nq(ir));
%			XDeltalambda_ripp(Xheavisidep) = 3/8*delta(ir)*mhubounce2(ir)*tan(theta0p(Xheavisidep)).^2./sqrt(1 - XYp(Xheavisidep)).*((1 - sqrt(1 - XYp(Xheavisidep)))./sqrt(XYp(Xheavisidep))).^(2.*Nq(ir));
%			XDeltalambda_ripm(Xheavisidem) = 3/8*delta(ir)*mhubounce2(ir).*tan(theta0m(Xheavisidem)).^2./sqrt(1 - XYm(Xheavisidem)).*((1 - sqrt(1 - XYm(Xheavisidem)))./sqrt(XYm(Xheavisidem))).^(2.*Nq(ir));
%
%			XDeltalambda_rip(~Xheaviside) = -3/4*delta(ir)*sqrt(Nq(ir)/pi)*mhubounce2(ir).*tan(theta0(~Xheaviside)).^2.*(1 - cos(thetaB(~Xheaviside))).^(5/2)./sin(thetaB(~Xheaviside)).^(3/2).*sin(pi/4 - Nq(ir).*thetaB(~Xheaviside));
%			XDeltalambda_ripp(~Xheavisidep) = -3/4*delta(ir)*sqrt(Nq(ir)/pi)*mhubounce2(ir).*tan(theta0p(~Xheavisidep)).^2.*(1 - cos(thetaBp(~Xheavisidep))).^(5/2)./sin(thetaBp(~Xheavisidep)).^(3/2).*sin(pi/4 - Nq(ir).*thetaBp(~Xheavisidep));
%			XDeltalambda_ripm(~Xheavisidem) = -3/4*delta(ir)*sqrt(Nq(ir)/pi)*mhubounce2(ir).*tan(theta0m(~Xheavisidem)).^2.*(1 - cos(thetaBm(~Xheavisidem))).^(5/2)./sin(thetaBm(~Xheavisidem)).^(3/2).*sin(pi/4 - Nq(ir).*thetaBm(~Xheavisidem));
%
%			XDelta = XDelta + XDeltalambda_rip./Xlambda;
%			XDeltap = XDeltap + XDeltalambda_ripp./Xlambdap;
%			XDeltam = XDeltam + XDeltalambda_ripm./Xlambdam;
%		elseif delta(ir) > 0 & dke_mode ==1,
%			error('Ripple calculations are only valid for the Foker-Planck equation mode !');			
%		end
%	end
else
	xmhubounce2 = zeros(1,nr);;
	Xxlambda = ones(nmhu,nr);
	Xxlambdap = ones(nmhu,nr);
	Xxlambdam = ones(nmhu,nr);
%	
	XXlambda = ones(npn,nmhu,nr);
%
	XXRlambdam = ones(npn,nmhu,nr);
	XXRlambdap =ones(npn,nmhu,nr);	
%
	XXsssl = ones(npn,nmhu,nr);
	XXssslm = ones(npn,nmhu,nr);
	XXssslp = ones(npn,nmhu,nr);
%
	XXlambda_p2m1_p = ones(npn,nmhu,nr);%lambda_p2m1 (= 1-delta/mhu0^2)
	XXlambda_p2m1_m = ones(npn,nmhu,nr);
%
	XXlambda_p2p0 = ones(npn,nmhu,nr);%s*_tilde
	XXlambda_p2p0_p = ones(npn,nmhu,nr);
	XXlambda_p2p0_m = ones(npn,nmhu,nr);
%
	XXheaviside = ones(npn,nmhu,nr)
%
	XXsstar = ones(npn,nmhu,nr)
%	XXsstarp = ones(npn,nmhu,nr)
%	XXsstarm = ones(npn,nmhu,nr)
end
