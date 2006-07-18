Building mex-files depend of the computer, the language (C, FORTRAN-77, 
FORTRAN-90) and the type of compiler (GNU, commercial,...). For your 
specific configuration, you need to setup all your library and compiler 
paths, and in addition, you must specify  compiling options (see MatLab documentation) in 
the .sh files. Here, two .sh files are given as examples for FORTRAN-77 and FORTRAN-90 
based mex-files on MS-Windows PC (pcwin), linux on PC compatible (gnlx86), 
linux on AMD64 (gnlxa64) and Macintosh OS X (mac). For compiling C-based mex-files, both FORTRAN-77 and 
FORTRAN-90 .sh files may be used indifferently. 

Once .sh file is set-up, go to Matlab and move to the local directory where the 
source of the mex-file is stored. If necessary, convert it for a 64 bits 
to a 32 bits processor using the script m64t32.sh

./$HOME/MEX/m64t32.sh <input_filename.f> <output_filename.f>

Then type

make_mex('filename',opts)

opts = '' for C files
opts = 'f77' or 'f90' for FORTRAN files.


Y. Peysson, CEA-DRFC (yves.peysson@cea.fr) and J. Decker, CEA-DRFC (joan.decker@cea.fr)