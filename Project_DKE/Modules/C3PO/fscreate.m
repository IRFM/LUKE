function [FSfun,Kn]=fscreate(varargin)
%FSCREATE Create Fourier Series Function.
% [FSfun,Kn] = FSCREATE(...) creates a function handle FSfun containing the
% complex exponential Fourier Series created from its input arguments. The
% optional output Kn is a row vector containing the complex exponential
% Fourier Series coefficients: Kn = [K(-N) ... K(0) ... K(N)]
%
% FSfun = FSCREATE(t,f,N,TYPE) computes the Fourier Series of a signal
% tabulated in the real-valued data vectors t and f.
% t is a monotonically increasing time vector with the signal period being
% T = t(end)-t(1). f(1)=f(end) is required.
% N is the number of harmonics. If N is empty or not given, N = 64.
% TYPE is a string describing the signal type described by the data t and f.
% If TYPE is not given or if TYPE = 'foh' (First Order Hold), the Fourier
% Series coefficients are computed by assuming that the input data is
% piecewise linear between the data points.
% If TYPE = 'zoh' (Zero Order Hold), the Fourier Series coefficients are
% computed by assuming that the input data is piecewise constant between
% the data points.
% The FFT is not used, so no aliasing occurs.
%
% FSfun = FSCREATE(WAVE,T,N,P) returns the Fourier Series of known
% waveforms. WAVE is a character string identifying the desired waveform,
% T is the period, and N is the number of harmonics computed. If N is empty
% or not given, N = 64. P is a vector of optional parameters required for
% some waveforms. See below for waveforms and parameters.
%
% FSfun = FSCREATE(Kn,T) creates a Fourier Series function using the Fourier
% series vector Kn and period T. Kn is a row vector of the complex
% exponential Fourier series coefficients Kn = [K(-N) ... K(0) ... K(N)]
% where K(n) is the n-th term, e.g., K(0) is the DC term, and N is the
% number of harmonics.
%
% FSfun2 = FSCREATE(FSfun,'Op',P) performs the operation specified by the
% string 'Op' on the Fourier Series function handle FSfun, returning a new
% Fourier series function handle. P is a parameter needed for some 'Op'.
%
% Operation   DESCRIPTION
% diff        differentiate the Fourier Series.
% int         integrate the Fourier Series, ignoring the DC or average term
%             and returning a Fourier Series having zero average.
% mirror      time mirror (Fourier Series of f(-t)).
% smooth      apply Blackman window to the Fourier Series (minimize Gibb's)
% trim        trim negligible real and imaginary elements.
% even        extract the even time part (real parts).
% odd         extract the odd time part (imaginary parts).
% halfwave    extract the halfwave part, (odd harmonics).
% nodc        remove DC or average value term (K(0) = 0).
% dc          P = desired DC or average value (K(0) = P).
% add         P = amount to add to DC or average value (K(0)=K(0)+P).
% delay       P = normalized delay to apply to FSfun, P = 1 is one period.
% delay       P = 'odd' or P = 'even' apply delay to achieve given symmetry.
% scale       P = amplitude scale factor to apply to FSfun (P*Kn)
% period      P = desired period to associate with Fourier Series.
% resize      P = number of harmonics desired in result. If P<N terms are
%             deleted; if P>N zeros are padded onto Kn.
% tag         P = tag character string to store with function handle 
%
% FSfun = FSCREATE(FSfunA,'Op',FSfunB) performs the mathematical operation
% specified by the string 'Op' on the underlying time signals in the input
% Fourier Series functions. 'Op' is one of the following '+' (addition),
% '-' (subtraction), '*' (multiplication). The period of FSfunA and FSfunB
% are assumed to be equal.
%
% FSCREATE(...,Tag) where character string Tag is the last input argument,
% stores the string Tag in the function handle for possible retrieval later.
% Tag can be any character string.
%
% FSCREATE('WAVE',T,N,P) Waveforms
%  WAVE       DESCRIPTION
% 'square'    square wave, odd symmetry, zero mean,
% 'saw'       sawtooth, positive slope, odd symmetry, zero mean,
%             P = fractional fall time, 0 < P < 0.5. If not given, P = 0.
% 'rsaw'      reversed sawtooth, same as 'sawtooth' but negative slope
%             P = fractional fall time, 0 < P < 0.5. If not given, P = 0.
% 'triangle'  triangle, even symmetry, zero mean.
% 'pulse'     pulse train, positive valued, even symmetry
%             P(1) = fractional duty cycle or fractional time High,
%             0 < P(1) < 1. If not given, P(1) = 1/2.
%             P(2) = fractional rise and fall time, 0 < P(2) < (1-P(1))/2.
%             If not given, P(2) = 0.
% 'bipolar'   bipolar pulse train, odd symmetry, zero mean,
%             P(1) = fractional duty cycle, 0 < P(1) < 1. If not given,
%             P(1) = 2/3.
%             P(2) = fractional rise and fall time, 0 < P(2) < (1-P(1))/4.
%             If not given, P(2) = 0.
% 'trap'      trapezoidal wave, odd symmetry, zero mean,
%             P = fractional duty cycle, 0 < P < 1. If not given, P = 2/3.
% 'full'      full wave rectified sine wave with the period equal to that
%             of the sine wave being rectified.
% 'half'      half wave rectified sine wave.
% 's2s'       sine-to-square wave, odd symmetry, zero mean,
%             P = normalized morph between a sine wave and a square wave,
%             P = 0 is a sine wave, P = 1 is a square wave,
%             0 < P < 1 is a flat-topped wave with sinusoidal transitions.
%             If not given, P = 1/2.
% 'sine'      sine wave, P = harmonic number. If not given, P = 1.
% 'cosine'    cosine wave,  P = harmonic number. If not given, P = 1.
% 'dc'        constant or dc value.
%
%--------------------------------------------------------------------------
% The created Fourier Series function handle FSfun provides the following:
%
% SYNTAX           DESCRIPTION
%
% FSfun(t)         evaluate function at the points in numerical array t.
%
% FSfun('tag')     return the Tag string stored in FSfun.
% FSfun('coef')    return Fourier Series coefficient row vector, Kn.
% FSfun('period')  return function period, T.
% FSfun('size')    return number of harmonics, N.
% FSfun('avg')     return DC or average value.
% FSfun('msv')     return mean square value (Parseval's Theorem).
% FSfun('max')     return maximum function value.
% FSfun('min')     return minimum function value.
% FSfun('thd')     return total harmonic distortion relative to fundamental.
% FSfun('one')     return one-sided line spectra amplitude vector, i.e.,
%                        [ |K(0)| 2*|K(1)| ... 2*|K(N)| ]
% FSfun('phase')   return one-sided line spectra phase vector in Degrees,
%                  i.e., [ angle(K(0)) angle(K(1)) ... angle(K(N)) ]
% FSfun('sine')    return a vector of the one-sided Fourier Series sine
%                  coefficients, sine portion of trigonometric FS form
% FSfun('cosine')  return a vector of the one-sided Fourier Series cosine
%                  coefficients, cosine portion of trigonometric FS form
% FSfun('all')     return a structure having field names equal to the above
%                  string arguments with contents equal to associated data
%                  as described above, e.g., out.coef is the coefficients.
%
% FSfun('plot')    create a TIME plot of one period of the Fourier Series
% FSfun('spectra') create a STEM plot of the one-sided spectra
%
% FSfun( {'area', [Tmin Tmax]} ) returns the area under the Fourier Series
%                                over the time range Tmin <= t <= Tmax.
% FSfun( {'plot', [Tmin Tmax]} ) creates the TIME plot over the time range
%                                Tmin <= t <= Tmax.
% FSfun( {'spectra', [Nmin Nmax]} ) creates the STEM plot over the positive
%                                   harmonic index range Nmin to Nmax.
%--------------------------------------------------------------------------

% D.C. Hanselman, University of Maine, Orono, ME 04469
% MasteringMatlab@yahoo.com
% Mastering MATLAB 7
% 2006-01-01, revised 2006-01-03, 2006-03-08, 2006-05-18, 2006-07-03

% parse inputs
N=64;
FSData.tag='';
narg=nargin;
if narg<2
   error('At Least Two Input Arguments Required.')
end
if narg>2 && ischar(varargin{end}) && ...
         ~any(strcmpi(varargin{end},{'odd','even'})) && ...
         ~any(strcmpi(varargin{end},{'foh','zoh'})) && ...
         (ischar(varargin{end-1}) && ~isequal(lower(varargin{end-1}),'tag'))
   FSData.tag=varargin{end};	% grab tag provided
   varargin(end)=[];          % strip tag from input
   narg=narg-1;
end
switch class(varargin{1}) % find class of first input argument
case {'double' 'single'}
   if isequal(numel(varargin{1}),numel(varargin{2})) % fscreate(t,f,N,TYPE)
      t=varargin{1}(:);
      f=varargin{2}(:);
      if narg>=3 && isnumeric(varargin{3})
         N=varargin{3};
         if fix(N)~=N || abs(N)~=N || N<1
            error('FSCREATE:InputError','N Must be a Positive Integer.')
         end
      end
      if ischar(varargin{end}) % Type is specified
         Tref={'foh' 'zoh'};
         idx=strncmpi(varargin{end},Tref,1);
         Type=char(Tref(idx));
         if isempty(Type)
            error('FSCREATE:InputError','Unknown TYPE Argument.')
         end
      else
         Type='foh';
      end
      Kn=local_getFS(t,f,N,Type);
      FSData.Kn=Kn;
      FSData.T=t(end)-t(1);
      FSfun=@(t) FourierSeries(FSData,t);
   else                                                    % fscreate(Kn,T)
      Kn=varargin{1}(:).';
      N=(length(Kn)-1)/2;
      if N~=fix(N) || max(abs(conj(Kn(N:-1:1))-Kn(N+2:end)))>sqrt(eps)
         error('FSCREATE:InputError', ...
            ['First Input Argument must be a valid Fourier Series\n', ...
             'vector containing the complex exponential series\n', ...
             'coefficients in increasing harmonic order with\n', ...
             'K(-n)=conj(K(n)) where n is the harmonic number.']);
      end
      T=varargin{2};
      if numel(T)~=1 || T<=0 || ~isreal(T)
         error('Second Input Argument Must be the Positive Scalar Period.')
      end
      FSData.Kn=Kn;
      FSData.T=T;
      FSfun=@(t) FourierSeries(FSData,t);
   end
case 'char'                                        % fscreate('WAVE',T,N,P)
   wave=varargin{1};
   T=varargin{2};
   if narg==4
      P=varargin{4};
   else
      P=[];
   end
   if narg>=3 && ~isempty(varargin{3})
      N=varargin{3};
      if fix(N)~=N || abs(N)~=N || N<1
      	error('FSCREATE:InputError','N Must be a Positive Integer.')
      end
   end
   Kn=local_getwave(wave,T,N,P);
   FSData.Kn=Kn;
   FSData.T=T;
   FSfun=@(t) FourierSeries(FSData,t);   
case 'function_handle'
   if ~ischar(varargin{2})
      error('FSCREATE:InputError','Second Input Argument Must be a String.')
   end
   if narg==3 && ...
      isa(varargin{3},'function_handle')     % fscreate(FSfunA,'Op',FSfunB)

      FSfunA=varargin{1};
      NA=FSfunA('size');
      KnA=FSfunA('coef');
      FSData.T=FSfunA('period');
      
      FSfunB=varargin{3};
      NB=FSfunB('size');
      KnB=FSfunB('coef');
      
      zAB=zeros(1,NA-NB);
      zBA=zeros(1,NB-NA);
      switch lower(varargin{2})
      case '+'
         Kn=[zBA KnA zBA]+[zAB KnB zAB];
      case '-'
         Kn=[zBA KnA zBA]-[zAB KnB zAB];
      case '*'
         Kn=conv(KnA,KnB);
         iDC=(length(Kn)+1)/2;
         N=max(NA,NB);
         Kn=Kn(iDC-N:iDC+N);
      otherwise
         error('FSCREATE:InputError','Unknown Mathematical Operator.')
      end
      FSData.Kn=Kn;
      FSfun=@(t) FourierSeries(FSData,t);
      
   else                    % fscreate(FSfun,'Op') or fscreate(FSfun,'Op',P)
      FSfun=varargin{1};
      Kn=FSfun('coef');
      N=(length(Kn)-1)/2;
      iDC=N+1;
      T=FSfun('period');
      wo=2*pi/T;
      if narg==3
         P=varargin{3};
      end
      switch lower(varargin{2}(1:min(2,length(varargin{2}))))
      case 'ta'                              % tag
         if ischar(P)
            FSData.tag=P;
         else
            error('FSCREATE:InputError','Character String Tag Required.')
         end
      case 'di'                              % differentiate
         Kn=1j*wo*(-N:N).*Kn;
      case 'in'                              % integrate
         nn=-N:N;
         idx=nn~=0;
         iKn=zeros(size(Kn));
         iKn(idx)=Kn(idx)./(nn(idx)*wo*1i);
         iKn(iDC)=0;
         Kn=iKn;
      case 'mi'                              % time mirror
         Kn=Kn(end:-1:1);
      case 'sm'                              % Exact Blackman smoothing
         m=linspace(-pi,pi,length(Kn));
         Kn=Kn.*(7938 + 9240*cos(m) + 1430*cos(2*m))/18608;
      case 'tr'                              % trim negigible elements
         tol=sqrt(eps);
         mKn=abs(Kn);
         rKn=abs(real(Kn));
         iKn=abs(imag(Kn));
         b=mKn<tol*max(mKn);
         Kn(b)=0;              % elements with small magnitude
         b=rKn<tol*max(rKn) | rKn<tol*iKn;
         Kn(b)=1i*imag(Kn(b)); % elements with small real part
         b=iKn<tol*max(iKn) | iKn<tol*rKn;
         Kn(b)=real(Kn(b));    % elements with small imaginary part         
      case 'ev'                              % Even part
         Kn=real(Kn);
      case 'od'                              % Odd part
         Kn=1i*imag(Kn);
      case 'ha'                              % Halfwave part
         idx=rem(N,2)+1:2:length(Kn);
         Kn(idx)=0;
      case 'no'                              % no DC part
         Kn(iDC)=0;
      case 'dc'                              % set DC value
         if narg==2 || numel(varargin{3})>1
            error('FSCREATE:InputError','Scalar Third Argument P Required.')
         end
         Kn(iDC)=real(P);
      case 'ad'                              % set DC value
         if narg==2 || numel(varargin{3})>1
            error('FSCREATE:InputError','Scalar Third Argument P Required.')
         end
         Kn(iDC)=Kn(iDC)+real(P);
      case 'de'                              % delay
         if narg==2
            error('FSCREATE:InputError','Third Argument P Required.')
         end
         if ischar(P)
            a1=angle(Kn(iDC+1))/(2*pi);
            switch lower(P(1))
            case 'o'
               d=a1+1/4;
            case 'e'
               d=a1;
            otherwise
               error('FSCREATE:InputError','Unknown Delay Requested.')
            end
         else
            d=P(1);
         end
         Kn=exp(-2j*pi*(-N:N)*d).*Kn;
      case 'sc'                              % scale amplitude
         if narg==2 || numel(varargin{3})>1
            error('FSCREATE:InputError','Scalar Third Argument P Required.')
         end
         Kn=P*Kn;
      case 'pe'                              % set period
         if narg==2 || numel(varargin{3})>1
            error('FSCREATE:InputError','Scalar Third Argument P Required.')
         end
         T=varargin{3};
      case 're'                              % resize
         if narg==2 || numel(varargin{3})>1
            error('FSCREATE:InputError','Scalar Third Argument P Required.')
         elseif fix(P)~=P || abs(P)~=P || P<1
            error('FSCREATE:InputError','P Must be a Positive Integer.')
         end
         if P>N     % pad with zeros
            zpadd=zeros(1,P-N);
            Kn=[zpadd Kn zpadd];
         elseif P<N % delete excess terms
            Kn=Kn(iDC-P:iDC+P);
         else % P=N no work
            return
         end
      otherwise
         error('FSCREATE:InputError','Unknown Operation Requested.')
      end
      FSData.Kn=Kn;
      FSData.T=T;
      FSfun=@(t) FourierSeries(FSData,t);
   end
otherwise
   error('Unknown First Input Argument.')
end % END of Primary Function
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function Kn=local_getFS(t,f,N,type)      % fscreate(t,f,N,type) Subfunction
T=t(end)-t(1);
if T<=0
   error('Period Must be Positive.')
end
if ~isreal(f)
   error('Input Must be Real-Valued.')
end
if abs(f(1)-f(end))> eps*(1+abs(max(f)-min(f)))
   error('Input Must Describe Exactly One Period of the Function.')
end
t=t/T;
wo=2*pi;
df=diff(f);
dt=diff(t);
if any(dt<0)
   error('Time Points Must be Nondecreasing.')
end
switch type
case 'foh'
   Nl=length(f)-1;
   idx=dt~=0;
   m=zeros(Nl,1);
   m(idx)=df(idx)./dt(idx);
   b=f(1:end-1)-m.*t(1:end-1);
   n=1:N;
   mm=repmat(m,1,N);
   bb=repmat(b,1,N);
   t1=repmat(t(1:end-1),1,N);
   t2=repmat(t(2:end),1,N);
   nn=repmat(n,Nl,1);
   Fp=sum((1j*(mm.*t2+bb)./(nn*wo)+mm./(nn*wo).^2).*exp(-1j*nn*wo.*t2) - ...
          (1j*(mm.*t1+bb)./(nn*wo)+mm./(nn*wo).^2).*exp(-1j*nn*wo.*t1));   
   Kn=[conj(Fp(end:-1:1)) trapz(t,f) Fp];
case 'zoh'
   n=1:N;
   Ni=length(f)-1;
   ff=repmat(f(1:end-1),1,N);
   t1=repmat(t(1:end-1),1,N);
   t2=repmat(t(2:end),1,N);
   nn=repmat(n,Ni,1);

   Fp=sum(1j*ff./(nn*wo).*(exp(-1j*nn*wo.*t2) - exp(-1j*nn*wo.*t1)));
   Kn=[conj(Fp(end:-1:1)) trapz(t,f) Fp];
end
%--------------------------------------------------------------------------
function Kn=local_getwave(wave,T,N,P) % fscreate('WAVE',T,N,P) Subfunction
lenP=length(P);
lkn=2*N+1;
Kn=zeros(1,lkn);

switch lower(wave(1:min(3,length(wave))))
case 'squ'                                                     % squarewave
   Kn(N+2:2:lkn)=-2j*(((1:2:N)*pi).^(-1));
   Kn(1:N)=conj(Kn(lkn:-1:N+2));
case 'tri'                                                       % triangle
   Kn(N+2:2:lkn)=4*(((1:2:N)*pi).^(-2));
   Kn(1:N)=conj(Kn(lkn:-1:N+2));
case 'ful'                                        % fullwave rectified sine
   Kn(N+1)=2/pi;
   n=2:2:N;    
   Kn(N+3:2:lkn)=2./(pi*(1-n.^2));
   Kn(1:N)=conj(Kn(lkn:-1:N+2));
case 'hal'                                        % halfwave rectified sine
   Kn(N+1)=1/pi;
   Kn(N+2)=-j/4;
   n=2:2:N;
   Kn(N+3:2:lkn)=1./(pi*(1-n.^2));
   Kn(1:N)=conj(Kn(lkn:-1:N+2));
case 'dc'                                                  % dc or constant
   Kn(N+1)=1;
case 'sin'                                                      % sine wave
   if lenP==1
      n=P;
   else
      n=1;
   end
   if fix(n)~=n || n<1 || n>N
      error('Harmonic Number Must be an Integer Between 1 and N.')
   end
   Kn=zeros(1,N);
   Kn(n)=-1i/2;
   Kn=[conj(Kn(end:-1:1)) 0 Kn];
case 'cos'                                                    % cosine wave
   if lenP==1
      n=P;
   else
      n=1;
   end
   if fix(n)~=n || n<1 || n>N
      error('Harmonic Number Must be an Integer Between 1 and N.')
   end
   Kn=zeros(1,N);
   Kn(n)=1/2;
   Kn=[Kn(end:-1:1) 0 Kn];
case 'saw'                                                       % sawtooth
   if lenP==0                             % ideal sawtooth
      Kn(N+2:lkn)=2j*(((1:N)*2*pi).^(-1));
      Kn(1:N)=conj(Kn(lkn:-1:N+2));
   else                                   % finite fall time sawtooth
      a=min(.4999,P(1));
      if a~=P(1)
         warning('FSCREATE:InputError',...
                 'Requested Fall Time Must be Less Than 1/2.')
      end
      t=[0 a .5 1-a 1];
      f=[0 -1 0  1  0];
      [dum,Kn]=fscreate(t,f,N);
   end
case 'rsa'                                               % reverse sawtooth 
   [dum,Kn]=fscreate('saw',T,N,P);
   Kn=Kn(end:-1:1);
case 'tra'                                                      % trapezoid
   if lenP==0
      p=2/3;
   else
      p=min(abs(P(1)),.999);
   end
   if lenP>0 && p~=P(1)
      warning('FSCREATE:InputError',...
              'Requested Duty Cycle Must Be Less Than 1.')
   end
   a=(1-p)/2;
   b=1-a;
   npi=(1:2:N)*pi;
   jnpia=1j*a*npi;
   jnpib=1j*b*npi;
   Kn(N+2:2:lkn)=(( (1+1j*a*npi).*exp(-jnpia)...
      - (1+jnpib).*exp(jnpia)...
      + 1j*npi).*(npi.^(-2))./a...
      + ( (1/a-1)*exp(jnpia)...
      - exp(-jnpia) -1/a)*1j./npi);
   Kn(1:N)=conj(Kn(lkn:-1:N+2));
case 'pul'                                                     % Pulsetrain
   if lenP==0
      p=1/2;
   else
      p=min(abs(P(1)),.999);
   end
   if lenP>0 && p~=P(1)
      warning('FSCREATE:InputError',...
              'Requested Duty Cycle Must Be Less Than 1.')
   end
   if lenP<2 || P(2)==0                 % ideal zero rise time pulse
      Kn(N+1)=p;
      arg=pi*p*(1:N);
      Kn(N+2:lkn)=p*sin(arg)./(arg+eps);
      Kn(1:N)=conj(Kn(lkn:-1:N+2));
   else                                 % finite rise time pulse
      r=min((1-p)/2-10*eps,abs(P(2)));
      if r~=P(2)
         warning('FSCREATE:InputError',...
                 'Requested Rise Time Too Long.')
      end
      a=p/2;
      t=[0 a a+r 0.5 1-a-r 1-a 1];
      f=[1 1  0   0    0    1  1];
      [dum,Kn]=fscreate(t,f,N);
   end      
case 'bip'                                             % Bipolar Pulsetrain
   if lenP==0
      p=2/3;
   else
      p=min(abs(P(1)),.999);
   end
   if lenP>0 && p~=P(1)
      warning('FSCREATE:InputError',...
              'Requested Duty Cycle Must Be Less Than 1.')
   end
   if lenP<2 || P(2)==0                 % ideal zero rise time pulsetrain
      a=(1-p)/2; b=1-a;
      jnpi=(1:2:N)*pi*1j;
      Kn(N+2:2:lkn)=(exp(-jnpi*b)-exp(-jnpi*a))./(-jnpi);
      Kn(1:N)=conj(Kn(lkn:-1:N+2));
   else                                 % finite rise time pulse
      r=min((1-p)/4-10*eps,abs(P(2)));
      if r~=P(2)
         warning('FSCREATE:InputError',...
                 'Requested Rise Time Too Long.')
      end
      a=p/4;
      b=.25;
      c=.75;
      t=[0 b-a-r b-a b+a b+a+r 0.5 c-a-r c-a c+a c+a+r 1];
      f=[0   0    1   1    0    0    0    -1  -1   0   0];
      [dum,Kn]=fscreate(t,f,N);
   end      
case 's2s'                                           % sine to square morph
   if lenP==0
      p=1/2;
   else
      p=P(1);
   end
   if p<0 || p>1
      error('FSCREATE:InputError',...
            'Morphing Parameter Must be Between 0 and 1.')
   end
   if p==0                            % sine wave
      Kn=zeros(1,N);
      Kn(1)=-1i/2;
      Kn=[conj(Kn(end:-1:1)) 0 Kn];
   elseif p==1                        % square wave
      Kn(N+2:2:lkn)=-2j*(((1:2:N)*pi).^(-1));
      Kn(1:N)=conj(Kn(lkn:-1:N+2));
   else                               % morph between sine and square
      kp=zeros(1,N);
      b=(1-p)/2;
      m=1:2:N;
      bm=b*m;
		kp(m)=(2*b/pi)*( 2i*bm.*exp(-1i*bm*pi)-1 )./(4*bm.^2-1)...
           - 2i*cos(bm*pi)./(m*pi)...
           + (2*b/pi)*( 1+ 2i*bm.*exp(1i*bm*pi))./(4*bm.^2-1);
		Kn=[conj(kp(end:-1:1)) 0 kp];
   end     
otherwise
      error('FSCREATE:InputError','Unknown Waveform Input.')
end
%--------------------------------------------------------------------------
% Fourier Series Function
%--------------------------------------------------------------------------
function y=FourierSeries(FSData,t)
% Fourier Series Evaluation and Manipulation using function handles
%
% This function gets called when FSfun(...) is issued where FSfun is a
% function handle returned by FSCREATE.

Kn=FSData.Kn;           % FS coefficient vector
wo=2*pi/FSData.T;       % fundamental frequency
N=(length(Kn)-1)/2;     % highest harmonic
iDC=N+1;                % index of dc component

if isnumeric(t) && isreal(t)                      % Evaluate Fourier Series
   nwo=wo*(1:N);		   % positive harmonic indices
   ko=real(Kn(iDC));	   % average value
   tsize=size(t);
   Knp=Kn(iDC+1:end).';	   % positive frequency coefs
   y=ko+2*(real(exp(1j*t(:)*nwo)*Knp))';
   y=reshape(y,tsize);
elseif iscell(t) && ischar(t{1})            % FSfun( {'command', [range]} )
   if length(t)~=2 || ~isnumeric(t{2}) || numel(t{2})~=2 || ~isreal(t{2})
      msg=['Two Element Cell Required. '...
           'Second Cell Must be a Two Element Numeric Vector.'];
      error(msg)
   end
   switch lower(t{1}(1:min(3,length(t{1}))))
   case 'are'
      n=1:N;
      nwo=n*wo;
      Ikn=Kn(iDC+n)./(1i*nwo); % Kn/(jn*wo) is integral
      tmm=t{2};
      y=diff(2*(real(exp(1j*tmm(:)*nwo)*Ikn.')))+Kn(iDC)*diff(tmm);
   case 'ste'

      if any(fix(t{2})~=t{2}) || any(t{2}<0)
         error('Harmonic Indices Must be Nonnegative Integers.')
      end
      xdata=(min(t{2}):min(max(t{2}),N))+1;
      subplot(2,1,1)
      ydata=abs([Kn(iDC) 2*Kn(iDC+1:end)]);
      ydata=ydata(xdata);
      stem(xdata,ydata)
      ylabel('Amplitude')
      xlabel('Harmonic Index')
      title('Fourier Series Line Spectra Plot')
      ydata=angle(Kn(iDC:end))*180/pi;
      ydata=ydata(xdata);
      subplot(2,1,2)
      stem(xdata,ydata)
      ylabel('Phase')
      xlabel('Harmonic Index')         
   case 'plo'
      tt=linspace(t{2}(1),t{2}(2),min(max(5*N,100),500));
      nwo=wo*(1:N);
      ko=real(Kn(iDC));
      Knp=Kn(iDC+1:end).';
      ydata=ko+2*(real(exp(1j*tt(:)*nwo)*Knp))';
      plot(tt,ydata)
      title('Fourier Series Plot.')  
   otherwise
      error('Uknown Input Argument.')
   end
         
elseif ~ischar(t)
   error('Unknown Input Argument.')
else                                                      % FSfun('string') 
   switch lower(t(1:min(3,length(t))))
   case 'tag'
      y=FSData.tag;
   case {'coe' 'kn'}                                   % coefficient vector       
      y=Kn;         
   case {'per' 't'}                                                % period
      y=FSData.T;
   case 'siz'                                    % size or highest harmonic
      y=N;
   case {'dc' 'ave' 'avg'}                            % dc or average value
      y=Kn(iDC);
   case 'msv'                                           % mean square value
      y=real(Kn*Kn');
   case 'max'                                       % maximum or peak value
      nwo=wo*(1:N);
      Knp=Kn(iDC+1:end).';
      t=linspace(-0.1,1.2,11*N)*FSData.T;
      [dum,idx]=max(real(Kn(iDC))+2*(real(exp(1j*t(:)*nwo)*Knp)));
      t=linspace(t(idx-1),t(idx+1),101);
      y=max(real(Kn(iDC))+2*(real(exp(1j*t(:)*nwo)*Knp)));    
   case 'min'                                              % minimum  value
      nwo=wo*(1:N);
      Knp=Kn(iDC+1:end).';
      t=linspace(-0.1,1.2,11*N)*FSData.T;
      [dum,idx]=min(real(Kn(iDC))+2*(real(exp(1j*t(:)*nwo)*Knp)));
      t=linspace(t(idx-1),t(idx+1),101);
      y=min(real(Kn(iDC))+2*(real(exp(1j*t(:)*nwo)*Knp)));
   case 'thd'                                   % total harmonic distortion
      idx=iDC+[-1 1];
      fn=Kn(idx);
      Kn(idx)=[];
      y=sqrt(real(Kn*Kn')/real(fn*fn'));
   case 'one'                            % one-sided line amplitude spectra
      y=abs([Kn(iDC) 2*Kn(iDC+1:end)]);
   case 'pha'                                % one-sided line phase spectra
      y=angle(Kn(iDC:end))*180/pi;
   case 'sin'                                      % trig sine coefficients
      y=-2*imag(Kn(iDC+1:end));
   case 'cos'                                    % trig cosine coefficients
      y=2*real(Kn(iDC+1:end));
   case 'all'                              % return all data in a structure
      y.tag=FSData.tag;
      y.coef=Kn;
      y.period=FSData.T;
      y.size=N;
      y.avg=Kn(iDC);
      y.msv=real(Kn*Kn');
      
      nwo=wo*(1:N);
      Knp=Kn(iDC+1:end).';
      t1=linspace(-0.1,1.2,11*N)*FSData.T;
      [dum,idx]=max(real(Kn(iDC))+2*(real(exp(1j*t1(:)*nwo)*Knp)));
      t2=linspace(t1(idx-1),t1(idx+1),101);
      y.max=max(real(Kn(iDC))+2*(real(exp(1j*t2(:)*nwo)*Knp)));
      
      [dum,idx]=min(real(Kn(iDC))+2*(real(exp(1j*t1(:)*nwo)*Knp)));
      t2=linspace(t1(idx-1),t1(idx+1),101);
      y.min=min(real(Kn(iDC))+2*(real(exp(1j*t2(:)*nwo)*Knp)));

      idx=iDC+[-1 1];
      fn=Kn(idx);
      Kn(idx)=[];
      y.thd=sqrt(real(Kn*Kn')/real(fn*fn'));
      
      y.one=abs([Kn(iDC) 2*Kn(iDC+1:end)]);
      y.phase=angle(Kn(iDC:end))*180/pi;
      y.sine=-2*imag(Kn(iDC+1:end));
      y.cosine=2*real(Kn(iDC+1:end));
      
   case {'spe' 'ste'}                                    % create stem plot
      xdata=0:N;
      subplot(2,1,1)
      ydata=abs([Kn(iDC) 2*Kn(iDC+1:end)]);
      stem(xdata,ydata)
      ylabel('Amplitude')
      xlabel('Harmonic Index')
      title('Fourier Series Line Spectra Plot')
      ydata=angle(Kn(iDC:end))*180/pi;
      subplot(2,1,2)
      stem(xdata,ydata)
      ylabel('Phase')
      xlabel('Harmonic Index')
   case 'plo'                                            % create time plot
      t=linspace(0,FSData.T,min(max(5*N,100),500));
      nwo=wo*(1:N);
      ko=real(Kn(iDC));
      Knp=Kn(iDC+1:end).';
      ydata=ko+2*(real(exp(1j*t(:)*nwo)*Knp))';
      plot(t,ydata)
      title('Fourier Series Plot.')
   otherwise
      error('Uknown Input Argument.')
   end
end
%--------------------------------------------------------------------------