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
echo '#$ -j oe'         >> "$6"
echo '#$ -m abe'        >> "$6"
echo '#$ -M ' $3        >> "$6"
echo '#$ -r n'          >> "$6"
echo '#$ -V'            >> "$6"
echo '#$ -l inter=false,ncpus=2,mem=4gb'    >> "$6"
echo  $4  $5            >> "$6"

chmod u+x $6 
qsub $6

# Pour CEPHEE qsub -N $3 -j oe -m abe -M $4 -r n -V -l inter=false,ncpus=2,mem=4gb $5