C
C pdispg.f - Gateway function for pdisp.f
C
C This is the FORTRAN code required for interfacing pdisp to MATLAB.
C
C This subroutine is the main gateway to MATLAB.  When the pdisp MEX function
C  is executed MATLAB calls the MEXFUNCTION subroutine in the corresponding
C  MEX file.
C
C J. Decker 10/26/05
C
      SUBROUTINE MEXFUNCTION(NLHS, PLHS, NRHS, PRHS)
C
C-----------------------------------------------------------------------
C     (pointer) Replace integer by integer*8 on the DEC Alpha
C     64-bit platform
C
      INTEGER PLHS(*), PRHS(*)
C
C-----------------------------------------------------------------------
C
      INTEGER NLHS, NRHS
C
C-----------------------------------------------------------------------
C     (pointer) Replace integer by integer*8 on the DEC Alpha
C     64-bit platform
C
      INTEGER MXCREATEDOUBLEMATRIX, MXGETPR
C
C-----------------------------------------------------------------------
C
C
      INTEGER MXGETM, MXGETN
C
C KEEP THE ABOVE SUBROUTINE, ARGUMENT, AND FUNCTION DECLARATIONS FOR USE
C IN ALL YOUR FORTRAN MEX FILES.
C---------------------------------------------------------------------
C
C-----------------------------------------------------------------------
C     (pointer) Replace integer by integer*8 on the DEC Alpha
C     64-bit platform
C
      INTEGER rnarp,cargrp,cargip,zrp,zip
C
      INTEGER N1,N2
      INTEGER M1,M2,M3
C
      PARAMETER (N1 = 1001)
      PARAMETER (N2 = 1001)
C      
      PARAMETER (M1 = 1)
      PARAMETER (M2 = 1001)
      PARAMETER (M3 = 1001)
C
      real*8 rnar(M1),cargr(M2),cargi(M3)
      real*8 zr(N1),zi(N2)
C
C CHECK FOR PROPER NUMBER OF ARGUMENTS
C
      IF (NRHS .NE. 3) THEN
        CALL MEXERRMSGTXT('R2D2 requires 3 input arguments')
      ENDIF  
      IF (NLHS .GT. 2) THEN
        CALL MEXERRMSGTXT('R2D2 requires 2 output argument')
      ENDIF
C
C CHECK THE DIMENSIONS OF INPUTS.
C
      IF (M1 .NE. MXGETN(PRHS(1))) THEN
        CALL MEXERRMSGTXT('wrong size for arg 1')
      ENDIF
C
      IF (M2 .NE. MXGETN(PRHS(2))) THEN
        CALL MEXERRMSGTXT('wrong size for arg 2')
      ENDIF
C
      IF (M3 .NE. MXGETN(PRHS(3))) THEN
        CALL MEXERRMSGTXT('wrong size for arg 3')
      ENDIF
C
C CREATE A MATRIX FOR RETURN ARGUMENT
C
      PLHS(1) = MXCREATEDOUBLEMATRIX(1,N1,0)
      PLHS(2) = MXCREATEDOUBLEMATRIX(1,N2,0)
C
C ASSIGN POINTERS TO THE VARIOUS PARAMETERS
C
      zrp = MXGETPR(PLHS(1))
      zip = MXGETPR(PLHS(2))
C
      rnarp = MXGETPR(PRHS(1))
      cargrp = MXGETPR(PRHS(2))
      cargip = MXGETPR(PRHS(3))
C
C COPY RIGHT HAND ARGUMENTS TO LOCAL ARRAYS OR VARIABLES
C
      CALL MXCOPYPTRTOREAL8(rnarp, rnar, M1)
      CALL MXCOPYPTRTOREAL8(cargrp, cargr, M2)
      CALL MXCOPYPTRTOREAL8(cargip, cargi, M3)
C
C DO THE ACTUAL COMPUTATIONS IN A SUBROUTINE
C       CREATED ARRAYS.
C
      CALL pdisp(rnar,cargr,cargi,zr,zi)
C
C COPY OUTPUT WHICH IS STORED IN LOCAL ARRAY TO MATRIX OUTPUT
      CALL MXCOPYREAL8TOPTR(zr, zrp, N1)
      CALL MXCOPYREAL8TOPTR(zi, zip, N2)
C
      RETURN
      END
