function writeCloopinput_dke_ft(nit_f,boundary_mode_f,bounce_mode,coll_mode,norm_mode_f,prec0_f,display_mode,betath_ref,xTe_norm,xne_norm,dtn,mhu,nmhu,npn,ns_f,nr,sm_f,...
   masku,maskl,dpn,dmhu,xpn,xpn2,xpn3,xsigma,xgamma,xz,xz2,pn,pn2,pn3,...
   sigma,gamma,z,z2,xJ1,xJ2,xJ3,xJ4,J1,J2,J3,J4,...
   Xmhu,XXsinksource,Xmask_r_edge,XXfM,XXfinit,XXRlambda_b_p1p1,rdke,Xpn2,Zpn2_t,...
   Zmask_f0_t,...
   MMXT_f_t,MMXR_f_t,MMXP_f_t,MMXPC_f_t,MMXPDI_f_t,...
   XXI,XXf0,time_scheme,dkepath)
%
% Write input parameters for internal C loop (unsing PETSc)
%
%   INPUTS:
%
%       - list of parmeters above
%
%   OUTPUTS:
%   
%       - none
%
% by Frédéric Teisseire (CEA/DRFC), Yves Peysson <yves.peysson@cea.fr> (CEA/DRFC) and Joan Decker <joan.decker@cea.fr> (CEA/DRFC)
%
%
% Writing loop constants and initializing variables
% Control parameters
%
writeBinaryIntArray_mex_c([dkepath.variables.input,'/nit_f'],int32(nit_f));
writeBinaryIntArray_mex_c([dkepath.variables.input,'/boundary_mode_f'],int32(boundary_mode_f));
writeBinaryIntArray_mex_c([dkepath.variables.input,'/bounce_mode'],int32(bounce_mode));
writeBinaryIntArray_mex_c([dkepath.variables.input,'/coll_mode'],int32(coll_mode));
writeBinaryIntArray_mex_c([dkepath.variables.input,'/norm_mode_f'],int32(norm_mode_f));
writeBinaryTensor_mex_c([dkepath.variables.input,'/prec0_f'],prec0_f);
writeBinaryIntArray_mex_c([dkepath.variables.input,'/display_mode'],int32(display_mode));
%
%Writing Binary files
%
writeBinaryTensor_mex_c([dkepath.variables.input,'/betath_ref'],betath_ref);
writeBinaryTensor_mex_c([dkepath.variables.input,'/xTe_norm'],xTe_norm);
writeBinaryTensor_mex_c([dkepath.variables.input,'/xne_norm'],xne_norm);
writeBinaryTensor_mex_c([dkepath.variables.input,'/dtn'],dtn);
writeBinaryTensor_mex_c([dkepath.variables.input,'/mhu'],mhu);
writeBinaryIntArray_mex_c([dkepath.variables.input,'/nmhu'],int32(nmhu));
writeBinaryIntArray_mex_c([dkepath.variables.input,'/npn'],int32(npn));
writeBinaryIntArray_mex_c([dkepath.variables.input,'/ns_f'],int32(ns_f));
writeBinaryIntArray_mex_c([dkepath.variables.input,'/nr'],int32(nr));
writeBinaryIntArray_mex_c([dkepath.variables.input,'/sm_f'],int32(sm_f));
% 
writeBinaryTensor_mex_c([dkepath.variables.input,'/masku'],masku);
writeBinaryTensor_mex_c([dkepath.variables.input,'/maskl'],maskl)
writeBinaryTensor_mex_c([dkepath.variables.input,'/dpn'],dpn);
writeBinaryTensor_mex_c([dkepath.variables.input,'/dmhu'],dmhu);
writeBinaryTensor_mex_c([dkepath.variables.input,'/xpn'],xpn);
writeBinaryTensor_mex_c([dkepath.variables.input,'/xpn2'],xpn2);
writeBinaryTensor_mex_c([dkepath.variables.input,'/xpn3'],xpn3);
writeBinaryTensor_mex_c([dkepath.variables.input,'/xsigma'],xsigma);
writeBinaryTensor_mex_c([dkepath.variables.input,'/xgamma'],xgamma);
writeBinaryTensor_mex_c([dkepath.variables.input,'/xz'],xz);
writeBinaryTensor_mex_c([dkepath.variables.input,'/xz2'],xz2);
writeBinaryTensor_mex_c([dkepath.variables.input,'/pn'],pn);
writeBinaryTensor_mex_c([dkepath.variables.input,'/pn2'],pn2);
writeBinaryTensor_mex_c([dkepath.variables.input,'/pn3'],pn3);
writeBinaryTensor_mex_c([dkepath.variables.input,'/sigma'],sigma);
writeBinaryTensor_mex_c([dkepath.variables.input,'/gamma'],gamma);
writeBinaryTensor_mex_c([dkepath.variables.input,'/z'],z);
writeBinaryTensor_mex_c([dkepath.variables.input,'/z2'],z2);
writeBinaryTensor_mex_c([dkepath.variables.input,'/xJ1'],xJ1);
writeBinaryTensor_mex_c([dkepath.variables.input,'/xJ2'],xJ2);
writeBinaryTensor_mex_c([dkepath.variables.input,'/xJ3'],xJ3);
writeBinaryTensor_mex_c([dkepath.variables.input,'/xJ4'],xJ4);
writeBinaryTensor_mex_c([dkepath.variables.input,'/J1'],J1);
writeBinaryTensor_mex_c([dkepath.variables.input,'/J2'],J2);
writeBinaryTensor_mex_c([dkepath.variables.input,'/J3'],J3);
writeBinaryTensor_mex_c([dkepath.variables.input,'/J4'],J4);
%
writeBinaryTensor_mex_c([dkepath.variables.input,'/Xmhu'],Xmhu);
writeBinaryTensor_mex_c([dkepath.variables.input,'/XXsinksource'],XXsinksource);
writeBinaryTensor_mex_c([dkepath.variables.input,'/Xmask_r_edge'],Xmask_r_edge);
writeBinaryTensor_mex_c([dkepath.variables.input,'/XXfM'],XXfM);
writeBinaryTensor_mex_c([dkepath.variables.input,'/XXfinit'],XXfinit);
writeBinaryTensor_mex_c([dkepath.variables.input,'/XXRlambda_b_p1p1'],XXRlambda_b_p1p1);
writeBinaryTensor_mex_c([dkepath.variables.input,'/rdke'],rdke);
writeBinaryTensor_mex_c([dkepath.variables.input,'/Xpn2'],Xpn2);
writeBinaryArray_mex_c([dkepath.variables.input,'/Zpn2_t'],Zpn2_t);
%
% for i=1:length(Zmask_g)
%     Zmask_g2{i}=int32(Zmask_g{i})
% end
%writeBinaryArray_mex_c([dkepath.variables.input,'/Zmask_g'],Zmask_g2);
%
for i=1:length(Zmask_f0_t)
    Zmask_f0_t2{i}=int32(Zmask_f0_t{i});
end
writeBinaryIntArray_mex_c([dkepath.variables.input,'/Zmask_f0_t'],Zmask_f0_t2);
%
%SparseMats
%
writeBinarySparseMat_mex_c([dkepath.variables.input,'/MMXT_f_t'],MMXT_f_t);
writeBinarySparseMat_mex_c([dkepath.variables.input,'/MMXR_f_t'],MMXR_f_t);
writeBinarySparseMat_mex_c([dkepath.variables.input,'/MMXP_f_t'],MMXP_f_t);
writePetscBin_DKE_ft([dkepath.variables.input,'/PMMXPC_f_t'],MMXPC_f_t,0,0);
writeBinarySparseMat_mex_c([dkepath.variables.input,'/MMXPC_f_t'],MMXPC_f_t); 
writeBinarySparseMat_mex_c([dkepath.variables.input,'/MMXPDI_f_t'],MMXPDI_f_t);
%
% Initializing
%
writeBinaryTensor_mex_c([dkepath.variables.input,'/XXI'],XXI);
writeBinaryTensor_mex_c([dkepath.variables.input,'/XXf0'],XXf0);
writeBinaryTensor_mex_c([dkepath.variables.input,'/time_scheme'],time_scheme);
