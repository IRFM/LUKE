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

- Comparison successful for LUKE 1.8.2 on 05/28/2010.
- Comparison successful for LUKE 1.8.5 on 09/28/2010.
    (7.5 then 7.10, script then irunluke then batch)

