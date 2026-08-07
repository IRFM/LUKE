% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
% script proc_ITER_Scan2_C3PO_EC_fluctn_Nscan
%
clear
close all
%
display_mode = 2;
%
backup_file = 'TS_32299_100.1733_ES_0_Dr0_0.2_C3PO_LH_C3_ne3_fluct_tail_dtn_10_calc_tail_jd_Nmax_2.5_n_5_P_NaN_opt_0+1i';
ref_file = 'TS_32299_100.1733_ES_0_Dr0_0.2_C3PO_LH_C3_ne3';
%
Zfluct_ref = fproc_fluctn_jd(ref_file);
Zfluct = fproc_fluctn_jd(backup_file,display_mode,Zfluct_ref);
%
    
    
    
    
    