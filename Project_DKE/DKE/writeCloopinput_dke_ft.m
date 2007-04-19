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
if ~exist([dkepath.temppath,'/DKESolver_variables']),
	mkdir([dkepath.temppath,'/DKESolver_variables']);%Create input directory    
end
if ~exist([dkepath.temppath,'/DKESolver_output']),
	mkdir([dkepath.temppath,'/DKESolver_output']);%Create output directory    
end
%
writeBinaryIntArray_mex_c([dkepath.temppath,'/DKESolver_variables/nit_f'],int32(nit_f));
writeBinaryIntArray_mex_c([dkepath.temppath,'/DKESolver_variables/boundary_mode_f'],int32(boundary_mode_f));
writeBinaryIntArray_mex_c([dkepath.temppath,'/DKESolver_variables/bounce_mode'],int32(bounce_mode));
writeBinaryIntArray_mex_c([dkepath.temppath,'/DKESolver_variables/coll_mode'],int32(coll_mode));
writeBinaryIntArray_mex_c([dkepath.temppath,'/DKESolver_variables/norm_mode_f'],int32(norm_mode_f));
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/prec0_f'],prec0_f);
writeBinaryIntArray_mex_c([dkepath.temppath,'/DKESolver_variables/display_mode'],int32(display_mode));
%
%Writing Binary files
%
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/betath_ref'],betath_ref);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/xTe_norm'],xTe_norm);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/xne_norm'],xne_norm);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/dtn'],dtn);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/mhu'],mhu);
%
writeBinaryIntArray_mex_c([dkepath.temppath,'/DKESolver_variables/nmhu'],int32(nmhu));
writeBinaryIntArray_mex_c([dkepath.temppath,'/DKESolver_variables/npn'],int32(npn));
writeBinaryIntArray_mex_c([dkepath.temppath,'/DKESolver_variables/ns_f'],int32(ns_f));
writeBinaryIntArray_mex_c([dkepath.temppath,'/DKESolver_variables/nr'],int32(nr));
writeBinaryIntArray_mex_c([dkepath.temppath,'/DKESolver_variables/sm_f'],int32(sm_f));
% 
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/masku'],masku);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/maskl'],maskl)
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/dpn'],dpn);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/dmhu'],dmhu);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/xpn'],xpn);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/xpn2'],xpn2);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/xpn3'],xpn3);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/xsigma'],xsigma);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/xgamma'],xgamma);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/xz'],xz);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/xz2'],xz2);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/pn'],pn);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/pn2'],pn2);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/pn3'],pn3);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/sigma'],sigma);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/gamma'],gamma);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/z'],z);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/z2'],z2);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/xJ1'],xJ1);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/xJ2'],xJ2);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/xJ3'],xJ3);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/xJ4'],xJ4);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/J1'],J1);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/J2'],J2);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/J3'],J3);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/J4'],J4);
%
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/Xmhu'],Xmhu);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/XXsinksource'],XXsinksource);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/Xmask_r_edge'],Xmask_r_edge);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/XXfM'],XXfM);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/XXfinit'],XXfinit);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/XXRlambda_b_p1p1'],XXRlambda_b_p1p1);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/rdke'],rdke);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/Xpn2'],Xpn2);
writeBinaryArray_mex_c([dkepath.temppath,'/DKESolver_variables/Zpn2_t'],Zpn2_t);
%
% for i=1:length(Zmask_g)
%     Zmask_g2{i}=int32(Zmask_g{i})
% end
%writeBinaryArray_mex_c([dkepath.temppath,'/DKESolver_variables/Zmask_g'],Zmask_g2);
%
for i=1:length(Zmask_f0_t)
    Zmask_f0_t2{i}=int32(Zmask_f0_t{i});
end
writeBinaryIntArray_mex_c([dkepath.temppath,'/DKESolver_variables/Zmask_f0_t'],Zmask_f0_t2);
%
%SparseMats
%
writeBinarySparseMat_mex_c([dkepath.temppath,'/DKESolver_variables/MMXT_f_t'],MMXT_f_t);
writeBinarySparseMat_mex_c([dkepath.temppath,'/DKESolver_variables/MMXR_f_t'],MMXR_f_t);
writeBinarySparseMat_mex_c([dkepath.temppath,'/DKESolver_variables/MMXP_f_t'],MMXP_f_t);
writePetscBin_DKE_ft([dkepath.temppath,'/DKESolver_variables/PMMXPC_f_t'],MMXPC_f_t,0,0);
writeBinarySparseMat_mex_c([dkepath.temppath,'/DKESolver_variables/MMXPC_f_t'],MMXPC_f_t); 
writeBinarySparseMat_mex_c([dkepath.temppath,'/DKESolver_variables/MMXPDI_f_t'],MMXPDI_f_t);
%
% Initializing
%
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/XXI'],XXI);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/XXf0'],XXf0);
writeBinaryTensor_mex_c([dkepath.temppath,'/DKESolver_variables/time_scheme'],time_scheme);
%
debug_petsc = 0;
if debug_petsc,
    nit_f_out = ReadBinaryIntArray_mex_c([dkepath.temppath,'/DKESolver_variables/nit_f']);nit_f,nit_f_out
    boundary_mode_f_out = ReadBinaryIntArray_mex_c([dkepath.temppath,'/DKESolver_variables/boundary_mode_f']);boundary_mode_f,boundary_mode_f_out
    bounce_mode_out = ReadBinaryIntArray_mex_c([dkepath.temppath,'/DKESolver_variables/bounce_mode']);bounce_mode,bounce_mode_out
    coll_mode_out = ReadBinaryIntArray_mex_c([dkepath.temppath,'/DKESolver_variables/coll_mode']);coll_mode,coll_mode_out
    norm_mode_f_out = ReadBinaryIntArray_mex_c([dkepath.temppath,'/DKESolver_variables/norm_mode_f']);norm_mode_f,norm_mode_f_out
    prec0_f_out = ReadBinaryArray_mex_c([dkepath.temppath,'/DKESolver_variables/prec0_f']);prec0_f,prec0_f_out
    display_mode_out = ReadBinaryIntArray_mex_c([dkepath.temppath,'/DKESolver_variables/display_mode']);display_mode,display_mode_out
%
    nmhu_out = ReadBinaryIntArray_mex_c([dkepath.temppath,'/DKESolver_variables/nmhu']);nmhu,nmhu_out
    npn_out = ReadBinaryIntArray_mex_c([dkepath.temppath,'/DKESolver_variables/npn']);npn,npn_out
    ns_f_out = ReadBinaryIntArray_mex_c([dkepath.temppath,'/DKESolver_variables/ns_f']);ns_f,ns_f_out
    nr_out = ReadBinaryIntArray_mex_c([dkepath.temppath,'/DKESolver_variables/nr']);nr,nr_out
    sm_f_out = ReadBinaryIntArray_mex_c([dkepath.temppath,'/DKESolver_variables/sm_f']);sm_f,sm_f_out    
end
