#!/bin/sh

set -x

#  1.  Generate grasp2K expansions for ground state

#Generate input file for rcsfgenerate
rcsfgenerate <<EOF1
*
2
3s(2,i)3p(6,i)4s(2,i)3d(10,i)4p(2,i)

3s, 3p, 3d, 4s, 4p
0,0
0
n
EOF1

cp rcsf.out DFgrd.c

rcsfgenerate <<EOF1
*
2
3s(2,*)3p(6,*)4s(2,*)3d(10,*)4p(2,*)

5s, 5p, 5d, 5f, 5g
0,0
2
n
EOF1

cp rcsf.out grd.c

rcsfsplit << EOF
grd
3
3s,3p,3d
3
4s,4p,4d,4f
4
5s, 5p, 5d, 5f, 5g
5
EOF

#  2.   Get nucleardata
rnucleus <<S1
74
184
n
183.84
1
1
1
S1

cat isodata

# 3. Get initial estimates for ground state

cp DFgrd.c rcsf.inp
#Get angular data
rangular  <<S4
y
S4

#  Get initial estimates of wave functions
rwfnestimate <<S5
y
2
*
S5

# Perform self-consistent field calculations
rmcdhf > outgrd_rmcdhf <<S6
y
1
*
*
100
S6

#  Save the result to even1
rsave DFgrd

cp DFgrd.w grd2.w


#	3rd layer
cp grd3.c rcsf.inp

#  Get angular data
rangular <<S4
y
S4

# Get initial estimates of wave functions
rwfnestimate <<S5
y
1
grd2.w
*
2
*
S5

# Perform self-consistent field calculations
rmcdhf > outgrd_rmcdhf_3 <<S6
y
1
3*

100
S6

rsave grd3


#	4th layer
cp grd4.c rcsf.inp

#  Get angular data
rangular <<S4
y
S4

# Get initial estimates of wave functions
rwfnestimate <<S5
y
1
grd3.w
*
2
*
S5

# Perform self-consistent field calculations
rmcdhf > outgrd_rmcdhf_4 <<S6
y
1
4*

100
S6

rsave grd4


#	5th layer 
cp grd5.c rcsf.inp

#  Get angular data
rangular <<S4
y
S4

# Get initial estimates of wave functions
rwfnestimate <<S5
y
1
grd4.w
*
2
*
S5

# Perform self-consistent field calculations
rmcdhf > outgrd_rmcdhf_5 <<S6
y
1
5*

100
S6

rsave grd5

# RCI calculations for ground5
rci > outground_rci <<S6
y
grd5
y
y
1.d-6
y
n
n
y
3
1
S6

# electron density
rdensity <<S6
y
grd5
y
2
