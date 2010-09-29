#!/bin/sh
# $1 is the execution directory
# $2 is the job submission command
# $3 commande
# $4 matlabroot
# $5 matfile
# $6 bachfile name

cd $1

echo '#\!/bin/csh'      > "$6"
echo  $3  $4 $5         > "$6"

chmod u+x $6 
$2 $6
