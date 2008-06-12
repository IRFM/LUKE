function [ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,XXfM,XXILor] = coll_dke_jd(dkepath,dkeparam,dkedisplay,equilDKE,mksa,gridDKE,Zmomcoef,Zbouncecoef);
%LUKE - collision operators calculations
%
%Collision operators calculations (e-e, e-i)
%
%by Yves Peysson (CEA-IRFM,yves.peysson@cea.fr) and Joan Decker (CEA-IRFM,joan.decker@cea.fr) and 
%
	etime_coll = 0;
	time0 = clock;
	%
	%load([fullfile(dkepath.temppath,'temp_DKE.mat'],'ZXXD_c','ZXXF_c','ZXXD_c_tp','ZXXF_c_tp','XXfM','XXILor');
	%
	if exist('XXfM') == 1, %The bounce averaging coefficients were calculated before.
  		%
		%load([fullfile(dkepath.temppath,'temp_DKE.mat'],'ZXXD_c','ZXXF_c','ZXXD_c_tp','ZXXF_c_tp','XXfM','XXILor')
  		%
		if dkedisplay.display_mode >= 1,info_dke_yp(2,['Collision flux coefficients retrieved.']);end	
		%
	else
		[xTe_norm,xne_norm,xzni_norm,xzTi_norm,xnloss_norm,xbetath,xlnc_e,xnhu,xrnhuth] = normcoef_dke_yp(mksa,equilDKE,gridDKE);
		%
		% Output files initialization
		%
		XXfM = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
		%
  		ZXXD_c.pp_ippj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
  		ZXXD_c.pp_ipj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
 		ZXXD_c.pp_ij = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
  		ZXXD_c.pp_imj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
  		ZXXD_c.pp_immj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
 		ZXXD_c.pm_ipj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
 		ZXXD_c.pm_ij = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
 		ZXXD_c.pm_imj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
 		ZXXD_c.mp_ijp = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
 		ZXXD_c.mp_ij = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
  		ZXXD_c.mp_ijm = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
 		ZXXD_c.mm_ijp = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
 		ZXXD_c.mm_ijm = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
		%
  		ZXXF_c.p_ippj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
  		ZXXF_c.p_ipj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
  		ZXXF_c.p_ij = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
  		ZXXF_c.p_imj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
  		ZXXF_c.p_immj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
  		ZXXF_c.m_ijp = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
  		ZXXF_c.m_ijm = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);		
  		%
    	if dkeparam.dke_mode == 1
    		%
    		ZXXD_c_tp.pp_ippj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr_dke);
    		ZXXD_c_tp.pp_ipj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr_dke);
    		ZXXD_c_tp.pp_ij = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr_dke);
    		ZXXD_c_tp.pp_imj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr_dke);
    		ZXXD_c_tp.pp_immj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr_dke);
    		ZXXD_c_tp.pm_ipj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr_dke);
    		ZXXD_c_tp.pm_ij = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr_dke);
    		ZXXD_c_tp.pm_imj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr_dke);
    		ZXXD_c_tp.mp_ijp = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr_dke);
    		ZXXD_c_tp.mp_ij = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr_dke);
    		ZXXD_c_tp.mp_ijm = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr_dke);
    		ZXXD_c_tp.mm_ijp = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr_dke);
    		ZXXD_c_tp.mm_ijm = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr_dke);
			%
			ZXXF_c_tp.p_ippj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr_dke);
			ZXXF_c_tp.p_ipj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr_dke);
			ZXXF_c_tp.p_ij = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr_dke);
			ZXXF_c_tp.p_imj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr_dke);
			ZXXF_c_tp.p_immj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr_dke);
			ZXXF_c_tp.m_ijp = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr_dke);
			ZXXF_c_tp.m_ijm = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr_dke);
    	else
    		ZXXD_c_tp = NaN;
			ZXXF_c_tp = NaN;		
		end
		%
        if isfield(dkeparam,'clustermode'),
            if isfield(dkeparam.clustermode,'coll_dke_jd'),
                if isfield(dkeparam.clustermode.coll_dke_jd,'mode'),
                    cluster_mode = dkeparam.clustermode.coll_dke_jd.mode;
                else
                    cluster_mode = 0;
                end
                %
                if isfield(dkeparam.clustermode.coll_dke_jd,'timeout'),
                    cluster_timeout = dkeparam.clustermode.coll_dke_jd.timeout;
                else
                    cluster_timeout = 60*10;%(s)
                end
                %
                if isfield(dkeparam.clustermode.coll_dke_jd,'size'),
                    cluster_size = dkeparam.clustermode.coll_dke_jd.size;
                else
                    cluster_size = 1;
                end            
            else
                cluster_mode = 0;
                cluster_timeout = 0;
                cluster_size = 0;
            end
        else
            cluster_mode = 0;
            cluster_timeout = 0;
            cluster_size = 0;
        end
		%
		if ~isfield(dkedisplay,'mdce'),dkedisplay.mdce = 1;end
		if cluster_mode,
			for ir = 1:gridDKE.nr,arg_range{ir} = ir;end
			[flag,XXfM_out,ZXXD_c_pp_ippj,ZXXD_c_pp_ipj,ZXXD_c_pp_ij,ZXXD_c_pp_imj,ZXXD_c_pp_immj,ZXXD_c_mm_ijp,ZXXD_c_mm_ijm,ZXXF_c_p_ippj,ZXXF_c_p_ipj,ZXXF_c_p_ij,ZXXF_c_p_imj,ZXXF_c_p_immj] = mdce_luke(@loop_coll_dke_jd1,{ir,gridDKE,Zmomcoef,Zbouncecoef,equilDKE,mksa,dkepath,dkedisplay,dkeparam,xTe_norm,xne_norm,xzni_norm,xzTi_norm,xnloss_norm,xbetath,xlnc_e,xnhu,xrnhuth},1,arg_range,cluster_size,dkepath,dkedisplay.mdce,cluster_mode,cluster_timeout);			
			for ir = 1:gridDKE.nr
				XXfM(:,:,ir) = XXfM_out{ir};
         		ZXXD_c.pp_ippj(:,:,ir) = ZXXD_c_pp_ippj{ir};
				ZXXD_c.pp_ippj(:,:,ir) = ZXXD_c_pp_ippj{ir};
				ZXXD_c.pp_ipj(:,:,ir) = ZXXD_c_pp_ipj{ir};
				ZXXD_c.pp_ij(:,:,ir) = ZXXD_c_pp_ij{ir};
				ZXXD_c.pp_imj(:,:,ir) = ZXXD_c_pp_imj{ir};
				ZXXD_c.pp_immj(:,:,ir) = ZXXD_c_pp_immj{ir};
				ZXXD_c.mm_ijp(:,:,ir) = ZXXD_c_mm_ijp{ir};
				ZXXD_c.mm_ijm(:,:,ir) = ZXXD_c_mm_ijm{ir};
				%				
				ZXXF_c.p_ippj(:,:,ir) = ZXXF_c_p_ippj{ir};
				ZXXF_c.p_ipj(:,:,ir) = ZXXF_c_p_ipj{ir};
				ZXXF_c.p_ij(:,:,ir) = ZXXF_c_p_ij{ir};
				ZXXF_c.p_imj(:,:,ir) = ZXXF_c_p_imj{ir};
				ZXXF_c.p_immj(:,:,ir) = ZXXF_c_p_immj{ir};	
         	end
			%
    		if dkeparam.dke_mode == 1
    			for ir = 1:gridDKE.nr,arg_range{ir} = ir;end		    	
    			[flag,ZXXD_c_tp_pp_ippj,ZXXD_c_tp_pp_ipj,ZXXD_c_tp_pp_ij,ZXXD_c_tp_pp_imj,ZXXD_c_tp_pp_immj,ZXXD_c_tp_mm_ijp,ZXXD_c_tp_mm_ijm,ZXXF_c_tp_p_ippj,ZXXF_c_tp_p_ipj,ZXXF_c_tp_p_ij,ZXXF_c_tp_p_im,ZXXF_c_tp_p_immj,ZXXF_c_tp_m_ijp,ZXXF_c_tp_m_ijm] = mdce_luke(@loop_coll_dke_jd2,{ir,gridDKE,Zbouncecoef,ZXXD_c,dkepath,dkeparam},1,arg_range,cluster_size,dkepath,dkedisplay.mdce,cluster_mode,cluster_timeout);
   		    	%
   		    	for ir = 1:gridDKE.nr,
    		    	ir_dke = find(ir == gridDKE.rdke);
        			if ~isempty(ir_dke)
        				ZXXD_c_tp.pp_ippj(:,:,ir_dke) = ZXXD_c_tp_pp_ippj{ir};
        				ZXXD_c_tp.pp_ipj(:,:,ir_dke) = ZXXD_c_tp_pp_ipj{ir};
        				ZXXD_c_tp.pp_ij(:,:,ir_dke) = ZXXD_c_tp_pp_ij{ir};
        				ZXXD_c_tp.pp_imj(:,:,ir_dke) = ZXXD_c_tp_pp_imj{ir};
        				ZXXD_c_tp.pp_immj(:,:,ir_dke) = ZXXD_c_tp_pp_immj{ir};
        				ZXXD_c_tp.mm_ijp(:,:,ir_dke) = ZXXD_c_tp_mm_ijp{ir};
        				ZXXD_c_tp.mm_ijm(:,:,ir_dke) = ZXXD_c_tp_mm_ijm{ir};
        				%
        				ZXXF_c_tp.p_ippj(:,:,ir_dke) = ZXXF_c_tp_p_ippj{ir};
        				ZXXF_c_tp.p_ipj(:,:,ir_dke) = ZXXF_c_tp_p_ipj{ir};
        				ZXXF_c_tp.p_ij(:,:,ir_dke) = ZXXF_c_tp_p_ij{ir};
        				ZXXF_c_tp.p_im(:,:,ir_dke) = ZXXF_c_tp_p_im{ir};
        				ZXXF_c_tp.p_immj(:,:,ir_dke) = ZXXF_c_tp_p_immj{ir};
        				ZXXF_c_tp.m_ijp(:,:,ir_dke) = ZXXF_c_tp_m_ijp{ir};
        				ZXXF_c_tp.m_ijm(:,:,ir_dke)= ZXXF_c_tp_m_ijm{ir};
        			end
    		    end
			end
		else
  			%
    		for ir = 1:gridDKE.nr,
				[XXfM(:,:,ir),ZXXD_c.pp_ippj(:,:,ir),ZXXD_c.pp_ipj(:,:,ir),ZXXD_c.pp_ij(:,:,ir),ZXXD_c.pp_imj(:,:,ir),ZXXD_c.pp_immj(:,:,ir),ZXXD_c.mm_ijp(:,:,ir),ZXXD_c.mm_ijm(:,:,ir),ZXXF_c.p_ippj(:,:,ir),ZXXF_c.p_ipj(:,:,ir),ZXXF_c.p_ij(:,:,ir),ZXXF_c.p_imj(:,:,ir),ZXXF_c.p_immj(:,:,ir)] = loop_coll_dke_jd1(ir,gridDKE,Zmomcoef,Zbouncecoef,equilDKE,mksa,dkepath,dkedisplay,dkeparam,xTe_norm,xne_norm,xzni_norm,xzTi_norm,xnloss_norm,xbetath,xlnc_e,xnhu,xrnhuth);
    		end
    		%
    		if dkeparam.dke_mode == 1
				%
    		    for ir = 1:gridDKE.nr,
    		    	ir_dke = find(ir == gridDKE.rdke);
        			if ~isempty(ir_dke)
    					[ZXXD_c_tp.pp_ippj(:,:,ir_dke),ZXXD_c_tp.pp_ipj(:,:,ir_dke),ZXXD_c_tp.pp_ij(:,:,ir_dke),ZXXD_c_tp.pp_imj(:,:,ir_dke),ZXXD_c_tp.pp_immj(:,:,ir_dke),ZXXD_c_tp.mm_ijp(:,:,ir_dke),ZXXD_c_tp.mm_ijm(:,:,ir_dke),ZXXF_c_tp.p_ippj(:,:,ir_dke),ZXXF_c_tp.p_ipj(:,:,ir_dke),ZXXF_c_tp.p_ij(:,:,ir_dke),ZXXF_c_tp.p_im(:,:,ir_dke),ZXXF_c_tp.p_immj(:,:,ir_dke),ZXXF_c_tp.m_ijp(:,:,ir_dke),ZXXF_c_tp.m_ijm(:,:,ir_dke)] = loop_coll_dke_jd2(ir,gridDKE,Zbouncecoef,ZXXD_c,dkepath,dkeparam);
					end
				end    		
    		end
		end
		%   
		%Pitch-angle integral for the Lorentz model (test mode only and initial guess for the drift kinetic equation, see documentation)
		%   
		XXILor =  zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
		for ir_dke = 1:gridDKE.nr_dke,
    		jr2 = gridDKE.rdke(ir_dke);
    		if dkeparam.bounce_mode == 1
        		ILor_p = Zbouncecoef.Zmask_f0_P{jr2}.*sum(((gridDKE.dmhu.*(gridDKE.mhu>=0).*Zbouncecoef.XXlambda_b_p3m2(1,:,jr2)./Zbouncecoef.XXlambda_p2m1(1,:,jr2))'*ones(1,gridDKE.nmhu)).*triu(ones(gridDKE.nmhu,gridDKE.nmhu)));
        		ILor_m = fliplr(ILor_p);
        		ILor = ILor_m + ILor_p;
        		XXILor(:,:,jr2) = ones(gridDKE.npn,1)*ILor;
    		else
        		XXILor(:,:,jr2) = zeros(gridDKE.npn,gridDKE.nmhu);
    		end 
		end 
		%
		%  save([fullfile(dkepath.temppath,'temp_DKE.mat'],'ZXXD_c','ZXXF_c','ZXXD_c_tp','ZXXF_c_tp','XXfM','XXILor','-append');
		%
		etime_coll = etime_coll + etime(clock,time0);
		if dkedisplay.display_mode >= 1,info_dke_yp(2,['Collision flux coefficients calculations done in ',num2str(etime_coll),' (s)']);end	
		%
	end
end

function [XXfM,ZXXD_c_pp_ippj,ZXXD_c_pp_ipj,ZXXD_c_pp_ij,ZXXD_c_pp_imj,ZXXD_c_pp_immj,ZXXD_c_mm_ijp,ZXXD_c_mm_ijm,ZXXF_c_p_ippj,ZXXF_c_p_ipj,ZXXF_c_p_ij,ZXXF_c_p_imj,ZXXF_c_p_immj] = loop_coll_dke_jd1(ir,gridDKE,Zmomcoef,Zbouncecoef,equilDKE,mksa,dkepath,dkedisplay,dkeparam,xTe_norm,xne_norm,xzni_norm,xzTi_norm,xnloss_norm,xbetath,xlnc_e,xnhu,xrnhuth)
%LUKE - Collision operator (loop function for distributed computing environment)
%
%Collision operator (loop function for distributed computing environment)
%
%by Yves Peysson (CEA-IRFM,yves.peysson@cea.fr) and Joan Decker (CEA-IRFM,joan.decker@cea.fr) 
%
%Relativistic Maxwellian distribution function normalized to the local density
%
  	fM = maxwellian_dke_yp(Zmomcoef.gamma(:),gridDKE.pn2(:),gridDKE.dpn(:),xne_norm,xTe_norm,ir);
    xfM = fM*ones(1,length(fM));
    XXfM = fM*ones(1,gridDKE.nmhu);
	%
	%Electron-ion collision term (non-relativistic limit)
	%
    [Fei,Aei,Btei] = eicoll_dke_yp(Zmomcoef.v,equilDKE.zZi,equilDKE.zmi,xzni_norm,xzTi_norm,ir,dkeparam.coll_mode);
    [Feim,Aeim] = eicoll_dke_yp(Zmomcoef.vm,equilDKE.zZi,equilDKE.zmi,xzni_norm,xzTi_norm,ir,dkeparam.coll_mode);
    [Feip,Aeip] = eicoll_dke_yp(Zmomcoef.vp,equilDKE.zZi,equilDKE.zmi,xzni_norm,xzTi_norm,ir,dkeparam.coll_mode);
	%   
    Feim(1) = 1;%Avoid singularity at p = 0, but the value is not used  
    Feimm = [0,Fei(1:gridDKE.npn-1)];
    Feipp = [Fei(2:gridDKE.npn),0];
	%       
    XFeimm = Feimm'*ones(1,gridDKE.nmhu);
    XFeim = Feim'*ones(1,gridDKE.nmhu);
    XFei = Fei'*ones(1,gridDKE.nmhu);
    XFeip = Feip'*ones(1,gridDKE.nmhu);
    XFeipp = Feipp'*ones(1,gridDKE.nmhu);
	%
    Aeim(1) = 1;%Avoid singularity at p = 0, but the value is not used
    Aeimm = [eps,Aei(1:gridDKE.npn-1)];
    Aeipp = [Aei(2:gridDKE.npn),eps];
	%
    XAeimm = Aeimm'*ones(1,gridDKE.nmhu);
    XAeim = Aeim'*ones(1,gridDKE.nmhu); 
    XAei = Aei'*ones(1,gridDKE.nmhu);
    XAeip = Aeip'*ones(1,gridDKE.nmhu);
    XAeipp = Aeipp'*ones(1,gridDKE.nmhu);
	%
    XBtei = Btei'*ones(1,gridDKE.nmhu);     
	%
	%Fast electron-thermal electron collision term
	%
    [Fee,Aee,Btee] = eecoll_dke_yp(Zmomcoef.v,Zmomcoef.z,Zmomcoef.gamma,Zmomcoef.sigma,gridDKE.pn,gridDKE.pn2,gridDKE.dpn,Zmomcoef.J1,Zmomcoef.J2,dkeparam.spfac,mksa.betath_ref,xne_norm,xTe_norm,ir,dkeparam.coll_mode,dkepath,dkedisplay,dkeparam);
    [Feem,Aeem] = eecoll_dke_yp(Zmomcoef.vm,Zmomcoef.zm,Zmomcoef.gammam,Zmomcoef.sigmam,gridDKE.pnm,gridDKE.pn2m,gridDKE.dpnm,Zmomcoef.J1,Zmomcoef.J2,dkeparam.spfac,mksa.betath_ref,xne_norm,xTe_norm,ir,dkeparam.coll_mode,dkepath,dkedisplay,dkeparam);
    [Feep,Aeep] = eecoll_dke_yp(Zmomcoef.vp,Zmomcoef.zp,Zmomcoef.gammap,Zmomcoef.sigmap,gridDKE.pnp,gridDKE.pn2p,gridDKE.dpnp,Zmomcoef.J1,Zmomcoef.J2,dkeparam.spfac,mksa.betath_ref,xne_norm,xTe_norm,ir,dkeparam.coll_mode,dkepath,dkedisplay,dkeparam);
	%
    Feem(1) = 1;%Avoid singularity at p = 0, but the value is not used
    Feemm = [0,Fee(1:gridDKE.npn-1)];
    Feepp = [Fee(2:gridDKE.npn),0];
	%       
    XFeemm = Feemm'*ones(1,gridDKE.nmhu);
    XFeem = Feem'*ones(1,gridDKE.nmhu);
    XFee = Fee'*ones(1,gridDKE.nmhu);
    XFeep = Feep'*ones(1,gridDKE.nmhu);
    XFeepp = Feepp'*ones(1,gridDKE.nmhu);
	%
    Aeem(1) = 1;%Avoid singularity at p = 0, but the value is not used
    Aeemm = [eps,Aee(1:gridDKE.npn-1)];
    Aeepp = [Aee(2:gridDKE.npn),eps];
	%
    XAeemm = Aeemm'*ones(1,gridDKE.nmhu);
    XAeem = Aeem'*ones(1,gridDKE.nmhu); 
    XAee = Aee'*ones(1,gridDKE.nmhu);
    XAeep = Aeep'*ones(1,gridDKE.nmhu);
    XAeepp = Aeepp'*ones(1,gridDKE.nmhu);
	%
    XBtee = Btee'*ones(1,gridDKE.nmhu);    
	%   
	% Collisions flux coefficients calculations for f0 and g
	%
    ZXXD_c_pp_ippj = XAeepp + XAeipp;
    ZXXD_c_pp_ipj = XAeep + XAeip;
    ZXXD_c_pp_ij = XAee + XAei;
    ZXXD_c_pp_imj = XAeem + XAeim;
    ZXXD_c_pp_immj = XAeemm + XAeimm;
	%
    ZXXD_c_mm_ijp = (XBtee + XBtei).*Zbouncecoef.XXRlambda_p2m1_p(:,:,ir);
    ZXXD_c_mm_ijm = (XBtee + XBtei).*Zbouncecoef.XXRlambda_p2m1_m(:,:,ir);
	%
    ZXXF_c_p_ippj = -XFeepp - XFeipp;
    ZXXF_c_p_ipj = -XFeep - XFeip;
    ZXXF_c_p_ij = -XFee - XFei;
    ZXXF_c_p_imj = -XFeem - XFeim;
    ZXXF_c_p_immj = -XFeemm - XFeimm;       
end

function [ZXXD_c_tp_pp_ippj,ZXXD_c_tp_pp_ipj,ZXXD_c_tp_pp_ij,ZXXD_c_tp_pp_imj,ZXXD_c_tp_pp_immj,ZXXD_c_tp_mm_ijp,ZXXD_c_tp_mm_ijm,ZXXF_c_tp_p_ippj,ZXXF_c_tp_p_ipj,ZXXF_c_tp_p_ij,ZXXF_c_tp_p_im,ZXXF_c_tp_p_immj,ZXXF_c_tp_m_ijp,ZXXF_c_tp_m_ijm] = loop_coll_dke_jd2(ir,gridDKE,Zbouncecoef,ZXXD_c,dkepath,dkeparam)
%LUKE - Collision operator for first order correction (loop function for distributed computing environment)
%
%Collision operator for first order correction (loop function for distributed computing environment)
%
%by Yves Peysson (CEA-IRFM,yves.peysson@cea.fr) and Joan Decker (CEA-IRFM,joan.decker@cea.fr) 
%
%Relativistic Maxwellian distribution function normalized to the local density
	%
	% Collisions flux coefficients calculations for ftp 
	%
    ir_dke = find(ir == gridDKE.rdke);
    if ~isempty(ir_dke)
		%        
    	ZXXD_c_tp_pp_ippj = ZXXD_c.pp_ippj.*Zbouncecoef.XXRlambda_b_p1m1(:,:,ir);
    	ZXXD_c_tp_pp_ipj = ZXXD_c.pp_ipj.*Zbouncecoef.XXRlambda_b_p1m1(:,:,ir);
    	ZXXD_c_tp_pp_ij = ZXXD_c.pp_ij.*Zbouncecoef.XXRlambda_b_p1m1(:,:,ir);
    	ZXXD_c_tp_pp_imj = ZXXD_c.pp_imj.*Zbouncecoef.XXRlambda_b_p1m1(:,:,ir);
    	ZXXD_c_tp_pp_immj = ZXXD_c.pp_immj.*Zbouncecoef.XXRlambda_b_p1m1(:,:,ir);
    	ZXXD_c_tp_mm_ijp = ZXXD_c.mm_ijp.*Zbouncecoef.XXRlambda_b_p3m2_p(:,:,ir)./Zbouncecoef.XXRlambda_p2m1_p(:,:,ir);
    	ZXXD_c_tp_mm_ijm = ZXXD_c.mm_ijm.*Zbouncecoef.XXRlambda_b_p3m2_m(:,:,ir)./Zbouncecoef.XXRlambda_p2m1_m(:,:,ir);
		%
    	ZXXF_c_tp_p_ippj = ZXXF_c.p_ippj.*Zbouncecoef.XXRlambda_b_p1m1(:,:,ir);
    	ZXXF_c_tp_p_ipj = ZXXF_c.p_ipj.*Zbouncecoef.XXRlambda_b_p1m1(:,:,ir);
    	ZXXF_c_tp_p_ij = ZXXF_c.p_ij.*Zbouncecoef.XXRlambda_b_p1m1(:,:,ir);
    	ZXXF_c_tp_p_im = ZXXF_c.p_imj.*Zbouncecoef.XXRlambda_b_p1m1(:,:,ir);
    	ZXXF_c_tp_p_immj = ZXXF_c.p_immj.*Zbouncecoef.XXRlambda_b_p1m1(:,:,ir);  
    	ZXXF_c_tp_m_ijp = (ZXXD_c.mm_ijp./Zbouncecoef.XXRlambda_p2m1_p(:,:,ir)).*(Zbouncecoef.XXRlambda_b_p1m1_p(:,:,ir) - Zbouncecoef.XXRlambda_b_p1m2_p(:,:,ir)).*sqrt(gridDKE.X1mmhu2p)./gridDKE.Xpn./gridDKE.Xmhu2p./gridDKE.Xmhup;
    	ZXXF_c_tp_m_ijm = (ZXXD_c.mm_ijm./Zbouncecoef.XXRlambda_p2m1_m(:,:,ir)).*(Zbouncecoef.XXRlambda_b_p1m1_m(:,:,ir) - Zbouncecoef.XXRlambda_b_p1m2_m(:,:,ir)).*sqrt(gridDKE.X1mmhu2m)./gridDKE.Xpn./gridDKE.Xmhu2m./gridDKE.Xmhum;
		%    
	end
end

