function [XXRS,xRL]=runaway_sinksource(dkeparam,mksa,gridDKE,equilDKE,Zbouncecoef,Zmomcoef,xne,xnr_loss,ohm,Xxpnlim)

% Calculates the Runaway Secondary (Avalanche) Source and Loss Terms, bounce-averaged or not
% the results are NOT normalized.         15/06/2007  modified  11/07/07

% INPUT
%
%     - dkeparam : simulation parameters
%     - mksa : normalization constants
%     - gridDKE : grid parameters
%     - equilDKE : magnetic equilibrium interpolated on the resolution grid
%     - Zbouncecoef : used to get lambda and qtilde, (bounce-averaging parameters)
%     - Zmomcoef : used to get gamma and XXgamma
%     - ohm : electric field (used to know the propagation direction of the runaway (opposed to the
%                            electric field)
%     - xnr_loss : density of already existing runaway electrons (1 nr)
%     - xne : density of thermal electron likely to be collided (inside Xxpnlim)
%     - Xxpnlim : momentum separating the source and loss domain of the
%                collision process (purely conventionnal) (nmhu nr)
%               

% OUTPUT
%
%     - XXSR : Runaway Secondary Source  (npn, nmhu, nr)
%     - xRL  : Runaway Secondary Loss of the termal bulk  (1,nr)
%
% the theta grid has to be uniform (if not, a line must be changed) 
%   
% The loss term is calculated as the integral of the source term on the
% outward domain delimited by Xxpnlin
%
% The source term is given everywhere. Caution : the bounce-averaged sounce
% term is not rigourously correct : the symmetry of the trapped region has 
% still to be enforced (cf the note on the report). This has been done
% in sinksourcecoeffbuilder.m .
%
if nargin < 8,
    error('Not enough input arguments');
end
%
%    Initialisation
%
bounce_mode=dkeparam.bounce_mode;
%
betath_ref=mksa.betath_ref;
lnc_e_ref=mksa.lnc_e_ref;
nhu_ref=mksa.nhu_ref;
ne_ref=mksa.ne_ref;
%
XXgamma=Zmomcoef.XXgamma;
XXpn=gridDKE.XXpn;
XXmhu=gridDKE.XXmhu;
gamma=Zmomcoef.gamma;
mhu=gridDKE.mhu;
npn=gridDKE.npn;
nmhu=gridDKE.nmhu;
nr=gridDKE.nr;
%
XXnebar=permute(repmat(xne/mksa.ne_ref,[npn 1 nmhu]),[1 3 2]);
XXnrbar=permute(repmat(xnr_loss/mksa.ne_ref,[npn 1 nmhu]),[1 3 2]);
%
dir=ohm.epsi(1)/abs(ohm.epsi(1)); %runaway propagation direction  CAUTION
% it depends on the convention on the sign of the E field. Here, runaway electrons
% moves towards mhu=+1 for E > 0.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% bounce-averaged source term
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if bounce_mode==1   
    %
    XXthetaT=zeros(npn,nmhu,nr);
    XXRS=zeros(npn,nmhu,nr);
    %
    XXB0=permute(repmat(equilDKE.xB0,[npn 1 nmhu]),[1 3 2]);
    ap=equilDKE.ap;
    XXqtilde=permute(repmat(Zbouncecoef.xqtilde,[npn 1 nmhu]),[1 3 2]);
    XXlambda=permute(repmat(Zbouncecoef.Xxlambda,[1 1 npn]),[3 1 2]);  %Xxlambda was (nmhu,nr)
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Theta star depending term calculation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    theta_S=equilDKE.mtheta;
    ntheta_S=length(theta_S);
    %
    dtheta=zeros(1,ntheta_S-1);
    dtheta=theta_S(2:end)-theta_S(1:end-1);
    %
    XXBstar=2*XXB0./( (1-XXmhu.^2).*(1+XXgamma)); %field to be interpolated
    YxBstar=reshape(XXBstar,[npn*nmhu nr]);
    %
    XB=sqrt(equilDKE.XBx.^2+equilDKE.XBy.^2+equilDKE.XBphi.^2);
    %
    xBmax=XB(:,(ntheta_S+1)/2); %Attention (nr,1)
    YxBmax=permute(repmat(xBmax,[1 npn*nmhu]),[2 1]); %(np*nmhu nr)
    YxB0=reshape(XXB0,[npn*nmhu nr]);
    %
    Ymhu=reshape(XXmhu,[1,npn*nmhu]); %for direction selection
    %
    for ir=1:nr
        %
        YthetaT=zeros(1,npn*nmhu); %to be used as transfer variable in the interpolation loop
        %
        Ymask=find(YxBmax(:,ir)>=YxBstar(:,ir) & YxBstar(:,ir)>=YxB0(:,ir) & Ymhu(:)*dir>=0 ); % Existence domain of thetastar for a given value of r
        %        
        YB=YxBstar(Ymask,ir);
        Bx=equilDKE.XBx(ir,:);
        By=equilDKE.XBy(ir,:);
        Bphi=equilDKE.XBphi(ir,:);  
        x=equilDKE.Xx(ir,:);
        y=equilDKE.Xy(ir,:);
        %
        %
        % Matrix to be interpolated at thetastar
        r_S=sqrt(x.^2+y.^2);   % (1;ntheta_S)
        Bp_S=sqrt(Bx.^2+By.^2);  % (1;ntheta_S)
        Psipr_S=abs(Bx.*y - By.*x)./(Bp_S.*r_S);  % (1;ntheta_S)
        %
        B0=equilDKE.xB0(ir); % scalar
        Psi_S=sqrt(Bx.^2+By.^2+Bphi.^2)./B0;% (1;ntheta_S)
        dPsidtheta_S=zeros(1,ntheta_S);
        dPsidtheta=zeros(1,ntheta_S);
        dPsidtheta(2:end)=(Psi_S(2:end)-Psi_S(1:end-1))./(dtheta); %on the half grid
        dPsidtheta(1)=dPsidtheta(end); % periodicity
        dPsidtheta_S(1:end-1)=(dPsidtheta(1:end-1)+dPsidtheta(2:end))/2; 
        % here, the full grid is in the middle of the half grid
        % as the theta grid is uniform
        dPsidtheta_S(end)=dPsidtheta_S(1); %periodicity
        %
        YT=zeros(ntheta_S,1,4);  %the second 1 is nr, here =1 beacause of the loop - to be adjusted
        YT(:,1,1)=r_S(:);
        YT(:,1,2)=Bp_S(:);
        YT(:,1,3)=Psipr_S(:);
        YT(:,1,4)=dPsidtheta_S(:); %(4, ntheta)
        %
        % Each term, and especially dPsidtheta, has to be interpolated
        % separately in order to preserve the source-term integrability.
        % Do not interpolate directly 1/dPsidtheta
        %
        [Ytheta_star1,Ytheta_star2,YT1,YT2] =...
        interp_theta_jd(theta_S,Bx',By',Bphi',YB',YT);    
        %
        r1=YT1(1,:,1);
        Bp1=YT1(1,:,2);
        Psipr1=YT1(1,:,3);
        dPsidtheta1=YT1(1,:,4);
        %
        r2=YT2(1,:,1);
        Bp2=YT2(1,:,2);
        Psipr2=YT2(1,:,3);
        dPsidtheta2=YT2(1,:,4);
        %        
        YmaskthetaT1=r1./(Bp1.*Psipr1.*abs(dPsidtheta1)); 
        YmaskthetaT2=r2./(Bp2.*Psipr2.*abs(dPsidtheta2)); 
        %
        YmaskthetaT = YmaskthetaT1 + YmaskthetaT2; 
        YthetaT(Ymask)=YmaskthetaT;
        XXthetaT(:,:,ir)= reshape(YthetaT,[npn nmhu]);
        %
    end
    %
    % Preliminary Constant Calcutation
    C = (nhu_ref*ne_ref)*(1/(2*pi))*(1/(pi*lnc_e_ref*ap));
    %
    % Final bounce-averaged result
    XXRS=C*(XXB0./(XXlambda.*XXqtilde)).*XXnebar.*XXnrbar.*(1./(XXgamma.*XXpn.^3.*(XXgamma-1))).*( abs(XXmhu)./((1-XXmhu.^2).^2)) .*XXthetaT;
    %
else
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % source term without bounce-average
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    XXmhustarval= dir * sqrt((XXgamma-1)./(XXgamma+1));
    XXmhustar=interp1(mhu,mhu,XXmhustarval,'nearest');    
    XXdeltastar=(XXmhu==XXmhustar);        
    XXdmhu=repmat(gridDKE.dmhu,[npn 1 nr]);
    %
    XXRS=(nhu_ref*ne_ref)*(betath_ref^2)/(4*pi*lnc_e_ref).*XXnebar.*XXnrbar.*(1./(XXgamma.*XXpn.*(XXgamma-1).^2)).*XXdeltastar./XXdmhu;
    %
end

%%%%%%%%%% Loss term, calculated using partially analytical integration %%%%%%%%%
%
xRL=zeros(1,nr);
mhustarval= dir*sqrt( (gamma-1)./(gamma+1) );
mhustar=interp1(mhu(1:end),[1:nmhu]',mhustarval,'nearest');
%
%
for ir=1:gridDKE.nr
    H=(gridDKE.pn(:)>=Xxpnlim(mhustar(:),ir));
    if sum(H)>0
        xRL(ir)=(nhu_ref*ne_ref)*((betath_ref^(5)*(xnr_loss(ir)/ne_ref)*(xne(ir)/ne_ref))/(2*lnc_e_ref))*integral_dke_jd(gridDKE.dpn(H),(gridDKE.pn(H))./(gamma(H).*(gamma(H)-1).^2),2); 
    else
        xRL(ir)=0;
    end
end


%%%%% Complementary loss term %%%%%%%%%%%%%%%%%%%%%
% Loss term
xRLC=zeros(1,nr);
xRLC(:)=(nhu_ref*(mksa.betath_ref)^3*xne(:).*xnr_loss(:)./(2*mksa.lnc_e_ref*ne_ref)).*(1./(sqrt(1+(mksa.betath_ref*dkeparam.pnmax_S)^2)-1) ) ;

xRL=xRL+xRLC;

%if sum(xRL<=0)>0 keyboard; end