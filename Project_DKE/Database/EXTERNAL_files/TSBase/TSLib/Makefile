#*****************************************************************************
#   NOM  DU FICHIER 	 :  Makefile
#   DESCRIPTION DU FICHIER : Makefile du client Unix/OSF TSLib 
#   Modifications    :
# *****************************************************************************

 CC = gcc #insure
 FF = f77 

 CFLAGS = -g
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

all : libTS.a 

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

rqtest: rqtest.o
	cc -g -o rqtest rqtest.o libTS.a -lm
rqtest: libTS.a

TestWP: TestWP.o 
	cc -g -o $@ TestWP.o libTS.a -lm

Tetat: Tetat.o 
	$(CC) -g -o $@ Tetat.o libTS.a -lm

TestTSLib: TestTSLib.o 
	$(CC) -g -o $@ TestTSLib.o libTS.a -lm

new_recette: new_recette.o t2.o
	$(CC) -g -o $@ new_recette.o t2.o libTS.a -lm
recette: recette.o 
	cc -g -o $@ recette.o libTS.a -lm
recette: libTS.a
new_recette: libTS.a
TestWP: libTS.a

tele.o :
	cc -c  -g -migrate -assume noaligned_objects tele.c
tele: tele.o
	cc -g -migrate -assume noaligned_objects  -o $@ tele.o \
	libTS.a /usr/drfc/devarc/tele/dev/New/libdisp.a 
tele: libTS.a /usr/drfc/devarc/tele/dev/New/libdisp.a

bob: bob.o t2.o 
	cc -g -o $@ bob.o t2.o libTS.a -lm
bob: libTS.a

t_charger: t_charger.o 
	cc -g -o $@ t_charger.o libTS.a 
t_charger: libTS.a

int: int.o
	f77 -g -o int int.o libTSFf.a TSLib.a 
int : TSLib.a libTSFf.a

tfort: tfort.o
	f77 -g -o tfort tfort.o libTSFf.a TSLib.a 
tfort : TSLib.a libTSFf.a

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
	rm -f *.o core *.BAK *.old *JNL *~
