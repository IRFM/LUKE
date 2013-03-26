function [varargout] = buildlukestruct_yp(loadstruct,equil,dkeparam_in,display,dkepath,ohm,waves,transpfaste,ripple,XXf0_in,XXsinksource_in)
%
% Build main structures for LUKE that can be used also for other purposes
%
% INPUT
%    - equil: axisymmetric toroidal magnetic equilibrium
%    - dkeparam_in: dkeparam structure
%    - display: dkedisplay structure
%    - loadstruct: structure for reloading data already calculated. 
%
% OUTPUT: 
%    - variable outputs depending upon the input mode
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
if ischar(loadstruct) && nargout ~= 1,
    error('There must be exactly one output argument in buildlukestruct_yp.m when a specific structure is requested.');
end
%
dkeparam_out = paramconsistency_dke_yp(dkeparam_in,equil);%Check consistency between input parameters
%
% Load data if existing in 'loadstruct' structure or recalculate them if not exists
%
radialDKE = make_struct_jd(loadstruct,display.display_mode,'radialgrid_dke_jd',equil,dkeparam_out,display);%Radial grid for DKE    
equilDKE = make_struct_jd(loadstruct,display.display_mode,'equilibrium_jd',equil,radialDKE,display,'spline',dkeparam_out.mfactor);%Magnetic equilibrium for DKE
momentumDKE = make_struct_jd(loadstruct,display.display_mode,'momentumgrid_dke_jd',dkeparam_out,equilDKE,radialDKE);%Momentum space 2D grid for DKE
gridDKE = make_struct_jd(loadstruct,display.display_mode,'matrix3Dgridbuilder_dke_yp',dkeparam_out,display,equilDKE,radialDKE,momentumDKE);%General grid structure for the DKE solver
%
mksa = make_struct_jd(loadstruct,display.display_mode,'mksacoefbuilder_dke_yp',dkeparam_out,display,equilDKE,radialDKE);%MKSA quantities calculations
if ischar(loadstruct) && strcmp(loadstruct,'mksa'),
    varargout{1} = mksa;
    return
end
%
Zmomcoef = make_struct_jd(loadstruct,display.display_mode,'momentumcoefbuilder_dke_yp',gridDKE,mksa);%Momentum space coefficients for FP calculations
if ischar(loadstruct) && strcmp(loadstruct,'Zmomcoef'),
    varargout{1} = Zmomcoef;
    return
end
%
Zbouncecoef = make_struct_jd(loadstruct,display.display_mode,'bouncecoefbuilder_dke_yp',dkeparam_out,display,equilDKE,gridDKE);%bounce averaging coefficients
if ischar(loadstruct) && strcmp(loadstruct,'Zbouncecoef'),
    varargout{1} = Zbouncecoef;
    return
end
%
XXsinksource = make_struct_jd(loadstruct,display.display_mode,'sinksourcecoeffbuilder_dke_yp',dkeparam_out,display,gridDKE,mksa,Zbouncecoef,XXsinksource_in);%External sink and source contributions (for right-hand side part of the FP equation)
Zmripple = make_struct_jd(loadstruct,display.display_mode,'mripplecoefbuilder_dke_yp',dkeparam_out,display,equil,equilDKE,gridDKE,mksa,ripple);%Magnetic ripple matrix coefficients
[ZXXD_a,ZXXF_a] = make_struct_jd(loadstruct,display.display_mode,'rad_dke_yp',dkeparam_out,display,equilDKE,gridDKE,mksa,Zbouncecoef,Zmomcoef,transpfaste);%Anomalous radial transport super matrix
[ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,XXfM,XXILor] = make_struct_jd(loadstruct,display.display_mode,'coll_dke_jd',dkepath,dkeparam_out,display,equilDKE,mksa,gridDKE,Zmomcoef,Zbouncecoef);%Collisions flux coefficients 
[ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,xepsi,xEfield_validity] = make_struct_jd(loadstruct,display.display_mode,'efield_dke_jd',dkepath,dkeparam_out,display,equilDKE,mksa,gridDKE,Zmomcoef,Zbouncecoef,ohm,ZXXF_c);%Electric field flux coefficients
[waveparam,xyprop_dke,xyP0_2piRp_mod,yb,yP0_2piRp,xys] = make_struct_jd(loadstruct,display.display_mode,'rfwave_dke_jd',dkeparam_out,display,equil,equilDKE,gridDKE,Zbouncecoef,mksa,waves);%RF wave parameters preprocessing calculations
%
if strcmp(waveparam.model,'RT'),% ray tracing simulation
    [ZXYD_rf,ZXYF_rf,ZXYD_rf_tp,ZXYF_rf_tp,gridindex_rf] = make_struct_jd(loadstruct,display.display_mode,'rfdiff_dke_jd',dkeparam_out,display,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,mksa,radialDKE,waveparam);%RF waves flux coefficients
elseif strcmp(waveparam.model,'FW_BIL')%full wave model by R. Bilato
    [ZXYD_rf,ZXYF_rf,ZXYD_rf_tp,ZXYF_rf_tp,gridindex_rf] = make_struct_jd(loadstruct,display.display_mode,'rfdiff_dke_fw_jd',dkeparam_out,display,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,mksa,radialDKE,waves);%RF waves flux coefficients
else
  error('Wave model not implemented')
end
%
[XXfinit] = make_struct_jd(loadstruct,display.display_mode,'finit_dke_yp',dkeparam_out,display,equilDKE,gridDKE,mksa,Zmomcoef,waveparam,XXf0_in);%Initial distribution function
%
varargout_loc = {dkeparam_out,radialDKE,equilDKE,momentumDKE,gridDKE,mksa,Zmomcoef,Zbouncecoef,XXsinksource,Zmripple,...
                 ZXXD_a,ZXXF_a,...
                 ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,XXfM,XXILor,...
                 ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,xepsi,xEfield_validity,...
                 waveparam,xyprop_dke,xyP0_2piRp_mod,yb,yP0_2piRp,xys,...
                 ZXYD_rf,ZXYF_rf,ZXYD_rf_tp,ZXYF_rf_tp,gridindex_rf,...
                 XXfinit};
%
varargout = varargout_loc(1:nargout);
%