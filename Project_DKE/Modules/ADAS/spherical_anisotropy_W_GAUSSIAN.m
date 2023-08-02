%            
close all
%
linestyle(1) = {'-'};
linestyle(2) = {'--'};
linestyle(3) = {'-.'};
linestyle(4) = {':'};
linestyle(5) = {'-'};
linestyle(6) = {'--'};
%
linecolor(1) = {'r'};
linecolor(2) = {'b'};
linecolor(3) = {'g'};
linecolor(4) = {'m'};
linecolor(5) = {'c'};
linecolor(6) = {'k'};
%
marker(1) = {'o'};
marker(2) = {'x'};
marker(3) = {'+'};
marker(4) = {'*'};
marker(5) = {'s'};
marker(6) = {'d'};
%
siz = 20+14i;
%
y = [0.00
0.07
0.07
0.00
0.00
0.09
0.00
0.00
0.09
0.14
0.08
0.07
0.00
0.00
0.00
0.00
0.01
0.01
0.00
0.01
0.03
0.00
0.04
0.04
0.03
0.08
0.08
0.03
0.00
0.04
0.04
0.00
0.05
0.10
0.05
0.11
0.00
0.06
0.00
0.11
0.12
0.29
0.16
0.17
0.00
0.00
0.00
0.04
0.00
0.10
0.05
0.00
0.05
0.00
0.00
0.07
0.00
0.15
0.17
0.45
0.26
0.30
0.00
0.00
0.00
0.18
0.19
0.54
0.32
0.38
0.00
0.00
0.00
0.00];
%
amp = [53.80
41.14
32.26
27.71
24.16
21.25
18.70
17.51
15.61
14.31
12.90
12.10
10.46
9.83
9.25
8.73
7.89
7.08
6.67
6.28
5.93
5.59
5.28
4.99
4.72
4.46
4.21
3.98
3.76
3.53
3.32
3.11
2.90
2.71
2.52
2.33
2.15
1.97
1.80
1.64
1.48
1.33
1.17
1.02
0.87
0.73
0.59
0.56
0.52
0.49
0.46
0.43
0.40
0.37
0.34
0.31
0.28
0.25
0.22
0.19
0.16
0.13
0.10
0.07
0.
0.03
0.03
0.02
0.02
0.02
0.01
0.01
0.00
0.00];
%
x = [0:73];
%
figure('Name','Tungsten (Z = 74)');
[ax] = graph1D_jd(x,y,0,0,'Screened ion charges Z_{0,s}','\Delta\Theta (a.u.)','Tungsten (Z = 74)','GAUSSIAN code',[0,73],[0,1],linestyle{1},'o',linecolor{1},1,siz,gca);
%graph1D_jd(dft.r,dft.ne(:,i),0,1,xlab,ylab1,tit1,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);hold on
grid minor
drawnow
%
print_opt = 2;
print_jd(print_opt,['SphericalanisoptropyGaussian_W_74'],'.',get(gcf,'Number'))



