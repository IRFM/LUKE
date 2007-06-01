
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

====> LUKE/Project_DKE/Modules/RT/Examples

U run_all.m (run all examples)

====> LUKE/Project_DKE/Modules/RT/Examples/JETlike/WAVE

U make_wave_JETliketest.m (simplified output)

====> LUKE/Project_DKE/Modules/RT/MEX/Bin

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




