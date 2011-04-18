function [P_ref, K_ref, E_ref] = reflect_tcv(shotnum, shotime , P_end, K_end, E_end )
% ray freq. X2-mode in TCV 82.7 GHz
%
%
%   reflect_tcv.m
%
% inputs: (from LUKE/C3PO LCFS)
% - shot and time numbersS
% - X exit ray position from LCFS (p) in [m]
% - K wave vector in X in [m-1], gives also the direction of the ray propagation
% - E field in X 
%
% X,K,E are in the rectangurlar reference frame of TCV (used by TORAY)
%
%       - x is the major radius direction: 0 at the axis of the machine; positive
%         outward, from Left to Right in a TCV top view)
%       - y is the major radius direction: 0 at the axis of the machine; positive
%         upward, from the axis in a TCV top view)
%       - z is the vertical direction: 0 at the axis of the machine; positive
%         coming out from the axis in a TCV top view)
%
% to interface with LUKE/C3PO reference (rho,theta,phi) we need to tranform the
% coodinates
%re
% outputs:
% - WaveX ray component in X-MODE (XoutX,KoutX,EoutX)
%   NOTE: the Kout is normalized to k_in ( kk = -k_in/norm(k_in) ); 
%   thus, norm(Kout) = 1
%
% - WaveO ray component in O-MODE (XoutO,KoutO,EoutO)
% - P contains the power fraction in X and O-MODE in the new incoming LCFS position
%
% the main body of this function exploit the reflect_toray_rays.m routine of 
%  /home/ffelici/matlab/


addpath /home/ffelici/matlab/ECPOL/pol_code_develop/
addpath /home/gnesin/

% 
R_end_XY = sqrt(P_end(1).^2+ P_end(2).^2);





X=P_end; K = K_end; E = E_end;       

disp(' ');
disp('*** running reflect_tcv ***')
disp(' ');

shot = str2num(shotnum);
time = str2num(shotime);
 %shot = 25474; time = 0.9;
     
do_polarization = 1; % do not worry about polarization for now, just flip k vector
doplot = 1;
plot_reflection = 0;
do_top_plot =0; % =1 enable 3D plot to check the ray reflection

% data at plasma exit (from LUKE/C3PO) the calculation is performed ray by ray
 % the Xposition is in [m]
  
 %iend(iray) = find(~isnan(raydata.s_out(:,iray)),1,'last'); %index upon which ray ends
 xend = X(1); %(:,iray) = raydata.x_out(iend(iray),iray)/100;
 yend = X(2); %(:,iray) = raydata.y_out(iend(iray),iray)/100;
 zend = X(3); %(:,iray) = raydata.z_out(iend(iray),iray)/100;
 %pend(:,iray) = raydata.p_out(iend(iray),iray)/100;
 kxend= K(1); %(:,iray) = raydata.kvx(iend(iray),iray);
 kyend= K(2); %(:,iray) = raydata.kvy(iend(iray),iray);
 kzend= K(3); %(:,iray) = raydata.kvz(iend(iray),iray);
 
 Exend= E(1); %(:,iray) = [raydata.ex_r(iend(iray),iray) + i*raydata.ex_i(iend(iray),iray)];
 Eyend= E(2); %(:,iray) = [raydata.ey_r(iend(iray),iray) + i*raydata.ey_i(iend(iray),iray)];
 Ezend= E(3); %(:,iray) = [raydata.ez_r(iend(iray),iray) + i*raydata.ez_i(iend(iray),iray)];
 
% position, k vectors and E field at plasma exit
%pend = [1.04;-0.45;0];% just for test
pend = [xend;yend;zend]; % position
%kend = [1.0834;-0.3321;-0.0006].*(1000); % just for test
kend = [kxend;kyend;kzend]; % k vector
Eend = [Exend;Eyend;Ezend]; % E vector



% check the end point is in the TCV vacuum chamber


%----------------------------------------------------------
disp(' '), disp(' ray parameters (exit from the LCFS): (RED point)')
disp(['P_exit = ', num2str(pend')])
disp(['k_exit = ', num2str(kend')])
disp(['E_exit = ', num2str(Eend')]), 




me = 9.10938188e-31; qe = 1.60217646e-19;
%O_c = qe*sqrt(sum(B.^2,1)) / me / (2*pi);
freq = 82.7e9;
cs = 299792458; % speed of light [m/s]

kkk = (freq*2*pi)/cs; % test the k norm
disp(['NORM(K_test) = freq/c: ', num2str(kkk), ' [1/m]']),disp(' ')

%------------------- intersect with the TCV wall -----------
mdsopen(shot)
rt=mdsdata('static("R_T")'); % in cm!
zt=mdsdata('static("Z_T")');
rr=rt;
zz=zt;  


% allocate
inointers = [];
l_out = nan; %*ones(raydata.nbr,1);
xw = nan; %*ones(raydata.nbr,1);
yw = nan; %*ones(raydata.nbr,1);
zw = nan; %*ones(raydata.nbr,1);


% here use inters3d to find the distance from the exit point to the TCV wall
 [l2pl,dd,cc]=inters3d_tcv(xend,yend,zend,...
                       kxend,kyend,kzend,rr',zz');

 %if  length(l2pl)<=2 & (R_end_XY > 1.13596 | R_end_XY < 0.624 |P_end(3) < -0.75 | P_end(3) > 0.75) 
 %l_out = max(abs(l2pl)); % to consider P_out on the wall
 %disp(' WARNING : l_out is chosen as a "max"')
 %else
 %l_out = min(abs(l2pl)); % distance of closest wall intersection
 l_out =min(l2pl(find(l2pl>100.*eps)));
 
 if sum(sign(l2pl)) == - length(l2pl)
 disp('l2pl has only negative elements')
 l_out = 0,min(abs(l2pl(find(abs(l2pl)>100.*eps))));
 end
 
 
 %end;
 
 if ~isempty(l_out)%(Pw),			% if 0 then no intersection points
                                        % wall intersection points
                                        xw= xend+kxend*l_out;%Pw(1); %xend+kxend*l_out;
                                        yw=yend+kyend*l_out;%Pw(2); %yend+kyend*l_out;
                                        zw=zend+kzend*l_out;%Pw(3); %zend+kzend*l_out;
 else
  disp('no intersection found with the wall');
  disp('intersection point is replaced with the edge point')
  inointers = [inointers 1]; % indices of rays with no wall intersection
 end
 
  if ~isempty(inointers)
   warning(['****** ', int2str(numel(inointers)), ' ray(s) did not find an intersection, eliminating ray(s)']) 
  end 

rw=sqrt(xw.^2+yw.^2);		% major-radial location of intersection point
inotinnerwall = find((rw-min(rr))>1e-6); % rays not hitting inner wall
rw1 = (xw.^2+yw.^2+zw.^2);
% ----------------------------------------------------------------------
%    REFLECTION CASES; TCV CROSS SECTION IS NOT EXACLTLY A RECTANGLE!!!
% ----------------------------------------------------------------------
R_tcv_int = 0.624 + 0.0001; R_tcv_out = 1.136 - eps;
direction = 0;
sign_w =1; % it is ok for outer reflection (also top and bottom)

 if abs(xw)  <= R_tcv_int & abs(yw)  <= R_tcv_int
    sign_w = -1;
    disp('Inward ray: inner wall reflection.')
 
    
 end; 
 
 if abs(rw)  >= R_tcv_int & abs(zw)  <= 0.55
    sign_w=1  ;  
    disp(' Outward ray: outer wall reflection')
 end
 
 if abs(rw)  >= R_tcv_int & (zw)  >= (max(zz)-0.0001)
    sign_w=1  ;  
    direction = 1;
    disp(' TOP wall reflection')
 end
 
 if abs(rw1) > (0.97.^2  + 0.75.^2  ) & abs(rw1) < (1.135.^2  + 0.55.^2  ) & zw>0.55
    sign_w=1  ;  
    direction =  2;
    th_2 = atan((0.75-0.55)./(1.135-0.97));  % angle for the normal vector in the X-Z plane
    phi_2 = atan((yw)./(xw));
    disp(' TOP(out) wall reflection')
 end
  
 if abs(rw1) > (0.62457.^2  + 0.704.^2  ) & abs(rw1) < (0.67164.^2  + 0.75.^2  ) & zw>0.62457
    sign_w=1  ;  
    direction =  3;
    th_3 = atan((0.75- 0.704)./(0.67164-0.62457));% is 45 degrees
    phi_3 = atan((yw)./(xw));
    disp(' TOP(in) wall reflection')
 end
 
 if abs(rw)  >= R_tcv_int & (zw)  <= (min(zz)+0.0001)
    sign_w=1  ;  
    direction =  -1;
    disp(' BOTTOM wall reflection')
 end


if abs(rw1) > (0.97.^2  + 0.75.^2  ) & abs(rw1) < (1.135.^2  + 0.55.^2  ) & zw<-0.55
    sign_w=1  ;  
    direction =  -2;
    th_2 = atan((0.75-0.55)./(1.135-0.97));
    phi_2 = atan((yw)./(xw));
    disp(' BOTTOM(out) wall reflection')
 end

 
 if abs(rw1) > (0.62457.^2  + 0.704.^2  ) & abs(rw1) < (0.67164.^2  + 0.75.^2  ) & zw<0.62457
    sign_w=1  ;  
    direction =  -3;
    th_3 = atan((0.75- 0.704)./(0.67164-0.62457)); % is 45 degrees
    phi_3 = atan((yw)./(xw));
    disp(' BOTTOM(in) wall reflection')
 end

% --------------------------------------------------

if ~isempty(inotinnerwall)
 warning(['****** ', int2str(numel(inotinnerwall)), ' ray(s) did not intersect inner wall, eliminating ray(s)']) 
end

%iok = setdiff(i_notelim,union(inointers,inotinnerwall)); % iok takes the index of the remaining
% beams over which the calculation will go on.. i = index ok = that are OK for the prosecution
% of the current analysis

%----------------------------------
 iok = 1; % for a ray by ray case
%----------------------------------

if isempty(iok); 
 warning('no rays could be reflected')
 raygeom_files = []; torinput_files = [],suffixes=[]; % return empty outputs
 return
end

%----------------------- inward Wall normals at intersection points--
zw = zw; % z of wall
%sign_w= 1;
nw = sign_w.*[xw'; yw'; zeros(size(xw))'] ./ (ones(3,1)*rw'); % inner wall normal in the (X-Y)plane 
pw = [xw';yw';zw']; % position of wall

disp('the Black point indicates the'),disp([' wall interctepion at p_wall = ' num2str(pw')])

 % Use ECPOL tools to handle the reflection including the correct
% polarization
if ~exist('mirror','file'); error('ECPOL tools are not in your path'); end

k_in = kend(:,iok); % "in" means INTO the mirror (wall)
E_in = Eend(:,iok);

% if we don't worry about the polarization, any E field will do (ignored
% anyway)

%---------------------------------------------------
if do_polarization
    % pre-load some stuff we'll need
    %load(fname_torinputs)
    %time = torinputs.time;
    %shot = torinputs.shot;
    
    psi = psitbxtcv(shot,time);  % get psi from the tree. This is psi with the correct signs and magnitude at the center.
    
    mdsopen(shot);
    rbou = mdsdata('\results::r_contour[,$1]',time); rbou = rbou(~isnan(rbou));
    zbou = mdsdata('\results::z_contour[,$1]',time); zbou = zbou(~isnan(zbou));
    
    % (rbou,zbou)are the coordinates of the last close flux surface from the TCV
    %  magnetic reconstruction
    
    RBphi = mdsdata('\magnetics::RBPHI[$1]',time); % get R*Bphi (is a scalar)
    
    mdsclose;
end
%--------------------------------------------------------------------------
%------------------
%-----------------------------------------------
%  ANALISI AT THE EXIT OF THE LCFS P = P_end
% -----------------------------------------------
 if ~do_polarization
    Nk = null(k_in'); E_in = Nk(:,1); % E is perpendicular to k
    wavein = wave(k_in,E_in,raygeomdata(iok).freq*1e9);
  else    
    % determine local B field - copied from wiki psitbx page
    x=pend(1); y=pend(2); z=pend(3);
    pgrid = psitbxgrid('orthogonal','points',{x,y,z}); % define point at which we want the B
    dpsidz = psitbxf2f(psi,pgrid,[0 1 0]); % spatial derivatives if psi
    dpsidr = psitbxf2f(psi,pgrid,[1 0 0]);
    R = sqrt(x.^2+y.^2); % R of the point
    Br = -1./R/(2*pi).*dpsidz.x; % Radial component of B
    Bz =  1./R/(2*pi).*dpsidr.x; % Z component of B
    Bphi = RBphi/R; % Toroidal component of B (positive anticlockwise looking from the top)
    % NB this way of computing Bphi is only valid outside the plasma!
    % now get the xyz components of the B field
    RR = [[x;y],[-y;x]]./norm([x;y]); % transformation matrix to get to xyz from cylindrical coord
    Bxy = RR*[Br;Bphi];
    
    %--------------------------------------------------------
    %---------------- B field at the Plasma exit form the LCFS:(P_end)
    
    Bxyz= [Bxy(1);Bxy(2);Bz];
    % all of the above was to get the local B field
    
    %---------------------------------------------------------
    
    kk = -k_in/norm(k_in); % normalized k vector back INTO the plasma (- sign)
    %kk is the same as (-1).*vk_out
    
    freq_thisray = 82.7*1e9;
    %freq_thisray = raygeomdata(iok).freq*1e9; % frequency of this ray [in Hz]
    [Xwave,Owave] = ox_coupling(kk,Bxyz,freq_thisray);
    % returns wave corresponding to O and X mode coming OUT of the plasma at LCFS?
    % flip k again
    Xwave.k = -Xwave.k; % k vector at P_end is the same as vk_out
    Owave.k = -Owave.k;  
    
    Xwave.Position = pend ; % 100*pend;  % check the units
    Owave.Position = pend ; % 100*pend;  % here we need [m]
  
  %--------------------- COMMENTS ------------------------
  % the O/X wave structure conteins the k & E vectors of the wave leaving the LCFS
  % and directed towards the TCV wall for a reflection
  % -------------------------------------------------------------------------
  
 end 
 %%%%%%%%%%%%%%%%%%%%%%%%%% the part here above can be deleted
 %%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%
 
mywave = wave(k_in,E_in,freq_thisray);
mywave.Position = pw;

mirr = mirror('flat',nw(:,iok)); % mirror with normal corresponding to wall normal
 %mirr = mirror('flat',n_Pw); % mirror with normal corresponding to wall normal

 % ------------------------------------------------------------------
 % differents wall orientations requires adapted normal vector (nw)   
 
if direction == 1;
nw=[0;0;1]; % pw is on the TCV TOP
mirr = mirror('flat',nw); 
end;

if direction == 2;
nw=[sin(th_2);sin(phi_2);cos(th_2)]; % pw is on the TCV TOP-out

  if xw < 0
      nw= [-sin(th_2);-sin(phi_2);cos(th_2)]; %  is ok for X<0, Y<0
  end

mirr = mirror('flat',nw); 
end;

if direction == 3;
nw=[-cos(pi/4);-sin(phi_3);sin(pi/4)];%/norm([-1;0;1]); % pw is on the TCV TOP-in
 if xw<0
     nw=[cos(pi/4);sin(phi_3);sin(pi/4)];%
  end

mirr = mirror('flat',nw); 
end;

if direction == -1
nw= [0;0;-1]; % pw is on the TCV BOTTOM
mirr = mirror('flat',nw); 
end

if direction == -2
nw= [cos(th_2);sin(phi_2);-sin(th_2)]; % pw is on the TCV BOTTOM-out
 if xw < 0
      nw= [-cos(th_2);-sin(phi_2);-sin(th_2)]; % 
  end;
mirr = mirror('flat',nw); 
end

if direction == -3;
nw=[-cos(pi/4);-sin(phi_3);-sin(pi/4)];%/norm([-1;0;-1]); % pw is on the TCV BOTTOM-in
 if xw<0 
     nw=[cos(pi/4);sin(phi_3);-sin(pi/4)];
  end

mirr = mirror('flat',nw); 
end;
 % -------------------------------------------------------------
 if do_polarization
   % Reflect waves off wall  
   % the wave out structure contains the k,E,freq of the wave reflected at the wall
   waveoutX = reflect(Xwave,mirr); %
   waveoutO = reflect(Owave,mirr);
   
   waveout = reflect(mywave,mirr);
   
   % ----------------- COMMENTS ---------------------
   % The waveout structure contains the k reflected at the wall; 
   % -------------------------------------------------
   
 else
    waveoutX = reflect(wavein,mirr);
    coupling_matrix = [];
 end


 
Pw=[xw;yw;zw]; vk_out = K_end./norm(K_end); vk_ref2=waveoutX.k; n_Pw = nw;

  if do_top_plot ==1  % plot the ray interception with TCV wall
     reflect_plot; % in /home/gnesin/
  end;

% ------------------ Prepare OUTPUTS --------------------------------
P_ref =  Pw; %[xw yw zw]';%= waverefX.Position;  % point of reflection at the TCV wall
K_ref = (waveout.k); % % relected wave number
E_ref = waveout.E; 

%save /home/gnesin/HXR/Mission_865_X2X3/shot_25474/reflect_ray.mat P_ref K_ref EX_ref EO_ref OX_ref

disp(' '); disp(' OUTPUTS: K_ref; E_ref; P_ref; ')
   disp(['P_ref = ',num2str(P_ref')])
   disp(['K_ref = ',num2str(K_ref'),'; norm(K_ref) = 1']) % 
   disp(['E_ref = ',num2str(E_ref'),' ' ])
  
