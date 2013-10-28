function [brem_bd_out,lchord] = loop_brem_chord_yp(mode,n_pol,kphot,cL,ZZIB,datahxr_in)
%R5-X2 - Calculation of  the line-integrated plasma bremsstrahlung emission (for parallel processing or GPU)
%
% Calculation of  the line-integrated plasma bremsstrahlung emission (for parallel processing or GPU)
%
% by Yves Peysson(CEA/IRFM,yves.peysson@cea.fr) and Joan Decker (CEA/IRFM,joan.decker@cea.fr) 
%
s_mask = ~isnan(datahxr_in.vschords(7,:));%Location where chord is inside the plasma
s_length = sum(s_mask);%Number of points along the chord inside the plasma
ir_spsi = datahxr_in.vschords(8,s_mask);
it_st = datahxr_in.vschords(9,s_mask);
%
IB1 = zeros(size(ZZIB,3),s_length,size(ZZIB,4));
%
nstep = 199;%In order to avoid use of too large multidimensional tables (limitation of MatLab)
jmax = floor(s_length/nstep)+1;
%
index_test = [(jmax-1)*nstep+1:jmax*nstep];
index_test = index_test(index_test<=s_length);
if length(index_test) == 1,%In order to avoid this case which generates an error for the line  "IB1(:,index,:) = permute(squeeze(IB(:,1,:,:)),[2,1,3]);"
    nstep = nstep - 1;
     jmax = floor(s_length/nstep)+1;
end
%	
for j = 1:jmax,
    index = [(j-1)*nstep+1:j*nstep];
    index = index(index<=s_length);
    if isempty(index) ~= 1
        IB = ZZIB(ir_spsi(index),it_st(index),:,:);
        IB1(:,index,:) = permute(squeeze(IB(:,1,:,:)),[2,1,3]);
    end
end
%
sksid = datahxr_in.vschords(10,s_mask);%nothing when taking the exact magnetic topology
if mode == 0,
    sksid = sksid*0;%exact perpendicular observation, no heliticity effect
elseif mode == 1,
    sksid = sksid*0 + 1;%exact forward observation, no heliticity effect
elseif mode == -1,
    sksid = sksid*0 - 1;%exact backward observation, no heliticity effect
end
%
[Pm_bd] = leg_dke_yp(sksid,n_pol);%Legendre polynomial for the cosine of the angle between magnetic field line and line of sight (negative sign because electrons are flowing in the opposite direction to the plasma current)
Pm_bd1 = repmat(Pm_bd,[1,1,length(kphot)]);
%	
cL1 = repmat(cL,[1,length(ir_spsi),length(kphot)]);
%
brem_bd = squeeze(sum(Pm_bd1.*IB1.*cL1,1));%Local bremsstrahlung emission in the direction of the detector
%	
s = datahxr_in.vschords(1,s_mask);
if size(s,2) > 0
   s = s - s(1);%s=0 where the chord enter the plasma towards the detector
   ds = [diff(s),0];%Elementary chord length for integration
   ds1 = repmat(ds',[1,length(kphot)]);
%
    brem_bd_out = sum(ds1.*brem_bd,1)*datahxr_in.EG_hxr;%Integration along the chord and multiplication by the geometrical factor
    lchord = sum(ds);%Chord length calculation
else
    brem_bd_out = 0;%Integration along the chord and multiplication by the geometrical factor
    lchord = 0;%Chord length calculation	   	
end
%
