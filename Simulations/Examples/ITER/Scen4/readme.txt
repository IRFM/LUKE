Simulations ITER Scen 4
=======================

- Equilibrium

	Created from source files under CVS control at location EQUIL/Source_files
		- EQDSK : 		Scen4.efit -> /luke/Simulations/Joan/Local/ITER/Scen4/Source_files/EQDSK_files_PET/Mesh 129x129/Scen4 bn2.57_129x129.txt
		- profiles : 	Scen4.prof -> /luke/Simulations/Joan/Local/ITER/Scen4/Source_files/ITER_Scen4_200111081134_3900.prof
	using :
		- either the (new) script make_equil_ITER_Scen4.m
		- or irunluke_jd with signs.Ip = 1 and signs.Bt = 1

- Run test with script under CVS control : 
		- rundke_ITER_Scen4_200111081134_3900_bn257_129_C3PO_f5_N2_dN0p2.m 

- Compare output file under CVS control : 
		- res_ITER_Scen4_200111081134_3900_bn257_129_C3PO_f5_N2_dN0.2.log

- Results can be compared to identical run with irunluke_jd : 

- Build launch with parameters from run script

	When building wave structure use default options except :
		- dsmin = 0;
		- fitparam.method = 'spline';
		- rayparam.tau_lim = 20;
		- C3POparam.clustermode.main_C3PO_jd.mode = 2 (if MDCE applicable)

- Comparison successful for LUKE 1.8.2 on 05/28/2010.
- Comparison successful for LUKE 1.8.5 on 09/28/2010.
    (7.5 then 7.10, script then irunluke then batch)
- Comparison successful for LUKE 1.8.6 on 04/15/2011.
	(7.10, script and irunluke in batch mode)
	Note : ray length vary slightly, reason unknown.
		- First ray points coincide.
		- same compiled mex files.
		- seems to depend upon cephee processor.
		
- Passage � LUKE 1.9 : first calculation (LUKE 1.9.0) wrong because dtn and tn not adjusted in dkeparam
- Comparison successful for LUKE 1.9.1 with dtn=tn=10000, old version of solver_dke_yp from 1.8.6
- Results validated for LUKE 1.9.1 with tn=100000, new version of solver_dke_yp

- Comparison sucessful on 09/21/2012 with old EQUIL.
- Small difference on 09/20/2012 with new EQUIL - tagged LUKE_1_10
	

