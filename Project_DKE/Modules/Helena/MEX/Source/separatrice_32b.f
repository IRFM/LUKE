      subroutine mexFunction(nlhs,plhs,nrhs,prhs)
C Compilation : !mex -f mexopts_f77.sh separatrice.f (dans matlab7)
C--------------------------------------------------------------

      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
C DECLARATION DES VARIABLES
c pointeurs mex   
      integer plhs(*), prhs(*),mxGetPr, mxCreateFull
      integer nlhs, nrhs, mxgetN, mxgetM
c 
c Extrait du main de helios.f concernant le trace de la derniere surface
c magnetique (il s'agit d'une implementation triviale des formules fournies)
c
c pointeurs et tailles      
      integer geom_pr,mode_pr,x_pr,y_pr
      integer*4 ifail 
      real*8 mode,geom(8),x(125*4),y(125*4)
      data pi/3.141592653589793/
      data two/2./,one/1./,rho/1./ 
c      data rkappax1/1.687/,ptdeltax1/0.466/,psip1dg/0./,psim1dg/0./,
c     & rkappax2/2.001/,ptdeltax2/0.568/,psip2dg/22.46/,psim2dg/67.92/
**********************************************************************

C---------------------------------------------------------------------
C GESTION DES ENTREES     
C entree
      write(*,*) 'debut separatrice'
      geom_pr = mxGetPr(prhs(1))
      call mxCopyPtrtoReal8(geom_pr,geom,8)

      rkappax1  = geom(1)
      ptdeltax1 = geom(2)
      psip1dg   = geom(3)
      psim1dg   = geom(4)
      rkappax2  = geom(5)
      ptdeltax2 = geom(6)
      psip2dg   = geom(7)
      psim2dg   = geom(8)
C mode de calcul
      mode_pr = mxGetPr(prhs(2))
      call mxCopyPtrtoReal8(mode_pr,mode,1)


c Initializing geometrical parameters
      psimoins1=psim1dg*pi/180.
      psiplus1=psip1dg*pi/180.
      psimoins2=psim2dg*pi/180.
      psiplus2=psip2dg*pi/180.
      tmoins1=tan(psimoins1)*(1.-ptdeltax1)/rkappax1
      tmoins2=tan(psimoins2)*(1.-ptdeltax2)/rkappax2
c      write(*,*) 'tmoins1 = ',tmoins1,' tmoins2 =',tmoins2
      tplus1=tan(psiplus1)*(1.+ptdeltax1)/rkappax1
      tplus2=tan(psiplus2)*(1.+ptdeltax2)/rkappax2
c      write(*,*) 'tplus1 = ',tplus1,' tplus2 =',tplus2
c      
c Activer manuellement la bonne partie du programme suivant le cas (voir texte
c fourni) en remplacant if(one.gt.two) par if(two.gt.one)
c Un algorithme automatique peut aussi �re �rit
c
c plot of the plasma last closed magnetic surface
c
c case where the upper part is made of 2 portions of ellipse and the
c bottom part is made of 2 portions of ellipse
c
      if(mode .eq. 1)then
        tetaxp2   = 0.5*pi-asin(tplus2/(1.-tplus2))
        tetap2in  = 0.
        tetap2fi  = tetaxp2
        nbtetap2  = 125
        tetap2st  = (tetap2fi-tetap2in)/(nbtetap2-1)
        tetaxm2   = 0.5*pi+asin(tmoins2/(1.-tmoins2))
        tetam2in  = tetaxm2
        tetam2fi  = pi
        nbtetam2  = 125
        tetam2st  = (tetam2fi-tetam2in)/(nbtetam2-1)
        tetaxm1   = 0.5*pi+asin(tmoins1/(1.-tmoins1))
        tetam1in  = pi
        tetam1fi  = tetaxm1
        nbtetam1  = 125
        tetam1st  = (tetam1fi-tetam1in)/(nbtetam1-1)
        tetaxp1   = 0.5*pi-asin(tplus1/(1.-tplus1))
        tetap1in  = -tetaxp1
        tetap1fi  = 0.
        nbtetap1  = 125
        tetap1st  = (tetap1fi-tetap1in)/(nbtetap1-1)
        ii        = 1
c bottom plus
        do noteta=1,nbtetap2
          teta     = tetap2in+(noteta-1)*tetap2st
          alpha0p2 = -(ptdeltax2+(1.-ptdeltax2)*tplus2)/(1.-2.*tplus2)
          alphap2  = (1.+ptdeltax2)*(1.-tplus2)/(1.-2.*tplus2)
          betap2   = rkappax2*(1.-tplus2)/(1.-2.*tplus2)**0.5
          x(ii)    = rho*(alpha0p2+alphap2*cos(teta))
          y(ii)    = -rho*(betap2*sin(teta))
          ii       = ii+1
        enddo ! noteta
c bottom minus
        do noteta=1,nbtetam2
          teta     = tetam2in+(noteta-1)*tetam2st
          alpha0m2 = -(ptdeltax2-(1.+ptdeltax2)*tmoins2)/(1.-2.*tmoins2)
          alpham2  = (1.-ptdeltax2)*(1.-tmoins2)/(1.-2.*tmoins2)
          betam2   = rkappax2*(1.-tmoins2)/(1.-2.*tmoins2)**0.5
          x(ii)    = rho*(alpha0m2+alpham2*cos(teta))
          y(ii)    = -rho*(betam2*sin(teta))
c          if (ii .eq. 150) then
c            write(*,*) 'y(ii)=',y(ii),betam2,teta,sin(teta)
c          endif

          ii       = ii+1
        enddo ! noteta
c upper minus
        do noteta=1,nbtetam1
          teta     = tetam1in+(noteta-1)*tetam1st
          alpha0m1 = -(ptdeltax1-(1.+ptdeltax1)*tmoins1)/(1.-2.*tmoins1)
          alpham1  = (1.-ptdeltax1)*(1.-tmoins1)/(1.-2.*tmoins1)
          betam1   = rkappax1*(1.-tmoins1)/(1.-2.*tmoins1)**0.5
          x(ii)    = rho*(alpha0m1+alpham1*cos(teta))
          y(ii)    = rho*(betam1*sin(teta))
          ii       = ii+1
c      write(7,*)x,y
        enddo ! noteta
c upper plus
        do noteta=1,nbtetap1
          teta     = tetap1in+(noteta-1)*tetap1st
          alpha0p1 = -(ptdeltax1+(1.-ptdeltax1)*tplus1)/(1.-2.*tplus1)
          alphap1  = (1.+ptdeltax1)*(1.-tplus1)/(1.-2.*tplus1)
          betap1   = rkappax1*(1.-tplus1)/(1.-2.*tplus1)**0.5
          x(ii)    = rho*(alpha0p1+alphap1*cos(teta))
          y(ii)    = -rho*(betap1*sin(teta))
          ii       = ii+1
c      write(7,*)x,y
        enddo ! noteta
      endif ! true/false

c
c case where the upper part is made of 2 portions of ellipse and the
c bottom part is made of 1 portion of hyperbola (inside) and
c 1 portion of ellipse (outside)
      if(mode .eq. 2)then
        tetaxp1=0.5*pi-asin(tplus1/(1.-tplus1))
        tetap1in=0.
        tetap1fi=tetaxp1
        nbtetap1=125
        tetap1st=(tetap1fi-tetap1in)/(nbtetap1-1)
        tetaxm1=0.5*pi+asin(tmoins1/(1.-tmoins1))
        tetam1in=tetaxm1
        tetam1fi=pi
        nbtetam1=125
        tetam1st=(tetam1fi-tetam1in)/(nbtetam1-1)
        phixm2=dasinh((2.*tmoins2-1.)**0.5/(1.-tmoins2))
c        write(*,*) 'phixm2=',phixm2
        phim2in=0.
        phim2fi=-phixm2
        nbphim2=125
        phim2st=(phim2fi-phim2in)/(nbphim2-1)
        tetaxp2=0.5*pi-asin(tplus2/(1.-tplus2))
        tetap2in=-tetaxp2
        tetap2fi=0.
        nbtetap2=125
        tetap2st=(tetap2fi-tetap2in)/(nbtetap2-1)
c upper plus
        ii = 1
        do noteta=1,nbtetap1
          teta=tetap1in+(noteta-1)*tetap1st
          alpha0p1=-(ptdeltax1+(1.-ptdeltax1)*tplus1)/(1.-2.*tplus1)
          alphap1=(1.+ptdeltax1)*(1.-tplus1)/(1.-2.*tplus1)
          betap1=rkappax1*(1.-tplus1)/(1.-2.*tplus1)**0.5
          x(ii) =rho*(alpha0p1+alphap1*cos(teta))
          y(ii) =rho*(betap1*sin(teta))
          ii = ii+1
        enddo ! noteta
c upper minus
        do noteta=1,nbtetam1
          teta=tetam1in+(noteta-1)*tetam1st
          alpha0m1=-(ptdeltax1-(1.+ptdeltax1)*tmoins1)/(1.-2.*tmoins1)
          alpham1=(1.-ptdeltax1)*(1.-tmoins1)/(1.-2.*tmoins1)
          betam1=rkappax1*(1.-tmoins1)/(1.-2.*tmoins1)**0.5
          x(ii)=rho*(alpha0m1+alpham1*cos(teta))
          y(ii)=rho*(betam1*sin(teta))
          ii = ii+1
        enddo ! noteta
c bottom minus
        do nophi=1,nbphim2
          phi=phim2in+(nophi-1)*phim2st
          alpha0m2=-((1.+ptdeltax2)*tmoins2-ptdeltax2)/(2.*tmoins2-1.)
          alpham2=(1.-ptdeltax2)*(1.-tmoins2)/(2.*tmoins2-1.)
          betam2=rkappax2*(1.-tmoins2)/(2.*tmoins2-1.)**0.5
          x(ii)=rho*(alpha0m2+alpham2*cosh(phi))
          y(ii)=rho*(betam2*sinh(phi))
          ii=ii+1
        enddo ! nophi
c bottom plus
        do noteta=1,nbtetap2
          teta=tetap2in+(noteta-1)*tetap2st
          alpha0p2=-(ptdeltax2+(1.-ptdeltax2)*tplus2)/(1.-2.*tplus2)
          alphap2=(1.+ptdeltax2)*(1.-tplus2)/(1.-2.*tplus2)
          betap2=rkappax2*(1.-tplus2)/(1.-2.*tplus2)**0.5
          x(ii)=rho*(alpha0p2+alphap2*cos(teta))
          y(ii)=rho*(betap2*sin(teta))
          ii = ii+1
        enddo ! noteta
      endif ! true/false
c
c case where the upper part is made of 1 portion of hyperbola and
c 1 portion of ellipse
c and the bottom part of 2 portions of ellipse
c
      if(mode .eq. 3)then
         tetaxp2=0.5*pi-asin(tplus2/(1.-tplus2))
         tetap2in=0.
         tetap2fi=tetaxp2
         nbtetap2=125
         tetap2st=(tetap2fi-tetap2in)/(nbtetap2-1)
         tetaxm2=0.5*pi+asin(tmoins2/(1.-tmoins2))
         tetam2in=tetaxm2
         tetam2fi=pi
         nbtetam2=125
         tetam2st=(tetam2fi-tetam2in)/(nbtetam2-1) 
         phixm1=dasinh((2.*tmoins1-1.)**0.5/(1.-tmoins1))
c         write(*,*) 'phixm1=',phixm1
         phim1in=0.
         phim1fi=-phixm1
         nbphim1=125
         phim1st=(phim1fi-phim1in)/(nbphim1-1)
         tetaxp1=0.5*pi-asin(tplus1/(1.-tplus1))
         tetap1in=-tetaxp1
         tetap1fi=0.
         nbtetap1=125
         tetap1st=(tetap1fi-tetap1in)/(nbtetap1-1)
         ii = 1
c bottom plus
         do noteta=1,nbtetap2
           teta=tetap2in+(noteta-1)*tetap2st
           alpha0p2=-(ptdeltax2+(1.-ptdeltax2)*tplus2)/(1.-2.*tplus2)
           alphap2=(1.+ptdeltax2)*(1.-tplus2)/(1.-2.*tplus2)
           betap2=rkappax2*(1.-tplus2)/(1.-2.*tplus2)**0.5
           x(ii)=rho*(alpha0p2+alphap2*cos(teta))
           y(ii)=-rho*(betap2*sin(teta))
           ii = ii+1
         enddo ! noteta
c bottom minus
         do noteta=1,nbtetam2
           teta=tetam2in+(noteta-1)*tetam2st
           alpha0m2=-(ptdeltax2-(1.+ptdeltax2)*tmoins2)/(1.-2.*tmoins2)
           alpham2=(1.-ptdeltax2)*(1.-tmoins2)/(1.-2.*tmoins2)
           betam2=rkappax2*(1.-tmoins2)/(1.-2.*tmoins2)**0.5
           x(ii)=rho*(alpha0m2+alpham2*cos(teta))
           y(ii)=-rho*(betam2*sin(teta))
           ii = ii+1
         enddo ! noteta
c upper minus
         do nophi=1,nbphim1
           phi=phim1in+(nophi-1)*phim1st
           alpha0m1=-((1.+ptdeltax1)*tmoins1-ptdeltax1)/(2.*tmoins1-1.)
           alpham1=(1.-ptdeltax1)*(1.-tmoins1)/(2.*tmoins1-1.)
           betam1=rkappax1*(1.-tmoins1)/(2.*tmoins1-1.)**0.5
           x(ii)=rho*(alpha0m1+alpham1*cosh(phi))
           y(ii)=-rho*(betam1*sinh(phi))
           ii = ii+1
         enddo ! nophi
c upper plus
         do noteta=1,nbtetap1
           teta=tetap1in+(noteta-1)*tetap1st
           alpha0p1=-(ptdeltax1+(1.-ptdeltax1)*tplus1)/(1.-2.*tplus1)
           alphap1=(1.+ptdeltax1)*(1.-tplus1)/(1.-2.*tplus1)
           betap1=rkappax1*(1.-tplus1)/(1.-2.*tplus1)**0.5
           x(ii)=rho*(alpha0p1+alphap1*cos(teta))
           y(ii)=-rho*(betap1*sin(teta))
           ii=ii+1
         enddo ! noteta
      endif ! true/false
c
c case of 2 semi-ellipse with triangularity
c 
      if(mode .eq. 4)then
        rkappax=0.5*(rkappax1+rkappax2)
        ptdeltax=0.5*(ptdeltax1+ptdeltax2)
        dzeta0=0.5*(rkappax1-rkappax2)
c external part
        tetain=-0.5*pi
        tetafi=0.5*pi
        nbteta=250
        tetast=(tetafi-tetain)/(nbteta-1)
        ii = 1
        do noteta=1,nbteta
          teta=tetain+(noteta-1)*tetast
          x(ii)=-ptdeltax+(1.+ptdeltax)*cos(teta)
          y(ii)=dzeta0+rkappax*sin(teta)
          ii = ii+1
        enddo ! noteta
c internal part
        tetain=0.5*pi
        tetafi=1.5*pi
        nbteta=250
        tetast=(tetafi-tetain)/(nbteta-1)
        do noteta=1,nbteta
          teta=tetain+(noteta-1)*tetast
          x(ii)=-ptdeltax+(1.-ptdeltax)*cos(teta)
          y(ii)=dzeta0+rkappax*sin(teta)
          ii = ii +1 
        enddo ! noteta
      endif ! true/false
       sizeOUT = 125*4
C x
      write(*,*) 'debut ecriture de x et y'
      plhs(1) = mxCreateFull(125*4,1,0)
      x_pr = mxGetPr(plhs(1))
      call mxCopyReal8ToPtr(x,x_pr,125*4)
C x
      plhs(2) = mxCreateFull(125*4,1,0)
      y_pr = mxGetPr(plhs(2))
      call mxCopyReal8ToPtr(y,y_pr,125*4)

       end
c
c
c

*DECK DASINH
      DOUBLE PRECISION FUNCTION DASINH (X)
C***BEGIN PROLOGUE  DASINH
C***PURPOSE  Compute the arc hyperbolic sine.
C***LIBRARY   SLATEC (FNLIB)
C***CATEGORY  C4C
C***TYPE      DOUBLE PRECISION (ASINH-S, DASINH-D, CASINH-C)
C***KEYWORDS  ARC HYPERBOLIC SINE, ASINH, ELEMENTARY FUNCTIONS, FNLIB,
C             INVERSE HYPERBOLIC SINE
C***AUTHOR  Fullerton, W., (LANL)
C***DESCRIPTION
C
C DASINH(X) calculates the double precision arc hyperbolic
C sine for double precision argument X.
C
C***REFERENCES  (NONE)
C***ROUTINES CALLED  D1MACH, DCSEVL, INITDS
C***REVISION HISTORY  (YYMMDD)
C   770601  DATE WRITTEN
C   890531  Changed all specific intrinsics to generic.  (WRB)
C   890531  REVISION DATE from Version 3.2
C   891214  Prologue converted to Version 4.0 format.  (BAB)
C***END PROLOGUE  DASINH
      DOUBLE PRECISION X, ASNHCS(39), ALN2, SQEPS, XMAX, Y,
     1  DCSEVL, D1MACH
      LOGICAL FIRST
      SAVE ASNHCS, ALN2, NTERMS, XMAX, SQEPS, FIRST
      DATA ASNHCS(  1) / -.1282003991 1738186343 3721273592 68 D+0     /
      DATA ASNHCS(  2) / -.5881176118 9951767565 2117571383 62 D-1     /
      DATA ASNHCS(  3) / +.4727465432 2124815640 7252497560 29 D-2     /
      DATA ASNHCS(  4) / -.4938363162 6536172101 3601747902 73 D-3     /
      DATA ASNHCS(  5) / +.5850620705 8557412287 4948352593 21 D-4     /
      DATA ASNHCS(  6) / -.7466998328 9313681354 7550692171 88 D-5     /
      DATA ASNHCS(  7) / +.1001169358 3558199265 9661920158 12 D-5     /
      DATA ASNHCS(  8) / -.1390354385 8708333608 6164722588 86 D-6     /
      DATA ASNHCS(  9) / +.1982316948 3172793547 3173602371 48 D-7     /
      DATA ASNHCS( 10) / -.2884746841 7848843612 7472728003 17 D-8     /
      DATA ASNHCS( 11) / +.4267296546 7159937953 4575149959 07 D-9     /
      DATA ASNHCS( 12) / -.6397608465 4366357868 7526323096 81 D-10    /
      DATA ASNHCS( 13) / +.9699168608 9064704147 8782931311 79 D-11    /
      DATA ASNHCS( 14) / -.1484427697 2043770830 2466583656 96 D-11    /
      DATA ASNHCS( 15) / +.2290373793 9027447988 0401843789 83 D-12    /
      DATA ASNHCS( 16) / -.3558839513 2732645159 9789426513 10 D-13    /
      DATA ASNHCS( 17) / +.5563969408 0056789953 3745390885 54 D-14    /
      DATA ASNHCS( 18) / -.8746250959 9624678045 6665935201 62 D-15    /
      DATA ASNHCS( 19) / +.1381524884 4526692155 8688022981 29 D-15    /
      DATA ASNHCS( 20) / -.2191668828 2900363984 9551422641 49 D-16    /
      DATA ASNHCS( 21) / +.3490465852 4827565638 3139237068 80 D-17    /
      DATA ASNHCS( 22) / -.5578578840 0895742439 6301570321 06 D-18    /
      DATA ASNHCS( 23) / +.8944514661 7134012551 0508827989 33 D-19    /
      DATA ASNHCS( 24) / -.1438342634 6571317305 5518452394 66 D-19    /
      DATA ASNHCS( 25) / +.2319181187 2169963036 3261446826 66 D-20    /
      DATA ASNHCS( 26) / -.3748700795 3314343674 5706045439 99 D-21    /
      DATA ASNHCS( 27) / +.6073210982 2064279404 5492428800 00 D-22    /
      DATA ASNHCS( 28) / -.9859940276 4633583177 3701734400 00 D-23    /
      DATA ASNHCS( 29) / +.1603921745 2788496315 2326382933 33 D-23    /
      DATA ASNHCS( 30) / -.2613884735 0287686596 7161343999 99 D-24    /
      DATA ASNHCS( 31) / +.4267084960 6857390833 3581653333 33 D-25    /
      DATA ASNHCS( 32) / -.6977021703 9185243299 7307733333 33 D-26    /
      DATA ASNHCS( 33) / +.1142508833 6806858659 8126933333 33 D-26    /
      DATA ASNHCS( 34) / -.1873529207 8860968933 0210133333 33 D-27    /
      DATA ASNHCS( 35) / +.3076358441 4464922794 0659200000 00 D-28    /
      DATA ASNHCS( 36) / -.5057736403 1639824787 0463999999 99 D-29    /
      DATA ASNHCS( 37) / +.8325075471 2689142224 2133333333 33 D-30    /
      DATA ASNHCS( 38) / -.1371845728 2501044163 9253333333 33 D-30    /
      DATA ASNHCS( 39) / +.2262986842 6552784104 1066666666 66 D-31    /
      DATA ALN2 / 0.6931471805 5994530941 7232121458 18D0 /
      DATA FIRST /.TRUE./
C***FIRST EXECUTABLE STATEMENT  DASINH
      IF (FIRST) THEN
         NTERMS = INITDS (ASNHCS, 39, 0.1*REAL(D1MACH(3)) )
         SQEPS = SQRT(D1MACH(3))
         XMAX = 1.0D0/SQEPS
      ENDIF
      FIRST = .FALSE.
C
      Y = ABS(X)
      IF (Y.GT.1.0D0) GO TO 20
C
      DASINH = X
      IF (Y.GT.SQEPS) DASINH = X*(1.0D0 + DCSEVL (2.D0*X*X-1.D0,
     1  ASNHCS, NTERMS) )
      RETURN
 20   IF (Y.LT.XMAX) DASINH = LOG (Y+SQRT(Y*Y+1.D0))
      IF (Y.GE.XMAX) DASINH = ALN2 + LOG(Y)
      DASINH = SIGN (DASINH, X)
      RETURN
C
      END
      
      
            DOUBLE PRECISION FUNCTION D1MACH(I)
      INTEGER I
C
C  DOUBLE-PRECISION MACHINE CONSTANTS
C  D1MACH( 1) = B**(EMIN-1), THE SMALLEST POSITIVE MAGNITUDE.
C  D1MACH( 2) = B**EMAX*(1 - B**(-T)), THE LARGEST MAGNITUDE.
C  D1MACH( 3) = B**(-T), THE SMALLEST RELATIVE SPACING.
C  D1MACH( 4) = B**(1-T), THE LARGEST RELATIVE SPACING.
C  D1MACH( 5) = LOG10(B)
C
      INTEGER SMALL(2)
      INTEGER LARGE(2)
      INTEGER RIGHT(2)
      INTEGER DIVER(2)
      INTEGER LOG10(2)
      INTEGER SC, CRAY1(38), J
      COMMON /D9MACH/ CRAY1
      SAVE SMALL, LARGE, RIGHT, DIVER, LOG10, SC
      DOUBLE PRECISION DMACH(5)
      EQUIVALENCE (DMACH(1),SMALL(1))
      EQUIVALENCE (DMACH(2),LARGE(1))
      EQUIVALENCE (DMACH(3),RIGHT(1))
      EQUIVALENCE (DMACH(4),DIVER(1))
      EQUIVALENCE (DMACH(5),LOG10(1))
C  THIS VERSION ADAPTS AUTOMATICALLY TO MOST CURRENT MACHINES.
C  R1MACH CAN HANDLE AUTO-DOUBLE COMPILING, BUT THIS VERSION OF
C  D1MACH DOES NOT, BECAUSE WE DO NOT HAVE QUAD CONSTANTS FOR
C  MANY MACHINES YET.
C  TO COMPILE ON OLDER MACHINES, ADD A C IN COLUMN 1
C  ON THE NEXT LINE
      DATA SC/0/
C  AND REMOVE THE C FROM COLUMN 1 IN ONE OF THE SECTIONS BELOW.
C  CONSTANTS FOR EVEN OLDER MACHINES CAN BE OBTAINED BY
C          mail netlib@research.bell-labs.com
C          send old1mach from blas
C  PLEASE SEND CORRECTIONS TO dmg OR ehg@bell-labs.com.
C
C     MACHINE CONSTANTS FOR THE HONEYWELL DPS 8/70 SERIES.
C      DATA SMALL(1),SMALL(2) / O402400000000, O000000000000 /
C      DATA LARGE(1),LARGE(2) / O376777777777, O777777777777 /
C      DATA RIGHT(1),RIGHT(2) / O604400000000, O000000000000 /
C      DATA DIVER(1),DIVER(2) / O606400000000, O000000000000 /
C      DATA LOG10(1),LOG10(2) / O776464202324, O117571775714 /, SC/987/
C
C     MACHINE CONSTANTS FOR PDP-11 FORTRANS SUPPORTING
C     32-BIT INTEGERS.
C      DATA SMALL(1),SMALL(2) /    8388608,           0 /
C      DATA LARGE(1),LARGE(2) / 2147483647,          -1 /
C      DATA RIGHT(1),RIGHT(2) /  612368384,           0 /
C      DATA DIVER(1),DIVER(2) /  620756992,           0 /
C      DATA LOG10(1),LOG10(2) / 1067065498, -2063872008 /, SC/987/
C
C     MACHINE CONSTANTS FOR THE UNIVAC 1100 SERIES.
C      DATA SMALL(1),SMALL(2) / O000040000000, O000000000000 /
C      DATA LARGE(1),LARGE(2) / O377777777777, O777777777777 /
C      DATA RIGHT(1),RIGHT(2) / O170540000000, O000000000000 /
C      DATA DIVER(1),DIVER(2) / O170640000000, O000000000000 /
C      DATA LOG10(1),LOG10(2) / O177746420232, O411757177572 /, SC/987/
C
C     ON FIRST CALL, IF NO DATA UNCOMMENTED, TEST MACHINE TYPES.
      IF (SC .NE. 987) THEN
         DMACH(1) = 1.D13
         IF (      SMALL(1) .EQ. 1117925532
     *       .AND. SMALL(2) .EQ. -448790528) THEN
*           *** IEEE BIG ENDIAN ***
            SMALL(1) = 1048576
            SMALL(2) = 0
            LARGE(1) = 2146435071
            LARGE(2) = -1
            RIGHT(1) = 1017118720
            RIGHT(2) = 0
            DIVER(1) = 1018167296
            DIVER(2) = 0
            LOG10(1) = 1070810131
            LOG10(2) = 1352628735
         ELSE IF ( SMALL(2) .EQ. 1117925532
     *       .AND. SMALL(1) .EQ. -448790528) THEN
*           *** IEEE LITTLE ENDIAN ***
            SMALL(2) = 1048576
            SMALL(1) = 0
            LARGE(2) = 2146435071
            LARGE(1) = -1
            RIGHT(2) = 1017118720
            RIGHT(1) = 0
            DIVER(2) = 1018167296
            DIVER(1) = 0
            LOG10(2) = 1070810131
            LOG10(1) = 1352628735
         ELSE IF ( SMALL(1) .EQ. -2065213935
     *       .AND. SMALL(2) .EQ. 10752) THEN
*               *** VAX WITH D_FLOATING ***
            SMALL(1) = 128
            SMALL(2) = 0
            LARGE(1) = -32769
            LARGE(2) = -1
            RIGHT(1) = 9344
            RIGHT(2) = 0
            DIVER(1) = 9472
            DIVER(2) = 0
            LOG10(1) = 546979738
            LOG10(2) = -805796613
         ELSE IF ( SMALL(1) .EQ. 1267827943
     *       .AND. SMALL(2) .EQ. 704643072) THEN
*               *** IBM MAINFRAME ***
            SMALL(1) = 1048576
            SMALL(2) = 0
            LARGE(1) = 2147483647
            LARGE(2) = -1
            RIGHT(1) = 856686592
            RIGHT(2) = 0
            DIVER(1) = 873463808
            DIVER(2) = 0
            LOG10(1) = 1091781651
            LOG10(2) = 1352628735
         ELSE IF ( SMALL(1) .EQ. 1120022684
     *       .AND. SMALL(2) .EQ. -448790528) THEN
*           *** CONVEX C-1 ***
            SMALL(1) = 1048576
            SMALL(2) = 0
            LARGE(1) = 2147483647
            LARGE(2) = -1
            RIGHT(1) = 1019215872
            RIGHT(2) = 0
            DIVER(1) = 1020264448
            DIVER(2) = 0
            LOG10(1) = 1072907283
            LOG10(2) = 1352628735
         ELSE IF ( SMALL(1) .EQ. 815547074
     *       .AND. SMALL(2) .EQ. 58688) THEN
*           *** VAX G-FLOATING ***
            SMALL(1) = 16
            SMALL(2) = 0
            LARGE(1) = -32769
            LARGE(2) = -1
            RIGHT(1) = 15552
            RIGHT(2) = 0
            DIVER(1) = 15568
            DIVER(2) = 0
            LOG10(1) = 1142112243
            LOG10(2) = 2046775455
         ELSE
            DMACH(2) = 1.D27 + 1
            DMACH(3) = 1.D27
            LARGE(2) = LARGE(2) - RIGHT(2)
            IF (LARGE(2) .EQ. 64 .AND. SMALL(2) .EQ. 0) THEN
               CRAY1(1) = 67291416
               DO 10 J = 1, 20
                  CRAY1(J+1) = CRAY1(J) + CRAY1(J)
 10               CONTINUE
               CRAY1(22) = CRAY1(21) + 321322
               DO 20 J = 22, 37
                  CRAY1(J+1) = CRAY1(J) + CRAY1(J)
 20               CONTINUE
               IF (CRAY1(38) .EQ. SMALL(1)) THEN
*                  *** CRAY ***
                  CALL I1MCRY(SMALL(1), J, 8285, 8388608, 0)
                  SMALL(2) = 0
                  CALL I1MCRY(LARGE(1), J, 24574, 16777215, 16777215)
                  CALL I1MCRY(LARGE(2), J, 0, 16777215, 16777214)
                  CALL I1MCRY(RIGHT(1), J, 16291, 8388608, 0)
                  RIGHT(2) = 0
                  CALL I1MCRY(DIVER(1), J, 16292, 8388608, 0)
                  DIVER(2) = 0
                  CALL I1MCRY(LOG10(1), J, 16383, 10100890, 8715215)
                  CALL I1MCRY(LOG10(2), J, 0, 16226447, 9001388)
               ELSE
                  WRITE(*,9000)
                  STOP 779
                  END IF
            ELSE
               WRITE(*,9000)
               STOP 779
               END IF
            END IF
         SC = 987
         END IF
*    SANITY CHECK
      IF (DMACH(4) .GE. 1.0D0) STOP 778
      IF (I .LT. 1 .OR. I .GT. 5) THEN
         WRITE(*,*) 'D1MACH(I): I =',I,' is out of bounds.'
         STOP
         END IF
      D1MACH = DMACH(I)
      RETURN
 9000 FORMAT(/' Adjust D1MACH by uncommenting data statements'/
     *' appropriate for your machine.')
* /* Standard C source for D1MACH -- remove the * in column 1 */
*#include <stdio.h>
*#include <float.h>
*#include <math.h>
*double d1mach_(long *i)
*{
*  switch(*i){
*    case 1: return DBL_MIN;
*    case 2: return DBL_MAX;
*    case 3: return DBL_EPSILON/FLT_RADIX;
*    case 4: return DBL_EPSILON;
*    case 5: return log10((double)FLT_RADIX);
*    }
*  fprintf(stderr, "invalid argument: d1mach(%ld)\n", *i);
*  exit(1); return 0; /* some compilers demand return values */
*}
      END
      SUBROUTINE I1MCRY(A, A1, B, C, D)
**** SPECIAL COMPUTATION FOR OLD CRAY MACHINES ****
      INTEGER A, A1, B, C, D
      A1 = 16777216*B + C
      A = 16777216*A1 + D
      END



*DECK DCSEVL
      DOUBLE PRECISION FUNCTION DCSEVL (X, CS, N)
C***BEGIN PROLOGUE  DCSEVL
C***PURPOSE  Evaluate a Chebyshev series.
C***LIBRARY   SLATEC (FNLIB)
C***CATEGORY  C3A2
C***TYPE      DOUBLE PRECISION (CSEVL-S, DCSEVL-D)
C***KEYWORDS  CHEBYSHEV SERIES, FNLIB, SPECIAL FUNCTIONS
C***AUTHOR  Fullerton, W., (LANL)
C***DESCRIPTION
C
C  Evaluate the N-term Chebyshev series CS at X.  Adapted from
C  a method presented in the paper by Broucke referenced below.
C
C       Input Arguments --
C  X    value at which the series is to be evaluated.
C  CS   array of N terms of a Chebyshev series.  In evaluating
C       CS, only half the first coefficient is summed.
C  N    number of terms in array CS.
C
C***REFERENCES  R. Broucke, Ten subroutines for the manipulation of
C                 Chebyshev series, Algorithm 446, Communications of
C                 the A.C.M. 16, (1973) pp. 254-256.
C               L. Fox and I. B. Parker, Chebyshev Polynomials in
C                 Numerical Analysis, Oxford University Press, 1968,
C                 page 56.
C***ROUTINES CALLED  D1MACH, XERMSG
C***REVISION HISTORY  (YYMMDD)
C   770401  DATE WRITTEN
C   890831  Modified array declarations.  (WRB)
C   890831  REVISION DATE from Version 3.2
C   891214  Prologue converted to Version 4.0 format.  (BAB)
C   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
C   900329  Prologued revised extensively and code rewritten to allow
C           X to be slightly outside interval (-1,+1).  (WRB)
C   920501  Reformatted the REFERENCES section.  (WRB)
C***END PROLOGUE  DCSEVL
      DOUBLE PRECISION B0, B1, B2, CS(*), ONEPL, TWOX, X, D1MACH
      LOGICAL FIRST
      SAVE FIRST, ONEPL
      DATA FIRST /.TRUE./
C***FIRST EXECUTABLE STATEMENT  DCSEVL
      IF (FIRST) ONEPL = 1.0D0 + D1MACH(4)
      FIRST = .FALSE.
      IF (N .LT. 1) PRINT *,'SLATEC', 'DCSEVL',
     +   'NUMBER OF TERMS .LE. 0', 2, 2
      IF (N .GT. 1000) PRINT *,'SLATEC', 'DCSEVL',
     +   'NUMBER OF TERMS .GT. 1000', 3, 2
      IF (ABS(X) .GT. ONEPL) PRINT *,'SLATEC', 'DCSEVL',
     +   'X OUTSIDE THE INTERVAL (-1,+1)', 1, 1
C
      B1 = 0.0D0
      B0 = 0.0D0
      TWOX = 2.0D0*X
      DO 10 I = 1,N
         B2 = B1
         B1 = B0
         NI = N + 1 - I
         B0 = TWOX*B1 - B2 + CS(NI)
   10 CONTINUE
C
      DCSEVL = 0.5D0*(B0-B2)
C
      RETURN
      END


*DECK INITDS
      FUNCTION INITDS (OS, NOS, ETA)
C***BEGIN PROLOGUE  INITDS
C***PURPOSE  Determine the number of terms needed in an orthogonal
C            polynomial series so that it meets a specified accuracy.
C***LIBRARY   SLATEC (FNLIB)
C***CATEGORY  C3A2
C***TYPE      DOUBLE PRECISION (INITS-S, INITDS-D)
C***KEYWORDS  CHEBYSHEV, FNLIB, INITIALIZE, ORTHOGONAL POLYNOMIAL,
C             ORTHOGONAL SERIES, SPECIAL FUNCTIONS
C***AUTHOR  Fullerton, W., (LANL)
C***DESCRIPTION
C
C  Initialize the orthogonal series, represented by the array OS, so
C  that INITDS is the number of terms needed to insure the error is no
C  larger than ETA.  Ordinarily, ETA will be chosen to be one-tenth
C  machine precision.
C
C             Input Arguments --
C   OS     double precision array of NOS coefficients in an orthogonal
C          series.
C   NOS    number of coefficients in OS.
C   ETA    single precision scalar containing requested accuracy of
C          series.
C
C***REFERENCES  (NONE)
C***ROUTINES CALLED  XERMSG
C***REVISION HISTORY  (YYMMDD)
C   770601  DATE WRITTEN
C   890531  Changed all specific intrinsics to generic.  (WRB)
C   890831  Modified array declarations.  (WRB)
C   891115  Modified error message.  (WRB)
C   891115  REVISION DATE from Version 3.2
C   891214  Prologue converted to Version 4.0 format.  (BAB)
C   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
C***END PROLOGUE  INITDS
      DOUBLE PRECISION OS(*)
C***FIRST EXECUTABLE STATEMENT  INITDS
      IF (NOS .LT. 1) PRINT *,'SLATEC', 'INITDS',
     +   'Number of coefficients is less than 1', 2, 1
C
      ERR = 0.
      DO 10 II = 1,NOS
        I = NOS + 1 - II
        ERR = ERR + ABS(REAL(OS(I)))
        IF (ERR.GT.ETA) GO TO 20
   10 CONTINUE
C
   20 IF (I .EQ. NOS) PRINT *,'SLATEC', 'INITDS',
     +   'Chebyshev series too short for specified accuracy', 1, 1
      INITDS = I
C
      RETURN
      END

      

