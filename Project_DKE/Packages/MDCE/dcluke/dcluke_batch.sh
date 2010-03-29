#!/bin/sh
# $1 is the execution directory
# $2 is the job submission command
# $3 commande
# $4 matfile
# $5 bachfile name

cd $1

echo '#\!/bin/csh'      > "$5"
echo  $3  $4            > "$5"

chmod u+x $5 
$2 $5
