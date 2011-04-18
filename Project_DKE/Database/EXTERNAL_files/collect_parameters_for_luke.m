function dummy = collect_parameters_for_luke (shot,t1,t2,laun,filename,teflag)

%
%	function dummy = collect_parameters_for_luke (shot,t1,t2,laun,filename,teflag)
%
%	collect all TCV data needed for Luke run (with the exception of the
%	  equilibrium, which must be supplied separately in EQDSK format:
%	  use make_eqdsk(shot,times,outdir,machine,liuqetype) for this)
%	input:
%		shot = shot number (vector)
%		t1, t2 = start and end times (vectors): data will be averaged
%			   from t1 to t2
%		laun = launcher numbers of interest (vector)
%		filename = filename for output data storage
%		teflag = flag, if 0 (default) Thomson data are used for Te,
%			 if nonzero Thomson data are renormalized to Te(0)
%			 supplied by XTe
%	rho coordinate is rho_psi


%	S. Coda, 30/04/07
%		 12/03/09

if nargin<6|isempty(teflag),teflag=0;end
if nargin<5|isempty(filename),filename='luke_input_parameters.mat';end

laun=laun(:)';

t0=0.5*(t1+t2);
for i=1:length(shot),
  mdsopen(shot(i));
  [tvloop,vl]=tcvget('VLOOP',[t1(i):.002:t2(i)]);
  vloop(i)=-mean(vl);
  [tnel,n]=tcvget('NEL',[t1(i):.002:t2(i)]);
  nel(i)=mean(n);
  if shot(i)<16000,
    teraw=mdsdata('\results::th_prof_te');
    dteraw=mdsdata('\results::th_prof_te:error_bar');
    neraw=mdsdata('\results::th_prof_ne');
    dneraw=mdsdata('\results::th_prof_ne:error_bar');
    rho(:,i)=mdsdata('dim_of(\results::th_prof_te,1)');
    tth=mdsdata('dim_of(\results::th_prof_te,0)');
  else
    teraw=mdsdata('\results::proffit.avg_time:teft')';
    dteraw=mdsdata('\results::proffit.avg_time:teft_std')';
    neraw=mdsdata('\results::proffit.avg_time:neft_abs')';
    dneraw=mdsdata('\results::proffit.avg_time:neft_std')'.* ...
      repmat(mdsdata('\results::proffit.avg_time:neft_firat'),1,size(neraw,2));
    rho(:,i)=mdsdata('dim_of(\results::proffit.avg_time:teft)');
    tth=mdsdata('dim_of(\results::proffit.avg_time:teft,1)');
  end
  teind1=min(find(tth>=t1(i)&tth<=t2(i)));
  teind2=max(find(tth>=t1(i)&tth<=t2(i)));
  if ~isempty(teind1),
    te(:,i)=mean(teraw(teind1:teind2,:),1)';
    dte(:,i)=max(std(dteraw(teind1:teind2,:),0,1), ...
	         sqrt(mean(dteraw(teind1:teind2,:).^2,1)/(teind2-teind1)))';
    ne(:,i)=mean(neraw(teind1:teind2,:),1)';
    dne(:,i)=max(std(dneraw(teind1:teind2,:),0,1), ...
	         sqrt(mean(dneraw(teind1:teind2,:).^2,1)/(teind2-teind1)))';
  else
    te(:,i)=NaN;
    dte(:,i)=NaN;
    ne(:,i)=NaN;
    dne(:,i)=NaN;
  end
  if teflag,
    te0(i)=mdsdata('\results::te_x_a[[$1],13]',t0(i));
    te(:,i)=te(:,i)/max(te(:,i))*te0(i);
    dte(:,i)=dte(:,i)/max(te(:,i))*te0(i);
  end
  tiraw=mdsdata('\results::cxrs:ti');
  if ~isempty(tiraw),
   rhotiraw=mdsdata('\results::cxrs:rho');
   ttiraw=mdsdata('dim_of(\results::cxrs:ti,1)');
   tiind1=min(find(ttiraw>=t1(i)&ttiraw<=t2(i)));
   tiind2=max(find(ttiraw>=t1(i)&ttiraw<=t2(i)));
   if ~isempty(tiind1),
    tiraw=mean(tiraw(:,tiind1:tiind2),2);
    rhotiraw=mean(rhotiraw(:,tiind1:tiind2),2);
    tiraw=tiraw(~isnan(tiraw));
    rhotiraw=rhotiraw(~isnan(tiraw));
    ti(:,i)=interp1(rhotiraw,tiraw,rho(:,i),'spline');
   else
    ti(:,i)=NaN;
   end
  else
   ti(:,i)=NaN;
  end
  for j=laun,
    clear ang
    js=int2str(j);
    if j<7,
      ang.theta=mean(mdsdata(['\ecrh::launchers:theta_l:x2_',js, ...
		   '[[$1]:[$2]:*]'],t1(i),t2(i)))/180*pi;
      ang.phi=mean(mdsdata(['\ecrh::launchers:phi_l:x2_',js, ...
		   '[[$1]:[$2]:*]'],t1(i),t2(i)))/180*pi;
      ang.theta_eff=mean(mdsdata( ...
	['-atand(tand(\ecrh::launchers:theta_l:x2_',js, ...
	'[[$1]:[$2]:*])*cosd(\ecrh::launchers:phi_l:x2_',js, ...
	'[[$1]:[$2]:*]))'],t1(i),t2(i)))/180*pi;
      dummy=mdsdata(['_y01=tand(\ecrh::launchers:theta_l:x2_',js, ...
		    '[[$1]:[$2]:*])'],t1(i),t2(i));
      dummy=mdsdata(['_y02=\ecrh::launchers:phi_l:x2_',js, ...
		'[[$1]:[$2]:*]'],t1(i),t2(i));
      ang.phi_eff=mean(mdsdata(['atand(_y01*sind(_y02)/', ...
		 'sqrt(1+_y01^2*(cosd(_y02))^2))']))/180*pi;
      ang.freq=82.7e9;
      pow=mdsdata('_p=\results::toray.input:p_gyro[*,$1]',j)*1000;
      tpow=mdsdata('dim_of(_p)');
      i1=min(find(tpow>=t1(i)));
      if ~isempty(i1),
        i2=max(find(tpow<=t2(i)));
        ang.P0=mean(pow(i1:i2));
      else
	ang.P0=NaN;
      end
      ang.P1_R=1.3072;
      ang.P1_theta=52.013/180*pi;
      ang.P2_R=1.1906;
      ang.P2_d=0.01;
      if j==1|j==4,
        ang.P1_Z=-0.05865;
        ang.P2_Z=0.0645;
        ang.P3_Z=-0.0025;
      else
        ang.P1_Z=0.39885;
        ang.P2_Z=0.522;
        ang.P3_Z=0.455;
      end
      ang.P3_tor=0.;
    else
      thetaraw=mean(mdsdata(['\ecrh::launchers:theta_l:x3', ...
		   '[[$1]:[$2]:*]'],t1(i),t2(i)))/180*pi;
      phiraw=mdsdata(['\ecrh::launchers:phi_l:x3_',js])/180*pi;
%  convert from X3 theta and phi to X2 theta and phi:
%	X3: tan(theta_l)=-y/x, tan(phi_l)=z/sqrt(x^2+y^2)
%	   x radially inward, y upward, z toroidal clockwise from top
%	X2: tan(theta_l)=sqrt(y^2+z^2)/x, tan(phi_l)=z/y
%	x radially inward, y upward, z toroidal counterclockwise from top
      ang.theta=atan2(sqrt(sin(thetaraw)^2+tan(phiraw)^2),cos(thetaraw));
      ang.phi=atan2(tan(phiraw),sin(thetaraw));
      ang.theta_eff=-thetaraw;
      dummy=mdsdata(['_y01=cosd(\ecrh::launchers:theta_l:x3', ...
		     '[[$1]:[$2]:*])'],t1(i),t2(i));
      dummy=mdsdata(['_y02=tand(\ecrh::launchers:phi_l:x3_',js,')']);
      ang.phi_eff=mean(mdsdata('atan2(_y02,abs(_y01))'));
      ang.freq=118.e9;
      ang.P0=0.47e6;
      ang.P1_R=mean(mdsdata('\ecrh::launchers:R:x3[[$1]:[$2]:*]',t1(i),t2(i)));
      ang.P1_Z=.9885;
      ang.P1_theta=0;
      ang.P2_R=ang.P1_R;
      ang.P2_Z=ang.P1_Z;
      ang.P2_d=0;
      ang.P3_Z=ang.P1_Z;
      ang.P3_tor=(ang.P1_R+0.125)*tan(phiraw);
    end
    ang.id=int2str(shot(i));
    eval(['angles_',int2str(j),'(1,i)=ang;']);
  end
  z=mdsdata('\results::zx[[$1]:[$2]:0.05]',t1(i),t2(i));
  if ~isempty(z)&~iscell(z)&~ischar(z),
    zeff(i)=mean(z(:,1));
  else
    zeff(i)=NaN;
  end
  zaxis(:,i)=mean(mdsdata('\results::z_axis[[$1]:[$2]:0.05]',t1(i),t2(i)));
  ip0=mdsdata('\ipol[[0.0,0.01],"OH_001"]');
  if ip0(2)>=ip0(1),
    ipsign(i)=-1;
  else
    ipsign(i)=1;
  end
  btsign(i)=sign(mdsdata('\magnetics::iphi[$]',(t1(i)+t2(i))/2));
  mdsclose
end
clear ang dummy
vloop=vloop';
nel=nel';
te=te';
dte=dte';
ne=ne';
dne=dne';
rho=rho';
ti=ti';
zeff=zeff';
zaxis=zaxis';
ipsign=ipsign';
btsign=btsign';

eval(['save ',filename]);
disp(' ');
disp(' ');
disp(['Data saved to ',filename]);
