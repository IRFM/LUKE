ALL= tsbase tsmat tsrqt tsdate tsoccur tsdernier_choc \
     tsexist tsstratmex nbwrite ifloor1 iround simpsint tsmatYB tsbaseYB tsldc \
     tsltr tsrfile
#     tsample tstablet tsplinet tswcert bin2 tswfile 

OPTIONS = -DUSE_FUNCTION_PROTOTYPES  -g# -DDEBUG
INCLUDES = -I$./ -I/Applications/Sciences/MatLab/extern/include
COPTS = -c 
FOPTS = -g -c 
CMEX = /Applications/Sciences/MatLab/bin/mex -I/usr/include -I./
LIB =  /Users/ypeysson/Desktop/TSLib/libTS.a
LIBYB =  /usr/agena/devarc/tslib/dev/client2000/libTS.a
AR = ar
DLLMEX = 

all:	${ALL}

.c.o:
	cc $(COPTS) $(INCLUDES) $(OPTIONS) $<
.F.o:
	f77 $(FOPTS) $<
tsdate:
	$(CMEX) $(OPTIONS) tsdate.c $(LIB)
teste:
	$(CMEX) $(OPTIONS) doubleelement.c
tsmat:
	$(CMEX) $(OPTIONS) tsmat.c tsignit.c tsparse.c $(LIB)
tsbase:
	$(CMEX) $(OPTIONS) tsbase.c tsignit.c tsparse.c $(LIB)
tsmatYB:
	$(CMEX) $(OPTIONS) tsmatYB.c tsignit.c tsparse.c $(LIBYB)
tsbaseYB:
	$(CMEX) $(OPTIONS) tsbaseYB.c tsignit.c tsparse.c $(LIBYB)
tsrqt:
	$(CMEX) $(OPTIONS) tsrqt.c $(LIB)
tsoccur:
	$(CMEX) $(OPTIONS) tsoccur.c $(LIB)
tsdernier_choc:
	$(CMEX) $(OPTIONS) tsdernier_choc.c $(LIB)
tsexist:
	$(CMEX) $(OPTIONS) tsexist.c $(LIB)
tsstratmex:
	$(CMEX) $(OPTIONS) tsstratmex.c $(LIB)
nbwrite:
	$(CMEX) $(OPTIONS) nbwrite.c $(LIB)
ifloor1:
	$(CMEX) $(OPTIONS) ifloor1.c
iround:
	$(CMEX) $(OPTIONS) iround.c
simpsint:
	$(CMEX) $(OPTIONS) simpsint.c simpson.o
tsample:
	$(CMEX) $(OPTIONS) tsample.c ctable1.o cround.o cspline.o
tstablet:
	$(CMEX) $(OPTIONS) tstablet.c
tsplinet:
	$(CMEX) $(OPTIONS) tsplinet.c
lib_bd.o: lib_bd.sc
	esqlc	lib_bd.sc
	cc -c -g -O1 lib_bd.c
tswcert:
	$(CMEX) $(OPTIONS) tswcert.c lib_bd.o $(LIB) \
        $(II_SYSTEM)/ingres/lib/libingres.a \
        -lpthread -lrt -lm
bin2:
	$(CMEX) $(OPTIONS) bin2.c
tsrfile:
	$(CMEX) $(OPTIONS) tsrfile.c $(LIB)
tswfile:
	$(CMEX) $(OPTIONS) tswfile.o $(LIB)

tsldc:
	$(CMEX) $(OPTIONS) tsldc.c $(LIB)
tsltr:
	$(CMEX) $(OPTIONS) tsltr.c $(LIB)

tsdate: tsdate.o 
tsmat : tsmat.o tsparse.o tsignit.o tsmat.h tsbamat.h $(LIB)
tsbase: tsbase.o tsparse.o tsignit.o tsbamat.h $(LIB)
tsmatYB : tsmatYB.o tsparse.o tsignit.o tsmat.h tsbamat.h $(LIBYB)
tsbaseYB: tsbaseYB.o tsparse.o tsignit.o tsbamat.h $(LIBYB)
tsrqt : tsrqt.o  $(LIB)
tsdernier_choc : tsdernier_choc.o $(LIB)
tsexist : tsexist.o $(LIB)
tsstratmex : tsstratmex.o $(LIB)
nbwrite : nbwrite.o $(LIB)
ifloor1 : ifloor1.o
iround : iround.o
simpsint : simpsint.o simpson.o
tsample : tsample.o ctable1.o cround.o cspline.o
tstablet : tstablet.o
tsplinet : tsplinet.o
tswcert : tswcert.o lib_bd.o $(LIB)
bin2 : bin2.o
tsrfile: tsrfile.o $(LIB)
tswfile: tswfile.o $(LIB)
tsldc: tsldc.o tsbamat.h $(LIB)
tsltr: tsltr.o tsbamat.h $(LIB)

dist:	
	tar cvf tsbamat.tar tsbase.c tsmat.c tsparse.c tsignit.c *.h Makefile
	gzip -v tsbamat.tar
	ls -l tsbamat.tar.gz

install:
	cp tsbase.mexds /usr/norma/buravand/matlab
	cp tsmat.mexds  /usr/norma/buravand/matlab
print :
	pr -l87 < tsmat.c | lpr
	pr -l87 < tsbase.c | lpr
	pr -l87 < tsparse.c | lpr
	pr -l87 < tsignit.c | lpr
	pr -l87 < tsbamat.h | lpr
	pr -l87 < tsmat.h | lpr
clean:
	rm -f *.o *.BAK *.sav *.old a.out core  *~ *.mexaxp
