C
C   Calculation of the plasma dispersion function
C
C   Requires the use of IMSL library
C
C   by A.K. Ram and J. Decker 10/26/05
C
      subroutine pdisp(rnar,cargr,cargi,zr,zi)
C
      implicit double precision (a-h, o-z)
C
      REAL*8 rnar,cargr(0:1000),cargi(0:1000),zr(0:1000),zi(0:1000)
C
      double complex dcmplx
      double complex csqpi,zerfe
C
      double complex carg, z
C
      external zerfe
C
      sqpi=1.772453850905516d0
        pi=3.141592653589793d0
C
      csqpi=dcmplx(0.d0,sqpi)
      nar = int(rnar)
C     
      do 1 i=0,nar
        carg = dcmplx(cargr(i),cargi(i))
        z=csqpi*zerfe(carg)      
        zr(i) = dreal(z)
        zi(i) = dimag(z)
    1 continue
C
      return
      end
