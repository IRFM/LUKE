#!/bin/csh
# $1 is the execution directory
# $2 is the job submission command
# $3 commande
# $4 matlabroot
# $5 matfile
# $6...n: additional commands (xgrid only)
# $n+1 bachfile name

cd $1

if ($# == 6) then
	echo '#\!/bin/csh'      > "$6"
	echo  $3  $4 $5         > "$6"
	
	chmod u+x $6 
	$2 $6
endif

if ($# == 7) then
    echo '#\!/bin/csh'      > "$7"
    echo  $3 $4  $5 \"$6\"  > "$7"
    chmod u+x $7 
    $7
endif
