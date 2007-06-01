Steps for (un)installing LUKE

========================================================
 INSTALL LUKE
========================================================
1) Run MatLab
2) cd ~/LUKE
3) Type "install_LUKE or install_LUKE('to/your/path/whereis/startup.m')".
4) If you wish to use external linear algebra packages (MUMPS, PETSc and SUPERLU are supported) 
  - Install packages (for example in LUKE/Packages)
  - Edit make_path_LUKE.m to set path for installed packages 
		OR
  - The path can be set interactively during the first run
5) It's done. No need to relaunch Matlab !
========================================================
 UNINSTALL LUKE
========================================================
1) Run MatLab
2) cd ~/LUKE
3) Type "uninstall_LUKE or uninstall_LUKE('to/your/path/whereis/startup.m')".
4) It's done. No need to relaunch Matlab !



