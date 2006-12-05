#!/bin/bash
#script de translation des fichier fortran 64 bits -> linux 32 bits
cp $1 $2
echo $1 will be translated
cat $2 | sed  -e 's/integer\*8/integer/' > $2.tmp
cat $2.tmp | sed  -e 's/INTEGER\*8/INTEGER/' > $2
grep -i "integer\*8" $2 && echo "Probleme de translation de $2" 
grep -i "integer \*8" $2 && echo "Probleme de translation de $2 (espace avant *)" 
grep -i "integer\* 8" $2 && echo "Probleme de translation de $2(espace apres *)" 
cat $2 | sed  -e 's/KMIN0(/MIN0(/' > $2.tmp
cat $2.tmp | sed  -e 's/kmin0(/min0(/' > $2
cat $2 | sed  -e 's/KMAX0(/MAX0(/' > $2.tmp
cat $2.tmp | sed  -e 's/kmax0(/max0(/' > $2
cat $2 | sed  -e 's/DMIN0(/MIN0(/' > $2.tmp
cat $2.tmp | sed  -e 's/dmin0(/min0(/' > $2
cat $2 | sed  -e 's/DMAX0(/MAX0(/' > $2.tmp
cat $2.tmp | sed  -e 's/dmax0(/max0(/' > $2
cat $2 | sed  -e 's/NINT(/INT(/' > $2.tmp
cat $2.tmp | sed  -e 's/nint(/int(/' > $2
cat $2 | sed  -e 's/DMAX1(/MAX(/' > $2.tmp
cat $2.tmp | sed  -e 's/dmax1(/max(/' > $2
cat $2 | sed  -e 's/DMAX(/MAX(/' > $2.tmp
cat $2.tmp | sed  -e 's/dmax(/max(/' > $2
cat $2 | sed  -e 's/MAX0(/MAX(/' > $2.tmp
cat $2.tmp | sed  -e 's/max0(/max(/' > $2
cat $2 | sed  -e 's/DMIN1(/MIN(/' > $2.tmp
cat $2.tmp | sed  -e 's/dmin1(/min(/' > $2
cat $2 | sed  -e 's/DMIN(/MIN(/' > $2.tmp
cat $2.tmp | sed  -e 's/dmin(/min(/' > $2
cat $2 | sed  -e 's/MIN0(/MIN(/' > $2.tmp
cat $2.tmp | sed  -e 's/min0(/min(/' > $2
cat $2 | sed  -e 's/DRAND(/RAND(/' > $2.tmp
cat $2.tmp | sed  -e 's/drand(/rand(/' > $2
cat $2 | sed  -e 's/c@linux/       /' > $2.tmp
cat $2.tmp | sed  -e 's/C@LINUX/       /' > $2

grep "mexFunction" $2 | grep  -i "subroutine" > /dev/null || \
	echo "$2 n'est pas un mexfile, pas de controles type mexfile" 
grep "mexFunction" $2 | grep  -i "subroutine" > /dev/null || exit 

grep "mxGetN" $2 | grep  -i "integer" > /dev/null || \
	echo "Il manque la declaration de mxGetN dans $2" 
grep "mxGetM" $2 | grep  -i "integer" > /dev/null || \
      echo "Il manque la declaration de mxGetM dans $2"  
grep -i  "plhs" $2 | grep  -i "integer" > /dev/null || \
      echo "Il manque la declaration de plhs(*) dans $2"  
grep -i "prhs" $2 | grep  -i "integer" > /dev/null || \
      echo "Il manque la declaration de plhs(*) dans $2"
grep -i "nlhs" $2 | grep  -i "integer" > /dev/null || \
	echo "Il manque la declaration de nlhs dans $2" 
grep -i "nrhs" $2 | grep  -i "integer" > /dev/null || \
	echo "Il manque la declaration de nrhs dans $2" 
grep "mxCreateFull" $2 | grep  -i "integer" > /dev/null || \
	echo "Il manque la declaration de mxCreateFull dans $2" 
grep "mxGetPr" $2 | grep -i "integer" > /dev/null || \
	echo "Il manque la declaration de mxGetPr dans $2" 
      
rm -rf *.tmp

exit

