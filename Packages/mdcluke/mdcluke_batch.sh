#!/bin/sh
# $1 is the execution directory
# $2 job name
# $3 user name
# $4 commande
# $5 matfile
# $6 bachfile name

cd $1

echo '#\!/bin/csh'      >  "$6"
echo '#$ -N ' $2        >> "$6"
echo '#$ -cwd'          >> "$6"
echo '#$ -j y'          >> "$6"
echo '#$ -M ' $3        >> "$6"
echo '#$ -R n'          >> "$6"
echo '#$ -V'            >> "$6"
echo '#$ -q batch.q'    >> "$6"
echo '#$ -sync n'       >> "$6"
echo  $4  $5            >> "$6"

chmod u+x $6 
qsub $6
