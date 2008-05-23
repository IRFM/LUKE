C
C erfcc_mex_jd.f - Gateway function for erfcc.f
C
C This is the FORTRAN code required for interfacing erfcc to MATLAB.
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
      INTEGER i,nx,nin,ninp,xrp,xip,zrp,zip 
C
      LOGICAL flag  
      PARAMETER (nx = 1024)   
C
      real*8 ninr,xr(nx),xi(nx),yr,yi
      real*8 zr(nx),zi(nx)
C
C CHECK FOR PROPER NUMBER OF ARGUMENTS
C
      IF (NRHS .NE. 3) THEN
        CALL MEXERRMSGTXT('erfcc_mex_jd requires 3 input arguments')
      ENDIF  
      IF (NLHS .GT. 2) THEN
        CALL MEXERRMSGTXT('erfcc_mex_jd requires 2 output arg. or less')
      ENDIF
C
C CHECK THE DIMENSIONS OF INPUTS.
C
      IF ((MXGETM(PRHS(1)) .NE. 1) .OR. (MXGETN(PRHS(1)) .NE. 1)) THEN
        CALL MEXERRMSGTXT('Argument 1 must be a scalar')
      ENDIF
C
      ninp = MXGETPR(PRHS(1))
      CALL MXCOPYPTRTOREAL8(ninp, ninr, 1)
      nin = INT(ninr);
C      print *, 'nin = ',nin
C
      IF (nin .GT. 1024) THEN
        CALL MEXERRMSGTXT('nin must be <= 1024')
      ENDIF
C
      IF (MXGETM(PRHS(2)) .NE. 1) THEN
        CALL MEXERRMSGTXT('Argument 2 must be a row vector')
      ENDIF
C
      IF (MXGETM(PRHS(3)) .NE. 1) THEN
        CALL MEXERRMSGTXT('Argument 3 must be a row vector')
      ENDIF
C
      IF (MXGETN(PRHS(2)) .NE. nx) THEN
        CALL MEXERRMSGTXT('Length of Arg. 2 must be 1024')
      ENDIF
C
      IF (MXGETN(PRHS(3)) .NE. MXGETN(PRHS(2))) THEN
        CALL MEXERRMSGTXT('Arg. 1 and 2 must have the same size')
      ENDIF
C
C CREATE A MATRIX FOR RETURN ARGUMENT
C
      PLHS(1) = MXCREATEDOUBLEMATRIX(1,nx,0)
      PLHS(2) = MXCREATEDOUBLEMATRIX(1,nx,0)
C
C ASSIGN POINTERS TO THE VARIOUS PARAMETERS
C
      zrp = MXGETPR(PLHS(1))
      zip = MXGETPR(PLHS(2))
C
      xrp = MXGETPR(PRHS(2))
      xip = MXGETPR(PRHS(3))
C      print *, 'xrp = ',xrp,', xip = ',xip
C
C COPY RIGHT HAND ARGUMENTS TO LOCAL ARRAYS OR VARIABLES
C
      CALL MXCOPYPTRTOREAL8(xrp, xr, nx)
      CALL MXCOPYPTRTOREAL8(xip, xi, nx)
C
C DO THE ACTUAL COMPUTATIONS IN A SUBROUTINE
C       CREATED ARRAYS.
C
      do 10 i=1,nin
C        print *, 'i',i,', xr(i)',xr(i),', xi(i)',xi(i)
        CALL WOFZ(xr(i),xi(i),yr,yi,flag)
C        yr = xr(i)
C        yi = xi(i)
C        print *, 'yr',yr,', yi',yi
        zr(i) = yr
        zi(i) = yi
   10 continue
C
	  do 20 i=(nin+1),nx-1
        zr(i) = 0.0
        zi(i) = 0.0
   20 continue
C
C COPY OUTPUT WHICH IS STORED IN LOCAL ARRAY TO MATRIX OUTPUT
      CALL MXCOPYREAL8TOPTR(zr, zrp, nx)
      CALL MXCOPYREAL8TOPTR(zi, zip, nx)
C
      RETURN
      END
