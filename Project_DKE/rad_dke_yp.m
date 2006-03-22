function [time0,MMXR_f_t] = rad_dke_yp(npn,nmhu,nr,ns_f,XXDr,XXVr,xpsin,xdpsin,xpsinm,xdpsinm,...
xpsinp,xdpsinp,XXlambda,XXpn2,Xmhu,Xmhu2,xmhubounce2,xR0,xqtilde,xBp0,xB0,blocksize_f_t,...
bounce_mode,radial_mode,display_mode,save_id,temppath)
%
% Calculation of the anomalous radial fast electron transport matrix coefficients for arbitrary magnetic plasma equilibrium 
%
% by J. Decker (MIT-RLE) <joan.decker@cea.fr> and Y. Peysson (CEA-DRFC) <yves.peysson@cea.fr>
%
%
if nargin < 27,
   error('Wrong number of input arguments for rad_dke_yp');
end
%
etime_radial = 0;
time0 = clock;
%
XXMrm = zeros(nmhu,npn,nr);
XXMr = zeros(nmhu,npn,nr);
XXMrp = zeros(nmhu,npn,nr);
%
nMMXP_f_t = max(cumsum(blocksize_f_t));
%
if radial_mode == 1,
%   
   load([fullfile(temppath,'temp_DKE_'),save_id,'.mat'],'MMXR_f_t');
%
   if exist('MMXR_f_t') == 1, %The radial matrix was calculated before.
      etime_radial = etime_radial + etime(clock,time0);time0 = clock;
      if display_mode >= 1,info_dke_yp(2,['Configuration space matrix coefficients retrieved in ',num2str(etime_radial),' (s)']);end
   else
   %
      MMXR_f_t = sparse(nMMXP_f_t,nMMXP_f_t);%Create supermatrix
% 
      xdpsinmm = [0,xdpsin(1:nr-1)];
      xdpsinpp = [xdpsin(2:nr),0];
%
      XXpsin = reshape(repmat(xpsin,[npn*nmhu,1]),[npn,nmhu,nr]);
      XXdpsin = reshape(repmat(xdpsin,[npn*nmhu,1]),[npn,nmhu,nr]);   
      XXpsinm = reshape(repmat(xpsinm,[npn*nmhu,1]),[npn,nmhu,nr]);   
      XXdpsinm = reshape(repmat(xdpsinm,[npn*nmhu,1]),[npn,nmhu,nr]); 
      XXpsinp = reshape(repmat(xpsinp,[npn*nmhu,1]),[npn,nmhu,nr]);   
      XXdpsinp = reshape(repmat(xdpsinp,[npn*nmhu,1]),[npn,nmhu,nr]); 
      XXdpsinmm = reshape(repmat(xdpsinmm,[npn*nmhu,1]),[npn,nmhu,nr]);   
      XXdpsinpp = reshape(repmat(xdpsinpp,[npn*nmhu,1]),[npn,nmhu,nr]);
%
      XXdeltalp = XXdpsinpp./(XXdpsinpp + XXdpsin);%Grid interpolation coefficients
      XXdeltalm = XXdpsin./(XXdpsinmm + XXdpsin);%Grid interpolation coefficients
%
      XXDrmm = zeros(npn,nmhu,nr);
      XXDrmm(:,:,2:nr) = XXDr(:,:,1:nr-1);
      XXDrpp = zeros(npn,nmhu,nr);
      XXDrpp(:,:,1:nr-1) = XXDr(:,:,2:nr);
%
      XXDrp = (1 - XXdeltalp).*XXDrpp + XXdeltalp.*XXDr;%Evaluation of the diffusion rate on the flux grid (linear interpolation)
      XXDrm = (1 - XXdeltalm).*XXDr + XXdeltalm.*XXDrmm;%Evaluation of the diffusion rate on the flux grid (linear interpolation)
%
      XXVrmm = zeros(npn,nmhu,nr);
      XXVrmm(:,:,2:nr) = XXVr(:,:,1:nr-1);
      XXVrpp = zeros(npn,nmhu,nr);
      XXVrpp(:,:,1:nr-1) = XXVr(:,:,2:nr);
%
      XXVrp = (1 - XXdeltalp).*XXVrpp + XXdeltalp.*XXVr;%Evaluation of the convection on the flux grid (linear interpolation)
      XXVrm = (1 - XXdeltalm).*XXVr + XXdeltalm.*XXVrmm;%Evaluation of the convection on the flux grid (linear interpolation)
%
      XXR0 = repmat(reshape(xR0',[1,1,nr]),[npn,nmhu,1]);
      XXR0mm = zeros(npn,nmhu,nr);
      XXR0mm(:,:,2:nr) = XXR0(:,:,1:nr-1);
      XXR0pp = zeros(npn,nmhu,nr);
      XXR0pp(:,:,1:nr-1) = XXR0(:,:,2:nr);
%
      XXR0p = (1 - XXdeltalp).*XXR0pp + XXdeltalp.*XXR0;%Evaluation on the flux grid (linear interpolation)
      XXR0m = (1 - XXdeltalm).*XXR0 + XXdeltalm.*XXR0mm;%Evaluation on the flux grid (linear interpolation)
%
      XXqtilde = repmat(reshape(xqtilde',[1,1,nr]),[npn,nmhu,1]);
      XXqtildemm = zeros(npn,nmhu,nr);
      XXqtildemm(:,:,2:nr) = XXqtilde(:,:,1:nr-1);
      XXqtildepp = zeros(npn,nmhu,nr);
      XXqtildepp(:,:,1:nr-1) = XXqtilde(:,:,2:nr);
%
      XXqtildep = (1 - XXdeltalp).*XXqtildepp + XXdeltalp.*XXqtilde;%Evaluation on the flux grid (linear interpolation)
      XXqtildem = (1 - XXdeltalm).*XXqtilde + XXdeltalm.*XXqtildemm;%Evaluation on the flux grid (linear interpolation)
%   
      XXBp0 = repmat(reshape(xBp0',[1,1,nr]),[npn,nmhu,1]);
      XXBp0mm = zeros(npn,nmhu,nr);
      XXBp0mm(:,:,2:nr) = XXBp0(:,:,1:nr-1);
      XXBp0pp = zeros(npn,nmhu,nr);
      XXBp0pp(:,:,1:nr-1) = XXBp0(:,:,2:nr);
%
      XXBp0p = (1 - XXdeltalp).*XXBp0pp + XXdeltalp.*XXBp0;%Evaluation on the flux grid (linear interpolation)
      XXBp0m = (1 - XXdeltalm).*XXBp0 + XXdeltalm.*XXBp0mm;%Evaluation on the flux grid (linear interpolation)
%
      XXB0 = repmat(reshape(xB0',[1,1,nr]),[npn,nmhu,1]);
      XXB0mm = zeros(npn,nmhu,nr);
      XXp0mm(:,:,2:nr) = XXB0(:,:,1:nr-1);
      XXB0pp = zeros(npn,nmhu,nr);
      XXB0pp(:,:,1:nr-1) = XXB0(:,:,2:nr);
%
      XXB0p = (1 - XXdeltalp).*XXB0pp + XXdeltalp.*XXB0;%Evaluation on the flux grid (linear interpolation)
      XXB0m = (1 - XXdeltalm).*XXB0 + XXdeltalm.*XXB0mm;%Evaluation on the flux grid (linear interpolation)
%
      XXlambdamm = zeros(npn,nmhu,nr);
      XXlambdamm(:,:,2:nr) = XXlambda(:,:,1:nr-1);
      XXlambdapp = zeros(npn,nmhu,nr);
      XXlambdapp(:,:,1:nr-1) = XXlambda(:,:,2:nr);
%
      XXlambdap = (1 - XXdeltalp).*XXlambdapp + XXdeltalp.*XXlambda;%Evaluation on the flux grid (linear interpolation)
      XXlambdam = (1 - XXdeltalm).*XXlambda + XXdeltalm.*XXlambdamm;%Evaluation on the flux grid (linear interpolation)
%   
      XXalpharp = XXR0p.*XXqtildep.*XXBp0p.*XXlambdap./XXB0p;%Evaluation on the flux grid (linear interpolation)
      XXalpharm = XXR0m.*XXqtildem.*XXBp0m.*XXlambdam./XXB0m;%Evaluation on the flux grid (linear interpolation)
      XXalpharm(:,:,1) = 0;%Force zero at the plasma center, which is the natural analytical limit (In cylindrical geometry, r=0)
      XXalpharp(:,:,nr) = 0;%Avoid NaN
%
%************************************************** Matrices calculation ******************************************************** 
%
      XXMrm = -(XXalpharm.*XXR0m.*XXBp0m./XXdpsinm./XXdpsin).*XXDrm - (XXalpharm./XXdpsin).*XXVrm.*XXdeltalm;
      XXMr = (XXalpharp.*XXR0p.*XXBp0p./XXdpsinp./XXdpsin).*XXDrp + (XXalpharp./XXdpsin).*XXVrp.*XXdeltalp +...
           (XXalpharm.*XXR0m.*XXBp0m./XXdpsinm./XXdpsin).*XXDrm - (XXalpharm./XXdpsin).*XXVrm.*(1 - XXdeltalm);                    
      XXMrp = -(XXalpharp.*XXR0p.*XXBp0p./XXdpsinp./XXdpsin).*XXDrp + (XXalpharp./XXdpsin).*XXVrp.*(1 - XXdeltalp);
%
      XXMrm = XXMrm.*XXpn2./XXlambda;%Partial Jacobian multiplication
      XXMr = XXMr.*XXpn2./XXlambda;%Partial Jacobian multiplication
      XXMrp = XXMrp.*XXpn2./XXlambda;%Partial Jacobian multiplication
%
% Radial off-diagonal terms for fast electron transport
%
      if bounce_mode == 0,
         XXMrm = permute(XXMrm,[2,1,3]);
         MMrm_t = reshape(XXMrm,npn*nmhu*nr,1,1);
         XXMr = permute(XXMr,[2,1,3]);
         MMr_t = reshape(XXMr,npn*nmhu*nr,1,1);
         XXMrp = permute(XXMrp,[2,1,3]);
         MMrp_t = reshape(XXMrp,npn*nmhu*nr,1,1);
%
         MMXR_f_t = MMXR_f_t + sparse([1+nmhu*npn:nMMXP_f_t],[1:nMMXP_f_t-nmhu*npn],MMrm_t(1+npn*nmhu:nMMXP_f_t),nMMXP_f_t,nMMXP_f_t);
         MMXR_f_t = MMXR_f_t + sparse([1:nMMXP_f_t],[1:nMMXP_f_t],MMr_t,nMMXP_f_t,nMMXP_f_t);    
         MMXR_f_t = MMXR_f_t + sparse([1:nMMXP_f_t-nmhu*npn],[1+npn*nmhu:nMMXP_f_t],MMrp_t(1:nMMXP_f_t-nmhu*npn),nMMXP_f_t,nMMXP_f_t);
         if display_mode >= 1,info_dke_yp(2,['Configuration space matrix calculations done in ',num2str(etime(clock,time0)),' (s)']);etime_radial = etime_radial + etime(clock,time0);time0 = clock;end
      elseif bounce_mode == 1,    
         ir = 1;
         ib0 = 0;
         ibp = max(cumsum(blocksize_f_t(1:ir)));
%
         Xmask_f0 = (Xmhu2 < xmhubounce2(ir)) & (Xmhu < 0);%Only the half-bounce region is removed
         Xmask_f0 = nonzeros(~(Xmask_f0(2,:)==1).*cumsum(ones(1,nmhu)))';
         Xmask_f0p = (Xmhu2 < xmhubounce2(ir+1)) & (Xmhu < 0);%Only the half-bounce region is removed
         Xmask_f0p = nonzeros(~(Xmask_f0p(2,:)==1).*cumsum(ones(1,nmhu)))';
%   
         imhu0 = sum((Xmhu(1,Xmask_f0) < 0).*(Xmhu2(1,Xmask_f0) > xmhubounce2(ir))); 
         imhup = sum((Xmhu(1,Xmask_f0p) < 0).*(Xmhu2(1,Xmask_f0p) > xmhubounce2(ir+1)));
%
         XMr = XXMr(:,:,ir);
         XMr_t = XMr(:,Xmask_f0);%Matrix reduction along the angular direction (half-bounce region is removed)
         MMr_t = reshape(XMr_t',npn*(nmhu-ns_f(ir)),1,1);
         MMXR_f_t = MMXR_f_t + sparse([1+ib0:ibp],[1+ib0:ibp],MMr_t,nMMXP_f_t,nMMXP_f_t);
%           
         XMrp = XXMrp(:,:,ir);
         XMrp_t = XMrp(:,Xmask_f0);%Matrix reduction along the angular direction (half-bounce region is removed)
         XMrp1_t = XMrp_t.*(Xmhu(:,Xmask_f0) < 0).*(Xmhu2(:,Xmask_f0) > xmhubounce2(ir+1));
         XMrp2_t = XMrp_t.*(Xmhu(:,Xmask_f0) < 0).*(Xmhu2(:,Xmask_f0) < xmhubounce2(ir+1)).*(Xmhu2(:,Xmask_f0) > xmhubounce2(ir));
         XMrp3_t = XMrp_t.*(Xmhu(:,Xmask_f0) > 0);
%           
         for ip = 1:npn, 
            MMXR_f_t = MMXR_f_t + sparse([ib0+(nmhu-ns_f(ir))*(ip-1)+1:ib0+(nmhu-ns_f(ir))*(ip-1)+imhup],[ibp+(nmhu-ns_f(ir+1))*(ip-1)+1:ibp+(nmhu-ns_f(ir+1))*(ip-1)+imhup],XMrp1_t(ip,[1:imhup]),nMMXP_f_t,nMMXP_f_t);
            MMXR_f_t = MMXR_f_t + sparse([ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0+1:ib0+(nmhu-ns_f(ir))*ip],[ibp+(nmhu-ns_f(ir+1))*(ip-1)+imhup+1:ibp+(nmhu-ns_f(ir+1))*ip],XMrp3_t(ip,[imhu0+1:nmhu-ns_f(ir)]),nMMXP_f_t,nMMXP_f_t);
            MMXR_f_t = MMXR_f_t + sparse([ib0+(nmhu-ns_f(ir))*(ip-1)+imhup+1:ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0],...
            [ibp+(nmhu-ns_f(ir+1))*(ip-1)+((nmhu-ns_f(ir+1))-imhup):-1:ibp+(nmhu-ns_f(ir+1))*(ip-1)+((nmhu-ns_f(ir+1))-imhu0)+1],XMrp2_t(ip,[imhup+1:imhu0]),nMMXP_f_t,nMMXP_f_t);
         end 
%
         if display_mode >= 1,info_dke_yp(2,['Configuration space matrix calculations (',int2str(ir),'/',int2str(nr),') done in ',num2str(etime(clock,time0)),' (s)']);etime_radial = etime_radial + etime(clock,time0);time0 = clock;end
%
         for ir = 2:nr-1,
            if ir == 2,
               ibm = 0;
            else
               ibm = max(cumsum(blocksize_f_t(1:ir-2)));%Block index reference
            end
%
            ib0 = max(cumsum(blocksize_f_t(1:ir-1)));%Block index reference
            ibp = max(cumsum(blocksize_f_t(1:ir)));
%
            Xmask_f0m = (Xmhu2 < xmhubounce2(ir-1)) & (Xmhu < 0);%Only the half-bounce region is removed
            Xmask_f0m = nonzeros(~(Xmask_f0m(2,:)==1).*cumsum(ones(1,nmhu)))';
            Xmask_f0 = (Xmhu2 < xmhubounce2(ir)) & (Xmhu < 0);%Only the half-bounce region is removed
            Xmask_f0 = nonzeros(~(Xmask_f0(2,:)==1).*cumsum(ones(1,nmhu)))';
            Xmask_f0p = (Xmhu2 < xmhubounce2(ir+1)) & (Xmhu < 0);%Only the half-bounce region is removed
            Xmask_f0p = nonzeros(~(Xmask_f0p(2,:)==1).*cumsum(ones(1,nmhu)))';
%   
            imhum = sum((Xmhu(1,Xmask_f0m) < 0).*(Xmhu2(1,Xmask_f0m) > xmhubounce2(ir-1)));
            imhu0 = sum((Xmhu(1,Xmask_f0) < 0).*(Xmhu2(1,Xmask_f0) > xmhubounce2(ir))); 
            imhup = sum((Xmhu(1,Xmask_f0p) < 0).*(Xmhu2(1,Xmask_f0p) > xmhubounce2(ir+1)));
%
            XMr = XXMr(:,:,ir);
            XMr_t = XMr(:,Xmask_f0);%Matrix reduction along the angular direction (half-bounce region is removed)
            MMr_t = reshape(XMr_t',npn*(nmhu-ns_f(ir)),1,1);
            MMXR_f_t = MMXR_f_t + sparse([1+ib0:ibp],[1+ib0:ibp],MMr_t,nMMXP_f_t,nMMXP_f_t);
%           
            XMrp = XXMrp(:,:,ir);
            XMrp_t = XMrp(:,Xmask_f0);%Matrix reduction along the angular direction (half-bounce region is removed)
            XMrp1_t = XMrp_t.*(Xmhu(:,Xmask_f0) < 0).*(Xmhu2(:,Xmask_f0) > xmhubounce2(ir+1));
            XMrp2_t = XMrp_t.*(Xmhu(:,Xmask_f0) < 0).*(Xmhu2(:,Xmask_f0) < xmhubounce2(ir+1)).*(Xmhu2(:,Xmask_f0) > xmhubounce2(ir));
            XMrp3_t = XMrp_t.*(Xmhu(:,Xmask_f0) > 0);           
%           
            XMrm = XXMrm(:,:,ir);
            XMrm_t = XMrm(:,Xmask_f0);%Matrix reduction along the angular direction (half-bounce region is removed)
            XMrm1_t = XMrm_t.*(Xmhu(:,Xmask_f0) < 0).*(Xmhu2(:,Xmask_f0) > xmhubounce2(ir));
            XMrm2_t = XMrm_t.*(Xmhu(:,Xmask_f0) > 0);
%   
            for ip = 1:npn, 
               MMXR_f_t = MMXR_f_t + sparse([ib0+(nmhu-ns_f(ir))*(ip-1)+1:ib0+(nmhu-ns_f(ir))*(ip-1)+imhup],[ibp+(nmhu-ns_f(ir+1))*(ip-1)+1:ibp+(nmhu-ns_f(ir+1))*(ip-1)+imhup],XMrp1_t(ip,[1:imhup]),nMMXP_f_t,nMMXP_f_t);
               MMXR_f_t = MMXR_f_t + sparse([ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0+1:ib0+(nmhu-ns_f(ir))*ip],[ibp+(nmhu-ns_f(ir+1))*(ip-1)+imhup+1:ibp+(nmhu-ns_f(ir+1))*ip],XMrp3_t(ip,[imhu0+1:nmhu-ns_f(ir)]),nMMXP_f_t,nMMXP_f_t);
               MMXR_f_t = MMXR_f_t + sparse([ib0+(nmhu-ns_f(ir))*(ip-1)+imhup+1:ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0],...
               [ibp+(nmhu-ns_f(ir+1))*(ip-1)+((nmhu-ns_f(ir+1))-imhup):-1:ibp+(nmhu-ns_f(ir+1))*(ip-1)+((nmhu-ns_f(ir+1))-imhu0)+1],XMrp2_t(ip,[imhup+1:imhu0]),nMMXP_f_t,nMMXP_f_t);
%
               MMXR_f_t = MMXR_f_t + sparse([ib0+(nmhu-ns_f(ir))*(ip-1)+1:ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0],[ibm+(nmhu-ns_f(ir-1))*(ip-1)+1:ibm+(nmhu-ns_f(ir-1))*(ip-1)+imhu0],XMrm1_t(ip,[1:imhu0]),nMMXP_f_t,nMMXP_f_t);                
               MMXR_f_t = MMXR_f_t + sparse([ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0+1:ib0+(nmhu-ns_f(ir))*ip],[ibm+(nmhu-ns_f(ir-1))*(ip-1)+imhum+1:ibm+(nmhu-ns_f(ir-1))*ip],XMrm2_t(ip,[imhu0+1:nmhu-ns_f(ir)]),nMMXP_f_t,nMMXP_f_t);              
            end 
%
            if display_mode >= 1,info_dke_yp(2,['Configuration space matrix calculations (',int2str(ir),'/',int2str(nr),') done in ',num2str(etime(clock,time0)),' (s)']);etime_radial = etime_radial + etime(clock,time0);time0 = clock;end
         end
%
         ir = nr;
         ibm = max(cumsum(blocksize_f_t(1:ir-2)));%Block index reference
         ib0 = max(cumsum(blocksize_f_t(1:ir-1)));%Block index reference
         ibp = max(cumsum(blocksize_f_t(1:ir)));
%
         Xmask_f0m = (Xmhu2 < xmhubounce2(ir-1)) & (Xmhu < 0);%Only the half-bounce region is removed
         Xmask_f0m = nonzeros(~(Xmask_f0m(2,:)==1).*cumsum(ones(1,nmhu)))';
         Xmask_f0 = (Xmhu2 < xmhubounce2(ir)) & (Xmhu < 0);%Only the half-bounce region is removed
         Xmask_f0 = nonzeros(~(Xmask_f0(2,:)==1).*cumsum(ones(1,nmhu)))';
%   
         imhum = sum((Xmhu(1,Xmask_f0m) < 0).*(Xmhu2(1,Xmask_f0m) > xmhubounce2(ir-1)));
         imhu0 = sum((Xmhu(1,Xmask_f0) < 0).*(Xmhu2(1,Xmask_f0) > xmhubounce2(ir))); 
%
         XMr = XXMr(:,:,ir);
         XMr_t = XMr(:,Xmask_f0);%Matrix reduction along the angular direction (half-bounce region is removed)
         MMr_t = reshape(XMr_t',npn*(nmhu-ns_f(ir)),1,1);
         MMXR_f_t = MMXR_f_t + sparse([1+ib0:ibp],[1+ib0:ibp],MMr_t,nMMXP_f_t,nMMXP_f_t);
%           
         XMrm = XXMrm(:,:,ir);
         XMrm_t = XMrm(:,Xmask_f0);%Matrix reduction along the angular direction (half-bounce region is removed)
         XMrm1_t = XMrm_t.*(Xmhu(:,Xmask_f0) < 0).*(Xmhu2(:,Xmask_f0) > xmhubounce2(ir));
         XMrm2_t = XMrm_t.*(Xmhu(:,Xmask_f0) > 0);
%   
         for ip = 1:npn, 
            MMXR_f_t = MMXR_f_t + sparse([ib0+(nmhu-ns_f(ir))*(ip-1)+1:ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0],[ibm+(nmhu-ns_f(ir-1))*(ip-1)+1:ibm+(nmhu-ns_f(ir-1))*(ip-1)+imhu0],XMrm1_t(ip,[1:imhu0]),nMMXP_f_t,nMMXP_f_t);                
            MMXR_f_t = MMXR_f_t + sparse([ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0+1:ib0+(nmhu-ns_f(ir))*ip],[ibm+(nmhu-ns_f(ir-1))*(ip-1)+imhum+1:ibm+(nmhu-ns_f(ir-1))*ip],XMrm2_t(ip,[imhu0+1:nmhu-ns_f(ir)]),nMMXP_f_t,nMMXP_f_t);              
         end
%
         if display_mode >= 1,info_dke_yp(2,['Configuration space matrix calculations (',int2str(ir),'/',int2str(nr),') done in ',num2str(etime(clock,time0)),' (s)']);etime_radial = etime_radial + etime(clock,time0);time0 = clock;end
         time0 = clock;
%
         save([fullfile(temppath,'temp_DKE_'),save_id,'.mat'],'MMXR_f_t');
         if display_mode >= 1,info_dke_yp(2,['Radial Matrix saved.']);end	
%
         if display_mode >= 1,info_dke_yp(2,['Zero order configuration space matrix calculations done in ',num2str(etime_radial),' (s)']);end
      end 
   end
else
    MMXR_f_t = sparse(nMMXP_f_t,nMMXP_f_t);%Create empty supermatrix
end

    
