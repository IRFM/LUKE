#!/bin/bash

rnucleus << eof
18
40
n
39.994
1
1
1
eof

rcsfgenerate << eof
* ! Orbital order
2  ! Selected core
3s(2,*)3p(6,*)
*
3s,3p
           0           0  ! Lower and higher 2*J
           0  ! Number of excitations
n
eof

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

rsave DHF_Ar0

rci << eof
y   
DHF_Ar0
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
DHF_Ar0
y
2
eof

rm mcp*
rm rci.res
rm rcsf*
rm clist.new
