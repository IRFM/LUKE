%************************************** HARD X-RAY CONFIGURATION ********************************************
%******************************************************************************************************************
% Create the local file HXR_hxr_id.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
hxr_id = 'TS99';%Set here the name (identifier) of the Hard X-ray configuration
%
%
%Fast electron bremsstrahlung tomography (if exists)
%
[alpha_hxr,beta_hxr,R_hxr,Z_hxr,EG_hxr,kd_hxr,phf_hxr,res_hxr,ef_hxr,tf_hxr,ea_hxr,ta_hxr,ec_hxr,tc_hxr,ed_hxr,td_hxr,kdiag_hxr] = bremTSconvert_dke_yp(1,10,1999);%Specific function for Tore Supra
%
hxr.alpha_hxr = alpha_hxr;
hxr.beta_hxr = beta_hxr;
hxr.R_hxr = R_hxr;
hxr.Z_hxr = Z_hxr;
hxr.EG_hxr = EG_hxr;
hxr.kd_hxr = kd_hxr;
hxr.phf_hxr = phf_hxr;
hxr.res_hxr = res_hxr;
hxr.ef_hxr = ef_hxr;
hxr.tf_hxr = tf_hxr;
hxr.ea_hxr = ea_hxr;
hxr.ta_hxr = ta_hxr;
hxr.ec_hxr = ec_hxr;
hxr.tc_hxr = tc_hxr;
hxr.ed_hxr = ed_hxr;
hxr.td_hxr = td_hxr;
hxr.kdiag_hxr = kdiag_hxr;
hxr.kphot = [20:10:180];%Photon energy in keV
hxr.n_gauleg = 35;%Number of Legendre polynomials for prjections of cross-section and distribution
hxr.epsi_gauleg = 1e-14;%Accuracy of the Legendre projection
%
eval(['save HXR_',hxr_id,'.mat hxr']);