#*****************************************************************************
#   NOM  DU FICHIER 	 :  Makefile
#   DESCRIPTION DU FICHIER : Makefile du client Linux TSLib 
#   Modifications    :
# *****************************************************************************

 CC = gcc 
 FF = gfortran

 CFLAGS = -fPIC -g 
 COMP = 
 FFLAGS = -c 

 INSTALL = /usr/bin/install -m 644
 INC_COMMUN = tsdef.h tsmes.h
 INC_COM    = tsconf.h tshote.h tslib.h
 INC_CLIENT = tsfonc.h 
 INC_CL_UTIL = tsext.h tstype.h

 OBJ =  tsutil.o\
	tserr.o\
	tsecri.o\
	tslect.o\
	ceat.o \
	cea_tswdb.o \
	tsdecl.o \
        tscom.o \
        tsdesc.o

 SRC =  tsutil.c\
	tserr.c\
	tsecri.c\
	tslect.c\
	ceat.c \
	cea_tswdb.c \
	tsdecl.c \
        tscom.c \
        tsdesc.c

SRCH = ceaf.h functs.h tsdef.h tshote.h tstype.h \
       ceat.h tdef.h tserreur.h def.h tsarcad.h tsext.h tslib.h \
       erreur.h tsconf.h tsfonc.h tsmes.h

SRCF =  tslib_fcf.c  tslib_fcd.c

OBJFF = tslib_fcf.o
OBJFD = tslib_fcd.o

all : libTS.a libTSFf.a libTSFd.a Tetat

.f.o:
	$(FF) $(FFLAGS) $<
.c.o:
	$(CC) -c $(CFLAGS) $<


libTS.a: $(OBJ)
	ar ru $@ $(OBJ)
	ranlib $@

TSLib.a : $(INC_COMMUN) $(INC_COM) $(INC_CLIENT) $(INC_CL_UTIL)

libTSFf.a: $(OBJFF)
	ar ru $@ $(OBJFF)
	ranlib $@

libTSFd.a: $(OBJFD)
	ar ru $@ $(OBJFD)
	ranlib $@

Tetat: Tetat.o 
	$(CC) -g -o $@ Tetat.o libTS.a -lm

tscom.o : tshote.h tsconf.h
tscom_random.o : tshote.h tsconf.h
ceat.o: tsdef.h ceaf.h
$(OBJ): tsarcad.h

dist :
	(make clean; make "CFLAGS=-std 0 -non_shared"; echo 'Copying files in distribution'; \
         d=`date`;mkdir distrib/"$$d"; mkdir distrib/"$$d"/src; mkdir distrib/"$$d"/lib; \
         cp *.a distrib/"$$d"/lib/.; cp $(SRC) distrib/"$$d"/src/.; cp $(SRCF) distrib/"$$d"/src/. ; \
         cp $(SRCH) distrib/"$$d"/src/.; \
         cp Makefile distrib/"$$d"/src/.;  make clean; make)

clean :
	rm -f *.o core *.BAK *JNL *~ *.a
