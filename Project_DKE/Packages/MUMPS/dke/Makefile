# This file is part of MUMPS VERSION 4.6.1
# This Version was built on Fri Feb 17 14:27:51 2006
#
# modified for using with DKE (Y.PEYSSON, CEA-DRFC, yves.peysson@cea.fr, J. DECKER, CEA-DRFC, joan.decker@cea.fr)
#

default:double

all: simple double cmplx cmplx16

double : mumpsdke

include ../Makefile.inc

.SUFFIXES: .F .o
.F.o:
	$(FC) $(OPTF) $(INC) -I. -I../include -c $*.F

.SUFFIXES: .c .o
.c.o:
	$(CC) $(OPTC) $(INC) -I. -I../include -c $*.c

clean:
	$(RM) *.o mumpsdke
	
mumpsdke: ../lib/libdmumps.a mumpsdke.o
	$(FL) -o mumpsdke $(OPTL) mumpsdke.o ../lib/libdmumps.a $(LIB) $(LIBBLAS) $(LIBOTHERS) $(LORDERINGS)

../lib/libsmumps.a:
	@ echo 'Error: you should build the library ../lib/libsmumps.a first'
	exit -1
../lib/libdmumps.a:
	@ echo 'Error: you should build the library ../lib/libdmumps.a first'
	exit -1
../lib/libcmumps.a:
	@ echo 'Error: you should build the library ../lib/libcmumps.a first'
	exit -1
../lib/libzmumps.a:
	@ echo 'Error: you should build the library ../lib/libzmumps.a first'
	exit -1


