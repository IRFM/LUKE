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
*
3
4s(2,*)3d(10,*)4p(6,*)5s(2,*)4d(10,*)5p(4,*)

3d, 4s, 4p, 4d, 5s, 5p

0,0
0
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

rsave DHF_W42

rci << eof
y   
DHF_W42
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
DHF_W42
y
2
eof

rm mcp*
rm rci.res
rm rcsf*
rm clist.new
