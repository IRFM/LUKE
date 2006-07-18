This is a short tutorial to run the 3-D drift kinetic solver.

$HOME refers to the PROJECT_DKE solver root directory ($HOME = ~/Project_DKE)

1) Launch MatLab (version > 7.0). Modify the Matlab startup.m file (see Matlab documentation) so that following
directories $HOME/DKE, $HOME/Database, $HOME/MEX, $HOME/Modules/<module_name> and $HOME/Packages/<package_name> can be 
recognized by Matlab. 

2) [optional] cd $HOME/DKE/MEX directory or $HOME/MODULES/<module_name>/MEX. Build all .*f and *.c mexfiles using 
make_mex command (see documentation in $HOME/DKE/MEX). Leave binaries in the local directory where they have been compiled.

3) CD $HOME/Database. Run make_all.m. If step 2) has not been done, answer 0 (no mex). 

4) CD $HOME/Examples/TScirc/LHkarney. Type rundke and enjoy your first experience !

5) [optional] How to run matrix inversion with MUMPS (parallel or sequential processing). Read the $HOME/Packages/MUMPS/readme.txt file

6) the full code documentation is given in $HOME/Doc/NoticeDKE.pdf file. It corresponds to the reference
J. Decker and Y. Peysson. Dke: "a fast numerical solver for the 3-D relativistic bounce-averaged electron 
drift kinetic equation". Euratom-CEA report EUR-CEA-FC-1736, Association EURATOM-CEA sur la 
Fusion Controlee, Saint-Paul-lez-Durance, France, 2004.

7) the directory $HOME/Display contains all functions for displaying results





