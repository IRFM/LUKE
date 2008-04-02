
****************************************************************************************************

LUKE Version 1.1

A directory Simulations has been created. It contains the Examples folder.

====> LUKE/Project_DKE/Database/DKEPARAM_files

U make_dkeparam_BOUNCE3D_MUMPS.m (abslim added and package parameters + MUMPSmex parameters)
U make_dkeparam_BOUNCE3D_MUMPS_m201.m
U make_dkeparam_BOUNCE3D_boostrap.m
U make_dkeparam_EC_RT.m
U make_dkeparam_LH_RT.m
U make_dkeparam_NONUNIFORM100100R.m
U make_dkeparam_UNIFORM10010020.m
U make_dkeparam_UNIFORM10010020_MUMPS.m
U make_dkeparam_UNIFORM10010020_RT.m
U make_dkeparam_UNIFORM10010020_coll0.m
U make_dkeparam_UNIFORM10010020_nit1.m

====> LUKE/Project_DKE/Database/PATH_files

U make_path_LUKE_DRFC.m (removed)
U make_path_LUKE.m (generic LOCAL .mat path file)

====> LUKE/Project_DKE/Database/HXR_files

U bremTSconvert_dke_yp.m (circle function replaced)

====> LUKE/Project_DKE/DKE

U alphaphi_fr_jd.m (scalar entries possible)
U disp_hot_jd.m
U disp_jd.m
U load_structures_yp.m (path changed with local option)
U main_dke_yp.m (warnings and ripple)
U path_LUKE_LOCAL.m 
U propagation_jd.m
U rayprocess_jd.m (dNpar a partir de beam width)
U run_lukert.m (dNpar increased at each caustic + warnings)
U setpath_luke_jd.m (now a function, mex as field)
U solver_dke_yp.m (mumpsmex added + petsc modified)
U writeCloopinput_dke_ft.m (gestion des repertoires temporaires)

====> LUKE/Project_DKE/MEX

U make_mex.m (path->dkepath)

====> LUKE/Project_DKE/Modules/Cronos

U make_dkeparam_cronos.m (new packages)
U zstarwars.m (abslim)
U make_wavelaunchs_cronos_lh.m (replaces make_wavelaunchs_cronos.m and ITER correction)

====> LUKE/Project_DKE/Modules/EFIT

U Teneprof_jd.m (one more case)
U equil_magnetic_EFIT_jd.m (equilibrium and profiles separated)
U equil_prof_jd.m (equilibrium and profiles separated)

====> LUKE/Project_DKE/Modules/RT

U main_C3PO_jd.m (beam option and pmode for caustic)
U main_rayinit_launch_jd.m (ray length increased)
U make_beam_wave_jd.m (beam-like damping)
U raypostprocessing_yp.m (pmode and toroidal projection)

====> LUKE/Project_DKE/Modules/Examples

U run_all.m (run all examples)

====> LUKE/Project_DKE/Modules/Examples/JETlike/WAVE

U make_wave_JETliketest.m (simplified output)

====> LUKE/Project_DKE/Modules/MEX/Bin

U Compile.text (path corrected)

====> LUKE/Project_DKE/Packages/MUMPS

U MUMPS_dke_yp.m (nproc and MPI managing)
U readme.txt
U MUMPSMEX_dke_yp.m (MEX file for MUMPS + extra parameters)

====> LUKE/Project_DKE/Packages/PETSc

U PETSc_Cloop_dke_ft.m (call to C collision function) 
U PETSc_dke_ft.m (nproc and MPI managing)
U writePetscBin_DKE_ft.m (display off)

====> LUKE/Project_DKE/Packages/PETSc/DKE

U division.c (display off)
U firstordercollop_dke_ft_c.c (display off)
U integral_dke_jd.c (display off)
U makefile
U product.c (display off)
U ReadBinary_DKE.c (display off)
U ReadBinaryArray_DKE.c (display off)
U ReadBinaryIntArray_DKE.c (display off)
U ReadBinarySparseMatrix_DKE.c (display off)
U readme.txt
U Scalar_Tensor_product.c (display off)
U SolverLoop_DKE_c.c (dynamic path managing + correction for current calculation)
U SparseMat_Tensorproduct.c (display off)
U tensor.h (long double -> double)
U Tensor_Create.c (display off)
U Tensor_Sum.c (display off)
U Tensor_Transpose.c (display off)

====> LUKE/Project_DKE/Packages/PETSc/MEX/Source

U writeBinaryArray_mex_c.c (display off)
U writeBinaryIntArray_mex_c.c (display off)
U writeBinarySparseMat_mex_c.c (display off)
U writeBinaryTensor_mex_c.c (display off)
U ReadBinaryIntArray_mex_c.c (new function)

====> LUKE/Project_DKE/Packages/PETSc/

U README.txt
U nproc_dke_yp.m (processor managing)
U testLU2D.mat (test matrix for inversion methods testing)
U testLU3D.mat (test matrix for inversion methods testing)
U test_packages_dke_yp.m (test function for inversion methods)

====> LUKE/Simulations

U Examples/run_all_examples.m (runs all examples)
U Examples/JETh77/LH_karney_transp_bounce/proc_rundke_yp.m (result processing)
U Examples/JETh77/LH_karney_transp_bounce/rundke.m (paths simplified + mumpsmex option)
U Examples/JETh77/LH_karney_transp_bounce_nomag/rundke.m (paths simplified + mumpsmex option)
U Examples/JETh77/LH_karney_transp_bounce_petsc/proc_rundke_yp.m (result processing)
U Examples/JETh77/LH_karney_transp_bounce_petsc/rundke.m (paths simplified + mumpsmex option)
U Examples/JETh77/Zero_test/rundke.m (paths simplified + mumpsmex option)
U Examples/TScirc/LH_karney_transp_bounce/rundke.m (paths simplified + mumpsmex option)
U Examples/TScirc/LH_karney_transp_bounce_nomag/rundke.m (paths simplified + mumpsmex option)
U Examples/TScirc_e1/Ohm_bounce/rundke.m (paths simplified + mumpsmex option)
U Examples/TScirc_e1/Runaway_bounce/rundke.m (paths simplified + mumpsmex option)
U Examples/TScirc_peak/LH_karney_ripple/rundke.m (paths simplified + mumpsmex option)
U Examples/TScyl/LH_karney_3D_num/rundke.m (paths simplified + mumpsmex option)
U Examples/TScyl/LH_karney_Zi_D0/rundke.m (paths simplified + mumpsmex option)
U Examples/TScyl/LH_karney_num/rundke.m (paths simplified + mumpsmex option)
U Examples/TScyl/LH_karney_transp_nobounce/rundke.m (paths simplified + mumpsmex option + parallel option)
U Examples/TScyl/Ohm_Zi/rundke.m (paths simplified + mumpsmex option)
U Examples/TScyl/Runaway_Zi_nobounce/rundke.m (paths simplified + mumpsmex option)
U Examples/TScyl/Runaway_particle_loss/rundke.m (paths simplified + mumpsmex option)
U Examples/TScyl/Thermal/rundke.m (paths simplified + mumpsmex option)

****************************************************************************************************

LUKE Version 1.2

====> LUKE/Project_DKE/Database/

U make_all.m (made into a function and PATH_files removed)
U clearmat.m (clear .mat files)

====> LUKE/Project_DKE/DKE

U main_dke_yp.m (sorties runaways)
U momentumgrid_dke_jd.m (Sorting mhu so that mhu is monotonic. Important for RFP simulations only)
U path_LUKE_LOCAL.m (PATH_LOCAL is also searched in matlab PATH. It can also be built interactively during the first run)
U savefig_dke_yp.m (Pour que les figures soient archiv�es dans un dossier au choix)

====> LUKE/Project_DKE/MEX/Bin

U readme.txt (to create Bin directory)

====> LUKE/Project_DKE/Modules/Cronos

U make_dkeparam_cronos.m (Mise en place des options de calcul pour MUMPS et des m�thodes diverses)
U make_equil_cronos.m (new function for building "equil" from Cronos data)
U make_wavelaunchs_cronos_ec.m (make launch parameters for EC waves)
U make_wavelaunchs_cronos_lh.m (replaces make_wavelaunchs_cronos.m and ITER correction)
U make_wavert_cronos.m (a few corrections)
U zstarwars.m (EC wave incorporated, path and ohmic corrections)

====> LUKE/Project_DKE/Modules/EFIT

U Teneprof_jd.m (ajouts de RFP et FTU) 
U equil_magnetic_EFIT_jd.m (Trace la dependence poloidale de B pour identifier l'existence de minimum secondaires le cas �ch�ant)

====> LUKE/Project_DKE/Modules/FEB/MEX/Bin

U readme.txt (to create Bin directory)

====> LUKE/Project_DKE/Modules/Helena

U MEX/Bin/readme.txt (to create Bin directory)
U MEX/Source/helmex77.f (Correction des lignes mal positionn�es faisant planter g95)

====> LUKE/Project_DKE/Modules/RT

U init_RT_jd.m (Possibilit� de choisir m0 ou n0 comme condition initiale (pour tokamak ou RFP))
U main_C3PO_jd.m (")
U main_rayinit_launch_jd.m (")

====> LUKE/Project_DKE/Packages

U nproc_dke_yp.m (PC case added)
U test_packages_dke_yp.m (Calcul avec moyenne et stockage des graphiques)

====> LUKE/Project_DKE/Packages/MUMPS

U MUMPS_dke_yp.m (Prend en compte le chemin vers le type de mpi utilis�. A d�finir dans PATH_files)

====> LUKE/Project_DKE/Packages/PETSc

U PETSc_Cloop_dke_ft.m (Prend en compte le chemin vers le type de mpi utilis�. A d�finir dans PATH_files)
U PETSc_dke_ft.m (")

====> LUKE/Simulations/Examples/JETh77

U LH_karney_transp_bounce/rundke.m (graphic output)
U LH_karney_transp_bounce_nomag/rundke.m (") 
U LH_karney_transp_bounce_petsc/rundke.m (")
U Zero_test/rundke.m (")

====> LUKE/Simulations/Examples/TScirc

U LH_karney_transp_bounce/rundke.m (") 
U LH_karney_transp_bounce_nomag/rundke.m (") 

====> LUKE/Simulations/Examples/TScirc_e1

U Ohm_bounce/rundke.m (cyl calc. for reference and better comparison with Sigmar-Coppi)
U Runaway_bounce/rundke.m (graphic output)

====> LUKE/Simulations/Examples/TScirc_peak

U LH_karney_ripple/proc_rundke_yp.m (correction)
U LH_karney_ripple/rundke.m (graphic output)

====> LUKE/Simulations/Examples/TScyl

U LH_karney_3D_num/rundke.m (graphic output)
U LH_karney_Zi_D0/rundke.m (") 
U LH_karney_num/rundke.m (") 
U LH_karney_transp_nobounce/rundke.m (") 
U Ohm_Zi/rundke.m (") 
U Runaway_Zi_nobounce/rundke.m (") 
U Runaway_particle_loss/rundke.m (") 
U Thermal/rundke.m (") 

****************************************************************************************************

LUKE Version 1.3

Main changes include:

- calculation of wave absorption and other characteristics included in C3PO
- improvement and generalization of theta interpolation at given magnetic field values
- compatibility of i/o with CRONOS flux-surface averaging


====> LUKE/Project_DKE/DKE

U alphaphi_fr_jd.m (possibility to use the MEX version)
U banana_dke_jd.m (use of the function interp_theta_jd and other improvements)
U bounce_dke_jd.m (new coefficient & simplification by using the structure equilDKE)
U bouncecoefbuilder_dke_yp.m (")
U bounceparam_dke_yp.m (")
U efield_dke_jd.m (compatibility with CRONOS flux-surface averaging included)
U fmoments_dke_yp.m (")
U graph1D_jd.m (marker size and legend as cell)
U graph2D_jd.m (labelling optional)
U interp_theta_jd.m (new function, theta interpolation at given magnetic field values)
U mex_compile_luke.m (PC case added)
U path_LUKE_LOCAL.m (made PC compatible)
U pc_dke_yp.m (use of varargout)
U rayprocess_jd.m (case where variables are already calculated is treated)
U setpath_luke_jd.m (made PC compatible)
U wave_process_jd.m (treats the case where ray.tau exists already)

====> LUKE/Project_DKE/MEX/

U Source/alphaphi_jd.c (wave absorption calculation, used by alphaphimex_jd and C3PO)
U Source/alphaphimex_jd.c (mex calculation of the absorption coefficient)
U Source/bessel_IK_jd.h (bessel functions I and K)

====> LUKE/Project_DKE/Packages

U test_packages_dke_yp.m (Test for the existence of mex file)

====> LUKE/Project_DKE/Modules/Cronos

U zstarwars.m (compatibility of i/o with CRONOS flux-surface averaging)

====> LUKE/Project_DKE/Modules/Helena

U equil_helmag_yp.m (Helena for LUKE as stand-alone application)
U equil_helprof_yp.m (")
U make_equil_helena.m (")
U make_helprof_yp.m (")
U make_helsep_yp.m (")
U run_helena_yp.m (")
U Application/hel12b.f (")

====> LUKE/Project_DKE/Modules/RT

U calcval_yp.m (modification of i/o)
U init_RT_jd.m (")
U main_C3PO_jd.m (modified to work with the new version of raytracing_yp : absorption calculated in C)
U make_beam_wave_jd.m (warning removed)
U raypostprocessing_yp.m (modified to work with the new version of raytracing_yp : absorption calculated in C)
U testfitequil_yp.m (modification of i/o)
U Examples/JETlike/WAVE/make_wave_JETliketest.m (")
U Examples/JETlike/WAVE/make_wave_JETliketest_bis.m(")
U MEX/Source/raytracing_dieltensor_yp.c (calculation of wave absorption and other characteristics included in C3PO)
U MEX/Source/raytracing_load_yp.c (")
U MEX/Source/raytracing_yp.c (")

====> LUKE/Simulations/Examples/TScyl

U Ohm_Zi/rundke.m (Spitzer conductivity added)

----------------------------------------------------------------------------------------------------

LUKE Release 1.3.1

- batch of the version LUKE 1.3

====> LUKE/Project_DKE/Database/DKEPARAM_files

U make_dkeparam_NONUNIFORM10010020.m (Cas grille non uniforme added)

====> LUKE/Project_DKE/Database/PATH_files

U make_path_LOCAL.m (updated for LUKE 1.3)
U make_path_LUKE.m (updated for LUKE 1.3)

====> LUKE/Project_DKE/DKE

U LUKEversion_jd.m
U conc_struct_jd.m (moved here from M_tools)
U equilibrium_jd.m (smoothing of the equilibrium if secondary extrema are present)
U interp_theta_jd.m (small correction for numerical precision)
U mex_compile_luke.m (c form of alphaphi included)
U print_jd.m (moved here from M_tools - blend of print_jd and savefig_dke_yp)

====> LUKE/Project_DKE/MEX

U Source/alphaphi_jd.c (correction for use in linux)

====> LUKE/Project_DKE/Modules/Cronos

U make_dkeparam_cronos.m (nmhu = 121)
U make_wavelaunchs_cronos_lh.m (one ITER antenna removed)
U zstarwars.m (distribution is passed as output + a few corrections in the electric field management)

====> LUKE/Project_DKE/Modules/FEB

U bremchorddisplay_dke_yp.m (Correction figures qui bombent avec MatLab 2007a)
U bremdiag_dke_yp.m (Correction de la boucle)
U bremdiagdisplay_dke_yp.m (Correction figures qui bombent avec MatLab 2007a)
U bremlocaldisplay_dke_yp.m (")
U bremsstrahlung_dke_yp.m (Retrait d'un facteur 2pi compt� deux fois)

====> LUKE/Project_DKE/Modules/RT

U main_C3PO_jd.m (flag option added + theta saved in as a ray parameter)
U Examples/JETlike/WAVE/make_wave_JETliketest.m (use of main_c3po_jd)
U Examples/JETlike/WAVE/make_wave_JETliketest_bis.m (")
U Examples/PLT/WAVE/make_wave_PLTtest.m (")
U Examples/RTtest/WAVE/make_wave_RTtest.m (")
U Examples/RTtest/WAVE/make_wave_RTtest_straight.m (")
U Bin/Compile.text (modified to work with the new version of raytracing_yp : absorption calculated in C)

====> LUKE/Project_DKE/Packages

U nproc_dke_yp.m (PC case added)

====> LUKE/Simulations/Examples

U run_all_examples.m (correction in the existence test)
U JETh77/Zero_test/rundke.m (E = 0.08ED)
U TScirc/Thermal/rundke.m (ce cas torique est ajout�)
U TScirc_e1/Ohm_bounce/rundke.m (Pas de sous dossier Figures)
U TScirc_e1/Runaway_bounce/rundke.m (Champ electrique � 0.08 pour limiter le nombre de cas)
U TScyl/LH_Karney/rundke.m (original karney case added)
U TScyl/LH_karney_Zi_D0/rundke.m (Suivi de la densit� et normalisation)
U TScyl/LH_karney_num/rundke.m (sequencial MUMPS test)
U TScyl/LH_karney_transp_nobounce/rundke.m (small correction + Retrait mumps de dkeparam par defaut)
U TScyl/Ohm_Zi/rundke.m (save name changed)
U TScyl/Runaway_Zi_nobounce/rundke.m (dkeparam par defaut)
U TScyl/Runaway_particle_loss/rundke.m (" + dkeparam par defaut)
U TScyl/Thermal/rundke.m (Comparaison grilles uniformes et non-uniformes)

----------------------------------------------------------------------------------------------------

LUKE Release 1.3.2

- batch of the version LUKE 1.3
	- runaway avalanches
	- corrected radial transport

====> LUKE/Project_DKE/DKE

U Bfit_dke_ds.m (interpolation function for avanlanche runaway calculations)
U main_dke_yp.m (different arguments for sinksourcecoeffbuilder_dke_yp.m and rad_dke_yp.m)
U rad_dke_yp.m (correction on trapped electron radial fluxes)
U runaway_sinksource.m (avanlanche runaway calculations)
U sinksourcecoeffbuilder_dke_yp.m (modified treatment of trapped electrons)
U thetastar_dke_ds.m (theta star calculations for avanlanche runaway calculations)
U zstarwars.m (MUMPS path managed in cronos path file)

LUKE Release 1.3.3

- batch of the version LUKE 1.3. 
	- Correction arising during the benchmarking effort on LUKE

====> LUKE/Project_DKE/Database

U DKEPARAM_files/make_dkeparam_NONUNIFORM10010020.m (so that np = 100)
U EQUIL_files/make_equil_TScirc.m (compatibility with TScyl and more precise calculation of psi)
U EQUIL_files/make_equil_TScirc_e1.m (")
U OHM_files/ohm_flat.m (new function creating flat ohmic profiles)

====> LUKE/Project_DKE/DKE

U Project_DKE/DKE/equilibrium_jd.m (equilibrium smoothing only for toroidal geometry)
U Project_DKE/DKE/main_dke_yp.m (curr0 and norm0 saved in dke_out)
U Project_DKE/DKE/momentumgrid_dke_jd.m (no mhu_T effect when bounce_mode = 0)
U Project_DKE/DKE/solver_dke_yp.m (curr0 and norm0 saved in dke_out)

====> LUKE/Simulations/Examples

This functions have been modified extensively in preparation for publication

U TScirc_e1/Ohm_bounce/rundke.m
U TScyl/Ohm/rundke_Zi.m
U TScyl/Ohm/rundke_betath.m (new function)
U TScyl/Ohm/rundke_epsi.m (new function)
U TScyl/Thermal/rundke.m

In addition:

- the directory TScyl/Ohm_Zi has been renamed TScyl/Ohm with 
	- rundke.m renamed rundke_Zi.m
	- rundke_betath.m and rundke_epsi.m added

- the directories TScyl/Runaway_Zi_nobounce and Runaway_particle_loss have been deleted
- the directory TScyl/Runaway has been created 
	- Runaway_Zi_nobounce/rundke.m renamed rundke_Zi.m
	- Runaway_particle_loss/rundke.m renamed rundke_particle_loss.m


****************************************************************************************************

LUKE Version 1.4

Main changes include:

- CRONOS coupling (proper outputs, signs management, etc)
- dNpar evolution (accessibility limit, numerical limit)
- RHS at first FPE iteration, important for time evolution
- HELMEX now working
- Many corrections in preparation for publication

====> LUKE

U install_LUKE.m (update of PATH directory)

====> LUKE/Project_DKE/DKE

U bounce_dke_jd.m (modifs equil_mode = 0)
U bouncecoefbuilder_dke_yp.m (qcronos calculated)
U bounceparam_dke_yp.m (")
U colddisp_dke_jd.m (accessibility condition added)
U conc_struct_jd.m (treatment of particuliar cases)
U eicoll_dke_yp.m (treatment of case Ti=0)
U equilibrium_jd.m (magnetic field on axis added for qcronos calculation)
U fact_dke_jd.m (matlab function with treatment of singles)
U finit_dke_yp.m (update with Fuchs model)
U fmoments_dke_yp.m (correction of cronos bounce averaging using qcronos)
U graph1D_jd.m (figure fonts and marker properties)
U load_structures_yp.m (correction when no wave is present)
U LUKEversion_jd.m (version 1.4)
U main_dke_yp.m (correction initial power and output of residue)
U mex_compile_luke.m (display and helmex)
U print_jd.m (modif Mac OSX)
A proc_luke_jd.m (LUKE output treatment)
U propagation_jd.m (correction initial power)
U qfactors_dke_yp.m (qcronos calculated)
U rad_dke_yp.m (to avoid error when vparmin > vnmax)
U rayprocess_jd.m (account for varying dnpar in absorption when rt_mode = 4 and accessibility condition)
U raysum_rf_jd.m (possibility to cap dparpar)
U rfdiff_dke_jd.m (resolution by block and accessibility)
U rfprop_dke_jd.m (initial power in ray)
U rfwave_dke_jd.m (initial power in ray)
U run_lukert.m (waves returned in dke_out, dnpar minimum in rt_mode = 2 for grid step, accessibility, 					account for varying dnpar in absorption when rt_mode = 4)
U setpath_luke_jd.m (path ACCOME)
U solver_dke_yp.m (correction for RHS at first iteration, loop simplification, residue saved and returned 				at all times)
U wave_process_jd.m (account for varying dnpar in absorption whe rt_mode = 4, kextra effect)

====> LUKE/Project_DKE/Database/DKEPARAM_files

U make_dkeparam_EC_RT.m (Dparparmax added)
U make_dkeparam_LH_RT.m (")
U make_dkeparam_NONUNIFORM10010020.m (Dparparmax added and nonuniformity in mhu only)
U make_dkeparam_UNIFORM10010020.m (Dparparmax added)
R make_dkeparam_BOUNCE3D_MUMPS.m is no longer in the repository
R make_dkeparam_BOUNCE3D_MUMPS_m201.m is no longer in the repository
R make_dkeparam_BOUNCE3D_boostrap.m is no longer in the repository
R make_dkeparam_NONUNIFORM100100R.m is no longer in the repository
R make_dkeparam_UNIFORM10010020_MUMPS.m is no longer in the repository
R make_dkeparam_UNIFORM10010020_RT.m is no longer in the repository
R make_dkeparam_UNIFORM10010020_coll0.m is no longer in the repository
R make_dkeparam_UNIFORM10010020_nit1.m is no longer in the repository

====> LUKE/Project_DKE/Database/EQUIL_files

U make_equil_JETh77.m (path management and other corrections)
U make_equil_TScirc_e1.m (to avoid interp. problems)
R make_equil_TScirc_peak.m is no longer in the repository
R make_equil_TScyl_lowTene.m is no longer in the repository

====> LUKE/Project_DKE/Database/OHM_files

R make_ohm_JETh77_p005_flat.m is no longer in the repository
R make_ohm_TScirc_e1_p001_flat.m is no longer in the repository
R make_ohm_TScirc_e1_p005_flat.m is no longer in the repository
R make_ohm_TScirc_e1_p008_flat.m is no longer in the repository
R make_ohm_TScirc_p005_flat.m is no longer in the repository
R make_ohm_TScyl_lowTene_p008_flat.m is no longer in the repository
R make_ohm_TScyl_p001_flat.m is no longer in the repository
R make_ohm_TScyl_p005_flat.m is no longer in the repository

====> LUKE/Project_DKE/Database/PATH_files

U make_path_LUKE.m (version 1.4)
U make_path_LOCAL.m (version 1.4)

====> LUKE/Project_DKE/Database/WAVE_files

A make_idealLHwave_jd.m (makes wave structure based on v1, v2 an D)
R make_wave_JETh77_LH_karney_offaxis_2.m is no longer in the repository
R make_wave_TScirc_LH_karney.m is no longer in the repository
R make_wave_TScirc_LH_karney_g.m is no longer in the repository
R make_wave_TScirc_LH_karney_offaxis_1.m is no longer in the repository
R make_wave_TScirc_LH_karney_offaxis_2.m is no longer in the repository
R make_wave_TScirc_e1_LH_karney.m is no longer in the repository
R make_wave_TScirc_e1_LH_karney_offaxis_2.m is no longer in the repository
R make_wave_TScirc_peak_LH_karney_uniform.m is no longer in the repository
R make_wave_TScirc_unicyl_psirho_LH_karney_offaxis_2.m is no longer in the repository
R make_wave_TScyl_LH_karney.m is no longer in the repository
R make_wave_TScyl_LH_karney_g.m is no longer in the repository
R make_wave_TScyl_LH_karney_offaxis_2.m is no longer in the repository
R make_wave_TSh77_LH_karney_offaxis_1.m is no longer in the repository

====> LUKE/Project_DKE/Modules/ACCOME

A accome_yp.m (reads ACCOME equilibrium data)
A equil_magnetic_ACCOME_yp.m (builds accome equilibrium)
A equil_prof_ACCOME_yp.m (builds accome profiles)

====> LUKE/Project_DKE/Modules/Cronos

U lhspectrum_cronos.m (sign management and possibility to add negative lobe)
U make_dkeparam_cronos.m (Dparparmax added)
U make_equil_cronos.m (sign management)
U make_wavelaunchs_cronos_ec.m (simplifications and polarization)
U make_wavelaunchs_cronos_lh.m (polarization and possibility to add negative lobe)
U make_wavert_cronos.m (polarization and ray parameters updated)
U zstarwars.m (simplifications, sign management and possibility to add negative lobe)

====> LUKE/Project_DKE/Modules/EFIT

U Teneprof_jd.m (EAST tokamak added)

====> LUKE/Project_DKE/Modules/FEB

U bremchord_dke_yp.m (file theta grid and chord length calculation)
U bremlocaldisplay_dke_yp.m (comments)
U bremsstrahlung_dke_yp.m (bugs and comments)
A contourfp_hxr_yp.m (draws the eergetic particle regions of the distribution)

====> LUKE/Project_DKE/Modules/Helena

R equil_helmag_yp.m is no longer in the repository
R equil_helprof_yp.m is no longer in the repository
R make_equil_helena.m is no longer in the repository
R make_helprof_yp.m is no longer in the repository
R make_helsep_yp.m is no longer in the repository
R run_helena_yp.m is no longer in the repository
R Application/hel12b.f is no longer in the repository
U testsep.txt (used by make_equil_helena)
U MEX/Source/ReadMe.txt (updated instruction)
A MEX/Source/helmex77_32b.f (helmex 32 bits)
U MEX/Source/helmex77_64b.f (corrected)
A MEX/Source/separatrice_32b.f (separatrix 32 bits)
R MEX/Source/helmex77.f is no longer in the repository
R MEX/Source/m64t32.sh is no longer in the repository
R MEX/Source/separatrice.f is no longer in the repository
U MEX/Bin/build_helmex77_yp.m (script to compile mex files)
U MEX/Bin/readme.txt

====> LUKE/Project_DKE/Modules/RT

U main_C3PO_jd.m (additional points can be required)
U main_rayinit_launch_jd.m (comments)
U raypostprocessing_yp.m (accessibility condition calculated)
U Examples/JETlike/WAVE/make_wave_JETliketest.m (bugs corrected)
U Examples/JETlike/WAVE/make_wave_JETliketest_bis.m (")
U Examples/VERSATOR2/WAVE/make_wave_VERSATOR2test.m (")
U MEX/Source/raytracing_load_yp.c (additional points)
U MEX/Source/raytracing_yp.c (")

====> Simulations/Examples

These files are examples updated for publication

U run_all_examples.m
U JETh77/LH_karney_transp_bounce/rundke.m
U TScirc_e1/Ohm_bounce/conductivity_model_yp.m
U TScirc_e1/Ohm_bounce/hinton_oberman_integral_yp.m
U TScirc_e1/Ohm_bounce/rundke.m
U TScirc_e1/Runaway_bounce/rundke.m
U TScyl/LH_Karney/rundke.m
U TScyl/LH_Karney/rundke_D0.m
U TScyl/LH_Karney/rundke_Zi.m
U TScyl/LH_Karney/rundke_betath.m
U TScyl/LH_Karney/rundke_conv.m
U TScyl/LH_Karney/rundke_grid.m
U TScyl/LH_Karney/rundke_init.m
U TScyl/LH_karney_3D_num/rundke.m
U TScyl/LH_karney_num/rundke.m
U TScyl/LH_karney_transp_nobounce/rundke.m
U TScyl/Ohm/rundke_Zi.m
U TScyl/Ohm/rundke_betath.m
U TScyl/Ohm/rundke_epsi.m
U TScyl/Runaway/rundke_Zi.m
U TScyl/Runaway/rundke_betath.m
U TScyl/Runaway/rundke_dtn.m
U TScyl/Runaway/rundke_init.m
U TScyl/Runaway/rundke_norm.m
U TScyl/Runaway/rundke_norm_ss.m
U TScyl/Runaway/rundke_time.m
U TScyl/Thermal/rundke_Ti.m
U TScyl/Thermal/rundke_dtn.m
U TScyl/Thermal/rundke_norm.m
R TScyl/LH_karney_Zi_D0/rundke.m is no longer in the repository
R TScirc_e1/LH_Karney_bounce/rundke.m is no longer in the repository

----------------------------------------------------------------------------------------------------

LUKE Release 1.4.1

- batch of the version LUKE 1.4
	- cronos test and modifications
	- figures for paper submission

====> Project_DKE/DKE

U LUKEversion_jd.m (version 1.4.1)
U main_dke_yp.m (residue out desactivated)
U proc_luke_jd.m (pnmax can be specified externally)
U solver_dke_yp.m (Taille des matrices LU pour MUMPS)

====> Project_DKE/Modules/Cronos

U make_wavelaunchs_cronos_lh.m (Z0 for antenna vertical position and ITER case) 
U make_wavert_cronos.m (kextra to 1000)
U zstarwars.m (eco mode, vincenteries removed, cronos tested on ITER ramp up (J.F.A))

====> Project_DKE/Modules/RT

U main_rayinit_launch_jd.m (Z0 for antenna vertical position)
U raypostprocessing_yp.m (Normalization s)

====> Simulations/Examples

U TScyl/LH_karney_3D_num/rundke.m (Final figure modifications for submission)
U TScyl/LH_karney_num/rundke.m (")
U TScyl/LH_karney_transp_nobounce/rundke.m (")
U TScirc_e1/Runaway_bounce/rundke.m (")
U TScyl/Runaway/rundke_betath.m (")
U TScyl/LH_Karney/rundke_conv.m (")
U TScyl/Thermal/rundke_dtn.m (")
U TScyl/LH_Karney/rundke_grid.m (")
U TScyl/Thermal/rundke_norm.m (")
U TScyl/Thermal/rundke_Ti.m (")
U TScyl/Runaway/rundke_time.m (")
U TScirc_e1/Ohm_bounce/rundke.m (")
U TScirc_peak/LH_karney_ripple/rundke.m (")

----------------------------------------------------------------------------------------------------

LUKE Release 1.4.2

- batch of the version LUKE 1.4
	- optimized radial grid calculation

====> Project_DKE/DKE

A optgrid_dke_jd.m (new function, calculates the grid)
U main_dke_yp.m (rho_S as output)
A radialdampingprofile_jd.m (transfered from DKE_Tools)
U radialgrid_dke_jd.m (rho_S as output)
U run_lukert.m (optimized radial grid calculation)

====> Project_DKE/Modules/Cronos

U zstarwars.m (optimized radial grid calculation)

****************************************************************************************************

LUKE Version 1.5

Main changes include:

- Interactive LUKE run
- Large memory gain in rfdiff_dke_jd
- Simplified install and path management
- Important correction in alphaphi_jd.c

====> LUKE

U install_LUKE.m (startup location modified and PATH structure created)
U uninstall_LUKE.m (update of mex cleaning)
U VERSIONS.txt (this file)

====> LUKE/Project_DKE/Display

A imake_angles_TCV_jd.m (interactively creates ANGLES structure for EC waves in TCV)
A imake_equil_jd.m (interactively creates an equilibrium)
A imake_launch_angles_TCV_jd.m (interactively creates the LAUNCh structure in TCV)
A imake_ohm_jd.m (interactively creates an OHM structure)
A imake_transp_jd.m (interactively creates a TRANSP structure)
A imake_wave_jd.m (interactively creates a WAVE structure)
A imake_wave_TORAY_jd.m (interactively creates a WAVE structure from TORAY output)
A irunhxr_jd.m (interactively runs the HXR postprocessing)
A irunluke_jd.m (interactively runs LUKE)

====> LUKE/Project_DKE/DKE

A bounce_ripple_jd.m (function that plots the trapping and ripple boundaries, moved from DKE_tools)
A mex_clean_luke.m (function that cleans LUKE of compiled mex files)
U comput_dke_yp.m (case of linux on PC)
A graph_wave_jd.m (function that plots the wave data, moved from DKE_tools)
U load_structures_yp.m (mex compile and rayinits)
U LUKEversion_jd.m (version 1.5)
U mex_compile_luke.m (use of dkepath, helmex compilation argument)
U mripplecoefbuilder_dke_yp.m (diaply)
U optgrid_dke_jd.m (display)
U path_LUKE_LOCAL.m (local path, temp path and helmex compilation argument)
U print_jd.m (.fig extension and -tiff removed)
U radialdampingprofile_jd.m (correction when rho > 1)
U rayprocess_jd.m (srho treated)
U rfdiff_dke_jd.m (better memory management)
U run_lukert.m (a_sdNpar location)
U rfwave_dke_jd.m (display)
U setpath_luke_jd.m  (HXR and DISPLAY in path)
U wave_process_jd.m (power fields calculation from sP_2piRp)

====> LUKE/Project_DKE/Database

U HXR_files/bremTSconvert_dke_yp.m (small correction)
U PATH_files/make_path_LUKE.m (option for helmex compilation)
U PATH_files/make_path_LOCAL.m (")
U WAVE_files/make_C3POparam.m (generates standard fitparam and rayparam structures)

====> LUKE/Project_DKE/MEX/Source

U alphaphi_jd.c (correction in the elliptical case)

====> LUKE/Project_DKE/Modules/Helena/

U build_helmex77_yp.m (compiles HELMEX, moved here from MEX/Bin)

====> LUKE/Project_DKE/Modules/EFIT/

U contlimit_jd.m (unwanted figure case)
U rz2pt_jd.m (")
U eqdsk_jd.m (better treatment of first line)
U equil_magnetic_EFIT_jd.m (file extension)
U equil_prof_jd.m (file extension)
U Teneprof_jd.m (ITER case added)

====> LUKE/Project_DKE/Modules/RT/

U make_beam_wave_jd.m (requires the calculation of beamlets damping)
U main_C3PO_jd.m (a_sdNpar location)
U main_rayinit_launch_jd.m (i_ref in this function)
U MEX/Source/raytracing_yp.c (ray treatment at rho = 0 removed)

====> LUKE/Project_DKE/Modules/FEB/

U bremdiagdisplay_dke_yp.m (plots experimental data if applicable)

====> LUKE/Project_DKE/Modules/Cronos/

U zstarwars.m (a_sdNpar location)




