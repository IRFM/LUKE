
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
U savefig_dke_yp.m (Pour que les figures soient archivées dans un dossier au choix)

====> LUKE/Project_DKE/MEX/Bin

U readme.txt (to create Bin directory)

====> LUKE/Project_DKE/Modules/Cronos

U make_dkeparam_cronos.m (Mise en place des options de calcul pour MUMPS et des méthodes diverses)
U make_equil_cronos.m (new function for building "equil" from Cronos data)
U make_wavelaunchs_cronos_ec.m (make launch parameters for EC waves)
U make_wavelaunchs_cronos_lh.m (replaces make_wavelaunchs_cronos.m and ITER correction)
U make_wavert_cronos.m (a few corrections)
U zstarwars.m (EC wave incorporated, path and ohmic corrections)

====> LUKE/Project_DKE/Modules/EFIT

U Teneprof_jd.m (ajouts de RFP et FTU) 
U equil_magnetic_EFIT_jd.m (Trace la dependence poloidale de B pour identifier l'existence de minimum secondaires le cas échéant)

====> LUKE/Project_DKE/Modules/FEB/MEX/Bin

U readme.txt (to create Bin directory)

====> LUKE/Project_DKE/Modules/Helena

U MEX/Bin/readme.txt (to create Bin directory)
U MEX/Source/helmex77.f (Correction des lignes mal positionnées faisant planter g95)

====> LUKE/Project_DKE/Modules/RT

U init_RT_jd.m (Possibilité de choisir m0 ou n0 comme condition initiale (pour tokamak ou RFP))
U main_C3PO_jd.m (")
U main_rayinit_launch_jd.m (")

====> LUKE/Project_DKE/Packages

U nproc_dke_yp.m (PC case added)
U test_packages_dke_yp.m (Calcul avec moyenne et stockage des graphiques)

====> LUKE/Project_DKE/Packages/MUMPS

U MUMPS_dke_yp.m (Prend en compte le chemin vers le type de mpi utilisé. A définir dans PATH_files)

====> LUKE/Project_DKE/Packages/PETSc

U PETSc_Cloop_dke_ft.m (Prend en compte le chemin vers le type de mpi utilisé. A définir dans PATH_files)
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
U bremsstrahlung_dke_yp.m (Retrait d'un facteur 2pi compté deux fois)

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
U TScirc/Thermal/rundke.m (ce cas torique est ajouté)
U TScirc_e1/Ohm_bounce/rundke.m (Pas de sous dossier Figures)
U TScirc_e1/Runaway_bounce/rundke.m (Champ electrique à 0.08 pour limiter le nombre de cas)
U TScyl/LH_Karney/rundke.m (original karney case added)
U TScyl/LH_karney_Zi_D0/rundke.m (Suivi de la densité et normalisation)
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
