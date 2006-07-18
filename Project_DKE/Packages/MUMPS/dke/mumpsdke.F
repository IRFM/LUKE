C This file must be used with DMUMPS VERSION 4.6.1
C
CCCCCCCCCCC ADAPTED FOR THE ELECTRON DRIFT KINETIC SOLVER DKE CCCCCCCCCCCCC 
CC By Y.PEYSSON (yves.peysson@cea.fr) and J. DECKER (joan.decker@cea.fr) CC
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
      PROGRAM DMUMPS_DKE
      IMPLICIT NONE
      INCLUDE 'mpif.h'
      INCLUDE 'dmumps_struc.h'
      TYPE (DMUMPS_STRUC) mumps_par
      INTEGER IERR, I
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC FOR DKE CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC   
C
      double precision:: dimvalu
      integer:: rw,rc,lengthin,lengthout
	  real*8 ZZ
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
      
      CALL MPI_INIT(IERR)
C Define a communicator for the package.
      mumps_par%COMM = MPI_COMM_WORLD
C  Initialize an instance of the package
C  for L U factorization (sym = 0, with working host)
      mumps_par%JOB = -1
      mumps_par%SYM = 0
      mumps_par%PAR = 1
      CALL DMUMPS(mumps_par)
C  Define problem on the host (processor 0)
      IF ( mumps_par%MYID .eq. 0 ) THEN

C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC FOR DKE CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC   
C

      inquire(iolength=lengthin) dimvalu
	  
C  Read vector size

      open(unit=77,file='MUMPS_N_in.bin',access='direct',
     *form='unformatted',status='old',recl=lengthin,iostat=rc,err=300)      
      read(unit=77,rec=1,iostat=rw) ZZ
      mumps_par%N = ZZ
      close(77)
C      write(*,*) ZZ,mumps_par%N
      
C  Read number of non-zero elements in matrix A 

      open(unit=77,file='MUMPS_NA_in.bin',access='direct',
     *form='unformatted',status='old',recl=lengthin,iostat=rc,err=301)      
      read(unit=77,rec=1,iostat=rw) ZZ
      mumps_par%NZ = ZZ
      close(77)
      
C  Memory allocation

      ALLOCATE( mumps_par%IRN ( mumps_par%NZ ) )
      ALLOCATE( mumps_par%JCN ( mumps_par%NZ ) )
      ALLOCATE( mumps_par%A( mumps_par%NZ ) )
      ALLOCATE( mumps_par%RHS ( mumps_par%N  ) )      

C  Read non-zero elements of matrix A      
      
      open(unit=77,file='MUMPS_AI_in.bin',access='direct',
     *form='unformatted',status='old',recl=lengthin,iostat=rc,err=302) 
      open(unit=78,file='MUMPS_AJ_in.bin',access='direct',
     *form='unformatted',status='old',recl=lengthin,iostat=rc,err=303) 
      open(unit=79,file='MUMPS_AV_in.bin',access='direct',
     *form='unformatted',status='old',recl=lengthin,iostat=rc,err=304) 
      
      DO I = 1, mumps_par%NZ
         read(unit=77,rec=I,iostat=rw) ZZ
         mumps_par%IRN(I) = ZZ
         read(unit=78,rec=I,iostat=rw) ZZ
         mumps_par%JCN(I) = ZZ
         read(unit=79,rec=I,iostat=rw) ZZ
         mumps_par%A(I) = ZZ
      END DO
      
      close(77)
      close(78)
      close(79)

C  Read vector B

      open(unit=77,file='MUMPS_B_in.bin',access='direct',
     *form='unformatted',status='old',recl=lengthin,iostat=rc,err=305) 

      DO I = 1, mumps_par%N
         read(unit=77,rec=I,iostat=rw) ZZ
         mumps_par%RHS(I) = ZZ  
      END DO

      close(77)

      END IF
C  Call package for solution
      mumps_par%JOB = 6
      CALL DMUMPS(mumps_par)
C  Solution has been assembled on the host
      IF ( mumps_par%MYID .eq. 0 ) THEN
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCC FOR DKE OUTPUT CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC   
C
      inquire(iolength=lengthout) dimvalu

C  Write vector X

      open(unit=77,file='MUMPS_X_out.bin',access='direct',
     *form='unformatted',status='replace',
     *recl=lengthout,iostat=rc,err=400)
      
      
      do i=1,mumps_par%N
        write(unit=77,rec=I,iostat=rw) mumps_par%RHS(I)
      enddo

      close(77)      
      
      GOTO 1000
      
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
      END IF
C  Deallocate user data
      
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC FOR DKE   CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C

      
  300 continue
      print*,'PROBLEM IN READING INPUT FILE MUMPS_N_in.bin'
      GOTO 1000
  301 continue
      print*,'PROBLEM IN READING INPUT FILE MUMPS_NA_in.bin'
      GOTO 1000
  302 continue
      print*,'PROBLEM IN READING INPUT FILE MUMPS_AI_in.bin'
      GOTO 1000
  303 continue
      print*,'PROBLEM IN READING INPUT FILE MUMPS_AJ_in.bin'
      GOTO 1000
  304 continue
      print*,'PROBLEM IN READING INPUT FILE MUMPS_AV_in.bin'
      GOTO 1000
  305 continue
      print*,'PROBLEM IN READING INPUT FILE MUMPS_B_in.bin'
      GOTO 1000
      
  400 continue
      print*,
     *'PROBLEM IN WRITING OUTPUT FILE MUMPS_X_out.bin'
      GOTO 1000

C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C

 1000 IF ( mumps_par%MYID .eq. 0 )THEN
        DEALLOCATE( mumps_par%IRN )
        DEALLOCATE( mumps_par%JCN )
        DEALLOCATE( mumps_par%A   )
        DEALLOCATE( mumps_par%RHS )
      END IF
C  Destroy the instance (deallocate internal data structures)
      mumps_par%JOB = -2
      CALL DMUMPS(mumps_par)
      CALL MPI_FINALIZE(IERR)

      STOP
      END

