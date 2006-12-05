Fortran based mex-files are different for 64 or 32 bits processors. 
Fortran source files whose names end by _64b are for 64 bits processors. 
In order to use mex-files with 32 bits processors, you must convert it 
first. 

In this directory, type

./m64t32.sh <input_filename.f> <output_filename.f>

the ouput file should be compatible with 32 bits processors.
