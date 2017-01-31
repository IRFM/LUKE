function [rho,theta,rho_0,theta_0] = xy2rhotheta_gb(equil_fit,x,y)
%
% Find the curvilinear couple associated to a cartesian one
%
% INPUT
%    - equil_fit: interpolated structure
%    - rho : Normalized radial coordinate
%    - theta : Poloidal angle
%    - kmax : Number of iterations of the algorithm

% OUTPUT: 
%    - x : Cartesian coordinate x
%    - y : Cartesian coordinate y

% By Guillaume Brochard (CEA-IRFM, guillaume.brochard@cea.fr)
%
%
function [rho_test] = rho1D(theta_test)%
   down = [0,0];
   up = [1,0];
   res = [0,1];
   k=0;
   kmax = 60;%Maximum number of iterations allowed
   prec = 1e-10;%Precision required
   while(k<kmax && abs(res(2))>prec)
      k = k+1;
      data1 = equilval_yp(equil_fit,down(1),theta_test);
      data2 = equilval_yp(equil_fit,up(1),theta_test);
      down(2) = data1.dxdrho*(data1.x - x) + data1.dydrho*(data1.y - y);
      up(2) = data2.dxdrho*(data2.x - x) + data2.dydrho*(data2.y - y);
      res(1) = (down(1) + up(1))/2;
      data3 = equilval_yp(equil_fit,res(1),theta_test);
      res(2) = data3.dxdrho*(data3.x - x) + data3.dydrho*(data3.y - y);
      if(down(2)*res(2)>0)
         down = res;
      else
         up = res;
      end
   end
   rho_test = res(1);
end
%
%
%
theta_0 = atan2(y,x);
rho_0 = rho1D(theta_0);
down_t = [theta_0*(9/10),0];
up_t = [theta_0*(11/10),0];
res_t = [0,1];
l=0;
%
prec = 1e-11;%Precision required
lmax = 60;%Maximum number of iterations allowed
while(l < lmax && abs(res_t(2)) > prec)
   l=l+1;
   res_t(1) = (down_t(1) + up_t(1))/2;
   rho_d = rho1D(down_t(1));
   rho_m = rho1D(res_t(1));
   data1_t = equilval_yp(equil_fit,rho_d,down_t(1));
   data2_t = equilval_yp(equil_fit,rho_m,res_t(1));
   down_t(2)= data1_t.dxdtheta*(data1_t.x - x) + data1_t.dydtheta*(data1_t.y - y);
   res_t(2) = data2_t.dxdtheta*(data2_t.x - x) + data2_t.dydtheta*(data2_t.y - y);
   if(down_t(2)*res_t(2)>0)
       down_t = res_t;
   else
       up_t = res_t;
   end
end
%
theta = res_t(1);
rho = rho1D(theta);
%
end