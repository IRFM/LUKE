      subroutine mexFunction(nlhs,plhs,nrhs,prhs)
C Compilation : mex separatrice.f -lnag
C--------------------------------------------------------------

      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
C DECLARATION DES VARIABLES
c pointeurs mex   
      integer*8 plhs(*), prhs(*),mxGetPr, mxCreateFull
      integer nlhs, nrhs, mxgetN, mxgetM
c 
c Extrait du main de helios.f concernant le trace de la derniere surface
c magnetique (il s'agit d'une implementation triviale des formules fournies)
c
c pointeurs et tailles      
      integer*8 geom_pr,mode_pr,x_pr,y_pr
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
      write(*,*) 'debut sepratrice'
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
        phixm2 = s11abf((2.*tmoins2-1.)**0.5/(1.-tmoins2),ifail)
c        phixm2=asinh((2.*tmoins2-1.)**0.5/(1.-tmoins2))
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
         phixm1=s11abf((2.*tmoins1-1.)**0.5/(1.-tmoins1),ifail) 
c         phixm1=asinh((2.*tmoins1-1.)**0.5/(1.-tmoins1))
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
      DOUBLE PRECISION FUNCTION S11ABF(X,IFAIL)
C     MARK 5A REVISED - NAG COPYRIGHT 1976
C     MARK 11.5(F77) REVISED. (SEPT 1985.)
C     ARCSINH(X)
C
C     .. Scalar Arguments ..
      DOUBLE PRECISION                 X
      INTEGER                          IFAIL
C     .. Local Scalars ..
      DOUBLE PRECISION                 LN2, T, XHI, Y
C     .. Intrinsic Functions ..
      INTRINSIC                        ABS, LOG, SIGN, SQRT
C     .. Data statements ..
C     PRECISION DEPENDENT CONSTANTS
C08   DATA XHI,LN2/1.0D+5,6.9314718D-1/
C12   DATA XHI,LN2/1.0D+7,6.93147180560D-1/
C14   DATA XHI,LN2/1.0D+8,6.9314718055995D-1/
      DATA XHI,LN2/1.0D+9,6.931471805599453D-1/
C18   DATA XHI,LN2/1.0D+10,6.93147180559945309D-1/
C     .. Executable Statements ..
C
C     NO FAILURE EXITS
      IFAIL = 0
      T = ABS(X)
C     TEST LARGE RANGE
      IF (T.GT.XHI) GO TO 20
      T = X*X
C
C     TEST FOR MIDDLE RANGE
      IF (T.GT.1.0D0) GO TO 40
C     EXPANSION ARGUMENT
      T = 2.0D0*T - 1.0D0
C
C      * EXPANSION (0012) *
C
C     EXPANSION (0012) EVALUATED AS Y(T)  --PRECISION 08E
C08   Y = ((((((((+2.5373657D-6)*T-8.8982681D-6)*T+2.6962688D-5)
C08  *    *T-1.0390000D-4)*T+4.2316523D-4)*T-1.8337913D-3)
C08  *    *T+9.0042679D-3)*T-5.7366614D-2)*T + 9.3122986D-1
C
C     EXPANSION (0012) EVALUATED AS Y(T)  --PRECISION 12E
C12   Y = (((((((((((((-6.08021584775D-9)*T+1.98638973110D-8)
C12  *    *T-4.57508091809D-8)*T+1.58893891259D-7)
C12  *    *T-5.83039413992D-7)*T+2.05819238929D-6)
C12  *    *T-7.40199001696D-6)*T+2.74058634726D-5)
C12  *    *T-1.05071718894D-4)*T+4.23002689824D-4)
C12  *    *T-1.83345864783D-3)*T+9.00428855313D-3)
C12  *    *T-5.73666392630D-2)*T + 9.31229859453D-1
C
C     EXPANSION (0012) EVALUATED AS Y(T)  --PRECISION 14E
C14   Y = (((((((((((((((-5.8308026585469D-10)*T+1.8762742119651D-9)
C14  *    *T-3.8936648507940D-9)*T+1.3296937569163D-8)
C14  *    *T-4.9030635676319D-8)*T+1.6792346090382D-7)
C14  *    *T-5.8053399097437D-7)*T+2.0520358645332D-6)
C14  *    *T-7.4030149627429D-6)*T+2.7408018256297D-5)
C14  *    *T-1.0507150365535D-4)*T+4.2300233069384D-4)
C14  *    *T-1.8334586677591D-3)*T+9.0042885755717D-3)
C14  *    *T-5.7366639262479D-2)*T + 9.3122985945271D-1
C
C     EXPANSION (0012) EVALUATED AS Y(T)  --PRECISION 16E
      Y = (((((((((((((((+1.810792296549804D-11
     *    *T-5.731943029121004D-11)*T+1.008344962167889D-10)
     *    *T-3.394726871170490D-10)*T+1.299779213740398D-9)
     *    *T-4.319978113584910D-9)*T+1.432753532351304D-8)
     *    *T-4.863477336087045D-8)*T+1.670117348345774D-7)
     *    *T-5.807433412373489D-7)*T+2.052474396638805D-6)
     *    *T-7.402952157663977D-6)*T+2.740790473603819D-5)
     *    *T-1.050715136470630D-4)*T+4.230023450529706D-4)
     *    *T-1.833458667045431D-3)*T+9.004288574881897D-3
      Y = (Y*T-5.736663926249348D-2)*T + 9.312298594527122D-1
C
C     EXPANSION (0012) EVALUATED AS Y(T)  --PRECISION 18E
C18   Y = (((((((((((((((+1.83000936086660710D-12
C18  *    *T-5.74532833323253760D-12)*T+8.95787616116500070D-12)
C18  *    *T-3.00291207083554898D-11)*T+1.20278345675996627D-10)
C18  *    *T-3.94053306282758078D-10)*T+1.27690409672956527D-9)
C18  *    *T-4.26028056137241518D-9)*T+1.43437981020129308D-8)
C18  *    *T-4.86735767698085752D-8)*T+1.67004579212037421D-7)
C18  *    *T-5.80728097040980303D-7)*T+2.05247631332341414D-6)
C18  *    *T-7.40295567555544635D-6)*T+2.74079044411636393D-5)
C18  *    *T-1.05071513207326607D-4)*T+4.23002345076007640D-4
C18   Y = (((Y*T-1.83345866707041640D-3)*T+9.00428857488119850D-3)
C18  *    *T-5.73666392624930609D-2)*T + 9.31229859452712177D-1
C
C
      S11ABF = X*Y
      RETURN
C
C     LARGE X
   20 S11ABF = SIGN(DLOG(T)+LN2,X)
      RETURN
C
C     MIDDLE X
   40 S11ABF = SIGN(DLOG(SQRT(T+1.0D0)+ABS(X)),X)
      RETURN
C
      END


