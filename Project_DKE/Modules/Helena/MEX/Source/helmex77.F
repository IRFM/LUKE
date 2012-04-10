
#include "fintrf.h"


      
      subroutine mexFunction(nlhs,plhs,nrhs,prhs)
C--------------------------------------------------------------
C Interface mex-file (matlab 5) pour le code HELENA
C F. Imbeaux - Aout 2000
C
C Appel depuis Matlab :
C [C2,C3,rho2m,R,Z,rho,Vp,drhoor,qpsi,psipout,ftra,Fdia,psiT,B2,invB2,Sp, ...
C    rav,oor,drhoav,xshift,xrad,xell,xtriapos,xtrianeg,jout,iout,pout, ...
C    r2,oor2,r2tau2,drho2ob2,r3otau3,r3otau,BPR,BPZ,b,df2,kkbig,li, ...
C    dimerc,drmerc,balcrit,ifail]= ...
C    helmex77(psipin,ptot,jin,R0,B0,Ip,lsc,a,elong,triangh,triangb,Rext,Zext,init,b,df2,kkbig,ecrit);
C 
C Inputs :
C psipin : flux poloidal (V*s, doit etre nul au centre) [Xpts,1]
C ptot : ne Te + ni Ti (keV * m-3) [Xpts,1] 
C jin : densite de courant (A/m2) [Xpts,1]
C R0 : grand rayon (m) [1,1]
C B0 : champ magnetique (T) [1,1]
C Ip : courant plasma (A) [1,1], Ip < 0 -> utilisation de psip pour le calcul du courant
C lsc : type d'input pour la derniere surface magnetique fermee [1,1]
C        0 = plasma symetrique, donnee de a, elong, triang
C        1 = plasma asym�trique, donnee de a, elong, triangh, triangb
C        2 = plasma asym�trique, donnee de la LSC en (R,Z)
C a  : petit rayon (m) [1,1]
C elong : ellipticite de la derniere surface magnetique fermee (1 pour TS) (-) [1,1]
C triangh : triangularite haute de la derniere surface magnetique fermee (0 pour TS) (-) [1,1]
C triangb : triangularite basse de la derniere surface magnetique fermee (0 pour TS) (-) [1,1]
C init : si =1, alors on part de l'equilibre initial specifie par df2,b,kkbig [1,1]
C        si =0, alors on part d'un equilibre initial quelconque
C b : parametre b de l'equilibre initial (-) [1,1]
C df2 : vecteur df2 de l'equilibre initial (-) [101,1]
C kkbig : matrice kkbig deja calculee (-) [KKLDA,4*MAXNODE]
C ecrit : matrice kkbig deja calculee (-) [KKLDA,4*MAXNODE]
C Rext  : grand rayon de la derniere surface de flux [250,1]
C Zext  : altitude de la derniere surface de flux [250,1]
C
C Outputs :
C <> designe la moyenne de la variable sur une surface de flux poloidal 
C C2     : Vp*<gradient(rho)^2/R^2 > [NRMAP,1]
C C3     : Vp*< 1/R^2 > [NRMAP,1]
C rho2m  : <|gradient(rho)|^2> [NRMAP,1]
C rho    : coordonee de flux toroidal (racine du flux toroidal) (m) [NRMAP,1]
C [R,Z]  : coordonnees geometriques des surfaces magnetiques (m) [NRMAP,NPMAP]
C Vp     : V' (dV/drho a rho(i)-m**2) [NRMAP,1]
C drhoor : <|grad(rho)|/R> [NRMAP,1]
C qpsi   : facteur de securite [NRMAP,1]
C psip   : flux poloidal (V*s) [NRMAP,1]
C ftra   : fraction de piegees [NRMAP,1] 
C Fdia   : fonction diamagnetique [NRMAP,1]
C psiT   : flux toroidal (V*s) [NRMAP,1]
C B2     : <B^2> (T^2) [NRMAP,1]
C invB2  : moyenne de l'inverse de B^2 sur une surface de flux (T^-2) [NRMAP,1]
C Sp     : dS/drho (<tau>) [NRMAP,1]
C rav    : <R> (m) [NRMAP,1]
C oor    : <1/R> (m^-1) [NRMAP,1]
C drhoav : <|grad(rho)|> [NRMAP,1]
C xshift : decentrement (m) [NRMAP,1]
C xrad   : petit rayon geometrique (m) [NRMAP,1]
C xell   : ellipticite (-) [NRMAP,1]
C xtriapos : triangularite superieure (Z>0) (-) [NRMAP,1]
C xtrianeg : triangularite inferieure (Z<0) (-) [NRMAP,1]
C jout   : densite de courant recalculee d'apres l'equilibre trouve (A/m2) [NRMAP,1]
C iout   : courant total ( pi*4E-7 * I / (a*B) )
C pout   : pression totale recalculee d'apres l'equilibre trouve (keV * m-3) [NRMAP,1]
C r2 : <R^2> (m^2) [NRMAP,1]
C oor2 : <1/R2> (m^-2) [NRMAP,1]
C r2tau2 : <R^2/tau^2> (m^-6) [NRMAP,1]
C drho2ob2 : < |grad(rho)|^2/B^2 > (m^2.T^-2) [NRMAP,1]
C r3otau3 : <R^3/tau^3> (m^-3) [NRMAP,1]
C r3otau : <R^3/tau> (m) [NRMAP,1] 
C BPR     : Coordonnee R du champ magnetique sur un maillage (R,Z) (T) [NRMAP,NPMAP]
C BPZ     : Coordonnee Z du champ magnetique sur un maillage (R,Z) (T) [NRMAP,NPMAP]
C b : parametre b de l'equilibre final (-) [1,1]
C df2 : vecteur df2 de l'equilibre initial (-) [101,1]
C kkbig : matrice kkbig deja calculee (-) [KKLDA,4*MAXNODE]
c DIMERC : Ideal Mercier criterion
c DRMERC : resistive Mercier criterion
c BALCRIT : ballooning stability criterion (stable if >1, marginally stable if =1, unstable if <1, except if s<0 : balcrit=0 (always stable with negative magnetic shear)) 
c ifail  : code d'erreur (0 si pas d'erreur) [1,1]
C
C Compilation : fmex helmex77.f -ldxml
C--------------------------------------------------------------

      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)

C-----------------------------------------------------------
C Taille des tableaux de sortie. Cette liste de parametres
C est presente dans de nombreuses subroutines, et doit etre
C mise a jour partout en cas de modification
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      COMMON / COMDAT/                                                  
     >        ELLIP,TRIAH,TRIAB,QUAD,PAR1,PAR2,PAR3,PAR4,                      
     >        AGA,BGA,CGA,DGA,EGA,FGA,GGA,HGA,                          
     >        API,BPI,CPI,DPI,EPI,FPI,GPI,HPI,                          
     >        ACUR,BCUR,CCUR,DCUR,ECUR,FCUR,GCUR,HCUR,                  
     >        ERRIT,ERRCUR,EPS,ALFA,B,C,XIAB,Q95,BETAP,AMIX,BMIX,       
     >        ABB, BBB, AMPL, RVAC,BVAC,ZEFF,ZN0,RPE,XR1,SIG1,          
     >        IAS,ICUR,NRCUR,NPCUR,NMESH,INIMESH,NBB,NQB,IARC,          
     >        MHARM,ISHAPE,ISOL,IGAM,IPAI,NR,NP,NRMAP,NPMAP,NITER       
      real*8    ELLIP,TRIAH,TRIAB,QUAD,PAR1,PAR2,PAR3,PAR4,                      
     >        AGA,BGA,CGA,DGA,EGA,FGA,GGA,HGA,                          
     >        API,BPI,CPI,DPI,EPI,FPI,GPI,HPI,                          
     >        ACUR,BCUR,CCUR,DCUR,ECUR,FCUR,GCUR,HCUR,                  
     >        ERRIT,ERRCUR,EPS,ALFA,B,C,XIAB,Q95,BETAP,AMIX,BMIX,       
     >        ABB, BBB, AMPL, RVAC,BVAC,ZEFF,ZN0,RPE,XR1,SIG1           
      integer IAS,ICUR,NRCUR,NPCUR,NMESH,INIMESH,NBB,NQB,IARC,          
     >        MHARM,ISHAPE,ISOL,IGAM,IPAI,NR,NP,NRMAP,NPMAP,NITER       
C-----------------------------------------------------------------------
      COMMON /CORNERS/ RS, IJ, NODENO                                   
      real*8    RS(4,2)                                                   
      integer IJ(4,2), NODENO(MAXMNODE,4)                               
C-----------------------------------------------------------------------
      COMMON/COMPROF/DPR,DF2,ZJZ,QIN,DPRES,DGAM,PINT,GINT,NPTS          
      real*8    DPR(NPTSMAX),DF2(NPTSMAX),ZJZ(NPTSMAX),QIN(NPTSMAX),      
     >        DPRES(1001),DGAM(1001),PINT(1001),GINT(1001)              
      integer NPTS                                                      
C-----------------------------------------------------------------------
      COMMON/TOLERA/PSITOL,THTTOL,TOL                                   
      real*8    PSITOL,THTTOL,TOL                                         
C-----------------------------------------------------------------------
      COMMON/MESH2/XXOLD,YYOLD,PSIOLD                                   
      real*8    XXOLD(4,MAXNODE),YYOLD(4,MAXNODE),PSIOLD(4*MAXNODE)       
C-----------------------------------------------------------------------
      COMMON/FAXIS/PSI,NAXIS                                            
      real*8    PSI(4*MAXMNODE)                                           
      integer NAXIS                                                     
C-----------------------------------------------------------------------
      COMMON/COMSOLV/KKBIG                                              
      real*8 KKBIG(KKLDA,4*MAXNODE)                                       
c      real*8, ALLOCATABLE :: KKBIG(:,:)                                  
c      integer KKLDA                                                    
C-----------------------------------------------------------------------                               
C DECLARATION DES VARIABLES
c pointeurs mex   
      INTEGER*8 plhs(*), prhs(*) 
      integer nlhs, nrhs
c variables de sortie      
      real*8 VP(NRMMAX),C2(NRMMAX),C3(NRMMAX),R2M(NRMMAX),RHO(NRMMAX)
      real*8 FTRA(NRMMAX),FDIA(NRMMAX),INVB2(NRMMAX)
      real*8 DRHOOR(NRMMAX),QPSI(NRMMAX),B2(NRMMAX)
      real*8 SP(NRMMAX),Jout(NRMMAX),PSIPOUT(NRMMAX),PSIT(NRMMAX)
      real*8 RR(NRMMAX,NPMMAX),ZZ(NRMMAX,NPMMAX)
      real*8 RAV(NRMMAX),OOR(NRMMAX),DRHOAV(NRMMAX),XRAD(NRMMAX)
      real*8 XSHIFT(NRMMAX),XELL(NRMMAX),XTRIAPOS(NRMMAX)
      real*8 XTRIANEG(NRMMAX),Pout(NRMMAX),R2(NRMMAX),OOR2(NRMMAX)
      real*8 R2TAU2(NRMMAX),DRHO2OB2(NRMMAX),R3OTAU3(NRMMAX)
      real*8 R3OTAU(NRMMAX)
      real*8 BPR(NRMMAX,NPMMAX),BPZ(NRMMAX,NPMMAX)
      real*8 DIMERC(NRMMAX),DRMERC(NRMMAX),BALCRIT(NRMMAX)
      real*8 LSC
      integer IFAIL
c taille des tableaux d'entree fixee a 101 elements      
      real*8 PSIPIN(101),PTOT(101),Jin(101),Rext(250),Zext(250)
      real*8 R0, amin, B0, Ip, ecrit
c pointeurs et tailles      
      INTEGER*8 VP_pr,C2_pr,C3_pr,R2M_pr,RHO_pr
      INTEGER*8 FTRA_pr,FDIA_pr,INVB2_pr
      INTEGER*8 DRHOOR_pr,QPSI_pr,B2_pr
      INTEGER*8 SP_pr,Jout_pr,PSIPOUT_pr,PSIT_pr,Pout_pr
      INTEGER*8 RR_pr,ZZ_pr,Rext_pr,Zext_pr,init_pr
      INTEGER*8 PSIPIN_pr,PTOT_pr,Jin_pr,B0_pr, Ip_pr
      INTEGER*8 R0_pr, amin_pr, ELLIP_pr, TRIAH_pr, TRIAB_pr      
      INTEGER*8 RAV_pr,OOR_pr,DRHOAV_pr,XRAD_pr,XIAB_pr
      INTEGER*8 XSHIFT_pr,XELL_pr,XTRIAPOS_pr,XTRIANEG_pr,IFAIL_pr
      INTEGER*8 ECRIT_pr,DIMERC_pr,DRMERC_pr,BALCRIT_pr
      INTEGER*8 R2_pr,OOR2_pr,R2TAU2_pr,DRHO2OB2_pr,R3OTAU3_pr,R3OTAU_pr
      INTEGER*8 LSC_pr,BPR_pr,BPZ_pr,b_pr,df2_pr,kkbig_pr,XLI_pr      
      integer   m, n, sizeIN, sizeOUT, mxGetM, mxGetN, mRext, nRext
      integer   sizeR
      INTEGER*8 mxCreateFull, mxGetPr

C---------------------------------------------------------------------
C GESTION DES ENTREES     
C taille des tableaux (nb de points radiaux)     
      m = mxGetM(prhs(1))
      n = mxGetN(prhs(1))
      sizeIN = m*n
c
c taille de la position de la derniere surface de flux
c
      mRext = mxGetM(prhs(12))
      nRext = mxGetN(prhs(12))
      sizeR = mRext*nRext   
   
C      if (sizeIN .gt. NRMMAX) then
C         call mexErrMsgTxt('Erreur de dimension : trop de points radiaux')
C      endif   
C flux poloidal (0 au centre du plasma)     
      PSIPIN_pr = mxGetPr(prhs(1))
      call mxCopyReal8ToPtr(PSIPIN_pr,PSIPIN,sizeIN)
C pression totale (keV * m-3)
      PTOT_pr = mxGetPr(prhs(2))
      call mxCopyReal8ToPtr(PTOT_pr,PTOT,sizeIN)
C densite de courant (A/m2)
      Jin_pr = mxGetPr(prhs(3))
      call mxCopyReal8ToPtr(Jin_pr,Jin,sizeIN)
C grand rayon (m)
      R0_pr = mxGetPr(prhs(4))
      call mxCopyReal8ToPtr(R0_pr,R0,1)
C champ magnetique (T)
      B0_pr = mxGetPr(prhs(5))
      call mxCopyReal8ToPtr(B0_pr,B0,1)
C courant total (A)
      Ip_pr = mxGetPr(prhs(6))
      call mxCopyReal8ToPtr(Ip_pr,Ip,1)
C type d'input pour la derniere surface fermee
      LSC_pr = mxGetPr(prhs(7))
      call mxCopyReal8ToPtr(LSC_pr,LSC,1)
      IF (INT(LSC).EQ.0) THEN
         IAS = 0      
C        petit rayon (m)
         amin_pr = mxGetPr(prhs(8))
         call mxCopyReal8ToPtr(amin_pr,amin,1)      
C        ellipticite
         ELLIP_pr = mxGetPr(prhs(9))
         call mxCopyReal8ToPtr(ELLIP_pr,ELLIP,1)
C        triangularite
         TRIAH_pr = mxGetPr(prhs(10))
         call mxCopyReal8ToPtr(TRIAH_pr,TRIAH,1)
         TRIAB = TRIAH
			NBext = -1
      ELSEIF (INT(LSC).EQ.1) THEN
         IAS = 1      
C        petit rayon (m)
         amin_pr = mxGetPr(prhs(8))
         call mxCopyReal8ToPtr(amin_pr,amin,1)      
C        ellipticite
         ELLIP_pr = mxGetPr(prhs(9))
         call mxCopyReal8ToPtr(ELLIP_pr,ELLIP,1)
C        triangularite haute
         TRIAH_pr = mxGetPr(prhs(10))
         call mxCopyReal8ToPtr(TRIAH_pr,TRIAH,1)
C        triangularite basse
         TRIAB_pr = mxGetPr(prhs(11))
         call mxCopyReal8ToPtr(TRIAB_pr,TRIAB,1)
         NBext = -1
      ELSE
         IAS = 1
c
c     position de la derniere surface de flux
c
C        petit rayon (m)
        amin_pr = mxGetPr(prhs(8))
        call mxCopyReal8ToPtr(amin_pr,amin,1)
        Rext_pr = mxGetPr(prhs(12))
        call mxCopyReal8ToPtr(Rext_pr,Rext,sizeR) 
        Zext_pr = mxGetPr(prhs(13))
        call mxCopyReal8ToPtr(Zext_pr,Zext,sizeR) 
        NBext = sizeR        
      ENDIF
      
C init (pour partir d'un equilibre deja specifie)
      init_pr = mxGetPr(prhs(14))
      call mxCopyReal8ToPtr(init_pr,TINIT,1)
      IF (INT(TINIT).EQ.1) THEN
         INI=1
C        B
         b_pr = mxGetPr(prhs(15))
         call mxCopyReal8ToPtr(b_pr,B,1)
C        DF2
         df2_pr = mxGetPr(prhs(16))
         call mxCopyReal8ToPtr(df2_pr,DF2,101)
C        KKBIG
         kkbig_pr = mxGetPr(prhs(17))
         call mxCopyReal8ToPtr(kkbig_pr,KKBIG,KKLDA*4*MAXNODE)
      ELSE
         INI=0
      ENDIF  
      IF (nrhs.GE.18) THEN
          ECRIT_pr = mxGetPr(prhs(18))
          call mxCopyReal8ToPtr(ECRIT_pr,ecrit,1)
      ELSE
          ecrit =0.0
      ENDIF      
      CALL HELENA(PSIPIN,PTOT,Jin,sizeIN,INI,amin,R0,B0,Ip,
     >            C2,C3,R2M,RR,ZZ,RHO,VP,DRHOOR,QPSI,PSIPOUT,FTRA,FDIA,
     >            PSIT,B2,INVB2,SP,Jout,RAV,OOR,DRHOAV,XRAD,XSHIFT,
     >            XELL,XTRIAPOS,XTRIANEG,Pout,
     >            R2,OOR2,R2TAU2,DRHO2OB2,R3OTAU3,R3OTAU,
     >            BPR,BPZ,Rext,Zext,NBext,XLI,DIMERC,DRMERC,
     >            BALCRIT,IFAIL,ecrit)

C---------------------------------------------------------------------
C GESTION DES SORTIES
C Recuperation du nombre de valeurs du flux poloidal et de l'angle poloidal
C de la grille de sortie
      sizeOUT = NRMAP * NPMAP
C C2 : Vp <gradient(rho)^2/R^2 >
      plhs(1) = mxCreateFull(NRMAP,1,0)
      C2_pr = mxGetPr(plhs(1))
      call mxCopyReal8ToPtr(C2,C2_pr,NRMAP)
C C3 : Vp < 1/R^2 >
      plhs(2) = mxCreateFull(NRMAP,1,0)
      C3_pr = mxGetPr(plhs(2))
      call mxCopyReal8ToPtr(C3,C3_pr,NRMAP)
C R2M : (rho2m) < | gradient(rho)^2 | >
      plhs(3) = mxCreateFull(NRMAP,1,0)
      R2M_pr = mxGetPr(plhs(3))
      call mxCopyReal8ToPtr(R2M,R2M_pr,NRMAP)
C R et Z des surfaces de flux     
      plhs(4) = mxCreateFull(NRMAP,NPMAP,0)
      RR_pr = mxGetPr(plhs(4))
      call mxCopyReal8ToPtr(RR,RR_pr,sizeOUT)
      plhs(5) = mxCreateFull(NRMAP,NPMAP,0)
      ZZ_pr = mxGetPr(plhs(5))
      call mxCopyReal8ToPtr(ZZ,ZZ_pr,sizeOUT)
C RHO racine du flux toroidal (m)
      plhs(6) = mxCreateFull(NRMAP,1,0)
      RHO_pr = mxGetPr(plhs(6))
      call mxCopyReal8ToPtr(RHO,RHO_pr,NRMAP)
C Vp : V' (dV/drho a rho(i)-m**2)
      plhs(7) = mxCreateFull(NRMAP,1,0)
      VP_pr = mxGetPr(plhs(7))
      call mxCopyReal8ToPtr(VP,VP_pr,NRMAP)
C drhoor : <abs(grad(rho))/R>
      plhs(8) = mxCreateFull(NRMAP,1,0)
      DRHOOR_pr = mxGetPr(plhs(8))
      call mxCopyReal8ToPtr(DRHOOR,DRHOOR_pr,NRMAP)
C qpsi : facteur de securite
      plhs(9) = mxCreateFull(NRMAP,1,0)
      QPSI_pr = mxGetPr(plhs(9))
      call mxCopyReal8ToPtr(QPSI,QPSI_pr,NRMAP)
C Flux poloidal (le meme qu'en entree)
      plhs(10) = mxCreateFull(NRMAP,1,0)
      PSIPOUT_pr = mxGetPr(plhs(10))
      call mxCopyReal8ToPtr(PSIPOUT,PSIPOUT_pr,NRMAP)
C ftra : fraction de piegees            
      plhs(11) = mxCreateFull(NRMAP,1,0)
      FTRA_pr = mxGetPr(plhs(11))
      call mxCopyReal8ToPtr(FTRA,FTRA_pr,NRMAP)
C Fdia : fonction diamagnetique
      plhs(12) = mxCreateFull(NRMAP,1,0)
      FDIA_pr = mxGetPr(plhs(12))
      call mxCopyReal8ToPtr(FDIA,FDIA_pr,NRMAP)
C Flux toroidal
      plhs(13) = mxCreateFull(NRMAP,1,0)
      PSIT_pr = mxGetPr(plhs(13))
      call mxCopyReal8ToPtr(PSIT,PSIT_pr,NRMAP)
C B2 : moyenne de B^2 sur une surface de flux
      plhs(14) = mxCreateFull(NRMAP,1,0)
      B2_pr = mxGetPr(plhs(14))
      call mxCopyReal8ToPtr(B2,B2_pr,NRMAP)
C invB2 : moyenne de l'inverse de B^2 sur une surface de flux
      plhs(15) = mxCreateFull(NRMAP,1,0)
      INVB2_pr = mxGetPr(plhs(15))
      call mxCopyReal8ToPtr(INVB2,INVB2_pr,NRMAP)
C Sp : element de surface
      plhs(16) = mxCreateFull(NRMAP,1,0)
      SP_pr = mxGetPr(plhs(16))
      call mxCopyReal8ToPtr(SP,SP_pr,NRMAP)
C RAV : <R>
      plhs(17) = mxCreateFull(NRMAP,1,0)
      RAV_pr = mxGetPr(plhs(17))
      call mxCopyReal8ToPtr(RAV,RAV_pr,NRMAP)
C OOR / <1/R>
      plhs(18) = mxCreateFull(NRMAP,1,0)
      OOR_pr = mxGetPr(plhs(18))
      call mxCopyReal8ToPtr(OOR,OOR_pr,NRMAP)
C DRHOAV : <abs(grad(rho))>
      plhs(19) = mxCreateFull(NRMAP,1,0)
      DRHOAV_pr = mxGetPr(plhs(19))
      call mxCopyReal8ToPtr(DRHOAV,DRHOAV_pr,NRMAP)
C XSHIFT : element d'ordre 0 de la serie de Fourier R(theta)
      plhs(20) = mxCreateFull(NRMAP,1,0)
      XSHIFT_pr = mxGetPr(plhs(20))
      call mxCopyReal8ToPtr(XSHIFT,XSHIFT_pr,NRMAP)
C XRAD : petit rayon geometrique
      plhs(21) = mxCreateFull(NRMAP,1,0)
      XRAD_pr = mxGetPr(plhs(21))
      call mxCopyReal8ToPtr(XRAD,XRAD_pr,NRMAP)
C XELL : ellipticite
      plhs(22) = mxCreateFull(NRMAP,1,0)
      XELL_pr = mxGetPr(plhs(22))
      call mxCopyReal8ToPtr(XELL,XELL_pr,NRMAP)      
C XTRIAPOS : triangularite partie superieure (Z>0)
      plhs(23) = mxCreateFull(NRMAP,1,0)
      XTRIAPOS_pr = mxGetPr(plhs(23))
      call mxCopyReal8ToPtr(XTRIAPOS,XTRIAPOS_pr,NRMAP)
C XTRIANEG : triangularite partie inferieure (Z<0)
      plhs(24) = mxCreateFull(NRMAP,1,0)
      XTRIANEG_pr = mxGetPr(plhs(24))
      call mxCopyReal8ToPtr(XTRIANEG,XTRIANEG_pr,NRMAP)
C Jout : densite de courant recalculee d'apres l'equilibre trouve
      plhs(25) = mxCreateFull(NRMAP,1,0)
      Jout_pr = mxGetPr(plhs(25))
      call mxCopyReal8ToPtr(Jout,Jout_pr,NRMAP)
C Iout : courant total
      plhs(26) = mxCreateFull(1,1,0)
      XIAB_pr = mxGetPr(plhs(26))
      call mxCopyReal8ToPtr(XIAB,XIAB_pr,1)
C Pout : pression recalculee d'apres l'equilibre trouve
      plhs(27) = mxCreateFull(NRMAP,1,0)
      Pout_pr = mxGetPr(plhs(27))
      call mxCopyReal8ToPtr(Pout,Pout_pr,NRMAP)
C R2 : <R^2>
      plhs(28) = mxCreateFull(NRMAP,1,0)
      R2_pr = mxGetPr(plhs(28))
      call mxCopyReal8ToPtr(R2,R2_pr,NRMAP)
C OOR2 : <1/R2>
      plhs(29) = mxCreateFull(NRMAP,1,0)
      OOR2_pr = mxGetPr(plhs(29))
      call mxCopyReal8ToPtr(OOR2,OOR2_pr,NRMAP)
C R2TAU2 : <R^2/tau^2>
      plhs(30) = mxCreateFull(NRMAP,1,0)
      R2TAU2_pr = mxGetPr(plhs(30))
      call mxCopyReal8ToPtr(R2TAU2,R2TAU2_pr,NRMAP)
C DRHO2OB2 : < |gradient(rho)|^2/B^2 >
      plhs(31) = mxCreateFull(NRMAP,1,0)
      DRHO2OB2_pr = mxGetPr(plhs(31))
      call mxCopyReal8ToPtr(DRHO2OB2,DRHO2OB2_pr,NRMAP)
C R3OTAU3 : <R^3/tau^3>
      plhs(32) = mxCreateFull(NRMAP,1,0)
      R3OTAU3_pr = mxGetPr(plhs(32))
      call mxCopyReal8ToPtr(R3OTAU3,R3OTAU3_pr,NRMAP)
C R3OTAU : <R^3/tau>
      plhs(33) = mxCreateFull(NRMAP,1,0)
      R3OTAU_pr = mxGetPr(plhs(33))
      call mxCopyReal8ToPtr(R3OTAU,R3OTAU_pr,NRMAP)
C BPR : Champ magnetique
      plhs(34) = mxCreateFull(NRMAP,NPMAP,0)
      BPR_pr    = mxGetPr(plhs(34))
      call mxCopyReal8ToPtr(BPR,BPR_pr,sizeOUT) 
C BPZ : Champ magnetique
      plhs(35) = mxCreateFull(NRMAP,NPMAP,0)
      BPZ_pr    = mxGetPr(plhs(35))
      call mxCopyReal8ToPtr(BPZ,BPZ_pr,sizeout)
C b : parametre de calcul de l'equilibre final
      plhs(36) = mxCreateFull(1,1,0)
      b_pr    = mxGetPr(plhs(36))
      call mxCopyReal8ToPtr(B,b_pr,1)
C df2 : parametre de calcul de l'equilibre final
      plhs(37) = mxCreateFull(101,1,0)
      df2_pr    = mxGetPr(plhs(37))
      call mxCopyReal8ToPtr(DF2,df2_pr,101)
C kkbig : matrice des elements finis
      plhs(38) = mxCreateFull(KKLDA,4*MAXNODE,0)
      kkbig_pr    = mxGetPr(plhs(38))
      call mxCopyReal8ToPtr(KKBIG,kkbig_pr,KKLDA*4*MAXNODE)             
C XLI : self
      plhs(39) = mxCreateFull(1,1,0)
      XLI_pr = mxGetPr(plhs(39))
      call mxCopyReal8ToPtr(XLI,XLI_pr,1)
C DIMERC : ideal Mercier criterion
      plhs(40) = mxCreateFull(NRMAP,1,0)
      DIMERC_pr = mxGetPr(plhs(40))
      call mxCopyReal8ToPtr(DIMERC,DIMERC_pr,NRMAP)
C DIMERC : resistive Mercier criterion
      plhs(41) = mxCreateFull(NRMAP,1,0)
      DRMERC_pr = mxGetPr(plhs(41))
      call mxCopyReal8ToPtr(DRMERC,DRMERC_pr,NRMAP)
C BALCRIT : Ballooning stability criterion
      plhs(42) = mxCreateFull(NRMAP,1,0)
      BALCRIT_pr = mxGetPr(plhs(42))
      call mxCopyReal8ToPtr(BALCRIT,BALCRIT_pr,NRMAP)
C IFAIL : code d'erreur
      plhs(43) = mxCreateFull(1,1,0)
      IFAIL_pr = mxGetPr(plhs(43))
      RIFAIL=REAL(IFAIL)
      call mxCopyReal8ToPtr(RIFAIL,IFAIL_pr,1)
     
      return
      END
                                                                   
************************************************************************
      SUBROUTINE HELENA(PSIN,PIN,ZJIN,NPRFL,INI,AMIN,R0,B0,XI,      
     >                  C2,C3,R2M,RR,ZZ,RHO,VP,DRHOOR,QPSI,PSIP,           
     >                  FTRA,FDIA,PSIT,B2,INVB2,SP,AVC,RAV,OOR,DRHOAV,
     >                  XRAD,XSHIFT,XELL,XTRIAPOS,XTRIANEG,ZP0,
     >                  R2,OOR2,R2OTAU2,DRHO2OB2,R3OTAU3,R3OTAU,
     >                  BPR,BPZ,Rext,Zext,NBext,XLI,DIMERC,DRMERC,
     >                  BALCRIT,IFAIL,ecrit)        
C-----------------------------------------------------------------------
C                                                                       
C MAIN PROGRAM HELENA :        (VERSION 12small  DATE 25-01-2000)       
C ---------------------                                                 
C      - SOLVES THE 2D GRAD-SHAFRANOV EQUATION FOR  ARBITRARY UP/DOWN   
C        SYMMETRIC CONTINUOUS PLASMA BOUNDARIES AND EQUILIBRIUM PRESSURE
C        AND GAMMA PROFILES.                                            
C      - 2D CUBIC ISOPARAMETRIC FINITE ELEMENTS ARE USED FOR AN ACCURATE
C        REPRESENTATION OF THE SOLUTION.                                
C      - THE FINAL SOLUTION IS OBTAINED AN A FLUXSURFACE GRID.          
C                                                                       
C                                                                       
C AUTHOR : G. HUYSMANS                                                  
C                                                                       
C-----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026, KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)
      PARAMETER (NPSIMAX=NRMMAX, NCHIMAX=1026)                             
      PARAMETER (NPNC=NPSIMAX*NCHIMAX, NP4=4*NPSIMAX)                   
                                         
C-----------------------------------------------------------------------
      COMMON / COMDAT/                                                  
     >        ELLIP,TRIAH,TRIAB,QUAD,PAR1,PAR2,PAR3,PAR4,                      
     >        AGA,BGA,CGA,DGA,EGA,FGA,GGA,HGA,                          
     >        API,BPI,CPI,DPI,EPI,FPI,GPI,HPI,                          
     >        ACUR,BCUR,CCUR,DCUR,ECUR,FCUR,GCUR,HCUR,                  
     >        ERRIT,ERRCUR,EPS,ALFA,B,C,XIAB,Q95,BETAP,AMIX,BMIX,       
     >        ABB, BBB, AMPL, RVAC,BVAC,ZEFF,ZN0,RPE,XR1,SIG1,          
     >        IAS,ICUR,NRCUR,NPCUR,NMESH,INIMESH,NBB,NQB,IARC,          
     >        MHARM,ISHAPE,ISOL,IGAM,IPAI,NR,NP,NRMAP,NPMAP,NITER       
      real*8    ELLIP,TRIAH,TRIAB,QUAD,PAR1,PAR2,PAR3,PAR4,                      
     >        AGA,BGA,CGA,DGA,EGA,FGA,GGA,HGA,                          
     >        API,BPI,CPI,DPI,EPI,FPI,GPI,HPI,                          
     >        ACUR,BCUR,CCUR,DCUR,ECUR,FCUR,GCUR,HCUR,                  
     >        ERRIT,ERRCUR,EPS,ALFA,B,C,XIAB,Q95,BETAP,AMIX,BMIX,       
     >        ABB, BBB, AMPL, RVAC,BVAC,ZEFF,ZN0,RPE,XR1,SIG1           
      integer IAS,ICUR,NRCUR,NPCUR,NMESH,INIMESH,NBB,NQB,IARC,          
     >        MHARM,ISHAPE,ISOL,IGAM,IPAI,NR,NP,NRMAP,NPMAP,NITER       
C-----------------------------------------------------------------------
      COMMON /CORNERS/ RS, IJ, NODENO                                   
      real*8    RS(4,2)                                                   
      integer IJ(4,2), NODENO(MAXMNODE,4)                               
C-----------------------------------------------------------------------
      COMMON/COMPROF/DPR,DF2,ZJZ,QIN,DPRES,DGAM,PINT,GINT,NPTS          
      real*8    DPR(NPTSMAX),DF2(NPTSMAX),ZJZ(NPTSMAX),QIN(NPTSMAX),      
     >        DPRES(1001),DGAM(1001),PINT(1001),GINT(1001)              
      integer NPTS                                                      
C-----------------------------------------------------------------------
      COMMON/TOLERA/PSITOL,THTTOL,TOL                                   
      real*8    PSITOL,THTTOL,TOL                                         
C-----------------------------------------------------------------------
      COMMON/MESH2/XXOLD,YYOLD,PSIOLD                                   
      real*8    XXOLD(4,MAXNODE),YYOLD(4,MAXNODE),PSIOLD(4*MAXNODE)       
C-----------------------------------------------------------------------
      COMMON/FAXIS/PSI,NAXIS                                            
      real*8    PSI(4*MAXMNODE)                                           
      integer NAXIS                                                     
C-----------------------------------------------------------------------
      COMMON/COMSOLV/KKBIG                                              
      real*8 KKBIG(KKLDA,4*MAXNODE)                                       
c      real*8, ALLOCATABLE :: KKBIG(:,:)                                  
c      integer KKLDA                                                    
C-----------------------------------------------------------------------
      COMMON /COMMAP/CS,QS,DQS,CURJ,CHI,   
     >     GEM11,GEM12,GEM33,  
     >     CHIKN,P0,RBPHI,
     >     DP,DRBPHI,
     >     DQEC,DJ0,DJE,CPSURF,RADIUS,RAXIS,DP0,DPE,DRBPHI0,DRBPHIE,
     >     JS0,NCHI,NPSI,NLTORE

      REAL*8 CS(NRMMAX),QS(NRMMAX),DQS(NRMMAX),CURJ(NRMMAX),CHI(NPMMAX),   
     >     GEM11(MAXMNODE),GEM12(MAXMNODE),GEM33(MAXMNODE),  
     >     CHIKN(NPMMAX),P0(NRMMAX),RBPHI(NRMMAX),
     >     DP(NRMMAX),DRBPHI(NRMMAX),
     >     DQEC,DJ0,DJE,CPSURF,RADIUS,RAXIS,DP0,DPE,DRBPHI0,DRBPHIE   
      INTEGER JS0,NCHI,NPSI
      LOGICAL NLTORE  
C-----------------------------------------------------------------------
      common / COMB02 / B02,DTB02 , DSB02
      REAL*8    B02(NPNC), DTB02(NPNC), DSB02(NPNC)
C-----------------------------------------------------------------------
      common / COMPQ / CP0, CP1, CP2, CQ0, CQ1, NCPQ
      REAL*8    CP0(NPNC),CP1(NPNC),CP2(NPNC),CQ0(NPNC),CQ1(NPNC)
      INTEGER NCPQ
C-----------------------------------------------------------------------
      common / COMNAM / QAXIS,TBB,TBF
      REAL*8     QAXIS,TBB,TBF
C-----------------------------------------------------------------------
      COMMON / COMPIE/ PI                                               
      real*8 PI                                                           
C-----------------------------------------------------------------------
      COMMON / COMSPL /                                                 
     R         Q1(NPSIMAX), Q2(NPSIMAX), Q3(NPSIMAX), Q4(NPSIMAX),      
     R         P1(NPSIMAX), P2(NPSIMAX), P3(NPSIMAX), P4(NPSIMAX),      
     R         RBP1(NPSIMAX), RBP2(NPSIMAX), RBP3(NPSIMAX),             
     R         RBP4(NPSIMAX)                                            
                                                                       
      REAL*8     Q1, Q2, Q3, Q4,                          
     >         P1, P2, P3, P4, RBP1, RBP2, RBP3, RBP4                  
C-----------------------------------------------------------------------

      real*8 XX(4,MAXMNODE),YY(4,MAXMNODE),FR(2*MBMAX+2)                  
      real*8 QQ(4*MAXNODE),DIAG(4*MAXNODE)                                
      real*8 PSPLOT(101),DPPLOT(101),DGPLOT(101),ZJPLOT(101),QPLOT(101)   
      real*8 DF2OLD(NPTSMAX),FM(MBMAX)                                    
      real*8 FCIRC(NRMMAX),B0MAX(NRMMAX),RAV(NRMMAX)                      
      real*8 DRMERC(NRMMAX),DIMERC(NRMMAX),HH(NRMMAX),QPROF(NRMMAX)       
      real*8 DQPROF(NRMMAX),GEONC(NRMMAX),ZJPAR(NRMMAX)                   
      real*8 DUMMY1(NRMMAX),DUMMY2(NRMMAX)                                
      real*8 ZJJ1(NRMMAX),ZJJ2(NRMMAX),ZJJ3(NRMMAX),ZJJ4(NRMMAX)          
      real*8 ZJJ5(NRMMAX),ZJJ6(NRMMAX),ZJJ7(NRMMAX),ZJJ12(NRMMAX)                       
      real*8 ZJJ8(NRMMAX),ZJJ9(NRMMAX),ZJJ10(NRMMAX),ZJJ11(NRMMAX)
      real*8 ZJJ13(NRMMAX),ZJJ14(NRMMAX),ZJJ15(NRMMAX)
      real*8 ZJJ16(NRMMAX),ZJJ17(NRMMAX),BALCRIT(NRMMAX)                                                   
      real*8 ZQ(NRMMAX),ZAREA(NRMMAX),ZVOL(NRMMAX),OOR(NRMMAX)
      real*8 DRHOAV(NRMMAX),AVC(NRMMAX),DRHOOR(NRMMAX)
      real*8 ZCUR(NRMMAX),ZP0(NRMMAX),ZFF(NRMMAX),TMP(NRMMAX)             
      real*8 VP(*),C2(*),C3(*),R2M(*),RHO(*),FTRA(*),FDIA(*),INVB2(*)     
      real*8 TAU(NRMMAX),QPSI(*),SP(*),PSIP(*),PSIT(*),B2(*)         
      real*8 PSIN(*),PIN(*),ZJIN(*),ABLTG(3),Rext(*),Zext(*)                 
      real*8 XSHIFT(*),XRAD(*),XTRIAPOS(*),XTRIANEG(*),XELL(*)
      real*8 R2(*),OOR2(*),R2OTAU2(*),DRHO2OB2(*),R3OTAU3(*),R3OTAU(*)
      real*8 RR(NRMMAX,NPMMAX),ZZ(NRMMAX,NPMMAX),BPR(NRMMAX,NPMMAX)
      real*8 BPZ(NRMMAX,NPMMAX)                                     
      real*8 S1(101),S2(101),S3(101),S4(101)
      real*8 ecrit
                                                                                         
      CALL INIVAL                                                
      IF (INI.EQ.0) THEN
         B = 0.002D0                                                          
      ENDIF
      
      IFAIL = 999
      IWRT = INT(ecrit)
      if (IWRT.GE.1)  then
      	IWRT = 1
	AMIX = 0.9
	NITER = 1000
      endif
            
      PSI0 = PSIN(1)
      DO I=1,NPRFL
        PSIN(I) = PSIN(I) - PSI0
      ENDDO

c      NBEXT = 33
      MF    = 128
      IF (IWRT.NE.0) WRITE(*,*) ' Point wise boundary : ',NBEXT
      IF (IWRT.NE.0) then
        DO I=1,NPRFL
          WRITE(*,*) 'I= ',I,' PSI =',PSIN(I)
	ENDDO
      ENDIF
      IF (NBext.GT.0) THEN
        CALL FBND(Rext,Zext,NBext-1,FR,MF,AMIN,R0)
      ENDIF
                        
      EPS = AMIN/R0                                                                                                            
      BETAP = PIN(1) * 1.6022D-16 * 12.56637D-7 / B0**2                 
      XIAB = 12.56637D-7 * XI / (AMIN * B0)                             
      ALFA =  2.*PI* AMIN**2 * B0 / DABS(PSIN(NPRFL))
      
      IF (IWRT.NE.0) THEN
         WRITE(*,*) ' IAS   : ',IAS
         WRITE(*,*) ' AMIN  : ',AMIN
	 WRITE(*,*) ' B0    : ',B0
	 WRITE(*,*) ' XI    : ',XI
	 WRITE(*,*) ' PSI(1): ',PSIN(NPRFL)
	 WRITE(*,*) ' XTRIA(TOP) : ',TRIAH
	 WRITE(*,*) ' XTRIA(BOT) : ',TRIAB
	 WRITE(*,*) ' ALFA  : ',ALFA
      ENDIF
      IF (INI.EQ.1) WRITE(*,*) ' B(prev) : ',B

c------------------------ quadratic extraolation to axis
      dp3 = (pin(4)-pin(3))/(psin(4)-psin(3))
      pin(1)=pin(3)+(psin(1)-psin(3))*dp3
      pin(2)=pin(3)+(psin(2)-psin(3))*dp3
      
      CALL SPLINE(NPRFL,PSIN,PIN,0.D0,0.D0,2,S1,S2,S3,S4)                   
      NPTS=101                                                          
      PSIB = DABS(PSIN(NPRFL))                                           
      DO I=1,NPTS   
        SS =  dble(I-1)/dble(NPTS-1)                                                   
        FI = PSIB * SS*SS                        
        TMP1 = SPWERT(NPRFL,FI,S1,S2,S3,S4,PSIN,ABLTG)                   
        DPR(I) = ABLTG(1)
      ENDDO                                                             
                                                                        
      CALL SPLINE(NPRFL,PSIN,ZJIN,0.D0,0.D0,2,S1,S2,S3,S4)                  
      NPTS=101                                                          
      DO I=1,NPTS                                                       
        SS =  dble(I-1)/dble(NPTS-1)                                                   
        FI = PSIB * SS*SS                
        ZJZ(I) = SPWERT(NPRFL,FI,S1,S2,S3,S4,PSIN,ABLTG)
        IF (INI.EQ.0) THEN               
           DF2(I) = 1. - FI/PSIB                                           
c           DF2(I) = DPR(I)                                           
        ENDIF        
      ENDDO       
                                                                              
C------------------------------------------ALLOCATE LARGE MATRIX        
      IF ((NR.GT.NRMAX).OR.(NP.GT.NPMAX)) THEN                          
        WRITE(*,*) ' NR or NP too large, NRMAX =',NRMAX,' NPMAX=',NPMAX 
        CALL mexErrMsgTxt(' NR or NP too large')                                                            
      ENDIF                                                             
c-90      KKLDA = 4*NP+9                                                
                                                                        
c-90      ALLOCATE(KKBIG(KKLDA,4*(NR+2)*NP))                            
                                                                        
C-------------------------------- INITIALIZE INTERPOLATING FUNCTIONS ---
      CALL GAUSS                                            
C------------------------------------ PLASMA BOUNDARY IN FOURIER SERIES 
      IF (NBEXT.LE.0) CALL FSHAPE(FR,MHARM)
C------------------------------------ NORMALIZE PROFILES ---------------
      FSCALE = DF2(1)                                                   
      PSCALE = DPR(1)                                                   
      CSCALE = ZJZ(1)                                                   
      DO I=1,NPTS                                                       
        DF2(I) = DF2(I) / FSCALE                                        
        DPR(I) = DPR(I) / PSCALE                                        
        ZJZ(I) = ZJZ(I) / CSCALE                                        
      ENDDO  
      ZMAXDPR = DPR(1)
      DO I=2,NPTS
        IF (ABS(DPR(I)).GT.ZMAXDPR ) THEN
	  ZMAXDPR = ABS(DPR(I))
	ENDIF
      ENDDO
   
      IF (INI.EQ.0) THEN
        IF (ZMAXDPR.GT.100.0) THEN
           B = .2/ZMAXDPR    
	ENDIF                                                     
      ENDIF
                                   
      IF (INI.EQ.0) THEN
        B = - B * PSCALE/DABS(PSCALE)
      ENDIF
C-------------------------------- INITIAL GUESS FOR A ------------------
      A = 4.D0 * B/DABS(B)                          
C--------------------------------- INITIALIZE PRES AND GAM PROFILES ----
      CALL INIPRES                                                      
      CALL INIGAM                                                       
      IF (IWRT.NE.0) THEN
      WRITE(*,*) '***********************************************'     
      WRITE(*,*) '*        INPUT PROFILES :                     *'     
      WRITE(*,*) '***********************************************'     
      WRITE(*,*) '*  PSI,       dP/dPSI,     Gamma,       J_phi *'     
      WRITE(*,*) '***********************************************'     
      DO I=1,101                                                         
          PS = dble(I-1)*0.01D0                                               
          PSPLOT(I) = PS                                                
          DPPLOT(I) = DPDPSI(PS)                                        
          DGPLOT(I) = DGDPSI(PS)                                        
          ZJPLOT(I) = CURPHI(PS)                                        
          WRITE(*,622) PS,DPPLOT(I),DGPLOT(I),ZJPLOT(I)             
      ENDDO
      ENDIF
                                                                        
  622 FORMAT(4E12.4)                                                    
C------------------------------------ DEFINE NUMBERING OF ELEMENTS ---- 
      CALL ELMNO(NR,NP,NODENO)                                          
                                                                        
C------------------------------------ DEFINE INITIAL GRID X,Y --------- 
      CALL INIGRID(XX,YY,PSI,NR,NP,FR,MHARM,INIMESH,IAS,IARC,XR1,SIG1)  
C----------------------------------- START OF LOOP OVER CURRENT/BETA--- 
      DO 888 NMG = 1,NMESH  
        IF (IWRT.NE.0) THEN                                            
        WRITE(*,*) '***************************************'           
        WRITE(*,21) NMG                                                
        WRITE(*,*) '***************************************'   
	ENDIF        
   21   FORMAT(' * ITERATION CURRENT PROFILE,  NMG=',I3,'  *')          
                                                                        
        NIT=NITER                                                       
C------------------------------------ LOOP OVER GS EQUATION ------------
        DO 10 NI = 1, NIT  
          DO J=1,4*NR*NP                                                
            QQ(J) = 0.D0                                                  
          ENDDO                                                         
C------------------------------------ INITIALIZE KK AND QQ TO ZERO -----
          DO I=1,4*NR*NP                                                
             PSIOLD(I) = PSI(I)                                         
          ENDDO   

          IF (INI.EQ.0) THEN
C------------------------------------ FORM MATRIX, NO CONDITIONS -------
          CALL FORMKQ(XX,YY,PSI,NR,NP,QQ,A,B,C,EPS,IGAM,ISOL,NI*NMG,IAS)
C------------------------------------ SOLVE SET OF EQUATIONS -----------
          CALL SOLVE2(QQ,NR,NP,PSI,NI*NMG,IAS)
          ELSE
          CALL FORMKQ(XX,YY,PSI,NR,NP,QQ,A,B,C,EPS,IGAM,ISOL,0,IAS)
          CALL SOLVE2(QQ,NR,NP,PSI,0,IAS)
          ENDIF
C------------------------------------ FIND MAGN. AXIS AND PSI AT AXIS --
          CALL FINDAXIS(XX,YY,NR,NP,PSAXIS,XAXIS,YAXIS,
     >                  NAX,RAX,SAX,IAS,IFAIL) 
c          IF (IWRT.NE.0) WRITE(*,*) 'MAGN. AXIS : ',XAXIS,YAXIS
           A = A / (1.-PSAXIS)   
C------------------------------------ NORMALIZE FLUX TO ZERO ON AXIS ---
	  IF (IFAIL.NE.0) THEN
	    WRITE(*,*) ' AXIS NOT FOUND'
	    RETURN
	  ENDIF
	  CALL NORMAL(PSI,NR,NP,PSAXIS) 
	  IF (AMIX.NE.0.) THEN
            DO  I=1,4*NR*NP
              PSI(I) = (1.- AMIX)*PSI(I) + AMIX*PSIOLD(I)
            ENDDO
           CALL FINDAXIS(XX,YY,NR,NP,PSAXIS,XAXIS,YAXIS,
     >                   NAX,RAX,SAX,IAS,IFAIL)
	    IF (IFAIL.NE.0) THEN
	      WRITE(*,*) ' AXIS NOT FOUND'
	      RETURN
	    ENDIF
            AOLD = A
            A = A / (1.-PSAXIS)
            CALL NORMAL(PSI,NR,NP,PSAXIS)
          ENDIF  

          ERR1 = 0.                                                     
          DO I=1,NR*NP                                                  
            NBASE = 4*(I-1)+1                                           
            ERR1 = ERR1 + DABS(PSI(NBASE)  - PSIOLD(NBASE))              
          ENDDO                                                         
          ERR1 = ERR1 / dble(NR*NP)                                    
          IF (ERR1.LT.ERRIT) GOTO 777                                   
   10   CONTINUE                                                        
c-----------------------------------------------------------------------
  777   CONTINUE                                                        
        IF (IWRT.NE.0)         WRITE(*,*) ERR1,NI                                            
c        AMIX = 0.
        IF (ERR1.GT.ERRIT) AMIX = 0.6
        IF (NMG.EQ.NMESH) GOTO 999                                      
                                                                        
C------------------------------------- CALC. NEW FF' PROFILE            
        CALL REMESH(XX,YY,PSI,A,B,C,EPS,NR,NP,NR,NP,MESHNO,             
     >              CX,CY,XAXIS,YAXIS,NAX,RAX,SAX,IGAM,IAS,IFAIL)
        IF (IFAIL.NE.0) RETURN
        DO I = 1, NPTS                                                  
          DF2OLD(I) = DF2(I)                                            
        ENDDO        
C-------------------------------- update FF' based on current profile   
        CALL FLXINT(XAXIS,XX,YY,PSI,NR,NP,A,B,C,EPS,ALFA,IGAM,ISOL,IAS) 

C-------------------------------- use current only when positive
        IF (XIAB.GT.0.) THEN
          CALL CURRENT(XX,YY,PSI,NR,NP,A,B,C,EPS,ALFA,IGAM,ISOL,CUR,IAS)
	  ALFA = ALFA * CUR / XIAB                                        
          IF (IWRT.NE.0) WRITE(*,*) ' ALFA = ',ALFA
        ENDIF
	
	                                                                
        CALL PROFILES(ZP0,ZFF,DUMMY1,DUMMY2,A)                          
        PAXIS=ZP0(1) * EPS / ALFA**2                                    
        IF ((BETAP.GE.0).AND.(DABS(PAXIS-BETAP).GT.0.001*PAXIS)) THEN   
          IF (NMG.EQ.NBB) THEN                                          
            B1 = B                                                      
            BP1 = PAXIS                                                 
            IF (B.LT.0.) THEN                                           
              IF (PAXIS .GT. BETAP) THEN                                
                B = 1.02*B1                                             
              ELSE                                                      
                B = 0.98*B1                                             
              ENDIF                                                     
ccc             B =  PAXIS /(BBB * BETAP) * B1                          
            ELSE                                                        
              B =   B1 / PAXIS * BETAP                                  
            ENDIF      
	    IF (IWRT.NE.0) THEN                                                                                             
              WRITE(*,'(A18,2f10.5,A4,f10.5)') 'first change of B ',    
     >                               B1,PAXIS,' >> ',B   
            ENDIF               
          ELSE                                                          
                                                                        
            IF (MOD(NMG,NBB).EQ.0) THEN                                 
              BOLD = B                                                  
              DELTAB = (B1-BOLD)/(BP1-PAXIS) * (BETAP-PAXIS)            
              IF (DABS(DELTAB/BOLD) .gt. AMPL) THEN                       
                B = BOLD + BBB*DELTAB/DABS(DELTAB)*ABS(BOLD)             
              ELSE                                                      
                B = BOLD + ABB*(B1-BOLD)/(BP1-PAXIS) * (BETAP-PAXIS)    
              ENDIF                                                     
              IF (IWRT.NE.0) THEN                                                                                             
              WRITE(*,'(A17,4f10.5,A4,f10.5)') 'next change of B ',     
     >                                BOLD,PAXIS,B1,BP1,' >> ',B   
              ENDIF     
              B1 = BOLD                                                 
              BP1 = PAXIS                                               
            ENDIF                                                       
          ENDIF                                                         
        ENDIF                                                           
                                                                        
        DIFDF2 = 0.                                                     
        DO I = 1, NPTS                              
          DIFDF2 = DIFDF2 + DABS(DF2(I) - DF2OLD(I))                     
        ENDDO                                                           
        IF (IWRT.NE.0) WRITE(*,711) NMG,DIFDF2,B,PAXIS                                 
 711    FORMAT(' ITERATION : ',I3,' DIFF : ',1PE10.2,0P2f10.5,1PE10.2)  
                                                                        
        DO I = 1, NR*NP                                                 
          DO K = 1, 4                                                   
             XX(K,I) = XXOLD(K,I)                                       
             YY(K,I) = YYOLD(K,I)                                       
             PSI(4*(I-1)+K) = PSIOLD(4*(I-1)+K)                         
          ENDDO                                                         
        ENDDO                                                           
                                                                        
        IF (((DIFDF2.LT.ERRCUR).AND.(DABS(PAXIS-BETAP).LT.0.001*PAXIS))  
     >          .OR.(NMG.EQ.NMESH-1)) THEN
           IFAIL = 0
	   GOTO 999 
	ENDIF
                                                                        
        CALL INIGAM                                                     
                                                                        
 888  CONTINUE                                                          
 999  CONTINUE                                                          
c-90      DEALLOCATE(KKBIG)                                             
              
      CALL CURRENT(XX,YY,PSI,NR,NP,A,B,C,EPS,ALFA,IGAM,ISOL,XIAB,IAS)
      IF (IWRT.NE.0) WRITE(*,*) ' TOTAL CURRENT : ',XIAB,ALFA
	                                                                
      CALL REMESH(XX,YY,PSI,A,B,C,EPS,NR,NP,NRMAP,NPMAP,MESHNO,         
     >              CX,CY,XAXIS,YAXIS,NAX,RAX,SAX,IGAM,IAS,IFAIL)             
      IF (IFAIL.NE.0) RETURN
                                                                              
      CALL DIAGNO(XX,YY,PSI,NR,NP,A,B,C,EPS,ALFA,IAS,IGAM,XAXIS,        
     >            ZJJ1,ZJJ2,ZJJ3,ZJJ4,ZJJ5,ZJJ6,ZJJ7,ZJJ8,ZJJ9,ZJJ10,   
     >            ZJJ11,ZJJ12,ZJJ13,ZJJ14,ZJJ15,ZJJ16,ZJJ17,
     >            PSIT,B2,INVB2,QPSI,ZAREA,ZVOL,ZCUR,ZP0,ZFF,AVC,XLI,
     >            DIMERC,DRMERC)          
                                                                        
      CALL CIRCUL(XX,YY,PSI,NR,NP,A,B,C,EPS,ALFA,IGAM,IAS,              
     >            FCIRC,TMP,B0MAX,RAV)                                  

      CALL TRIANG(XX,YY,XAXIS,NR,NP,XSHIFT,XRAD,XELL,XTRIAPOS,XTRIANEG
     >            ,IAS)


C Added 17/09/03 for calculation of Ballooning and Mercier criteria
C-------------------------------------- MAPPING OF FLUX COORDINATES ----
C
c      write (*,*) 'Start Mapping'
      CALL MAPPING(XX,YY,PSI,CX,CY,XAXIS,A)
c      write (*,*) 'End of Mapping'
C
C--------------------------------------- CALC. BALLOONING STABILITY -----
C
c     En fait, le critere de Mercier est calcule au dessus, dans DIAGNO
c      CALL MERCIER(XX,YY,PSI,NR,NP,A,B,C,EPS,ALFA,IGAM,IAS,
c     >             DIMERC,DRMERC,HH,QPROF,DQPROF,GEONC,ZJPAR)

c      write (*,*) 'Start HELBAL'
      CALL HELBAL(ZVOL,ZJJ5,XAXIS,BALCRIT)
c      write (*,*) 'End of HELBAL'

c-------------------------------------- undo normalisation -------------
      PI = 2.D0*DASIN(1.D0)                                                  
      ZMU0 = 4D-7*PI                                                    
      ZE   = 1.6022D-19                                                 
      PSCALE  = B0**2 / ZMU0                                            
      RBSCALE = B0 * R0                                                 
      RADIUS  = EPS * R0                                                
      CPSURF  = DABS(RADIUS**2 * B0 / ALFA)                                   
      CTSURF  = PSIT(NR) * R0*R0*B0                                     

                           
      DO I = 1,NRMAP     
        
        XSHIFT(I) = XSHIFT(I) * RADIUS
        XRAD(I) = XRAD(I) * RADIUS
                                                        
        PS = PSI(4*(NRMAP-I)*NPMAP + 1)                                       
        PSIP(I) = 2. * PI * PS * CPSURF                                 
                                                                        
        SPS2 = 2.*CPSURF*DSQRT(DABS(PS))                                       
c        ancienne normalisation de RHO                                                                        
c        RHO(I) = DSQRT(DABS(PSIT(I)/PSIT(NR))) * RADIUS                        
                                                                       
        ZP0(I) = ZP0(I) * PSCALE / 1.6D-16                                       
        FDIA(I) = ZFF(I) * RBSCALE                                      
        PSIT(I) = PSIT(I) * R0*R0*B0
        RHO(I) = DSQRT(DABS(PSIT(I))/PI/B0)                                   
        ZVOL(I) = ZVOL(I)  * R0**3                                      
        ZAREA(I)= ZAREA(I) * R0**2                                      
        ZCUR(I) = ZCUR(I)  * B0 * R0 / ZMU0                    
                                                                        
        B2(I) = B2(I) * B0*B0                                           
        INVB2(I) = INVB2(I) / (B0*B0)       
                                    
c       pour l'ancienne normalisation de RHO                                                                        
c        DPSIDRHO = 2.* RHO(I) * CTSURF / (QPSI(I) * RADIUS**2)          
        DPSIDRHO = 2.D0 * RHO(I) * PI * B0 / QPSI(I)          
                                                                       
        VP(I)   = ZJJ5(I) * DPSIDRHO * R0/B0   *  2.D0*PI                 
        SP(I)   = ZJJ8(I) * DPSIDRHO / B0                               
        C2(I)   = ZJJ6(I) / DPSIDRHO * (R0*B0) * (2.D0*PI)**3             
        C3(I)   = ZJJ4(I) * DPSIDRHO / (R0*B0) *  2.D0*PI                 
        R2M(I)  = ZJJ7(I) / (ZJJ5(I) * DPSIDRHO**2) * (2.D0*PI*R0*B0)**2  
        OOR(I)  = ZJJ8(I)    / ZJJ5(I) / R0
        OOR2(I) = ZJJ4(I) / ZJJ5(I) / R0**2
	RAV(I)  = ZJJ10(I)   / ZJJ5(I) * R0
	DRHOAV(I) = ZJJ9(I)  / ZJJ5(I) / DPSIDRHO * (2.D0*PI*R0*B0)
	DRHOOR(I) = ZJJ12(I) / ZJJ5(I) / DPSIDRHO * (2.D0*PI*B0)
        R2(I) = ZJJ13(I) / ZJJ5(I) * R0**2
        DRHO2OB2(I) = ZJJ15(I) / ZJJ5(I) / DPSIDRHO**2 *(2.D0*PI*R0)**2

c        R2TAU2(I)   = ZJJ14(I) / ZJJ5(I) / (DPSIDRHO / B0)**2 / R0**2
c        R3OTAU3(I)  = -ZJJ16(I) / ZJJ5(I) / (DPSIDRHO / B0)**3 / R0**3
c        R3OTAU(I)   = -ZJJ17(I) / ZJJ5(I) / (DPSIDRHO / B0) * R0


        R2OTAU2(I)=  ZJJ14(I)/ZJJ5(I)/(DPSIDRHO / (2.*PI*B0))**2 *R0**2
        R3OTAU3(I)= -ZJJ16(I)/ZJJ5(I)/(DPSIDRHO /(2.*PI*B0))**3 * R0**3
        R3OTAU(I)= -ZJJ17(I)/ZJJ5(I)/(DPSIDRHO / (2.*PI*B0)) * R0**3
        

	FTRA(I) = 1. - FCIRC(I)                                         

        AVC(I)    = AVC(I) * B0 / (ZMU0 * R0)
        TAU(I)    = - ZJJ11(I) / ZJJ5(I) * DPSIDRHO/(2.*PI) / (B0)
		                                                                        
      ENDDO                                 
                                                                        
      PSIP(1) = 0.                                                      
      PSIT(1) = 0.                                                      
      C2(1) = 0.                                                        
      C3(1) = 0.                                                        
      QPSI(1) = FDIA(1)/(R0*B0)* ALFA/(2.D0*DSQRT(DABS(CX*CY))*
     >          (1.D0+EPS*XAXIS))   
      B2(1) = (FDIA(1)/(R0*(1.D0+EPS*XAXIS)))**2                          
      INVB2(1) = 1./B2(1)                                               
      FTRA(1) = 0.                                                      
      R2M(1) = QPSI(1)*PSIP(NR)/PSIT(NR) * (CX + CY)/2.                 
      VP(1) = 0.                                                        
      SP(1) = 0.                                 
      TAU(1) = 0.                                  
                                                                         
      DO I=1,NRMAP                                                        
        DO J=1,NPMAP                                                       
          NODE = (NRMAP-I)*NPMAP + J                                          
          RR(I,J) = RADIUS * XX(1,NODE) + R0                            
          ZZ(I,J) = RADIUS * YY(1,NODE)
          IF (IAS.EQ.0) THEN
             JSYM = NPMAP * 2 - J
             RR(I,JSYM) = RR(I,J)
             ZZ(I,JSYM) = - ZZ(I,J)
          ENDIF
        ENDDO  
      ENDDO                            
      DO I=2,NRMAP                                                        
        DO J=1,NPMAP                                                       
          NODE = (NRMAP-I)*NPMAP + J                                          
 	  XR    = XX(2,NODE)
	  YR    = YY(2,NODE)
	  XS    = XX(3,NODE)
	  YS    = YY(3,NODE)
	  PSIR  = PSI(4*(NODE-1)+2) 
	  EJAC  = (XR*YS-XS*YR)
          PSIX  =   PSIR * YS / EJAC  * (CPSURF/RADIUS) 
          PSIY  = - PSIR * XS / EJAC  * (CPSURF/RADIUS) 

          BPR(I,J) = - PSIY / RR(I,J) 
          BPZ(I,J) = + PSIX / RR(I,J)

          IF (IAS.EQ.0) THEN
             JSYM = NPMAP * 2 - J
 	     BPR(I,JSYM) = - BPR(I,J)
	     BPZ(I,JSYM) = + BPZ(I,J)
          ENDIF
        ENDDO  
      ENDDO                            
      DO J=1,NPMAX
        BPR(1,J) = 0.
        BPZ(1,J) = 0.
      ENDDO
c pour que matlab ait la bonne dimension en theta :
      IF (IAS.EQ.0) NPMAP = NPMAP * 2 - 1
      WRITE(*,*) ' HELENA ENDS OK',TAU(NR)                                                                                         
      RETURN                                                            
      END                                                               

*********************************************************************** 
      SUBROUTINE FBND(r,z,NTHT,FR,MF,AMIN,R0)
      IMPLICIT REAL*8 (A-H,O-Z)
      COMMON / COMPIE/ PI                                               
      REAL*8 PI                                                           
      REAL*8 r(*),z(*),FR(*)
      REAL*8 theta(770),radius(770)
      REAL*8 ar(770),br(770),cr(770),dr(770),dummy(3)
      
      rmax = -1.D10
      rmin = -rmax
      do i=1,ntht
        if (r(i).gt. rmax) then
          rmax=r(i)
          z0=z(i)         
          jmax = i
        endif
	if (r(i).lt. rmin) then
          rmin=r(i)
          jmin = i
        endif
      enddo
      r0 = (rmin+rmax)/2.D0
      do i=1,ntht
        theta(i) = atan2(z(i)-z0,r(i)-r0)
        if (theta(i).lt.0.D0) then
          theta(i) = theta(i)+2.*pi
	endif
c
c       protection en fin de contour, theta pouvant etre nul
c       V. Basiuk, 30 octobre 2001
c	
        if (i .eq. ntht .and. theta(i).eq.0.D0) then
          theta(i) = theta(i)+2.*pi
	     endif
      enddo
      call spline(ntht,theta,r,0.D0,0.D0,2,ar,br,cr,dr)
      rmin = spwert(ntht,PI,ar,br,cr,dr,theta,dummy)
      r0 = (rmin+rmax)/2.D0
      amin = (rmax-rmin)/2.D0
      
      do i=1,ntht
        theta(i) = atan2(z(i)-z0,r(i)-r0)
        if (theta(i).lt.0.D0) then
          theta(i) = theta(i)+2.*pi
	endif
        radius(i) = sqrt((r(i)-r0)**2 + (z(i)-z0)**2) / amin
      enddo
      do i=1,ntht-1
         if (theta(i).gt.theta(i+1)) theta(i+1)=theta(i+1)+2.*pi
      enddo
      do i=1,ntht
        theta(i+ntht) = theta(i) + 2.*pi
	radius(i+ntht) = radius(i)
      enddo
      do i=1,ntht
        theta(i+2*ntht)  = theta(i) + 4.*pi
	radius(i+2*ntht) = radius(i)
      enddo
      call spline(3*ntht,theta,radius,0.D0,0.D0,2,ar,br,cr,dr)

      NP=MF
      NTHT3 = 3*NTHT
      DO i=1,NP
        angle = 2.D0 * DBLE(i-1)/DBLE(NP) * PI + 2.D0*PI + theta(1)
        radius(i) = spwert(NTHT3,angle,ar,br,cr,dr,theta,dummy)
      ENDDO
      call RFT2(RADIUS,NP,1)
      DO M=1,NP
        FR(m) = 2.D0 * RADIUS(m)/DBLE(np)
      ENDDO
      DO M=2,NP,2
        FR(M) = - FR(M)
      ENDDO
      RETURN
      END

                                                                        
*********************************************************************** 
      SUBROUTINE INIVAL                                                 
C-----------------------------------------------------------------------
C SUBROUTINE TO INITIALIZE THE NAMELIST INPUT VARIABLES                 
C-----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      COMMON /CORNERS/ RS, IJ, NODENO                                   
      real*8    RS(4,2)                                                   
      integer IJ(4,2), NODENO(MAXMNODE,4)                               
C-----------------------------------------------------------------------
      COMMON /GAUSINT/ XGAUSS,WGAUSS,H,HR,HS,HRS                        
      real*8 XGAUSS(4),WGAUSS(4)                                          
      real*8 H(4,4,4,4),HR(4,4,4,4),HS(4,4,4,4),HRS(4,4,4,4)              
C-----------------------------------------------------------------------
      COMMON / COMDAT/                                                  
     >        ELLIP,TRIAH,TRIAB,QUAD,PAR1,PAR2,PAR3,PAR4,                      
     >        AGA,BGA,CGA,DGA,EGA,FGA,GGA,HGA,                          
     >        API,BPI,CPI,DPI,EPI,FPI,GPI,HPI,                          
     >        ACUR,BCUR,CCUR,DCUR,ECUR,FCUR,GCUR,HCUR,                  
     >        ERRIT,ERRCUR,EPS,ALFA,B,C,XIAB,Q95,BETAP,AMIX,BMIX,       
     >        ABB, BBB, AMPL, RVAC,BVAC,ZEFF,ZN0,RPE,XR1,SIG1,          
     >        IAS,ICUR,NRCUR,NPCUR,NMESH,INIMESH,NBB,NQB,IARC,          
     >        MHARM,ISHAPE,ISOL,IGAM,IPAI,NR,NP,NRMAP,NPMAP,NITER       
      real*8    ELLIP,TRIAH,TRIAB,QUAD,PAR1,PAR2,PAR3,PAR4,                      
     >        AGA,BGA,CGA,DGA,EGA,FGA,GGA,HGA,                          
     >        API,BPI,CPI,DPI,EPI,FPI,GPI,HPI,                          
     >        ACUR,BCUR,CCUR,DCUR,ECUR,FCUR,GCUR,HCUR,                  
     >        ERRIT,ERRCUR,EPS,ALFA,B,C,XIAB,Q95,BETAP,AMIX,BMIX,       
     >        ABB, BBB, AMPL, RVAC,BVAC,ZEFF,ZN0,RPE,XR1,SIG1           
      integer IAS,ICUR,NRCUR,NPCUR,NMESH,INIMESH,NBB,NQB,IARC,          
     >        MHARM,ISHAPE,ISOL,IGAM,IPAI,NR,NP,NRMAP,NPMAP,NITER       
C-----------------------------------------------------------------------
      COMMON/TOLERA/PSITOL,THTTOL,TOL                                   
      real*8    PSITOL,THTTOL,TOL                                         
C-----------------------------------------------------------------------
      COMMON / COMPIE/ PI                                               
      real*8 PI                                                           
 
C                                                                       
                                                                        
      RS(1,1) = -1.D0                                                     
      RS(1,2) = -1.D0                                                     
      RS(2,1) = -1.D0                                                     
      RS(2,2) = +1.D0                                                     
      RS(3,1) = +1.D0                                                     
      RS(3,2) = +1.D0                                                     
      RS(4,1) = +1.D0                                                     
      RS(4,2) = -1.D0                                                    
      IJ(1,1) = 0                                                       
      IJ(1,2) = 0                                                       
      IJ(2,1) = 1                                                       
      IJ(2,2) = 0                                                       
      IJ(3,1) = 0                                                       
      IJ(3,2) = 1                                                       
      IJ(4,1) = 1                                                       
      IJ(4,2) = 1                                                       
      XGAUSS(1) = -0.86113 63115 94053D0                                  
      XGAUSS(2) = -0.33998 10435 84856D0                                  
      XGAUSS(3) =  0.33998 10435 84856D0                                  
      XGAUSS(4) =  0.86113 63115 94053D0                                  
      WGAUSS(1) =  0.34785 48451 37454D0                                  
      WGAUSS(2) =  0.65214 51548 62546D0                                  
      WGAUSS(3) =  0.65214 51548 62546D0                                  
      WGAUSS(4) =  0.34785 48451 37454D0                                  
                                                                        
      PI = 2.D0*DASIN(1.D0)                                                  
C      IAS=0   mis a jour au niveau de l'entree matlab maintenant                                                           
      QUAD  = 0.0D0                                                       
c
c correction 17 mars 2004, V. Basiuk
c
      MHARM = 512                                                        
      ISHAPE = 1                                                        
      ISOL = 0                                                          
c
c pour plasma iter (avant iarc = 0)
c 17 mars 2004, V. Basiuk 
c
      IARC = 1                                                          
      XR1 = 99.D0                                                         
      SIG1 = 99.D0                                                        
      AGA = -1.D0                                                         
      BGA = 0.D0                                                          
      CGA = 0.D0                                                          
      DGA = 0.D0                                                          
      EGA = 0.D0                                                          
      API = -1.D0                                                         
      BPI = 0.D0                                                          
      CPI = 0.D0                                                          
      DPI = 0.D0                                                          
      EPI = 0.D0                                                          
      IPAI = 11                                                          
      IGAM = 2                                                          
      ICUR = 11                                                         
      EPS = 0.1D0                                                         
      ALFA = 2.D0                                                         
      Q95 = -1.D0                                                         
      BETAP = -1.D0                                                       
      C = 1.D0                                                            
      AMIX = 0.D0                                                        
      BMIX = 0.D0
c taille de la grille (R,Z) sur laquelle le calcul est effectue                                                               
      NR=51                                                             
      NP=16*(IAS+1)+1                                              
c taille de la grille (R,Z) des variables de sortie                     
      NRMAP=101
c nb de point en theta depend de la condition de symetrie IAS
      IF (IAS.EQ.0) THEN                                                         
         NPMAP=33
      ELSE
         NPMAP=65
c         NPMAP=129
      ENDIF                
c                                                  
      NITER = 100                                                        
      NMESH = 100                                                        
      NPTS = 21                                                         
      INIMESH=1                                                         
      NBB = 6                                                           
      ABB = 1.D0                                                          
      BBB = 0.2D0                                                          
      AMPL = 2.D0                                                         
c     ERRCUR = 1.D-4 
c modifier le 12/04/2001 par J-F Artaud :                                                   
      ERRCUR = 1.D-3                                                    
      ERRIT  = 1.D-5                                                    
      PSITOL = 1.D-6                                                    
      THTTOL = 1.D-6                                                    
      TOL    = 1.D-6                                                    
      NQB = 1                                                           
                                                                        
      ZEFF = 1.0D0                                                        
      ZN0  = 1.0D0                                                        
      RPE  = 0.5D0                                                        
                                                                                                                                               
      RETURN                                                            
      END                                                               
                                                                        
************************************************************************
      SUBROUTINE GAUSS                                                  
C-----------------------------------------------------------------------
C CALCULATE THE SIXTHEEN FUNCTIONS AT THE SIXTEEN GAUSSIAN POINTS       
C-----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      COMMON /CORNERS/ RS, IJ, NODENO                                   
      real*8    RS(4,2)                                                   
      integer IJ(4,2), NODENO(MAXMNODE,4)                               
C-----------------------------------------------------------------------
      COMMON /GAUSINT/ XGAUSS,WGAUSS,H,HR,HS,HRS                        
      real*8 XGAUSS(4),WGAUSS(4)                                          
      real*8 H(4,4,4,4),HR(4,4,4,4),HS(4,4,4,4),HRS(4,4,4,4)              
C-----------------------------------------------------------------------
                                                                              
      DO 10 IRS=1,4                                                     
        R0 = RS(IRS,1)                                                  
        S0 = RS(IRS,2)                                                  
        DO 20 IM=1,4                                                    
          MI = IJ(IM,1)                                                 
          MJ = IJ(IM,2)
                                                 
          DO 30 NGR=1,4                                                 
          R = XGAUSS(NGR)                                               
            DO 40 NGS=1,4                                               
              S  = XGAUSS(NGS)  
                                        
              CALL CUBICH(MI,MJ,R0,S0,R,S,H(IM,IRS,NGR,NGS),            
     >                    HR(IM,IRS,NGR,NGS),HS(IM,IRS,NGR,NGS),        
     >                    HRS(IM,IRS,NGR,NGS),DUMRR,DUMSS)
   40       CONTINUE                                                    
   30     CONTINUE                                                      
   20   CONTINUE                                                        
   10 CONTINUE    
                                                         
      RETURN                                                            
      END                                                               
                                                                        
************************************************************************
      SUBROUTINE CUBICH(I,J,R0,S0,R,S,H,HR,HS,HRS,HRR,HSS)              
                                                                        
C------------------------------------------------------------------     
C SUBROUTINE TO CALCULATE THE VALUE OF THE CUBIC POLYNOMIALS AND        
C THE DERIVATIVES OF THE CORNER MARKED BY R0,S0 AT THE POSITION R,S     
C------------------------------------------------------------------     
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      real*8 H,HR,HS,HRS,HI,HRI,HJ,HSJ,HRR,HSS,HRRI,HSSJ                  
                                                                       
      IF (I.EQ.0) THEN                                                  
        HI = - (R+R0)**2 * (R*R0-2.D0) / 4.D0                               
        HRI = - (R+R0)*(R*R0-2.D0)/2.D0 - R0*(R+R0)**2 / 4.D0                 
        HRRI = - 1.5D0 * R * R0                                           
      ELSE                                                              
        HI = + R0 * (R+R0)**2 * (R*R0 - 1.D0) / 4.D0                        
        HRI = + R0*(R+R0)*(R*R0-1.D0)/2.D0 + (R+R0)**2 /4.D0                  
        HRRI = 1.5D0*R + .5D0*R0                                            
      ENDIF  
                                                                       
      IF (J.EQ.0) THEN                                                  
        HJ = - (S+S0)**2 * (S*S0-2.D0) / 4.D0                               
        HSJ = - (S+S0)*(S*S0-2.D0)/2.D0 - S0*(S+S0)**2 / 4.D0                 
        HSSJ = - 1.5D0 * S * S0                                           
      ELSE                                                              
        HJ = + S0 * (S+S0)**2 * (S*S0 - 1.D0) / 4.D0                        
        HSJ = + S0*(S+S0)*(S*S0-1.D0)/2.D0 + (S+S0)**2 / 4.D0                 
        HSSJ = 1.5D0*S + .5D0*S0                                            
      ENDIF        
      
                                                           
      H = HI * HJ                                                       
      HR = HRI * HJ                                                     
      HS = HI * HSJ                                                     
      HRS = HRI * HSJ                                                   
      HRR = HRRI * HJ                                                   
      HSS = HI   * HSSJ
      RETURN                                                            
      END                                                               
                                                                        
************************************************************************
      SUBROUTINE CUBICH1(I,J,R0,S0,R,S,H)                               
C------------------------------------------------------------------     
C SUBROUTINE TO CALCULATE THE VALUE OF THE CUBIC POLYNOMIALS AND        
C THE DERIVATIVES OF THE CORNER MARKED BY R0,S0 AT THE POSITION R,S     
C------------------------------------------------------------------     
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      real*8 H,HI,HJ                                                      
                                                                         
      IF (I.EQ.0) THEN                                                  
        HI = - (R+R0)**2 * (R*R0-2.D0) / 4.D0                               
      ELSE                                                              
        HI = + R0 * (R+R0)**2 * (R*R0 - 1.D0) / 4.D0                        
      ENDIF                                                             
      IF (J.EQ.0) THEN                                                  
        HJ = - (S+S0)**2 * (S*S0-2.D0) / 4.D0                               
      ELSE                                                              
        HJ = + S0 * (S+S0)**2 * (S*S0 - 1.D0) / 4.D0                        
      ENDIF                                                             
      H = HI * HJ                                                       
      RETURN                                                            
      END                                                               
                                                                        
************************************************************************
      SUBROUTINE CUBICH2(I,J,R0,S0,R,S,H,HR,HS)                         
C------------------------------------------------------------------     
C SUBROUTINE TO CALCULATE THE VALUE OF THE CUBIC POLYNOMIALS AND        
C THE DERIVATIVES OF THE CORNER MARKED BY R0,S0 AT THE POSITION R,S     
C------------------------------------------------------------------     
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      real*8 H,HR,HS,HI,HRI,HJ,HSJ                                        
                                                                         
      IF (I.EQ.0) THEN                                                  
        HI = - (R+R0)**2 * (R*R0-2.D0) / 4.D0                               
        HRI = - (R+R0)*(R*R0-2.D0)/2.D0 - R0*(R+R0)**2 / 4.D0                 
      ELSE                                                              
        HI = + R0 * (R+R0)**2 * (R*R0 - 1.D0) / 4.D0                        
        HRI = + R0*(R+R0)*(R*R0-1.D0)/2.D0 + (R+R0)**2 /4.D0                  
      ENDIF                                                             
      IF (J.EQ.0) THEN                                                  
        HJ = - (S+S0)**2 * (S*S0-2.D0) / 4.D0                               
        HSJ = - (S+S0)*(S*S0-2.D0)/2.D0 - S0*(S+S0)**2 / 4.D0                 
      ELSE                                                              
        HJ = + S0 * (S+S0)**2 * (S*S0 - 1.D0) / 4.D0                        
        HSJ = + S0*(S+S0)*(S*S0-1.D0)/2.D0 + (S+S0)**2 / 4.D0                 
      ENDIF                                                             
      H = HI * HJ                                                       
      HR = HRI * HJ                                                     
      HS = HI * HSJ                                                     
      RETURN                                                            
      END                                                               
                                                                        
************************************************************************
      SUBROUTINE FSHAPE(FR,MF)                                          
C-----------------------------------------------------------------------
C  THE SHAPE R=SQRT(X**2+Y**2)=FR(THETA) OF THE PLASMA CROSS-SECTION IN 
C  Z-PLANE IS COMPUTED FROM A FORMULA WHICH GIVES ELLIPSES, D-SHAPES ETC
                                                                        
C     X=A*COS(GAMMA+C*SIN(GAMMA)+D*SIN(2.*GAMMA)),                      
C     Y=B*SIN(GAMMA),                                                   
C  WHERE THETA IS FOUND FROM GAMMA BY INVERSION.                        
C  THE FOURIER COEFFICIENTS FRFNUL,FRF(M) OF FR(J) ARE ALSO CALCULATED. 
C-----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      COMMON / COMDAT/                                                  
     >        ELLIP,TRIAH,TRIAB,QUAD,PAR1,PAR2,PAR3,PAR4,                      
     >        AGA,BGA,CGA,DGA,EGA,FGA,GGA,HGA,                          
     >        API,BPI,CPI,DPI,EPI,FPI,GPI,HPI,                          
     >        ACUR,BCUR,CCUR,DCUR,ECUR,FCUR,GCUR,HCUR,                  
     >        ERRIT,ERRCUR,EPS,ALFA,B,C,XIAB,Q95,BETAP,AMIX,BMIX,       
     >        ABB, BBB, AMPL, RVAC,BVAC,ZEFF,ZN0,RPE,XR1,SIG1,          
     >        IAS,ICUR,NRCUR,NPCUR,NMESH,INIMESH,NBB,NQB,IARC,          
     >        MHARM,ISHAPE,ISOL,IGAM,IPAI,NR,NP,NRMAP,NPMAP,NITER       
      real*8    ELLIP,TRIAH,TRIAB,QUAD,PAR1,PAR2,PAR3,PAR4,                      
     >        AGA,BGA,CGA,DGA,EGA,FGA,GGA,HGA,                          
     >        API,BPI,CPI,DPI,EPI,FPI,GPI,HPI,                          
     >        ACUR,BCUR,CCUR,DCUR,ECUR,FCUR,GCUR,HCUR,                  
     >        ERRIT,ERRCUR,EPS,ALFA,B,C,XIAB,Q95,BETAP,AMIX,BMIX,       
     >        ABB, BBB, AMPL, RVAC,BVAC,ZEFF,ZN0,RPE,XR1,SIG1           
      integer IAS,ICUR,NRCUR,NPCUR,NMESH,INIMESH,NBB,NQB,IARC,          
     >        MHARM,ISHAPE,ISOL,IGAM,IPAI,NR,NP,NRMAP,NPMAP,NITER       
C-----------------------------------------------------------------------
      COMMON / COMPIE/ PI                                               
      real*8 PI                                                           
                                                                      
      real*8 FR(*), THETA(2*MBMAX+2), GAMMA(2*MBMAX+2)                    
      real*8 XV(2*MBMAX+2),YV(2*MBMAX+2)                                  
C                                                                       
C------------------------------------------ THETA(GAMMA(J)) ------------
      DO 10 J=1,MF                                                      
        GA = 2.D0*PI*DBLE(J-1)/dble(MF)
        IF (GA.LE.PI) THEN                                
           XJO= DCOS(GA + TRIAB*DSIN(GA) + QUAD*DSIN(2*GA))                    
        ELSE
           XJO= DCOS(GA + TRIAH*DSIN(GA) + QUAD*DSIN(2*GA))
        ENDIF
        YJO= ELLIP * DSIN(GA + PAR4*DCOS(GA))                             
        XJ = XJO * DCOS(PAR1) - YJO*DSIN(PAR1)                            
        YJ = XJO * DSIN(PAR1) + YJO*DCOS(PAR1) + PAR2                     
        THETA(J) = DATAN2(YJ,XJ)  
   10 CONTINUE   
   11 format(i3,3f12.4)                                                       
C-------------- INVERSION OF THETA(GAMMA(J)) TO GAMMA(THETA(J)) ------  
      CALL GRID2NV(THETA,GAMMA,MF,1.D-6,IGRINV,0)                       
      DO 30 J=1,MF                                                      
        GAMM=GAMMA(J)
        IF (GAMM.LE.PI) THEN                                                   
           XJO= DCOS(GAMM + TRIAB*DSIN(GAMM) + QUAD*DSIN(2*GAMM))
        ELSE
           XJO= DCOS(GAMM + TRIAH*DSIN(GAMM) + QUAD*DSIN(2*GAMM))
        ENDIF              
        YJO= ELLIP * DSIN(GAMM + PAR4*DCOS(GAMM))                         
        XV(J) = XJO * DCOS(PAR1) - YJO*DSIN(PAR1)                         
        YV(J) = XJO * DSIN(PAR1) + YJO*DCOS(PAR1) + PAR2                  
   30 CONTINUE                                                          
      XEAST = XV(1)                                                     
      XWEST = XV(MF/2+1)                                                
      X0 = (XEAST + XWEST)/2.D0                                           
      XL = (XEAST - XWEST)/2.D0                                           
      DO 35 J=1,MF                                                      
        XN = (XV(J) - X0) / XL                                          
        YN =  YV(J) / XL                                                
        FR(J) = DSQRT(XN**2 + YN**2)                                     
   35 CONTINUE                          
C------------------- FOURIER COEFFICIENTS FRFNUL AND FRF(M) OF FR(J).   
      CALL RFT2(FR,MF,1)     
      DO 50 M=1,MF                                                      
        FR(M) = 2.D0 * FR(M) / dble(MF)                                    
   50 CONTINUE                                                          
ccc      CALL PRARR1('FR : ',FR,MF,203)                                 
      RETURN                                                            
      END                                                               
                                                                        
************************************************************************
      SUBROUTINE ELMNO(NR,NP,NODENO)                                    
C-------------------------------------------------------------------    
C SUBROUTINE TO CALCULATE THE FOUR NODENUMBERS OF EVERY ELEMENT         
C-------------------------------------------------------------------    
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      integer NODENO(MAXMNODE,4)                                        

      NO = 0                                                            
      DO 10 N=1,NR-1                                                    
        DO 20 M=1,NP-1                                                  
          NO = NO + 1                                                   
          NODENO(NO,1) = (N-1)*NP + M                                   
          NODENO(NO,2) = NODENO(NO,1) + 1                               
          NODENO(NO,3) = NODENO(NO,2) + NP                              
          NODENO(NO,4) = NODENO(NO,1) + NP                              
   20   CONTINUE                                                        
   10 CONTINUE                                                          
      RETURN                                                            
      END                                                               
************************************************************************
      SUBROUTINE MESHAC2(NR,SG,DSG,DDSG,XR1,SIG1)                        
C-----------------------------------------------------------------------
C subroutine to construct non-equidistant radial mesh in Helena         
C-----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NMAX=1001)                                             
      real*8 SG(*),DSG(*),DDSG(*)                                         
      real*8 S1(NMAX),F1(NMAX),F2(NMAX),F3(NMAX),F4(NMAX),FSUM(NMAX)      
      real*8 ABLTG(3)                                                     
                                                                         
C--------------------------------------- set parameters of gaussians    
      BGF  = 0.3D0                                                        
      XR2  = 9999.D0                                                      
      SIG2 = 1.D0                                                         
      FACT = 1.D0                                                         
C--------------------------------------- integrate gaussian             
      DSI = 1.D0 / dble(NMAX-1)                                          
      S1(1) = 0.D0                                                        
      FSUM(1)  = 0.D0                                                     
      FINT2 = FGAUS(S1(1),BGF,XR1,XR2,SIG1,SIG2,FACT,DFG)               
      DO I=2,NMAX                                                       
        S1(I) = dble(I-1) * DSI                                        
        FINT1 = FINT2                                                   
        FINT2 = FGAUS(S1(I),BGF,XR1,XR2,SIG1,SIG2,FACT,DFG)             
        SUM = SUM + (FINT1+FINT2)/2. * DSI                              
        FSUM(I) = SUM                                                   
      ENDDO                                                             
                                                                        
      DO I=1,NMAX-1                                                     
        FSUM(I) = FSUM(I)/FSUM(NMAX)                                    
      ENDDO                                                             
      FSUM(NMAX) = 1.D0                                                   
      ALFA = 0.D0                                                         
      BETA = 0.D0                                                         
      TYP = 2                                                           
      CALL SPLINE(NMAX,FSUM,S1,ALFA,BETA,TYP,F1,F2,F3,F4)               
                                                                        
      SG(1)   = 0.D0                                                      
      DSG(1)  = F2(1)                                                   
      DDSG(1) = F3(1)                                                   
      DO I=2,NR-1                                                       
        FI = dble(I-1)/dble(NR-1)                                     
        SG(I)   = SPWERT(NMAX,FI,F1,F2,F3,F4,FSUM,ABLTG)                
        DSG(I)  = ABLTG(1)                                              
        DDSG(I) = ABLTG(2)                                              
      ENDDO                                                             
      SG(NR)   = 1.D0                                                     
      DSG(NR)  = F2(NMAX)                                               
      DDSG(NR) = F3(NMAX)                                               
      RETURN                                                            
      END                                                               
                                                                        
************************************************************************
      REAL*8 FUNCTION FGAUS(ZS,BGF,XR1,XR2,SIG1,SIG2,FACT,DFGAUSS)             
      IMPLICIT REAL*8 (A-H,O-Z)
C-----------------------------------------------------------------------
C     BGF + (1 - BGF) * (GAUSS1 + FACT * GAUSS2) / FACT                 
C-----------------------------------------------------------------------
C                                                                       
      ZNORM1 = 0.39894D0 / SIG1                                           
      ZNORM2 = 0.39894D0 / SIG2                                           
      ZEX1   = -0.5D0 * (ZS - XR1)**2 / SIG1**2                           
      ZEX2   = -0.5D0 * (ZS - XR2)**2 / SIG2**2                           
      DEX1   = -(ZS-XR1)/SIG1**2                                        
      DEX2   = -(ZS-XR2)/SIG2**2                                        
                                                                        
      F1     = ZNORM1 * EXP(ZEX1)                                       
      F2     = ZNORM2 * EXP(ZEX2)                                       
      DF1    = ZNORM1 * DEX1 * EXP(ZEX1)                                
      DF2    = ZNORM2 * DEX2 * EXP(ZEX2)                                
C                                                                       
      FGAUS  = BGF + (1.0D0 - BGF) * (F1 + FACT * F2) / FACT              
      DFGAUSS = (1.0D0-BGF) * (DF1 + FACT * DF2) / FACT                   
C                                                                       
      RETURN                                                            
      END                                                               
                                                                        
************************************************************************
      SUBROUTINE ARCLENGTH(FR,MF,THETA,DTC,NP,IAS,WR,WS)                
C-----------------------------------------------------------------------
C SUBROUTINE TO CALCULATE THE ARCLENGTH OF THE PLASMA BOUNDARY          
C ROUTINE RETURNS THE THETA VALUES AT EQUIDISTANT ARCLENGTH             
C PARAMETERS :                                                          
C                FR    : FOURIER SERIES OF BOUNDARY (INPUT)             
C                MF    : NUMBER OF HARMONICS IN FR  (INPUT)             
C                THETA : RESULTING VALUEs OF THETA                      
C                DTC   : THE DERIVATIVE OF THETA TO EQUIDISTANT ANGLE   
C                NP    : NUMBER OF POINTS IN THETA,DTC                  
C                IAS   : CONTROLS SYM/ASYM (INPUT)                      
C-----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NPTS=512)                                              
      real*8 FR(*),THETA(*),DTC(*),WR(4),WS(4),XL(NPTS),DXL(NPTS)         
      integer NF,NP,IAS                                                 
                                                                        
      PI = 2.D0*DASIN(1.D0)                                                  
      XL(1) = 0.D0                                                        
C---------------------------------- calculate lenght(theta)             
      DO J=1,NPTS-1                                                     
        TI1 = dble(J-1)/dble(NPTS-1) * dble(IAS+1)*PI                
        TI2 = dble(J)  /dble(NPTS-1) * dble(IAS+1)*PI                
C---------------------------------- 4 point Gaussian integration        
        DL = 0.D0                                                         
        DO K=1,4                                                        
          TK = TI1 + (TI2-TI1)*(WR(K)+1.D0)/2.D0                            
          RR = FR(1)/2.D0                                                 
          DR = 0.D0                                                       
          DO M=2,MF/2                                                   
            RR = RR + FR(2*M-1)*DCOS((M-1)*TK)                           
     >              + FR(2*M)  *DSIN((M-1)*TK)                           
            DR = DR - dble(M-1)*FR(2*M-1)*DSIN((M-1)*TK)                
     >              + dble(M-1)*FR(2*M)  *DCOS((M-1)*TK)                
          ENDDO                                                         
          DL = DL + DSQRT(RR*RR + DR*DR) * WS(K)                         
        ENDDO                                                           
        XL(J+1) = XL(J) + DL * dble(IAS+1)/2 *PI/dble(NPTS-1)         
        RR = FR(1)/2.D0                                                   
        DR = 0.D0                                                         
        DO M=2,MF/2                                                     
           RR = RR + FR(2*M-1)*DCOS((M-1)*TI2)                           
     >             + FR(2*M)  *DSIN((M-1)*TI2)                           
           DR = DR - dble(M-1)*FR(2*M-1)*DSIN((M-1)*TI2)                
     >             + dble(M-1)*FR(2*M)  *DCOS((M-1)*TI2)                
        ENDDO                                                           
      DXL(J+1) = DSQRT(RR*RR + DR*DR)                                    
      ENDDO                                                             
      TI2 = 0.D0                                                          
      RR = FR(1)/2.D0                                                     
      DR = 0.D0                                                           
                                                                        
      DO M=2,MF/2                                                       
        RR = RR + FR(2*M-1)*DCOS((M-1)*TI2)                              
     >          + FR(2*M)  *DSIN((M-1)*TI2)                              
        DR = DR - dble(M-1)*FR(2*M-1)*DSIN((M-1)*TI2)                   
     >          + dble(M-1)*FR(2*M)  *DCOS((M-1)*TI2)                   
      ENDDO                                                             
      DXL(1) = DSQRT(RR*RR + DR*DR)                                      
c      WRITE(*,2) (I,XL(I),DXL(I),I=1,NPTS)                             
    2 format(i4,2f10.6)                                                 
                                                                        
      THETA(1) = 0.D0                                                     
      THETA(NP) = dble(IAS+1)*PI                                       
      DTC(1)  = 1.D0/(DXL(1)    * dble(IAS+1)*PI/XL(NPTS))               
      DTC(NP) = 1.D0/(DXL(NPTS) * dble(IAS+1)*PI/XL(NPTS))               
      I=1                                                               
      DO J=2,NP-1                                                       
        CHIL = dble(J-1)/dble(NP-1) * XL(NPTS)                        
        DO WHILE ((CHIL.GT.XL(I)).AND.(I.LT.NPTS))                      
          I = I+1                                                       
         ENDDO                                                          
c--------------------------- interval located, use linear interpolation 
        THETA(J) = (dble(I-1) + (CHIL-XL(I))/(XL(I+1)-XL(I)) )         
     >           / dble(NPTS-1) * dble(IAS+1)*PI                      
        DCT   = ( (CHIL-XL(I))/(XL(I+1)-XL(I)) * (DXL(I+1)-DXL(I))      
     >           +  DXL(I) ) * dble(IAS+1)*PI/XL(NPTS)                 
        DTC(J) =  1.D0/ DCT                                               
      ENDDO                                                             
      RETURN                                                            
      END                                                               
************************************************************************
      SUBROUTINE INIGRID(XX,YY,PSI,NR,NP,FR,MHARM,INIMESH,IAS,          
     >                   IARC,XR1,SIG1)                                 
C--------------------------------------------------------------------   
C ON EXIT XX AND YY ARE FILLED WITH THE VALUES OF X,XR,XS,XRS AND       
C Y,YR,YS,YRS OF EVERY NODE :                                           
C XX(1,NODE) = X, XX(2,NODE) = XR, XX(3,NODE) = XS, XX(4,NODE) = XRS    
C THE SHAPE OF THE BOUNDARY IS GIVEN BY FR(M)                           
C--------------------------------------------------------------------   
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      COMMON /GAUSINT/ XGAUSS,WGAUSS,H,HR,HS,HRS                        
      real*8 XGAUSS(4),WGAUSS(4)                                          
      real*8 H(4,4,4,4),HR(4,4,4,4),HS(4,4,4,4),HRS(4,4,4,4)              
C-----------------------------------------------------------------------
      real*8 XX(4,*),YY(4,*),FR(*),PSI(*),THETA(NPMMAX),DTC(NPMMAX)       
      real*8 SS(NRMAX),DS(NRMAX),DDS(NRMAX)                               
                                                                         
      PI = 2.*DASIN(1.D0)                                                  
      DT = (1.+dble(IAS))*PI/dble(NP-1)                                
      DR = 1./dble(NR-1)                                                
                                                                        
C--------------------------- change theta grid to constant arclenght    
      IF (IARC.EQ.1) THEN                                               
        MF = 2.*MHARM                                                   
        CALL ARCLENGTH(FR,MF,THETA,DTC,NP,IAS,XGAUSS,WGAUSS)            
      ELSE                                                              
        DO J=1,NP                                                       
          THETA(J) = DT * dble(J-1)                                     
          DTC(J) = 1.D0                                                   
        ENDDO                                                           
      ENDIF                                                             
                                                                        
      IF ((XR1.LE.1.D0).AND.(SIG1.LT.1.D0)) THEN                            
        CALL MESHAC2(NR,SS,DS,DDS,XR1,SIG1)                              
      ELSE                                                              
        DO I=1,NR                                                       
          SS(I)  = dble(I-1)/dble(NR-1)                               
          DS(I)  = 1.D0                                                   
          DDS(I) = 0.D0                                                   
        ENDDO                                                           
      ENDIF                                                             
                                                                        
      DO 10 I=1,NR                                                      
        DO 20 J=1,NP                                                    
          NODE = NP*(I-1) + J                                           
          THTJ = THETA(J)                                               
          RADIUS = SS(NR-I+1)                                           
          XX(1,NODE) = RADIUS * FR(1) * DCOS(THTJ) / 2.D0                  
          XX(2,NODE) = FR(1) * DCOS(THTJ)          / 2.D0                  
          XX(3,NODE) = - RADIUS * FR(1) * DSIN(THTJ) / 2.D0                
          XX(4,NODE) = - FR(1) * DSIN(THTJ)          / 2.D0                
          YY(1,NODE) = RADIUS * FR(1) * DSIN(THTJ)   / 2.D0                
          YY(2,NODE) = FR(1) * DSIN(THTJ)            / 2.D0                
          YY(3,NODE) = RADIUS * FR(1) * DCOS(THTJ)   / 2.D0                
          YY(4,NODE) = FR(1) * DCOS(THTJ)            / 2.D0                
C---------------------------- KEEP ELLIPTICITY ON AXIS -----------      
          DO 30 M = 2,MHARM                                             
            IF (M.EQ.2) THEN                                            
              RM = RADIUS * ( FR(2*M-1) * DCOS((M-1)*THTJ)               
     >                      + FR(2*M)   * DSIN((M-1)*THTJ) )             
              DRM = ( FR(2*M-1) * DCOS((M-1)*THTJ)                       
     >              + FR(2*M)   * DSIN((M-1)*THTJ))                      
              DRMT = RADIUS*(- FR(2*M-1) *dble(M-1)*DSIN((M-1)*THTJ)     
     >                       + FR(2*M)   *dble(M-1)*DCOS((M-1)*THTJ))    
              DRMTR= (-FR(2*M-1)*dble(M-1)*DSIN((M-1)*THTJ)              
     >                +FR(2*M) *dble(M-1)*DCOS((M-1)*THTJ))              
            ELSE                                                        
              RM = RADIUS**(M-1) * ( FR(2*M-1) * DCOS((M-1)*THTJ)        
     >                           + FR(2*M)   * DSIN((M-1)*THTJ) )        
              DRM =(M-1)*RADIUS**(M-2) * ( FR(2*M-1)*DCOS((M-1)*THTJ)  
     >                                  + FR(2*M)   *DSIN((M-1)*THTJ))  
              DRMT = RADIUS**(M-1)*(- FR(2*M-1) *(M-1)*DSIN((M-1)*THTJ)  
     >                              + FR(2*M)   *(M-1)*DCOS((M-1)*THTJ)) 
            DRMTR=(M-1)*RADIUS**(M-2)*(-FR(2*M-1)*(M-1)*DSIN((M-1)*THTJ) 
     >                                 +FR(2*M) *(M-1)*DCOS((M-1)*THTJ)) 
            ENDIF                                                       
            XX(1,NODE) = XX(1,NODE) + RM * DCOS(THTJ)                    
            YY(1,NODE) = YY(1,NODE) + RM * DSIN(THTJ)                    
            XX(2,NODE) = XX(2,NODE) + DRM * DCOS(THTJ)                   
            YY(2,NODE) = YY(2,NODE) + DRM * DSIN(THTJ)                   
            XX(3,NODE) = XX(3,NODE) - RM * DSIN(THTJ) + DRMT*DCOS(THTJ) 
            YY(3,NODE) = YY(3,NODE) + RM * DCOS(THTJ) + DRMT*DSIN(THTJ) 
            XX(4,NODE) = XX(4,NODE) - DRM * DSIN(THTJ)+DRMTR*DCOS(THTJ) 
            YY(4,NODE) = YY(4,NODE) + DRM * DCOS(THTJ)+DRMTR*DSIN(THTJ) 
   30     CONTINUE                                                      
          XX(2,NODE) = - XX(2,NODE) * DR/2.D0 * DS(NR-I+1)                
          XX(3,NODE) =   XX(3,NODE) * DT/2.D0 * DTC(J)                    
          XX(4,NODE) = - XX(4,NODE)*DR/2.D0*DT/2.D0*DTC(J)*DS(NR-I+1) 
          YY(2,NODE) = - YY(2,NODE) * DR/2.D0 * DS(NR-I+1)                
          YY(3,NODE) =   YY(3,NODE) * DT/2.D0 * DTC(J)                    
          YY(4,NODE) = - YY(4,NODE)*DR/2.D0*DT/2.D0*DTC(J)*DS(NR-I+1) 
          PSI(4*(NODE-1)+1) = RADIUS **2                                
          PSI(4*(NODE-1)+2) = - 2.D0* RADIUS * DR / 2.D0 * DS(NR-I+1)       
          PSI(4*(NODE-1)+3) = 0.D0                                        
          PSI(4*(NODE-1)+4) = 0.D0                                        
   20   CONTINUE                                                        
   10 CONTINUE                                                          
      RETURN                                                            
      END                                                               
                                                                        
                                                                        
                                                                        
                                                                        
************************************************************************
      SUBROUTINE CUB1D(X1,X1S,X2,X2S,S,X,XS)                            
C-----------------------------------------------------------------------
C CUBIC HERMITE INTERPOLATION IN ONE DIMENSION                          
C-----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      real*8 H0M,H0P,H1M,H1P,H0MS,H0PS,H1MS,H1PS                          
                                                                         
      H0M  =  (S-1.D0)**2 *(S+2.D0) * 0.25D0                                  
      H0MS =  (S-1.D0)*(S+2.D0)/2.D0 + (S-1.D0)**2 * 0.25D0                       
      H0P  = -(S+1.D0)**2 *(S-2.D0) * 0.25D0                                  
      H0PS = -(S+1.D0)*(S-2.D0)/2.D0 - (S+1.D0)**2 * 0.25D0                       
      H1M  =  (S-1.D0)**2 *(S+1.D0) * 0.25D0                                  
      H1MS =  (S-1.D0)*(S+1.D0)/2.D0 + (S-1.D0)**2 * 0.25D0                       
      H1P  =  (S+1.D0)**2 *(S-1.D0) * 0.25D0                                  
      H1PS =  (S+1.D0)*(S-1.D0)/2.D0 + (S+1.D0)**2 * 0.25D0                       
                                                                        
      X  = X1*H0M  + X1S*H1M +  X2*H0P  + X2S*H1P                       
      XS = X1*H0MS + X1S*H1MS + X2*H0PS + X2S*H1PS                      
      RETURN                                                            
      END                                                               
                                                                        
                                                                        
************************************************************************
      SUBROUTINE FORMKQ(XX,YY,PSI,NR,NP,QQ,A,B,C,EPS,IGAM,ISOL,ITER,IAS)
C---------------------------------------------------------------------- 
C SUBROUTINE TO CALCULATE THE MATRIX KK AND THE RIGHT HAND SIDE ARRAY QQ
C NO BOUNDARY CONDITION ARE YET USED.                                   
C NUMBER OF ROWS AND COLUMNS : 4*NR*NP                                  
C NR : NUMBER OF RADIAL NODES                                           
C NP : NUMBER OF POLOIDAL NODES                                         
C A  : THE TOTAL AMPLITUDE OF THE RHS (HBT DEFINITION)                  
C B  : MEASURE OF THE TOTAL PRESSURE   (HBT DEFINITION)                 
C EPS : THE INVERS ASPECT RATIO                                         
C IGAM=1-4 : HBT GAMMA PROFILE INPUT, 5- : FF' AS INPUT PROFILE.        
C---------------------------------------------------------------------- 
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      COMMON /CORNERS/ RS, IJ, NODENO                                   
      real*8    RS(4,2)                                                   
      integer IJ(4,2), NODENO(MAXMNODE,4)                               
C-----------------------------------------------------------------------
      COMMON /GAUSINT/ XGAUSS,WGAUSS,H,HR,HS,HRS                        
      real*8 XGAUSS(4),WGAUSS(4)                                          
      real*8 H(4,4,4,4),HR(4,4,4,4),HS(4,4,4,4),HRS(4,4,4,4)              
C-----------------------------------------------------------------------
      COMMON/COMSOLV/KKBIG                                              
      real*8 KKBIG(KKLDA,4*MAXNODE)                                       
c      real*8, ALLOCATABLE :: KKBIG(:,:)                                  
c      integer KKLDA                                                    
C-----------------------------------------------------------------------
      real*8 QQ(*)                                                        
      real*8 XX(4,*),YY(4,*),PSI(*)                                       
      real*8 GPX(4,4,MAXNODE),GPJAC(4,4,MAXNODE)                          
      integer INDEX(MAXNODE)                                            
                                                                         
                                                                        
      SAVE GPX,GPJAC,INDEX                                              
                                                                        
      NELM = (NP-1)*(NR-1)                                              
                                                                        
      IF (ITER.EQ.1) THEN                                               
                                                                        
C-----------------------------------------------------------------------
C CALCULATE THE INDEX IN THE MATRIX. IT IS REORDERED FROM               
C CLOCKWISE ORDERING IN THE REST OF HELENA TO SAVE REDUCE THE MATRIX SIZ
C BY A FACTOR OF 2.                                                     
C THE POLOIDAL INDEX J CHANGES TO:                                      
C          JN = 1           (J=1, NP)                                   
C          JN = 2*(J-1),    (2 .LE. J .GE. (NP-1)/2+1)                  
C          JN = 2*(NP-J)+1, ((NP-1)/2 + 2 .LE. J .GE. NP-1)             
C-----------------------------------------------------------------------
      IF (IAS.EQ.1) THEN                                                
        DO I=1,NR                                                       
          J  = 1                                                        
          JN = 1                                                        
          IJ1 = (I-1)*NP     + J                                        
          IJN = (I-1)*(NP-1) + JN                                       
          INDEX(IJ1) = IJN                                              
          DO J=2,(NP-1)/2+1                                             
            JN = 2*(J-1)                                                
	    IJ1 = (I-1)*NP     + J                                             
	    IJN = (I-1)*(NP-1) + JN                                            
	    INDEX(IJ1) = IJN                                                   
          ENDDO                                                         
	  DO J=(NP-1)/2+2,NP                                                   
	    JN = 2*(NP-J)+1                                                    
	    IJ1 = (I-1)*NP     + J                                             
	    IJN = (I-1)*(NP-1) + JN                                            
	    INDEX(IJ1) = IJN                                                   
          ENDDO                                                         
        ENDDO                                                           
      ELSE                                                              
        DO I=1,NR                                                       
	  DO J=1,NP                                                            
	    IJ1 = (I-1)*NP + J                                                 
	    INDEX(IJ1) = IJ1                                                   
	  ENDDO                                                                
	ENDDO                                                                  
      ENDIF	                                                            
C------------------------------------- NELM ELEMENTS ------------------ 
      DO 10 I=1,4*NR*NP                                                 
        DO 20 J=1,KKLDA                                                 
           KKBIG(J,I) = 0.                                              
   20   CONTINUE                                                        
   10 CONTINUE                                                          
      DO 50 N=1,NELM                                                    
        N1 = NODENO(N,1)                                                
        N2 = NODENO(N,2)                                                
        N3 = NODENO(N,3)                                                
        N4 = NODENO(N,4)                                                
C------------------------------------- 4 POINT GAUSSIAN INT. IN R ----- 
        DO 60 NGR=1,4                                                   
          R = XGAUSS(NGR)                                               
          WR = WGAUSS(NGR)                                              
C------------------------------------- 4 POINT GAUSSIAN INT. IN S ----- 
          DO 70 NGS=1,4                                                 
            S  = XGAUSS(NGS)                                            
            WS = WGAUSS(NGS)                                            
            WRS = WR * WS                                               
            CALL INTERP3(XX(1,N1),XX(1,N2),XX(1,N3),XX(1,N4),           
     >                   YY(1,N1),YY(1,N2),YY(1,N3),YY(1,N4),           
     >                PSI(4*(N1-1)+1),PSI(4*(N2-1)+1),PSI(4*(N3-1)+1),  
     >                PSI(4*(N4-1)+1),R,S,X,XR,XS,YR,YS,PS)             
                                                                        
            XJAC =  XR*YS - XS*YR                                       
            GPX(NGR,NGS,N) = X                                          
            GPJAC(NGR,NGS,N) = XJAC                                     
C----------------------------------------- CALCULATE RIGHT HAND SIDE ---
            IF ((IGAM.GE.1).AND.(IGAM.LE.4)) THEN                       
              ARHS = C*DGDPSI(PS) + B*X*(1.D0+EPS*X/2.D0)*DPDPSI(PS)          
            ELSE                                                        
              ARHS = C*DGDPSI(PS) + B*(1.D0+EPS*X)**2 * DPDPSI(PS)        
            ENDIF                                                       
            ARHS = A * ARHS / (1.D0+EPS*X)                                
C---------------------------------------------- SOLOVIEV RHS ---------- 
         IF (ISOL.EQ.1) ARHS=A*(1.D0+B*X*(1.D0+EPS*X/2.))/(1.D0+EPS*X)
C------------------------------------- 4 NODES PER ELEMENT ------------ 
            DO 80 I=1,4                                                 
C------------------------------------- 4 FUNCTIONS V PER NODE --------- 
              DO 90 J=1,4                                               
                NROW = 4*(INDEX(NODENO(N,I)) - 1) + J                   
                SUMQ = - ARHS * H(J,I,NGR,NGS) * XJAC                   
                VX =  YS*HR(J,I,NGR,NGS)  - YR*HS(J,I,NGR,NGS)          
                VY = -XS*HR(J,I,NGR,NGS)  + XR*HS(J,I,NGR,NGS)          
                QQ(NROW) = QQ(NROW) - WRS * SUMQ                        
C------------------------------------- 4 NODES OF FUNCTION PSI -------- 
                DO 100 K=1,4                                            
C------------------------------------- 4 FUNCTIONS H IN PSI ----------- 
                  DO 110 L=1,4                                          
                    NCOL = 4*(INDEX(NODENO(N,K)) - 1) + L               
                    NOFF = NROW - NCOL                                  
                    IF (NOFF.GE.0) THEN                                 
                      PSIX =  YS*HR(L,K,NGR,NGS)  - YR*HS(L,K,NGR,NGS)  
                      PSIY = -XS*HR(L,K,NGR,NGS)  + XR*HS(L,K,NGR,NGS)  
                      SUMK = - 1.D0/(1.D0+EPS*X)*(PSIX*VX+PSIY*VY)/XJAC 
                      KKBIG(NOFF+1,NCOL) = KKBIG(NOFF+1,NCOL)           
     >                                   + WRS * SUMK                   
                    ENDIF                                               
  110             CONTINUE                                              
  100           CONTINUE                                                
   90         CONTINUE                                                  
   80       CONTINUE                                                    
   70     CONTINUE                                                      
   60   CONTINUE                                                        
   50 CONTINUE                                                          
C------------------------------------------- REMOVE EMPTY COLUMNS (BND.)
      NEND = NP - 1                                                     
      IF (IAS.EQ.0) NEND=NP                                             
      DO J=1,NEND                                                       
          KKBIG(1,4*J-3) = 1.D20                                        
          KKBIG(1,4*J-1) = 1.D20                                        
      ENDDO                                                             
C------------------------------------------- IF MATRIX EXISTS THEN      
      ELSE                                                              
      DO 150 N=1,NELM                                                   
        N1 = NODENO(N,1)                                                
        N2 = NODENO(N,2)                                                
        N3 = NODENO(N,3)                                                
        N4 = NODENO(N,4)                                                
C------------------------------------- 4 POINT GAUSSIAN INT. IN R ----- 
        DO 160 NGR=1,4                                                  
          R = XGAUSS(NGR)                                               
          WR = WGAUSS(NGR)                                              
C------------------------------------- 4 POINT GAUSSIAN INT. IN S ----- 
                                                                        
          DO 170 NGS=1,4                                                
            S  = XGAUSS(NGS)                                            
            WS = WGAUSS(NGS)                                            
            X = GPX(NGR,NGS,N)                                          
            XJAC = GPJAC(NGR,NGS,N)                                     
            CALL INTERP1(PSI(4*(N1-1)+1),PSI(4*(N2-1)+1),PSI(4*(N3-1)+1)
     >                  ,PSI(4*(N4-1)+1),R,S,PS)                        
C----------------------------------------- CALCULATE RIGHT HAND SIDE ---
            IF ((IGAM.GE.1).AND.(IGAM.LE.4)) THEN                       
              ARHS = C*DGDPSI(PS) + B*X*(1.D0+EPS*X/2.D0)*DPDPSI(PS)          
            ELSE                                                        
              ARHS = C*DGDPSI(PS) + B*(1.D0+EPS*X)**2 * DPDPSI(PS)        
            ENDIF                                                       
            ARHS = A * ARHS / (1.+EPS*X)                                
C---------------------------------------------- SOLOVIEV RHS ---------- 
       IF (ISOL.EQ.1) ARHS=A*(1.D0+ B*X*(1.D0+EPS*X/2.D0))/(1.D0+EPS*X)
C------------------------------------- 4 NODES PER ELEMENT ------------ 
            DO 180 I=1,4                                                
C------------------------------------- 4 FUNCTIONS V PER NODE --------- 
              DO 190 J=1,4                                              
                NROW = 4*(INDEX(NODENO(N,I)) - 1) + J                   
                SUMQ = - ARHS * H(J,I,NGR,NGS) * XJAC                   
                QQ(NROW) = QQ(NROW) - WR * WS * SUMQ                    
  190         CONTINUE                                                  
  180       CONTINUE                                                    
  170     CONTINUE                                                      
  160   CONTINUE                                                        
  150 CONTINUE                                                          
      ENDIF                                                             
      RETURN                                                            
      END                                                               
                                                                        
************************************************************************
      SUBROUTINE INIPRES                                                
C------------------------------------------------------------------     
C INITIALIZING THE ARRAY DPRES(1001) USED BY FUNCTION DPDPSI            
C------------------------------------------------------------------     
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      COMMON / COMDAT/                                                  
     >        ELLIP,TRIAH,TRIAB,QUAD,PAR1,PAR2,PAR3,PAR4,                      
     >        AGA,BGA,CGA,DGA,EGA,FGA,GGA,HGA,                          
     >        API,BPI,CPI,DPI,EPI,FPI,GPI,HPI,                          
     >        ACUR,BCUR,CCUR,DCUR,ECUR,FCUR,GCUR,HCUR,                  
     >        ERRIT,ERRCUR,EPS,ALFA,B,C,XIAB,Q95,BETAP,AMIX,BMIX,       
     >        ABB, BBB, AMPL, RVAC,BVAC,ZEFF,ZN0,RPE,XR1,SIG1,          
     >        IAS,ICUR,NRCUR,NPCUR,NMESH,INIMESH,NBB,NQB,IARC,          
     >        MHARM,ISHAPE,ISOL,IGAM,IPAI,NR,NP,NRMAP,NPMAP,NITER       
      real*8    ELLIP,TRIAH,TRIAB,QUAD,PAR1,PAR2,PAR3,PAR4,                      
     >        AGA,BGA,CGA,DGA,EGA,FGA,GGA,HGA,                          
     >        API,BPI,CPI,DPI,EPI,FPI,GPI,HPI,                          
     >        ACUR,BCUR,CCUR,DCUR,ECUR,FCUR,GCUR,HCUR,                  
     >        ERRIT,ERRCUR,EPS,ALFA,B,C,XIAB,Q95,BETAP,AMIX,BMIX,       
     >        ABB, BBB, AMPL, RVAC,BVAC,ZEFF,ZN0,RPE,XR1,SIG1           
      integer IAS,ICUR,NRCUR,NPCUR,NMESH,INIMESH,NBB,NQB,IARC,          
     >        MHARM,ISHAPE,ISOL,IGAM,IPAI,NR,NP,NRMAP,NPMAP,NITER       
C-----------------------------------------------------------------------
      COMMON/COMPROF/DPR,DF2,ZJZ,QIN,DPRES,DGAM,PINT,GINT,NPTS          
      real*8    DPR(NPTSMAX),DF2(NPTSMAX),ZJZ(NPTSMAX),QIN(NPTSMAX),      
     >        DPRES(1001),DGAM(1001),PINT(1001),GINT(1001)              
      integer NPTS                                                      
C-----------------------------------------------------------------------
                                                                         
      NPT=1001                                                          
      DO 10 I=1,NPT                                                     
        PSI = dble(I-1)/dble(NPT-1)                                     
        DPS = 1.D0 / dble(NPTS-1)                                            
        NINT = INT(dble(NPTS-1)*DSQRT(PSI)) + 1                                    
        IF (PSI.GE.1.) NINT=NPTS-1                                      
         DPDPSI = DPR(NINT) + (DSQRT(PSI)-DPS*dble(NINT-1))/DPS *                 
     >                         (DPR(NINT+1)-DPR(NINT))                  
         DPRES(I) = DPDPSI
   10 CONTINUE                                                          
      DPS = 1.D0/dble(NPT-1)
      SUM = 0.D0                                                          
      PINT(NPT) = 0.D0                                                    
      DO I=1,NPT-1                                                      
        SUM = SUM + (DPRES(NPT-I+1)+DPRES(NPT-I))*DPS/2.D0                
        PINT(NPT-I) = SUM                                               
      ENDDO                                                             
      RETURN                                                            
      END                                                               
                                                 
                                                                        
                                                                        
************************************************************************
      REAL*8 FUNCTION DPDPSI(PSI)                                              
C------------------------------------------------------------------     
C THE NORMALIZED PROFILE OF THE PRESSURE GRADIENT VERSUS FLUX           
C THIS ROUTINE MUST BE INITIALIZED BY A CALL TO INIPRES                 
C------------------------------------------------------------------     
      IMPLICIT REAL*8 (A-H,O-Z)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      COMMON / COMDAT/                                                  
     >        ELLIP,TRIAH,TRIAB,QUAD,PAR1,PAR2,PAR3,PAR4,                      
     >        AGA,BGA,CGA,DGA,EGA,FGA,GGA,HGA,                          
     >        API,BPI,CPI,DPI,EPI,FPI,GPI,HPI,                          
     >        ACUR,BCUR,CCUR,DCUR,ECUR,FCUR,GCUR,HCUR,                  
     >        ERRIT,ERRCUR,EPS,ALFA,B,C,XIAB,Q95,BETAP,AMIX,BMIX,       
     >        ABB, BBB, AMPL, RVAC,BVAC,ZEFF,ZN0,RPE,XR1,SIG1,          
     >        IAS,ICUR,NRCUR,NPCUR,NMESH,INIMESH,NBB,NQB,IARC,          
     >        MHARM,ISHAPE,ISOL,IGAM,IPAI,NR,NP,NRMAP,NPMAP,NITER       
      real*8    ELLIP,TRIAH,TRIAB,QUAD,PAR1,PAR2,PAR3,PAR4,                      
     >        AGA,BGA,CGA,DGA,EGA,FGA,GGA,HGA,                          
     >        API,BPI,CPI,DPI,EPI,FPI,GPI,HPI,                          
     >        ACUR,BCUR,CCUR,DCUR,ECUR,FCUR,GCUR,HCUR,                  
     >        ERRIT,ERRCUR,EPS,ALFA,B,C,XIAB,Q95,BETAP,AMIX,BMIX,       
     >        ABB, BBB, AMPL, RVAC,BVAC,ZEFF,ZN0,RPE,XR1,SIG1           
      integer IAS,ICUR,NRCUR,NPCUR,NMESH,INIMESH,NBB,NQB,IARC,          
     >        MHARM,ISHAPE,ISOL,IGAM,IPAI,NR,NP,NRMAP,NPMAP,NITER       
C-----------------------------------------------------------------------
      COMMON/COMPROF/DPR,DF2,ZJZ,QIN,DPRES,DGAM,PINT,GINT,NPTS          
      real*8    DPR(NPTSMAX),DF2(NPTSMAX),ZJZ(NPTSMAX),QIN(NPTSMAX),      
     >        DPRES(1001),DGAM(1001),PINT(1001),GINT(1001)              
      integer NPTS                                                      
C-----------------------------------------------------------------------
      NPT = 1001                                                        
      DPS = 1.D0 /dble(NPT-1)
      NINT = MAX(INT(dble(NPT-1)*PSI) + 1,1)
      IF (PSI.GE.1.) NINT=NPT-1                                         
      DPDPSI = DPRES(NINT) + (PSI-DPS*dble(NINT-1))/DPS *                 
     >                         (DPRES(NINT+1)-DPRES(NINT))              
      RETURN                                                            
      END                                                               
************************************************************************
      SUBROUTINE INIGAM                                                 
C---------------------------------------------------------------------  
C SUBROUTINE TO INITIALIZE THE ARRAY DGAM USED IN THE FUNCTION DGDPSI   
C------------------------------------------------------------------     
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      COMMON / COMDAT/                                                  
     >        ELLIP,TRIAH,TRIAB,QUAD,PAR1,PAR2,PAR3,PAR4,                      
     >        AGA,BGA,CGA,DGA,EGA,FGA,GGA,HGA,                          
     >        API,BPI,CPI,DPI,EPI,FPI,GPI,HPI,                          
     >        ACUR,BCUR,CCUR,DCUR,ECUR,FCUR,GCUR,HCUR,                  
     >        ERRIT,ERRCUR,EPS,ALFA,B,C,XIAB,Q95,BETAP,AMIX,BMIX,       
     >        ABB, BBB, AMPL, RVAC,BVAC,ZEFF,ZN0,RPE,XR1,SIG1,          
     >        IAS,ICUR,NRCUR,NPCUR,NMESH,INIMESH,NBB,NQB,IARC,          
     >        MHARM,ISHAPE,ISOL,IGAM,IPAI,NR,NP,NRMAP,NPMAP,NITER       
      real*8    ELLIP,TRIAH,TRIAB,QUAD,PAR1,PAR2,PAR3,PAR4,                      
     >        AGA,BGA,CGA,DGA,EGA,FGA,GGA,HGA,                          
     >        API,BPI,CPI,DPI,EPI,FPI,GPI,HPI,                          
     >        ACUR,BCUR,CCUR,DCUR,ECUR,FCUR,GCUR,HCUR,                  
     >        ERRIT,ERRCUR,EPS,ALFA,B,C,XIAB,Q95,BETAP,AMIX,BMIX,       
     >        ABB, BBB, AMPL, RVAC,BVAC,ZEFF,ZN0,RPE,XR1,SIG1           
      integer IAS,ICUR,NRCUR,NPCUR,NMESH,INIMESH,NBB,NQB,IARC,          
     >        MHARM,ISHAPE,ISOL,IGAM,IPAI,NR,NP,NRMAP,NPMAP,NITER       
C-----------------------------------------------------------------------
      COMMON/COMPROF/DPR,DF2,ZJZ,QIN,DPRES,DGAM,PINT,GINT,NPTS          
      real*8    DPR(NPTSMAX),DF2(NPTSMAX),ZJZ(NPTSMAX),QIN(NPTSMAX),      
     >        DPRES(1001),DGAM(1001),PINT(1001),GINT(1001)              
      integer NPTS                                                      
C-----------------------------------------------------------------------
                                                                         
      NPT=1001                                                          
      DO 10 I=1,NPT                                                     
        PSI = dble(I-1)/dble(NPT-1)                                     
        DPS = 1.D0 / dble(NPTS-1)                                            
        NINT = INT((NPTS-1)*DSQRT(PSI)) + 1                                    
        IF (PSI.GE.1.) NINT=NPTS-1                                      
        DGDPSI = DF2(NINT) + (DSQRT(PSI)-DPS*(NINT-1))/DPS *                   
     >                           (DF2(NINT+1)-DF2(NINT))                
        DGAM(I) = DGDPSI                                                
   10 CONTINUE                                                          
      DPS = 1.D0/dble(NPT-1)                                              
      SUM = 0.D0                                                          
      GINT(NPT) = 0.D0                                                    
      DO I=1,NPT-1                                                      
        SUM = SUM + (DGAM(NPT-I+1)+DGAM(NPT-I))*DPS/2.D0                  
        GINT(NPT-I) = SUM                                               
      ENDDO                                                             
                                                                        
      RETURN                                                            
      END                                                               
************************************************************************
      REAL*8 FUNCTION DGDPSI(PSI)                                              
C------------------------------------------------------------------     
C THE NORMALIZED PROFILE OF GRADIENT OF GAMMA VERSUS FLUX               
C------------------------------------------------------------------     
      IMPLICIT REAL*8 (A-H,O-Z)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      COMMON / COMDAT/                                                  
     >        ELLIP,TRIAH,TRIAB,QUAD,PAR1,PAR2,PAR3,PAR4,                      
     >        AGA,BGA,CGA,DGA,EGA,FGA,GGA,HGA,                          
     >        API,BPI,CPI,DPI,EPI,FPI,GPI,HPI,                          
     >        ACUR,BCUR,CCUR,DCUR,ECUR,FCUR,GCUR,HCUR,                  
     >        ERRIT,ERRCUR,EPS,ALFA,B,C,XIAB,Q95,BETAP,AMIX,BMIX,       
     >        ABB, BBB, AMPL, RVAC,BVAC,ZEFF,ZN0,RPE,XR1,SIG1,          
     >        IAS,ICUR,NRCUR,NPCUR,NMESH,INIMESH,NBB,NQB,IARC,          
     >        MHARM,ISHAPE,ISOL,IGAM,IPAI,NR,NP,NRMAP,NPMAP,NITER       
      real*8    ELLIP,TRIAH,TRIAB,QUAD,PAR1,PAR2,PAR3,PAR4,                      
     >        AGA,BGA,CGA,DGA,EGA,FGA,GGA,HGA,                          
     >        API,BPI,CPI,DPI,EPI,FPI,GPI,HPI,                          
     >        ACUR,BCUR,CCUR,DCUR,ECUR,FCUR,GCUR,HCUR,                  
     >        ERRIT,ERRCUR,EPS,ALFA,B,C,XIAB,Q95,BETAP,AMIX,BMIX,       
     >        ABB, BBB, AMPL, RVAC,BVAC,ZEFF,ZN0,RPE,XR1,SIG1           
      integer IAS,ICUR,NRCUR,NPCUR,NMESH,INIMESH,NBB,NQB,IARC,          
     >        MHARM,ISHAPE,ISOL,IGAM,IPAI,NR,NP,NRMAP,NPMAP,NITER       
C-----------------------------------------------------------------------
      COMMON/COMPROF/DPR,DF2,ZJZ,QIN,DPRES,DGAM,PINT,GINT,NPTS          
      real*8    DPR(NPTSMAX),DF2(NPTSMAX),ZJZ(NPTSMAX),QIN(NPTSMAX),      
     >        DPRES(1001),DGAM(1001),PINT(1001),GINT(1001)              
      integer NPTS                                                      
C-----------------------------------------------------------------------
      NPT=1001                                                          
      DPS = 1.D0/dble(NPT-1)                                              
      NINT = MAX(INT((NPT-1)*(PSI)) + 1,1)                                     
      IF (PSI.GE.1.) NINT=NPT-1                                         
      DGDPSI = DGAM(NINT) + ((PSI)-DPS*(NINT-1))/DPS *                  
     >                         (DGAM(NINT+1)-DGAM(NINT))                
      RETURN                                                            
      END                                                               
************************************************************************
      REAL*8 FUNCTION CURPHI(PSI)                                              
C------------------------------------------------------------------     
C THE NORMALIZED PROFILE OF THE CURRENT DENSITY VERSUS FLUX             
C------------------------------------------------------------------     
      IMPLICIT REAL*8 (A-H,O-Z)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      COMMON / COMDAT/                                                  
     >        ELLIP,TRIAH,TRIAB,QUAD,PAR1,PAR2,PAR3,PAR4,                      
     >        AGA,BGA,CGA,DGA,EGA,FGA,GGA,HGA,                          
     >        API,BPI,CPI,DPI,EPI,FPI,GPI,HPI,                          
     >        ACUR,BCUR,CCUR,DCUR,ECUR,FCUR,GCUR,HCUR,                  
     >        ERRIT,ERRCUR,EPS,ALFA,B,C,XIAB,Q95,BETAP,AMIX,BMIX,       
     >        ABB, BBB, AMPL, RVAC,BVAC,ZEFF,ZN0,RPE,XR1,SIG1,          
     >        IAS,ICUR,NRCUR,NPCUR,NMESH,INIMESH,NBB,NQB,IARC,          
     >        MHARM,ISHAPE,ISOL,IGAM,IPAI,NR,NP,NRMAP,NPMAP,NITER       
      real*8    ELLIP,TRIAH,TRIAB,QUAD,PAR1,PAR2,PAR3,PAR4,                      
     >        AGA,BGA,CGA,DGA,EGA,FGA,GGA,HGA,                          
     >        API,BPI,CPI,DPI,EPI,FPI,GPI,HPI,                          
     >        ACUR,BCUR,CCUR,DCUR,ECUR,FCUR,GCUR,HCUR,                  
     >        ERRIT,ERRCUR,EPS,ALFA,B,C,XIAB,Q95,BETAP,AMIX,BMIX,       
     >        ABB, BBB, AMPL, RVAC,BVAC,ZEFF,ZN0,RPE,XR1,SIG1           
      integer IAS,ICUR,NRCUR,NPCUR,NMESH,INIMESH,NBB,NQB,IARC,          
     >        MHARM,ISHAPE,ISOL,IGAM,IPAI,NR,NP,NRMAP,NPMAP,NITER       
C-----------------------------------------------------------------------
      COMMON/COMPROF/DPR,DF2,ZJZ,QIN,DPRES,DGAM,PINT,GINT,NPTS          
      real*8    DPR(NPTSMAX),DF2(NPTSMAX),ZJZ(NPTSMAX),QIN(NPTSMAX),      
     >        DPRES(1001),DGAM(1001),PINT(1001),GINT(1001)              
      integer NPTS                                                      
C-----------------------------------------------------------------------
                                                                        
      DPS = 1./dble(NPTS-1)                                             
      NINT = INT((NPTS-1)*DSQRT(PSI)) + 1                                      
      IF (PSI.GE.1.) NINT=NPTS-1                                        
      CURPHI = ZJZ(NINT) + (DSQRT(PSI)-DPS*(NINT-1))/DPS *                     
     >                         (ZJZ(NINT+1)-ZJZ(NINT))                  
      RETURN                                                            
      END                                                               
                                                                        
                                                                        
************************************************************************
      SUBROUTINE INTERP(XN1,XN2,XN3,XN4,R,S,X,XR,XS,XRS,XRR,XSS)        
C---------------------------------------------------------------------- 
C SUBROUTINE CALCULATES THE INTERPOLATED VALUE OF THE FUNCTION X GIVEN  
C BY XI(1..4) AT THE FOUR NODES USING BI-CUBIC HERMITE ELEMENTS         
C---------------------------------------------------------------------- 
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      COMMON /CORNERS/ RS, IJ, NODENO                                   
      real*8    RS(4,2)                                                   
      integer IJ(4,2), NODENO(MAXMNODE,4)                               
C-----------------------------------------------------------------------
      real*8 XN1(4),XN2(4),XN3(4),XN4(4)                                  
                                                                        
      HI0M   = - (R-1.)**2 * (-R-2.) * 0.25                             
      HRI0M  = - (R-1.)*(-R-2.)*0.5 +(R-1.)**2 * 0.25                   
      HRRI0M = + 1.5 * R                                                
      HI1M   = - (R-1.)**2 * (-R-1.) * 0.25                             
      HRI1M  = - (R-1.)*(-R-1.)*0.5 + (R-1.)**2 *0.25                   
      HRRI1M = + 1.5 * R - .5                                           
                                                                        
      HJ0M   = - (S-1.)**2 * (-S-2.) * 0.25                             
      HSJ0M  = - (S-1.)*(-S-2.)*0.5 +(S-1.)**2 * 0.25                   
      HSSJ0M = + 1.5 * S                                                
      HJ1M   = - (S-1.)**2 * (-S-1.) * 0.25                             
      HSJ1M  = - (S-1.)*(-S-1.)*0.5 + (S-1.)**2 * 0.25                  
      HSSJ1M = + 1.5 * S - .5                                           
                                                                        
      HI0P   = - (R+1.)**2 * (R-2.) * 0.25                              
      HRI0P  = - (R+1.)*(R-2.)*0.5 - (R+1.)**2 * 0.25                   
      HRRI0P = - 1.5 * R                                                
      HI1P   = + (R+1.)**2 * (R-1.) * 0.25                              
      HRI1P  = + (R+1.)*(R-1.)*0.5 + (R+1.)**2 * 0.25                   
      HRRI1P = + 1.5 * R + .5                                           
                                                                        
      HJ0P  = - (S+1.)**2 * (S-2.) * 0.25                               
      HSJ0P = - (S+1.)*(S-2.)*0.5 - (S+1.)**2 * 0.25                    
      HSSJ0P = - 1.5 * S                                                
      HJ1P  = + (S+1.)**2 * (S-1.) * 0.25                               
      HSJ1P = + (S+1.)*(S-1.)*0.5 + (S+1.)**2 * 0.25                    
      HSSJ1P = + 1.5 * S + .5                                           
                                                                        
      X = HI0M*HJ0M * XN1(1) + HI1M*HJ0M * XN1(2)                       
     >  + HI0M*HJ1M * XN1(3) + HI1M*HJ1M * XN1(4)                       
     >  + HI0M*HJ0P * XN2(1) + HI1M*HJ0P * XN2(2)                       
     >  + HI0M*HJ1P * XN2(3) + HI1M*HJ1P * XN2(4)                       
     >  + HI0P*HJ0M * XN4(1) + HI1P*HJ0M * XN4(2)                       
     >  + HI0P*HJ1M * XN4(3) + HI1P*HJ1M * XN4(4)                       
     >  + HI0P*HJ0P * XN3(1) + HI1P*HJ0P * XN3(2)                       
     >  + HI0P*HJ1P * XN3(3) + HI1P*HJ1P * XN3(4)                       
                                                                        
      XR = HRI0M*HJ0M * XN1(1) + HRI1M*HJ0M * XN1(2)                    
     >   + HRI0M*HJ1M * XN1(3) + HRI1M*HJ1M * XN1(4)                    
     >   + HRI0M*HJ0P * XN2(1) + HRI1M*HJ0P * XN2(2)                    
     >   + HRI0M*HJ1P * XN2(3) + HRI1M*HJ1P * XN2(4)                    
     >   + HRI0P*HJ0M * XN4(1) + HRI1P*HJ0M * XN4(2)                    
     >   + HRI0P*HJ1M * XN4(3) + HRI1P*HJ1M * XN4(4)                    
     >   + HRI0P*HJ0P * XN3(1) + HRI1P*HJ0P * XN3(2)                    
     >   + HRI0P*HJ1P * XN3(3) + HRI1P*HJ1P * XN3(4)                    
                                                                        
      XS = HI0M*HSJ0M * XN1(1) + HI1M*HSJ0M * XN1(2)                    
     >   + HI0M*HSJ1M * XN1(3) + HI1M*HSJ1M * XN1(4)                    
     >   + HI0M*HSJ0P * XN2(1) + HI1M*HSJ0P * XN2(2)                    
     >   + HI0M*HSJ1P * XN2(3) + HI1M*HSJ1P * XN2(4)                    
     >   + HI0P*HSJ0M * XN4(1) + HI1P*HSJ0M * XN4(2)                    
     >   + HI0P*HSJ1M * XN4(3) + HI1P*HSJ1M * XN4(4)                    
     >   + HI0P*HSJ0P * XN3(1) + HI1P*HSJ0P * XN3(2)                    
     >   + HI0P*HSJ1P * XN3(3) + HI1P*HSJ1P * XN3(4)                    
                                                                        
      XRR = HRRI0M*HJ0M * XN1(1) + HRRI1M*HJ0M * XN1(2)                 
     >    + HRRI0M*HJ1M * XN1(3) + HRRI1M*HJ1M * XN1(4)                 
     >    + HRRI0M*HJ0P * XN2(1) + HRRI1M*HJ0P * XN2(2)                 
     >    + HRRI0M*HJ1P * XN2(3) + HRRI1M*HJ1P * XN2(4)                 
     >    + HRRI0P*HJ0M * XN4(1) + HRRI1P*HJ0M * XN4(2)                 
     >    + HRRI0P*HJ1M * XN4(3) + HRRI1P*HJ1M * XN4(4)                 
     >    + HRRI0P*HJ0P * XN3(1) + HRRI1P*HJ0P * XN3(2)                 
     >    + HRRI0P*HJ1P * XN3(3) + HRRI1P*HJ1P * XN3(4)                 
                                                                        
      XSS = HI0M*HSSJ0M * XN1(1) + HI1M*HSSJ0M * XN1(2)                 
     >    + HI0M*HSSJ1M * XN1(3) + HI1M*HSSJ1M * XN1(4)                 
     >    + HI0M*HSSJ0P * XN2(1) + HI1M*HSSJ0P * XN2(2)                 
     >    + HI0M*HSSJ1P * XN2(3) + HI1M*HSSJ1P * XN2(4)                 
     >    + HI0P*HSSJ0M * XN4(1) + HI1P*HSSJ0M * XN4(2)                 
     >    + HI0P*HSSJ1M * XN4(3) + HI1P*HSSJ1M * XN4(4)                 
     >    + HI0P*HSSJ0P * XN3(1) + HI1P*HSSJ0P * XN3(2)                 
     >    + HI0P*HSSJ1P * XN3(3) + HI1P*HSSJ1P * XN3(4)                 
                                                                        
      XRS = HRI0M*HSJ0M * XN1(1) + HRI1M*HSJ0M * XN1(2)                 
     >    + HRI0M*HSJ1M * XN1(3) + HRI1M*HSJ1M * XN1(4)                 
     >    + HRI0M*HSJ0P * XN2(1) + HRI1M*HSJ0P * XN2(2)                 
     >    + HRI0M*HSJ1P * XN2(3) + HRI1M*HSJ1P * XN2(4)                 
     >    + HRI0P*HSJ0M * XN4(1) + HRI1P*HSJ0M * XN4(2)                 
     >    + HRI0P*HSJ1M * XN4(3) + HRI1P*HSJ1M * XN4(4)                 
     >    + HRI0P*HSJ0P * XN3(1) + HRI1P*HSJ0P * XN3(2)                 
     >    + HRI0P*HSJ1P * XN3(3) + HRI1P*HSJ1P * XN3(4)                 
                                                                        
      RETURN                                                            
      END                                                               
                                                                        
                                                                        
************************************************************************
      SUBROUTINE INTERP1(XN1,XN2,XN3,XN4,R,S,X)                         
C---------------------------------------------------------------------- 
C SUBROUTINE CALCULATES THE INTERPOLATED VALUE OF THE FUNCTION X GIVEN  
C BY XI(1..4) AT THE FOUR NODES USING BI-CUBIC HERMITE ELEMENTS         
C---------------------------------------------------------------------- 
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      COMMON /CORNERS/ RS, IJ, NODENO                                   
      real*8    RS(4,2)                                                   
      integer IJ(4,2), NODENO(MAXMNODE,4)                               
C-----------------------------------------------------------------------
      real*8 XN1(4),XN2(4),XN3(4),XN4(4)                                  
                                                                         
      HI0M  = - (R-1.D0)**2 * (-R-2.D0) * 0.25D0                              
      HI1M  = - (R-1.D0)**2 * (-R-1.D0) * 0.25D0                              
                                                                        
      HJ0M  = - (S-1.D0)**2 * (-S-2.D0) * 0.25D0                              
      HJ1M  = - (S-1.D0)**2 * (-S-1.D0) * 0.25D0                              
                                                                        
      HI0P  = - (R+1.D0)**2 * (R-2.D0)  * 0.25D0                              
      HI1P  = + (R+1.D0)**2 * (R-1.D0)  * 0.25D0                              
                                                                        
      HJ0P  = - (S+1.D0)**2 * (S-2.D0)  * 0.25D0                              
      HJ1P  = + (S+1.D0)**2 * (S-1.D0)  * 0.25D0                              
                                                                        
      X = HI0M*HJ0M * XN1(1) + HI1M*HJ0M * XN1(2)                       
     >  + HI0M*HJ1M * XN1(3) + HI1M*HJ1M * XN1(4)                       
     >  + HI0M*HJ0P * XN2(1) + HI1M*HJ0P * XN2(2)                       
     >  + HI0M*HJ1P * XN2(3) + HI1M*HJ1P * XN2(4)                       
     >  + HI0P*HJ0M * XN4(1) + HI1P*HJ0M * XN4(2)                       
     >  + HI0P*HJ1M * XN4(3) + HI1P*HJ1M * XN4(4)                       
     >  + HI0P*HJ0P * XN3(1) + HI1P*HJ0P * XN3(2)                       
     >  + HI0P*HJ1P * XN3(3) + HI1P*HJ1P * XN3(4)                       
                                                                        
      RETURN                                                            
      END                                                               
                                                                        
************************************************************************
      SUBROUTINE INTERP2(XN1,XN2,XN3,XN4,R,S,X,XR,XS)                   
C---------------------------------------------------------------------- 
C SUBROUTINE CALCULATES THE INTERPOLATED VALUE OF THE FUNCTION X GIVEN  
C BY XI(1..4) AT THE FOUR NODES USING BI-CUBIC HERMITE ELEMENTS         
C---------------------------------------------------------------------- 
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      COMMON /CORNERS/ RS, IJ, NODENO                                   
      real*8    RS(4,2)                                                   
      integer IJ(4,2), NODENO(MAXMNODE,4)                               
C-----------------------------------------------------------------------
      real*8 XN1(4),XN2(4),XN3(4),XN4(4)                                  
                                                                         
      HI0M  = - (R-1.D0)**2 * (-R-2.D0) * 0.25D0                              
      HRI0M = - (R-1.D0)*(-R-2.D0)*0.5D0 +(R-1.D0)**2 * 0.25D0                    
      HI1M  = - (R-1.D0)**2 * (-R-1.D0) * 0.25D0                              
      HRI1M = - (R-1.D0)*(-R-1.D0)*0.5D0 + (R-1.D0)**2 * 0.25D0                   
      HJ0M  = - (S-1.D0)**2 * (-S-2.D0) * 0.25D0                              
      HSJ0M = - (S-1.D0)*(-S-2.D0)*0.5D0 +(S-1.D0)**2  * 0.25D0                   
      HJ1M  = - (S-1.D0)**2 * (-S-1.D0) * 0.25D0                              
      HSJ1M = - (S-1.D0)*(-S-1.D0)*0.5D0 + (S-1.D0)**2 * 0.25D0                   
                                                                        
      HI0P  = - (R+1.D0)**2 * (R-2.D0) * 0.25D0                               
      HRI0P = - (R+1.D0)*(R-2.D0)*0.5D0 - (R+1.D0)**2 * 0.25D0                    
      HI1P  = + (R+1.D0)**2 * (R-1.D0) * 0.25D0                               
      HRI1P = + (R+1.D0)*(R-1.D0)*0.5D0 + (R+1.D0)**2 * 0.25D0                    
                                                                        
      HJ0P  = - (S+1.D0)**2 * (S-2.D0) * 0.25D0                               
      HSJ0P = - (S+1.D0)*(S-2.D0)*0.5D0 - (S+1.D0)**2 * 0.25D0                    
      HJ1P  = + (S+1.D0)**2 * (S-1.D0) * 0.25D0                               
      HSJ1P = + (S+1.D0)*(S-1.D0)*0.5D0 + (S+1.D0)**2 * 0.25D0                    
                                                                        
      X = HI0M*HJ0M * XN1(1) + HI1M*HJ0M * XN1(2)                       
     >  + HI0M*HJ1M * XN1(3) + HI1M*HJ1M * XN1(4)                       
     >  + HI0M*HJ0P * XN2(1) + HI1M*HJ0P * XN2(2)                       
     >  + HI0M*HJ1P * XN2(3) + HI1M*HJ1P * XN2(4)                       
     >  + HI0P*HJ0M * XN4(1) + HI1P*HJ0M * XN4(2)                       
     >  + HI0P*HJ1M * XN4(3) + HI1P*HJ1M * XN4(4)                       
     >  + HI0P*HJ0P * XN3(1) + HI1P*HJ0P * XN3(2)                       
     >  + HI0P*HJ1P * XN3(3) + HI1P*HJ1P * XN3(4)                       
                                                                        
      XR = HRI0M*HJ0M * XN1(1) + HRI1M*HJ0M * XN1(2)                    
     >   + HRI0M*HJ1M * XN1(3) + HRI1M*HJ1M * XN1(4)                    
     >   + HRI0M*HJ0P * XN2(1) + HRI1M*HJ0P * XN2(2)                    
     >   + HRI0M*HJ1P * XN2(3) + HRI1M*HJ1P * XN2(4)                    
     >   + HRI0P*HJ0M * XN4(1) + HRI1P*HJ0M * XN4(2)                    
     >   + HRI0P*HJ1M * XN4(3) + HRI1P*HJ1M * XN4(4)                    
     >   + HRI0P*HJ0P * XN3(1) + HRI1P*HJ0P * XN3(2)                    
     >   + HRI0P*HJ1P * XN3(3) + HRI1P*HJ1P * XN3(4)                    
                                                                        
      XS = HI0M*HSJ0M * XN1(1) + HI1M*HSJ0M * XN1(2)                    
     >   + HI0M*HSJ1M * XN1(3) + HI1M*HSJ1M * XN1(4)                    
     >   + HI0M*HSJ0P * XN2(1) + HI1M*HSJ0P * XN2(2)                    
     >   + HI0M*HSJ1P * XN2(3) + HI1M*HSJ1P * XN2(4)                    
     >   + HI0P*HSJ0M * XN4(1) + HI1P*HSJ0M * XN4(2)                    
     >   + HI0P*HSJ1M * XN4(3) + HI1P*HSJ1M * XN4(4)                    
     >   + HI0P*HSJ0P * XN3(1) + HI1P*HSJ0P * XN3(2)                    
     >   + HI0P*HSJ1P * XN3(3) + HI1P*HSJ1P * XN3(4)                    
                                                                        
      RETURN                                                            
      END                                                               
                                                                        
      SUBROUTINE INTERP3(XN1,XN2,XN3,XN4,                               
     >                   YN1,YN2,YN3,YN4,                               
     >                   PN1,PN2,PN3,PN4,R,S,                           
     >                   X,XR,XS,YR,YS,PS)                              
C---------------------------------------------------------------------- 
C SUBROUTINE CALCULATES THE INTERPOLATED VALUE OF THE FUNCTION X GIVEN  
C BY XI(1..4) AT THE FOUR NODES USING BI-CUBIC HERMITE ELEMENTS         
C---------------------------------------------------------------------- 
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      real*8 XN1(4),XN2(4),XN3(4),XN4(4)                                  
      real*8 YN1(4),YN2(4),YN3(4),YN4(4)                                  
      real*8 PN1(4),PN2(4),PN3(4),PN4(4)                                  
                                                                        
      HI0M  = - (R-1.D0)**2 * (-R-2.D0) * 0.25D0                              
      HRI0M = - (R-1.D0)*(-R-2.D0)*0.5D0 +(R-1.D0)**2 * 0.25D0                    
      HI1M  = - (R-1.D0)**2 * (-R-1.D0) * 0.25D0                              
      HRI1M = - (R-1.D0)*(-R-1.D0)*0.5D0 + (R-1.D0)**2 * 0.25D0                  
      HJ0M  = - (S-1.D0)**2 * (-S-2.D0) * 0.25D0                              
      HSJ0M = - (S-1.D0)*(-S-2.D0)*0.5D0 +(S-1.D0)**2  * 0.25D0                   
      HJ1M  = - (S-1.D0)**2 * (-S-1.D0) * 0.25D0                              
      HSJ1M = - (S-1.D0)*(-S-1.D0)*0.5D0 + (S-1.D0)**2 * 0.25D0                   
                                                                        
      HI0P  = - (R+1.D0)**2 * (R-2.D0) * 0.25D0                               
      HRI0P = - (R+1.D0)*(R-2.D0)*0.5D0 - (R+1.D0)**2 * 0.25D0                    
      HI1P  = + (R+1.D0)**2 * (R-1.D0) * 0.25D0                               
      HRI1P = + (R+1.D0)*(R-1.D0)*0.5D0 + (R+1.D0)**2 * 0.25D0                    
                                                                        
      HJ0P  = - (S+1.D0)**2 * (S-2.D0) * 0.25D0                               
      HSJ0P = - (S+1.D0)*(S-2.D0)*0.5D0 - (S+1.D0)**2 * 0.25D0                    
      HJ1P  = + (S+1.D0)**2 * (S-1.D0) * 0.25                               
      HSJ1P = + (S+1.D0)*(S-1.D0)*0.5D0 + (S+1.D0)**2 * 0.25D0                    
                                                                        
      X = HI0M*HJ0M * XN1(1) + HI1M*HJ0M * XN1(2)                       
     >  + HI0M*HJ1M * XN1(3) + HI1M*HJ1M * XN1(4)                       
     >  + HI0M*HJ0P * XN2(1) + HI1M*HJ0P * XN2(2)                       
     >  + HI0M*HJ1P * XN2(3) + HI1M*HJ1P * XN2(4)                       
     >  + HI0P*HJ0M * XN4(1) + HI1P*HJ0M * XN4(2)                       
     >  + HI0P*HJ1M * XN4(3) + HI1P*HJ1M * XN4(4)                       
     >  + HI0P*HJ0P * XN3(1) + HI1P*HJ0P * XN3(2)                       
     >  + HI0P*HJ1P * XN3(3) + HI1P*HJ1P * XN3(4)                       
                                                                        
      XR = HRI0M*HJ0M * XN1(1) + HRI1M*HJ0M * XN1(2)                    
     >   + HRI0M*HJ1M * XN1(3) + HRI1M*HJ1M * XN1(4)                    
     >   + HRI0M*HJ0P * XN2(1) + HRI1M*HJ0P * XN2(2)                    
     >   + HRI0M*HJ1P * XN2(3) + HRI1M*HJ1P * XN2(4)                    
     >   + HRI0P*HJ0M * XN4(1) + HRI1P*HJ0M * XN4(2)                    
     >   + HRI0P*HJ1M * XN4(3) + HRI1P*HJ1M * XN4(4)                    
     >   + HRI0P*HJ0P * XN3(1) + HRI1P*HJ0P * XN3(2)                    
     >   + HRI0P*HJ1P * XN3(3) + HRI1P*HJ1P * XN3(4)                    
                                                                        
      XS = HI0M*HSJ0M * XN1(1) + HI1M*HSJ0M * XN1(2)                    
     >   + HI0M*HSJ1M * XN1(3) + HI1M*HSJ1M * XN1(4)                    
     >   + HI0M*HSJ0P * XN2(1) + HI1M*HSJ0P * XN2(2)                    
     >   + HI0M*HSJ1P * XN2(3) + HI1M*HSJ1P * XN2(4)                    
     >   + HI0P*HSJ0M * XN4(1) + HI1P*HSJ0M * XN4(2)                    
     >   + HI0P*HSJ1M * XN4(3) + HI1P*HSJ1M * XN4(4)                    
     >   + HI0P*HSJ0P * XN3(1) + HI1P*HSJ0P * XN3(2)                    
     >   + HI0P*HSJ1P * XN3(3) + HI1P*HSJ1P * XN3(4)                    
                                                                        
      PS= HI0M*HJ0M * PN1(1) + HI1M*HJ0M * PN1(2)                       
     >  + HI0M*HJ1M * PN1(3) + HI1M*HJ1M * PN1(4)                       
     >  + HI0M*HJ0P * PN2(1) + HI1M*HJ0P * PN2(2)                       
     >  + HI0M*HJ1P * PN2(3) + HI1M*HJ1P * PN2(4)                       
     >  + HI0P*HJ0M * PN4(1) + HI1P*HJ0M * PN4(2)                       
     >  + HI0P*HJ1M * PN4(3) + HI1P*HJ1M * PN4(4)                       
     >  + HI0P*HJ0P * PN3(1) + HI1P*HJ0P * PN3(2)                       
     >  + HI0P*HJ1P * PN3(3) + HI1P*HJ1P * PN3(4)                       
                                                                        
      YR = HRI0M*HJ0M * YN1(1) + HRI1M*HJ0M * YN1(2)                    
     >   + HRI0M*HJ1M * YN1(3) + HRI1M*HJ1M * YN1(4)                    
     >   + HRI0M*HJ0P * YN2(1) + HRI1M*HJ0P * YN2(2)                    
     >   + HRI0M*HJ1P * YN2(3) + HRI1M*HJ1P * YN2(4)                    
     >   + HRI0P*HJ0M * YN4(1) + HRI1P*HJ0M * YN4(2)                    
     >   + HRI0P*HJ1M * YN4(3) + HRI1P*HJ1M * YN4(4)                    
     >   + HRI0P*HJ0P * YN3(1) + HRI1P*HJ0P * YN3(2)                    
     >   + HRI0P*HJ1P * YN3(3) + HRI1P*HJ1P * YN3(4)                    
                                                                        
      YS = HI0M*HSJ0M * YN1(1) + HI1M*HSJ0M * YN1(2)                    
     >   + HI0M*HSJ1M * YN1(3) + HI1M*HSJ1M * YN1(4)                    
     >   + HI0M*HSJ0P * YN2(1) + HI1M*HSJ0P * YN2(2)                    
     >   + HI0M*HSJ1P * YN2(3) + HI1M*HSJ1P * YN2(4)                    
     >   + HI0P*HSJ0M * YN4(1) + HI1P*HSJ0M * YN4(2)                    
     >   + HI0P*HSJ1M * YN4(3) + HI1P*HSJ1M * YN4(4)                    
     >   + HI0P*HSJ0P * YN3(1) + HI1P*HSJ0P * YN3(2)                    
     >   + HI0P*HSJ1P * YN3(3) + HI1P*HSJ1P * YN3(4)                    
                                                                        
      RETURN                                                            
      END                                                               
                                                                        
                                                                        
************************************************************************
      SUBROUTINE SOLVE2(QQ,NR,NP,PSI,ITER,IAS)                          
C-----------------------------------------------------------------------
C SUBROUTINE TO SOLVE THE SYSTEM OF EQUATIONS USING GAUSSIAN ELIMINATION
C-----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      COMMON/COMSOLV/KKBIG                                              
      real*8 KKBIG(KKLDA,4*MAXNODE)                                       
c      real*8, ALLOCATABLE :: KKBIG(:,:)                                  
c      integer KKLDA                                                    
C-----------------------------------------------------------------------
      real*8    QQ(*),PSI(*)                                              
      integer INDEX(MAXNODE)                                            
                                                                         
      SAVE INDEX                                                        
                                                                        
      IF (ITER.EQ.1) THEN                                               
C------------------------------INVERSE OF INDEX IN FORMKQ TO RESTORE    
      IF (IAS.EQ.1) THEN                                                
        DO I=1,NR                                                       
          J  = 1                                                        
          JN = 1                                                        
          IJ1 = (I-1)*NP     + J                                        
	  IJN = (I-1)*(NP-1) + JN                                              
	  INDEX(IJN) = IJ1                                                     
          DO J=2,(NP-1)/2+1                                             
            JN = 2*(J-1)                                                
	    IJ1 = (I-1)*NP     + J                                             
	    IJN = (I-1)*(NP-1) + JN                                            
	    INDEX(IJN) = IJ1                                                   
          ENDDO                                                         
	  DO J=(NP-1)/2+2,NP-1                                                 
	    JN = 2*(NP-J)+1                                                    
	    IJ1 = (I-1)*NP     + J                                             
	    IJN = (I-1)*(NP-1) + JN                                            
	    INDEX(IJN) = IJ1                                                   
          ENDDO                                                         
        ENDDO                                                           
      ENDIF                                                             
      IF (IAS.EQ.0) THEN                                                
         ND = 4*NR*NP                                                   
      ELSE                                                              
         ND = 4*NR*(NP-1)                                               
      ENDIF                                                             
c---------------------------------------------------- ESSL version      
c        CALL DPBF(KKBIG,KKLDA,ND,4*NP+8)                               
c---------------------------------------------------- lapack version    
        CALL DPBTRF('L',ND,4*NP+7,KKBIG,KKLDA,INFO)                     
      ENDIF                                                             
                                                                        
      DO 220 I=1,4*NR*NP                                                
        PSI(I) = QQ(I)                                                  
  220 CONTINUE                                                          
c-------------------------------------------------- ESSL version        
c      CALL DPBS(KKBIG,KKLDA,ND,4*NP+8,PSI)                             
c-------------------------------------------------- lapack version      
      IF (IAS.EQ.0) THEN                                                
         ND = 4*NR*NP                                                   
      ELSE                                                              
         ND = 4*NR*(NP-1)                                               
      ENDIF   
      CALL DPBTRS('L',ND,4*NP+7,1,KKBIG,KKLDA,PSI,4*MAXMNODE,INFO)      
                                                                        
c-------------- restore to simple clockwise numbering                   
      IF (IAS.EQ.1) THEN                                                
        DO I=1,4*NR*NP                                                  
          QQ(I) = PSI(I)                                                
        ENDDO                                                           
        DO I=1,NR*(NP-1)                                                
          DO K=1,4                                                      
	    IK = 4*(I-1)+K                                                     
	    IKN = 4*(INDEX(I)-1)+K                                             
            PSI(IKN) = QQ(IK)                                           
          ENDDO                                                         
        ENDDO                                                           
        DO I=1,NR                                                       
          DO K=1,4                                                      
	    IK  = 4*(I-1)*NP + K                                               
	    IK2 = 4*(I-1)*NP + 4*(NP-1) + K                                    
            PSI(IK2) = PSI(IK)                                          
          ENDDO                                                         
        ENDDO                                                           
      ENDIF                                                             
c-------------------------------- fill in boundary conditions           
      DO 225 I=1,NR*NP                                                  
        PSI(4*(I-1)+1) = PSI(4*(I-1)+1) + 1.                            
  225 CONTINUE                                                          
      DO 100 J=1,NP                                                     
        PSI(4*J-3) = 1.                                                 
        PSI(4*J-1) = 0.                                                 
  100 CONTINUE                                                          
      IF (IAS.EQ.1) THEN                                                
        DO 230 I=1,NR                                                   
          DO 240 K=1,4                                                  
            NBASE = 4*(I-1)*NP + K                                      
            NBASE2 = NBASE + 4*(NP-1)                                   
            PSI(NBASE2) = PSI(NBASE)                                    
  240     CONTINUE                                                      
  230   CONTINUE                                                        
      ENDIF                                                             
CCC      CALL PRARR1('PSI : ',PSI,4*NR*NP,203)                          
                                                                        
      RETURN                                                            
      END                                                               
                                                                        
                                                                        
************************************************************************
      SUBROUTINE FINDAXIS(XX,YY,NR,NP,PSAXIS,XAXIS,YAXIS,               
     >                    NAX,RAX,SAX,IAS,IFAIL)                              
C-----------------------------------------------------------------------
C SUBROUTINE TO LOCALIZE THE POSITION OF THE MAGNETIC AXIS ; THE MINIMUM
C OF PSI OF ALL ELEMENTS                                                
C-----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      COMMON /CORNERS/ RS, IJ, NODENO                                   
      real*8    RS(4,2)                                                   
      integer IJ(4,2), NODENO(MAXMNODE,4)                               
C-----------------------------------------------------------------------
      COMMON/FAXIS/PSI,NAXIS                                            
      real*8    PSI(4*MAXMNODE)                                           
      integer NAXIS                                                     
C-----------------------------------------------------------------------
      real*8 XX(4,*),YY(4,*)                                              
      REAL*8 X(2),FVEC(2),FJAC(2,2)                                  
                                                                        
      PSMIN = 1.D20                                                     
      IF (IAS.EQ.1) THEN                                                
c----------------------------------- asymmetric part -----------        
      NELM = (NR-1)*(NP-1)                                              
      XERR = 1D-8                                                       
      XTOL = 1D-4                                                       
      TOLL = 1.D0 + XTOL                                                  
      NEQ2 = 2                                                          
      LDFJAC = 2                                                        
      LWA = 15                                                          
      NTRIAL=50                                                         
      TOLX = 1.D-8                                                    
      TOLF = 1.D-8    
      IFAIL2 = 1                                                  
      DO I=NELM,NELM/2,-1                                               
        NAXIS = I                                                       
        IFAIL = 1                                                       
        X(1) = 0.D0                                                       
        X(2) = 0.D0                                                       
        call mnewtax(ntrial,x,neq2,tolx,tolf,xerr,ferr,ifail)                 
c        if ((xerr.le.tolx).or.(ferr.le.tolf)) then                      
c          ifail = 0                                                    
c        else                                                            
c         WRITE(*,*) ' accuracy not reached : ',xerr,ferr              
c        endif                                                           
        R = X(1)                                                        
        S = X(2)                                                        
        IF ((IFAIL.EQ.0).AND.                                           
     >      ((DABS(R).LE.TOLL).AND.(DABS(S).LE.TOLL))) THEN   
          N1 = NODENO(NAXIS,1)                                          
          N2 = NODENO(NAXIS,2)                                          
          N3 = NODENO(NAXIS,3)                                          
          N4 = NODENO(NAXIS,4)                                          
          CALL INTERP(PSI(4*(N1-1)+1),PSI(4*(N2-1)+1),                  
     >                PSI(4*(N3-1)+1),PSI(4*(N4-1)+1),                  
     >                R,S,ZPSI,ZPSIR,ZPSIS,ZPSIRS,ZPSIRR,ZPSISS)        

          IF (ZPSI.LT.PSMIN) THEN                                       
            PSMIN = ZPSI                                                
            NAX = NAXIS                                                 
            NNAX = NAXIS                                                
            RAX = R                                                     
            SAX = S  
	    IFAIL2 = 0                                                   
          ENDIF     
        ENDIF                                                           
      ENDDO     
      IF (IFAIL2.EQ.0) THEN                                                        
      N1 = NODENO(NNAX,1)                                               
      N2 = NODENO(NNAX,2)                                               
      N3 = NODENO(NNAX,3)                                               
      N4 = NODENO(NNAX,4)                                               
      CALL INTERP1(XX(1,N1),XX(1,N2),XX(1,N3),XX(1,N4),RAX,SAX,XAXIS)   
      CALL INTERP1(YY(1,N1),YY(1,N2),YY(1,N3),YY(1,N4),RAX,SAX,YAXIS)   
      PSAXIS = PSMIN                                                    
      IFAIL  = IFAIL2
      ENDIF                                                                  
      ELSE                                                              
c**************************************** SYMMETRIC PART ***************
      DO N=1, (NR-1)*(NP-1), NP-1                                       
        N1 = NODENO(N,1)                                                
        N2 = NODENO(N,4)                                                
        IF  (PSI(4*(N1-1)+2)*PSI(4*(N2-1)+2).LE.0.) THEN                
C------------------------------------- QUAD. EQ FOR R VALUE AT MINIMUM -
          PSIM  = PSI(4*(N1-1)+1)                                       
          PSIMR = PSI(4*(N1-1)+2)                                       
          PSIP  = PSI(4*(N2-1)+1)                                       
          PSIPR = PSI(4*(N2-1)+2)                                       
          AA =  3.D0 * (PSIM + PSIMR - PSIP + PSIPR ) / 4.D0                
          BB =  ( - PSIMR + PSIPR ) / 2.D0                                
          CC =  ( - 3.D0*PSIM - PSIMR + 3.D0*PSIP - PSIPR) / 4.D0               
          DET = BB*BB - 4.D0*AA*CC   
	  IF (DET.GE.0.D0) THEN
            R  = ROOT(AA,BB,CC,DET,1.D0)                                    
            IF (DABS(R).GT.1.+1.D-8) THEN                                  
              R = ROOT(AA,BB,CC,DET,-1.D0)                                  
            ENDIF
C-------- THE DSIGN OF R CHANGES FOR ELEMENTS ON THE LEFT  (SEE REMESH) -
          CALL CUB1D(XX(1,N1),XX(2,N1),XX(1,N2),XX(2,N2),R,XAXIS,DUMMY) 
            CALL CUB1D(PSIM,PSIMR,PSIP,PSIPR,R,PSAXIS,DUMMY)              
            IF (PSAXIS.LT.PSMIN) THEN                                     
              PSMIN = PSAXIS                                              
              NAX  = N                                                    
              NAX1 = N1                                                   
              NAX2 = N2                                                   
              RAX = R                                                     
	      SAX = -1.D0                                                          
c            WRITE(*,*) 'LOCAL MINIMUM AT XAXIS = ',XAXIS              
            ENDIF
	  ENDIF
        ENDIF                                                           
      ENDDO                                                             
      DO  N=NP-1, (NR-1)*(NP-1), NP-1                                   
        N1 = NODENO(N,2)                                                
        N2 = NODENO(N,3)                                                
        IF  (PSI(4*(N1-1)+2)*PSI(4*(N2-1)+2).LT.0.) THEN                
C------------------------------------- QUAD. EQ FOR R VALUE AT MINIMUM -
          PSIM  = PSI(4*(N1-1)+1)                                       
          PSIMR = PSI(4*(N1-1)+2)                                       
          PSIP  = PSI(4*(N2-1)+1)                                       
          PSIPR = PSI(4*(N2-1)+2)                                       
          AA =  3.D0 * (PSIM + PSIMR - PSIP + PSIPR ) / 4.D0                
          BB =  ( - PSIMR + PSIPR ) / 2.D0                                
          CC =  ( - 3.D0*PSIM - PSIMR + 3.D0*PSIP - PSIPR) / 4.D0               
          DET = BB*BB - 4.D0*AA*CC         
	  IF (DET.GE.0.D0) THEN
            R  = ROOT(AA,BB,CC,DET,1.D0)                                    
            IF (DABS(R).GT.1.D0+1.D-8) THEN                                  
              R = ROOT(AA,BB,CC,DET,-1.D0)                                  
            ENDIF                                                         
C-------- THE DSIGN OF R CHANGES FOR ELEMENTS ON THE LEFT  (SEE REMESH) -
          CALL CUB1D(XX(1,N1),XX(2,N1),XX(1,N2),XX(2,N2),R,XAXIS,DUMMY) 
            CALL CUB1D(PSIM,PSIMR,PSIP,PSIPR,R,PSAXIS,DUMMY)              
            IF (PSAXIS.LT.PSMIN) THEN                                     
              PSMIN = PSAXIS                                              
              NAX  = N                                                    
              NAX1 = N1                                                   
              NAX2 = N2                                                   
              RAX = R                                                     
	      SAX = 1.D0                                                           
c             WRITE(*,*) 'LOCAL MINIMUM AT XAXIS = ',XAXIS              
            ENDIF  
	  ENDIF
        ENDIF                                                           
      ENDDO                                                             
      YAXIS = 0.D0   
      IFAIL  = 0                                                     
      ENDIF                                                             
      RETURN                                                            
      END                                                               
                                                                        
*********************************************************************** 
      SUBROUTINE FZERO2(N,X,FVEC,FJAC,LDFJAC,IFLAG)                     
C---------------------------------------------------------------------- 
C SOLUTION DETERMINES THE MINIMUM OF THE FLUX IN ONE ELEMENT            
C---------------------------------------------------------------------- 
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      COMMON /CORNERS/ RS, IJ, NODENO                                   
      real*8    RS(4,2)                                                   
      integer IJ(4,2), NODENO(MAXMNODE,4)                               
C-----------------------------------------------------------------------
      COMMON/FAXIS/PSI,NAXIS                                            
      real*8    PSI(4*MAXMNODE)                                           
      integer NAXIS                                                     
C-----------------------------------------------------------------------
      real*8 X(N),FVEC(N),FJAC(LDFJAC,N)                                  
                                                                        
      R = X(1)                                                          
      S = X(2)                                                          
      N1 = NODENO(NAXIS,1)                                              
      N2 = NODENO(NAXIS,2)                                              
      N3 = NODENO(NAXIS,3)                                              
      N4 = NODENO(NAXIS,4)                                              
      CALL INTERP(PSI(4*(N1-1)+1),PSI(4*(N2-1)+1),                      
     >            PSI(4*(N3-1)+1),PSI(4*(N4-1)+1),                      
     >            R,S,ZPSI,ZPSIR,ZPSIS,ZPSIRS,ZPSIRR,ZPSISS)            
      IF (IFLAG.EQ.1) THEN                                              
        FVEC(1) = ZPSIR                                                 
        FVEC(2) = ZPSIS                                                 
      ENDIF                                                             
      IF (IFLAG.EQ.2) THEN                                              
        FJAC(1,1) = ZPSIRR                                              
        FJAC(1,2) = ZPSIRS                                              
        FJAC(2,1) = ZPSIRS                                              
        FJAC(2,2) = ZPSISS                                              
      ENDIF                                                             
      RETURN                                                            
      END                                                               
                                                                        
************************************************************************
      REAL*8 FUNCTION ROOT(A,B,C,D,SGN)                                        
C---------------------------------------------------------------------  
C THIS FUNCTION GIVES BETTER ROOTS OF QUADRATICS BY AVOIDING            
C CANCELLATION OF SMALLER ROOT                                          
C---------------------------------------------------------------------  
      IMPLICIT REAL*8 (A-H,O-Z)
      IF (B*SGN .GE. 0.D0) THEN                                          
        ROOT = -2.D0*C/(B+SGN*DSQRT(DABS(D)))                                   
      ELSE                                                              
        ROOT = (-B + SGN*DSQRT(DABS(D))) / (2.D0 * A)                           
      ENDIF                                                             
      RETURN                                                            
      END                                                               
************************************************************************
      SUBROUTINE NORMAL(PSI,NR,NP,PSAXIS)                               
C-----------------------------------------------------------------------
C SUBROUTINE TO NORMALIZE PSI TO ONE ON THE BOUNDARY AND ZERO ON AXIS   
C-----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      real*8 PSI(*)                                                       
                                                                        
      DO 60 I=1,NR*NP                                                   
        PSI(4*(I-1)+1) = 1. - (1.- PSI(4*(I-1)+1)) / (1.- PSAXIS)       
        DO 70 L=2,4                                                     
          PSI(4*(I-1)+L) = PSI(4*(I-1)+L) / (1. - PSAXIS)               
   70   CONTINUE                                                        
   60 CONTINUE                                                          
      RETURN                                                            
      END                                                               
                                                                        
                                                                        
************************************************************************
       SUBROUTINE REMESH(XX,YY,PSI,A,B,C,EPS,NR,NP,NRNEW,NPNEW,MESHNO,  
     >                  CX,CY,XAXIS,YAXIS,NAX,RAX,SAX,IGAM,IAS,IFAIL)         
C---------------------------------------------------------------------  
C FORM THE SYSTEM OF NEW FINITE ELEMENTS AS FLUX COORDINATES USING      
C THE EXACT INTERPOLATION                                               
C   XX,YY,PSI : ON EXIT CONTAIN THE VALUES ON THE NEW GRID              
C   NR,NP     : THE NUMBER RADIAL AND POLOIDAL POINTS IN THE OLD GRID   
C   NRNEW,NPNEW :         ,,                ,,         IN THE NEW GRID  
C   XAXIS : POSITION OF MAGNETIC AXIS                                   
C   NAX1,NAX2 : NODENUMBERS OF ELEMENT WITH MAGNETIC AXIS               
C   RAX : R VALUE OF MAGNETIC AXIS                                      
C---------------------------------------------------------------------- 
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      COMMON /CORNERS/ RS, IJ, NODENO                                   
      real*8    RS(4,2)                                                   
      integer IJ(4,2), NODENO(MAXMNODE,4)                               
C-----------------------------------------------------------------------
      COMMON/MESH2/XXOLD,YYOLD,PSIOLD                                   
      real*8    XXOLD(4,MAXNODE),YYOLD(4,MAXNODE),PSIOLD(4*MAXNODE)       
C-----------------------------------------------------------------------
      COMMON /NODES/ PSIKN,THTKN,RADPSI,DPSIKN,DDPSIKN                                   
      REAL*8    PSIKN(NRMMAX),THTKN(NPMMAX),RADPSI(NRMMAX) 
      REAL*8    DPSIKN(NRMMAX),DDPSIKN(NRMMAX)
C-----------------------------------------------------------------------
      COMMON/TOLERA/PSITOL,THTTOL,TOL                                   
      real*8    PSITOL,THTTOL,TOL                                         
C-----------------------------------------------------------------------
      real*8 XX(4,*), YY(4,*), PSI(*)                                     
      integer NSYM(2*NR-2),SSYM(2*NR-2),ISEARCH(2*NRMAX)                                 
      LOGICAL FOUND,NOBRACK,CHAGR(MAXMNODE)                             
                                                                        
      PI = 2.D0 * DASIN(1.D0)                                                
      TOLTHT = 1.D-6                                                    
      TOLPSI = 1.D-6                                                    
                                                                
      FACTAS = 1.D0                                                       
      IF (IAS.EQ.0) FACTAS = 2.D0                                         
                                                                        
      DO I=1,NR-1                                                       
        NSYM(I) = (I-1)*(NP-1) + 1                                      
        SSYM(I) = -1.D0                                                   
        NSYM(NR-1+I) = (NR-1)*(NP-1) - (I-1)*(NP-1)                     
        SSYM(NR-1+I) = +1.D0                                              
      ENDDO                                                             
                                                                        
      DO 5 I=1,NRNEW                                                    
        RPSI =  dble(I-1)/dble(NRNEW-1)                                 
        PSID = RPSI**2                                                  
        PSIKN(NRNEW-I+1) = PSID                                         
        RADPSI(NRNEW-I+1) = RPSI                                        
   5  CONTINUE                                                          
      RADPSI(NRNEW) = 0.D0                                                
      PSIKN(NRNEW) = 0.D0                                                 
C      CALL PRARR1('PSI VALUES : ',PSIKN,NRNEW,203)                     
      DO 6 J=1,NPNEW                                                    
        THTKN(J) = (1.D0+dble(IAS)) * PI * dble(J-1)/dble(NPNEW-1)       
    6 CONTINUE                                                          
      MESHNO = MESHNO + 1                                               
C------------------------- UPDATE OLD MESH FOR THE FIRST ITERATION ---- 
      DO 8 I= 1,NRNEW*NPNEW                                             
        CHAGR(I) = .FALSE.                                              
    8 CONTINUE                                                          
      DO 10 I = 1,NR*NP                                                 
        DO 20 K=1,4                                                     
          XXOLD(K,I) = XX(K,I)                                          
          YYOLD(K,I) = YY(K,I)                                          
          PSIOLD(4*(I-1)+K) = PSI(4*(I-1)+K)                            
   20   CONTINUE                                                        
   10 CONTINUE                                                          
      IS = 0                                               
      DO I=1,NR
        IF (XAXIS .GT. 0.) THEN
          IELM = NAX - (I-1)*(NP-1) 
	ELSE
	  IELM = (I-1) * (NP-1)  + 1
	ENDIF
	IF ((IELM .GT. 0). AND. (IELM .LE. (NR-1)*(NP-1))) THEN 
	  ISEARCH(IS+1) = IELM
	  IS = IS + 1
	ENDIF
      ENDDO  
      IF (XAXIS .LT. 0.) THEN
        DO I=1,NR
	  IELM = NAX + (I-1)*(NP-1)
	  IF ((IELM .GT. 0). AND. (IELM .LE. (NR-1)*(NP-1))) THEN 
	    ISEARCH(IS+1) = IELM
	    IS = IS + 1
	  ENDIF
        ENDDO
      ENDIF  
      NSEARCH = IS                                                                            
C--------------------------- LOOP OVER ALL FLUXSURFACES -----------     
      DO 30 I=1,NRNEW-1                                                 
        PSIVAL=PSIKN(I)      
c        WRITE(*,*) ' FINDING SURFACE : ',PSIVAL,NAX                    
C--------------------------- FIND STARTING POINT OF FLUXCONTOUR         
        DO 40 IN=1,NSEARCH     
          N = ISEARCH(IN)
          N1 = NODENO(N,1)                                              
          N2 = NODENO(N,2)                                              
          N3 = NODENO(N,3)                                              
          N4 = NODENO(N,4)                                              
C------------------------------------- QUAD. EQ FOR R VALUE AT MINIMUM -
          RR = -1.D0                                                      
          CALL INTERP2(PSIOLD(4*(N1-1)+1),PSIOLD(4*(N2-1)+1),           
     >                 PSIOLD(4*(N3-1)+1),PSIOLD(4*(N4-1)+1),           
     >                 RR,SAX,PSIM,PSIMR,DPSIS)                         
          RR = +1.D0                                                      
          CALL INTERP2(PSIOLD(4*(N1-1)+1),PSIOLD(4*(N2-1)+1),           
     >                 PSIOLD(4*(N3-1)+1),PSIOLD(4*(N4-1)+1),           
     >                 RR,SAX,PSIP,PSIPR,DPSIS)                         
          AA =  3.D0 * (PSIM + PSIMR - PSIP + PSIPR ) / 4.D0                
          BB =  ( - PSIMR + PSIPR ) / 2.D0                                
          CC =  ( - 3.D0*PSIM - PSIMR + 3.D0*PSIP - PSIPR) / 4.D0               
          DET = BB*BB - 4.D0*AA*CC                                        
          R = 999.D0                                                      
          IF (DET .GE. 0.D0) THEN                                          
            R = ROOT(AA,BB,CC,DET,1.D0)                                   
            IF (DABS(R).GT.1.D0) THEN                                      
              R = ROOT(AA,BB,CC,DET,-1.D0)                                
            ENDIF                                                       
          ENDIF                                                         
          IF (DABS(R).GT.1.D0) THEN                                        
            PSIMIN=MIN(PSIM,PSIP)                                       
            PSIMAX=MAX(PSIM,PSIP)                                       
          ELSE                                                          
            CALL INTERP2(PSIOLD(4*(N1-1)+1),PSIOLD(4*(N2-1)+1),         
     >                 PSIOLD(4*(N3-1)+1),PSIOLD(4*(N4-1)+1),           
     >                 R,SAX,PS,DPSIR,DPSIS)                            
            PSIMIN=MIN(MIN(PSIM,PS),PSIP)                               
            PSIMAX=MAX(MAX(PSIM,PS),PSIP)                               
          ENDIF                                                         
          IF ((PSIVAL.GE.PSIMIN-PSITOL).AND.                            
     >        (PSIVAL.LE.PSIMAX+PSITOL))THEN                            
            A3 = (PSIM+PSIMR-PSIP+PSIPR)/4.D0                             
            A2 = (- PSIMR + PSIPR)/4.D0                                   
            A1=(-3.D0*PSIM-PSIMR+3.D0*PSIP-PSIPR)/4.D0                          
            A0=( 2.D0*PSIM+PSIMR+2.D0*PSIP-PSIPR)/4.D0-PSIVAL                   
            CALL SOLVP3(A0,A1,A2,A3,RR,R2,R3,IFAIL)                     
            CALL INTERP2(PSIOLD(4*(N1-1)+1),PSIOLD(4*(N2-1)+1),         
     >                   PSIOLD(4*(N3-1)+1),PSIOLD(4*(N4-1)+1),         
     >                   RR,SAX,PS,DPSIR,DPSIS)                         
            CALL INTERP2(XXOLD(1,N1),XXOLD(1,N2),                       
     >                   XXOLD(1,N3),XXOLD(1,N4),                       
     >                   RR,SAX,ZX,DXR,DXS)                             

	         IF (ZX.LT.XAXIS) THEN                                       
c              WRITE(*,*) ' NODE ON WRONG SIDE : ',ZX,XAXIS,R2             
              RR = R2                                                   
              CALL INTERP2(PSIOLD(4*(N1-1)+1),PSIOLD(4*(N2-1)+1),       
     >                     PSIOLD(4*(N3-1)+1),PSIOLD(4*(N4-1)+1),       
     >                     RR,SAX,PS,DPSIR,DPSIS)                       
              CALL INTERP2(XXOLD(1,N1),XXOLD(1,N2),                     
     >                     XXOLD(1,N3),XXOLD(1,N4),                     
     >                     RR,SAX,ZX,DXR,DXS)                           
            ENDIF   
c            write(*,*) 'RR=',RR,ZX,XAXIS,PS                                                    
            IF ((DABS(RR).LE.1.D0+1.D-5).AND.(ZX.GE.XAXIS)) GOTO 45        
c------------------ special case psi=1.                 
            IF ((I.EQ.1).AND.(DABS(PS-PSIVAL).LT.1.D-5)) THEN  
              RR = -1.D0                                                  
              GOTO 45                                                   
            ENDIF                                                       
          ENDIF                                                         
   40   CONTINUE                                                        
c        WRITE(*,*) ' STARTING VALUE NOT FOUND : ',PSIVAL,RR,PS          
	IFAIL=1
	RETURN      
   45   CONTINUE                                                        
c--------------------------- starting position found ----------------   
        CALL INTERP2(YYOLD(1,N1),YYOLD(1,N2),                           
     >               YYOLD(1,N3),YYOLD(1,N4),RR,SAX,ZY,DYR,DYS)         
        THT0 = DATAN2(ZY-YAXIS,ZX-XAXIS)                                 
        IF (THT0.LT.0.D0) THT0 = THT0 + 2.D0*PI                             
C----------------------------- trace fluxsurface to find theta values   
        DD = 0.1D0*(PSIVAL)**0.33D0 / FACTAS                                
        IPREV = 0                                                       
        JPREV = 0                                                       
        SS = SAX                                                        
        NN = N                                                          
        THT1 = THT0                                                     
        THT2 = THT0                                                     
        ITMAX = 5000                                                    
        ITTEST = 0                                                      
	NOBRACK = .TRUE.                                                       
        DO 50 J=1,NPNEW                                                 
	  If (IAS.EQ.1) THEN                                                   
            JINDEX = MOD(INT(THT0/(2.D0*PI)*NPNEW) + J,NPNEW)+1           
	  ELSE                                                                 
	    JINDEX = J                                                         
	  ENDIF                                                                
          THTVAL = THTKN(JINDEX)                                        
          FOUND = .FALSE.                                               
                                                                        
c---------------------------------- treat theta=pi as special point     
          IF ((J.EQ.NPNEW).AND.(IAS.EQ.0)) THEN                         
            DO 140 NS=1, 2*NR-2                                         
              N  = NSYM(NS)                                             
              SS = SSYM(NS)                                             
              N1 = NODENO(N,1)                                          
              N2 = NODENO(N,2)                                          
              N3 = NODENO(N,3)                                          
              N4 = NODENO(N,4)                                          
              RR = -1.D0                                                  
              CALL INTERP2(PSIOLD(4*(N1-1)+1),PSIOLD(4*(N2-1)+1),       
     >                 PSIOLD(4*(N3-1)+1),PSIOLD(4*(N4-1)+1),           
     >                 RR,SS,PSIM,PSIMR,DPSIS)                          
              RR = +1.D0                                                  
              CALL INTERP2(PSIOLD(4*(N1-1)+1),PSIOLD(4*(N2-1)+1),       
     >                 PSIOLD(4*(N3-1)+1),PSIOLD(4*(N4-1)+1),           
     >                 RR,SS,PSIP,PSIPR,DPSIS)                          
              A3 = (PSIM+PSIMR-PSIP+PSIPR)/4.D0                           
              A2 = (- PSIMR + PSIPR)/4.D0                                 
              A1=(-3.D0*PSIM-PSIMR+3.D0*PSIP-PSIPR)/4.D0                        
              A0=( 2.D0*PSIM+PSIMR+2.D0*PSIP-PSIPR)/4.D0-PSIVAL                 
              CALL SOLVP3(A0,A1,A2,A3,RR,R2,R3,IFAIL)                   
              CALL INTERP2(PSIOLD(4*(N1-1)+1),PSIOLD(4*(N2-1)+1),       
     >                     PSIOLD(4*(N3-1)+1),PSIOLD(4*(N4-1)+1),       
     >                     RR,SS,PS,DPSIR,DPSIS)                        
              CALL INTERP2(XXOLD(1,N1),XXOLD(1,N2),                     
     >                     XXOLD(1,N3),XXOLD(1,N4),                     
     >                     RR,SS,ZX,DXR,DXS)                            
              IF (ZX.GT.XAXIS) THEN                                     
C                WRITE(*,*) ' NODE ON WRONG SIDE : ',ZX,XAXIS           
                 RR = R2                                                
                 CALL INTERP2(PSIOLD(4*(N1-1)+1),PSIOLD(4*(N2-1)+1),    
     >                        PSIOLD(4*(N3-1)+1),PSIOLD(4*(N4-1)+1),    
     >                        RR,SS,PS,DPSIR,DPSIS)                     
                 CALL INTERP2(XXOLD(1,N1),XXOLD(1,N2),                  
     >                        XXOLD(1,N3),XXOLD(1,N4),                  
     >                        RR,SS,ZX,DXR,DXS)                         
              ENDIF                               
              IF ((DABS(RR).LE.1.D0+1.D-5).AND.(ZX.LT.XAXIS)               
     >                                 .AND.(ZX.GE.-1.D0-1.D-8)) THEN     
                FOUND = .TRUE.                                          
                NN = N                                                  
                NOBRACK= .FALSE.
                GOTO 145                                                
              ENDIF                                                     
  140       CONTINUE                                                    
          ENDIF                                                         
  145     CONTINUE                                                      
                                                                        
                                                                        
      	  DO ITN=1,ITMAX                                                 
            N1 = NODENO(NN,1)                                           
            N2 = NODENO(NN,2)                                           
            N3 = NODENO(NN,3)                                           
            N4 = NODENO(NN,4)                                           
            CALL INTERP2(XXOLD(1,N1),XXOLD(1,N2),                       
     >                   XXOLD(1,N3),XXOLD(1,N4),RR,SS,ZX,ZXR,ZXS)      
            CALL INTERP2(YYOLD(1,N1),YYOLD(1,N2),                       
     >                   YYOLD(1,N3),YYOLD(1,N4),RR,SS,ZY,ZYR,ZYS)      
            CALL INTERP2(PSIOLD(4*(N1-1)+1),PSIOLD(4*(N2-1)+1),         
     >                   PSIOLD(4*(N3-1)+1),PSIOLD(4*(N4-1)+1),         
     >                   RR,SS,PS,DPSIR,DPSIS)                          
            THT = DATAN2(ZY-YAXIS,ZX-XAXIS)                              
                                                                        
            IF (THT.LT.0.D0) THT = THT + 2.D0*PI                             
            IF (NOBRACK) THEN                                           
              THT1 = THT2                                               
              THT2 = THT                                                
	    ELSEIF (FOUND) THEN                                                
	      THT1 = THT                                                       
            ENDIF  
            IF (((DABS(THTVAL-THT).LT.TOLTHT) .OR.                       
     >           (DABS(THTVAL-THT+2.D0*PI) .LT. TOLTHT) .OR.                
     >           (DABS(THTVAL-THT-2.D0*PI) .LT. TOLTHT)) .AND.              
     >           (DABS(PSIVAL-PS).LT.TOLPSI))  THEN                      
c                                                                       
c----------------------------- node located ---------------------       
              FOUND = .TRUE.                                            
              IF ((DABS(RR).GT.1.D0+TOLPSI).OR.                            
     >            (DABS(SS).GT.1.D0+TOLTHT)) THEN                          
                WRITE(*,*) ' WARNING : ',RR,SS                          
              ENDIF                                                     
              NODE = (I-1)*NPNEW + JINDEX                               
              N1 = NODENO(NN,1)                                         
              N2 = NODENO(NN,2)                                         
              N3 = NODENO(NN,3)                                         
              N4 = NODENO(NN,4)                                         
              CALL INTERP(XXOLD(1,N1),XXOLD(1,N2),XXOLD(1,N3),          
     >                    XXOLD(1,N4),RR,SS,X,XR,XS,XRS,XRR,XSS)        
              CALL INTERP(YYOLD(1,N1),YYOLD(1,N2),YYOLD(1,N3),          
     >                    YYOLD(1,N4),RR,SS,Y,YR,YS,YRS,YRR,YSS)        
              CALL INTERP(PSIOLD(4*(N1-1)+1),PSIOLD(4*(N2-1)+1),        
     >                    PSIOLD(4*(N3-1)+1),PSIOLD(4*(N4-1)+1),        
     >               RR,SS,ZPSI,ZPSIR,ZPSIS,ZPSIRS,ZPSIRR,ZPSISS)       
c-------------------------------------------------------------------    
              RAD = (X-XAXIS)**2 + (Y-YAXIS)**2                         
              THY = (X-XAXIS) / RAD                                     
              THX = -(Y-YAXIS) / RAD                                    
              THXX = 2.D0*(Y-YAXIS)*(X-XAXIS) / RAD**2                     
              THYY = - THXX                                             
              THXY = ( (Y-YAXIS)**2 - (X-XAXIS)**2 ) / RAD**2           
              THS = THX * XS + THY * YS                                 
              THR = THX * XR + THY * YR                                 
              THRR = THXX*XR*XR + 2*THXY*XR*YR + THX*XRR                
     >             + THYY*YR*YR + THY*YRR                               
              THRS = THXX*XR*XS + THXY*XR*YS + THX*XRS                  
     >             + THXY*YR*XS + THYY*YR*YS + THY*YRS                  
              THSS = THXX*XS*XS + 2*THXY*XS*YS + THX*XSS                
     >             + THYY*YS*YS + THY*YSS                               
              PTJAC = ZPSIR*THS - ZPSIS*THR                             
              RT = - ZPSIS / PTJAC                                      
              ST =   ZPSIR / PTJAC                                      
              PTJR = ZPSIRR*THS+ZPSIR*THRS-ZPSIRS*THR-ZPSIS*THRR        
              PTJS = ZPSIRS*THS+ZPSIR*THSS-ZPSISS*THR-ZPSIS*THRS        
              RPT = (-PTJR*THS/PTJAC**2 + THRS/PTJAC) * RT              
     >            + (-PTJS*THS/PTJAC**2 + THSS/PTJAC) * ST              
              SPT = ( PTJR*THR/PTJAC**2 - THRR/PTJAC) * RT              
     >            + ( PTJS*THR/PTJAC**2 - THRS/PTJAC) * ST              
              XPT = - XRR * THS*ZPSIS/PTJAC**2                          
     >              + XRS * (THS*ZPSIR + THR*ZPSIS)/PTJAC**2            
     >              + XR  * RPT        + XS * SPT                       
     >              - XSS * THR*ZPSIR/PTJAC**2                          
              YPT = - YRR * THS*ZPSIS/PTJAC**2                          
     >              + YRS * (THS*ZPSIR + THR*ZPSIS)/PTJAC**2            
     >              + YR  * RPT        + YS * SPT                       
     >              - YSS * THR*ZPSIR/PTJAC**2                          
              XYJAC = XR*YS - XS*YR                                     
              PSIX = ( YS*ZPSIR - YR*ZPSIS) / XYJAC                     
              PSIY = (-XS*ZPSIR + XR*ZPSIS) / XYJAC                     
                                                                        
              ETAP = 1.D0/ (2.D0*RADPSI(I))                                 
              EJAC = ETAP * (PSIX*THY - PSIY*THX)                       
              XX(1,NODE) = X                                            
              YY(1,NODE) = Y                                            
C-------------------------------- WATCH MINUS DSIGN FROM R ORIENTATION --
       XX(2,NODE) = - ( THY  / EJAC)/(2.D0*dble(NRNEW-1))        
       YY(2,NODE) = - (-THX  / EJAC)/(2.D0*dble(NRNEW-1))        
       XX(3,NODE) =+(-ETAP*PSIY / EJAC)/(FACTAS*dble(NPNEW-1)/PI)  
       YY(3,NODE) =+( ETAP*PSIX / EJAC)/(FACTAS*dble(NPNEW-1)/PI)  
       XX(4,NODE) =-(XPT/ETAP)/(2.D0*FACTAS*dble(NRNEW-1)
     >  *dble(NPNEW-1)/PI)
       YY(4,NODE) =-(YPT/ETAP)/(2.D0*FACTAS*dble(NRNEW-1)
     >  *dble(NPNEW-1)/PI)
              PSI(4*(NODE-1)+1) = ZPSI                                  
              PSI(4*(NODE-1)+2) = - 2.D0*RADPSI(I)/(2.D0*dble(NRNEW-1))      
              PSI(4*(NODE-1)+3) = 0.D0                                    
              PSI(4*(NODE-1)+4) = 0.D0                                    
              CHAGR(NODE) = .TRUE.                                      
              IF (ITN.GT.ITTEST) ITTEST = ITN                           
              GOTO 50                                                   
            ELSEIF ( ((THT1.LE.THTVAL+1.D-5).AND.                       
     >                (THT2.GE.THTVAL-1.D-5).AND.(THT2.GE.THT1))                           
     >        .OR.                                                      
     >         ((IAS.EQ.1).AND.(THT1.GT.THT2+1.57)                           
     >                    .AND.(THT1.LE.THTVAL+1.D-5)                   
     >                    .AND.(THT2+2.D0*PI.GE.THTVAL-1.D-5))             
     >        .OR.                                                      
     >         ((IAS.EQ.1).AND.(THT1.GT.THT2+1.57)                           
     >                    .AND.(THT1-2.D0*PI.LE.THTVAL+1.D-5)              
     >                    .AND.(THT2.GE.THTVAL-1.D-5)) )  THEN          
                                                                   
   47         FORMAT(' THETA BRACK : ',3E14.6)	                         
c                                                                       
c----------------------------- theta value bracketed ------------       
c                                                                       
              FVEC1 = -(ZY - YAXIS) + (ZX - XAXIS) * TAN(THTVAL)        
              FVEC2 = -PS + PSIVAL                                      
              FJAC11 = ZYR - ZXR*TAN(THTVAL)                            
              FJAC12 = ZYS - ZXS*TAN(THTVAL)                            
              FJAC21 = DPSIR                                            
              FJAC22 = DPSIS                                            
              DIS = FJAC22*FJAC11-FJAC12*FJAC21                         
              DR = (FJAC22*FVEC1-FJAC12*FVEC2)/DIS                      
              DS = (FJAC11*FVEC2-FJAC21*FVEC1)/DIS   
              DR = DSIGN(MIN(DABS(DR),0.05D0),DR)                           
              DS = DSIGN(MIN(DABS(DS),0.05D0),DS)                           
              RR = RR + DR                                              
              SS = SS + DS                                              

   46         FORMAT(' 2D NEWTON- : ',1P5E12.4)                          
   56         FORMAT(' No brack : ',1P5E12.4)  
   57         FORMAT(4e16.8)                         
              NOBRACK = .FALSE.                                         
            ELSE                                                        
c                                                                       
c------------------------ theta not found yet, track flux surface       
c                                                                       
              NOBRACK = .TRUE.                                          
              DS = - DD * DPSIR/DABS(DPSIR)                              
              IF (DABS((PSIVAL-PS)/PSIVAL).GT.0.01D0) THEN                 
                DS=0.D0                                                   
                DR = (PSIVAL-PS) / DPSIR                                
                RR = RR + DR                                            
              ELSE                                                      
                DR = (PSIVAL-PS - DPSIS * DS ) / DPSIR                  
                DTOT = DSQRT(DR*DR+DS*DS)                                
                DR = DR * DD/DTOT                                       
                DS = DS * DD/DTOT                                       
                RR = RR + DR                                            
                SS = SS + DS                                            
              ENDIF                                                     
            ENDIF          
   58       Format('tracking:',6e16.8)                                       
            IN = (NN-1)/(NP-1)+1                                        
            JN = MOD(NN-1,NP-1)+1                                       
            IF (SS.LT.-1.D0) THEN                                         
              IF (JPREV.EQ.-1) THEN                                     
                NN = NN - 1                                             
                IF (JN.EQ.1) NN = NN + (NP-1)                           
                SS = SS + 2.D0                                            
                JPREV = 0                                               
              ELSE                                                      
                SS = -1.D0                                                
                JPREV = -1                                              
              ENDIF                                                     
            ELSEIF (SS.GT.1.D0) THEN                                       
              IF (JPREV.EQ.1) THEN                                      
                NN = NN + 1                                             
                IF (JN.EQ.NP-1) NN = NN - (NP-1)                        
                SS = SS - 2.D0                                            
                JPREV = 0                                               
              ELSE                                                      
                SS = 1.D0                                                 
                JPREV = 1                                               
              ENDIF                                                     
            ENDIF                                                       
            IF (RR.LT.-1.D0) THEN                                          
              IF ((IN.GT.1).AND.(IPREV.EQ.-1))THEN                      
                NN = NN - NP + 1                                        
                RR = RR + 2.D0                                          
                IPREV = 0                                               
              ELSE                                                      
                RR = -1.D0                                                
                IPREV = -1                                              
              ENDIF                                                     
            ELSEIF (RR.GT.1.D0) THEN                                      
              IF ((IN.LT.NR-1).AND.(IPREV.EQ.1)) THEN                   
                NN = NN + NP - 1                                        
                RR = RR - 2.D0                                            
                IPREV = 0                                               
              ELSE                                                      
                RR = 1.D0                                                 
                IPREV = 1                                               
              ENDIF                                                     
            ENDIF                                                       
          ENDDO                                                         
          WRITE(*,43) I,J,PSIVAL,THTVAL 
	  IFAIL = 1
	  WRITE(*,*) ' RETURN FROM REMESH IFAIL : ',IFAIL
	  RETURN     
   50   CONTINUE                                                        
C        WRITE(*,*) ' MAX NUMBER ITERATIONS : ',ITTEST,DD               
   30 CONTINUE                                                          
   41 FORMAT(i3,2e12.4,4e14.6)                                          
   42 FORMAT(i3,6e12.4)                                                 
   43 FORMAT(' FATAL NODE NOT FOUND : ',2i3,2f12.6)                                                                    
      IF (IAS.EQ.1) THEN                                                
C------------------------------------ copy tht=0 to tht=2PI             
      DO I=1,NRNEW-1                                                    
        J = NPNEW                                                       
        NODE = (I-1)*NPNEW + J                                          
        J0 = 1                                                          
        N0 = (I-1)*NPNEW + J0                                           
        XX(1,NODE) = XX(1,N0)                                           
        XX(2,NODE) = XX(2,N0)                                           
        XX(3,NODE) = XX(3,N0)                                           
        XX(4,NODE) = XX(4,N0)                                           
        YY(1,NODE) = YY(1,N0)                                           
        YY(2,NODE) = YY(2,N0)                                           
        YY(3,NODE) = YY(3,N0)                                           
        YY(4,NODE) = YY(4,N0)                                           
        PSI(4*(NODE-1)+1) = PSI(4*(N0-1)+1)                             
        PSI(4*(NODE-1)+2) = PSI(4*(N0-1)+2)                             
        PSI(4*(NODE-1)+3) = PSI(4*(N0-1)+3)                             
        PSI(4*(NODE-1)+4) = PSI(4*(N0-1)+4)                             
        CHAGR(NODE)=.TRUE.                                              
      ENDDO                                                             
      ENDIF                                                             
                                                                        
      N1 = NODENO(NAX,1)                                                
      N2 = NODENO(NAX,2)                                                
      N3 = NODENO(NAX,3)                                                
      N4 = NODENO(NAX,4)                                                
      S = SAX                                                           
      R = RAX                                                           
      CALL INTERP(XXOLD(1,N1),XXOLD(1,N2),XXOLD(1,N3),XXOLD(1,N4),      
     >            R,S,X,XR,XS,XRS,XRR,XSS)                              
      CALL INTERP(YYOLD(1,N1),YYOLD(1,N2),YYOLD(1,N3),YYOLD(1,N4),      
     >            R,S,Y,YR,YS,YRS,YRR,YSS)                              
      CALL INTERP(PSIOLD(4*(N1-1)+1),PSIOLD(4*(N2-1)+1),                
     >            PSIOLD(4*(N3-1)+1),PSIOLD(4*(N4-1)+1),                
     >            R,S,EQPSI,PSIR,PSIS,PSRS,PSRR,PSSS)                   
      EJAC = XR*YS - XS*YR                                              
      RY = - XS / EJAC                                                  
      RX =   YS / EJAC                                                  
      SY =   XR / EJAC                                                  
      SX = - YR / EJAC                                                  
      PSIXX = PSRR*RX*RX + 2.D0*PSRS*RX*SX + PSSS*SX*SX                   
      PSIYY = PSRR*RY*RY + 2.D0*PSRS*RY*SY + PSSS*SY*SY                   
      IF ((IGAM.GE.1).AND.(IGAM.LE.4)) THEN                             
        PSIYY0 = A * ( C + B*X*(1+EPS*X/2.D0) ) - PSIXX                  
      ELSE                                                              
        PSIYY0 = A * ( C + B*(1.D0+EPS*X)**2   ) - PSIXX                  
      ENDIF                                                             
      CX = PSIXX/2.D0                                                     
      CY = PSIYY0/2.D0                                                    
ccc      WRITE(*,3) CX,CY                                              
      DO 60 J = 1, NPNEW                                                
        NODE = (NRNEW-1)*NPNEW + J                                      
        XX(1,NODE) = XAXIS                                              
        YY(1,NODE) = YAXIS                                              
        TN = TAN(THTKN(J))                                              
        TN2 = TN**2                                                     
        CN = DCOS(THTKN(J))                                              
        IF (THTKN(J).EQ.(PI/2.D0)) THEN                                   
          XX(2,NODE) = 0.D0                                               
          YY(2,NODE) = -1.D0/(DSQRT(DABS(CY))*2.D0*dble(NRNEW-1))                      
          XX(4,NODE) = +1.D0/(DSQRT(DABS(CY))*2.D0*FACTAS*dble(NRNEW-1)
     >                   *dble(NPNEW-1)/PI)  
          YY(4,NODE) = 0.D0                                               
        ELSEIF (THTKN(J).EQ.(3.D0*PI/2)) THEN                              
          XX(2,NODE) = 0.D0                                               
          YY(2,NODE) = -1.D0/(DSQRT(DABS(CY))*2.D0*dble(NRNEW-1))                      
          XX(4,NODE) = +1.D0/(DSQRT(DABS(CY))*2.D0*FACTAS*dble(NRNEW-1)
     >                 *dble(NPNEW-1)/PI)  
          YY(4,NODE) = 0.D0                                               
        ELSE                                                            
       XX(2,NODE)=- DSIGN(1.D0,CN)/(DSQRT(DABS(CX+CY*TN2))*2.D0
     >  *dble(NRNEW-1))  
        YY(2,NODE)=-DABS(TN)/(DSQRT(DABS(CX+CY*TN2))*2.D0*dble(NRNEW-1))     
        XX(4,NODE) = + (CX+CY*TN2)**(-1.5D0) * CY * DABS(TN)              
     >    / (CN**2 * 2.D0*FACTAS*dble(NRNEW-1)*dble(NPNEW-1)/PI)        
         YY(4,NODE) = - CX * (CX + CY*TN2)**(-1.5D0) / (CN*DABS(CN)       
     >              * 2.D0*FACTAS*dble(NRNEW-1)*dble(NPNEW-1)/PI)                 
        ENDIF                                                           
        IF (THTKN(J).GT.PI) THEN                                        
          YY(2,NODE) = - YY(2,NODE)                                     
          XX(4,NODE) = - XX(4,NODE)                                     
        ENDIF                                                           
        XX(3,NODE) = 0.D0                                                 
        YY(3,NODE) = 0.D0                                                 
        PSI(4*(NODE-1)+1) = 0.D0                                          
        PSI(4*(NODE-1)+2) = 0.D0                                          
        PSI(4*(NODE-1)+3) = 0.D0                                          
        PSI(4*(NODE-1)+4) = 0.D0                                          
        CHAGR(NODE) = .TRUE.                                            
   60 CONTINUE                                                          
      DO 80 I=1,NRNEW*NPNEW                                             
        IF (.NOT. CHAGR(I)) THEN
	   WRITE(*,*) 'NODE MISSED AT I = ',I         
	   IFAIL = I
	ENDIF
   80 CONTINUE                                                          
      NR = NRNEW                                                        
      NP = NPNEW                                                        
      CALL ELMNO(NR,NP,NODENO)                                          
    3 FORMAT('ELONGATION ON AXIS : CX,CY = ',2E12.4)                    
                                                                        
c      CALL PRARR1('X : ',XX,4*NRNEW*NPNEW,203)                         
c      CALL PRARR1('Y : ',YY,4*NRNEW*NPNEW,203)                         
c      CALL PRARR1('PSI : ',PSI,4*NRNEW*NPNEW,203)                                                                                        
      RETURN                                                            
      END                                                               
                                                                        
************************************************************************
      SUBROUTINE PSIMIMA(N,PSI,PSIMIN,PSIMAX)                           
C-----------------------------------------------------------------------
C SUBROUTINE TO DETERMINE THE MINIMA AND MAXIMA OF PSI AT THE ELEMENT   
C BOUNDARIES FOR USE IN THE REMESH SUBROUTINE                           
C   N : NUMBER OF THE ELEMENT                                           
C   PSI : VECTOR WITH PSI VALUES                                        
C   PSIMIN,PSIMAX : THE RESULTING MINIMUM AND MAXIMUM VALUES OF PSI     
C-----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      COMMON /CORNERS/ RS, IJ, NODENO                                   
      real*8    RS(4,2)                                                   
      integer IJ(4,2), NODENO(MAXMNODE,4)                               
C-----------------------------------------------------------------------
      real*8 PSI(*)                                                       
                                                                        
      PSIMIN = 1D10                                                     
      PSIMAX =-1D10                                                     
      DO 10 I=1,4                                                       
        IM = MOD(I,4) + 1                                               
        N1 = NODENO(N,I)                                                
        N2 = NODENO(N,IM)                                               
        IF (ABS(N1-N2).EQ.1) THEN                                       
           PSIM  = PSI(4*(N1-1)+1)                                      
           PSIMR = PSI(4*(N1-1)+3)                                      
           PSIP  = PSI(4*(N2-1)+1)                                      
           PSIPR = PSI(4*(N2-1)+3)                                      
        ELSE                                                            
           PSIM  = PSI(4*(N1-1)+1)                                      
           PSIMR = PSI(4*(N1-1)+2)                                      
           PSIP  = PSI(4*(N2-1)+1)                                      
           PSIPR = PSI(4*(N2-1)+2)                                      
        ENDIF                                                           
        PSMA = MAX(PSIM,PSIP)                                           
        PSMI = MIN(PSIM,PSIP)                                           
        AA =  3.D0 * (PSIM + PSIMR - PSIP + PSIPR ) / 4.D0                  
        BB =  ( - PSIMR + PSIPR ) / 2.D0                                  
        CC =  ( - 3.D0*PSIM - PSIMR + 3.D0*PSIP - PSIPR) / 4.D0                 
        DET = BB**2 - 4.D0*AA*CC                                           
        IF (DET.GT.0.D0) THEN                                             
           R = (-BB + DSQRT(DET) ) / (2.D0*AA)                    
           IF (DABS(R).GT.1.D0) THEN                                       
              R = (-BB - DSQRT(DET) ) / (2.D0*AA)                 
           ENDIF                                                        
           IF (DABS(R).LE.1.D0) THEN                                        
              CALL CUB1D(PSIM,PSIMR,PSIP,PSIPR,R,PSMIMA,DUMMY)          
              IF (PSMIMA.GT.PSMA) THEN                                  
                 PSMA = PSMIMA                                          
              ELSE                                                      
                 PSMI = PSMIMA                                          
              ENDIF                                                     
           ENDIF                                                        
        ENDIF                                                           
        IF (PSMI.LT.PSIMIN) PSIMIN = PSMI                               
        IF (PSMA.GT.PSIMAX) PSIMAX = PSMA                               
   10 CONTINUE                                                          
      RETURN                                                            
      END                                                               
                                                                        
************************************************************************
      SUBROUTINE THTMIMA(N,NP,XX,YY,XAXIS,YAXIS,THTMIN,THTMAX)          
C-----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      COMMON /CORNERS/ RS, IJ, NODENO                                   
      real*8    RS(4,2)                                                   
      integer IJ(4,2), NODENO(MAXMNODE,4)                               
C-----------------------------------------------------------------------
       real*8 XX(4,*), YY(4,*)                                             
                                                                        
      THTMIN = 1D10                                                     
      THTMAX =-1D10                                                     
      DO 10 I=1,4                                                       
        NODE = NODENO(N,I)                                              
        THETA = DATAN2(YY(1,NODE)-YAXIS,XX(1,NODE)-XAXIS)                
        IF (THETA.LT.-1.D-3) THEN                                       
          THETA = THETA + 6.28318530717958624D0                           
        ENDIF                                                           
        IF (THETA.LT.THTMIN) THTMIN = THETA                             
        IF (THETA.GT.THTMAX) THTMAX = THETA                             
   10 CONTINUE                                                          
      IF ((THTMIN.LT.1.57).AND.(THTMAX.GT.4.71)) THEN                   
        THTMIN = 1D10                                                   
        THTMAX =-1D10                                                   
        DO 20 I=1,4                                                     
          NODE = NODENO(N,I)                                            
          THETA = DATAN2(YY(1,NODE)-YAXIS,XX(1,NODE)-XAXIS)              
          IF (THETA.LT.THTMIN) THTMIN = THETA                           
          IF (THETA.GT.THTMAX) THTMAX = THETA                           
   20   CONTINUE                                                        
      ENDIF                                                             
      RETURN                                                            
      END                                                               
                                                                        
************************************************************************
*DECK SOLVP3
      SUBROUTINE SOLVP3(C0,C1,C2,C3,X1,X2,X3,IFAIL)
C-----------------------------------------------------------------------
C SOLVES A CUBIC EQUATION WITH A SOLUTION WITH -1.< X < 1
C CN : THE COEFFICIENT OF X**N, X : THE REAL SOLUTION WITH -1.< X < 1.
C-----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      REAL*8 C0,C1,C2,C3,X1,X2,X3

      X1 = 99.D0
      X2 = 999.D0
      X3 = 9999.D0
      TOL = 1D-8
      IFAIL = 0
c------------------------------------- 2nd order poly for small c3
      IF (ABS(C3)/(ABS(C0)+ABS(C1)+ABS(C2)).LT.1.D-7) THEN
        AA = C2
        BB = C1
        CC = C0
        DET = BB**2 - 4*AA*CC
        IF (DET.GT.0.D0) THEN
          X1 = ROOT(AA,BB,CC,DET,1.D0)
          IF (ABS(X1).GT.1.+TOL) THEN
            X1 = ROOT(AA,BB,CC,DET,-1.D0)
          ENDIF
        ELSE
           IFAIL = 1
        ENDIF

      ELSE
c------------------------------------- 3rd order poly solution
      PI = 2.D0*ASIN(1.D0)                                                   
      A0 = C0 / C3                                                      
      A1 = C1 / C3                                                      
      A2 = C2 / C3                                                      
      P = - (A2**2)/3.D0 + A1                                             
      Q = 2.D0/27.D0*(A2**3) - A2 * A1/3.D0 + A0                              
      DET = (P/3.D0)**3 + (Q/2.D0)**2                                       
      IF (DET.GE.0.D0) THEN                                                
        U  = DSIGN(1.D0,-Q/2.D0+SQRT(DET))
     >   *ABS(-Q/2.D0 + SQRT(DET))**(1.D0/3.D0)   
        V  = DSIGN(1.D0,-Q/2.D0-SQRT(DET))   
     >   *ABS(-Q/2.D0 - SQRT(DET))**(1.D0/3.D0)
        X1 =  U + V - A2/3.D0                                             
        IF (ABS(X1).GE.(1.D0+TOL)) IFAIL = 1                               
      ELSE                                                              
        P = -P                                                          
        ANGLE = DSIGN(1.D0,P)*ACOS((Q/2.D0)/SQRT(DABS(P)/3.D0)**3)              
        X1 = -2.D0*SQRT(DABS(P)/3.D0)*COS(ANGLE/3.D0) - A2/3.D0                   
        X2 = -2.D0*SQRT(DABS(P)/3.D0)*COS(2*PI/3.D0-ANGLE/3.D0)-A2/3.D0        
        X3 = -2.D0*SQRT(DABS(P)/3.D0)*COS(2*PI/3.D0+ANGLE/3.D0)-A2/3.D0        
      ENDIF                                                             
      IF (ABS(X1).GT.ABS(X2)) THEN                                      
        DUM = X1                                                        
        X1 = X2                                                         
        X2 = DUM                                                        
      ENDIF                                                             
      IF (ABS(X2).GT.ABS(X3)) THEN                                      
        DUM = X2                                                        
        X2 = X3                                                         
        X3 = DUM                                                        
      ENDIF                                                             
      IF (ABS(X1).GT.ABS(X2)) THEN                                      
        DUM = X1                                                        
        X1 = X2                                                         
        X2 = DUM                                                        
      ENDIF    
      ENDIF
      IF (ABS(X1).GT.(1.D0+TOL)) IFAIL=1                                  
      RETURN                                                            
      END        
                                              
                                                                        
************************************************************************
      SUBROUTINE PROFILES(P0,RBPHI,DP,DRBPHI,A)                         
C-----------------------------------------------------------------------
C SUBROUTINE TO INTEGRATE THE EQUILIBRIUM PROFILES                      
C-----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      COMMON / COMDAT/                                                  
     >        ELLIP,TRIAH,TRIAB,QUAD,PAR1,PAR2,PAR3,PAR4,                      
     >        AGA,BGA,CGA,DGA,EGA,FGA,GGA,HGA,                          
     >        API,BPI,CPI,DPI,EPI,FPI,GPI,HPI,                          
     >        ACUR,BCUR,CCUR,DCUR,ECUR,FCUR,GCUR,HCUR,                  
     >        ERRIT,ERRCUR,EPS,ALFA,B,C,XIAB,Q95,BETAP,AMIX,BMIX,       
     >        ABB, BBB, AMPL, RVAC,BVAC,ZEFF,ZN0,RPE,XR1,SIG1,          
     >        IAS,ICUR,NRCUR,NPCUR,NMESH,INIMESH,NBB,NQB,IARC,          
     >        MHARM,ISHAPE,ISOL,IGAM,IPAI,NR,NP,NRMAP,NPMAP,NITER       
      real*8    ELLIP,TRIAH,TRIAB,QUAD,PAR1,PAR2,PAR3,PAR4,                      
     >        AGA,BGA,CGA,DGA,EGA,FGA,GGA,HGA,                          
     >        API,BPI,CPI,DPI,EPI,FPI,GPI,HPI,                          
     >        ACUR,BCUR,CCUR,DCUR,ECUR,FCUR,GCUR,HCUR,                  
     >        ERRIT,ERRCUR,EPS,ALFA,B,C,XIAB,Q95,BETAP,AMIX,BMIX,       
     >        ABB, BBB, AMPL, RVAC,BVAC,ZEFF,ZN0,RPE,XR1,SIG1           
      integer IAS,ICUR,NRCUR,NPCUR,NMESH,INIMESH,NBB,NQB,IARC,          
     >        MHARM,ISHAPE,ISOL,IGAM,IPAI,NR,NP,NRMAP,NPMAP,NITER       
C-----------------------------------------------------------------------
      COMMON /NODES/ PSIKN,THTKN,RADPSI,DPSIKN,DDPSIKN                                   
      REAL*8    PSIKN(NRMMAX),THTKN(NPMMAX),RADPSI(NRMMAX) 
      REAL*8    DPSIKN(NRMMAX),DDPSIKN(NRMMAX)
c-----------------------------------------------------------------------
      real*8 P0(*),RBPHI(*),DP(*),DRBPHI(*)                               
                                                                        
C---------------------------- DERIVATIVES TO R = SQRT(PSI) !!!! --------
      DO 10 J=1,NR                                                      
        FLUX = PSIKN(NR-J+1)                                            
        IF ((IGAM.GE.1).AND.(IGAM.LE.4)) THEN                           
          P0(J) =  .5D0 * A * B * PRES(FLUX)                              
          DP(J) = - A * B * DPDPSI(FLUX) * DSQRT(DABS(FLUX))                   
          DGAM = - 2.D0 * A * DGDPSI(FLUX) * DSQRT(DABS(FLUX))                   
          GAM = A * C * XGAMMA(FLUX)                                        
          RBPHI(J) = P0(J) - EPS * GAM                                  
          DRBPHI(J) = DP(J) - EPS * DGAM                                
        ELSE                                                            
          P0(J) = EPS * A * B * PRES(FLUX)                              
          DP(J) = -2.D0*EPS*A*B * DPDPSI(FLUX) * DSQRT(DABS(FLUX))               
          RBPHI(J) = - EPS * A * C * XGAMMA(FLUX)                       
          DRBPHI(J) = EPS * 2.D0*A*C * DGDPSI(FLUX) * DSQRT(DABS(FLUX))          
        ENDIF                                                           
        RBPHI(J) = DSQRT(DABS(1.D0 - 2.D0*EPS*RBPHI(J) /ALFA**2))                 
        DRBPHI(J) = - 1.D0/(2.D0*RBPHI(J)) * 2.D0*EPS*DRBPHI(J)/ALFA**2       
   10 CONTINUE                                                          
      RETURN                                                            
      END                                                               
                                                                        
*********************************************************************** 
      REAL*8 FUNCTION PRES(FLUX)                                               
C-----------------------------------------------------------------------
C PRESSURE PROFILE AS A FUNCTION OF PSI                                 
C-----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      COMMON / COMDAT/                                                  
     >        ELLIP,TRIAH,TRIAB,QUAD,PAR1,PAR2,PAR3,PAR4,                      
     >        AGA,BGA,CGA,DGA,EGA,FGA,GGA,HGA,                          
     >        API,BPI,CPI,DPI,EPI,FPI,GPI,HPI,                          
     >        ACUR,BCUR,CCUR,DCUR,ECUR,FCUR,GCUR,HCUR,                  
     >        ERRIT,ERRCUR,EPS,ALFA,B,C,XIAB,Q95,BETAP,AMIX,BMIX,       
     >        ABB, BBB, AMPL, RVAC,BVAC,ZEFF,ZN0,RPE,XR1,SIG1,          
     >        IAS,ICUR,NRCUR,NPCUR,NMESH,INIMESH,NBB,NQB,IARC,          
     >        MHARM,ISHAPE,ISOL,IGAM,IPAI,NR,NP,NRMAP,NPMAP,NITER       
      real*8    ELLIP,TRIAH,TRIAB,QUAD,PAR1,PAR2,PAR3,PAR4,                      
     >        AGA,BGA,CGA,DGA,EGA,FGA,GGA,HGA,                          
     >        API,BPI,CPI,DPI,EPI,FPI,GPI,HPI,                          
     >        ACUR,BCUR,CCUR,DCUR,ECUR,FCUR,GCUR,HCUR,                  
     >        ERRIT,ERRCUR,EPS,ALFA,B,C,XIAB,Q95,BETAP,AMIX,BMIX,       
     >        ABB, BBB, AMPL, RVAC,BVAC,ZEFF,ZN0,RPE,XR1,SIG1           
      integer IAS,ICUR,NRCUR,NPCUR,NMESH,INIMESH,NBB,NQB,IARC,          
     >        MHARM,ISHAPE,ISOL,IGAM,IPAI,NR,NP,NRMAP,NPMAP,NITER       
C-----------------------------------------------------------------------
      COMMON/COMPROF/DPR,DF2,ZJZ,QIN,DPRES,DGAM,PINT,GINT,NPTS          
      real*8    DPR(NPTSMAX),DF2(NPTSMAX),ZJZ(NPTSMAX),QIN(NPTSMAX),      
     >        DPRES(1001),DGAM(1001),PINT(1001),GINT(1001)              
      integer NPTS                                                      
C-----------------------------------------------------------------------
      NPT=1001                                                          
      NINT = INT((NPT-1)*FLUX)+1                                        
      IF (FLUX.GE.1.) NINT=NPT-1                                        
      DPS = 1./dble(NPT-1)                                              
      SUM = PINT(NINT+1)                                                
      DPSI = NINT*DPS - FLUX                                            
      PSII = (NINT-1)*DPS                                               
      DPRI = DPRES(NINT) + (FLUX-PSII)/DPS*(DPRES(NINT+1)-DPRES(NINT))  
      SUM  = SUM + DPSI * (DPRI + DPRES(NINT+1))/2.                     
      PRES = SUM                                                        
      RETURN                                                            
      END                                                               
                                                                        
************************************************************************
      REAL*8 FUNCTION XGAMMA(FLUX)                                             
C-----------------------------------------------------------------------
C SECOND PROFILE AS A FUNCTION OF PSI                                   
C-----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      COMMON / COMDAT/                                                  
     >        ELLIP,TRIAH,TRIAB,QUAD,PAR1,PAR2,PAR3,PAR4,                      
     >        AGA,BGA,CGA,DGA,EGA,FGA,GGA,HGA,                          
     >        API,BPI,CPI,DPI,EPI,FPI,GPI,HPI,                          
     >        ACUR,BCUR,CCUR,DCUR,ECUR,FCUR,GCUR,HCUR,                  
     >        ERRIT,ERRCUR,EPS,ALFA,B,C,XIAB,Q95,BETAP,AMIX,BMIX,       
     >        ABB, BBB, AMPL, RVAC,BVAC,ZEFF,ZN0,RPE,XR1,SIG1,          
     >        IAS,ICUR,NRCUR,NPCUR,NMESH,INIMESH,NBB,NQB,IARC,          
     >        MHARM,ISHAPE,ISOL,IGAM,IPAI,NR,NP,NRMAP,NPMAP,NITER       
      real*8    ELLIP,TRIAH,TRIAB,QUAD,PAR1,PAR2,PAR3,PAR4,                      
     >        AGA,BGA,CGA,DGA,EGA,FGA,GGA,HGA,                          
     >        API,BPI,CPI,DPI,EPI,FPI,GPI,HPI,                          
     >        ACUR,BCUR,CCUR,DCUR,ECUR,FCUR,GCUR,HCUR,                  
     >        ERRIT,ERRCUR,EPS,ALFA,B,C,XIAB,Q95,BETAP,AMIX,BMIX,       
     >        ABB, BBB, AMPL, RVAC,BVAC,ZEFF,ZN0,RPE,XR1,SIG1           
      integer IAS,ICUR,NRCUR,NPCUR,NMESH,INIMESH,NBB,NQB,IARC,          
     >        MHARM,ISHAPE,ISOL,IGAM,IPAI,NR,NP,NRMAP,NPMAP,NITER       
C-----------------------------------------------------------------------
      COMMON/COMPROF/DPR,DF2,ZJZ,QIN,DPRES,DGAM,PINT,GINT,NPTS          
      real*8    DPR(NPTSMAX),DF2(NPTSMAX),ZJZ(NPTSMAX),QIN(NPTSMAX),      
     >        DPRES(1001),DGAM(1001),PINT(1001),GINT(1001)              
      integer NPTS                                                      
C-----------------------------------------------------------------------
      NPT=1001                                                          
      NINT = INT((NPT-1)*FLUX)+1                                        
      IF (FLUX.GE.1.) NINT=NPT-1                                        
      DPS = 1./dble(NPT-1)                                              
      SUM = GINT(NINT+1)                                                
      DPSI = NINT*DPS - FLUX                                            
      PSII = (NINT-1)*DPS                                               
      DF2I = DGAM(NINT)+(FLUX-PSII)/DPS*(DGAM(NINT+1)-DGAM(NINT))       
      SUM = SUM + DPSI * (DF2I + DGAM(NINT+1))/2.                       
      XGAMMA = SUM                                                      
      RETURN                                                            
      END                                                               
                                                                        
                                                                        
                                                                        
************************************************************************
      SUBROUTINE DIAGNO(XX,YY,PSI,NR,NP,A,B,C,EPS,ALFA,IAS,IGAM,XAXIS,  
     >                  ZJJ1,ZJJ2,ZJJ3,ZJJ4,ZJJ5,ZJJ6,ZJJ7,ZJJ8,ZJJ9,   
     >                  ZJJ10,ZJJ11,ZJJ12,ZJJ13,ZJJ14,ZJJ15,ZJJ16,     
     >                  ZJJ17,PSIT,B02AV,OB2AV,ZQ,ZAREA,ZVOL,
     >                  ZCUR,P0,FF,AVC,XLI,DIMERC,DRMERC)           
C---------------------------------------------------------------------- 
C SUBROUTINE TO EVALUATE OUTPUT QUANTITIES                              
C---------------------------------------------------------------------- 
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      COMMON /CORNERS/ RS, IJ, NODENO                                   
      real*8    RS(4,2)                                                   
      integer IJ(4,2), NODENO(MAXMNODE,4)                               
C-----------------------------------------------------------------------
      COMMON /GAUSINT/ XGAUSS,WGAUSS,H,HR,HS,HRS                        
      real*8 XGAUSS(4),WGAUSS(4)                                          
      real*8 H(4,4,4,4),HR(4,4,4,4),HS(4,4,4,4),HRS(4,4,4,4)              
C-----------------------------------------------------------------------
      real*8    BETAPL,BETA                                               
C-----------------------------------------------------------------------
      real*8 XX(4,*),YY(4,*),PSI(*)                                       
      real*8 P0(*),FF(*),ZQ(*),PSIT(*)                                   
      real*8 B02AV(*),OB2AV(*),ZAREA(*),ZVOL(*),ZCUR(*)                  
      real*8 ZJJ1(*),ZJJ2(*),ZJJ3(*),ZJJ4(*),ZJJ9(*),ZJJ10(*)                              
      real*8 ZJJ5(*),ZJJ6(*),ZJJ7(*),ZJJ8(*),ZJJ11(*),ZJJ12(*)
      real*8 ZJJ13(*),ZJJ14(*),ZJJ15(*),ZJJ16(*),ZJJ17(*),DJJ5(NRMMAX)
      real*8 DQ(NRMMAX),BIGG(NRMMAX),DP(NRMMAX),DF(NRMMAX)                
      real*8 DRMERC(NRMMAX),DIMERC(NRMMAX),HH(NRMMAX)                     
      real*8 GEONC(NRMMAX),ZJPAR(NRMMAX)                                  
      real*8 XL(NRMMAX),ZPS(NRMMAX),AVC(*)
      real*8 ZJAR(NRMMAX),ZPAR(NRMMAX) 
                                                                        
      PI = 2.D0 * DASIN(1.D0)                                                
                                                                        
      FACTAS = 2.D0                                                       
      IF (IAS.EQ.1) FACTAS=1.D0                                           
                                                                        
      R0 = 1.D0                                                           
      B0 = 1.D0                                                           
      RADIUS = EPS * R0                                                 
      CPSURF = RADIUS**2 * B0 / ALFA                                    
                                                                        
      CALL PROFILES(P0,FF,DP,DF,A)                                      
                                                                        
      PSCALE = B0**2 * EPS / ALFA**2                                    
      RBSCALE = B0 * R0                                                 
      DO 90 I = 1,NR                                                    
        P0(I) = P0(I) * PSCALE                                          
        DP(I) = DP(I) * PSCALE                                          
        FF(I) = FF(I) * RBSCALE                                         
        DF(I) = DF(I) * RBSCALE                                         
   90 CONTINUE                                                          
                                                                        
      AREA = 0.D0                                                         
      VOLUME = 0.D0                                                       
      BP2VOL = 0.D0                                                       
      PAREA = 0.D0                                                        
      PAR2  = 0.D0                                                        
      CAREA = 0.D0                                                        
      PTAR  = 0.D0                                                        
C------------------------------------- NELM ELEMENTS ------------------ 
      DO 10 I=NR-1,1,-1                                                 
      DO 15 J=1,NP-1                                                    
        NELM = (I-1)*(NP-1) + J                                         
        N1 = NODENO(NELM,1)                                             
        N2 = NODENO(NELM,2)                                             
        N3 = NODENO(NELM,3)                                             
        N4 = NODENO(NELM,4)                                             
C------------------------------------- 4 POINT GAUSSIAN INT. IN R ----- 
        DO 20 NGR=1,4                                                   
          R = XGAUSS(NGR)                                               
          WR = WGAUSS(NGR)                                              
C------------------------------------- 4 POINT GAUSSIAN INT. IN S ----- 
          DO 30 NGS=1,4                                                 
            S  = XGAUSS(NGS)                                            
            WS = WGAUSS(NGS)                                            
            CALL INTERP(XX(1,N1),XX(1,N2),XX(1,N3),XX(1,N4),            
     >                R,S,X,XR,XS,XRS,XRR,XSS)                          
            CALL INTERP(YY(1,N1),YY(1,N2),YY(1,N3),YY(1,N4),            
     >                R,S,Y,YR,YS,YRS,YRR,YSS)                          
            CALL INTERP(PSI(4*(N1-1)+1),PSI(4*(N2-1)+1),                
     >                PSI(4*(N3-1)+1),PSI(4*(N4-1)+1),                  
     >                R,S,PS,PSR,PSS,PSRS,PSRR,PSSS)                    
            XJAC =  (XR*YS - XS*YR) * RADIUS**2                         
            AREA = AREA + WR * WS * XJAC                                
            VOLUME = VOLUME + (1.D0+EPS*X) * WR * WS * XJAC               
            GRPS2  = PSR**2 * RADIUS**2 * (XS**2 + YS**2) / XJAC**2     
            BP2    = GRPS2 / (1.D0+EPS*X)**2                              
            BP2VOL = BP2VOL + (1.D0+EPS*X) * BP2 *WR*WS*XJAC              
            PRESS  = PRES(PS)                                           
            PAREA  = PAREA + WR * WS * XJAC * PRESS                     
            PAR2   = PAR2  + WR * WS * XJAC * PRESS**2                  
            IF ((IGAM.GE.1).AND.(IGAM.LE.4)) THEN                       
              ARHS = DGDPSI(PS) + B*X*(1.+EPS*X/2.D0)*DPDPSI(PS)          
              P0J =  .5D0 * A * B * PRES(PS)                              
              GAM = A * C * XGAMMA(PS)                                      
              RBPHIJ = P0J - EPS * GAM                                  
            ELSE                                                        
              ARHS = C*DGDPSI(PS) + B*(1.+EPS*X)**2 * DPDPSI(PS)        
              RBPHIJ = - EPS * A * C * XGAMMA(PS)                       
            ENDIF                                                       
            RBPHIJ = DSQRT(DABS( 1.D0 - 2.D0*EPS*RBPHIJ /ALFA**2) )                
            ARHS =  ARHS / (1.D0+EPS*X)                                   
            CAREA = CAREA + WR * WS * XJAC * ARHS                       
            PTAR  = PTAR  + WR * WS * XJAC * RBPHIJ / (1.+EPS*X)        
   30     CONTINUE                                                      
   20   CONTINUE                                                        
   15 CONTINUE                                                          
      NI = NR - I + 1                                                   
      IF ((IGAM.GE.1).AND.(IGAM.LE.4)) THEN                             
          ZJAR(NI)  = -FACTAS * A * CAREA                               
          ZPAR(NI)  = -FACTAS * 0.5D0 * A * B * PAREA                     
        ELSE                                                            
          ZJAR(NI)  = -FACTAS * A * CAREA                               
          ZPAR(NI)  = -FACTAS * EPS * A * B * PAREA                     
        ENDIF                                                           
        ZAREA(NI) = FACTAS * DABS(AREA)                                  
        ZVOL(NI)  = 2.D0 * PI * FACTAS * DABS(VOLUME)                       
        ZCUR(NI)  = - FACTAS * A * CAREA / ALFA                   
        PSIT(NI)  = - FACTAS * PTAR                                     
   10 CONTINUE                                                          
      AREA   = FACTAS * DABS(AREA)                                       
      VOLUME = FACTAS *  DABS(VOLUME)                                    
      RAV = VOLUME / AREA                                               
      IF ((IGAM.GE.1).AND.(IGAM.LE.4)) THEN                             
        PAREA = FACTAS * 0.5D0 * A * B * PAREA                            
        PAR2  = FACTAS * (0.5D0*A*B)**2 * PAR2                            
        CAREA = FACTAS * A * CAREA                                      
      ELSE                                                              
        PAREA =  FACTAS * EPS * A * B * PAREA                           
        PAR2  =  FACTAS * (EPS * A * B)**2 * PAR2                       
        CAREA =  FACTAS * A * CAREA                                     
      ENDIF                                                             
      VOLUME = 2.D0 * PI * VOLUME                                          
      XLI = DABS(4.D0*FACTAS*PI * EPS**4 * BP2VOL / (RAV * CAREA**2))
c      write(6,*) 'Volume',VOLUME,' aire',AREA,' EPS',EPS
c      write(6,*) ' FACTAS',FACTAS
c      write(6,*) 'BP2VOL',BP2VOL,' <R>',RAV,' CAREA',CAREA       
      BETA   = 2.D0* (EPS/ALFA**2) * DABS(PAREA) / AREA                     
      BETASTAR = 2.D0 * (EPS/ALFA**2) * DSQRT(DABS(PAR2)/AREA)               
      BETAPL = (8.D0*PI*EPS)    * DABS(PAREA) / CAREA**2                    
      CURRENT  = DABS(CAREA) / (EPS*ALFA)                                
                                                                        
c      WRITE(*,*)                                                       
c      WRITE(*,*) '***************************************'             
c      WRITE(*,11) XAXIS                                                
c      WRITE(*,2) BETAPL                                                
c      WRITE(*,3) BETA                                                  
c      WRITE(*,8) BETASTAR                                              
c      WRITE(*,12) 1.256637*BETA/CURRENT                                
c      WRITE(*,4) CURRENT                                               
c      WRITE(*,5) AREA                                                  
c      WRITE(*,6) VOLUME                                                
c      WRITE(*,7) XLI                                                   
c      WRITE(*,9) ALFA                                                  
c      WRITE(*,*) '***************************************'             
c      WRITE(*,*)                                                       
                                                                        
                                                                        
c    2 FORMAT('  POLOIDAL BETA : ',E12.4)                                
c    3 FORMAT('  TOROIDAL BETA : ',E12.4)                                
c    4 FORMAT('  TOTAL CURRENT : ',E12.4)                                
c    5 FORMAT('  TOTAL AREA    : ',E12.4)                                
c    6 FORMAT('  TOTAL VOLUME  : ',E12.4)                                
c    7 FORMAT('  INT. INDUCTANCE : ',E12.4)                              
c    8 FORMAT('  BETA STAR     : ',E12.4)                                
c    9 FORMAT('  POL. FLUX     : ',E12.4)                                
c   11 FORMAT('  MAGNETIC AXIS : ',F9.5)                                 
c   12 FORMAT('  NORM. BETA    : ',F9.5)                                 
                                                                        
C------------------------------------- NELM ELEMENTS ------------------ 
      DTDS = (1./FACTAS) * PI/REAL(NP-1)
      R = -1.D0                                                           
      DO 40 I=1,NR-1                                                    
      XLENGTH = 0.D0                                                      
      AVCUR   = 0.D0                                                      
      SUMQ  = 0.D0                                                        
      SUMJ1 = 0.D0                                                        
      SUMJ2 = 0.D0                                                        
      SUMJ3 = 0.D0                                                        
      SUMJ4 = 0.D0                                                        
      SUMJ5 = 0.D0                                                        
      SUMJ6 = 0.D0                                                        
      SUMJ7 = 0.D0                                                       
      SUMJ8 = 0.D0                                   
      SUMJ9 = 0.D0
      SUMJ10 = 0.D0
      SUMJ11 = 0.D0
      SUMJ12 = 0.D0
      SUMJ13 = 0.D0
      SUMJ14 = 0.D0
      SUMJ15 = 0.D0
      SUMJ16 = 0.D0
      SUMJ17 = 0.D0
      SUMJ5R= 0.D0                                                        
      SUMQR = 0.D0                                                        
      SUMB0  = 0.D0                                                       
      SUMOB  = 0.D0                                                       
      SUMBOP = 0.D0                                                       
      SUMOR2 = 0.D0                                                       
      DO 50 J=1,NP-1                                                    
        NELM = (I-1)*(NP-1) + J                                         
        N1 = NODENO(NELM,1)                                             
        N2 = NODENO(NELM,2)                                             
        N3 = NODENO(NELM,3)                                             
        N4 = NODENO(NELM,4)                                             
C------------------------------------- 4 POINT GAUSSIAN INT. IN S ----- 
        DO 60 NGS=1,4                                                   
          S  = XGAUSS(NGS)                                              
          WS = WGAUSS(NGS)                                              
          CALL INTERP(XX(1,N1),XX(1,N2),XX(1,N3),XX(1,N4),              
     >                R,S,X,XR,XS,XRS,XRR,XSS)                          
          CALL INTERP(YY(1,N1),YY(1,N2),YY(1,N3),YY(1,N4),              
     >                R,S,Y,YR,YS,YRS,YRR,YSS)                          
          CALL INTERP(PSI(4*(N1-1)+1),PSI(4*(N2-1)+1),PSI(4*(N3-1)+1),  
     >                PSI(4*(N4-1)+1),                                  
     >                R,S,PS,PSR,PSS,PSRS,PSRR,PSSS)                    
                                                                        
          XJAC =  XR*YS - XS*YR                                         
          XJACR = XRR*YS + XR*YRS - XRS*YR - XS*YRR                     
                                                                        
          DL = DSQRT(XS**2+YS**2)                                        
          BIGR = (1.D0 + EPS * X)                                         
	  GRADPS2 = PSR**2 * (XS**2 + YS**2) / XJAC**2                         
          DSSDR = DABS(PSR) / (2.D0*DSQRT(DABS(PS)))                              
c------------------------------------------------ normalisations	       
	  GRADPS2 = GRADPS2 * (CPSURF/RADIUS)**2                               
	  XJAC    = XJAC * RADIUS**2                                           
	  BIGR    = BIGR                                                       
	  DL      = RADIUS * DL                                                
	  PSR     = CPSURF * PSR                                               
          PSRR    = CPSURF * PSRR                                       
	  XJACR   = XJACR  * RADIUS**2                                         
c---------------------------------------------------------------        
                                                                        
	  ZJDCHI = BIGR * XJAC / DABS(PSR)                                      
	                                                                       
	  SUMJ1 = SUMJ1 - WS * ZJDCHI / (GRADPS2 * BIGR**2)                    
	  SUMJ2 = SUMJ2 - WS * ZJDCHI / (GRADPS2)                              
	  SUMJ3 = SUMJ3 - WS * ZJDCHI * (BIGR**2 / GRADPS2)                    
	  SUMJ4 = SUMJ4 - WS * ZJDCHI / BIGR**2                                
	  SUMJ5 = SUMJ5 - WS * ZJDCHI                                          
	  SUMJ6 = SUMJ6 - WS * ZJDCHI * GRADPS2 / BIGR**2                      
          SUMJ7 = SUMJ7 - WS * ZJDCHI * GRADPS2                         
          SUMJ8 = SUMJ8 - WS * ZJDCHI / BIGR                            
          SUMJ9 = SUMJ9 - WS * ZJDCHI * SQRT(GRADPS2)
	  SUMJ10 = SUMJ10 - WS * ZJDCHI * BIGR
	  SUMJ11 = SUMJ11 - WS * ZJDCHI * XJAC / (DABS(PSR)*DTDS)
          SUMJ12 = SUMJ12 - WS * ZJDCHI * SQRT(GRADPS2)/BIGR
          SUMJ13 = SUMJ13 - WS * ZJDCHI * BIGR**2
          SUMJ14 = SUMJ14 - WS * ZJDCHI * BIGR**2 / 
     >                      (XJAC / (DABS(PSR)*DTDS))**2
          SUMJ16 = SUMJ16 - WS * ZJDCHI * BIGR**3 /
     >                      (XJAC / (DABS(PSR)*DTDS))**3
          SUMJ17 = SUMJ17 - WS * ZJDCHI * BIGR**3 /
     >                      (XJAC / (DABS(PSR)*DTDS))

	  SUMQ  = SUMQ  - WS * XJAC / ( BIGR * DABS(PSR))                
                                                                        
          SUMQR = SUMQR + PSRR * XJAC / ((PSR**2)*BIGR) * WS            
          SUMQR = SUMQR - XJACR / (BIGR*PSR)            * WS            
          SUMQR = SUMQR + XJAC*EPS*XR/((BIGR**2)*PSR)   * WS            
	                                                                       
	  SUMJ5R = SUMJ5R + XJAC  * BIGR * PSRR / (PSR**2) * WS                
	  SUMJ5R = SUMJ5R - XJACR * BIGR / PSR             * WS                
	  SUMJ5R = SUMJ5R - XJAC  * EPS *XR / PSR          * WS                
	                                                                       
c-----------------------------------------------------------------      
                                                                        
          B02 = (FF(NR-I+1)/BIGR)**2 + GRADPS2/BIGR**2                  
                                                                        
          SUMJ15 = SUMJ15 - WS * ZJDCHI * GRADPS2 / B02
          SUMB0  = SUMB0  - WS * ZJDCHI * B02                           
          SUMBOP = SUMBOP - WS * ZJDCHI * B02 / GRADPS2                 
	  SUMOR2 = SUMOR2 - WS * ZJDCHI / BIGR**2                              
          SUMOB  = SUMOB  - WS * ZJDCHI / B02                           
                                                                        
          XLENGTH = XLENGTH + RADIUS**2 * DSQRT(XS**2 + YS**2)*WS      
          IF ((IGAM.GE.1).AND.(IGAM.LE.4)) THEN                         
            ARHS = C*DGDPSI(PS) + B*X*(1.D0+EPS*X/2.D0)*DPDPSI(PS)            
          ELSE                                                          
            ARHS = C*DGDPSI(PS) + B*(1.D0+EPS*X)**2 * DPDPSI(PS)          
          ENDIF                                                         
          ARHS =  ARHS / (1.D0+EPS*X)                                     
          AVCUR = AVCUR + WS * ARHS * ZJDCHI/(1.D0+EPS*X)   
   60     CONTINUE                                                      
   50   CONTINUE                                                        
                                                                        
        NI = NR-I+1                                                     
                                                                        
        XL(NI)  = FACTAS * XLENGTH                                      
        AVC(NI) = - A * AVCUR/ (ALFA * SUMJ8)            
        ZPS(NI) = PS                                                    
                                                                        
        ZJJ1(NI) = FACTAS * SUMJ1 / (2.D0*PI)                             
	ZJJ2(NI) = FACTAS * SUMJ2 / (2.D0*PI)                                    
        ZJJ3(NI) = FACTAS * SUMJ3 / (2.D0*PI)                             
	ZJJ4(NI) = FACTAS * SUMJ4 / (2.D0*PI)                                    
        ZJJ5(NI) = FACTAS * SUMJ5 / (2.D0*PI)                             
	ZJJ6(NI) = FACTAS * SUMJ6 / (2.D0*PI)                                    
	ZJJ7(NI) = FACTAS * SUMJ7 / (2.D0*PI)                                    
	ZJJ8(NI) = FACTAS * SUMJ8 / (2.D0*PI)                                    
        ZJJ9(NI) = FACTAS * SUMJ9 / (2.D0*PI)          
        ZJJ10(NI)= FACTAS * SUMJ10 / (2.D0*PI)          
        ZJJ11(NI)= FACTAS * SUMJ11 / (2.D0*PI)          
        ZJJ12(NI)= FACTAS * SUMJ12 / (2.D0*PI)
        ZJJ13(NI)= FACTAS * SUMJ13 / (2.D0*PI)
        ZJJ14(NI)= FACTAS * SUMJ14 / (2.D0*PI)
        ZJJ15(NI)= FACTAS * SUMJ15 / (2.D0*PI)
        ZJJ16(NI)= FACTAS * SUMJ16 / (2.D0*PI)
        ZJJ17(NI)= FACTAS * SUMJ17 / (2.D0*PI)
             
									
	DJJ5(NI) = FACTAS * SUMJ5R/DSSDR  / (2.D0*PI)                            
	                                                                       
	ZQ(NI) = FACTAS * FF(NI) * SUMQ / (2.D0*PI)                              
        DQ(NI) = DF(NI)*SUMQ + FF(NI)*SUMQR/DSSDR                       
	DQ(NI) = DQ(NI) * FACTAS / (2.D0*PI)                                     
	                                                                       
	OR2AV     = FACTAS * SUMOR2 / (2.D0*PI) / ZJJ5(NI)                       
	B02AV(NI) = FACTAS * SUMB0  / (2.D0*PI) / ZJJ5(NI)                       
	OB2AV(NI) = FACTAS * SUMOB  / (2.D0*PI) / ZJJ5(NI)                       
        GBAR      = FACTAS * SUMBOP / (2.D0*PI)                           
	                                                                       
        GEONC(NI) = GBAR / B02AV(NI)                                    
                                                                        
        ZJPAR(NI) = (- DP(NI) * FF(NI) - DF(NI) * B02AV(NI))            
     >            /( 2.D0*CPSURF*DSQRT(DABS(PS)))                                
                                                                        
        BIGG(NI) = FACTAS * SUMBOP / (2.D0*PI)                            
	                                                                       
	DIMERC(NI) = (DP(NI)*FF(NI)*ZJJ2(NI)/DQ(NI)-0.5D0)**2                  
     >     +  DP(NI)/DQ(NI)**2 * (DJJ5(NI) - DP(NI)*ZJJ3(NI))           
     >     * (FF(NI)**2 * ZJJ1(NI) + ZJJ4(NI) )                         
	                                                                       
	HH(NI) = FF(NI) * DP(NI)/DQ(NI) * (ZJJ2(NI)                            
     >    - ZJJ5(NI)*(ZJJ4(NI)+FF(NI)**2 * ZJJ1(NI))                    
     >    / (ZJJ6(NI) + FF(NI)**2 * ZJJ4(NI) ) )                        
                                                                        
        DRMERC(NI) = DIMERC(NI) - (HH(NI) - 0.5D0)**2                     
                                                                        
        SHEAR = DSQRT(DABS(PS)) * DQ(NI) / ZQ(NI)                              
                                                                        
   40 CONTINUE                                                          
   41 FORMAT(I3,1P15E11.3)                                              
c      AVC(1) = AVC(2) - (AVC(3)-AVC(2))/(ZPS(3)-ZPS(2))*ZPS(2)                                   
      IF ((IGAM.GE.1).AND.(IGAM.LE.4)) THEN                             
         CUR0 = (C+B*XAXIS*(1.D0+EPS*XAXIS/2.D0))/(1.D0+EPS*XAXIS)           
      ELSE                                                              
         CUR0 = (C+B*(1.D0+EPS*XAXIS)**2)/(1.D0+EPS*XAXIS)                 
      ENDIF                                                             
      AVC(1) = A * CUR0 / ALFA   

                                                                        
c      WRITE(*,21)                                                      
c      WRITE(*,*) '*I,    SS,     D_I,     D_R,     H,'                 
c     >          //'       Q,   *'                                       
c      WRITE(*,21)                                                      
c      DO I=1,NR                                                         
c      	WRITE(*,23) I,SQRT(ZPS(I)),-DIMERC(I),-DRMERC(I),               
c     >               HH(I),ZQ(I)                                        
c      ENDDO                                                             
c   21 FORMAT(' ',48('*'))                                               
c   22 FORMAT(' * IDEAL AND RESISTIVE MERCIER CRITERION ',26(' '),'*')   
c   23 FORMAT(I3,F8.3,1P2E10.2,0P3F8.3,1PE10.2,2F8.3,1PE10.2)            
                                                                        
c        WRITE(*,*)                                                     
c        WRITE(*,*) '***********************************************'   
c     >             //'***************'                                  
c        WRITE(*,*) '* I   PSI     S      <J>     ERROR   LENGTH    '   
c     >             //'   Q     P    *'                                  
c        WRITE(*,*) '***********************************************'   
c     >             //'***************'                                  
c        AVC(1) = AVC(2) - (AVC(3)-AVC(2))                               
c     >        /(ZPS(3)-ZPS(2))*ZPS(2)                                   
c      DO I=1,NR                                                         
c          ERR = AVC(I)/AVC(1) - CURPHI(ZPS(I))                          
c          WRITE(*,72) I,ZPS(I),SQRT(ZPS(I)),AVC(I)/AVC(1),             
c     >               ERR,XL(I),ZQ(I),P0(I)                              
c      ENDDO                                                             
c      WRITE(*,*) '***********************************************'     
c     >             //'******************'                               
c      WRITE(*,*)                                                       
c                                                                        
   72 FORMAT(I3,3F8.4,1PE10.2,0P,5F8.4)                                 
      RETURN                                                            
      END                                                               

************************************************************************
*DECK TRIANG
      SUBROUTINE TRIANG(XX,YY,XAXIS,NR,NP,
     >                    XSHIFT,XRAD,XELL,XTRIAPOS,XTRIANEG,IAS)
C----------------------------------------------------------------------
C SUBROUTINE TO CALCULATE THE TRIANGULARITY OF FLUXSURFACES AS A FUNCTION
C OF THE MINOR RADIUS (GEOMETRICAL DEFINITION)
C----------------------------------------------------------------------

      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      COMMON /CORNERS/ RS, IJ, NODENO                                   
      real*8    RS(4,2)                                                   
      integer IJ(4,2), NODENO(MAXMNODE,4)                               
C-----------------------------------------------------------------------
      COMMON /GAUSINT/ XGAUSS,WGAUSS,H,HR,HS,HRS                        
      real*8 XGAUSS(4),WGAUSS(4)                                          
      real*8 H(4,4,4,4),HR(4,4,4,4),HS(4,4,4,4),HRS(4,4,4,4)              

      REAL*8 XX(4,*),YY(4,*),XSHIFT(*),XRAD(*),
     >     FRR(8*MAXMNODE+2),RRT(4*MAXMNODE),XTRIAPOS(*),XELL(*),
     >     FZZ(8*MAXMNODE+2),ZZT(4*MAXMNODE),XTRIANEG(*)

c      XAXIS = XX(1,NR*NP)
c      YAXIS = YY(1,NR*NP)
c      PI = 2.D0 * DASIN(1.D0)                                                
c      FACTAS = 2.D0                                                       
c      IF (IAS.EQ.1) FACTAS=1.D0                                           
  

      IF (IAS.EQ.0) THEN
        R0temp=(XX(1,1)+XX(1,NP))/2.

      DO 60 I=1,NR-1
      DO 50 J=1, NP-1
        N1 = (I-1)*NP + J
        N2 = (I-1)*NP + J + 1
        IF  (YY(3,N1)*YY(3,N2).LE.0.) THEN
C------------------------------------- QUAD. EQ FOR S VALUE AT MINIMUM -
          YYM  = YY(1,N1)
          YYMR = YY(3,N1)
          YYP  = YY(1,N2)
          YYPR = YY(3,N2)
          AA =  3. * (YYM + YYMR - YYP + YYPR ) / 4.
          BB =  ( - YYMR + YYPR ) / 2.
          CC =  ( - 3*YYM - YYMR + 3*YYP - YYPR) / 4.
          DET = BB*BB - 4.*AA*CC
          S  = ROOT(AA,BB,CC,DET,1.D0)
          IF (ABS(S).GT.1.+1.D-8) THEN
            S = ROOT(AA,BB,CC,DET,-1.D0)
          ENDIF
          CALL CUB1D(XX(1,N1),XX(3,N1),XX(1,N2),XX(3,N2),S,XTOP,DUMMY)
          CALL CUB1D(YY(1,N1),YY(3,N1),YY(1,N2),YY(3,N2),S,YTOP,DUMMY)
          XLEFT = XX(1,(I-1)*NP+1)
          XRIGHT = XX(1,(I-1)*NP+NP)
          XGEO = (XLEFT + XRIGHT)/2.
          XRAD(NR+1-I) = (XLEFT - XRIGHT)/2.
          XSHIFT(NR+1-I) = XGEO - R0temp
          XELL(NR+1-I) = YTOP/XRAD(NR+1-I)     
          XTRIAPOS(NR+1-I) = -(XTOP-XGEO)
          XTRIANEG(NR+1-I) = -(XTOP-XGEO)
        ENDIF
   50 CONTINUE
   60 CONTINUE
      ELSE
        R0temp=(XX(1,1)+XX(1,1+(NP-1)/2))/2.
      DO 80 I=1,NR-1
      DO 70 J=1, (NP-1)/2
        N1 = (I-1)*NP + J
        N2 = (I-1)*NP + J + 1
        IF  (YY(3,N1)*YY(3,N2).LE.0.) THEN
C------------------------------------- QUAD. EQ FOR S VALUE AT MINIMUM -
          YYM  = YY(1,N1)
          YYMR = YY(3,N1)
          YYP  = YY(1,N2)
          YYPR = YY(3,N2)
          AA =  3. * (YYM + YYMR - YYP + YYPR ) / 4.
          BB =  ( - YYMR + YYPR ) / 2.
          CC =  ( - 3*YYM - YYMR + 3*YYP - YYPR) / 4.
          DET = BB*BB - 4.*AA*CC
          S  = ROOT(AA,BB,CC,DET,1.D0)
          IF (ABS(S).GT.1.+1.D-8) THEN
            S = ROOT(AA,BB,CC,DET,-1.D0)
          ENDIF
          CALL CUB1D(XX(1,N1),XX(3,N1),XX(1,N2),XX(3,N2),S,XTOP,DUMMY)
          CALL CUB1D(YY(1,N1),YY(3,N1),YY(1,N2),YY(3,N2),S,YTOP,DUMMY)
          XLEFT = XX(1,(I-1)*NP+1)
          XRIGHT = XX(1,(I-1)*NP+(NP-1)/2+1)
          XGEO = (XLEFT + XRIGHT)/2.
          XRAD(NR+1-I) = (XLEFT - XRIGHT)/2.
          XSHIFT(NR+1-I) = XGEO - R0temp
          XELL(NR+1-I) = YTOP/XRAD(NR+1-I)     
          XTRIAPOS(NR+1-I) = -(XTOP-XGEO)
c	       IF (I.EQ.1) then
c			   write(*,*) ' YTOP : ',YTOP
c		    endif
        ENDIF
   70 CONTINUE
      DO 75 J=(NP-1)/2 , NP-1
        N1 = (I-1)*NP + J
        N2 = (I-1)*NP + J + 1
        IF  (YY(3,N1)*YY(3,N2).LE.0.) THEN
C------------------------------------- QUAD. EQ FOR S VALUE AT MINIMUM -
          YYM  = YY(1,N1)
          YYMR = YY(3,N1)
          YYP  = YY(1,N2)
          YYPR = YY(3,N2)
          AA =  3. * (YYM + YYMR - YYP + YYPR ) / 4.
          BB =  ( - YYMR + YYPR ) / 2.
          CC =  ( - 3*YYM - YYMR + 3*YYP - YYPR) / 4.
          DET = BB*BB - 4.*AA*CC
          S  = ROOT(AA,BB,CC,DET,1.D0)
          IF (ABS(S).GT.1.+1.D-8) THEN
            S = ROOT(AA,BB,CC,DET,-1.D0)
          ENDIF
          CALL CUB1D(XX(1,N1),XX(3,N1),XX(1,N2),XX(3,N2),S,XBOT,DUMMY)
          CALL CUB1D(YY(1,N1),YY(3,N1),YY(1,N2),YY(3,N2),S,YBOT,DUMMY)
          XTRIANEG(NR+1-I) = -(XBOT-XGEO)
	       XELL(NR+1-I) = (XELL(NR+1-I) - YBOT/XRAD(NR+1-I))/2.
c	       IF (I.EQ.1) then
c			   write(*,*) ' YBOT : ',YBOT
c          endif        
		  ENDIF
   75 CONTINUE
   80 CONTINUE
      ENDIF
C     valeur sur l'axe magnetique      
      XSHIFT(1) = XAXIS
      XRAD(1) = 0.
      XELL(1) = XELL(2)
      XTRIAPOS(1) = XTRIAPOS(2)
      XTRIANEG(1) = XTRIANEG(2)
   

c      WITH FOURIER DECOMPOSITION :
C
c      WRITE(*,*) '**************************************************'
c      WRITE(*,*) '*  ELLIPTICITY AND TRIANGULARITY   (FOURIER CO.) *' 
c      WRITE(*,*) '**************************************************'
c      WRITE(*,*) '* INDEX,  S,    RADIUS,   SHIFT,   ELLIP,   TRIA *'
c      WRITE(*,*) '**************************************************'
c      DO 10 I=1,NR-1
c        DO 20 J=1, NP-1
c          NELM = (I-1)*(NP-1) + J                                         
c          N1 = NODENO(NELM,1)                                             
c          N2 = NODENO(NELM,2)                                             
c          N3 = NODENO(NELM,3)                                             
c          N4 = NODENO(NELM,4)      
c          DO 30 NGS=1,4
c            R  = -1.
c            S  = (-1. + 0.5 * REAL(NGS-1)) 
c            CALL INTERP1(XX(1,N1),XX(1,N2),XX(1,N3),XX(1,N4),
c     >                  R,S,X)
c            CALL INTERP1(YY(1,N1),YY(1,N2),YY(1,N3),YY(1,N4),
c     >                  R,S,Y)
c            CALL INTERP1(PSI(4*(N1-1)+1),PSI(4*(N2-1)+1),
c     >                   PSI(4*(N3-1)+1),PSI(4*(N4-1)+1),R,S,PS)
c            RRT(4*(J-1)+ NGS) = X 
c	    ZZT(4*(J-1)+ NGS) = Y
c   30     CONTINUE
c   20   CONTINUE
c        IF (IAS.EQ.0) THEN
c          RRT(4*(NP-1)+1) = X
c	  ZZT(4*(NP-1)+1) = Y
c          DO J=1,4*(NP-1)+1
c            FRR(J) = RRT(J)
c	    FZZ(J) = ZZT(J)
c          ENDDO       
c          DO J=1,4*(NP-1)-1
c            FRR(4*(NP-1)+J+1) =  FRR(4*(NP-1)-J+1)
c            FZZ(4*(NP-1)+J+1) = -FZZ(4*(NP-1)-J+1)
c	  ENDDO
c          NPT = 8*(NP-1)
c	ELSE
c	  NPT = 4*(NP-1)
c          DO J=1,NPT
c            FRR(J) = RRT(J)
c	    FZZ(J) = ZZT(J)
c          ENDDO       
c	ENDIF
c        CALL RFT2(FRR,NPT,1)
c        CALL RFT2(FZZ,NPT,1)
c   41   FORMAT(I3,E16.8)  

c	XSHIFT(NR-I+1) =      FRR(1) / REAL(NPT) 
c        XRAD(NR-I+1)   = 2. * FRR(3) / REAL(NPT)
c        XTRIA(NR-I+1)  = 2. * FRR(5) / REAL(NPT)
c	XR3(NR-I+1)    = 2. * FRR(7) / REAL(NPT) 
c	XELL(NR-I+1)   = 2. * ABS(FZZ(4)) / REAL(NPT)
c     >                 / XRAD(NR-I+1)
c	
c	I1 = NR-I+1
c        WRITE(*,11) I1,SQRT(DABS(PS)),XRAD(I1),XSHIFT(I1),
c     >              XELL(I1),XTRIA(I1)
c   10 CONTINUE
c      XRAD(1)   = 0.
c      XSHIFT(1) = XAXIS 
c      XTRIA(1)  = 0.
c      XR3(1)    = 0.
c      XELL(1)   = SQRT(CX/CY)
c   11 FORMAT(I3,5E16.8)

      RETURN
      END
                                                                      

                                                                      
                                                                        
************************************************************************
      SUBROUTINE FLXINT(XAXIS,XX,YY,PSI,NR,NP,A,B,C,EPS,ALFA,           
     >                  IGAM,ISOL,IAS)                                  
C---------------------------------------------------------------------- 
C SUBROUTINE TO EVALUATE NEW DF2 PROFILE                                
C---------------------------------------------------------------------- 
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      COMMON /CORNERS/ RS, IJ, NODENO                                   
      real*8    RS(4,2)                                                   
      integer IJ(4,2), NODENO(MAXMNODE,4)                               
C-----------------------------------------------------------------------
      COMMON /GAUSINT/ XGAUSS,WGAUSS,H,HR,HS,HRS                        
      real*8 XGAUSS(4),WGAUSS(4)                                          
      real*8 H(4,4,4,4),HR(4,4,4,4),HS(4,4,4,4),HRS(4,4,4,4)              
C-----------------------------------------------------------------------
      real*8    BETAPL,BETA                                               
C-----------------------------------------------------------------------
      COMMON/COMPROF/DPR,DF2,ZJZ,QIN,DPRES,DGAM,PINT,GINT,NPTS          
      real*8    DPR(NPTSMAX),DF2(NPTSMAX),ZJZ(NPTSMAX),QIN(NPTSMAX),      
     >        DPRES(1001),DGAM(1001),PINT(1001),GINT(1001)              
      integer NPTS                                                      
C-----------------------------------------------------------------------
      real*8 XX(4,MAXMNODE),YY(4,MAXMNODE),PSI(4*MAXMNODE)                
      real*8 AVC(NRMMAX),XL(NRMMAX),ZPS(NRMMAX)                           
      real*8 DF2TMP(NRMMAX)                                               
      real*8 DD1(NRMMAX),DD2(NRMMAX),DD3(NRMMAX),DD4(NRMMAX),ABLTG(3)     

      PI = 2.D0 * DASIN(1.D0)                                               
                                                                        
      FACTAS = 2.D0                                                       
      IF (IAS.EQ.1) FACTAS=1.D0                                           
                                                                        
      IF ((IGAM.GE.1).AND.(IGAM.LE.4)) THEN                             
         CUR0 = (C+B*XAXIS*(1.D0+EPS*XAXIS/2.D0))/(1.D0+EPS*XAXIS)           
      ELSE                                                              
         CUR0 = (C+B*(1.D0+EPS*XAXIS)**2)/(1.D0+EPS*XAXIS)                 
      ENDIF                                                             
      DF2TMP(1) = 1.D0                                                    
C------------------------------------- NELM ELEMENTS ------------------ 
      R = -1.D0                                                           
      DO 40 I=1,NR-1                                                    
      XLENGTH = 0.D0                                                      
      SUMC1 = 0.D0                                                        
      SUMC2 = 0.D0     
      SUMC3 = 0.D0
      DO 50 J=1,NP-1                                                    
        NELM = (I-1)*(NP-1) + J                                         
        N1 = NODENO(NELM,1)                                             
        N2 = NODENO(NELM,2)                                             
        N3 = NODENO(NELM,3)                                             
        N4 = NODENO(NELM,4)                                             
C------------------------------------- 4 POINT GAUSSIAN INT. IN S ----- 
        DO 60 NGS=1,4                                                   
          S  = XGAUSS(NGS)                                              
          WS = WGAUSS(NGS)                                              
          CALL INTERP(XX(1,N1),XX(1,N2),XX(1,N3),XX(1,N4),              
     >                R,S,X,XR,XS,XRS,XRR,XSS)                          
          CALL INTERP(YY(1,N1),YY(1,N2),YY(1,N3),YY(1,N4),              
     >                R,S,Y,YR,YS,YRS,YRR,YSS)                          
          CALL INTERP(PSI(4*(N1-1)+1),PSI(4*(N2-1)+1),PSI(4*(N3-1)+1),  
     >                PSI(4*(N4-1)+1),                                  
     >                R,S,PS,PSR,PSS,PSRS,PSRR,PSSS)                    
          XJAC =  XR*YS - XS*YR                                         
          DL = DSQRT(XS**2+YS**2)            
          BIGR = (1.D0 + EPS * X)                                         
	  ZJDCHI = BIGR * XJAC / DABS(PSR)  
          XLENGTH = XLENGTH + DL * WS                                   
          SUMC1 = SUMC1 + 1.D0/(1.D0+EPS*X)**2 * ZJDCHI * WS
	  SUMC3 = SUMC3 + 1.D0/(1.D0+EPS*X) * ZJDCHI * WS 
          IF ((IGAM.GE.1).AND.(IGAM.LE.4)) THEN                         
             SUMC2 = SUMC2 + X*(1.D0+EPS*X/2.)/(1.D0+EPS*X)**2
     >                     * ZJDCHI * WS       
          ELSE                                                          
             SUMC2 = SUMC2 + ZJDCHI * WS                    
          ENDIF                                                         
   60     CONTINUE                                                      
   50   CONTINUE                                                        
        ZPS(NR-I+1) = PS                                                       
c        DF2TMP(NR-I+1) = (CUR0*CURPHI(PS)*XLENGTH-B*SUMC2*DPDPSI(PS))   
c     >       / (C*SUMC1)                                                    
        DF2TMP(NR-I+1) = (CUR0*CURPHI(PS)*SUMC3-B*SUMC2*DPDPSI(PS))   
     >       / (C*SUMC1)                                                    

   40 CONTINUE                                                          
c------------------------------------- calc equidistant gamma profile   
      DF2TMP(1) = 1.D0                                                    
      ZPS(1) = 0.D0                                                       
      CALL SPLINE(NR,ZPS,DF2TMP,0.D0,0.D0,2,DD1,DD2,DD3,DD4)                
      DO 70 I=2,NPTS                                                    
        IF ((IGAM.EQ.2).OR.(IGAM.EQ.11)) THEN                           
          SS = dble(I-1)/dble(NPTS-1)                                   
          PS = SS*SS                                                    
        ELSE                                                            
          PS = dble(I-1)/dble(NPTS-1)                                   
        ENDIF                                                           
        DF2(I) = SPWERT(NR,PS,DD1,DD2,DD3,DD4,ZPS,ABLTG)                
   70 CONTINUE                                                          
       DF2(1) = 1.D0            
      RETURN                                                            
      END                                                               
************************************************************************
      SUBROUTINE FLXINT2(XAXIS,XX,YY,PSI,NR,NP,A,B,C,EPS,ALFA,           
     >                  IGAM,ISOL,IAS)                                  
C---------------------------------------------------------------------- 
C SUBROUTINE TO EVALUATE NEW DF2 PROFILE                                
C---------------------------------------------------------------------- 
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      COMMON /CORNERS/ RS, IJ, NODENO                                   
      real*8    RS(4,2)                                                   
      integer IJ(4,2), NODENO(MAXMNODE,4)                               
C-----------------------------------------------------------------------
      COMMON /GAUSINT/ XGAUSS,WGAUSS,H,HR,HS,HRS                        
      real*8 XGAUSS(4),WGAUSS(4)                                          
      real*8 H(4,4,4,4),HR(4,4,4,4),HS(4,4,4,4),HRS(4,4,4,4)              
C-----------------------------------------------------------------------
      real*8    BETAPL,BETA                                               
C-----------------------------------------------------------------------
      COMMON/COMPROF/DPR,DF2,ZJZ,QIN,DPRES,DGAM,PINT,GINT,NPTS          
      real*8    DPR(NPTSMAX),DF2(NPTSMAX),ZJZ(NPTSMAX),QIN(NPTSMAX),      
     >        DPRES(1001),DGAM(1001),PINT(1001),GINT(1001)              
      integer NPTS                                                      
C-----------------------------------------------------------------------
      real*8 XX(4,MAXMNODE),YY(4,MAXMNODE),PSI(4*MAXMNODE)                
      real*8 AVC(NRMMAX),XL(NRMMAX),ZPS(NRMMAX)                           
      real*8 DF2TMP(NRMMAX)                                               
      real*8 DD1(NRMMAX),DD2(NRMMAX),DD3(NRMMAX),DD4(NRMMAX),ABLTG(3)     
                                                                        
      PI = 2.D0 * DASIN(1.D0)                                               
                                                                        
      FACTAS = 2.D0                                                       
      IF (IAS.EQ.1) FACTAS=1.D0                                           
                                                                        
      IF ((IGAM.GE.1).AND.(IGAM.LE.4)) THEN                             
         CUR0 = (C+B*XAXIS*(1.D0+EPS*XAXIS/2.D0))/(1.D0+EPS*XAXIS)           
      ELSE                                                              
         CUR0 = (C+B*(1.D0+EPS*XAXIS)**2)/(1.D0+EPS*XAXIS)                 
      ENDIF                                                             
      DF2TMP(1) = 1.D0                                                    
C------------------------------------- NELM ELEMENTS ------------------ 
      R = -1.D0                                                           
      DO 40 I=1,NR-1                                                    
      XLENGTH = 0.D0                                                      
      SUMC1 = 0.D0                                                        
      SUMC2 = 0.D0                                                        
      DO 50 J=1,NP-1                                                    
        NELM = (I-1)*(NP-1) + J                                         
        N1 = NODENO(NELM,1)                                             
        N2 = NODENO(NELM,2)                                             
        N3 = NODENO(NELM,3)                                             
        N4 = NODENO(NELM,4)                                             
C------------------------------------- 4 POINT GAUSSIAN INT. IN S ----- 
        DO 60 NGS=1,4                                                   
          S  = XGAUSS(NGS)                                              
          WS = WGAUSS(NGS)                                              
          CALL INTERP(XX(1,N1),XX(1,N2),XX(1,N3),XX(1,N4),              
     >                R,S,X,XR,XS,XRS,XRR,XSS)                          
          CALL INTERP(YY(1,N1),YY(1,N2),YY(1,N3),YY(1,N4),              
     >                R,S,Y,YR,YS,YRS,YRR,YSS)                          
          CALL INTERP(PSI(4*(N1-1)+1),PSI(4*(N2-1)+1),PSI(4*(N3-1)+1),  
     >                PSI(4*(N4-1)+1),                                  
     >                R,S,PS,PSR,PSS,PSRS,PSRR,PSSS)                    
          XJAC =  XR*YS - XS*YR                                         
          DL = DSQRT(XS**2+YS**2)                                        
          XLENGTH = XLENGTH + DL * WS                                   
          SUMC1 = SUMC1 + 1.D0/(1.D0+EPS*X) * DL * WS                       
          IF ((IGAM.GE.1).AND.(IGAM.LE.4)) THEN                         
             SUMC2 = SUMC2 + X*(1.D0+EPS*X/2.)/(1.D0+EPS*X) * DL * WS       
          ELSE                                                          
             SUMC2 = SUMC2 + (1.D0+EPS*X) * DL * WS                       
          ENDIF                                                         
   60     CONTINUE                                                      
   50   CONTINUE                                                        
	ZPS(NR-I+1) = PS                                                       
        DF2TMP(NR-I+1) = (CUR0*CURPHI(PS)*XLENGTH-B*SUMC2*DPDPSI(PS))   
     >       / (C*SUMC1)                                                    
   40 CONTINUE                                                          
c------------------------------------- calc equidistant gamma profile   
      DF2TMP(1) = 1.D0                                                    
      ZPS(1) = 0.D0                                                       
      CALL SPLINE(NR,ZPS,DF2TMP,0.D0,0.D0,2,DD1,DD2,DD3,DD4)                
      DO 70 I=2,NPTS                                                    
        IF ((IGAM.EQ.2).OR.(IGAM.EQ.11)) THEN                           
          SS = dble(I-1)/dble(NPTS-1)                                   
          PS = SS*SS                                                    
        ELSE                                                            
          PS = dble(I-1)/dble(NPTS-1)                                   
        ENDIF                                                           
        DF2(I) = SPWERT(NR,PS,DD1,DD2,DD3,DD4,ZPS,ABLTG)                
   70 CONTINUE                                                          
       DF2(1) = 1.D0                                                      
      RETURN                                                            
      END                                                                                                             
************************************************************************
      SUBROUTINE CURRENT(XX,YY,PSI,NR,NP,A,B,C,EPS,ALFA,                
     >                   IGAM,ISOL,CUR,IAS)                             
C---------------------------------------------------------------------- 
C SUBROUTINE TO EVALUATE NEW DF2 PROFILE                                
C---------------------------------------------------------------------- 
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      COMMON /CORNERS/ RS, IJ, NODENO                                   
      real*8    RS(4,2)                                                   
      integer IJ(4,2), NODENO(MAXMNODE,4)                               
C-----------------------------------------------------------------------
      COMMON /GAUSINT/ XGAUSS,WGAUSS,H,HR,HS,HRS                        
      real*8 XGAUSS(4),WGAUSS(4)                                          
      real*8 H(4,4,4,4),HR(4,4,4,4),HS(4,4,4,4),HRS(4,4,4,4)              
C-----------------------------------------------------------------------
      real*8    BETAPL,BETA                                               
C-----------------------------------------------------------------------
      COMMON/COMPROF/DPR,DF2,ZJZ,QIN,DPRES,DGAM,PINT,GINT,NPTS          
      real*8    DPR(NPTSMAX),DF2(NPTSMAX),ZJZ(NPTSMAX),QIN(NPTSMAX),      
     >        DPRES(1001),DGAM(1001),PINT(1001),GINT(1001)              
      integer NPTS                                                      
C-----------------------------------------------------------------------
      real*8 XX(4,MAXMNODE),YY(4,MAXMNODE),PSI(4*MAXMNODE)                
                                                                        
      PI = 2.D0 * DASIN(1.D0)                                               
      FACTAS = 2.D0                                                       
      IF (IAS.EQ.1) FACTAS=1.D0                                           
                                                                        
      R = -1.D0                                                           
      SUMC1 = 0.D0                                                        
      DO 50 J=1,NP-1                                                    
        NELM =  J                                                       
        N1 = NODENO(NELM,1)                                             
        N2 = NODENO(NELM,2)                                             
        N3 = NODENO(NELM,3)                                             
        N4 = NODENO(NELM,4)                                             
C------------------------------------- 4 POINT GAUSSIAN INT. IN S ----- 
        DO 60 NGS=1,4                                                   
          S  = XGAUSS(NGS)                                              
          WS = WGAUSS(NGS)                                              
          CALL INTERP(XX(1,N1),XX(1,N2),XX(1,N3),XX(1,N4),              
     >                R,S,X,XR,XS,XRS,XRR,XSS)                          
          CALL INTERP(YY(1,N1),YY(1,N2),YY(1,N3),YY(1,N4),              
     >                R,S,Y,YR,YS,YRS,YRR,YSS)                          
          CALL INTERP(PSI(4*(N1-1)+1),PSI(4*(N2-1)+1),PSI(4*(N3-1)+1),  
     >                PSI(4*(N4-1)+1),                                  
     >                R,S,PS,PSR,PSS,PSRS,PSRR,PSSS)                    
          XJAC =  XR*YS - XS*YR                                         
          DL = DSQRT(XS**2+YS**2)                                        
          XLENGTH = XLENGTH + DL * WS                                   
	  GRADPS2 = PSR**2 * (XS**2 + YS**2) / XJAC**2                         
          SUMC1 = SUMC1 + DSQRT(GRADPS2)/(1.D0+EPS*X) * DL * WS            
   60     CONTINUE                                                      
   50   CONTINUE                                                        
        CUR = FACTAS * SUMC1 * EPS / ALFA                               
      RETURN                                                            
      END                                                               
                                                                        
                                                                        
************************************************************************
                                                                        
************************************************************************
      SUBROUTINE CIRCUL(XX,YY,PSI,NR,NP,A,B,C,EPS,ALFA,IGAM,IAS,        
     >                  FCIRC,B02AV,B0MAX,RAV)                          
C---------------------------------------------------------------------- 
C SUBROUTINE FOR THE FRACTION OF CIRCULATING PARTICLES                  
C---------------------------------------------------------------------- 
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      COMMON /CORNERS/ RS, IJ, NODENO                                   
      real*8    RS(4,2)                                                   
      integer IJ(4,2), NODENO(MAXMNODE,4)                               
C-----------------------------------------------------------------------
      COMMON /GAUSINT/ XGAUSS,WGAUSS,H,HR,HS,HRS                        
      real*8 XGAUSS(4),WGAUSS(4)                                          
      real*8 H(4,4,4,4),HR(4,4,4,4),HS(4,4,4,4),HRS(4,4,4,4)              
C-----------------------------------------------------------------------
      real*8    BETAPL,BETA                                               
C-----------------------------------------------------------------------
      COMMON/COMPROF/DPR,DF2,ZJZ,QIN,DPRES,DGAM,PINT,GINT,NPTS          
      real*8    DPR(NPTSMAX),DF2(NPTSMAX),ZJZ(NPTSMAX),QIN(NPTSMAX),      
     >        DPRES(1001),DGAM(1001),PINT(1001),GINT(1001)              
      integer NPTS                                                      
C-----------------------------------------------------------------------
      COMMON / COMPIE/ PI                                               
      real*8 PI                                                           
C                                                                       
      real*8 XX(4,*),YY(4,*),PSI(*)                                       
      real*8 FTMP(NRMMAX),DFTMP(NRMMAX)                                   
      real*8 P0TMP(NRMMAX),DPTMP(NRMMAX)                                   
      real*8 B0MAX(*),B02AV(*),FCIRC(*),RAV(*),SUMK(101)                  
                                                                        
      FACTAS = 2.                                                       
      IF (IAS.EQ.1) FACTAS=1.                                           
                                                                        
      R0 = 1.D0                                                           
      B0 = 1.D0                                                           
      RADIUS = EPS * R0                                                 
      CPSURF = RADIUS**2 * B0 / ALFA                                    
                                                                        
      CALL PROFILES(P0TMP,FTMP,DPTMP,DFTMP,A)                           
                                                                        
      RBSCALE = B0 * R0                                                 
      DO I = 1,NR                                                       
        FTMP(I)  = FTMP(I)  * RBSCALE                                   
        DFTMP(I) = DFTMP(I) * RBSCALE                                   
      ENDDO                                                             
c---------------------- find Bmax and B^2 average on every surface      
      R = -1.D0                                                           
      DO 40 I=1,NR-1                                                    
      SUM1 = 0.D0                                                         
      SUM2 = 0.D0                                                         
      SUMR = 0.D0                                                         
      B02MAX = -1.D20                                                   
      DO 50 J=1,NP-1                                                    
        N1 = (I-1)*NP + J                                               
        N2 = N1 + 1                                                     
        N3 = N2 + NP                                                    
        N4 = N1 + NP                                                    
C------------------------------------- 4 POINT GAUSSIAN INT. IN S ----- 
        DO 60 NGS=1,4                                                   
          S  = XGAUSS(NGS)                                              
          WS = WGAUSS(NGS)                                              
          CALL INTERP(XX(1,N1),XX(1,N2),XX(1,N3),XX(1,N4),              
     >                R,S,X,XR,XS,XRS,XRR,XSS)                          
          CALL INTERP(YY(1,N1),YY(1,N2),YY(1,N3),YY(1,N4),              
     >                R,S,Y,YR,YS,YRS,YRR,YSS)                          
          CALL INTERP(PSI(4*(N1-1)+1),PSI(4*(N2-1)+1),PSI(4*(N3-1)+1),  
     >                PSI(4*(N4-1)+1),                                  
     >                R,S,PS,PSR,PSS,PSRS,PSRR,PSSS)                    
                                                                        
          XJAC =  XR*YS - XS*YR                                         
          BIGR = (1.D0 + EPS * X)                                         
	  GRADPS2 = PSR**2 * (XS**2 + YS**2) / XJAC**2                         
c------------------------------------------------ normalisations	       
	  GRADPS2 = GRADPS2 * (CPSURF/RADIUS)**2                               
	  XJAC    = XJAC * RADIUS**2                                           
	  BIGR    = BIGR                                                       
	  PSR     = CPSURF * PSR                                               
c---------------------------------------------------------------        
	  ZJDCHI = BIGR * XJAC / DABS(PSR)                                      
          B02 = (FTMP(NR-I+1)/BIGR)**2 + GRADPS2/BIGR**2                
	  SUM1  = SUM1 - WS * ZJDCHI                                           
          SUM2  = SUM2 - WS * ZJDCHI * B02                              
          SUMR  = SUMR - WS * ZJDCHI * BIGR                             
                                                                        
          IF (B02.GT.B02MAX) B02MAX = B02                               
   60     CONTINUE                                                      
   50   CONTINUE                                                        
        NI = NR-I+1                                                     
        SUM1 = FACTAS * SUM1 / (2.*PI)                                  
	SUM2 = FACTAS * SUM2 / (2.*PI)                                         
        SUMR = FACTAS * SUMR / (2.*PI)                                  
	B02AV(NI) = SUM2 / SUM1                                                
        B0MAX(NI) = DSQRT(DABS(B02MAX))                                        
	RAV(NI)   = SUMR / SUM1                                                
   40 CONTINUE                                                          
   41 FORMAT(I3,1P15E11.3)                                              
                                                                        
c---------------------------------- calculate average term in integral  
      NK=101                                                            
      R = -1.D0                                                           
      DO 140 I=1,NR-1                                                   
        SUM1 = 0.D0                                                       
        DO K=1,NK                                                       
          SUMK(K) = 0.D0                                                  
        ENDDO                                                           
      DO 150 J=1,NP-1                                                   
        N1 = (I-1)*NP + J                                               
        N2 = N1 + 1                                                     
        N3 = N2 + NP                                                    
        N4 = N1 + NP                                                    
C------------------------------------- 4 POINT GAUSSIAN INT. IN S ----- 
        DO 160 NGS=1,4                                                  
          S  = XGAUSS(NGS)                                              
          WS = WGAUSS(NGS)                                              
          CALL INTERP(XX(1,N1),XX(1,N2),XX(1,N3),XX(1,N4),              
     >                R,S,X,XR,XS,XRS,XRR,XSS)                          
          CALL INTERP(YY(1,N1),YY(1,N2),YY(1,N3),YY(1,N4),              
     >                R,S,Y,YR,YS,YRS,YRR,YSS)                          
          CALL INTERP(PSI(4*(N1-1)+1),PSI(4*(N2-1)+1),PSI(4*(N3-1)+1),  
     >                PSI(4*(N4-1)+1),                                  
     >                R,S,PS,PSR,PSS,PSRS,PSRR,PSSS)                    
                                                                        
          XJAC =  XR*YS - XS*YR                                         
          BIGR = (1.D0 + EPS * X)                                         
	  GRADPS2 = PSR**2 * (XS**2 + YS**2) / XJAC**2                         
c------------------------------------------------ normalisations	       
	  GRADPS2 = GRADPS2 * (CPSURF/RADIUS)**2                               
	  XJAC    = XJAC * RADIUS**2                                           
	  BIGR    = BIGR                                                       
	  PSR     = CPSURF * PSR                                               
c---------------------------------------------------------------        
	  ZJDCHI = BIGR * XJAC / DABS(PSR)                                      
          B02 = (FTMP(NR-I+1)/BIGR)**2 + GRADPS2/BIGR**2                
	  B0 = DSQRT(DABS(B02))                                                       
	  BM = B0MAX(NR-I+1)                                                   
	  DO K = 1, NK                                                         
	    ZLAM = dble(K-1)/dble(NK-1)                                      
	    SUMK(K) = SUMK(K) - WS*ZJDCHI*DSQRT(DABS(1.-ZLAM*B0/BM))         
	  ENDDO                                                                
          SUM1  = SUM1 - WS * ZJDCHI                                    
  160     CONTINUE                                                      
  150   CONTINUE                                                        
        NI = NR-I+1                                                     
c        DO K=1,NK                                                      
c	  SUMK(K) = SUMK(K) / SUM1                                            
ccc	  WRITE(*,*) I,K,SUMK(K)                                           
c        ENDDO                                                          
c------------------------------------------ integrate over lambda       
        SUM = 0.D0                                                        
        DO K=2,NK-1                                                     
	  ZLAM = dble(K-1)/dble(NK-1)                                        
	  SUM = SUM + ZLAM * SUM1 / SUMK(K)                                    
	ENDDO                                                                  
	FCIRC(NI) = (SUM + 0.5D0 * SUM1/SUMK(NK)) / dble(NK-1)                  
	FCIRC(NI) = 0.75D0 * FCIRC(NI)  * B02AV(NI) / B0MAX(NI)**2               
ccc        WRITE(*,41) I,SQRT(PS),B02AV(NI),B0MAX(NI),FCIRC(NI)        
  140 CONTINUE                                                          
                                                                        
      RETURN                                                            
      END                                                               
                                                                        
                                                                        
                                                                        
                                                                        
                                                                        
************************************************************************
C***********************************************************************
C***********************************************************************
C**                                                                   **
C**  BELOW FOLLOW THE SOURCES OF THE HGOLIB ROUTINES AS USED IN       **
C**  HELENA :                                                         **
C**                     - GRID2NV      - ZERO                         **
C**                     - RFT2         - RTRAN2                       **
C**                     - RFT          - FFT2                         **
C**                     - PRARR1       - FSUM2                        **
C**                     - PRARR2                                      **
C**                                                                   **
C***********************************************************************
C***********************************************************************
                                                                        
************************************************************************
      SUBROUTINE ZERO(X1,Y1,X2,Y2,FUNC,ERR,X,Y,IZERO,LL)                
C                                                                       
C     ******************************************************************
C     * THE ZERO Y=FUNC(X)=0 ON THE INTERVAL (X1,X2) IS FOUND.         *
C     * THE FUNCTION FUNC(X) SHOULD BE PROVIDED BY AN EXTERNAL.        *
C     * UPON RETURN IZERO IS THE NUMBER OF ITERATIONS WHICH WERE       *
C     * REQUIRED TO OBTAIN ABS(Y).LE.ERR.                              *
C     * DIAGNOSTIC INFORMATION IS PRINTED IF L.NE.0.                   *
C     * THE ARGUMENT LL HAS THE DOUBLE FUNCTION OF COMMUNICATING THE   *
C     * OUTPUT UNIT IOUT=LL/10 AND THE PRINT SWITCH L=LL-IOUT*10.      *
C     * IOUT=0 (L=LL): FILE IS "OUTPUT".                               *
C     * MODIFIED BY JAN REM TO IMPROVE CONVERGENCE 25/08/84.           *
C     ******************************************************************
C                                                                       
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      EXTERNAL FUNC                                                     
C                                                                       
      IOUT=LL/10                                                        
      L=LL-IOUT*10                                                      
      NIZERO=50                                                         
      IF((Y1.LT.0..AND.Y2.LT.0.).OR.(Y1.GT.0..AND.Y2.GT.0.)) THEN       
         IF(IOUT.EQ.0) WRITE(   *,5)                                    
         IF(IOUT.NE.0) WRITE(IOUT,5)                                    
         RETURN                                                         
      ENDIF                                                             
      IF(L.NE.0) THEN                                                   
         IF(IOUT.EQ.0) WRITE(   *,6)                                    
         IF(IOUT.NE.0) WRITE(IOUT,6)                                    
      ENDIF                                                             
      X1S=X1                                                            
      Y1S=Y1                                                            
      X2S=X2                                                            
      Y2S=Y2                                                            
      IF(X1.GT.X2) THEN                                                 
         X1=X2S                                                         
         Y1=Y2S                                                         
         X2=X1S                                                         
         Y2=Y1S                                                         
      ENDIF                                                             
      SIG=1.                                                            
      IF(Y1.GE.0.) THEN                                                 
         SIG=-1.                                                        
         Y1=-Y1                                                         
         Y2=-Y2                                                         
      ENDIF                                                             
C                                                                       
C     ***BEGIN LOOP ON IZERO***                                         
      IZERO=0                                                           
   10 X0=X1-(X2-X1)*Y1/(Y2-Y1)                                          
      Y0=SIG*FUNC(X0)                                                   
      IZERO=IZERO+1                                                     
      IF(L.NE.0) THEN                                                   
         IF(IOUT.EQ.0) WRITE(   *,11) IZERO,X1,Y1,X2,Y2,X0,Y0           
         IF(IOUT.NE.0) WRITE(IOUT,11) IZERO,X1,Y1,X2,Y2,X0,Y0           
      ENDIF                                                             
      IF(DABS(Y0).LE.ERR) GOTO 20                                        
      IF(DABS(Y0).GE.0.2D0*MIN(-Y1,Y2)) THEN                               
         A=((Y2-Y0)/(X2-X0)-(Y0-Y1)/(X0-X1))/(X2-X1)                    
         B=(Y2-Y1)/(X2-X1)-A*(X2+X1)                                    
         C=Y0-A*X0*X0-B*X0                                              
         XN=(-B+DSQRT(B*B-4.D0*A*C))/(2.D0*A)                                
         YN=SIG*FUNC(XN)                                                
         IZERO=IZERO+1                                                  
         IF(L.NE.0) THEN                                                
            IF(IOUT.EQ.0) WRITE(   *,12) IZERO,X1,Y1,X2,Y2,XN,YN        
            IF(IOUT.NE.0) WRITE(IOUT,12) IZERO,X1,Y1,X2,Y2,XN,YN        
         ENDIF                                                          
         IF(DABS(YN).LE.ERR) GOTO 30                                     
         IF(YN.LT.0.D0) THEN                                              
            X1=XN                                                       
            Y1=YN                                                       
            IF(Y0.GT.0.D0) THEN                                           
               X2=X0                                                    
               Y2=Y0                                                    
            ENDIF                                                       
         ELSE                                                           
            X2=XN                                                       
            Y2=YN                                                       
            IF(Y0.LT.0.D0) THEN                                           
               X1=X0                                                    
               Y1=Y0                                                    
            ENDIF                                                       
         ENDIF                                                          
      ELSEIF(Y0.GT.ERR) THEN                                            
         X2=X0                                                          
         Y2=Y0                                                          
      ELSE                                                              
         X1=X0                                                          
         Y1=Y0                                                          
      ENDIF                                                             
      IF(IZERO.LT.NIZERO) GOTO 10                                       
C     ***END LOOP ON IZERO***                                           
      IF(IOUT.EQ.0) WRITE(   *,13) NIZERO                               
      IF(IOUT.NE.0) WRITE(IOUT,13) NIZERO                               
C                                                                       
   20 X=X0                                                              
      Y=SIG*Y0                                                          
      X1=X1S                                                            
      Y1=Y1S                                                            
      X2=X2S                                                            
      Y2=Y2S                                                            
      RETURN                                                            
C                                                                       
   30 X=XN                                                              
      Y=SIG*YN                                                          
      X1=X1S                                                            
      Y1=Y1S                                                            
      X2=X2S                                                            
      Y2=Y2S                                                            
      RETURN                                                            
C                                                                       
C     * FORMATS.                                                        
    5 FORMAT(/1X,'***SUBROUTINE ZERO: Y1 AND Y2 VIOLATE REQUIREMENTS')  
    6 FORMAT(/30X,'==== SUBROUTINE ZERO ====')                          
   11 FORMAT(1X,'IZERO=',I3,3X,'X1=',1PE12.4,3X,'Y1=',1PE12.4,          
     A       3X,'X2=',1PE12.4,3X,'Y2=',1PE12.4,3X,'X0=',1PE12.4,        
     B       3X,'Y0=',1PE12.4)                                          
   12 FORMAT(1X,'IZERO=',I3,3X,'X1=',1PE12.4,3X,'Y1=',1PE12.4,          
     A       3X,'X2=',1PE12.4,3X,'Y2=',1PE12.4,3X,'XN=',1PE12.4,        
     B       3X,'YN=',1PE12.4)                                          
   13 FORMAT(/1X,'***SUBROUTINE ZERO: NO CONVERGENCE FOR X IN ',I3,     
     A       ' STEPS')                                                  
      END                                                               
C                                                                       
************************************************************************
      SUBROUTINE RFT2(DATA,NR,KR)                                       
C                                                                       
C     ******************************************************************
C     * real*8 FOURIER TRANSFORM.                                        *
C     * INPUT:  NR real*8 COEFFICIENTS                                   *
C     *             DATA(1),DATA(1+KR),....,DATA(1+(NR-1)*KR).         *
C     * OUTPUT: NR/2+1 COMPLEX COEFFICIENTS                            *
C     *            (DATA(1),      DATA(1+KR))                          *
C     *            (DATA(1+2*KR), DATA(1+3*KR))                        *
C     *             .............................                      *
C     *            (DATA(1+NR*KR),DATA(1+(NR+1)*KR).                   *
C     * THE CALLING PROGRAM SHOULD HAVE DATA DIMENSIONED WITH AT LEAST *
C     * (NR+1)*KR+1 ELEMENTS. (I.E., NR+2 IF INCREMENT KR=1).          *
C     * LASL ROUTINE MAY 75, CALLING FFT2 AND RTRAN2.                  *
C     ******************************************************************
C                                                                       
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      REAL*8 DATA(*)                                                 
      CALL FFT2(DATA(1),DATA(KR+1),NR/2,-(KR+KR))                       
      CALL RTRAN2(DATA,NR,KR,1)                                         
      RETURN                                                            
      END                                                               
C                                                                       
C                                                                       
************************************************************************
      SUBROUTINE RTRAN2(DATA,NR,KR,KTRAN)                               
C                                                                       
C     ******************************************************************
C     * INTERFACE BETWEEN RFT2, RFI2, AND FFT2.                        *
C     * THE CALLING PROGRAM SHOULD HAVE DATA DIMENSIONED WITH AT LEAST *
C     * (NR+1)*KR+1 ELEMENTS.                                          *
C     * LASL ROUTINE MAY 75, CALLED FROM RFT2 AND RFI2.                *
C     ******************************************************************
C                                                                       
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      REAL*8 DATA(*)                                                 
      KS=2*KR                                                           
      N=NR/2                                                            
      NMAX=N*KS+2                                                       
      KMAX=NMAX/2                                                       
      THETA=1.5707963267949D0/N                                           
      DC=2.D0*DSIN(THETA)**2                                               
      DS=DSIN(2.D0*THETA)                                                  
      WS=0.D0                                                             
      IF(KTRAN.LE.0) THEN                                               
         WC=-1.0D0                                                        
         DS=-DS                                                         
      ELSE                                                              
         WC=1.0D0                                                         
         DATA(NMAX-1)=DATA(1)                                           
         DATA(NMAX-1+KR)=DATA(KR+1)                                     
      ENDIF                                                             
      DO 10 K=1,KMAX,KS                                                 
         NK=NMAX-K                                                      
         SUMR=.5D0*(DATA(K)+DATA(NK))                                     
         DIFR=.5D0*(DATA(K)-DATA(NK))                                     
         SUMI=.5D0*(DATA(K+KR)+DATA(NK+KR))                               
         DIFI=.5D0*(DATA(K+KR)-DATA(NK+KR))                               
         TR=WC*SUMI-WS*DIFR                                             
         TI=WS*SUMI+WC*DIFR                                             
         DATA(K)=SUMR+TR                                                
         DATA(K+KR)=DIFI-TI                                             
         DATA(NK)=SUMR-TR                                               
         DATA(NK+KR)=-DIFI-TI                                           
         WCA=WC-DC*WC-DS*WS                                             
         WS=WS+DS*WC-DC*WS                                              
         WC=WCA                                                         
   10 CONTINUE                                                          
      RETURN                                                            
      END                                                               
C                                                                       
************************************************************************
      SUBROUTINE FFT2 (DATAR,DATAI,N,INC)                               
C                                                                       
C     ******************************************************************
C     * FFT2 FORTRAN VERSION CLAIR NIELSON MAY 75.                     *
C     ******************************************************************
C                                                                       
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      REAL*8 DATAR(*), DATAI(*)                                      
      KTRAN=ISIGN(-1,INC)                                               
      KS=IABS(INC)                                                      
      IP0=KS                                                            
      IP3=IP0*N                                                         
      IREV=1                                                            
      DO 20 I=1,IP3,IP0                                                 
         IF(I.LT.IREV) THEN                                             
            TEMPR=DATAR(I)                                              
            TEMPI=DATAI(I)                                              
            DATAR(I)=DATAR(IREV)                                        
            DATAI(I)=DATAI(IREV)                                        
            DATAR(IREV)=TEMPR                                           
            DATAI(IREV)=TEMPI                                           
         ENDIF                                                          
         IBIT=IP3/2                                                     
   10    IF(IREV.GT.IBIT) THEN                                          
            IREV=IREV-IBIT                                              
            IBIT=IBIT/2                                                 
            IF(IBIT.GE.IP0) GOTO 10                                     
         ENDIF                                                          
   20    IREV=IREV+IBIT                                                 
      IP1=IP0                                                           
      THETA=dble(KTRAN)*3.1415926535898D0                                 
   30 IF(IP1.GE.IP3) GOTO 60                                            
      IP2=IP1+IP1                                                       
      SINTH=DSIN(.5D0*THETA)                                               
      WSTPR=-2.D0*SINTH*SINTH                                             
      WSTPI=DSIN(THETA)                                                  
      WR=1.D0                                                             
      WI=0.D0                                                             
      DO 50 I1=1,IP1,IP0                                                
         DO 40 I3=I1,IP3,IP2                                            
            J0=I3                                                       
            J1=J0+IP1                                                   
            TEMPR=WR*DATAR(J1)-WI*DATAI(J1)                             
            TEMPI=WR*DATAI(J1)+WI*DATAR(J1)                             
            DATAR(J1)=DATAR(J0)-TEMPR                                   
            DATAI(J1)=DATAI(J0)-TEMPI                                   
            DATAR(J0)=DATAR(J0)+TEMPR                                   
   40       DATAI(J0)=DATAI(J0)+TEMPI                                   
         TEMPR=WR                                                       
         WR=WR*WSTPR-WI*WSTPI+WR                                        
   50    WI=WI*WSTPR+TEMPR*WSTPI+WI                                     
      IP1=IP2                                                           
      THETA=.5D0*THETA                                                    
      GOTO 30                                                           
   60 RETURN                                                            
      END                                                               
                                                                        
************************************************************************
      SUBROUTINE GRID2NV(TIN,TOUT,JPTS,ACC,IGRD,LL)                     
C-----------------------------------------------------------------------
C  THE FUNCTION TIN(TOUT), GIVEN ON THE GRID TOUT=2*PI*(J-1)/JPTS,      
C  IS INVERTED TO GIVE TOUT(TIN) ON THE GRID TIN=2*PI*(I-1)/JPTS.       
C  THIS IS DONE BY DETERMINING THE ZEROS OF THE FUNCTION                
C     Y(T)=T+SUM(GF(M)*SIN(M*T))-2*PI*(I-1)/JPTS,                       
C  WHERE GF(M) ARE THE FOURIER COEFFICIENTS OF G(T)=TIN(T)-T.           
C  DIAGNOSTIC INFORMATION IS PRINTED IF L.NE.0.                         
C  THE ARGUMENT LL HAS THE DOUBLE FUNCTION OF COMMUNICATING THE         
C  OUTPUT UNIT IOUT=LL/10 AND THE PRINT SWITCH L=LL-IOUT*10.            
C  IOUT=0 (L=LL): FILE IS "OUTPUT".                                     
C-----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (JMAX=1024,NINV=100)                                    
      REAL*8 TIN(*),TOUT(*),T(JMAX+1),G(JMAX+1),GFCOS(JMAX/2-1),     
     A          GFSIN(JMAX/2-1)                                         
      EQUIVALENCE(T(1),G(1))                                            
C                                                                       
      PI=2.D0*DASIN(1.D0)                                                
      MHARM=JPTS/2-1                                                    
C                                                                       

      DO 9 JJ=2,JPTS                                                    
        IF (TIN(JJ-1).GT.TIN(JJ))  TIN(JJ)=TIN(JJ)+2*PI                 
    9 CONTINUE                                                          
      IOUT=LL/10                                                        
      L=LL-IOUT*10                                                      
      IF(L.NE.0) THEN                                                   
         IF(IOUT.EQ.0) WRITE(   *,3)                                    
         IF(IOUT.NE.0) WRITE(IOUT,3)                                    
      ENDIF                                                             
      DO 10 I=1,JPTS                                                    
   10 G(I)=TIN(I)-2.D0*PI*REAL(I-1)/REAL(JPTS)                                     
      CALL RFT(G,GFNUL,GFCOS,GFSIN,JPTS,MHARM)                          
      IF(L.NE.0) THEN                                                   
c         CALL PRARR1('TIN(J) : ',TIN,JPTS,IOUT*10+L)                   
c         CALL PRARR1('G(I):',T,JPTS,IOUT*10+L)                         
         IF(IOUT.EQ.0) WRITE(*,56) GFNUL                               
         IF(IOUT.NE.0) WRITE(IOUT,56) GFNUL                             
c         CALL PRARR1('GFCOS(M):',GFCOS,MHARM,IOUT*10+L)                
c         CALL PRARR1('GFSIN(M):',GFSIN,MHARM,IOUT*10+L)                
      ENDIF                                                             
      DO 20 I=1,JPTS+1                                                  
        T(I)=2.D0*PI*REAL(I-1)/REAL(JPTS)                                          
   20 CONTINUE                                                          
      J1=1                                                              
      IGRDNV=1                                                          
      IFIRST=0                                                          
      ICIRC= - (INT(TIN(1)/(2.D0*PI)+10000.D0) -  9999.D0)                       
      IF (DABS(TIN(1)).LT.1D-12) ICIRC=0                                 
      DO 80 I=1,JPTS                                                    
        J=J1                                                            
        T1=T(J) + ICIRC*2.D0*PI                                            
        CALL FSUM2(SUM1,T1,GFNUL,GFCOS,GFSIN,MHARM)                     
        Y1=T1+SUM1-T(I)                                                 
   30   CONTINUE                                                        
          T0=T1                                                         
          Y0=Y1                                                         
          IF (DABS(Y0).LE.ACC) THEN                                      
            TOUT(I)=T0                                                  
            GOTO 80                                                     
          ENDIF                                                         
          IF (J.NE.JPTS+1) GOTO 31                                      
            IF (IFIRST.EQ.0)  THEN                                      
              J=1                                                       
              ICIRC=ICIRC+1                                             
              IFIRST=1                                                  
            ELSE                                                        
              WRITE(IOUT,70)                                            
              GOTO 90                                                   
            ENDIF                                                       
   31     J=J+1                                                         
          T1=T(J) + ICIRC*2.D0*PI                                          
          CALL FSUM2(SUM1,T1,GFNUL,GFCOS,GFSIN,MHARM)                   
          Y1=T1+SUM1-T(I)                                               
          IF(DSIGN(1.D0,Y0).EQ.DSIGN(1.D0,Y1)) GOTO 30                        
        J1=J-1                                                          
        DO 40 N=1,NINV                                                  
          T2=T0-(T1-T0)*Y0/(Y1-Y0)                                      
          CALL FSUM2(SUM2,T2,GFNUL,GFCOS,GFSIN,MHARM)                   
          Y2=T2+SUM2-T(I)                                               
          IF(L.NE.0) THEN                                               
             IF(IOUT.EQ.0) WRITE(   *,25) N,T0,T1,Y0,Y1,T2,Y2,J         
             IF(IOUT.NE.0) WRITE(IOUT,25) N,T0,T1,Y0,Y1,T2,Y2,J         
          ENDIF                                                         
          IF(DABS(Y2).LE.ACC) GOTO 50                                    
          IF(DSIGN(1.D0,Y2).EQ.DSIGN(1.D0,Y1)) GOTO 45                        
          T0=T2                                                         
          Y0=Y2                                                         
          GOTO 40                                                       
   45     T1=T2                                                         
          Y1=Y2                                                         
   40   CONTINUE                                                        
   50   TOUT(I)=T2                                                      
        IF(L.NE.0) THEN                                                 
          IF(IOUT.EQ.0) WRITE(   *,55) I,N                              
          IF(IOUT.NE.0) WRITE(IOUT,55) I,N                              
        ENDIF                                                           
        IF(N.GT.IGRDNV) IGRDNV=N                                        
   80 CONTINUE                                                          
   90 RETURN                                                            
C                                                                       
C     * FORMATS.                                                        
    3 FORMAT(///1X,'SUBROUTINE GRIDINV')                                
   25 FORMAT(1X,'N=',I3,' T0=',F10.5,' T1=',F10.5,                      
     A       ' Y0=',F10.5,' Y1=',F10.5,' T2=',F10.5,' Y2=',F10.5,       
     B       ' J=',I3)                                                  
   55 FORMAT(1X,'I=',I3,5X,'N=',I3)                                     
   56 FORMAT(/1X,'GFNUL = ',1PE12.4)                                    
   70 FORMAT(/1X,'***SUBROUTINE GRIDINV: NO ZERO FOUND ')               
      END                                                               
                                                                        
************************************************************************
      SUBROUTINE FSUM2(F,T,FFNUL,FFCOS,FFSIN,MHARM)                     
C-----------------------------------------------------------------------
C FOURIER SYNTHESIS OF GENERAL  FUNCTION F(T) AT SINGLE POINT T.        
C-----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      REAL*8 FFCOS(*),FFSIN(*)                                       
      CO=DCOS(T)                                                         
      SI=DSIN(T)                                                         
      C=1.D0                                                              
      S=0.D0                                                              
      SUM=.5D0*FFNUL                                                      
      DO 10 M=1,MHARM                                                   
        CA=C*CO-S*SI                                                    
        S=S*CO+C*SI                                                     
        C=CA                                                            
        SUM=SUM+FFCOS(M)*C + FFSIN(M)*S                                 
   10 CONTINUE                                                          
      F=SUM                                                             
      RETURN                                                            
      END                                                               
                                                                        
************************************************************************
      SUBROUTINE RFT(F,FFNUL,FFCOS,FFSIN,JPTS,MHARM)                    
C-----------------------------------------------------------------------
C  CALCULATES FOURIER COSINE AND SINE COEFFICIENTS FFCOS AND            
C  FFSIN OF THE ARRAY FF CORRESPONDING TO THE  FUNCTION                 
C  F(T)=.5*FFNUL+SUM(FFCOS(M)*COS(M*T)+FFSIN(M)*SIN(M*T))               
C  WHERE MHARM.LE.JPTS/2-1, FFNUL=FF(0) AND T=2*PI*(J-1)/JPTS.          
C  THE INPUT ARRAY F(J) IS NOT DESTROYED BY CALLING RFTCOS.             
C  TYPICAL USE IS FOR MHARM MUCH SMALLER THAN JPTS/2-1, SO THAT         
C  RFT2 CANNOT BE USED DIRECTLY.                                        
C-----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (JMAX=1024)                                             
      REAL*8 F(*),FFCOS(*),FFSIN(*),FSTORE(JMAX+2)                   
      DO 10 J=1,JPTS                                                    
   10 FSTORE(J)=F(J)                                                    
      CALL RFT2(FSTORE,JPTS,1)                                          
      FAC=2.D0/DBLE(JPTS)                                                       
      FFNUL=FSTORE(1)*FAC                                               
      DO 20 M=1,MHARM                                                   
        FFCOS(M)=FSTORE(2*M+1)*FAC                                      
        FFSIN(M) = - FSTORE(2*M+2)*FAC                                  
   20 CONTINUE                                                          
      RETURN                                                            
      END                                                               
                                                                        
************************************************************************
      SUBROUTINE RFI2(DATA,NR,KR)                                       
C-----------------------------------------------------------------------
C  INVERSE OF RFT2.                                                     
C  WHEN USING RFI2 IT IS NECESSARY TO HAVE VANISHING IMAGINARY          
C  PARTS OF THE FIRST AND LAST ELEMENT OF THE INPUT VECTOR:             
C  DATA(1+KR)=DATA(1+(NR+1)*KR)=0.                                      
C  THE CALLING PROGRAM SHOULD HAVE DATA DIMENSIONED WITH AT LEAST       
C    (NR+1)*KR+1 ELEMENTS.                                              
C  LASL ROUTINE MAY 75, CALLING RTRAN2 AND FFT2.                        
C ----------------------------------------------------------------------
C                                                                       
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      REAL*8 DATA(*)                                                 
      CALL RTRAN2(DATA,NR,KR,-1)                                        
      MR=NR*KR                                                          
      FNI=2.D0/DBLE(NR)                                                         
      DO 10 I=1,MR,KR                                                   
   10 DATA(I)=FNI*DATA(I)                                               
      CALL FFT2(DATA(1),DATA(KR+1),NR/2,(KR+KR))                        
      RETURN                                                            
      END                                                               
                                                                        
************************************************************************
      SUBROUTINE mnewtax(ntrial,x,n,tolx,tolf,errx,errf,ifail)                
C-----------------------------------------------------------------------
C ROUTINE TO SOLVE TWO NONLINEAR EQUATIONS USING NEWTONS METHOD FROM    
C NUMERICAL RECIPES.                                                    
C LU DECOMPOSITION REPLACED BY EXPLICIT SOLUTION OF 2X2 MATRIX.         
C-----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
C-----------------------------------------------------------------------
      COMMON /CORNERS/ RS, IJ, NODENO                                   
      real*8    RS(4,2)                                                   
      integer IJ(4,2), NODENO(MAXMNODE,4)                               
C-----------------------------------------------------------------------
      COMMON/FAXIS/PSI,NAXIS                                            
      real*8    PSI(4*MAXMNODE)                                           
      integer NAXIS                                                     
C-----------------------------------------------------------------------
      PARAMETER (NEQ=2)                                                 
      real*8 X(NEQ),FVEC(NEQ),FJAC(NEQ,NEQ)                               
      integer n,ntrial                                                  
      real*8 tolf,tolx                                                    
      integer i,k,indx(NEQ)                                             
      real*8 d,errf,errx,p(NEQ)                                           
                                                                        
      ifail=0
      do  k=1,ntrial                                                 
c----------------------------- usrfun iserted here ---------------------
        R = X(1)                                                        
        S = X(2)                                                        
        N1 = NODENO(NAXIS,1)                                            
        N2 = NODENO(NAXIS,2)                                            
        N3 = NODENO(NAXIS,3)                                            
        N4 = NODENO(NAXIS,4)                                            
        CALL INTERP(PSI(4*(N1-1)+1),PSI(4*(N2-1)+1),                    
     >            PSI(4*(N3-1)+1),PSI(4*(N4-1)+1),                      
     >            R,S,ZPSI,ZPSIR,ZPSIS,ZPSIRS,ZPSIRR,ZPSISS)            
        FVEC(1) = ZPSIR                                                 
        FVEC(2) = ZPSIS                                                 
        FJAC(1,1) = ZPSIRR                                              
        FJAC(1,2) = ZPSIRS                                              
        FJAC(2,1) = ZPSIRS                                              
        FJAC(2,2) = ZPSISS                                              
c-----------------------------------------------------------------------                                                      
        errf=dabs(fvec(1))+dabs(fvec(2))                                        
        if(errf.le.tolf)return   

	p(1) = -fvec(1)
	p(2) = -fvec(2)                                       
        temp = p(1)                                                     
        dis = fjac(2,2)*fjac(1,1)-fjac(1,2)*fjac(2,1)                   
        p(1) = (fjac(2,2)*p(1)-fjac(1,2)*p(2))/dis                      
        p(2) = (fjac(1,1)*p(2)-fjac(2,1)*temp)/dis                                                 
				                        
        errx=dabs(p(1))+dabs(p(2))   
	x(1) = x(1) + p(1)
	x(2) = X(2) + p(2)                                                                                       
        if(errx.le.tolx)return                                          
      enddo   
      ifail=1                                                 
      return                                                            
      END                                                               
C  (C) Copr. 1986-92 Numerical Recipes Software *N*1V45_Lt+V'.          
                                                                        
                                                                        
************************************************************************
      SUBROUTINE SPLINE(N,X,Y,ALFA,BETA,TYP,A,B,C,D)                    
C-----------------------------------------------------------------------
C     INPUT:                                                            
C                                                                       
C     N     ANZAHL DER KNOTEN                                           
C     X     ARRAY DER X-WERTE                                           
C     Y     ARRAY DER Y-WERTE                                           
C     ALFA  RANDBEDINGUNG IN X(1)                                       
C     BETA        "       IN X(N)                                       
C     TYP   =  0  NOT-A-KNOT SPLINE                                     
C              1  ALFA, BETA 1. ABLEITUNGEN VORGEGEBEN                  
C              2    "    "   2.     "           "                       
C              3    "    "   3.     "           "                       
C                                                                       
C     BEMERKUNG: MIT TYP = 2 UND ALFA = BETA = 0 ERHAELT MAN            
C           EINEN NATUERLICHEN SPLINE                                   
C                                                                       
C     OUTPUT:                                                           
C                                                                       
C     A, B, C, D     ARRAYS DER SPLINEKOEFFIZIENTEN                     
C       S = A(I) + B(I)*(X-X(I)) + C(I)*(X-X(I))**2+ D(I)*(X-X(I))**3   
C                                                                       
C     BEI ANWENDUNGSFEHLERN WIRD DAS PROGRAMM MIT ENTSPRECHENDER        
C     FEHLERMELDUNG ABGEBROCHEN                                         
C-----------------------------------------------------------------------
C                                                                       
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      integer  N, TYP                                                   
      real*8     X(N), Y(N), ALFA, BETA, A(N), B(N), C(N), D(N)           
      integer  I, IERR                                                  
      real*8     H(1001)                                                  
                                                                              
C                                                                       
      NMAX = 1001                                                       
      IF((TYP.LT.0).OR.(TYP.GT.3)) THEN                                 
         WRITE(*,*) 'FEHLER IN ROUTINE SPLINE: FALSCHER TYP'            
         CALL mexErrMsgTxt('FEHLER IN ROUTINE SPLINE: FALSCHER TYP')                                                           
      ENDIF                                                             
C                                                                       
      IF((N.LT.3).OR.(N.GT.NMAX)) THEN                                  
         WRITE(*,*) 'FEHLER IN ROUTINE  SPLINE: N < 3 ODER N > NMAX'    
         CALL mexErrMsgTxt('FEHLER IN ROUTINE  SPLINE')                                                            
      ENDIF                                                             
C                                                                       
C                                                                       
C     BERECHNE DIFFERENZ AUFEINENDERFOLGENDER X-WERTE UND               
C     UNTERSUCHE MONOTONIE                                              
C                                                                       
      DO 10 I = 1, N-1                                                  
         H(I) = X(I+1)- X(I)
         IF(H(I).LE.0.0D0) THEN                                           
            WRITE(*,*) 'MONOTONIEFEHLER IN SPLINE: X(I-1) >= X(I)'      
            CALL mexErrMsgTxt('FEHLER IN ROUTINE')                                                       
         ENDIF                                                          
   10 CONTINUE                                                          
C                                                                       
C     AUFSTELLEN DES GLEICHUNGSSYSTEMS                                  
C                                                                       
      DO 20 I = 1, N-2                                                  
      A(I) = 3.0D0 * ((Y(I+2)-Y(I+1)) / H(I+1) - (Y(I+1)-Y(I)) / H(I)) 
         B(I) = H(I)                                                    
         C(I) = H(I+1)                                                  
         D(I) = 2.0D0 * (H(I) + H(I+1))                                   
   20 CONTINUE                                                          
C                                                                       
C     BERUECKSICHTIGEN DER RANDBEDINGUNGEN                              
C                                                                       
C     NOT-A-KNOT                                                        
C                
      IF(TYP.EQ.0) THEN                                                 
         A(1)   = A(1) * H(2) / (H(1) + H(2))                           
         A(N-2) = A(N-2) * H(N-2) / (H(N-1) + H(N-2))                   
         D(1)   = D(1) - H(1)                                           
         D(N-2) = D(N-2) - H(N-1)                                       
         C(1)   = C(1) - H(1)                                           
         B(N-2) = B(N-2) - H(N-1)                                       
      ENDIF                                                             
C                                                                       
C     1. ABLEITUNG VORGEGEBEN                                           
C                                                                       
      IF(TYP.EQ.1) THEN                                                 
         A(1)   = A(1) - 1.5D0 * ((Y(2)-Y(1)) / H(1) - ALFA)              
         A(N-2) = A(N-2) - 1.5D0 * (BETA - (Y(N)-Y(N-1)) / H(N-1))        
         D(1)   = D(1) - 0.5D0 * H(1)                                     
         D(N-2) = D(N-2) - 0.5D0 * H(N-1)                                 
      ENDIF                                                             
C                                                                       
C     2. ABLEITUNG VORGEGEBEN                                           
C                                                                                                                             
      IF(TYP.EQ.2) THEN                                                 
         A(1)   = A(1) - 0.5D0 * ALFA * H(1)                              
         A(N-2) = A(N-2) - 0.5D0 * BETA * H(N-1)                          
      ENDIF  
C                                                                       
C     3. ABLEITUNG VORGEGEBEN                                           
C                                                                       
      IF(TYP.EQ.3 ) THEN                                                
         A(1)   = A(1) + 0.5D0 * ALFA * H(1) * H(1)                       
         A(N-2) = A(N-2) - 0.5D0 * BETA * H(N-1)* H(N-1)                  
         D(1)   = D(1) + H(1)                                           
         D(N-2) = D(N-2) + H(N-1)                                       
      ENDIF                                                             
C                                                                       
C     BERECHNUNG DER KOEFFIZIENTEN                                      
C            
      CALL SGTSL(N-2,B,D,C,A,IERR)                                      
      IF(IERR.NE.0) THEN                                                
         WRITE(*,21)                                                    
         CALL mexErrMsgTxt('ERROR IN SGTSL: MATRIX SINGULAR')                                                           
      ENDIF                                                             
C                                                                       
C     UEBERSCHREIBEN DES LOESUNGSVEKTORS                                
C     
      CALL DCOPY(N-2,A,1,C(2),1)
C                                                                       
C     IN ABHAENGIGKEIT VON DEN RANDBEDINGUNGEN WIRD DER 1. UND          
C     DER LETZTE WERT VON C KORRIGIERT                                  
C                                                                       
      IF(TYP.EQ.0) THEN                                                 
         C(1) = C(2) + H(1) * (C(2)-C(3)) / H(2)                        
         C(N) = C(N-1) + H(N-1) * (C(N-1)-C(N-2)) / H(N-2)              
      ENDIF                                                             
C                                                                       
      IF(TYP.EQ.1) THEN                                                 
      C(1) = 1.5D0*((Y(2)-Y(1)) / H(1) - ALFA) / H(1) - 0.5D0 * C(2)     
      C(N) = -1.5D0*((Y(N)-Y(N-1)) / H(N-1)-BETA) / H(N-1)-0.5D0*C(N-1)  
      ENDIF                                                             
C                                                                       
      IF(TYP.EQ.2) THEN                                                 
         C(1) = 0.5D0 * ALFA                                              
         C(N) = 0.5D0 * BETA                                              
      ENDIF                                                             
C                                                                       
      IF(TYP.EQ.3) THEN                                                 
         C(1) = C(2) - 0.5D0 * ALFA * H(1)                                
         C(N) = C(N-1) + 0.5D0 * BETA * H(N-1)                            
      ENDIF                                                             
C                                                                       
      CALL DCOPY(N,Y,1,A,1)                                             
C                                                                       
      DO 30 I = 1, N-1                                                  
         B(I) = (A(I+1)-A(I))/H(I) - H(I) * (C(I+1)+2.0D0 * C(I))/3.0D0 
         D(I) = (C(I+1)-C(I))/(3.0D0 * H(I))                            
   30 CONTINUE                                                          
C                                                                       
      B(N) = (3.0D0 * D(N-1) * H(N-1) + 2.0D0 * C(N-1)) * H(N-1) 
     >         + B(N-1)   
C                                                                       
      RETURN                                                            
C                                                                       
   21 FORMAT(1X,'ERROR IN SGTSL: MATRIX SINGULAR')                      
      END                                                               
                                                                        
************************************************************************
      real*8 FUNCTION SPWERT(N,XWERT,A,B,C,D,X,ABLTG)                     
C-----------------------------------------------------------------------
C     INPUT:                                                            
C                                                                       
C     N           ANZAHL DER KNOTENPUNKTE                               
C     XWERT       STELLE AN DER FUNKTIONSWERTE BERECHNET WERDEN         
C     A, B, C, D  ARRAYS DER SPLINEKOEFFIZIENTEN (AUS SPLINE)           
C     X           ARRAY DER KNOTENPUNKTE                                
C                                                                       
C     OUTPUT:                                                           
C                                                                       
C     SPWERT   FUNKTIONSWERT AN DER STELLE XWERT                        
C     ABLTG(I) WERT DER I-TEN ABLEITUNG BEI XWERT                       
C-----------------------------------------------------------------------
C     
      IMPLICIT REAL*8 (A-H,O-Z)
      integer  N                                                        
      real*8     XWERT, A(N), B(N), C(N), D(N), X(N), ABLTG(3)            
      integer  I, K, M                                                  
C                                                                       
C     SUCHE PASSENDES INTERVALL (BINAERE SUCHE)                         
C                                                                       
      I = 1                                                             
      K = N                                                             
C                                                                       
   10 M = (I+K) / 2                                                     
C     
      IF(M.NE.I) THEN                                                   
         IF(XWERT.LT.X(M)) THEN                                         
            K = M                                                       
         ELSE                                                           
            I = M                                                       
         ENDIF                                                          
         GOTO 10                                                        
      ENDIF                                                             
C                                                                       
      XX = XWERT - X(I)                                                 
C                                                                       
      ABLTG(1) = (3.0D0 * D(I) * XX + 2.0D0 * C(I)) * XX + B(I)             
      ABLTG(2) = 6.0D0 * D(I) * XX + 2.0D0 * C(I)                           
      ABLTG(3) = 6.0D0 * D(I)                                             
C                                                                       
      SPWERT = ((D(I)*XX + C(I))*XX + B(I))*XX + A(I)                   
C                                                                       
      RETURN                                                            
      END                                                               
                                                                        
************************************************************************
*** FROM NETLIB, TUE AUG 28 08:28:34 EDT 1990 ***                       
C                                                                       
      SUBROUTINE SGTSL(N,C,D,E,B,INFO)                                  
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      integer N,INFO                                                    
      real*8 C(1),D(1),E(1),B(1)                                          
C                                                                       
C     SGTSL GIVEN A GENERAL TRIDIAGONAL MATRIX AND A RIGHT HAND         
C     SIDE WILL FIND THE SOLUTION.                                      
C                                                                       
C     ON ENTRY                                                          
C                                                                       
C        N       integer                                                
C                IS THE ORDER OF THE TRIDIAGONAL MATRIX.                
C                                                                       
C        C       dble(N)                                                
C                IS THE SUBDIAGONAL OF THE TRIDIAGONAL MATRIX.          
C                C(2) THROUGH C(N) SHOULD CONTAIN THE SUBDIAGONAL.      
C                ON OUTPUT C IS DESTROYED.                              
C                                                                       
C        D       dble(N)                                                
C                IS THE DIAGONAL OF THE TRIDIAGONAL MATRIX.             
C                ON OUTPUT D IS DESTROYED.                              
C                                                                       
C        E       dble(N)                                                
C                IS THE SUPERDIAGONAL OF THE TRIDIAGONAL MATRIX.        
C                E(1) THROUGH E(N-1) SHOULD CONTAIN THE SUPERDIAGONAL.  
C                ON OUTPUT E IS DESTROYED.                              
C                                                                       
C        B       dble(N)                                                
C                IS THE RIGHT HAND SIDE VECTOR.                         
C                                                                       
C     ON RETURN                                                         
C                                                                       
C        B       IS THE SOLUTION VECTOR.                                
C                                                                       
C        INFO    integer                                                
C                = 0 NORMAL VALUE.                                      
C                = K IF THE K-TH ELEMENT OF THE DIAGONAL BECOMES        
C                    EXACTLY ZERO.  THE SUBROUTINE RETURNS WHEN         
C                    THIS IS DETECTED.                                  
C                                                                       
C     LINPACK. THIS VERSION DATED 08/14/78 .                            
C     JACK DONGARRA, ARGONNE NATIONAL LABORATORY.                       
C                                                                       
C     NO EXTERNALS                                                      
C     FORTRAN ABS                                                       
C                                                                       
C     INTERNAL VARIABLES                                                
C                                                                       
      integer K,KB,KP1,NM1,NM2                                          
      real*8 T                                                            
C     BEGIN BLOCK PERMITTING ...EXITS TO 100                            
C                                                                       
         INFO = 0                                                       
         C(1) = D(1)                                                    
         NM1 = N - 1                                                    
         IF (NM1 .LT. 1) GO TO 40                                       
            D(1) = E(1)                                                 
            E(1) = 0.0D0                                                
            E(N) = 0.0D0                                                
C                                                                       
            DO 30 K = 1, NM1                                            
               KP1 = K + 1                                              
C                                                                       
C              FIND THE LARGEST OF THE TWO ROWS                         
C                                                                       
               IF (DABS(C(KP1)) .LT. DABS(C(K))) GO TO 10                 
C                                                                       
C                 INTERCHANGE ROW                                       
C                                                                       
                  T = C(KP1)                                            
                  C(KP1) = C(K)                                         
                  C(K) = T                                              
                  T = D(KP1)                                            
                  D(KP1) = D(K)                                         
                  D(K) = T                                              
                  T = E(KP1)                                            
                  E(KP1) = E(K)                                         
                  E(K) = T                                              
                  T = B(KP1)                                            
                  B(KP1) = B(K)                                         
                  B(K) = T                                              
   10          CONTINUE                                                 
C                                                                       
C              ZERO ELEMENTS                                            
C                                                                       
               IF (C(K) .NE. 0.0D0) GO TO 20                            
                  INFO = K                                              
C     ............EXIT                                                  
                  GO TO 100                                             
   20          CONTINUE                                                 
               T = -C(KP1)/C(K)                                         
               C(KP1) = D(KP1) + T*D(K)                                 
               D(KP1) = E(KP1) + T*E(K)                                 
               E(KP1) = 0.0D0                                           
               B(KP1) = B(KP1) + T*B(K)                                 
   30       CONTINUE                                                    
   40    CONTINUE                                                       
         IF (C(N) .NE. 0.0D0) GO TO 50                                  
            INFO = N                                                    
         GO TO 90                                                       
   50    CONTINUE                                                       
C                                                                       
C           BACK SOLVE                                                  
C                                                                       
            NM2 = N - 2                                                 
            B(N) = B(N)/C(N)                                            
            IF (N .EQ. 1) GO TO 80                                      
               B(NM1) = (B(NM1) - D(NM1)*B(N))/C(NM1)                   
               IF (NM2 .LT. 1) GO TO 70                                 
               DO 60 KB = 1, NM2                                        
                  K = NM2 - KB + 1                                      
                  B(K) = (B(K) - D(K)*B(K+1) - E(K)*B(K+2))/C(K)        
   60          CONTINUE                                                 
   70          CONTINUE                                                 
   80       CONTINUE                                                    
   90    CONTINUE                                                       
  100 CONTINUE                                                          
C                                                                       
      RETURN                                                            
      END      
      
                              
************************************************************************
*DECK HELBAL
      SUBROUTINE HELBAL(ZVOL,ZVOLP,XAXIS,BALCRIT)

      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
C-----------------------------------------------------------------------
C PROGRAM TO DETERMINE THE BALLOONING STABILITY OF HELENA EQUILIBRIA
C         - READS THE MAPPING FILE AS USED BY CASTOR
C         - CALCULATES STABILITY INDEX USING SUYDAM METHOD
C         - FOR SYMMETRIC AND ASYMMETRIC PLASMA BOUNDARY SHAPES
C
C         VERSION : 1                 DATE : 28-09-95
C-----------------------------------------------------------------------
C STATUS : 
C
C 28/9/95   - tested for symmetric soloviev equilibrium with E=1.41
C             eps=0.382, compares well with Turnbull results.
C           - also tested for sym. soloviev asymmetric helena
C
C-----------------------------------------------------------------------
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
      PARAMETER (NPSIMAX=NRMMAX, NCHIMAX=1026)                             
      PARAMETER (NPNC=NPSIMAX*NCHIMAX, NP4=4*NPSIMAX)                   
c      USE COMPIO ?
C-----------------------------------------------------------------------
      COMMON / COMDAT/                                                  
     >        ELLIP,TRIAH,TRIAB,QUAD,PAR1,PAR2,PAR3,PAR4,                      
     >        AGA,BGA,CGA,DGA,EGA,FGA,GGA,HGA,                          
     >        API,BPI,CPI,DPI,EPI,FPI,GPI,HPI,                          
     >        ACUR,BCUR,CCUR,DCUR,ECUR,FCUR,GCUR,HCUR,                  
     >        ERRIT,ERRCUR,EPS,ALFA,B,C,XIAB,Q95,BETAP,AMIX,BMIX,       
     >        ABB, BBB, AMPL, RVAC,BVAC,ZEFF,ZN0,RPE,XR1,SIG1,          
     >        IAS,ICUR,NRCUR,NPCUR,NMESH,INIMESH,NBB,NQB,IARC,          
     >        MHARM,ISHAPE,ISOL,IGAM,IPAI,NR,NP,NRMAP,NPMAP,NITER       
      real*8    ELLIP,TRIAH,TRIAB,QUAD,PAR1,PAR2,PAR3,PAR4,                      
     >        AGA,BGA,CGA,DGA,EGA,FGA,GGA,HGA,                          
     >        API,BPI,CPI,DPI,EPI,FPI,GPI,HPI,                          
     >        ACUR,BCUR,CCUR,DCUR,ECUR,FCUR,GCUR,HCUR,                  
     >        ERRIT,ERRCUR,EPS,ALFA,B,C,XIAB,Q95,BETAP,AMIX,BMIX,       
     >        ABB, BBB, AMPL, RVAC,BVAC,ZEFF,ZN0,RPE,XR1,SIG1           
      integer IAS,ICUR,NRCUR,NPCUR,NMESH,INIMESH,NBB,NQB,IARC,          
     >        MHARM,ISHAPE,ISOL,IGAM,IPAI,NR,NP,NRMAP,NPMAP,NITER       
c------------------------------------------------------------------
      COMMON /COMMAP/CS,QS,DQS,CURJ,CHI,   
     >     GEM11,GEM12,GEM33,  
     >     CHIKN,P0,RBPHI,
     >     DP,DRBPHI,
     >     DQEC,DJ0,DJE,CPSURF,RADIUS,RAXIS,DP0,DPE,DRBPHI0,DRBPHIE,
     >     JS0,NCHI,NPSI,NLTORE

      REAL*8 CS(NRMMAX),QS(NRMMAX),DQS(NRMMAX),CURJ(NRMMAX),CHI(NPMMAX),   
     >     GEM11(MAXMNODE),GEM12(MAXMNODE),GEM33(MAXMNODE),  
     >     CHIKN(NPMMAX),P0(NRMMAX),RBPHI(NRMMAX),
     >     DP(NRMMAX),DRBPHI(NRMMAX),
     >     DQEC,DJ0,DJE,CPSURF,RADIUS,RAXIS,DP0,DPE,DRBPHI0,DRBPHIE   
      INTEGER JS0,NCHI,NPSI
      LOGICAL NLTORE  
C-----------------------------------------------------------------------
      COMMON / COMSPL /                                                 
     R         Q1(NPSIMAX), Q2(NPSIMAX), Q3(NPSIMAX), Q4(NPSIMAX),      
     R         P1(NPSIMAX), P2(NPSIMAX), P3(NPSIMAX), P4(NPSIMAX),      
     R         RBP1(NPSIMAX), RBP2(NPSIMAX), RBP3(NPSIMAX),             
     R         RBP4(NPSIMAX)                                            
                                                                      
      REAL*8     Q1, Q2, Q3, Q4,                          
     >         P1, P2, P3, P4, RBP1, RBP2, RBP3, RBP4                   
C-----------------------------------------------------------------------
      common / COMB02 / B02,DTB02 , DSB02
      REAL*8    B02(NPNC), DTB02(NPNC), DSB02(NPNC)
C-----------------------------------------------------------------------
      common / COMPQ / CP0, CP1, CP2, CQ0, CQ1, NCPQ
      REAL*8    CP0(NPNC),CP1(NPNC),CP2(NPNC),CQ0(NPNC),CQ1(NPNC)
      INTEGER NCPQ
C-----------------------------------------------------------------------
      common / COMNAM / QAXIS,TBB,TBF
      REAL*8     QAXIS,TBB,TBF
C-----------------------------------------------------------------------




      REAL*8 ZVOL(*),ZVOLP(*),XAXIS,BALCRIT(*)
      CHARACTER*25 BAL,INIBAL

      PI = 2.*ASIN(1.)
      CALL INIT(IAS)
C---------------------- READ HELENA MAPPING FILE -----------------------      
      CALL IODSK
C---------------------- CALCULATE B-FIELD ON GRID POINTS ---------------     
      CALL BFIELD(IAS)
C---------------------- CALCULATE P AND Q COEFF. ON ALL GRIDPOINTS -----      
      CALL PQ(IAS)
C---------------------- CALCULATE STABILITY INDEX ----------------------     
c      WRITE(20,*)
c      WRITE(20,*) '****************************************************'
c     >            //'***************************'
c      WRITE(20,*) '* I, FLUX,  RHO,   Q,    SHEAR,   SHEAR1, ALPHA,'//
c     >              '  ALPHA1,  FMARG,  BALLOONING *'
c      WRITE(20,*) '****************************************************'
c     >            //'***************************'
      DO 10 IPSI=2,NPSI
         FACT = 1.
         CALL SUYDAM(IPSI,0.,TBB,TBF,NCPQ,1.,BAL)
C---------------------- FIND DISTANCE FROM STABILITY BOUNDARY ----------         
         INIBAL = BAL
         IF (BAL.EQ.' STABLE') THEN
            DELF = 2.
         ELSE
            DELF = 0.5
         ENDIF      
         FACT = DELF * FACT
         DO 20 NIT=1,10
           CALL SUYDAM(IPSI,0.,TBB,TBF,NCPQ,FACT,BAL)
           IF (BAL.EQ.INIBAL) THEN
              FACT = DELF * FACT
           ELSE
              GOTO 30
           ENDIF  
   20   CONTINUE
C--------------------- UPPER AND LOWER LIMII ESTABLISHED --------------    
   30   CONTINUE
        IF (INIBAL.EQ.' STABLE') THEN
          FUNST = FACT
          FSTAB = FACT / 2.
        ELSE
          FSTAB = FACT
          FUNST = FACT * 2.
        ENDIF   
c------------------------------------- BISECTION TO FIND FACTOR
        DO 40 NIT = 1, 10 
           FACT = (FUNST + FSTAB)/2.
           CALL SUYDAM(IPSI,0.,TBB,TBF,NCPQ,FACT,BAL)
           IF (BAL.EQ.' STABLE') THEN
             FSTAB = FACT
           ELSE
             FUNST = FACT
           ENDIF               
   40   CONTINUE      
        SHEAR = CS(IPSI)/QS(IPSI) * DQS(IPSI) 
        ALPHA = - 2.*QS(IPSI)**2 * P2(IPSI)/EPS

	SHEAR1 = 2.*ZVOL(IPSI)/QS(IPSI) * DQS(IPSI)
     >         / (2.*CS(IPSI)*ZVOLP(IPSI))
c-------------------------------------------- Lao's definition
c        ALPHA1 = -P2(IPSI)/(2.*CS(IPSI)) * ZVOLP(IPSI) / CPSURF**2
c     >         * SQRT(ZVOL(IPSI)/(4.*PI*(1.+EPS*XAXIS))) * EPS**3
c
c--------------------------------------------- use rho as radius
        RHO = SQRT(ZVOL(IPSI)/ZVOL(NR))
        DRHODS =  CS(IPSI)/ (RHO*ZVOL(NR)) * ZVOLP(IPSI)  
	ALPHA2 = ALPHA / DRHODS

c----------------------------------------- Lao corrected? Needs check
c        ALPHA11 = -P2(IPSI)/(2.*CS(IPSI)) * ZVOLP(IPSI) / CPSURF**2
c     >          / (PI*PI*EPS) * RHO * ZVOL(NR) *EPS**4
c----------------------------------------------------------------------
	
	FMARG = (FSTAB+FUNST)/2.
C----------------------------------- temporary fix for negative shear and IAS=1
        IF ((SHEAR.LE.0.).AND.(IAS.EQ.1)) THEN   
	  FMARG = 0.
	  INIBAL =  ' STABLE'
        ENDIF
        BALCRIT(IPSI) = FMARG
c        WRITE(20,11) IPSI,CS(IPSI)**2,RHO,QS(IPSI),SHEAR,SHEAR1,
c     >               ALPHA,ALPHA2,FMARG, INIBAL
   10 CONTINUE
c      WRITE(20,*) '****************************************************'
c     >            //'*****************'
c   11 FORMAT(' ',I3,' ',F6.3,' ',F6.3,' ',F6.3,' ',F7.4,' ',F7.4,' ',
c     >       F7.4,' ',F7.4,' ',F8.3,'  ',A25)

      END

************************************************************************
*DECK INIT
      SUBROUTINE INIT(IAS)
C-----------------------------------------------------------------------
C SUBROUTINE TO INITIALIZE THE INPUT VARIABLES, ALSO WRITES THE HEADER
C OF THE OUTPUT FILE
C-----------------------------------------------------------------------
C-----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      common / COMNAM / QAXIS,TBB,TBF
      REAL*8     QAXIS,TBB,TBF
C-----------------------------------------------------------------------

      TBB = -100.
      IF (IAS.EQ.0) TBB = 0.
      TBF =  100.
      RETURN
      END      
************************************************************************
*DECK PQ
      SUBROUTINE PQ(IAS)
C-----------------------------------------------------------------------
C SUBROUTINE TO CALCULATE THE P AND Q COEFFICENTS IN THE BALLOONING
C EQUATION IN ALL GRID POINTS.
C THE TERMS DEPENDING ON THE EXTENDED BALLOONING ANGLE ARE SEPERATED.
C THE BALLOONING EQUATION (POGUSTE AND YURCHENKO) READS:
C       DT((P0 + T * P1 + T^2 P2) DT(F)) - (Q0 + T * Q1) F = 0 
C
C NOTE : THE FINAL ARRAYS CP AND CQ HAVE A DIFFERENT INDEX FROM THE
C GEMIJ ARRAYS. THE J INDEX RUNS FROM 0 TO 2PI (INCLUDING 2PI), THE
C NUMBER OF POINTS IN POLOIDAL DIRECTION IS NCHI+1 FOR IAS=1 AND 
C 2*NCHI-1 FOR IAS=0.
C-----------------------------------------------------------------------      
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
      PARAMETER (NPSIMAX=NRMMAX, NCHIMAX=1026)                             
      PARAMETER (NPNC=NPSIMAX*NCHIMAX, NP4=4*NPSIMAX)                   
c      USE COMMAX ?
c      USE COMPIO ?
c------------------------------------------------------------------
      COMMON /COMMAP/CS,QS,DQS,CURJ,CHI,   
     >     GEM11,GEM12,GEM33,  
     >     CHIKN,P0,RBPHI,
     >     DP,DRBPHI,
     >     DQEC,DJ0,DJE,CPSURF,RADIUS,RAXIS,DP0,DPE,DRBPHI0,DRBPHIE,
     >     JS0,NCHI,NPSI,NLTORE

      REAL*8 CS(NRMMAX),QS(NRMMAX),DQS(NRMMAX),CURJ(NRMMAX),CHI(NPMMAX),   
     >     GEM11(MAXMNODE),GEM12(MAXMNODE),GEM33(MAXMNODE),  
     >     CHIKN(NPMMAX),P0(NRMMAX),RBPHI(NRMMAX),
     >     DP(NRMMAX),DRBPHI(NRMMAX),
     >     DQEC,DJ0,DJE,CPSURF,RADIUS,RAXIS,DP0,DPE,DRBPHI0,DRBPHIE   
      INTEGER JS0,NCHI,NPSI
      LOGICAL NLTORE  
C-----------------------------------------------------------------------
      COMMON / COMSPL /                                                 
     R         Q1(NPSIMAX), Q2(NPSIMAX), Q3(NPSIMAX), Q4(NPSIMAX),      
     R         P1(NPSIMAX), P2(NPSIMAX), P3(NPSIMAX), P4(NPSIMAX),      
     R         RBP1(NPSIMAX), RBP2(NPSIMAX), RBP3(NPSIMAX),             
     R         RBP4(NPSIMAX)                                            
C                                                                       
      REAL*8     Q1, Q2, Q3, Q4,                          
     >         P1, P2, P3, P4, RBP1, RBP2, RBP3, RBP4                   
C-----------------------------------------------------------------------
      common / COMB02 / B02,DTB02 , DSB02
      REAL*8    B02(NPNC), DTB02(NPNC), DSB02(NPNC)
C-----------------------------------------------------------------------
      common / COMPQ / CP0, CP1, CP2, CQ0, CQ1, NCPQ
      REAL*8    CP0(NPNC),CP1(NPNC),CP2(NPNC),CQ0(NPNC),CQ1(NPNC)
      INTEGER NCPQ
C-----------------------------------------------------------------------
C-----------------------------------------------------------------------
      common / COMNAM / QAXIS,TBB,TBF
      REAL*8     QAXIS,TBB,TBF
C-----------------------------------------------------------------------

      NCPQ = 2*NCHI-1
      IF (IAS.EQ.1) NCPQ = NCHI+1
      DO 10 I=2,NPSI
        SPS2 = 2.*CPSURF*CS(I)
        ZQ = QS(I)
        ZT = RBPHI(I)
        ZDP = P2(I)
        ZDQ = DQS(I)
        DO 20 J=1,NCHI
          IJ = (I-1)*NCHI + J
          IF (IAS.EQ.0) THEN
            IJ1 = (I-1)*(2*NCHI-1) + J
          ELSE  
            IJ1 = (I-1)*(NCHI+1) + J
          ENDIF  
C----------------------------------- LOWER INDEX GEOMETRIC COEFF. -------     
c          G33 = GEM33(IJ)
c          G11 = SPS2**2 *(1. + ZQ**2/ZT**2 
c     >                       * GEM33(IJ) * GEM12(IJ)**2 ) / GEM11(IJ)  
c          G12 = - SPS2 * ZQ**2 / ZT**2 * GEM12(IJ) * GEM33(IJ)
c          G22 = ZQ**2 / ZT**2 * GEM11(IJ) * GEM33(IJ)
c          ZJ  = SPS2 * ZQ * GEM33(IJ) / ZT
C----------------------------------------------------------------------- 
          BETA =  - GEM12(IJ)/GEM11(IJ) 
          CP0(IJ1) = 1. / (GEM33(IJ)*GEM11(IJ))
     >             + ZQ**2 * GEM11(IJ) *BETA**2 /(GEM33(IJ)*B02(IJ))
          CP1(IJ1) = 2.*BETA * GEM11(IJ) * (ZDQ*ZQ)
     >                               /(SPS2*GEM33(IJ)*B02(IJ))
          CP2(IJ1) = GEM11(IJ) * ZDQ**2
     >                               /(SPS2**2 *GEM33(IJ)*B02(IJ))
          CQ0(IJ1) = -ZDP* ZQ**2 * GEM33(IJ) / (SPS2*ZT*B02(IJ))**2
     >             *( (2.*ZDP+DSB02(IJ))*B02(IJ) + 
     >                SPS2*BETA*GEM11(IJ)/GEM33(IJ) * DTB02(IJ))     
          CQ1(IJ1) = ZDP*ZDQ*ZQ /(SPS2 * B02(IJ))**2 * DTB02(IJ)   
C----------------------------------------------------------------------- 
          IF (IAS.EQ.0) THEN
             IJ2 = I*(2*NCHI-1) - J + 1 
             CP0(IJ2) = CP0(IJ1)
             CP1(IJ2) =-CP1(IJ1)
             CP2(IJ2) = CP2(IJ1)
             CQ0(IJ2) = CQ0(IJ1)
             CQ1(IJ2) =-CQ1(IJ1)
          ELSEIF ((IAS.EQ.1).AND.(J.EQ.1)) THEN
             IJ2 = I*(NCHI+1)
             CP0(IJ2) = CP0(IJ1)
             CP1(IJ2) = CP1(IJ1)
             CP2(IJ2) = CP2(IJ1)
             CQ0(IJ2) = CQ0(IJ1)
             CQ1(IJ2) = CQ1(IJ1)
          ENDIF    
   20   CONTINUE         
   10 CONTINUE
      RETURN
      END

************************************************************************
*DECK BFIELD      
      SUBROUTINE BFIELD(IAS)
C-----------------------------------------------------------------------
C SUBROUTINE TO CALCULATE :
C      - THE TOTAL MAGNETIC FIELD SQUARED
C      - THE RADIAL AND POLOIDAL DERIVATIVE OF THE TOTAL FIELD SQUARED
C    ON THE GRID POINTS OF THE STRAIGHT FIELD LINE COORDINATE SYSTEM. 
C-----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
      PARAMETER (NPSIMAX=NRMMAX, NCHIMAX=1026)                             
      PARAMETER (NPNC=NPSIMAX*NCHIMAX, NP4=4*NPSIMAX)                   
c      USE COMMAX ?
c      USE COMPIO ?
c------------------------------------------------------------------
      COMMON /COMMAP/CS,QS,DQS,CURJ,CHI,   
     >     GEM11,GEM12,GEM33,  
     >     CHIKN,P0,RBPHI,
     >     DP,DRBPHI,
     >     DQEC,DJ0,DJE,CPSURF,RADIUS,RAXIS,DP0,DPE,DRBPHI0,DRBPHIE,
     >     JS0,NCHI,NPSI,NLTORE

      REAL*8 CS(NRMMAX),QS(NRMMAX),DQS(NRMMAX),CURJ(NRMMAX),CHI(NPMMAX),   
     >     GEM11(MAXMNODE),GEM12(MAXMNODE),GEM33(MAXMNODE),  
     >     CHIKN(NPMMAX),P0(NRMMAX),RBPHI(NRMMAX),
     >     DP(NRMMAX),DRBPHI(NRMMAX),
     >     DQEC,DJ0,DJE,CPSURF,RADIUS,RAXIS,DP0,DPE,DRBPHI0,DRBPHIE   
      INTEGER JS0,NCHI,NPSI
      LOGICAL NLTORE  
C-----------------------------------------------------------------------
      COMMON / COMSPL /                                                 
     R         Q1(NPSIMAX), Q2(NPSIMAX), Q3(NPSIMAX), Q4(NPSIMAX),      
     R         P1(NPSIMAX), P2(NPSIMAX), P3(NPSIMAX), P4(NPSIMAX),      
     R         RBP1(NPSIMAX), RBP2(NPSIMAX), RBP3(NPSIMAX),             
     R         RBP4(NPSIMAX)                                            
C                                                                       
      REAL*8     Q1, Q2, Q3, Q4,                          
     >         P1, P2, P3, P4, RBP1, RBP2, RBP3, RBP4                   
C-----------------------------------------------------------------------
      common / COMB02 / B02,DTB02 , DSB02
      REAL*8    B02(NPNC), DTB02(NPNC), DSB02(NPNC)
C-----------------------------------------------------------------------
      common / COMNAM / QAXIS,TBB,TBF
      REAL*8     QAXIS,TBB,TBF
C-----------------------------------------------------------------------
      REAL*8 SP(NPSIMAX),S1(NPSIMAX),S2(NPSIMAX),S3(NPSIMAX),S4(NPSIMAX)
C---------------------------------------- B0 ON GRID POINTS -----------
      DO 10 I=1,NPSI
        DO 20 J=1,NCHI
           IJ = (I-1)*NCHI + J
           B02(IJ) = (GEM11(IJ) + RBPHI(I)**2)/GEM33(IJ)
   20   CONTINUE
   10 CONTINUE
C---------------------------------------- D(B02)/D(THETA) -------------
      DO 30 I=1,NPSI
        IJSTART = (I-1)*NCHI + 1
        CALL DERIV(B02(IJSTART),DTB02(IJSTART),NCHI,IAS)     
   30 CONTINUE
C---------------------------------------- D(B02)/DS --------------------
      DO 40 J=1,NCHI
        DO 50 I=1,NPSI
          IJ = (I-1)*NCHI + J
          SP(I) = B02(IJ)
   50   CONTINUE
        CALL SPLINE(NPSI,CS,SP,0.0,0.0,2,S1,S2,S3,S4)
        DO 60 I=1,NPSI
          IJ = (I-1)*NCHI + J
          DSB02(IJ) = S2(I)
   60   CONTINUE 
   40 CONTINUE
      RETURN
      END       
************************************************************************
*DECK IODSK
      SUBROUTINE IODSK
C-----------------------------------------------------------------------
C    - READS HELENA MAPPING FILE
C    - SCALES QUANTITIES WITH Q ON AXIS
C-----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
      PARAMETER (NPSIMAX=NRMMAX, NCHIMAX=1026)                             
      PARAMETER (NPNC=NPSIMAX*NCHIMAX, NP4=4*NPSIMAX)                   
c      USE COMPIO ?
c------------------------------------------------------------------
      COMMON /COMMAP/CS,QS,DQS,CURJ,CHI,   
     >     GEM11,GEM12,GEM33,  
     >     CHIKN,P0,RBPHI,
     >     DP,DRBPHI,
     >     DQEC,DJ0,DJE,CPSURF,RADIUS,RAXIS,DP0,DPE,DRBPHI0,DRBPHIE,
     >     JS0,NCHI,NPSI,NLTORE

      REAL*8 CS(NRMMAX),QS(NRMMAX),DQS(NRMMAX),CURJ(NRMMAX),CHI(NPMMAX),   
     >     GEM11(MAXMNODE),GEM12(MAXMNODE),GEM33(MAXMNODE),  
     >     CHIKN(NPMMAX),P0(NRMMAX),RBPHI(NRMMAX),
     >     DP(NRMMAX),DRBPHI(NRMMAX),
     >     DQEC,DJ0,DJE,CPSURF,RADIUS,RAXIS,DP0,DPE,DRBPHI0,DRBPHIE   
      INTEGER JS0,NCHI,NPSI
      LOGICAL NLTORE  
C-----------------------------------------------------------------------
      COMMON / COMSPL /                                                 
     R         Q1(NPSIMAX), Q2(NPSIMAX), Q3(NPSIMAX), Q4(NPSIMAX),      
     R         P1(NPSIMAX), P2(NPSIMAX), P3(NPSIMAX), P4(NPSIMAX),      
     R         RBP1(NPSIMAX), RBP2(NPSIMAX), RBP3(NPSIMAX),             
     R         RBP4(NPSIMAX)                                            
C                                                                       
      REAL*8     Q1, Q2, Q3, Q4,                          
     >         P1, P2, P3, P4, RBP1, RBP2, RBP3, RBP4                   
C-----------------------------------------------------------------------
      common / COMNAM / QAXIS,TBB,TBF
      REAL*8     QAXIS,TBB,TBF
C-----------------------------------------------------------------------
      REAL*8 dummy(3)

      NPSI = JS0 + 1
      NG = NPSI*NCHI

      DO 30 JC=1,NCHI
        GEM11(JC) = 0.
        GEM33(JC) = RAXIS**2
   30 CONTINUE
C
      DO 40 JC=1,NCHI
         CALL DCOPY(NPSI-1,GEM12(NCHI+JC),NCHI,C1,1)
         CALL SPLINE(NPSI-1,CS(2),C1,0.0,0.0,2,Q1,Q2,Q3,Q4)
         GEM12(JC) = SPWERT(NPSI-1,0.0,Q1,Q2,Q3,Q4,CS(2),DUMMY)
   40 CONTINUE

C------------------------------------------------------------------
C     SCALE QUANTITIES WITH VALUE OF Q ON AXIS (TOTAL CURRENT)
C------------------------------------------------------------------
      SCALEQ = QS(1)/QAXIS
C
      CPSURF = CPSURF*SCALEQ
      CALL DSCAL(NPSI,SCALEQ**2,P0,1)
      CALL DSCAL(NPSI*NCHI,-SCALEQ,GEM12,1)
      CALL DSCAL(NPSI*NCHI,SCALEQ**2,GEM11,1)
C
      RBPHI02 = RBPHI(1)**2
C
      DP0     = DP0*SCALEQ**2
      DPE     = DPE*SCALEQ**2
      DRBPHI0 = DRBPHI0*SCALEQ**2
      DRBPHIE = DRBPHIE*SCALEQ/SQRT(1.+RBPHI02/RBPHI(NPSI)**2*
     >          (1./SCALEQ**2-1.))
C
      DO 50 J=1,NPSI
         WURZEL   = SQRT(1.+RBPHI02/RBPHI(J)**2*(1./SCALEQ**2-1.))
         QS(J)    = WURZEL * QS(J)
         RBPHI(J) = WURZEL * SCALEQ * RBPHI(J)
   50 CONTINUE
C
      WRITE(20,*)  NPSI,NCHI
      WRITE(20,51) SCALEQ
      WRITE(20,52) CPSURF
      WRITE(20,53) (QS(JJ),JJ=1,JS0+1)
      WRITE(20,54) (P0(JJ),JJ=1,NPSI)
      WRITE(20,55) (RBPHI(JJ),JJ=1,NPSI)
C
C     SPLINES
C
      DQ1 = (QS(NPSI)-QS(NPSI-1))/(CS(NPSI)-CS(NPSI-1))
      DQ0 = (QS(2)-QS(1))/(CS(2)-CS(1))
      
      CALL SPLINE(NPSI,CS,QS,DQ0,DQ1,1,Q1,Q2,Q3,Q4)
      CALL SPLINE(NPSI,CS,P0,DP0,DPE,1,P1,P2,P3,P4)
      CALL SPLINE(NPSI,CS,RBPHI,DRBPHI0,DRBPHIE,1,RBP1,RBP2,RBP3,RBP4)
C
      CALL DCOPY(NPSI,Q2,1,DQS,1)
      RETURN
C
   51 FORMAT(/' AFTER SCALE: SCALEQ=',1P,E12.4,0P)
   52 FORMAT(/' CPSURF = ',1P,E12.4,0P)
   53 FORMAT(/' QS'/(1X,1P,5E16.8,0P))
   54 FORMAT(/' P0'/(1X,1P,5E16.8,0P))
   55 FORMAT(/' RBPHI'/(1X,1P,5E16.8,0P))
      END

************************************************************************
*DECK KGS
      SUBROUTINE KGS(T,T0,CP,CQ,IPSI)
C-----------------------------------------------------------------------
C SUBROUTINE TO EVALUATE THE P AND Q COEFFICIENT, USED IN THE SUYDAM
C ROUTINE. 
C NOTE : THE ROUTINE ASUMES THAT ONLY VALUES ON GRID POINTS ARE
C REQUESTED. NO INTERPOLATION IS DONE!
C-----------------------------------------------------------------------      
c      USE COMMAX ?
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
c parametres MISHKA		              
      PARAMETER (NCHIMAX=1026)                                                       
      PARAMETER (NVPSIMX=101, NVCHIMX=1026)                             
      PARAMETER (NPSIMAX=NRMMAX)                             
      PARAMETER (NPNC=NPSIMAX*NCHIMAX, NP4=4*NPSIMAX)                   
c-----------------------------------------------------------------------
      common / COMPQ / CP0, CP1, CP2, CQ0, CQ1, NCPQ
      REAL*8    CP0(NPNC),CP1(NPNC),CP2(NPNC),CQ0(NPNC),CQ1(NPNC)
      INTEGER NCPQ
C-----------------------------------------------------------------------


      TWOPI = 4.*ASIN(1.)
      DT = TWOPI/REAL(NCPQ-1)
      TM = MOD(MOD(T,TWOPI)+TWOPI, TWOPI)
C-------------------------- NCPQ=2*NCHI-1 (IAS=0) OR NCPQ=NCHI+1 (IAS=1)      
      JM = INT((NCPQ-1) * TM/TWOPI) + 1
      IJM = (IPSI-1)*NCPQ + JM
      FRAC = (TM - REAL(JM-1)*DT)/DT
      CP0D = CP0(IJM) + (CP0(IJM+1)-CP0(IJM))*FRAC
      CP1D = CP1(IJM) + (CP1(IJM+1)-CP1(IJM))*FRAC
      CP2D = CP2(IJM) + (CP2(IJM+1)-CP2(IJM))*FRAC
      CQ0D = CQ0(IJM) + (CQ0(IJM+1)-CQ0(IJM))*FRAC 
      CQ1D = CQ1(IJM) + (CQ1(IJM+1)-CQ1(IJM))*FRAC           
      CP = CP0D + CP1D*(T-T0) + CP2D*(T-T0)**2 
      CQ = CQ0D + CQ1D*(T-T0)
      RETURN
      END

************************************************************************
*DECK SUYDAM
      SUBROUTINE SUYDAM(IPSI,T0,TBB,TBF,NCPQ,FACT,BAL)
C-----------------------------------------------------------------------
C  SUBROUTINE TO VERIFY THE SIGN OF THE BALLOONING ENERGY        
C  FUNCTIONAL ACCORDING TO THE SUYDAM FINITE DIFFERENCE SCHEME.  
C-----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      REAL*8 KP1,KP2
      CHARACTER*25 BAL
      
      PI  = 2*ASIN(1.)
      BAL = ' STABLE'
      DBT = 4.*ASIN(1.)/REAL(NCPQ-1)

      N  = INT((TBF - TBB) / DBT)
      ALP= 1.
      T2 = TBB - DBT/2.

      KP2 = 0.
      GP2 = 0.
C
      DO 10 I=1,N
        T1  = T2
        KP1 = KP2
        GP1 = GP2
        T2  = T1+DBT
        CALL KGS(T2,T0,KP2,GP2TEMP,IPSI)
        GP2 = GP2TEMP * FACT
        A11=(KP2+KP1)/DBT+0.25*(GP1+GP2)*DBT       
        A01=-KP1/DBT+0.25*GP1*DBT
        IF (I.EQ.1) A01 = 0.
        ALP=A11-(A01*A01)/ALP
        IF(ALP.LE.0.) THEN
          TS = (T1+T2)/2.
          WRITE(BAL,11) TS
          RETURN
        ENDIF
   10 CONTINUE
   11 FORMAT(' UNSTABLE AT T = ',F8.3)
   20 RETURN
      END

**********************************************************************
*DECK DERIV
      SUBROUTINE DERIV(ARRIN,DARR,NCHI,IAS)
C---------------------------------------------------------------------
C SUBROUTINE TO CALCULATE THE THETA DERIVATE USING FFT.
C ARRIN : THE INPUT ARRAY
C DARR  : THE RESULTING THETA DERIVATIVE 
C NCHI  : THE NUMBER OF POLOIDAL POINTS
C IAS   : 0 FOR UP/DOWN SYMMETRIC EQUILIBRIA, 1 FOR ASYMMETRIC EQUIL.
C---------------------------------------------------------------------
c      USE COMMAX ?
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026 ,KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)                                         
c parametres MISHKA		              
      PARAMETER (NCHIMAX=1026)                                                       
      PARAMETER (NVPSIMX=101, NVCHIMX=1026)                             
      PARAMETER (NPSIMAX=NRMMAX)                             
      PARAMETER (NPNC=NPSIMAX*NCHIMAX, NP4=4*NPSIMAX)                   
      REAL*8       ARRIN(*),DARR(*),FF(2*NCHIMAX+2),DF(2*NCHIMAX+2)
      INTEGER    INDEX(2*NCHIMAX)

      PI = 2.* ASIN(1.)

      DO 10 J=1,NCHI
         INDEX(J) = J
   10 CONTINUE
   
      IF (IAS.EQ.0) THEN
        DO 20 J=NCHI+1,2*NCHI-2
          INDEX(J) = 2*NCHI-J
   20   CONTINUE
      ENDIF

      IF (IAS.EQ.0) THEN
         N=2*(NCHI-1)
      ELSE
         N=NCHI
      ENDIF
      DO 40 J=1,N       
        FF(J) = ARRIN(INDEX(J))
   40 CONTINUE 
                        
      CALL RFT2(FF,N,1)
      
      DO 50 J = 1,N/2
        DF(2*J-1) = - real(J-1) * FF(2*J)   
        DF(2*J)   =   real(J-1) * FF(2*J-1) 
   50 CONTINUE
   
      DF(2) = 0.
      DF(N+2) = 0.

      CALL RFI2(DF,N,1)

      DO 60 J=1,NCHI
        DARR(J) = DF(J)
   60 CONTINUE
      END
************************************************************************
*DECK MAPPING
      SUBROUTINE MAPPING(XX,YY,PSI,CX,CY,XAXIS,A)
C-----------------------------------------------------------------------
C SUBROUTINE TO CALCULATE THE METRIC COEFFICIENTS NEEDED FOR CASTOR
C-----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT integer (I-N)
      PARAMETER (NRMAX = 51,  NPMAX = 129)                              
      PARAMETER (MAXNODE=NRMAX*NPMAX, MBMAX=1026, KKLDA=4*NPMAX+9)        
      PARAMETER (NRMMAX = 201, NPMMAX = 129)                             
      PARAMETER (MAXMNODE = NRMMAX*NPMMAX)                              
      PARAMETER (NPTSMAX = 201)
      PARAMETER (NPSIMAX=NRMMAX, NCHIMAX=1026)                             
      PARAMETER (NPNC=NPSIMAX*NCHIMAX, NP4=4*NPSIMAX)                   
                                         
C-----------------------------------------------------------------------
      COMMON / COMDAT/                                                  
     >        ELLIP,TRIAH,TRIAB,QUAD,PAR1,PAR2,PAR3,PAR4,                      
     >        AGA,BGA,CGA,DGA,EGA,FGA,GGA,HGA,                          
     >        API,BPI,CPI,DPI,EPI,FPI,GPI,HPI,                          
     >        ACUR,BCUR,CCUR,DCUR,ECUR,FCUR,GCUR,HCUR,                  
     >        ERRIT,ERRCUR,EPS,ALFA,B,C,XIAB,Q95,BETAP,AMIX,BMIX,       
     >        ABB, BBB, AMPL, RVAC,BVAC,ZEFF,ZN0,RPE,XR1,SIG1,          
     >        IAS,ICUR,NRCUR,NPCUR,NMESH,INIMESH,NBB,NQB,IARC,          
     >        MHARM,ISHAPE,ISOL,IGAM,IPAI,NR,NP,NRMAP,NPMAP,NITER       
      real*8    ELLIP,TRIAH,TRIAB,QUAD,PAR1,PAR2,PAR3,PAR4,                      
     >        AGA,BGA,CGA,DGA,EGA,FGA,GGA,HGA,                          
     >        API,BPI,CPI,DPI,EPI,FPI,GPI,HPI,                          
     >        ACUR,BCUR,CCUR,DCUR,ECUR,FCUR,GCUR,HCUR,                  
     >        ERRIT,ERRCUR,EPS,ALFA,B,C,XIAB,Q95,BETAP,AMIX,BMIX,       
     >        ABB, BBB, AMPL, RVAC,BVAC,ZEFF,ZN0,RPE,XR1,SIG1           
      integer IAS,ICUR,NRCUR,NPCUR,NMESH,INIMESH,NBB,NQB,IARC,          
     >        MHARM,ISHAPE,ISOL,IGAM,IPAI,NR,NP,NRMAP,NPMAP,NITER       
C-----------------------------------------------------------------------
      COMMON /GAUSINT/ XGAUSS,WGAUSS,H,HR,HS,HRS                        
      real*8 XGAUSS(4),WGAUSS(4)                                          
      real*8 H(4,4,4,4),HR(4,4,4,4),HS(4,4,4,4),HRS(4,4,4,4)              
C-----------------------------------------------------------------------
      COMMON /NODES/ PSIKN,THTKN,RADPSI,DPSIKN,DDPSIKN                                   
      REAL*8    PSIKN(NRMMAX),THTKN(NPMMAX),RADPSI(NRMMAX) 
      REAL*8    DPSIKN(NRMMAX),DDPSIKN(NRMMAX)
C-----------------------------------------------------------------------
      COMMON /COMPRI/ NPR1,NPR2,NROUT,NDIAG
      INTEGER NPR1,NPR2,NROUT,NDIAG
C-----------------------------------------------------------------------
      COMMON /COMPLO/ NPL1,TXTOUT
      INTEGER       NPL1
      CHARACTER*100 TXTOUT(40)
C-----------------------------------------------------------------------
      COMMON /COMMAP/ CS,QS,DQS,CURJ,CHI,   
     >     GEM11,GEM12,GEM33,  
     >     CHIKN,P0,RBPHI,
     >     DP,DRBPHI,
     >     DQEC,DJ0,DJE,CPSURF,RADIUS,RAXIS,DP0,DPE,DRBPHI0,DRBPHIE,
     >     JS0,NCHI,NPSI,NLTORE

      REAL*8 CS(NRMMAX),QS(NRMMAX),DQS(NRMMAX),CURJ(NRMMAX),CHI(NPMMAX),   
     >     GEM11(MAXMNODE),GEM12(MAXMNODE),GEM33(MAXMNODE),  
     >     CHIKN(NPMMAX),P0(NRMMAX),RBPHI(NRMMAX),
     >     DP(NRMMAX),DRBPHI(NRMMAX),
     >     DQEC,DJ0,DJE,CPSURF,RADIUS,RAXIS,DP0,DPE,DRBPHI0,DRBPHIE   
      INTEGER JS0,NCHI,NPSI
      LOGICAL NLTORE  
C-----------------------------------------------------------------------
      common / COMNAM / QAXIS,TBB,TBF
      REAL*8     QAXIS,TBB,TBF
C-----------------------------------------------------------------------
      COMMON / COMPIE/ PI                                               
      real*8 PI                                                           
C-----------------------------------------------------------------------
      COMMON / COMSPL /                                                 
     R         Q1(NPSIMAX), Q2(NPSIMAX), Q3(NPSIMAX), Q4(NPSIMAX),      
     R         P1(NPSIMAX), P2(NPSIMAX), P3(NPSIMAX), P4(NPSIMAX),      
     R         RBP1(NPSIMAX), RBP2(NPSIMAX), RBP3(NPSIMAX),             
     R         RBP4(NPSIMAX)                                            
                                                                       
      REAL*8     Q1, Q2, Q3, Q4,                          
     >         P1, P2, P3, P4, RBP1, RBP2, RBP3, RBP4                   
C-----------------------------------------------------------------------
      COMMON /MESHAC/ AMESH,BMESH,CMESH,XR1DONE,SIG1DONE,
     > SG,DSG,DDSG,IMESH,NRDONE 
      REAL*8    AMESH,BMESH,CMESH
      REAL*8    XR1DONE,SIG1DONE
      REAL*8    SG(NRMMAX),DSG(NRMMAX),DDSG(NRMMAX)
      INTEGER IMESH,NRDONE
C-----------------------------------------------------------------------
      COMMON/COMLOCAL/CCHI,SCHI,XCHI,YCHI,XOUT,YOUT,IJCHI

      REAL*8 XX(4,*),YY(4,*),PSI(*),MAXERR
      REAL*8 CCHI(4,2*MAXMNODE),SCHI(2*MAXMNODE)
      REAL*8 XCHI(2*MAXMNODE),YCHI(2*MAXMNODE)
      REAL*8 XOUT(2*MAXMNODE),YOUT(2*MAXMNODE)
      INTEGER IJCHI(2*MAXMNODE)
      LOGICAL CHIN
      REAL*8 XPLOT(2*NRMMAX),PPLOT(2*NRMMAX),PSIPLOT(2*NRMMAX)
      REAL*8 QPLOT(2*NRMMAX),CUPLOT(2*NRMMAX),DQPLOT(2*NRMMAX)
C--------------------------------------------- VARIABLES FOR VACUUM --
      REAL*8 VX(2*NPMMAX-1),VY(2*NPMMAX-1)
C---------------------------------------------------------------------
      PI = 2.*ASIN(1.D0)
      MAXERR = -1.D20
      FACTAS = 2.D0
      IF (IAS.EQ.1) FACTAS=1.D0
c      write(*,*) 'Before Profile'
C--------------------------------------------- NORM FACTORS ----------
      CALL PROFILES(P0,RBPHI,DP,DRBPHI,A)

c      write (*,*) 'After PROFILES'
c      IF (NPR1.NE.0) THEN
c        WRITE(20,*)
c        WRITE(20,*) '*************************************'
c        WRITE(20,*) '* PRESSURE PROFILE BEFORE NORM.  :  *'
c        WRITE(20,*) '*************************************'
c        WRITE(20,91) (P0(I)*EPS/ALFA**2,I=1,NR)
c        WRITE(20,*) '*************************************'
c	WRITE(20,*)
c      ENDIF
c   91 FORMAT(4E16.8)
      PAX = P0(1)*EPS/(ALFA*ALFA)
      
      RAXIS = 1. + EPS * XAXIS
      BM = RBPHI(1) / RAXIS
      B0 = 1./ BM
      R0 = 1./ RAXIS
      RADIUS = EPS * R0
      PSCALE = B0**2 * EPS / ALFA**2
      RBSCALE = B0 * R0
      DO 90 I = 1,NR
        P0(I) = P0(I) * PSCALE
        DP(I) = DP(I) * PSCALE
        RBPHI(I) = RBPHI(I) * RBSCALE
        DRBPHI(I) = DRBPHI(I) * RBSCALE
   90 CONTINUE
      CPSURF = RADIUS**2 * B0 / ALFA
      RAXIS = 1.
      PAXIS = P0(1)
c      WRITE(20,2) RADIUS
c      WRITE(20,3) B0
c      WRITE(20,4) CPSURF
c    2 FORMAT(' RADIUS : ',E12.4)
c    3 FORMAT(' B0     : ',E12.4)
c    4 FORMAT(' CPSURF : ',E12.4)
C------------------------------------------------- DERIVATIVE DP/DS ----
      DPE = DP(NR)
      DP0 = 0.
      DRBPHI0 = 0.


C--------------------------------------------- DATA FOR VECTOR PLOT ----
c      WRITE(21,*) NR,NCHI,EPS
C------------------------------------------ - Q PROFILE ----------------
C                                           - DQ/DS PROFILE
C                                           - CHI VALUES AT THETA NODES
      DO 10 I = 1, NR-1
        SUMQ = 0.
        SUMQR = 0.
        ZPSI = PSIKN(I)
c        CALL RADMESH(RADPSI(I),ZPSI,DZPSI,DDZPSI)
        PSIR  = - DPSIKN(I)  /(2.*REAL(NR-1))
        PSIRR =   DDPSIKN(I) /(2.*REAL(NR-1))**2
        CS(NR-I+1) = SQRT(ZPSI)
c        write(*,*) 'Ligne 6559'
        DO 20 J = 1, NP-1
          N1 = (I-1)*NP + J
          N2 = N1 + 1
          N3 = N2 + NP
          N4 = N1 + NP
          DO 30 K = 1,4
            S = XGAUSS(K)
            CALL INTERP(XX(1,N1),XX(1,N2),XX(1,N3),XX(1,N4),-1.D0,S,
     >                  X,XR,XS,XRS,XRR,XSS)
            CALL INTERP(YY(1,N1),YY(1,N2),YY(1,N3),YY(1,N4),-1.D0,S,
     >                  Y,YR,YS,YRS,YRR,YSS)
            EJAC = XR*YS - XS*YR
            ER = XRR*YS + XR*YRS - XRS*YR - XS*YRR
            BIGR  = (1. + EPS * X)
            SUMQ  = SUMQ - WGAUSS(K) * EJAC / ( BIGR * ABS(PSIR))
            SUMQR = SUMQR + PSIRR * EJAC / ((PSIR**2)*BIGR)* WGAUSS(K)
            SUMQR = SUMQR - ER / (BIGR*PSIR)               * WGAUSS(K)
            SUMQR = SUMQR + EJAC*EPS*XR/((BIGR**2)*PSIR)  * WGAUSS(K)
   30     CONTINUE
          CCHI(1,(I-1)*NP+J+1) = SUMQ
          CCHI(2,(I-1)*NP+J+1) = SUMQR
          CALL INTERP(XX(1,N1),XX(1,N2),XX(1,N3),XX(1,N4),-1.D0,1.D0,
     >                X,XR,XS,XRS,XRR,XSS)
          CALL INTERP(YY(1,N1),YY(1,N2),YY(1,N3),YY(1,N4),-1.D0,1.D0,
     >                Y,YR,YS,YRS,YRR,YSS)
          EJAC = XR*YS - XS*YR
          ER = XRR*YS + XR*YRS - XRS*YR - XS*YRR
          BIGR = (1. + EPS * X )
          ZSUMQ  = - EJAC / ( BIGR * ABS(PSIR))
          ZSUMQR = + PSIRR * EJAC / (PSIR**2 *BIGR)
          ZSUMQR =  ZSUMQR - ER / (BIGR*PSIR)
          ZSUMQR =  ZSUMQR + EJAC*EPS*XR/((BIGR**2) * PSIR)
          CCHI(3,(I-1)*NP+J+1) = ZSUMQ
          CCHI(4,(I-1)*NP+J+1) = ZSUMQR
   20   CONTINUE
        CCHI(1,(I-1)*NP+1) = 0.
        CCHI(2,(I-1)*NP+1) = 0.
        N1 = (I-1)*NP + 1
        N2 = N1 + 1
        N3 = N2 + NP
        N4 = N1 + NP
        CALL INTERP(XX(1,N1),XX(1,N2),XX(1,N3),XX(1,N4),-1.D0,-1.D0,
     >              X,XR,XS,XRS,XRR,XSS)
        CALL INTERP(YY(1,N1),YY(1,N2),YY(1,N3),YY(1,N4),-1.D0,-1.D0,
     >              Y,YR,YS,YRS,YRR,YSS)
        EJAC = XR*YS - XS*YR
        ER = XRR*YS + XR*YRS - XRS*YR - XS*YRR
        BIGR = (1. + EPS * X )
        ZSUMQ = - EJAC / (BIGR * ABS(PSIR))
        ZSUMQR =  + PSIRR * EJAC / (PSIR**2 *BIGR)
        ZSUMQR = ZSUMQR - ER / (BIGR*PSIR)
        ZSUMQR = ZSUMQR + EJAC*EPS*XR/((BIGR**2) * PSIR)
        CCHI(3,(I-1)*NP+1) =  ZSUMQ
        CCHI(4,(I-1)*NP+1) =  ZSUMQR
        QS(NR-I+1) =  0.5D0*FACTAS * SUMQ * RBPHI(NR-I+1) / RBSCALE
        DQS(NR-I+1)=SUMQR*RBPHI(NR-I+1)+SUMQ*DRBPHI(NR-I+1)/(2.*(NR-1))
        DQS(NR-I+1)=  0.5D0*FACTAS * DQS(NR-I+1) / RBSCALE
   10 CONTINUE
      IF ((EPS.LE.0.01).AND.(P0(1).LE.0.)) THEN
        S2 = SQRT(PSIKN(NR-1))
        S3 = SQRT(PSIKN(NR-2))
        QS(1) = QS(2) - (QS(3)-QS(2))/(S3-S2) * S2
      ELSE
        QS(1) = RBPHI(1)* PI/(2.*SQRT(CX*CY)*(1.+EPS*XAXIS)*RBSCALE)
      ENDIF
      DQS(1) = 0.
      DO 40 I = 1, NR-1
        DO 50 J = 1, NP
          DUM = CCHI(1,I*NP)
          NO = (I-1)*NP+J
          CCHI(1,NO) = real(1+IAS)*PI*CCHI(1,NO) / DUM
          DUM2 = CCHI(2,I*NP)
          CCHI(2,NO) = real(1+IAS)*PI*CCHI(2,NO) / DUM
          CCHI(3,NO) = real(1+IAS)*PI*CCHI(3,NO) / DUM
          CCHI(4,NO) = real(1+IAS)*PI*CCHI(4,NO) / DUM
C------------------------------ FINAL VALUES OF CHI --------------------
          QQ  = QS(NR-I+1)
          DQQ = DQS(NR-I+1)
          RB  = RBPHI(NR-I+1)
          DRB = DRBPHI(NR-I+1)  /  (2*(NR-1))
          CCHI(2,NO)= +(DQQ/QQ - DRB/RB) * CCHI(1,NO) - CCHI(2,NO)
          CCHI(4,NO)= +(DQQ/QQ - DRB/RB) * CCHI(3,NO) - CCHI(4,NO)
   50   CONTINUE
   40 CONTINUE
c      IF (NPR1.NE.0) THEN
c        CALL PRARR1(' CHI : ',CCHI,4*NR*NP,203)
c      ENDIF
c      write(*,*) 'Profil de q'

      DO 45 I=1,NR
        QS(I) = QS(I) * ALFA / PI
        QPLOT(NR+1-I) = QS(I)
        DQS(I) = DQS(I) * ALFA / PI
        DQPLOT(NR+1-I) = DQS(I)
   45 CONTINUE
      QS0 = QS(1)
      QAXIS = QS(1)
c      WRITE(20,*)
c      WRITE(20,31) QS(1)
c      WRITE(20,32) QS(NR)
c   31 FORMAT('  Q ON AXIS = ',f7.4)
c   32 FORMAT('  Q AT BOUNDARY = ',f7.4)

c      IF (NPR1.NE.0) THEN
c        CALL PRARR1(' Q PROFILE : ',QS,NR,203)
c      ENDIF
      DQEC = DQS(NR)
C--------------------------- DETERMINE POSITIONS OF EQUIDISTANT CHI'S --
C                            AND CALCULATE MATRIX ELEMENTS -------------
c   54 FORMAT('NUMBER OF CHI VALUES : ',I3)
      JS0 = NR - 1
      IF (IAS.EQ.0) THEN
        DO 55 J=1,NCHI
          CHIKN(J) =  PI * REAL(J-1)/REAL(NCHI-1)
          CHI(J)   =  PI * REAL(J-1)/REAL(NCHI-1)
   55   CONTINUE
      ELSE
        DO 56 J=1,NCHI
          CHIKN(J) = 2. * PI * REAL(J-1)/REAL(NCHI)
          CHI(J)   = 2. * PI * REAL(J-1)/REAL(NCHI)
   56   CONTINUE
      ENDIF
C      CALL PRARR1(' CHI : ',CHI,NCHI,201)
C      CALL PRARR2(' CCHI : ',' ',CCHI,4,NR*NP,4,203)
C      CALL PRARR2(' XX : ',' ',XX,4,NR*NP,4,203)
C      CALL PRARR2(' YY : ',' ',YY,4,NR*NP,4,203)
      DO 60 I=1,NR-1
        ZPSI = PSIKN(I)
c        CALL RADMESH(RADPSI(I),ZPSI,DZPSI,DDZPSI)
        PSIR  = - DPSIKN(I)  /(2.*REAL(NR-1))
        PSIRR =   DDPSIKN(I) /(2.*REAL(NR-1))**2
C-------------------------- FIRST POINT IS KNOWN -----------------------
c      write(*,*)  'Ligne 6691'
        NO = (I-1)*NCHI + 1
        K = 1
        S = -1.D0
        SCHI((I-1)*NCHI+J) = S
        IJCHI((I-1)*NCHI+J) = K
        N1 =  (I-1)*NP + K
        N2 = N1 + 1
        N3 = N2 + NP
        N4 = N1 + NP
        CALL INTERP(XX(1,N1),XX(1,N2),XX(1,N3),XX(1,N4),
     >              -1.D0,S,XCHI(NO),XR,XS,XRS,XRR,XSS)
        CALL INTERP(YY(1,N1),YY(1,N2),YY(1,N3),YY(1,N4),
     >              -1.D0,S,YCHI(NO),YR,YS,YRS,YRR,YSS)
        CALL INTERP(CCHI(1,N1),CCHI(1,N2),CCHI(1,N3),CCHI(1,N4),
     >              -1.D0,S,DCHI,CHIR,CHIS,CHIRS,CHIRR,CHISS)
C--------------------------------------------- VACUUM DATA ---------
        IF (I.EQ.1) THEN
          VX(1) = XCHI(NO)
          VY(1) = YCHI(NO)
        ENDIF
C-----------------------------------------------------------------------
        EJAC  = (XR*YS-XS*YR)
        EJAC2 = EJAC**2
C----------------------------- DATA FOR VECTOR PLOT TO FILE 21 -----
        PSIX = PSIR * YS / EJAC
        PSIY = - PSIR * XS / EJAC
        CHIX = (CHIR * YS - CHIS * YR) / EJAC
        CHIY = (-CHIR * XS + CHIS * XR)/ EJAC
c        WRITE(21,61) SQRT(ZPSI),DCHI,XCHI(NO),YCHI(NO),
c     >              PSIX,PSIY,CHIX,CHIY
C----------------------------------------------------------------------
        GRPS2 = PSIR**2 * (XS**2 + YS**2) / EJAC2
        NOG = (NR-1)*NCHI - I*NCHI + 1
        GEM11(NCHI+NOG) = GRPS2 * (CPSURF/RADIUS)**2
        GRPGRC = ( CHIR * PSIR * (XS**2 + YS**2) -
     >             CHIS * PSIR * (XR*XS + YR*YS) ) / EJAC2
        GEM12(NCHI+NOG) = GRPGRC * CPSURF / (RADIUS**2)
        GEM33(NCHI+NOG) =((1.+EPS*XCHI(NO))/(1.+EPS*XAXIS))**2
        XOUT(NCHI+NOG) = XCHI(NO)
        YOUT(NCHI+NOG) = YCHI(NO)
C------------------------------------ CHECK JACOBIAN -----------------        
                GRCHI2 = CHIX**2 + CHIY**2                                    
                DUM1 = RBPHI(NR-I+1)**2 /                                     
     >             (QS(NR-I+1)**2 * GEM33(NCHI+NOG))                          
                DUM2 = GEM11(NCHI+NOG) * GRCHI2 / (RADIUS**2)                 
                DUM3 = GEM12(NCHI+NOG)                                        
                DUM4 = DUM2 - DUM3*DUM3
		ERRJ = ABS(DUM4-DUM1)
                IF (ERRJ.GT.MAXERR) THEN
                  MAXERR=ERRJ
                  IERR = I
                  JERR = J
                  SERR = SQRT(ZPSI)
                  CERR = DCHI
                ENDIF
CCC                WRITE(20,*) DUM1,DUM4,(dum1-dum4)/dum1
c      write(*,*) 'Ligne 6747'
C---------------------------------------------------------------------
        JBASE = 2
        DO 70 K = 1,NP-1
          CHIN =.FALSE.
          DO 80 J = JBASE,NCHI
            ZCHI = CHIKN(J)
            NO = (I-1)*NCHI + J
            IF ((((CCHI(1,(I-1)*NP+K).LE.ZCHI).AND.(CCHI(1,(I-1)*NP+K+1)
     >           .GE.ZCHI)) ).OR. 
     >           ((J.EQ.NCHI).AND.(K.EQ.NP-1).AND.(IAS.EQ.0))) THEN
              CHIN = .TRUE.
              NOM = (I-1)*NP + K
              NOP = NOM + 1
              A3 = (CCHI(1,NOM)+CCHI(3,NOM)-CCHI(1,NOP)+CCHI(3,NOP))/4.
              A2 = (- CCHI(3,NOM) + CCHI(3,NOP))/4.
           A1=(-3*CCHI(1,NOM)-CCHI(3,NOM)+3*CCHI(1,NOP)-CCHI(3,NOP))/4.
           A0=( 2*CCHI(1,NOM)+CCHI(3,NOM)+2*CCHI(1,NOP)-CCHI(3,NOP))/4.
     >       - ZCHI
              CALL SOLVP3(A0,A1,A2,A3,S,S2,S3,IFAIL)
	      IF ((IAS.EQ.0).AND.(J.EQ.NCHI)) THEN
	        S = 1.0
		IFAIL=0
	      ENDIF	
              IF (IFAIL.EQ.0) THEN
                SCHI((I-1)*NCHI+J) = S
                IJCHI((I-1)*NCHI+J) = K
                N1 = (I-1)*NP + K
                N2 = N1 + 1
                N3 = N2 + NP
                N4 = N1 + NP
                CALL INTERP(XX(1,N1),XX(1,N2),XX(1,N3),XX(1,N4),
     >                      -1.,S,XCHI(NO),XR,XS,XRS,XRR,XSS)
                CALL INTERP(YY(1,N1),YY(1,N2),YY(1,N3),YY(1,N4),
     >                      -1.,S,YCHI(NO),YR,YS,YRS,YRR,YSS)
                CALL INTERP(CCHI(1,N1),CCHI(1,N2),CCHI(1,N3),CCHI(1,N4),
     >                      -1.,S,DCHI,CHIR,CHIS,CHIRS,CHIRR,CHISS)
C--------------------------------------------- VACUUM DATA ---------
                IF (I.EQ.1) THEN
                  VX(J) = XCHI(NO)
                  VY(J) = YCHI(NO)
                ENDIF
C-----------------------------------------------------------------------
                EJAC  = (XR*YS-XS*YR)
                EJAC2 = EJAC**2
C-------------------------------- DATA FOR VECTOR PLOT TO FILE 21 -----
                PSIX = PSIR * YS / EJAC
                PSIY = - PSIR * XS / EJAC
                CHIX = (CHIR * YS - CHIS * YR) / EJAC
                CHIY = (-CHIR * XS + CHIS * XR)/ EJAC
c                WRITE(21,61) SQRT(ZPSI),DCHI,XCHI(NO),YCHI(NO),
c     >                        PSIX,PSIY,CHIX,CHIY
C----------------------------------------------------------------------
                GRPS2 = PSIR**2 * (XS**2 + YS**2) / EJAC2
                NOG = (NR-1)*NCHI - I*NCHI + J
                GEM11(NCHI+NOG) = GRPS2 * (CPSURF/RADIUS)**2
                GRPGRC = ( CHIR * PSIR * (XS**2 + YS**2) -
     >                     CHIS * PSIR * (XR*XS + YR*YS) ) / EJAC2
                GEM12(NCHI+NOG) = GRPGRC * CPSURF / (RADIUS**2)
                GEM33(NCHI+NOG) =((1.+EPS*XCHI(NO))/(1.+EPS*XAXIS))**2
                XOUT(NCHI+NOG) = XCHI(NO)
                YOUT(NCHI+NOG) = YCHI(NO)
C------------------------------------ CHECK JACOBIAN -----------------        
                GRCHI2 = CHIX**2 + CHIY**2                                    
                DUM1 = RBPHI(NR-I+1)**2 /                                     
     >             (QS(NR-I+1)**2 * GEM33(NCHI+NOG))                          
                DUM2 = GEM11(NCHI+NOG) * GRCHI2 / (RADIUS**2)                 
                DUM3 = GEM12(NCHI+NOG)                                        
                DUM4 = DUM2 - DUM3*DUM3
		ERRJ = ABS(DUM4-DUM1)
                IF (ERRJ.GT.MAXERR) THEN
                  MAXERR=ERRJ
                  IERR = I
                  JERR = J
                  SERR = SQRT(ZPSI)
                  CERR = DCHI
                ENDIF
CCC                WRITE(20,*) DUM1,DUM4,dum1-dum4
C---------------------------------------------------------------------
              ELSE
                WRITE(*,*) 'ERROR IN SOLVP3 I,J,K : ',I,J,K,S,s2,s3
                WRITE(*,*) A0,A1,A2,A3,ZCHI
                WRITE(*,*) CCHI(1,(I-1)*NP+K),CCHI(1,(I-1)*NP+K+1)
              ENDIF
            ELSEIF (CHIN) THEN
              JBASE = J
              GOTO 70
            ENDIF
   80     CONTINUE
   70   CONTINUE
   60 CONTINUE
   61 FORMAT(8E16.8)  

   62 FORMAT(' MAX. ERROR IN JACOBIAN AFTER MAPPING : ',
     >       1PE10.3,0P2F10.6,2I4)
c      WRITE(20,*)
c      WRITE(20,*) '***************************************************'
c      WRITE(20,62) MAXERR,SERR,CERR,IERR,JERR
c      WRITE(20,*) '***************************************************'


C-------------------- WRITE GEOMETRIC QUANTITIES TO TAPE12 -----------
c      NMAP = 12
c      OPEN(NMAP)
c      WRITE(NMAP,8) JS0
c      WRITE(NMAP,6) (CS(JS),JS=1,JS0+1)
c      WRITE(NMAP,6) (QS(JS),JS=1,JS0+1)
c      WRITE(NMAP,7) DQS(1),DQEC
c      WRITE(NMAP,6) (DQS(JS),JS=2,JS0+1)
c      WRITE(NMAP,6) (CURJ(JS),JS=1,JS0+1)
c      WRITE(NMAP,7) DJ0,DJE
c      WRITE(NMAP,8) NCHI
c      WRITE(NMAP,6) (CHI(JS),JS=1,NCHI)
c      WRITE(NMAP,6) (GEM11(JS),JS=NCHI+1,(JS0+1)*NCHI)
c      WRITE(NMAP,6) (GEM12(JS),JS=NCHI+1,(JS0+1)*NCHI)
c      WRITE(NMAP,7) CPSURF,RADIUS
c      WRITE(NMAP,6) (GEM33(JS),JS=NCHI+1,(JS0+1)*NCHI)
c      WRITE(NMAP,9) RAXIS
c      WRITE(NMAP,6) (P0(JS),JS=1,JS0+1)
c      WRITE(NMAP,7) DP0,DPE
c      WRITE(NMAP,6) (RBPHI(JS),JS=1,JS0+1)
c      WRITE(NMAP,7)  DRBPHI0,DRBPHIE
cC----------------------------------------- ADDITIONAL DATA FOR VACUUM --
c      WRITE(NMAP,6) (VX(JS),JS=1,NCHI)
c     WRITE(NMAP,6) (VY(JS),JS=1,NCHI)
c     WRITE(NMAP,9) EPS
c      WRITE(NMAP,6) (XOUT(JS),JS=NCHI+1,(JS0+1)*NCHI)
c      WRITE(NMAP,6) (YOUT(JS),JS=NCHI+1,(JS0+1)*NCHI)
C----------------------------------------- write profiles to vector file
c      WRITE(21,11)  (P0(JS),RBPHI(JS),QS(JS),JS=1,JS0+1)
c      WRITE(21,11)  CPSURF
c      CLOSE(21)
c    6 FORMAT(4E16.8)
c    7 FORMAT(2E16.8)
c    8 FORMAT(I5)
c    9 FORMAT(E16.8)
c   11 FORMAT(3E16.8)

      
c      IF (NPL1.NE.0) THEN
c      CALL LBLBOT('HELENA EQUILIBRIUM Version 12',34)      
c      CALL PLOTM(XCHI,YCHI,NR-1,NCHI,IAS)
C---------------------------------------- PLOT PROFILES --------------
c      DO 65 I=1,NR
c        IF (IAS.EQ.1) THEN
c          ILEFT = (I-1)*NP + (NP+1)/2
c	ELSE 
c	  ILEFT = (I-1)*NP + NP
c	ENDIF  
c        IRIGHT= (I-1)*NP + 1
c        XL = XX(1,ILEFT)
c        XR = XX(1,IRIGHT)
c        ZPSI = PSIKN(I)
c        IF ((IGAM.GE.1).AND.(IGAM.LE.4)) THEN
c          CUPLOT(I) = DGDPSI(ZPSI) + B*XL*(1.+EPS*XL/2.)*DPDPSI(ZPSI)
c          CUPLOT(2*NR-I)= DGDPSI(ZPSI)+B*XR*(1.+EPS*XR/2.)*DPDPSI(ZPSI)
c        ELSE
c          CUPLOT(I) = C*DGDPSI(ZPSI) + B*(1.+EPS*XL)**2 * DPDPSI(ZPSI)
c          CUPLOT(2*NR-I)=C*DGDPSI(ZPSI)+B*(1.+EPS*XR)**2 *DPDPSI(ZPSI)
c        ENDIF
c        CUPLOT(I) = A * CUPLOT(I) / (1.+EPS*XL)
c        IF (I.NE.NR) THEN
c          CUPLOT(2*NR-I) = A * CUPLOT(2*NR-I) / (1.+EPS*XR)
c        ENDIF
c   65 CONTINUE
c      DO 100 I=1,NR
c        IF (IAS.EQ.1) THEN
c          ILEFT = (I-1)*NP + (NP+1)/2
c	ELSE 
c	  ILEFT = (I-1)*NP + NP
c	ENDIF  
c        IRIGHT= (I-1)*NP + 1
c        XPLOT(I) = XX(1,ILEFT)
c        XPLOT(2*NR-I) = XX(1,IRIGHT)
c        PPLOT(I) = P0(NR-I+1)/P0(1)
c        PPLOT(2*NR-I) = P0(NR-I+1)/P0(1)
c        PSIPLOT(I) = PSIKN(I)
c        PSIPLOT(2*NR-I) = PSIKN(I)
c        QPLOT(2*NR-I) = QPLOT(I)
c        DQPLOT(2*NR-I) = DQPLOT(I)
c  100 CONTINUE
c      IF (NPR1.NE.0) THEN
c      WRITE(20,*)
c      WRITE(20,*) '***************************************************'
c      WRITE(20,*) '* I,     X,          PSI,          P,         Q   *'
c      WRITE(20,*) '***************************************************'
c     WRITE(20,101) (I,XPLOT(I),PSIPLOT(I),PAX*PPLOT(I),QPLOT(I),
c     >               I=1,2*NR-1) 
c      WRITE(20,*) '***************************************************'
c      WRITE(20,*)
c      ENDIF
c  101 FORMAT(I4,4E12.4)
      
C      CALL PRARR1('XPLOT : ',XPLOT,2*NR-1,203)                            
C      CALL PRARR1('PPLOT : ',PPLOT,2*NR-1,203)                            
C      CALL PRARR1('PSIPLOT : ',PSIPLOT,2*NR-1,203)                        
C      CALL PRARR1('QPLOT : ',QPLOT,2*NR-1,203)                            

c      WRITE(25,*) '  I,           X,          PSI,        P,       Q '
c      WRITE(25,106) (XPLOT(I),PSIPLOT(I),PAXIS*PPLOT(I),QPLOT(I),
c     >               I=1,2*NR-1)
c  106 FORMAT(4E12.4)   
c      IF (XPLOT(1).LT.-0.999)       XPLOT(1)     =-0.999
c      IF (XPLOT(2*NR-1).GT.0.999)   XPLOT(2*NR-1)= 0.999

c      CALL LPLOT(3,2,1,XPLOT,PPLOT,2*NR-1,1,'PRESSURE',8,'X',1,'P/P0',4)
c      CALL LPLOT(3,3,1,XPLOT,QPLOT,2*NR-1,1,'Q-PROFILE',9,'X',1,'Q',1)
c      CALL LBLBOT('HELENA EQUILIBRIUM Version 12',34)


c      CALL LPLOT(2,2,1,XPLOT,PSIPLOT,2*NR-1,1,'FLUX',4,'X',1,'PSI',3)
c      CALL LPLOT(3,2,1,XPLOT,PPLOT,2*NR-1,1,'PRESSURE',8,'X',1,'P/P0',4)
c      CALL LPLOT(2,3,1,XPLOT,CUPLOT,2*NR-1,1,'CURRENT DENSITY',15,'X',1,
c     >           'J',1)
c      CALL LPLOT(3,3,1,XPLOT,QPLOT,2*NR-1,1,'Q-PROFILE',9,'X',1,'Q',1)
c      CALL LBLBOT('HELENA EQUILIBRIUM Version 12',34)

c      ENDIF
      
      RETURN
      END
************************************************************************
