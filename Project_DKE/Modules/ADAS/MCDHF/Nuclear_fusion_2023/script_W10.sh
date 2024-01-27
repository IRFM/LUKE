#!/bin/bash

rnucleus << eof
74
184
n
183.84
1
1
1
eof

rcsfgenerate <<EOF1
* ! Orbital order
5  ! Selected core
6s(2,*)4f(4,*)5d(4,*)
*
6s,5d,4f
           0           0  ! Lower and higher 2*J
           0  ! Number of excitations
n
EOF1

mv rcsf.out rcsf.inp

rangular << eof
y
eof

rwfnestimate << eof
y
2
*
eof

rmcdhf << eof
y
1
*
*
100
eof

rsave DHF_W10

rci << eof
y   
DHF_W10
y  
y   
1.E-6
y 
n 
n 
y 
5 
1
eof

rdensity << eof
y
DHF_W10
y
2
eof

rm mcp*
rm rci.res
rm rcsf*
rm clist.new
