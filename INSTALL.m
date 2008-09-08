% Steps for (un)installing LUKE
% 
% ========================================================
% INSTALL LUKE
% ========================================================
% 
% 1) Start MatLab
% 
% 2) cd ~/LUKE
% 
% 3) Type "install_LUKE" or "install_LUKE('yourpath')" where yourpath is either
%  - The location of an existing startup.m on which the LUKE paths will be set
%  - The location where you want a new startup.m file to be created.
%     
% 4) If you wish to use external linear algebra packages (MUMPS, PETSc and SUPERLU are supported) 
%  - Install packages (for example in LUKE/Packages)
%  - Edit make_path_LOCAL.m to set the paths to installed packages 
% 		OR
%  - The path can be set interactively during the installation
% 
% 5) It's done. No need to restart Matlab !
% 
% ========================================================
% UNINSTALL LUKE
% ========================================================
% 
% 1) Start MatLab
% 
% 2) cd ~/LUKE
% 
% 3) Type "uninstall_LUKE or uninstall_LUKE('yourpath')".
% 
% 4) It's done. No need to restart Matlab !
% 
% ========================================================
% UPDATE LUKE
% ========================================================
% 
% A new version of LUKE can be distributed in three different forms, for example:
% 
% a) LUKE.tar.gz : The latest version of LUKE in a LUKE/ folder
% b) LUKE_1_5.tar.gz : LUKE version 1.5 in a LUKE_1_5/ folder
% c) LUKE_1_5_1_patch.tar.gz : LUKE version 1.5.1 in a LUKE_1_5/ folder
% 
% 1) case a) and c): uninstall LUKE as described above
% 
% 2) Go to the folder where LUKE is to be installed and untar the file.
% 
%    - in the case a), if the LUKE folder already exists, the new files will 
%      replace older files.
% 
%    - in the case b), a new LUKE_1_5 folder will be installed 
%      and previously installed LUKE versions will remain operational.
% 
%    - in the case c), the LUKE_1_5_1_patch.tar.gz file must be untared
%      in the location of LUKE_1_5. Only the updated files will be replaced. 
% 
%    - in the cases a) and c), the PATH_*.mat files and the 
%      personal make_PATH_*.m files won't be replaced.
% 
% 3) install LUKE.
% 
% ========================================================
% REQUIREMENTS
% ========================================================
% 
% For a quick and easy install of LUKE, there are several requirements:
%
%	a) a gcc version consistent with the running MatLab version 
%      (> 4.00 recommanded)
%   b) a g95 fortran compiler (gfortran can be used with latest gcc release)
%	c) the program graphviz for graphs and documentation generation must be 
%      installed (open-source)
%	d) a TeX/LaTeX must be available with TeX4ht and pdfLateX capabilities
%
% For external packages like MUMPS, PETSc, SUPERLU, it is better to install 
% and compile them before performing the install of LUKE, though it can always
% be done later.
%
% For enabling distributed computing, it is necessary to have several MatLab
% licenses and adjust the script to the environment where LUKE is installed.
%

