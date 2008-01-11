Fortran based mex-files are different for 64 or 32 bits processors. 
Fortran source files whose names end by _64b are for 64 bits processors. 

Therefore, in this directory ~/LUKE/Project_DKE/Modules/Helena/MEX/Source , 
duplicate the appropriate mexfile regarding the type of processor on which 
MatLab is installed, and rename it according to the following rules:

helmex77_32b.f -> helmex77.f (no integer*8)
or 
helmex77_64b.f -> helmex77.f (some integer*8)

and

separatrice_32b.f -> separatrice.f (no integer*8)
or
separatrice_64b.f -> separatrice.f (some integer*8)


before building the binaries from the directory ~/LUKE/Project_DKE/Modules/Helena/MEX/Bin