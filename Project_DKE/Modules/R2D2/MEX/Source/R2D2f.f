C
C   CODE R2D2
C
C#####################################################################
C          evaluating the non-relativistic and relativistic          #
C        dielectric tensor elements (two different formalisms)       #
C   (only for waves in the electron cyclotron range of frequencies)  #
C#####################################################################
C
C---------------------------------------------------------------------
C
C VERSION 5:  September 23, 2003
C             May 2003
C              (modified the integration routine to check for
C               convergence -- seems to be doing fine)
C             June 5, 2003
C              (incorporated the weiss' way of doing things)
C             June 9, 2003
C              (incorporated solving of dispersion
C               relation at different positions in a plasma)
C             June 10, 2003
C              (seems to be working)
C              (Note: need to reduce accuracy of root finder for
C                     some relativistic cases to 1.0e-6;
C                     true specially near doppler-shifted harmonics)
C              (Note: need to keep at most 20 terms in the 
C                     non-relativistic dielectric tensor elements;
C                     accuracy issues for higher harmonic terms)
C             June 24, 2003
C              (added polarization subroutine for diffusion
C               coefficient calculations)
C             July 27, 2003
C             (extended to arbitrary number of roots -- use the
C              n_rts to change the number of roots in various
C              routines)
C             September 19, 2003
C              (extended evaluation of polarizations to the
C               relativistic dispersion tensor)
C             September 23, 2003
C              (the number of terms to be kept in nonrelativistic
C               tensor element sums is now an input parameter)
C              (Note: sometimes to follow the EBW near the resonance
C                     may need 150 or so elements instead of the 20
C                     mentioned above.)
C              (zeroed small elements in the polarization vector)
C             October 10, 2003
C              (added non-relativistic power flow/ power dissipated
C               routines including solving the hermitian dispersion
C               tensor for roots)
C              (note: in the routine for solving the hermitian 
C                     tensor one can change the number of intervals
C                     in which to search for roots, and the range 
C                     over which to solve for the roots)
C                     (finished and tested October 14, 2003)
C
C---------------------------------------------------------------------
C
C
      implicit double precision (a-h, o-z)
C
      parameter (n_rts=10)
C
      double precision guesr(n_rts),guesi(n_rts)
C
    character*20 tokamak,tokparam
    integer l_tokamak
C
      common /para1/ w0
      common /para2/ npos
      common /para4/ den0,bt0,te0
      common /para5/ wpe0,wce0,vte0
C
      common /nrels/ nr_nterms
C
      common /trub0/ ktrub
      common /trub1/ xi_lo,dxi,nxi
      common /trub2/ diff_err,navg
      common /trerr/ errabs0,errrel0,irule0
C
      common /ppara/ p_para_min,p_para_max
      common /pperp/ p_perp_min,p_perp_max
      common /weerr/ errabs1,errrel1,irule1
C
      common /nrts1/ knr,nrt_nr,nrt_fr,tol_ht,nd_ht
C
      common /chck1/ kparam
      common /chck2/ cnpa_in,cnpa_fi,n_cnpa
      common /chck3/ omega_in,omega_fi,n_omega
      common /chck4/ alpha_in,alpha_fi,n_alpha
C
      common /rterr/ errt_abs,errt_rel,it_max
C
      common /wave0/ cnpa
C
      common /guinp/ guesr,guesi,kgues
C
      common /prnt/  kpr
C
C   Simulation parameters
C
    open(20,file='simparam.m')
C
C   Code parameters
C
      open(22,file='codeparam.m')
C
C....  output non-relativistic and relativistic roots .....
C....... (data output is the local position and all the roots) .......
C.... (kparam = 1: local cnpa, omega, or alpha and all the roots) ....
C
      open(5,file='nr1.m',status='replace')
      open(8,file='r1.m',status='replace')
C
C........ the non-relativistic and relativistic polarizations ........
C..... polarizations are w.r.t. E_x and output as E_+, E_-, E_z ......
C.. the first element is either the position, cnpa, omega, or alpha ..
C...... the second/third elements are cnpe -- the complex root .......
C......... the other elements are the complex polarizations ..........
C
      open(4,file='pn.m',status='replace')
      open(2,file='pr.m',status='replace')
C
C..... output file containing information on elements and roots ......
C
      open(6,file='d1.m',status='replace')
C
C... output file containing local plasma parameters with position ....
C......... position, wpe, wce, wuh, 1/wce, vte, bt, den, te ..........
C
      open(7,file='p1.m',status='replace')
C
C...... output file containing all the run-time error messages .......
C
      open(9,file='errmsg1',status='replace')
C
C....... output file for checking various parts of the program .......
C.................... (presently not being used) .....................
C
      open(10,file='out1',status='replace')
C
C
C........ controlling whether solving the dispersion relation ........
C.......... in the conventional form (i.e. along x) or as a ..........
C.............. function of n_parallel, omega, or alpha ..............
C
C........ if knp = 0 ==> cnpa is actually k_para in cm**(-1) .........
C...... if knp = 1 ==> cnpa is normalized; cnpa = (c*k_para/w) .......
C...... (NOTE: knp is used only for the conventional d.r. form) ......
C....... (NOTE: otherwise, it is assumed that cnpa is n_para) ........
C.............. (omega = w/wce,  alpha = (wpe/wce)**2) ...............
C
C...... kparam = 0 solves the conventional dispersion relation .......
C..... (here the input n_para or k_para is as given in cnpa_in) ......
C..... kparam = 1 solves the d.r. for a range in n_para (param1) .....
C....... (omega and alpha are fixed at omega_in and alpha_in) ........
C..... kparam = 2 solves the d.r. for a range in omega (param2) ......
C....... (n_para and alpha are fixed at cnpa_in and alpha_in) ........
C..... kparam = 3 solves the d.r. for a range in alpha (param3) ......
C....... (n_para and omega are fixed at cnpa_in and omega_in) ........
C...... initial n_para, final n_para, number of steps in n_para ......
C....... initial omega, final omega, number of steps in omega ........
C....... initial alpha, final alpha, number of steps in alpha ........
C.. (NOTE: for kparam.ge.1 the temperature used is te0 given below) ..
C
C...... output file containing power flow and power dissipated .......
C...... (output: input parameter e.g. position, cnpe, sx, pdis) ......
C
      open(11,file='pf.m',status='replace')
C
      namelist /param0/ kparam
      namelist /param1/ knp,cnpa_in,cnpa_fi,n_cnpa
      namelist /param2/ omega_in,omega_fi,n_omega
      namelist /param3/ alpha_in,alpha_fi,n_alpha
C
C............ if kw0 = 0 ==> w0 is the frequency in Hertz ............
C............ if kw0 = 1 ==> w0 is the angular frequency  ............
C
      namelist /para/ kw0
C
C... error limits for root finder and maximum number of iterations ...
C
      namelist /rtfnd/ errt_abs,errt_rel,it_max
C
C............... for the trubnikov integration package ...............
C........... ktrub = 1 uses the trubnikov form of the d.r. ...........
C............. (this is a single time-history integral) ..............
C........... ktrub = 0 uses the momentum  form of the d.r. ...........
C.......... (this is the double integral in momenta space) ...........
C.......... ktrub = 2 gives results for both representation ..........
C.... (NOTE: used only by the rel_chk for checking d.r. elements) ....
C......... the upper and lower limit for the xi-integration ..........
C..... nxi = number of intervals in which this range is divided ......
C.... absolute and relative errors and the rule for integration ......
C.. navg = number of intervals for averaging the integration result ..
C.... diff_err = error tolerance between three of these averages .....
C
      namelist /trint1/ ktrub,xi_lo,xi_hi,nxi
      namelist /trint2/ errabs0,errrel0,irule0
      namelist /trint3/ navg,diff_err
C
C... these are parameters when doing the integration over momenta ....
C.......... minimum and maximum values of parallel momentum ..........
C....... minimum and maximum values of perpendicular momentum ........
C.... (NOTE: p_perp_min has to be equal to or greater than zero) .....
C.... absolute and relative errors and the rule for integration ......
C
      namelist /pint1/ p_para_min,p_para_max,p_perp_min,p_perp_max
      namelist /pint2/ errabs1,errrel1,irule1
C
C......... kpr  = 0 suppresses printing out of various data ..........
C... kcheck = 1 checks the dispersion elements for a given n_perp ....
C... cnpe_r and cnpe_i are the real and imaginary parts of n_perp ....
C
      namelist /pwrit/ kpr,kcheck,cnpe_r,cnpe_i
C
C...... number of normalized radial positions ......
C.............. (NOTE: these are used when kparam = 0) ...............
C
      read (20,*) npos
C
C... knr = 1 solves the non-relativistic disperison relation only ....
C.. knr = 0 solves the fully relativistic dispersion relation also ... 
C..... number of roots to be found in the non-relativistic case ......
C....... number of roots to be found in the relativistic case ........
C
      read (20,*) knr,nrt_nr,nrt_fr,tol_ht,nd_ht 
C
C.......... number of terms to be used in the sums for the ...........
C............ non-relativistic dielectric tensor elements ............
C
    read (20,*) nr_nterms
C
C............ kflag = 1 : these initial guesses are used .............
C....... when solving the non-relativistic dispersion relation .......
C......... (real part in guesr and imaginary part in guesi) ..........
C....... kflag = 0 : these guesses are ignored and the guesses .......
C.... obtained from the approximate dispersion relation are used .....
C
    read (20,*) kgues
C
C............... input guesses of roots if so desired ................
C
      read (20,*) guesr(1:nrt_nr)
      read (20,*) guesi(1:nrt_nr)
C
C.............. reference magnetic field,  ..............
C.............. peak electron temperature, peak density ..............
C............... frequency ...........................................
C........ (NOTE: this te0 is used for all kparam given above) ........
C.... (NOTE: the other parameters are used only when kparam = 0) .....
C
C
    read (20,*) bt0,te0,den0,w0
C
      read (22,param0)
      read (22,param1)
      read (22,param2)
      read (22,param3)
      read (22,para)
      read (22,rtfnd)
      read (22,trint1)
      read (22,trint2)
      read (22,trint3)
      read (22,pint1)
      read (22,pint2)
      read (22,pwrit)
C
      twopi=6.283185307179586476925287
      clight=2.99792458d10
C
C..... getting the angular frequency (if kw0 = 0) in radians/sec .....
C
      if (kparam.eq.0.and.kw0.eq.0) then
        w0=twopi*w0
      end if
C
C...... the integration grid for the trubnikov form (if needed) ......
C
      dxi=(xi_hi-xi_lo)/dfloat(nxi)
      ci=dcmplx(0.d0,1.d0)
C
      if (kcheck.eq.1) then
        call rel_chk(cnpa_in,omega_in,alpha_in,te0,cnpe_r,cnpe_i)
        go to 99
      end if
C
C... solving the dispersion relation for two different conditions ....
C
      if (kparam.eq.0) then
        call rel_disp
      else
        call rel_eff(te0)
      end if
C
   99 continue
C
C
      stop
      end
C
C
C=====================================================================
C
      subroutine rel_chk(cnpa_in,omega_in,alpha_in,te0,cnpe_r,cnpe_i)
C
      implicit double precision (a-h, o-z)
C
      double complex dcmplx,cnpe,ep(6),ci
C
      common /para9/ alpha,omega,vt,besk2
      common /wave0/ cnpa
      common /wave1/ cnpe
      common /nrels/ nr_nterms
      common /trub0/ ktrub
      common /prnt/  kpr
C
      external dbsk0e,dbsk1e,besk_a,umach,erset
C
      cnpa=cnpa_in
      omega=omega_in
      alpha=alpha_in
      vt=4.19396657d7/2.99792458d10*dsqrt(te0)
C
      cnpe=dcmplx(cnpe_r,cnpe_i)
C      
      arg=1./vt**2
      if (arg.lt.50.d0) then
        call umach(-3,9)
        besk2=dbsk0e(arg)-2.*dbsk1e(arg)/arg
        call erset(0,1,1)
      else
        besk2=besk_a(2,arg)
      end if
C
      call d_nr(nr_nterms,cnpe)
C
      if (ktrub.eq.1.or.ktrub.eq.2) then
        call trub(ep)
        write (6,701) ep(1:2)
        write (6,701) ep(3:4)
        write (6,701) ep(5:6)
  701   format(1x,"trub x's = ",4g18.10)
      end if
C
      if (ktrub.eq.0.or.ktrub.eq.2) then
        call weiss(ep)
        write (6,801) ep(1:2)
        write (6,801) ep(3:4)
        write (6,801) ep(5:6)
  801   format(1x,"weiss x's = ",4g18.10)
      end if
C
C
      return
      end
C
C=====================================================================
C
      subroutine rel_disp
C
      implicit double precision (a-h, o-z)
C
      parameter (n_rts=10)
C
      double precision guesr(n_rts),guesi(n_rts)
C
      double complex dcmplx,ci
C
      double complex croots(4)
      double complex rguess(n_rts),roots(n_rts)
      double complex frtgues(n_rts),frt(n_rts)
      double complex rguess_in(n_rts),frtgues_in(n_rts)
C
      common /para1/ w0
      common /para2/ npos
      common /para8/ wp,wc,vte
      common /para9/ alpha,omega,vt,besk2
      common /nrts1/ knr,nrt_nr,nrt_fr,tol_ht,nd_ht
      common /guinp/ guesr,guesi,kgues
      common /prnt/  kpr
C
      ci=dcmplx(0.d0,1.d0)
C
      call prof_in
C
      call pp(r,1)
C
C..... solving for the cold plasma and approximate plasma roots ......
C
      call coldrt(croots)
      call zero_roots(croots,4)
      call app_nr(rguess)
      call zero_roots(rguess,6)
      write (6,401) croots(1:2)
      write (6,401) croots(3:4)
      write (6,402) rguess(1:2)
      write (6,402) rguess(3:4)
      write (6,402) rguess(5:6)
  401 format("cold rt = ",4g18.10)
  402 format("warm rt = ",4g18.10)
C
C........... setting up the initial guesses if so desired ............
C
      if (kgues.eq.1) then
        do 1 i=1,nrt_nr
          rguess(i)=dcmplx(guesr(i),guesi(i))
    1   continue
      end if
C
C......... solving the non-relativistic dispersion relation ..........
C
      call nr_disp(rguess,roots,nrt_nr)
      call zero_roots(roots,nrt_nr)
      write (5,107) r,roots(1:nrt_nr)
      do 21 j=1,nrt_nr
        rguess(j)=roots(j)
        rguess_in(j)=rguess(j)
        write (6,501) r,roots(j)
  501   format(1x,"r, nr-root = ",3g18.10)
        call wave_polar(r,roots(j),0)
   21 continue
      call nr_disp_herm(r,roots,nrt_nr)
C
C........ solving the fully-relativistic dispersion relation .........
C
      if (knr.eq.0) then
        do 31 j=1,nrt_fr
          frtgues(j)=rguess(j)
   31   continue
        call fr_disp(frtgues,frt,nrt_fr)
        call zero_roots(frt,nrt_fr)
        write (8,108) r,frt(1:nrt_fr)
        do 41 j=1,nrt_fr
          frtgues(j)=frt(j)
          frtgues_in(j)=frtgues(j)
          write (6,601) r,frt(j)
  601     format(1x,"r, rel-root = ",3g18.10)
          call wave_polar(r,frt(j),1)
   41   continue
      end if
C
C...... do-loop for calculating the roots at various positions .......
C
      do 3 n=1,npos
C
C.......... reading next position r and the corresponding plasma parameters ..........
C
        call pp(r,1)
C
C......... solving the non-relativistic dispersion relation ..........
C
        call nr_disp(rguess,roots,nrt_nr)
        call zero_roots(roots,nrt_nr)
        write (5,107) r,roots(1:nrt_nr)
        do 22 j=1,nrt_nr
          rguess(j)=roots(j)
          if (n.eq.1.or.kpr.eq.1) write (6,501) r,roots(j)
          call wave_polar(r,roots(j),0)
   22   continue
        call nr_disp_herm(r,roots,nrt_nr)
C
C........ solving the fully-relativistic dispersion relation .........
C
        if (knr.eq.0) then
          call fr_disp(frtgues,frt,nrt_fr)
          call zero_roots(frt,nrt_fr)
          write (8,108) r,frt(1:nrt_fr)
          do 42 j=1,nrt_fr
            frtgues(j)=frt(j)
            if (n.eq.1.or.kpr.eq.1) write (6,601) r,frt(j)
            call wave_polar(r,frt(j),1)
   42     continue
        end if
C
    3 continue
C
    4 continue
C
  107 format(<2*nrt_nr+1>g18.10)
  108 format(<2*nrt_fr+1>g18.10)
C
C
      return
      end
C
C=====================================================================
C
      subroutine rel_eff(te0)
C
      implicit double precision (a-h, o-z)
C
      parameter (n_rts=10)
C
      double precision guesr(n_rts),guesi(n_rts)
C
      double complex dcmplx,ci
C
      double complex croots(4)
      double complex rguess(n_rts),roots(n_rts)
      double complex frtgues(n_rts),frt(n_rts)
C
      common /para9/ alpha,omega,vt,besk2
      common /nrts1/ knr,nrt_nr,nrt_fr,tol_ht,nd_ht
      common /chck1/ kparam
      common /chck2/ cnpa_in,cnpa_fi,n_cnpa
      common /chck3/ omega_in,omega_fi,n_omega
      common /chck4/ alpha_in,alpha_fi,n_alpha
      common /wave0/ cnpa
      common /guinp/ guesr,guesi,kgues
      common /prnt/  kpr
C
      external dbsk0e,dbsk1e,besk_a,umach,erset
C
      clight=2.99792458d10
      ci=dcmplx(0.d0,1.d0)
C
C................ vt is the electron thermal velocity ................
C
      vt=4.19388628d7*dsqrt(te0)/clight
C
C... the modified bessel function in the denominator of integrals ....
C...... (this is multiplied by exp(x) where x is the argument) .......
C
      arg=1./vt**2
      if (arg.lt.50.d0) then
        call umach(-3,9)
        besk2=dbsk0e(arg)-2.*dbsk1e(arg)/arg
        call erset(0,1,1)
      else
        besk2=besk_a(2,arg)
      end if
C
C.... kparam = 1 ==> dispersion solved for different n_para       ....
C....        = 2 ==> dispersion solved for different w0/wce       ....
C....        = 3 ==> dispersion solved for different (wpe/wce)**2 ....
C
      if (kparam.eq.1) then
C
         omega=omega_in
         alpha=alpha_in
C
        if (n_cnpa.eq.1) then
          d_cnpa=0.d0
        else
          d_cnpa=(cnpa_fi-cnpa_in)/dfloat(n_cnpa-1)
        end if
C
        cnpa=cnpa_in-d_cnpa
C
        do 1 i=1,n_cnpa
C
          cnpa=cnpa+d_cnpa
C
          write (6,301) cnpa
  301     format(1x,"cnpa = ",g18.10)
C
C..... solving for the cold plasma and approximate plasma roots ......
C
          if (i.eq.1) then
            call coldrt(croots)
            call zero_roots(croots,4)
            call app_nr(rguess)
            call zero_roots(rguess,6)
            write (6,401) croots(1:2)
            write (6,401) croots(3:4)
            write (6,402) rguess(1:2)
            write (6,402) rguess(3:4)
            write (6,402) rguess(5:6)
  401       format("cold rt = ",4g18.10)
  402       format("warm rt = ",4g18.10)
          end if
C
C........... setting up the initial guesses if so desired ............
C
      if (i.eq.1.and.kgues.eq.1) then
        do 61 ig=1,nrt_nr
          rguess(ig)=dcmplx(guesr(ig),guesi(ig))
   61   continue
      end if
C
C......... solving the non-relativistic dispersion relation ..........
C
          call nr_disp(rguess,roots,nrt_nr)
          call zero_roots(roots,nrt_nr)
          write (5,107) cnpa,roots(1:nrt_nr)
          do 21 j=1,nrt_nr
            rguess(j)=roots(j)
            if (i.eq.1.or.kpr.eq.1) write (6,501) cnpa,roots(j)
  501       format(1x,"cnpa, nr-root = ",3g18.10)
            call wave_polar(cnpa,roots(j),0)
   21     continue
          call nr_disp_herm(cnpa,roots,nrt_nr)
C
          if (knr.eq.1) go to 1
C
C........ solving the fully relativistic dispersion relation .........
C
          if (i.eq.1) then
            do 31 j=1,nrt_fr
              frtgues(j)=rguess(j)
   31        continue
          end if
CC          frtgues(1)=dcmplx(93.76,-0.56e-2)
          call fr_disp(frtgues,frt,nrt_fr)
          call zero_roots(frt,nrt_fr)
          write (8,108) cnpa,frt(1:nrt_fr)
          do 41 j=1,nrt_fr
            frtgues(j)=frt(j)
            if (i.eq.1.or.kpr.eq.1) write (6,601) cnpa,frt(j)
  601       format(1x,"cnpa, rel-root = ",3g18.10)
            call wave_polar(cnpa,frt(j),1)
   41     continue
C
    1   continue
C
      end if
C
C
      if (kparam.eq.2) then
C
         cnpa=cnpa_in
         alpha=alpha_in
C
        if (n_omega.eq.1) then
          d_omega=0.d0
        else
          d_omega=(omega_fi-omega_in)/dfloat(n_omega-1)
        end if
C
        omega=omega_in-d_omega
C
        do 2 i=1,n_omega
C
          omega=omega+d_omega
C
          write (6,302) omega
  302     format(1x,"omega/omega_c = ",g18.10)
C
C..... solving for the cold plasma and approximate plasma roots ......
C
          if (i.eq.1) then
            call coldrt(croots)
            call zero_roots(croots,4)
            call app_nr(rguess)
            call zero_roots(rguess,6)
            write (6,401) croots(1:2)
            write (6,401) croots(3:4)
            write (6,402) rguess(1:2)
            write (6,402) rguess(3:4)
            write (6,402) rguess(5:6)
          end if
C
C........... setting up the initial guesses if so desired ............
C
      if (i.eq.1.and.kgues.eq.1) then
        do 62 ig=1,nrt_nr
          rguess(ig)=dcmplx(guesr(ig),guesi(ig))
   62   continue
      end if
C
C......... solving the non-relativistic dispersion relation ..........
C
          call nr_disp(rguess,roots,nrt_nr)
          call zero_roots(roots,nrt_nr)
          write (5,107) omega,roots(1:nrt_nr)
          do 22 j=1,nrt_nr
            rguess(j)=roots(j)
            if (i.eq.1.or.kpr.eq.1) write (6,502) omega,roots(j)
  502       format(1x,"omega, nr-root = ",3g18.10)
            call wave_polar(omega,roots(j),0)
   22     continue
          call nr_disp_herm(omega,roots,nrt_nr)
C
          if (knr.eq.1) go to 2
C
C........ solving the fully relativistic dispersion relation .........
C
          if (i.eq.1) then
            do 32 j=1,nrt_fr
              frtgues(j)=rguess(j)
   32       continue
          end if
CC          frtgues(1)=dcmplx(93.76,-0.56e-2)
          call fr_disp(frtgues,frt,nrt_fr)
          call zero_roots(frt,nrt_fr)
          write (8,108) omega,frt(1:nrt_fr)
          do 42 j=1,nrt_fr
            frtgues(j)=frt(j)
            if (i.eq.1.or.kpr.eq.1) write (6,602) omega,frt(j)
  602       format(1x,"cnpa, rel-root = ",3g18.10)
            call wave_polar(omega,frt(j),1)
   42     continue
C
    2   continue
C
      end if
C
C
      if (kparam.eq.3) then
C
         cnpa=cnpa_in
         omega=omega_in
C
        if (n_alpha.eq.1) then
          d_alpha=0.d0
        else
          d_alpha=(alpha_fi-alpha_in)/dfloat(n_alpha-1)
        end if
C
        alpha=alpha_in-d_alpha
C
        do 3 i=1,n_alpha
C
          alpha=alpha+d_alpha
C
          write (6,302) alpha
  303     format(1x,"alpha = ",g18.10)
C
C..... solving for the cold plasma and approximate plasma roots ......
C
          if (i.eq.1) then
            call coldrt(croots)
            call zero_roots(croots,4)
            call app_nr(rguess)
            call zero_roots(rguess,6)
            write (6,401) croots(1:2)
            write (6,401) croots(3:4)
            write (6,402) rguess(1:2)
            write (6,402) rguess(3:4)
            write (6,402) rguess(5:6)
          end if
C
C........... setting up the initial guesses if so desired ............
C
      if (i.eq.1.and.kgues.eq.1) then
        do 63 ig=1,nrt_nr
          rguess(ig)=dcmplx(guesr(ig),guesi(ig))
   63   continue
      end if
C
C......... solving the non-relativistic dispersion relation ..........
C
          call nr_disp(rguess,roots,nrt_nr)
          call zero_roots(roots,nrt_nr)
          write (5,107) alpha,roots(1:nrt_nr)
          do 23 j=1,nrt_nr
            rguess(j)=roots(j)
            if (i.eq.1.or.kpr.eq.1) write (6,503) alpha,roots(j)
  503       format(1x,"alpha, nr-root = ",3g18.10)
            call wave_polar(alpha,roots(j),0)
   23    continue
          call nr_disp_herm(alpha,roots,nrt_nr)
C
          if (knr.eq.1) go to 3
C
C........ solving the fully relativistic dispersion relation .........
C
          if (i.eq.1) then
            do 33 j=1,nrt_fr
              frtgues(j)=rguess(j)
   33      continue
          end if
CC          frtgues(1)=dcmplx(93.76,-0.56e-2)
          call fr_disp(frtgues,frt,nrt_fr)
          call zero_roots(frt,nrt_fr)
          write (8,108) alpha,frt(1:nrt_fr)
          do 43 j=1,nrt_fr
            frtgues(j)=frt(j)
            if (i.eq.1.or.kpr.eq.1) write (6,603) alpha,frt(j)
  603       format(1x,"alpha, rel-root = ",3g18.10)
            call wave_polar(alpha,frt(j),1)
   43     continue
C
    3   continue
C
      end if
C
C
  101 format("om, rel-eps = ",3g18.10)
  103 format("------------------------------------------------------")
  104 format("om, nr-eps  = ",3g18.10)
  105 format("om, nr-sin  = ",3g18.10)
  106 format("om, rel-sin = ",3g18.10)
  107 format(<2*nrt_nr+1>g18.10)
  108 format(<2*nrt_fr+1>g18.10)
  201 format("sum/d11,d12 = ",4g18.10)
  202 format("sum/d13,d22 = ",4g18.10)
  203 format("sum/d23,d33 = ",4g18.10)
  204 format("sum/x11,x12 = ",4g18.10)
  205 format("sum/x13,x22 = ",4g18.10)
  206 format("sum/x23,x33 = ",4g18.10)
C
C
      return
      end
C
C=====================================================================
C
C
C---------------------------------------------------------------------
C
C..... initial data for density, magnetic field, and temperature .....
C
      subroutine prof_in
C
      implicit double precision (a-h, o-z)
C
      common /para1/ w0
      common /para2/ npos
      common /para4/ den0,bt0,te0
      common /para5/ wpe0,wce0,vte0
C
      pi=3.141592653589793238462643d0
C
C...... electron plasma and cycloton frequencies at the center .......
C........................ (normalised to w0) .........................
C
      wpe0=5.6414187d4/w0*dsqrt(den0)
      wce0=1.7588103d7/w0*bt0
C
C......... thermal velocity at the center (normalised to c) ..........
C
      vte0=4.19396657d7/2.99792458d10*dsqrt(te0)
C
C
      return
      end
C
C---------------------------------------------------------------------
C
C...... calculating the various plasma parameters at position r ......
C
      subroutine pp(r,kout)
C
      implicit double precision (a-h, o-z)
C
      common /para1/ w0
      common /para4/ den0,bt0,te0
      common /para5/ wpe0,wce0,vte0
      common /para8/ wpe,wce,vte
      common /para9/ alpha,omega,vt,besk2
      common /wave0/ cnpa

C
      external dbsk0e,dbsk1e,besk_a,umach,erset
C
C... distances normalised to plasma radius .....
C.............. profiles for density and magnetic field ..............
C.............. (normalised to their central values) .................
C................ extending into the scrape-off layer ................
C... (in this region the density/temperatures are the edge values) ...
C
    read(20,*) r, te, den, bt, cnpa
C   read(21,*) rcm, tem, denm, qm
C   read(21,*) rcp, tep, denp, qp

C   te = ((rcp - r)*tem + (r - rcm)*tep)/(rcp - rcm)
C   den = ((rcp - r)*denm + (r - rcm)*denp)/(rcp - rcm)
C   q = ((rcp - r)*qm + (r - rcm)*qp)/(rcp - rcm)



C
C      bpol=r/r0/q/(1.+r/r0*cos(theta))
C.......Modified j.d. 9/16/03. Poloidal dependence added for B field 
C      btor=1./(1.+r/r0*cos(theta))

C      bt=dsqrt(bpol**2+btor**2)

C
C....... various frequencies normalised to the wave frequency ........
C
      wpe=wpe0*dsqrt(den)
      wce=wce0*bt
C
C........... alpha is the overdense parameter (wpe/wce)**2 ...........
C
      alpha=(wpe/wce)**2
C
      omega=1.d0/wce
C
C............. electron thermal velocity normalized to c .............
C
      vte=vte0*dsqrt(te)
      vt=vte
C
C.... this is K_2(c**2/vt**2) needed for relativistic Maxwellians ....
C... the modified bessel function in the denominator of integrals ....
C...... (this is multiplied by exp(x) where x is the argument) .......
C
      arg=1./vte**2
      if (arg.lt.50.d0) then
        call umach(-3,9)
        besk2=dbsk0e(arg)-2.*dbsk1e(arg)/arg
        call erset(0,1,1)
      else
        besk2=besk_a(2,arg)
      end if
C
      if (kout.eq.1) then
        write (7,101) r,wpe,wce,dsqrt(wpe**2+wce**2),
     %                1./wce,vte,bt*bt0,den*den0,te*te0
      end if
C
C
  101 format(9g18.10)
C
      return
      end
C
C---------------------------------------------------------------------
C
C... aymptotic form for the modified Bessel function (second kind) ...
C.......... this is for real argument and is exp(x)*K(nu,x) ..........
C
      double precision function besk_a(nu,z)
C
      implicit double precision (a-h,o-z)
C
      double precision mu
C
C.......................... fac=sqrt(pi/2) ...........................
C
      fac=1.253314137315500251207883
C
      mu=dfloat(4*nu**2)
      besk_a=fac/dsqrt(z)*(1.+(mu-1.)/(8.*z)+
     %                        (mu-1.)*(mu-9.)/(128.*z**2)+
     %                        (mu-1.)*(mu-9.)*(mu-25.)/(3072.*z**3))
C
C
      return
      end
C
C---------------------------------------------------------------------
C
C... aymptotic form for the modified Bessel function (second kind) ...
C........ this is for complex argument and is exp(x)*K(nu,x) .........
C
      double complex function cbesk_a(nu,z)
C
      implicit double precision (a-h,o-z)
C
      double precision mu
C
      double complex z,cdsqrt
C
C.......................... fac=sqrt(pi/2) ...........................
C
      fac=1.253314137315500251207883
C
      mu=dfloat(4*nu**2)
      cbesk_a=fac/cdsqrt(z)*(1.+(mu-1.)/(8.*z)+
     %                          (mu-1.)*(mu-9.)/(128.*z**2)+
     %                          (mu-1.)*(mu-9.)*(mu-25.)/(3072.*z**3))
C
C
      return
      end
C
C---------------------------------------------------------------------
C---------------------------------------------------------------------
C
C........ solving the fully relativistic dispersion relation .........
C
      subroutine fr_disp(rguess,roots,nrts)
C
      implicit double precision (a-h,o-z)
C
      parameter (n_rts=10)
C
      integer info(n_rts)
C
      double complex fr_func
      double complex rguess(n_rts),roots(n_rts)
C
      common /rterr/ errt_abs,errt_rel,it_max
      common /prnt/  kpr
C
      external fr_func,dzanly,umach,erset
C
      errabs=errt_abs
      errrel=errt_rel
      itmax=it_max
      nknown=0
      nnew=nrts
      nguess=nrts
C
      call umach(-3,9)
      call dzanly(fr_func,errabs,errrel,nknown,nnew,nguess,
     %            rguess,itmax,roots,info)
      call erset(0,1,1)
C
      call order_roots(roots,nrts)
C
CC      if (kpr.eq.1) then
CC        write (6,101) roots(1:2)
CC        write (6,101) roots(3:4)
CC        write (6,101) roots(5:6)
CC        write (6,101) roots(7:8)
CC      end if
  101 format(1x,"full r-r = ",4g18.10)
C
C
      return
      end
C
C---------------------------------------------------------------------
C
C............ the fully-relativistic dispersion function .............
C
      double complex function fr_func(roots)
C
      implicit double precision (a-h, o-z)
C
      double complex roots,cnpe
      double complex d11,d12,d13,d22,d23,d33
      double complex x11,x12,x13,x22,x23,x33
C
      double complex ep(6)
C
      common /trub0/ ktrub
      common /wave0/ cnpa
      common /wave1/ cnpe
      common /coutd/ d11,d12,d13,d22,d23,d33
C
      cnpe=roots
C
      if (ktrub.eq.1) then
        call trub(ep)
      else
        call weiss(ep)
      end if
C
      x11=ep(1)
      x12=ep(2)
      x13=ep(3)
      x22=ep(4)
      x23=ep(5)
      x33=ep(6)
C
C........ the dielectric tensor elements (satisfying D.E = 0) ........
C
      d11=1.-cnpa**2+x11
      d12=x12
      d13=cnpe*cnpa+x13
      d22=1.-cnpe**2-cnpa**2+x22
      d23=x23
      d33=1.-cnpe**2+x33
C
      fr_func=d11*(d22*d33+d23*d23)+
     %        d12*(d23*d13+d12*d33)+
     %        d13*(d12*d23-d22*d13)
C
C
      return
      end
C
C---------------------------------------------------------------------
C---------------------------------------------------------------------
C
C......... solving the non-relativistic dispersion relation ..........
C
      subroutine nr_disp(rguess,roots,nrts)
C
      implicit double precision (a-h, o-z)
C
      parameter (n_rts=10)
C
      integer info(n_rts)
C
      double complex nr_func
      double complex rguess(n_rts),roots(n_rts)
C
      common /rterr/ errt_abs,errt_rel,it_max
      common /prnt/  kpr
C
      external nr_func,dzanly,umach,erset
C
      errabs=errt_abs
      errrel=errt_rel
      itmax=it_max
      nknown=0
      nnew=nrts
      nguess=nrts
C
      call umach(-3,9)
      call dzanly(nr_func,errabs,errrel,nknown,nnew,nguess,
     %            rguess,itmax,roots,info)
      call erset(0,1,1)
C
      call order_roots(roots,nrts)
C
CC      if (kpr.eq.1) then
CC        write (6,101) roots(1:2)
CC        write (6,101) roots(3:4)
CC        write (6,101) roots(5:6)
CC        write (6,101) roots(7:8)
CC      end if
C
  101 format(1x,"full nr-rts = ",4g18.10)
C
C
      return
      end
C
C---------------------------------------------------------------------
C
C............. the non-relativistic dispersion function ..............
C
      double complex function nr_func(roots)
C
      implicit double precision (a-h, o-z)
C
      double complex roots
      double complex d11,d12,d13,d22,d23,d33
C
      common /nrels/ nr_nterms
      common /coutd/ d11,d12,d13,d22,d23,d33
C
      call d_nr(nr_nterms,roots)
C
      nr_func=d11*(d22*d33+d23*d23)+
     %        d12*(d23*d13+d12*d33)+
     %        d13*(d12*d23-d22*d13)
C
C
      return
      end
C
C---------------------------------------------------------------------
C
C................. non-relativistic tensor elements ..................
C
      subroutine d_nr(nn,cnpe)
C
      implicit double precision (a-h, o-z)
C
      double complex dcmplx,cnpe
      double complex ci,scmu,cmu
      double complex x11,x12,x13,x22,x23,x33
      double complex d11,d12,d13,d22,d23,d33
C
      double complex cbi(0:1000),dcbi(0:1000)
      double complex zm(0:1000),zp(0:1000)
      double complex zargm(0:1000),zargp(0:1000)
      double complex csum(6)
C
      common /para9/ alpha,omega,vt,besk2
      common /coutd/ d11,d12,d13,d22,d23,d33
      common /coutx/ x11,x12,x13,x22,x23,x33
      common /wave0/ cnpa
      common /prnt/  kpr
C
      ci=dcmplx(0.d0,1.d0)
C
C.. scmu is the sqrt (cmu) (defined to take care of sign of k_perp) ..
C.............. cmu = (k_perp * v_te)**2 / omega_ce**2 ...............
C............ cy0 = omega / ( sqrt(2)*abs(k_para)*v_te ) .............
C
      scmu=cnpe*vt*omega
      cmu=scmu**2
      cy0=1./(dsqrt(2.d0)*dabs(cnpa)*vt)
C
C.......... arguments of the z-functions in the summations ...........
C
      do 1 n=0,nn
        zargm(n)=dcmplx(cy0*(1.-dfloat(n)/omega),0.d0)
        zargp(n)=dcmplx(cy0*(1.+dfloat(n)/omega),0.d0)
    1 continue
C
      call ebes(nn,cmu,cbi,dcbi)
C
      call pdisp(nn,zargm,zargp,zm,zp)
C
      csum(1)=dcmplx(0.d0,0.d0)
      csum(2)=dcmplx(0.d0,0.d0)
      csum(3)=dcmplx(0.d0,0.d0)
      csum(4)=2.*(cbi(0)-dcbi(0))*zp(0)
      csum(5)=zargp(0)*zp(0)*(dcbi(0)-cbi(0))
      csum(6)=zargp(0)*(1.d0+cbi(0)*zargp(0)*zp(0))
C
      do 2 n=1,nn
C
        csum(1)=csum(1)+
     %          dfloat(n**2)*cbi(n)*(zp(n)+zm(n))
        csum(2)=csum(2)+
     %          dfloat(n)*(dcbi(n)-cbi(n))*(zm(n)-zp(n))
        csum(3)=csum(3)+
     %          dfloat(n)*cbi(n)*(zargm(n)*zm(n)-
     %                            zargp(n)*zp(n))
        csum(4)=csum(4)+
     %          ((2.+dfloat(n**2)/cmu**2)*cbi(n)-2.*dcbi(n))*
     %          (zp(n)+zm(n))
        csum(5)=csum(5)+
     %          (dcbi(n)-cbi(n))*(zargp(n)*zp(n)+zargm(n)*zm(n))
        csum(6)=csum(6)+
     %          cbi(n)*(zargp(n)**2*zp(n)+zargm(n)**2*zm(n))
C
    2 continue
C
C.......................... sign of k_para ...........................
C
      sk=cnpa/(dabs(cnpa))
C
      fac=alpha/omega**2
C
      x11=fac*cy0/cmu*csum(1)
      x12=-ci*fac*cy0*csum(2)
      x13=sk*fac*dsqrt(2.d0)/scmu*cy0*csum(3)
      x22=fac*cmu*cy0*csum(4)
      x23=ci*sk*fac*dsqrt(2.d0)*scmu*cy0*csum(5)
      x33=2.*fac*cy0*csum(6)
C
      if (kpr.eq.1) then
        write (6,601) x11,x12
        write (6,601) x13,x22
        write (6,601) x23,x33
  601   format("non-rel x's = ",4g18.10)
      end if
C
C........ the dielectric tensor elements (satisfying D.E = 0) ........
C
      d11=1.-cnpa**2+x11
      d12=x12
      d13=cnpe*cnpa+x13
      d22=1.-cnpe**2-cnpa**2+x22
      d23=x23
      d33=1.-cnpe**2+x33
C
C
      return
      end
C
C---------------------------------------------------------------------
C
C....... evaluating the Bessel functions and their derivatives .......
C
      subroutine ebes(n,carg,cbi,dcbi)
C
      implicit double precision (a-h, o-z)
C
      double complex cdexp
      double complex carg,factor
C
      double complex cbi(0:1000),dcbi(0:1000)
C
      external dcbis
C
      xnu=0.
      numb=n+2
C
C............... evaluating the bessel function itself ...............
C
      call dcbis(xnu,carg,numb,cbi)
C
C......... calculating the derivates of the bessel functions .........
C
      dcbi(0)=cbi(1)
      do 1 i=1,numb-1
        dcbi(i)=0.5*(cbi(i-1)+cbi(i+1))
    1 continue
C
C.............. multiplying by exp(-mu_e) for the sums ...............
C
      factor=cdexp(-carg)
      do 2 i=0,numb-1
        cbi(i)=cbi(i)*factor
        dcbi(i)=dcbi(i)*factor
    2 continue
C
C
      return
      end
C
C---------------------------------------------------------------------
C
C............ calculating the plasma dispersion functions ............
C
      subroutine pdisp(nar,cargm,cargp,zm,zp)
C
      implicit double precision (a-h, o-z)
C
      double complex dcmplx
      double complex carg,csqpi,zerfe
C
      double complex cargm(0:1000),cargp(0:1000)
      double complex zm(0:1000),zp(0:1000)
C
      external zerfe
C
      sqpi=1.772453850905516027298167d0
        pi=3.141592653589793238462643d0
C
      csqpi=dcmplx(0.d0,sqpi)
C     
      do 1 i=0,nar
        zm(i)=csqpi*zerfe(cargm(i))
        zp(i)=csqpi*zerfe(cargp(i))
    1 continue
C
C
        return
        end
C
C---------------------------------------------------------------------
C---------------------------------------------------------------------
C
C................. calculating the cold plasma roots .................
C
      subroutine coldrt(croots)
C
      implicit double precision (a-h, o-z)
C
      double complex dcmplx,cdsqrt,sc,s2,cdummy
      double complex cnpe
C
      double complex cr(2),croots(4)
C
      common /para9/ alpha,omega,vt,besk2
      common /wave0/ cnpa
      common /wave1/ cnpe
C
C..................... the stix tensor elements ......................
C
      sx=1.-alpha/(omega**2-1.)
      sy=-alpha/(omega*(omega**2-1.))
      sz=1.-alpha/omega**2
C
      s1=0.5*(sx+sz-cnpa**2)-0.5*(cnpa**2*sz+sy**2)/sx
      sdummy=((cnpa**2-sx)*(sx-sz)+sy**2)**2+
     %         4.*cnpa**2*sy**2*sz
      sc=dcmplx(sdummy,0.d0)
      s2=0.5*cdsqrt(sc)/sx
C
      cr(1)=s1+s2
      cr(2)=s1-s2
C
C...... this orders the roots in terms of their absolute values ......
C
      if (cdabs(cr(1)).gt.cdabs(cr(2))) then
        cdummy=cr(1)
        cr(1)=cr(2)
        cr(2)=cdummy
      end if
C
C.................. and now all the roots of n-perp ..................
C... roots(1) and (2) are for fast wave; (3) and (4) for slow wave ...
C
      croots(1)= cdsqrt(cr(1))
      croots(2)=-croots(1)
      croots(3)= cdsqrt(cr(2))
      croots(4)=-croots(3)
C
      return
      end
C
C---------------------------------------------------------------------
C
C......... approximate non-relativistic dispersion equation ..........
C
      subroutine app_nr(roots)
C
      implicit double precision (a-h, o-z)
C
C......... this is the order of the polynomial to be solved ..........
C....... (should be set to at least 3 and can be 4 if desired) .......
C
      parameter (n_order=3)
C
      double complex dcmplx,ci,cdsqrt,zero
      double complex cnpe
C
      double complex zm(0:1000),zp(0:1000)
      double complex zargm(0:1000),zargp(0:1000)
      double complex xi(0:5),be(0:5)
      double complex ga(0:5),de(0:5),ph(0:5)
      double complex d11(0:8),d12(0:8),d13(0:8)
      double complex d22(0:8),d23(0:8),d33(0:8)
      double complex x11(0:8),x12(0:8),x13(0:8)
      double complex x22(0:8),x23(0:8),x33(0:8)
      double complex co(0:4),coo(0:n_order)
      double complex rts(n_order),roots(8)
C
      common /para9/ alpha,omega,vt,besk2
      common /wave0/ cnpa
      common /wave1/ cnpe
C
      external dzpocc,umach,erset
C
      ci=dcmplx(0.d0,1.d0)
C
C.. scmu is the sqrt (cmu) (defined to take care of sign of k_perp) ..
C............ cmu = (v_te / c)**2 / (omega_ce / omega)**2 ............
C............ cy0 = omega / ( sqrt(2)*abs(k_para)*v_te ) .............
C
      scmu=vt*omega
      cmu=scmu**2
      cy0=1./(dsqrt(2.d0)*dabs(cnpa)*vt)
C
C.......................... sign of k_para ...........................
C
      sk=cnpa/(dabs(cnpa))
C
C.......... arguments of the z-functions in the summations ...........
C
      do 1 n=0,6
        zargm(n)=dcmplx(cy0*(1.-dfloat(n)/omega),0.d0)
        zargp(n)=dcmplx(cy0*(1.+dfloat(n)/omega),0.d0)
    1 continue
C
      nn=7
      call pdisp(nn,zargm,zargp,zm,zp)
C
      do 2 n=0,5
        be(n)=zm(n)-zp(n)
        ga(n)=zargm(n)*zm(n)-zargp(n)*zp(n)
        if (n.eq.0) then
          xi(0)=zm(0)
          de(0)=zargm(0)*zm(0)
          ph(0)=zargm(0)**2*zm(0)
        else
          xi(n)=zm(n)+zp(n)
          de(n)=zargm(n)*zm(n)+zargp(n)*zp(n)
          ph(n)=zargm(n)**2*zm(n)+zargp(n)**2*zp(n)
        end if
    2 continue
C
      zero=dcmplx(0.d0,0.d0)
      do 3 i=0,8
        d11(i)=zero
        d12(i)=zero
        d13(i)=zero
        d22(i)=zero
        d23(i)=zero
        d33(i)=zero
        x11(i)=zero
        x12(i)=zero
        x13(i)=zero
        x22(i)=zero
        x23(i)=zero
        x33(i)=zero
    3 continue
C
      d11(0)=1.-cnpa**2
      d13(1)=cnpa
      d22(0)=1.-cnpa**2
      d22(2)=-1.
      d33(0)=1.
      d33(2)=-1.
C
      x11(0)=xi(1)
      x11(2)=cmu*(-xi(1)+xi(2))
      x11(4)=cmu**2*(0.625*xi(1)-xi(2)+0.375*xi(3))
      x11(6)=cmu**3/24.*(-7.*xi(1)+14.*xi(2)-
     %                    9.*xi(3)+2.*xi(4))
      x11(8)=cmu**4/384.*(42.*xi(1)-96.*xi(2)+81.*xi(3)-
     %                     32.*xi(4)+5.*xi(5))
C
C........ this is i*D_12 (or D_12-bar) as set up in the notes ........
C
      x12(0)=be(1)
      x12(2)=cmu*(-2.*be(1)+be(2))
      x12(4)=cmu**2*(1.875*be(1)-1.5*be(2)+0.375*be(3))
      x12(6)=cmu**3/12.*(-14.*be(1)+14.*be(2)-6.*be(3)+be(4))
      x12(8)=cmu**4/384.*(210.*be(1)-240.*be(2)+125.*be(3)-
     %                        40.*be(4)+5.*be(5))
C
      cdum=sk*scmu*dsqrt(2.d0)
      x13(1)=cdum*ga(1)
      x13(3)=cdum*cmu*(-ga(1)+0.5*ga(2))
      x13(5)=cdum*cmu**2*0.125*(5.*ga(1)-4.*ga(2)+ga(3))
      x13(7)=cdum*cmu**3/48.*(-14.*ga(1)+14.*ga(2)-
     %                         6.*ga(3)+ga(4))
C
      x22(0)=xi(1)
      x22(2)=cmu*(4.*xi(0)-3.*xi(1)+xi(2))
      x22(4)=cmu**2*(-6.*xi(0)+4.625*xi(1)-
     %                2.*xi(2)+0.375*xi(3))
      x22(6)=cmu**3*(120.*xi(0)-97.*xi(1)+50.*xi(2)-
     %               15.*xi(3)+2.*xi(4))
      x22(8)=cmu**4/384.*(-560.*xi(0)+938.*xi(1)-544.*xi(2)+
     %                     209.*xi(3)-48.*xi(4)+5.*xi(5))
C
C
C........ this is i*D_23 (or D_23-bar) as set up in the notes ........
C
      cdum=-sk*dsqrt(2.d0)*scmu
      x23(1)=cdum*(-2.*de(0)+de(1))
      x23(3)=cdum*cmu*(3.*de(0)-2.*de(1)+0.5*de(2))
      x23(5)=cdum*cmu**2*(-2.5*de(0)+1.875*de(1)-
     %                    0.75*de(2)+0.125*de(3))
      x23(7)=cdum*cmu**3/48.*(70.*de(0)-56.*de(1)+28.*de(2)-
     %                        8.*de(3)+de(4))
C
      x33(0)=4.*(cy0+ph(0))
      x33(2)=cmu*2.*(-2.*ph(0)+ph(1))
      x33(4)=cmu**2*(3.*ph(0)-2.*ph(1)+0.5*ph(2))
      x33(6)=cmu**3/12.*(-20.*ph(0)+15.*ph(1)-
     %                    6.*ph(2)+ph(3))
      x33(8)=cmu**4/96.*(70.*ph(0)-56.*ph(1)+28.*ph(2)-
     %                    8.*ph(3)+ph(4))
C
      fac=0.5*alpha/omega**2*cy0
C
      do 4 i=0,8
        x11(i)=fac*x11(i)
        x12(i)=fac*x12(i)
        x13(i)=fac*x13(i)
        x22(i)=fac*x22(i)
        x23(i)=fac*x23(i)
        x33(i)=fac*x33(i)
    4 continue
C
      do 5 i=0,8
        d11(i)=d11(i)+x11(i)
        d12(i)=d12(i)+x12(i)
        d13(i)=d13(i)+x13(i)
        d22(i)=d22(i)+x22(i)
        d23(i)=d23(i)+x23(i)
        d33(i)=d33(i)+x33(i)
    5 continue
C
C.... the coefficients of (n-perp)**2 in the dispersion function .....
C........ disp-fn = co(0)+co(1)*(n-perp)**2+co(2)*(n-perp)**4 ........
C.......             + co(3)*(n-perp)**6+co(4)*(n-perp)**8    ........
C............ the co(i)'s were dertermined using macsyma .............
C
      co(0) = d11(0)*d22(0)*d33(0)-d12(0)**2*d33(0)
C
      co(1) = d11(0)*d22(0)*d33(2)-d12(0)**2*d33(2)+
     %        d11(0)*d33(0)*d22(2)-2.*d12(0)*d33(0)*d12(2)+
     %        d22(0)*d33(0)*d11(2)-d11(0)*d23(1)**2-
     %        2.*d12(0)*d13(1)*d23(1)-d22(0)*d13(1)**2
C
      co(2) = d11(0)*d22(0)*d33(4)-d12(0)**2*d33(4)+
     %        d11(0)*d33(0)*d22(4)-2.*d12(0)*d33(0)*d12(4)+
     %        d22(0)*d33(0)*d11(4)-2.*d11(0)*d23(1)*d23(3)-
     %        2.*d12(0)*d13(1)*d23(3)-2.*d12(0)*d23(1)*d13(3)-
     %        2.*d22(0)*d13(1)*d13(3)+d11(0)*d22(2)*d33(2)-
     %        2.*d12(0)*d12(2)*d33(2)+d22(0)*d11(2)*d33(2)+
     %        d33(0)*d11(2)*d22(2)-d13(1)**2*d22(2)-
     %        d33(0)*d12(2)**2-2.*d13(1)*d23(1)*d12(2)-
     %        d23(1)**2*d11(2)
C
      co(3) = d11(0)*d22(0)*d33(6)-d12(0)**2*d33(6)+
     %        d11(0)*d33(0)*d22(6)-2.*d12(0)*d33(0)*d12(6)+
     %        d22(0)*d33(0)*d11(6)-2.*d11(0)*d23(1)*d23(5)-
     %        2.*d12(0)*d13(1)*d23(5)-2.*d12(0)*d23(1)*d13(5)-
     %        2.*d22(0)*d13(1)*d13(5)+d11(0)*d22(2)*d33(4)-
     %        2.*d12(0)*d12(2)*d33(4)+d22(0)*d11(2)*d33(4)+
     %        d11(0)*d33(2)*d22(4)+d33(0)*d11(2)*d22(4)-
     %        d13(1)**2*d22(4)-2.*d12(0)*d33(2)*d12(4)-
     %        2.*d33(0)*d12(2)*d12(4)-2.*d13(1)*d23(1)*d12(4)+
     %        d22(0)*d33(2)*d11(4)+d33(0)*d22(2)*d11(4)-
     %        d23(1)**2*d11(4)-d11(0)*d23(3)**2-
     %        2.*d12(0)*d13(3)*d23(3)-2.*d13(1)*d12(2)*d23(3)-
     %        2.*d23(1)*d11(2)*d23(3)-d22(0)*d13(3)**2-
     %        2.*d13(1)*d22(2)*d13(3)-2.*d23(1)*d12(2)*d13(3)+
     %        d11(2)*d22(2)*d33(2)-d12(2)**2*d33(2)
C
      co(4) = d11(0)*d22(0)*d33(8)-d12(0)**2*d33(8)+
     %        d11(0)*d33(0)*d22(8)-2.*d12(0)*d33(0)*d12(8)+
     %        d22(0)*d33(0)*d11(8)-2.*d11(0)*d23(1)*d23(7)-
     %        2.*d12(0)*d13(1)*d23(7)-2.*d12(0)*d23(1)*d13(7)-
     %        2.*d22(0)*d13(1)*d13(7)+d11(0)*d22(2)*d33(6)-
     %        2.*d12(0)*d12(2)*d33(6)+d22(0)*d11(2)*d33(6)+
     %        d11(0)*d33(2)*d22(6)+d33(0)*d11(2)*d22(6)-
     %        d13(1)**2*d22(6)-2.*d12(0)*d33(2)*d12(6)-
     %        2.*d33(0)*d12(2)*d12(6)-2.*d13(1)*d23(1)*d12(6)+
     %        d22(0)*d33(2)*d11(6)+d33(0)*d22(2)*d11(6)-
     %        d23(1)**2*d11(6)-2.*d11(0)*d23(3)*d23(5)-
     %        2.*d12(0)*d13(3)*d23(5)-2.*d13(1)*d12(2)*d23(5)-
     %        2.*d23(1)*d11(2)*d23(5)-2.*d12(0)*d23(3)*d13(5)-
     %        2.*d22(0)*d13(3)*d13(5)-2.*d13(1)*d22(2)*d13(5)-
     %        2.*d23(1)*d12(2)*d13(5)+d11(0)*d22(4)*d33(4)-
     %        2.*d12(0)*d12(4)*d33(4)+d22(0)*d11(4)*d33(4)+
     %        d11(2)*d22(2)*d33(4)-d12(2)**2*d33(4)+
     %        d33(0)*d11(4)*d22(4)-2.*d13(1)*d13(3)*d22(4)+
     %        d11(2)*d33(2)*d22(4)-d33(0)*d12(4)**2-
     %        2.*d13(1)*d23(3)*d12(4)-2.*d23(1)*d13(3)*d12(4)-
     %        2.*d12(2)*d33(2)*d12(4)-2.*d23(1)*d23(3)*d11(4)+
     %        d22(2)*d33(2)*d11(4)-d11(2)*d23(3)**2-
     %        2.*d12(2)*d13(3)*d23(3)-d22(2)*d13(3)**2
C
      do 6 i=0,n_order
        coo(i)=co(i)
    6 continue
C
      ndeg=n_order
      call umach(-3,9)
      call dzpocc(ndeg,coo,rts)
      call erset(0,1,1)
C
      do 7 i=1,n_order
        roots(2*i-1)=cdsqrt(rts(i))
        roots(2*i)=-roots(2*i-1)
    7 continue
C
C
      return
      end
C
C---------------------------------------------------------------------
C---------------------------------------------------------------------
C
C......... this is for zeroing out components that are small .........
C
      subroutine zero_roots(roots,nrt0)
C
      implicit double precision (a-h, o-z)
C
      parameter (n_rts=10)
C
      double complex dcmplx
C
      double complex roots(n_rts)
C
      do 1 i=1,nrt0
        if (dabs(dreal(roots(i))).lt.1.0d-15) 
     %      roots(i)=dcmplx(0.d0,dimag(roots(i)))
        if (dabs(dimag(roots(i))).lt.1.0d-15) 
     %      roots(i)=dcmplx(dreal(roots(i)),0.d0)
    1 continue
C
C
      return
      end
C
C---------------------------------------------------------------------
C
C........... calculating polarizations with respect to E_x ...........
C
      subroutine wave_polar(data,cnpe,kfl_fr)
C
      implicit double precision (a-h, o-z)
C
      double complex dcmplx,ci,cnpe,cdummy
      double complex d11,d12,d13,d22,d23,d33
      double complex ey,ez
      double complex pol_p,pol_m,pol_z
C
      double complex nr_func,fr_func
C
      double complex det(3),pdum(3)
C
      common /wave0/ cnpa
      common /coutd/ d11,d12,d13,d22,d23,d33
C
      external nr_func,fr_func
C
      ci=dcmplx(0.d0,1.d0)
C
      if (kfl_fr.eq.0) cdummy=nr_func(cnpe)
      if (kfl_fr.eq.1) cdummy=fr_func(cnpe)
C
      det(1)=-d12*d23-d13*d22
      det(2)= d22*d33-d23*d23
      det(3)= d12*d33+d13*d23
C
      if (cdabs(det(1)).gt.cdabs(det(2))) then
        if (cdabs(det(1)).gt.cdabs(det(3))) then
          nn=1
        else
          nn=3
        end if
      else
        if (cdabs(det(2)).gt.cdabs(det(3))) then
          nn=2
        else
          nn=3
        end if
      end if
C
      if (nn.eq.1) then
        ey=(d11*d23-d13*d12)/det(1)
        ez=(d12*d12+d11*d22)/det(1)
      end if
      if (nn.eq.2) then
        ey=(d12*d33-d13*d23)/det(2) 
        ez=(d12*d23-d13*d22)/det(2)
      end if
      if (nn.eq.3) then
        ey= (d13*d13-d11*d33)/det(3)
        ez=-(d12*d13+d11*d23)/det(3)
      end if
C
C....... zeroing out the small components of the polarizations .......
C
      pdum(1)=(1.d0+ci*ey)/dsqrt(2.d0)
      pdum(2)=(1.d0-ci*ey)/dsqrt(2.d0)
      pdum(3)=ez
C
      do 1 i=1,3
        if (dabs(dreal(pdum(i))).lt.1.0d-15) 
     %      pdum(i)=dcmplx(0.d0,dimag(pdum(i)))
        if (dabs(dimag(pdum(i))).lt.1.0d-15) 
     %      pdum(i)=dcmplx(dreal(pdum(i)),0.d0)
    1 continue
C
      pol_p=pdum(1)
      pol_m=pdum(2)
      pol_z=pdum(3)
C
      if (kfl_fr.eq.0) 
     %  write (4,101) data,cnpe,pol_p,pol_m,pol_z
      if (kfl_fr.eq.1) 
     %  write (2,101) data,cnpe,pol_p,pol_m,pol_z
C
  101 format(9g18.10)
C
C
      return
      end
C
C---------------------------------------------------------------------
C---------------------------------------------------------------------
C
C......  ordering the roots found from the dispersion relation .......
C
      subroutine order_roots(roots,nrt0)
C
      implicit double precision (a-h, o-z)
C
      parameter (n_rts=10)
C
      double complex cdummy,ctemp
C
      double complex roots(n_rts)
C
C... arranging the real and imaginary parts in terms of magnitude ....
C... values decrease from highest positive to the lowest negative ....
C
      do 1 i=1,nrt0
        cdummy=roots(i)
        do 2 j=i+1,nrt0
          if (dreal(roots(j)).gt.dreal(cdummy)) then
            ctemp=roots(j)
            roots(j)=cdummy
            cdummy=ctemp
          end if
          if (dreal(roots(j)).eq.dreal(cdummy)) then
            if (dimag(roots(j)).eq.dimag(cdummy)) then
              ctemp=roots(j)
              roots(j)=cdummy
              cdummy=ctemp
            end if
          end if
    2   continue
        roots(i)=cdummy
    1 continue
C
      call zero_roots(roots,nrt0)
C
C
      return
      end
C
C---------------------------------------------------------------------
C---------------------------------------------------------------------
C
C..... evaluating the trubnikov form of the relativistic tensor ......
C
      subroutine trub(epsilon)
C
      implicit double precision (a-h, o-z)
C
      double precision stot(3),sumr(0:1000)
C
      double complex dcmplx,csum
C
      double complex epsilon(6),co(0:1)
C
      common /trub1/ xi_lo,dxi,nxi
      common /trub2/ diff_err,navg
      common /trerr/ errabs0,errrel0,irule0
      common /trubc/ kel,kreal
      common /prnt/  kpr
C
      external dqdag,ftrub,umach,erset
C
      co(0)=dcmplx(0.d0,1.d0)
      co(1)=dcmplx(1.d0,0.d0)
C
      do 1 j=1,6
        kel=j
        csum=dcmplx(0.d0,0.d0)
C
        do 2 k=0,1
          kreal=k
C
C.. ntr keeps track of the number of averages (3) that are compared ..
C
          ntr=0
C
          xi_0=xi_lo
          xi_1=xi_0+dxi
C
          sum=0.d0
C
          do 3 i=1,nxi
C
            errabs=errabs0
            errrel=errrel0
            irule=irule0
C
            call umach(-3,9)
            call dqdag(ftrub,xi_0,xi_1,errabs,errrel,irule,
     %                 t_real,errest)
            call erset(0,1,1)
C
            sum=sum+t_real
C
            jj=mod(i-1,navg)
            sumr(jj)=sum
            if (jj.eq.navg-1) then
              ntr=ntr+1
              stot(ntr)=0.d0
              do 4 ij=0,navg-1
                stot(ntr)=stot(ntr)+sumr(ij)
    4         continue
              stot(ntr)=stot(ntr)/dfloat(navg)
              if (ntr.eq.3) then
                diff1=dabs(dabs(stot(1))-dabs(stot(2)))
                diff2=dabs(dabs(stot(2))-dabs(stot(3)))
                if (diff1.lt.diff_err.and.diff2.lt.diff_err) then
                  sum_real=stot(3)
                  go to 5
                else
                  stot(1)=stot(2)
                  stot(2)=stot(3)
                  ntr=2
                end if
              end if
            end if
C
            xi_0=xi_1
            xi_1=xi_0+dxi
C
    3     continue
C
    5     continue
C
          if (kpr.eq.1) then
            if (kreal.eq.0) then
              write (6,201) i,sum
  201         format("imag integral used ",i9,
     %               "steps to get ",g18.10)
            else
              write (6,202) i,sum
  202         format("real integral used ",i9,
     %               "steps to get ",g18.10)
            end if
          end if
C
          csum=csum+co(k)*sum
    2   continue
C
        epsilon(kel)=csum
C
    1 continue
C
C
      return
      end
C
C---------------------------------------------------------------------
C
      double precision function ftrub(xi)
C
      implicit double precision (a-h, o-z)
C
      double complex dcmplx,ci,factor
      double complex tx_11,tx_12,tx_13
      double complex tx_22,tx_23,tx_33
C
      common /para9/ alpha,omega,vt,besk2
      common /trubc/ kel,kreal
C
      external tx_11,tx_12,tx_13
      external tx_22,tx_23,tx_33
C
      ci=dcmplx(0.d0,1.d0)
C
C...... factor is the multiplier in the dielectric tensor form .......
C.............. factor = i * {(wpe/wce)**2} * (wce/w0) ...............
C
      factor=ci*alpha/omega
C
      if (kreal.eq.0) then
        if (kel.eq.1) ftrub=dimag(factor*tx_11(xi))
        if (kel.eq.2) ftrub=dimag(factor*tx_12(xi))
        if (kel.eq.3) ftrub=dimag(factor*tx_13(xi))
        if (kel.eq.4) ftrub=dimag(factor*tx_22(xi))
        if (kel.eq.5) ftrub=dimag(factor*tx_23(xi))
        if (kel.eq.6) ftrub=dimag(factor*tx_33(xi))
      else
        if (kel.eq.1) ftrub=dreal(factor*tx_11(xi))
        if (kel.eq.2) ftrub=dreal(factor*tx_12(xi))
        if (kel.eq.3) ftrub=dreal(factor*tx_13(xi))
        if (kel.eq.4) ftrub=dreal(factor*tx_22(xi))
        if (kel.eq.5) ftrub=dreal(factor*tx_23(xi))
        if (kel.eq.6) ftrub=dreal(factor*tx_33(xi))
      end if
C
C
      return
      end
C
C---------------------------------------------------------------------
C
      double complex function tx_11(xi)
C
      implicit double precision (a-h, o-z)
C
      double complex dcmplx,cdexp,cdsqrt
      double complex cnpe
      double complex ci,r,sr,t2
      double complex ck2,ck3,factor
      double complex ce,cfac,cbesk_a
C
      double complex ckbs(2)
C
      common /para9/ alpha,omega,vt,besk2
      common /wave0/ cnpa
      common /wave1/ cnpe
C
      external dcbks,umach,erset
C
      ci=dcmplx(0.d0,1.d0)
C
      twopi=6.283185307179586476925287
      xim=dmod(xi,twopi)
C
C... r is the actual r multiplied by (vte/c)**4 and K_2({c/vt}**2) ...
C.... this takes care of the normalization factors in the tensor .....
C... sr is the square-root of r (argument of the Bessel functions) ...
C............ dom = omega*(vte/c)**2 = (w/wce)*(vte/c)**2 ............
C
      dom=omega*vt**2
      r=(1.-ci*xi*dom)**2+2.*(cnpe*dom)**2*(1.-dcos(xim))+
     %  (cnpa*dom*xi)**2
CC      r=(1./vt**2-ci*xi*omega)**2+
CC     %  2.*(cnpe*omega)**2*(1.-dcos(xim))+
CC     %  (cnpa*omega*xi)**2
      sr=cdsqrt(r)/vt**2
      r=r*besk2
C
      if (dreal(sr).lt.50.d0) then
C
        numb=2
        xnu=2.
        call umach(-3,9)
        call dcbks(xnu,sr,numb,ckbs)
        call erset(0,1,1)
C
        ck2=ckbs(1)*dexp(1./vt**2)
        ck3=ckbs(2)*dexp(1./vt**2)
C
      else
C
        ce=1./vt**2-sr
        cfac=cdexp(ce)
        ck2=cbesk_a(2,sr)*cfac
        ck3=cbesk_a(3,sr)*cfac
C
      end if
C
      t1=dcos(xim)
C
      co=omega**2
C
      t2=co*(cnpe*dsin(xim))**2
C
CC      tx_11=ck2/(r*vt**4*besk2)*t1-ck3/(r*sr*vt**4*besk2)*t2
      tx_11=ck2/r*t1-ck3/(r*sr)*t2
C
C
      return
      end
C
C---------------------------------------------------------------------
C
      double complex function tx_12(xi)
C
      implicit double precision (a-h, o-z)
C
      double complex dcmplx,cdexp,cdsqrt
      double complex cnpe
      double complex ci,r,sr,t2
      double complex ck2,ck3
      double complex ce,cfac,cbesk_a
C
      double complex ckbs(2)
C
      common /para9/ alpha,omega,vt,besk2
      common /wave0/ cnpa
      common /wave1/ cnpe
C
      external dcbks,umach,erset
C
      ci=dcmplx(0.d0,1.d0)
C
      twopi=6.283185307179586476925287
      xim=dmod(xi,twopi)
C
C... r is the actual r multiplied by (vte/c)**4 and K_2({c/vt}**2) ...
C.... this takes care of the normalization factors in the tensor .....
C... sr is the square-root of r (argument of the Bessel functions) ...
C............ dom = omega*(vte/c)**2 = (w/wce)*(vte/c)**2 ............
C
      dom=omega*vt**2
      r=(1.-ci*xi*dom)**2+2.*(cnpe*dom)**2*(1.-dcos(xim))+
     %  (cnpa*dom*xi)**2
CC      r=(1./vt**2-ci*xi*omega)**2+
CC     %  2.*(cnpe*omega)**2*(1.-dcos(xim))+
CC     %  (cnpa*omega*xi)**2
      sr=cdsqrt(r)/vt**2
      r=r*besk2
C
      if (dreal(sr).lt.50.d0) then
C
        numb=2
        xnu=2.
        call umach(-3,9)
        call dcbks(xnu,sr,numb,ckbs)
        call erset(0,1,1)
C
        ck2=ckbs(1)*dexp(1./vt**2)
        ck3=ckbs(2)*dexp(1./vt**2)
C
      else
C
        ce=1./vt**2-sr
        cfac=cdexp(ce)
        ck2=cbesk_a(2,sr)*cfac
        ck3=cbesk_a(3,sr)*cfac
C
      end if
C
      t1=-dsin(xim)
C
      co=omega**2
C
      t2=-co*cnpe**2*dsin(xim)*(1.-dcos(xim))
C
CC      tx_12=ck2/(r*vt**4*besk2)*t1-ck3/(r*sr*vt**4*besk2)*t2
      tx_12=ck2/r*t1-ck3/(r*sr)*t2
C
C
      return
      end
C
C---------------------------------------------------------------------
C
      double complex function tx_13(xi)
C
      implicit double precision (a-h, o-z)
C
      double complex dcmplx,cdexp,cdsqrt
      double complex cnpe
      double complex ci,r,sr,t2
      double complex ck3
      double complex ce,cfac,cbesk_a
C
      double complex ckbs(2)
C
      common /para9/ alpha,omega,vt,besk2
      common /wave0/ cnpa
      common /wave1/ cnpe
C
      external dcbks,umach,erset
C
      ci=dcmplx(0.d0,1.d0)
C
      twopi=6.283185307179586476925287
      xim=dmod(xi,twopi)
C
C... r is the actual r multiplied by (vte/c)**4 and K_2({c/vt}**2) ...
C.... this takes care of the normalization factors in the tensor .....
C... sr is the square-root of r (argument of the Bessel functions) ...
C............ dom = omega*(vte/c)**2 = (w/wce)*(vte/c)**2 ............
C
      dom=omega*vt**2
      r=(1.-ci*xi*dom)**2+2.*(cnpe*dom)**2*(1.-dcos(xim))+
     %  (cnpa*dom*xi)**2
CC      r=(1./vt**2-ci*xi*omega)**2+
CC     %  2.*(cnpe*omega)**2*(1.-dcos(xim))+
CC     %  (cnpa*omega*xi)**2
      sr=cdsqrt(r)/vt**2
      r=r*besk2
C
      if (dreal(sr).lt.50.d0) then
C
        numb=2
        xnu=2.
        call umach(-3,9)
        call dcbks(xnu,sr,numb,ckbs)
        call erset(0,1,1)
C
        ck2=ckbs(1)*dexp(1./vt**2)
        ck3=ckbs(2)*dexp(1./vt**2)
C
      else
C
        ce=1./vt**2-sr
        cfac=cdexp(ce)
        ck2=cbesk_a(2,sr)*cfac
        ck3=cbesk_a(3,sr)*cfac
C
      end if
C
      co=omega**2
C
      t2=co*cnpe*cnpa*xi*dsin(xim)
C
CC      tx_13=-ck3/(r*sr*vt**4*besk2)*t2
      tx_13=-ck3/(r*sr)*t2
C
C
      return
      end
C
C---------------------------------------------------------------------
C
      double complex function tx_22(xi)
C
      implicit double precision (a-h, o-z)
C
      double complex dcmplx,cdexp,cdsqrt
      double complex cnpe
      double complex ci,r,sr,t2
      double complex ck2,ck3
      double complex ce,cfac,cbesk_a
C
      double complex ckbs(2)
C
      common /para9/ alpha,omega,vt,besk2
      common /wave0/ cnpa
      common /wave1/ cnpe
C
      external dcbks,umach,erset
C
      ci=dcmplx(0.d0,1.d0)
C
      twopi=6.283185307179586476925287
      xim=dmod(xi,twopi)
C
C... r is the actual r multiplied by (vte/c)**4 and K_2({c/vt}**2) ...
C.... this takes care of the normalization factors in the tensor .....
C... sr is the square-root of r (argument of the Bessel functions) ...
C............ dom = omega*(vte/c)**2 = (w/wce)*(vte/c)**2 ............
C
      dom=omega*vt**2
      r=(1.-ci*xi*dom)**2+2.*(cnpe*dom)**2*(1.-dcos(xim))+
     %  (cnpa*dom*xi)**2
CC      r=(1./vt**2-ci*xi*omega)**2+
CC     %  2.*(cnpe*omega)**2*(1.-dcos(xim))+
CC     %  (cnpa*omega*xi)**2
      sr=cdsqrt(r)/vt**2
      r=r*besk2
C
      if (dreal(sr).lt.50.d0) then
C
        numb=2
        xnu=2.
        call umach(-3,9)
        call dcbks(xnu,sr,numb,ckbs)
        call erset(0,1,1)
C
        ck2=ckbs(1)*dexp(1./vt**2)
        ck3=ckbs(2)*dexp(1./vt**2)
C
      else
C
        ce=1./vt**2-sr
        cfac=cdexp(ce)
        ck2=cbesk_a(2,sr)*cfac
        ck3=cbesk_a(3,sr)*cfac
C
      end if
C
      t1=dcos(xim)
C
      co=omega**2
C
      t2=-co*cnpe**2*(1.-dcos(xim))**2
C
CC      tx_22=ck2/(r*vt**4*besk2)*t1-ck3/(r*sr*vt**4*besk2)*t2
      tx_22=ck2/r*t1-ck3/(r*sr)*t2
C
C
      return
      end
C
C---------------------------------------------------------------------
C
      double complex function tx_23(xi)
C
      implicit double precision (a-h, o-z)
C
      double complex dcmplx,cdexp,cdsqrt
      double complex cnpe
      double complex ci,r,sr,t2
      double complex ck3
      double complex ce,cfac,cbesk_a
C
      double complex ckbs(2)
C
      common /para9/ alpha,omega,vt,besk2
      common /wave0/ cnpa
      common /wave1/ cnpe
C
      external dcbks,umach,erset
C
      ci=dcmplx(0.d0,1.d0)
C
      twopi=6.283185307179586476925287
      xim=dmod(xi,twopi)
C
C... r is the actual r multiplied by (vte/c)**4 and K_2({c/vt}**2) ...
C.... this takes care of the normalization factors in the tensor .....
C... sr is the square-root of r (argument of the Bessel functions) ...
C............ dom = omega*(vte/c)**2 = (w/wce)*(vte/c)**2 ............
C
      dom=omega*vt**2
      r=(1.-ci*xi*dom)**2+2.*(cnpe*dom)**2*(1.-dcos(xim))+
     %  (cnpa*dom*xi)**2
CC      r=(1./vt**2-ci*xi*omega)**2+
CC     %  2.*(cnpe*omega)**2*(1.-dcos(xim))+
CC     %  (cnpa*omega*xi)**2
      sr=cdsqrt(r)/vt**2
      r=r*besk2
C
      if (dreal(sr).lt.50.d0) then
C
        numb=2
        xnu=2.
        call umach(-3,9)
        call dcbks(xnu,sr,numb,ckbs)
        call erset(0,1,1)
C
        ck2=ckbs(1)*dexp(1./vt**2)
        ck3=ckbs(2)*dexp(1./vt**2)
C
      else
C
        ce=1./vt**2-sr
        cfac=cdexp(ce)
        ck2=cbesk_a(2,sr)*cfac
        ck3=cbesk_a(3,sr)*cfac
C
      end if
C
      co=omega**2
C
      t2=co*cnpe*cnpa*xi*(1.-dcos(xim))
C
CC      tx_23=-ck3/(r*sr*vt**4*besk2)*t2
      tx_23=-ck3/(r*sr)*t2
C
C
      return
      end
C
C---------------------------------------------------------------------
C
      double complex function tx_33(xi)
C
      implicit double precision (a-h, o-z)
C
      double complex dcmplx,cdexp,cdsqrt
      double complex cnpe
      double complex ci,r,sr,t2
      double complex ck2,ck3
      double complex ce,cfac,cbesk_a
C
      double complex ckbs(2)
C
      common /para9/ alpha,omega,vt,besk2
      common /wave0/ cnpa
      common /wave1/ cnpe
C
      external dcbks,umach,erset
C
      ci=dcmplx(0.d0,1.d0)
C
      twopi=6.283185307179586476925287
      xim=dmod(xi,twopi)
C
C... r is the actual r multiplied by (vte/c)**4 and K_2({c/vt}**2) ...
C.... this takes care of the normalization factors in the tensor .....
C... sr is the square-root of r (argument of the Bessel functions) ...
C............ dom = omega*(vte/c)**2 = (w/wce)*(vte/c)**2 ............
C
      dom=omega*vt**2
      r=(1.-ci*xi*dom)**2+2.*(cnpe*dom)**2*(1.-dcos(xim))+
     %  (cnpa*dom*xi)**2
CC      r=(1./vt**2-ci*xi*omega)**2+
CC     %  2.*(cnpe*omega)**2*(1.-dcos(xim))+
CC     %  (cnpa*omega*xi)**2
      sr=cdsqrt(r)/vt**2
      r=r*besk2
C
      if (dreal(sr).lt.50.d0) then
C
        numb=2
        xnu=2.
        call umach(-3,9)
        call dcbks(xnu,sr,numb,ckbs)
        call erset(0,1,1)
C
        ck2=ckbs(1)*dexp(1./vt**2)
        ck3=ckbs(2)*dexp(1./vt**2)
C
      else
C
        ce=1./vt**2-sr
        cfac=cdexp(ce)
        ck2=cbesk_a(2,sr)*cfac
        ck3=cbesk_a(3,sr)*cfac
C
      end if
C
      co=omega**2
C
      t2=co*(cnpa*xi)**2
C
CC      tx_33=ck2/(r*vt**4*besk2)-ck3/(r*sr*vt**4*besk2)*t2
      tx_33=ck2/r-ck3/(r*sr)*t2
C
C
      return
      end
C
C---------------------------------------------------------------------
C
C#####################################################################
C       evaluating the relativistic dielectric tensor elements        
C          this part of the code is for the Weiss' formalism          
C#####################################################################
C
C.....................................................................
C
C.............. doing the two dimensional integrations ...............
C
      subroutine weiss(epsilon)
C
      implicit double precision (a-h, o-z)
C
      double complex cnpe,ckpe,dcmplx,csum,ci
C
      double complex co(0:1),ep(6),epsilon(6)
C
      common /para9/ alpha,omega,vt,besk2
      common /ppara/ p_para_min,p_para_max
      common /pperp/ p_perp_min,p_perp_max
      common /weerr/ errabs0,errrel0,irule0
      common /wave0/ cnpa
      common /wave1/ cnpe
      common /wkpa/  ckpa
      common /wkpe/  ckpe
      common /nar2/  ireal
      common /nar4/  kel
C
      external dqdag,fperp,umach,erset
C
      ckpa=cnpa*omega
      ckpe=cnpe*omega
C
      pi=3.141592653589793238462643d0
      factor=0.5*pi*alpha/(vt**4*omega*besk2)
C
      co(0)=dcmplx(0.d0,1.d0)
      co(1)=dcmplx(1.d0,0.d0)
C
      do 1 j=1,6
        kel=j
        csum=dcmplx(0.d0,0.d0)
C
        do 2 i=0,1
          ireal=i
          errabs=errabs0
          errrel=errrel0
          irule=irule0
          call umach(-3,9)
          call dqdag(fperp,p_perp_min,p_perp_max,
     %              errabs,errrel,irule,result,errest)
          call erset(0,1,1)
          csum=csum+co(i)*result
    2   continue
C
        ep(kel)=csum*factor
C
    1 continue
C
      ci=dcmplx(0.d0,1.d0)
C
      epsilon(1)=0.5d0*(ep(1)+2.d0*ep(2)+ep(4))
      epsilon(2)=ci*0.5d0*(ep(1)-ep(4))
      epsilon(3)=1.d0/dsqrt(2.d0)*(ep(3)-ep(5))
      epsilon(4)=0.5d0*(ep(1)-2.d0*ep(2)+ep(4))
      epsilon(5)=-ci/dsqrt(2.d0)*(ep(3)+ep(5))
      epsilon(6)=ep(6)
C
C
      return
      end
C
C=====================================================================
C
      double precision function fperp(p_perp)
C
      implicit double precision (a-h, o-z)
C
      double precision pa(200)
C
      double complex ci,dcmplx,sum
C
      double complex co(0:1)
C
      common /weerr/ errabs0,errrel0,irule0
      common /ppara/ p_para_min,p_para_max
      common /var1/  ppe,ppa0
      common /nar1/  nsing
      common /nar2/  ireal
      common /nar3/  kreal
C
      external dqdawc,fpara,dqdag,umach,erset
C
      pi=3.141592653589793238462643d0
      ci=dcmplx(0.d0,1.d0)
C
      co(0)=ci
      co(1)=dcmplx(1.d0,0.d0)
C
      ppe=p_perp
C
      call sing(ppe,p_para_min,p_para_max,pa,index)
C
C...... nsing keeps track of whether we have singularity or not ......
C.... if index is not zero then all intervals in the integration .....
C.... contain a singular point, otherwise there is no singularity ....
C... for no singularity the integration routine used is different ....
C
      if (index.eq.0) then
        nsing=0
      else
        nsing=1
      end if
C
      if (index.ne.0) then
        if (index.eq.1) then
          sum=dcmplx(0.d0,0.d0)
          do 1 i=0,1
            kreal=i
            errabs=errabs0
            errrel=errrel0
            pin=p_para_min
            pfi=p_para_max
            ppa0=pa(1)
            call umach(-3,9)
            call dqdawc(fpara,pin,pfi,ppa0,
     %                  errabs,errrel,result,errest)
            call erset(0,1,1)
            sum=sum+co(i)*(result+ci*pi*fpara(ppa0))
    1     continue
          go to 5
        else
          sum=dcmplx(0.d0,0.d0)
          pin=p_para_min
          do 2 i=1,index-1
            do 3 j=0,1
              kreal=j
              pfi=(pa(i+1)+pa(i))/2.
              errabs=errabs0
              errrel=errrel0
              ppa0=pa(i)
              call umach(-3,9)
CC              write (10,201) pin,pfi,ppa0
  201         format("fperp: pin,pfi,ppa0 =",3g18.10)
              call dqdawc(fpara,pin,pfi,ppa0,
     %                     errabs,errrel,result,errest)
              call erset(0,1,1)
              sum=sum+co(j)*(result+ci*pi*fpara(ppa0))
CC              write (10,202) sum
  202         format("sum = ",2g18.10)
    3       continue
            pin=pfi
    2     continue
          do 4 i=0,1
            kreal=i
            pfi=p_para_max
            errabs=errabs0
            errrel=errrel0
            ppa0=pa(index)
CC            write (10,201) pin,pfi,ppa0
            call umach(-3,9)
            call dqdawc(fpara,pin,pfi,ppa0,
     %                  errabs,errrel,result,errest)
            call erset(0,1,1)
            sum=sum+co(i)*(result+ci*pi*fpara(ppa0))
CC            write (10,202) sum
    4     continue
        end if
      end if
C
      if (index.eq.0) then
        errabs=errabs0
        errrel=errrel0
        irule=irule0
C
        pin=p_para_min
        pfi=p_para_max
        call umach(-3,9)
        call dqdag(fpara,pin,pfi,
     %             errabs,errrel,irule,result,errest)
        call erset(0,1,1)
        sum=dcmplx(result,0.d0)
      end if
C
    5 continue
C
      if (ireal.eq.0) then
        fperp=dimag(sum)
      else
        fperp=dreal(sum)
      end if
C
C
      return
      end
C
C=====================================================================
C
      double precision function fpara(p_para)
C
      implicit double precision (a-h, o-z)
C
      double complex sigma_11,sigma_12,sigma_13
      double complex sigma_22,sigma_23,sigma_33
C
      common /nar3/ kreal
      common /nar4/ kel
C
      external sigma_11,sigma_12,sigma_13
      external sigma_22,sigma_23,sigma_33
C
      if (kreal.eq.0) then
        if (kel.eq.1) fpara=dimag(sigma_11(p_para))
        if (kel.eq.2) fpara=dimag(sigma_12(p_para))
        if (kel.eq.3) fpara=dimag(sigma_13(p_para))
        if (kel.eq.4) fpara=dimag(sigma_22(p_para))
        if (kel.eq.5) fpara=dimag(sigma_23(p_para))
        if (kel.eq.6) fpara=dimag(sigma_33(p_para))
      else
        if (kel.eq.1) fpara=dreal(sigma_11(p_para))
        if (kel.eq.2) fpara=dreal(sigma_12(p_para))
        if (kel.eq.3) fpara=dreal(sigma_13(p_para))
        if (kel.eq.4) fpara=dreal(sigma_22(p_para))
        if (kel.eq.5) fpara=dreal(sigma_23(p_para))
        if (kel.eq.6) fpara=dreal(sigma_33(p_para))
      end if
C
C
      return
      end
C
C=====================================================================
C
      double complex function sigma_11(p_para)
C
      implicit double precision (a-h, o-z)
C
      double complex ckpe,carg,besfun
C
      double complex cbesj(1),cbesy(1)
C
      common /para9/ alpha,omega,vt,besk2
      common /wkpa/  ckpa
      common /wkpe/  ckpe
      common /var1/  p_perp,ppa0
      common /nar1/  nsing
      common /nar3/  kreal
C
      external sinom
      external dcbjs,dcbys
C
      pi=3.141592653589793238462643d0
C
      gamma=dsqrt(1.+p_perp**2+p_para**2)
C
      omt=omega*gamma-ckpa*p_para
      carg=ckpe*p_perp
C
      ord=dabs(omt+1.d0)
      numb=1
      call dcbjs(ord,carg,numb,cbesj)
      numb=1
      call dcbys(ord,carg,numb,cbesy)
C
      besfun=cbesj(1)*(cbesj(1)*dcos(pi*ord)-
     %                 cbesy(1)*dsin(pi*ord))
C
      sigma_11=p_perp**3/(2.d0*gamma)*
     %         dexp(-(gamma-1.)/vt**2)*
     %         sinom(p_perp,p_para,ppa0)*besfun
C
C
      return
      end
C
C=====================================================================
C
      double complex function sigma_12(p_para)
C
      implicit double precision (a-h, o-z)
C
      double complex ckpe,carg,besfun,cdum
C
      double complex cbesj(1),cbesy(1)
C
      common /para9/ alpha,omega,vt,besk2
      common /wkpa/  ckpa
      common /wkpe/  ckpe
      common /var1/  p_perp,ppa0
      common /nar1/  nsing
      common /nar3/  kreal
C
      external sinom
      external dcbjs,dcbys
C
      pi=3.141592653589793238462643d0
C
      gamma=dsqrt(1.+p_perp**2+p_para**2)
C
      omt=omega*gamma-ckpa*p_para
      carg=ckpe*p_perp
C
      ord=1.d0+dabs(omt)
      numb=1
      call dcbjs(ord,carg,numb,cbesj)
      cdum=cbesj(1)
      if (dabs(omt).le.1.d0) then
        ord=1.d0-dabs(omt)
        numb=1
        call dcbjs(ord,carg,numb,cbesj)
        besfun=cdum*cbesj(1)
      else
        ord=dabs(omt)-1.d0
        numb=1
        call dcbjs(ord,carg,numb,cbesj)
        numb=1
        call dcbys(ord,carg,numb,cbesy)
        besfun=cdum*(cbesj(1)*dcos(pi*ord)-
     %               cbesy(1)*dsin(pi*ord))
      end if
C
      sigma_12=p_perp**3/(2.d0*gamma)*
     %         dexp(-(gamma-1.)/vt**2)*
     %         sinom(p_perp,p_para,ppa0)*besfun
C
C
      return
      end
C
C=====================================================================
C
      double complex function sigma_13(p_para)
C
      implicit double precision (a-h, o-z)
C
      double complex ckpe,carg,besfun,cdum
C
      double complex cbesj(1),cbesy(1)
C
      common /para9/ alpha,omega,vt,besk2
      common /wkpa/  ckpa
      common /wkpe/  ckpe
      common /var1/  p_perp,ppa0
      common /nar1/  nsing
      common /nar3/  kreal
C
      external sinom
      external dcbjs,dcbys
C
      pi=3.141592653589793238462643d0
C
      gamma=dsqrt(1.+p_perp**2+p_para**2)
C
      omt=omega*gamma-ckpa*p_para
      carg=ckpe*p_perp
C
      if (omt.ge.0.d0) then
        ord=omt+1.d0
        numb=1
        call dcbjs(ord,carg,numb,cbesj)
        cdum=cbesj(1)
        ord=omt
        numb=1
        call dcbjs(ord,carg,numb,cbesj)
        numb=1
        call dcbys(ord,carg,numb,cbesy)
        besfun=cdum*(cbesj(1)*dcos(pi*ord)-
     %               cbesy(1)*dsin(pi*ord))
      end if
C
      if (omt.gt.-1.d0.and.omt.lt.0.d0) then
        ord=omt+1.d0
        numb=1
        call dcbjs(ord,carg,numb,cbesj)
        cdum=cbesj(1)
        ord=-omt
        numb=1
        call dcbjs(ord,carg,numb,cbesj)
        besfun=cdum*cbesj(1)
      end if
C
      if (omt.le.-1.d0) then
        ord=-omt
        numb=1
        call dcbjs(ord,carg,numb,cbesj)
        cdum=cbesj(1)
        ord=-1.d0-omt
        numb=1
        call dcbjs(ord,carg,numb,cbesj)
        numb=1
        call dcbys(ord,carg,numb,cbesy)
        besfun=cdum*(cbesj(1)*dcos(pi*ord)-
     %               cbesy(1)*dsin(pi*ord))
      end if
C
      sigma_13=-p_perp**2*p_para/(dsqrt(2.d0)*gamma)*
     %          dexp(-(gamma-1.)/vt**2)*
     %          sinom(p_perp,p_para,ppa0)*besfun
C
C
      return
      end
C
C=====================================================================
C
      double complex function sigma_22(p_para)
C
      implicit double precision (a-h, o-z)
C
      double complex ckpe,carg,besfun,cdum
C
      double complex cbesj(1),cbesy(1)
C
      common /para9/ alpha,omega,vt,besk2
      common /wkpa/  ckpa
      common /wkpe/  ckpe
      common /var1/  p_perp,ppa0
      common /nar1/  nsing
      common /nar3/  kreal
C
      external sinom
      external dcbjs,dcbys
C
      pi=3.141592653589793238462643d0
C
      gamma=dsqrt(1.+p_perp**2+p_para**2)
C
      omt=omega*gamma-ckpa*p_para
      carg=ckpe*p_perp
C
      ord=dabs(omt-1.d0)
      numb=1
      call dcbjs(ord,carg,numb,cbesj)
      numb=1
      call dcbys(ord,carg,numb,cbesy)
      besfun=cbesj(1)*(cbesj(1)*dcos(pi*ord)-
     %                 cbesy(1)*dsin(pi*ord))
C
      sigma_22=p_perp**3/(2.d0*gamma)*
     %         dexp(-(gamma-1.)/vt**2)*
     %         sinom(p_perp,p_para,ppa0)*besfun
C
C
      return
      end
C
C=====================================================================
C
      double complex function sigma_23(p_para)
C
      implicit double precision (a-h, o-z)
C
      double complex ckpe,carg,besfun,cdum
C
      double complex cbesj(1),cbesy(1)
C
      common /para9/ alpha,omega,vt,besk2
      common /wkpa/  ckpa
      common /wkpe/  ckpe
      common /var1/  p_perp,ppa0
      common /nar1/  nsing
      common /nar3/  kreal
C
      external sinom
      external dcbjs,dcbys
C
      pi=3.141592653589793238462643d0
C
      gamma=dsqrt(1.+p_perp**2+p_para**2)
C
      omt=omega*gamma-ckpa*p_para
      carg=ckpe*p_perp
C
      if (omt.le.0.d0) then
        ord=1.d0-omt
        numb=1
        call dcbjs(ord,carg,numb,cbesj)
        cdum=cbesj(1)
        ord=-omt
        numb=1
        call dcbjs(ord,carg,numb,cbesj)
        numb=1
        call dcbys(ord,carg,numb,cbesy)
        besfun=cdum*(cbesj(1)*dcos(pi*ord)-
     %               cbesy(1)*dsin(pi*ord))
      end if
C
      if (omt.gt.0.d0.and.omt.lt.1.d0) then
        ord=omt
        numb=1
        call dcbjs(ord,carg,numb,cbesj)
        cdum=cbesj(1)
        ord=1.d0-omt
        numb=1
        call dcbjs(ord,carg,numb,cbesj)
        besfun=cdum*cbesj(1)
      end if
C
      if (omt.ge.1.d0) then
        ord=omt
        numb=1
        call dcbjs(ord,carg,numb,cbesj)
        cdum=cbesj(1)
        ord=omt-1.d0
        numb=1
        call dcbjs(ord,carg,numb,cbesj)
        numb=1
        call dcbys(ord,carg,numb,cbesy)
        besfun=cdum*(cbesj(1)*dcos(pi*ord)-
     %               cbesy(1)*dsin(pi*ord))
      end if
C
      sigma_23=-p_perp**2*p_para/(dsqrt(2.d0)*gamma)*
     %          dexp(-(gamma-1.)/vt**2)*
     %          sinom(p_perp,p_para,ppa0)*besfun
C
C
      return
      end
C
C=====================================================================
C
      double complex function sigma_33(p_para)
C
      implicit double precision (a-h, o-z)
C
      double complex ckpe,carg,besfun
C
      double complex cbesj(1),cbesy(1)
C
      common /para9/ alpha,omega,vt,besk2
      common /wkpa/  ckpa
      common /wkpe/  ckpe
      common /var1/  p_perp,ppa0
      common /nar1/  nsing
      common /nar3/  kreal
C
      external sinom
      external dcbjs,dcbys
C
      pi=3.141592653589793238462643d0
C
      gamma=dsqrt(1.+p_perp**2+p_para**2)
C
      omt=omega*gamma-ckpa*p_para
      carg=ckpe*p_perp
C
      ord=dabs(omt)
      numb=1
      call dcbjs(ord,carg,numb,cbesj)
      numb=1
      call dcbys(ord,carg,numb,cbesy)
      besfun=cbesj(1)*(cbesj(1)*dcos(pi*ord)-
     %                 cbesy(1)*dsin(pi*ord))
C
      sigma_33=-p_perp*p_para**2/gamma*dexp(-(gamma-1.)/vt**2)*
     %          sinom(p_perp,p_para,ppa0)*besfun
C
C
      return
      end
C
C=====================================================================
C
C........ this is the sinusoidal part of the tensor elements .........
C
      double precision function sinom(ppe,ppa,ppa0)
C
      implicit double precision (a-h,o-z)
C
      common /para9/ alpha,omega,vt,besk2
      common /wkpa/  ckpa
      common /nar1/  nsing
C
      pi=3.141592653589793238462643d0
C
      gamma=dsqrt(1.+ppe**2+ppa**2)
      omt=(omega*gamma-ckpa*ppa)
C
      if (nsing.eq.1) then
        domt=omega*ppa/gamma-ckpa
        if (ppa.eq.ppa0) then
          fun=1./(pi*dcos(pi*omt)*domt)
        else
          fun=(ppa-ppa0)/(dsin(pi*omt))
        end if
      else
        fun=1./(dsin(pi*omt))
      end if
C
      sinom=fun
C
C
      return
      end
C
C=====================================================================
C
C...... finding the location of the singularities in p_parallel ......
C.......... this is the case when n_para is not equal to 1 ...........
C
      subroutine sing(p_perp,p_para_min,p_para_max,pres,index)
C
      implicit double precision (a-h, o-z)
C
      double precision pres(200)
C
      common /para9/ alpha,omega,vt,besk2
      common /wkpa/  ckpa
C
C....... calculating the range in l for a range in p_parallel ........
C
      gamma=dsqrt(1.+p_perp**2+p_para_min**2)
      l1=int(gamma*omega-ckpa*p_para_min)
      gamma=dsqrt(1.+p_perp**2+p_para_max**2)
      l2=int(gamma*omega-ckpa*p_para_max)
C
      lmax=max(iabs(l1),iabs(l2))
C
      index=0
C
      do 1 i=0,lmax
        fl=dfloat(i)
        sqp=(ckpa**2-omega**2)*(1.+p_perp**2)+fl**2
        if (sqp.lt.0.) then
          go to 2
        else
          dummy=(ckpa*fl+omega*dsqrt(sqp))/(omega**2-ckpa**2)
          if (dummy.gt.p_para_min.and.dummy.lt.p_para_max) then
            index=index+1
            pres(index)=dummy
          end if
          dummy=(ckpa*fl-omega*dsqrt(sqp))/(omega**2-ckpa**2)
          if (dummy.gt.p_para_min.and.dummy.lt.p_para_max) then
            index=index+1
            pres(index)=dummy
          end if
        end if
C
    2   continue
C
    1 continue
C
C...... arranging the pres array in order of increasing p_para .......
C
      nr=0
C
      do 3 i=1,index
        dum1=pres(i)
        do 4 j=i+1,index
          if (pres(j).lt.dum1) then
            temp1=pres(j)
            pres(j)=dum1
            dum1=temp1
          end if
    4   continue
        pres(i)=dum1
    3 continue
C
C
      return
      end
C
C=====================================================================
C=====================================================================
C=====================================================================
C=====================================================================
C
C........ for plotting the data for a given tensor component .........
C
      subroutine fun_plot
C
      implicit double precision (a-h,o-z)
C
      common /trub1/ xi_lo,dxi,nxi
C
      external rinteg,ainteg
C
      xi=xi_lo-dxi
C
      do 1 i=1,nxi
        xi=xi+dxi
        dumr=rinteg(xi)
        dumi=ainteg(xi)
        if (dabs(dumr).lt.1.d-40) dumr=0.d0
        if (dabs(dumi).lt.1.d-40) dumi=0.d0
        write (5,101) xi,dumr,dumi
    1 continue
C
  101 format(3g15.10)
C
C
      return
      end
C
C
C---------------------------------------------------------------------
C
C.......... evaluating the integral for each tensor element ..........
C
      subroutine cint(c_int)
C
      implicit double precision (a-h, o-z)
C
      double precision sumr(0:1000),stot(3)
C
      double complex c_int,csum
      double complex dcmplx
C
      common /trub1/ xi_lo,dxi,nxi
      common /trub2/ diff_err,navg
      common /trerr/ errabs0,errrel0,irule0
C
      external rinteg,ainteg,dqdag,umach,erset
C
C.. ntr keeps track of the number of averages (3) that are compared ..
C
      ntr=0
C
      xi_0=xi_lo
      xi_1=xi_0+dxi
C
      sum=0.d0
C
      do 1 i=1,nxi
C
        errabs=errabs0
        errrel=errrel0
        irule=irule0
C
        call umach(-3,9)
        call dqdag(rinteg,xi_0,xi_1,errabs,errrel,irule,
     %             t_real,errest)
        call erset(0,1,1)
C
        sum=sum+t_real
C
        jj=mod(i-1,navg)
        sumr(jj)=sum
        if (jj.eq.navg-1) then
          ntr=ntr+1
          stot(ntr)=0.d0
          do 2 j=0,navg-1
            stot(ntr)=stot(ntr)+sumr(j)
    2     continue
          stot(ntr)=stot(ntr)/dfloat(navg)
          if (ntr.eq.3) then
            diff1=dabs(dabs(stot(1))-dabs(stot(2)))
            diff2=dabs(dabs(stot(2))-dabs(stot(3)))
            if (diff1.lt.diff_err.and.diff2.lt.diff_err) then
              sum_real=stot(3)
              go to 3
            else
              stot(1)=stot(2)
              stot(2)=stot(3)
              ntr=2
            end if
          end if
        end if
C
        xi_0=xi_1
        xi_1=xi_0+dxi
C
    1 continue
C
    3 continue
C
      write (6,201) i,sum
  201 format("real integral used ",i9," steps to get ",g18.10)
C
      if (i.ge.nxi) sum_real=sum
C
      xi_0=xi_lo
      xi_1=xi_0+dxi
C
      sum=0.d0
      ntr=0
C
      do 4 i=1,nxi
C
        errabs=errabs0
        errrel=errrel0
        irule=irule0
C
        call umach(-3,9)
        call dqdag(ainteg,xi_0,xi_1,errabs,errrel,irule,
     %             t_imag,errest)
        call erset(0,1,1)
C
        sum=sum+t_imag
C
        jj=mod(i-1,navg)
        sumr(jj)=sum
        if (jj.eq.navg-1) then
          ntr=ntr+1
          stot(ntr)=0.d0
          do 5 j=0,navg-1
            stot(ntr)=stot(ntr)+sumr(j)
    5     continue
          stot(ntr)=stot(ntr)/dfloat(navg)
          if (ntr.eq.3) then
            diff1=dabs(dabs(stot(1))-dabs(stot(2)))
            diff2=dabs(dabs(stot(2))-dabs(stot(3)))
            if (diff1.lt.diff_err.and.diff2.lt.diff_err) then
              sum_imag=stot(3)
              go to 6
            else
              stot(1)=stot(2)
              stot(2)=stot(3)
              ntr=2
            end if
          end if
        end if
C
        xi_0=xi_1
        xi_1=xi_0+dxi
C
    4 continue
C
    6 continue
C
      if (i.ge.nxi) sum_imag=sum
C
      csum=dcmplx(sum_real,sum_imag)
C
      write (6,202) i,sum
  202 format("imaginary integral used ",i9," steps to get ",g18.10)
C
      c_int=csum
C
C
      return
      end
C
C---------------------------------------------------------------------
C
C... real and imaginary parts of the integrand (given separately) ....
C
C
      double precision function rinteg(xi)
C
      implicit double precision (a-h, o-z)
C
      double precision t1(3,3)
C
      double complex dcmplx,cdexp,cdsqrt
      double complex cnpe
      double complex ci,r,sr
      double complex ck2,ck3,factor
      double complex ce,cfac,cbesk_a
      double complex delta_t,cd_del
      double complex rt,srt
C
      double complex ckbs(2)
      double complex t2(3,3)
C
      common /para9/ alpha,omega,vt,besk2
      common /wave0/ cnpa
      common /wave1/ cnpe
      common /nele/  n1,n2
C
      external dcbks,umach,erset
      external cbesk_a
C
      ci=dcmplx(0.d0,1.d0)
C
      twopi=6.283185307179586476925287
      xim=dmod(xi,twopi)
C
C...... factor is the multiplier in the dielectric tensor form .......
C
      factor=ci*alpha/omega
C
C... sr is the square-root of r (argument of the Bessel functions) ...
C
      r=(1./vt**2-ci*xi*omega)**2+
     %  2.*(cnpe*omega)**2*(1.-dcos(xim))+
     %  (cnpa*omega*xi)**2
      sr=cdsqrt(r)
C
      if (dreal(sr).lt.50.d0) then
C
        numb=2
        xnu=2.
        call umach(-3,9)
        call dcbks(xnu,sr,numb,ckbs)
        call erset(0,1,1)
C
        ck2=ckbs(1)*dexp(1./vt**2)
        ck3=ckbs(2)*dexp(1./vt**2)
C
      else
C
        ce=1./vt**2-sr
        cfac=cdexp(ce)
        ck2=cbesk_a(2,sr)*cfac
        ck3=cbesk_a(3,sr)*cfac
C
      end if
C
      t1(1,1)=dcos(xim)
      t1(1,2)=-dsin(xim)
      t1(1,3)=0.d0
      t1(2,1)=-t1(1,2)
      t1(2,2)=t1(1,1)
      t1(2,3)=0.d0
      t1(3,1)=0.d0
      t1(3,2)=0.d0
      t1(3,3)=1.d0
C
      co=omega**2
C
      t2(1,1)=co*(cnpe*dsin(xim))**2
      t2(1,2)=-co*cnpe**2*dsin(xim)*(1.-dcos(xim))
      t2(1,3)=co*cnpe*cnpa*xi*dsin(xim)
      t2(2,1)=-t2(1,2)
      t2(2,2)=-co*cnpe**2*(1.-dcos(xim))**2
      t2(2,3)=co*cnpe*cnpa*xi*(1.-dcos(xim))
      t2(3,1)=t2(1,3)
      t2(3,2)=-t2(2,3)
      t2(3,3)=co*(cnpa*xi)**2
C
C.................... the relativistic integrand .....................
C
      rinteg_r=dreal(factor*(ck2/(r*vt**4*besk2)*t1(n1,n2)-
     %                       ck3/(r*sr*vt**4*besk2)*t2(n1,n2)))
C
      rinteg=rinteg_r
C
C
      return
      end
C
C---------------------------------------------------------------------
C
C... real and imaginary parts of the integrand (given separately) ....
C
C
      double precision function ainteg(xi)
C
      implicit double precision (a-h, o-z)
C
      double precision t1(3,3)
C
      double complex dcmplx,cdexp,cdsqrt
      double complex cnpe
      double complex ci,r,sr
      double complex ck2,ck3,factor
      double complex ce,cfac,cbesk_a
      double complex delta_t,cd_del
      double complex rt,srt
C
      double complex ckbs(2)
      double complex t2(3,3)
C
      common /para9/ alpha,omega,vt,besk2
      common /wave0/ cnpa
      common /wave1/ cnpe
      common /nele/  n1,n2
C
      external dcbks,umach,erset
      external cbesk_a
C
      ci=dcmplx(0.d0,1.d0)
C
C...... factor is the multiplier in the dielectric tensor form .......
C
      factor=ci*alpha/omega
C
C... sr is the square-root of r (argument of the Bessel functions) ...
C
      r=(1./vt**2-ci*xi*omega)**2+
     %  2.*(cnpe*omega)**2*(1.-dcos(xi))+
     %  (cnpa*omega*xi)**2
      sr=cdsqrt(r)
C
      if (dreal(sr).lt.50.d0) then
C
        numb=2
        xnu=2.
        call umach(-3,9)
        call dcbks(xnu,sr,numb,ckbs)
        call erset(0,1,1)
C
        ck2=ckbs(1)*dexp(1./vt**2)
        ck3=ckbs(2)*dexp(1./vt**2)
C
      else
C
        ce=1./vt**2-sr
        cfac=cdexp(ce)
        ck2=cbesk_a(2,sr)*cfac
        ck3=cbesk_a(3,sr)*cfac
C
      end if
C
      t1(1,1)=dcos(xi)
      t1(1,2)=-dsin(xi)
      t1(1,3)=0.d0
      t1(2,1)=-t1(1,2)
      t1(2,2)=t1(1,1)
      t1(2,3)=0.d0
      t1(3,1)=0.d0
      t1(3,2)=0.d0
      t1(3,3)=1.d0
C
      co=omega**2
C
      t2(1,1)=co*(cnpe*dsin(xi))**2
      t2(1,2)=-co*cnpe**2*dsin(xi)*(1.-dcos(xi))
      t2(1,3)=co*cnpe*cnpa*xi*dsin(xi)
      t2(2,1)=-t2(1,2)
      t2(2,2)=-co*cnpe**2*(1.-dcos(xi))**2
      t2(2,3)=co*cnpe*cnpa*xi*(1.-dcos(xi))
      t2(3,1)=t2(1,3)
      t2(3,2)=-t2(2,3)
      t2(3,3)=co*(cnpa*xi)**2
C
C.................... the relativistic integrand .....................
C
      ainteg_r=dimag(factor*(ck2/(r*vt**4*besk2)*t1(n1,n2)-
     %                       ck3/(r*sr*vt**4*besk2)*t2(n1,n2)))
C
      ainteg=ainteg_r
C
C
      return
      end
C
C---------------------------------------------------------------------
C
C---------------------------------------------------------------------
C.......... non-relativistic power flow and energy density ...........
C---------------------------------------------------------------------
C
C.... solving the non-relativistic hermitian dispersion relation .....
C
      subroutine nr_disp_herm(data,rguess,nrts)
C
      implicit double precision (a-h, o-z)
C
      parameter (n_rts=10)
C
      integer info(n_rts)
C
      double precision nr_func_herm
C
      double precision re_rt(n_rts)
C
      double complex rguess(n_rts),roots(n_rts)
C
      common /rterr/ errt_abs,errt_rel,it_max
      common /nrels/ nr_nterms
      common /nrts1/ knr,nrt_nr,nrt_fr,tol_ht,nd_ht
      common /prnt/  kpr
C
      external nr_func_herm,dzbren,umach,erset
C
C.......... taking the real part of the complex input roots ..........
C
      do 1 i=1,nrts
        re_rt(i)=dreal(rguess(i))
    1 continue
C
C... finding the maximum and minimum limits for finding the roots ....
C
      rtmin=re_rt(1)
      rtmax=re_rt(1)
      do 2 i=2,nrts
        rtmin=dmin1(rtmin,re_rt(i))
        rtmax=dmax1(rtmax,re_rt(i))
    2 continue
C
      rtmin=(1.d0-tol_ht*dabs(rtmin)/rtmin)*rtmin
      rtmax=(1.d0+tol_ht*dabs(rtmax)/rtmax)*rtmax
C
C....... finding the real n_perp roots for the hermitian tensor ......
C
      newrt=0
      nu_int=nd_ht
      drt=(rtmax-rtmin)/dfloat(nu_int)
      rti=rtmin-drt
      do 3 i=1,nu_int
        rti=rti+drt
        rtf=rti+drt
        if (nr_func_herm(rti)*nr_func_herm(rtf).lt.0.d0) then
          errabs=0.d0
          errrel=errt_rel
          maxfn=it_max
          xin=rti
          xfi=rtf
C
          call umach(-3,9)
          call dzbren(nr_func_herm,errabs,errrel,xin,xfi,maxfn)
          call erset(0,1,1)
C
          newrt=newrt+1
          roots(newrt)=dcmplx(xfi,0.d0)
C
        end if
C
    3 continue
C
      nn=nr_nterms
      do 4 i=1,newrt
        call pwr_nr(nn,roots(i),data)
    4 continue
C
C
      return
      end
C
C---------------------------------------------------------------------
C
C........ the non-relativistic hermitian dispersion function .........
C
      double precision function nr_func_herm(re_roots)
C
      implicit double precision (a-h, o-z)
C
      double complex dcmplx,roots
      double complex x11,x12,x13,x22,x23,x33
C
      common /nrels/ nr_nterms
      common /wave0/ cnpa
      common /coutx/ x11,x12,x13,x22,x23,x33
C
      cnpe=re_roots
      roots=dcmplx(cnpe,0.0d0)
C
      call d_nr(nr_nterms,roots)
C
C........... hermitian and anti-hermitian tensor elements ............
C
      d11h=1.-cnpa**2+dreal(x11)
      d12h=dimag(x12)
      d13h=cnpe*cnpa+dreal(x13)
      d22h=1.-cnpe**2-cnpa**2+dreal(x22)
      d23h=dimag(x23)
      d33h=1.-cnpe**2+dreal(x33)
C
      nr_func_herm=d11h*(d22h*d33h+d23h*d23h)-
     %             d12h*(d23h*d13h+d12h*d33h)-
     %             d13h*(d12h*d23h+d22h*d13h)
C
C
      return
      end
C
C---------------------------------------------------------------------
C
C................. non-relativistic tensor elements ..................
C
      subroutine pwr_nr(nn,cnpe,data)
C
      implicit double precision (a-h, o-z)
C
      double complex dcmplx,dconjg,cnpe
      double complex ci,scmu,cmu
      double complex d11,d12,d13,d22,d23,d33
      double complex d11h,d12h,d13h,d22h,d23h,d33h
      double complex up,um,dup,dum,uzp,uzm,duzp,duzm
      double complex uz2p,duz2p,duz2m,duz3p
      double complex ex,ey,ez
      double complex sx,pdis
C
      double complex x11(4),x12(4),x13(4)
      double complex x22(4),x23(4),x33(4)
      double complex x11h(4),x12h(4),x13h(4)
      double complex x22h(4),x23h(4),x33h(4)
      double complex x11a(4),x12a(4),x13a(4)
      double complex x22a(4),x23a(4),x33a(4)
      double complex cbi(0:1000),dcbi(0:1000),dcbi2(0:1000)
      double complex zm(0:1000),zp(0:1000)
      double complex zargm(0:1000),zargp(0:1000)
      double complex dzm(0:1000),dzp(0:1000)
      double complex csum(6,4)
C
      common /para1/ w0
      common /para9/ alpha,omega,vt,besk2
      common /wave0/ cnpa
      common /prnt/  kpr
      common /pwrdi/ d11h,d12h,d13h,d22h,d23h,d33h
C
      ci=dcmplx(0.d0,1.d0)
C
C.. scmu is the sqrt (cmu) (defined to take care of sign of k_perp) ..
C.............. cmu = (k_perp * v_te)**2 / omega_ce**2 ...............
C............ cy0 = omega / ( sqrt(2)*abs(k_para)*v_te ) .............
C
      scmu=cnpe*vt*omega
      cmu=scmu**2
      cy0=1./(dsqrt(2.d0)*dabs(cnpa)*vt)
C
C.......... arguments of the z-functions in the summations ...........
C
      do 1 n=0,nn
        zargm(n)=dcmplx(cy0*(1.-dfloat(n)/omega),0.d0)
        zargp(n)=dcmplx(cy0*(1.+dfloat(n)/omega),0.d0)
    1 continue
C
      call ebes2(nn,cmu,cbi,dcbi,dcbi2)
C
      call pdisp2(nn,zargm,zargp,zm,zp,dzm,dzp)
C
C..... the first element denotes the component of the 2x2 tensor .....
C.. (1 is for xx, 2 for xy, 3 for xz, 4 for yy, 5 for yz, 6 for zz) ..
C............. the second element is defined as follows ..............
C.............. 1 gives the dielectric tensor elements ...............
C............. 2 gives the derivative with respect to mu .............
C......... 3 gives omega * derivative with respect to omega ..........
C..... 4 gives k_parallel*derivative with respect to k_parallel ......
C
      csum(1,1)=dcmplx(0.d0,0.d0)
      csum(1,2)=dcmplx(0.d0,0.d0)
      csum(1,3)=dcmplx(0.d0,0.d0)
      csum(1,4)=dcmplx(0.d0,0.d0)
C
      csum(2,1)=dcmplx(0.d0,0.d0)
      csum(2,2)=dcmplx(0.d0,0.d0)
      csum(2,3)=dcmplx(0.d0,0.d0)
      csum(2,4)=dcmplx(0.d0,0.d0)
C
      csum(3,1)=dcmplx(0.d0,0.d0)
      csum(3,2)=dcmplx(0.d0,0.d0)
      csum(3,3)=dcmplx(0.d0,0.d0)
      csum(3,4)=dcmplx(0.d0,0.d0)
C
      csum(4,1)=2.*(cbi(0)-dcbi(0))*zp(0)
      csum(4,2)=2.*(dcbi(0)-dcbi2(0))*zp(0)
      csum(4,3)=2.*(cbi(0)-dcbi(0))*dzp(0)
      csum(4,4)=2.*(cbi(0)-dcbi(0))*cy0*dzp(0)
C
      csum(5,1)=(dcbi(0)-cbi(0))*cy0*zp(0)
      csum(5,2)=(dcbi2(0)-dcbi(0))*cy0*zp(0)
      csum(5,3)=(dcbi(0)-cbi(0))*(zp(0)+cy0*dzp(0))
      csum(5,4)=(dcbi(0)-cbi(0))*cy0*(zp(0)+cy0*dzp(0))
C
      csum(6,1)=cy0*(1.d0+cbi(0)*cy0*zp(0))
      csum(6,2)=cy0*(1.d0+dcbi(0)*cy0*zp(0))
      csum(6,3)=1.d0+cbi(0)*cy0*(2.d0*zp(0)+cy0*dzp(0))
      csum(6,4)=cy0*(-1.d0+cbi(0)*cy0**2*dzp(0))
C
      do 2 n=1,nn
C
        up=zm(n)+zp(n)
        um=zm(n)-zp(n)
        dup=dzm(n)+dzp(n)
        dum=dzm(n)-dzp(n)
        uzp=zargm(n)*zm(n)+zargp(n)*zp(n)
        uzm=zargm(n)*zm(n)-zargp(n)*zp(n)
        uz2p=zargm(n)**2*zm(n)+zargp(n)**2*zp(n)
        duzp=zargm(n)*dzm(n)+zargp(n)*dzp(n)
        duzm=zargm(n)*dzm(n)-zargp(n)*dzp(n)
        duz2p=zargm(n)**2*dzm(n)+zargp(n)**2*dzp(n)
        duz2m=zargm(n)**2*dzm(n)-zargp(n)**2*dzp(n)
        duz3p=zargm(n)**3*dzm(n)+zargp(n)**3*dzp(n)
C
        csum(1,1)=csum(1,1)+dfloat(n**2)*cbi(n)*up
        csum(1,2)=csum(1,2)+dfloat(n**2)*dcbi(n)*up
        csum(1,3)=csum(1,3)+dfloat(n**2)*cbi(n)*dup
        csum(1,4)=csum(1,4)+dfloat(n**2)*cbi(n)*duzp
C
        csum(2,1)=csum(2,1)+dfloat(n)*(dcbi(n)-cbi(n))*um
        csum(2,2)=csum(2,2)+dfloat(n)*(dcbi2(n)-dcbi(n))*um
        csum(2,3)=csum(2,3)+dfloat(n)*(dcbi(n)-cbi(n))*dum
        csum(2,4)=csum(2,4)+dfloat(n)*(dcbi(n)-cbi(n))*duzm
C
        csum(3,1)=csum(3,1)+dfloat(n)*cbi(n)*uzm
        csum(3,2)=csum(3,2)+dfloat(n)*dcbi(n)*uzm
        csum(3,3)=csum(3,3)+dfloat(n)*cbi(n)*(um+duzm)
        csum(3,4)=csum(3,4)+dfloat(n)*cbi(n)*duz2m
C
        csum(4,1)=csum(4,1)+
     %            ((2.+dfloat(n**2)/cmu**2)*cbi(n)-2.*dcbi(n))*up
        csum(4,2)=csum(4,2)+
     %            (-2.*dfloat(n**2)/cmu**3*cbi(n)+
     %             (2.+dfloat(n**2)/cmu**2)*dcbi(n)-2.*dcbi2(n))*up
        csum(4,3)=csum(4,3)+
     %            ((2.+dfloat(n**2)/cmu**2)*cbi(n)-2.*dcbi(n))*dup
        csum(4,4)=csum(4,4)+
     %            ((2.+dfloat(n**2)/cmu**2)*cbi(n)-2.*dcbi(n))*duzp
C
        csum(5,1)=csum(5,1)+(dcbi(n)-cbi(n))*uzp
        csum(5,2)=csum(5,2)+(dcbi2(n)-dcbi(n))*uzp
        csum(5,3)=csum(5,3)+(dcbi(n)-cbi(n))*(up+duzp)
        csum(5,4)=csum(5,4)+(dcbi(n)-cbi(n))*(uzp+duz2p)
C
        csum(6,1)=csum(6,1)+cbi(n)*uz2p
        csum(6,2)=csum(6,2)+dcbi(n)*uz2p
        csum(6,3)=csum(6,3)+cbi(n)*(2.*uzp+duz2p)
        csum(6,4)=csum(6,4)+cbi(n)*duz3p
C
    2 continue
C
C.......................... sign of k_para ...........................
C
      sk=cnpa/(dabs(cnpa))
C
      fac=alpha/omega**2
C
C........................ the tensor elements ........................
C
      x11(1)=fac*cy0/cmu*csum(1,1)
      x12(1)=-ci*fac*cy0*csum(2,1)
      x13(1)=sk*fac*dsqrt(2.d0)/scmu*cy0*csum(3,1)
      x22(1)=fac*cmu*cy0*csum(4,1)
      x23(1)=ci*sk*fac*dsqrt(2.d0)*scmu*cy0*csum(5,1)
      x33(1)=2.*fac*cy0*csum(6,1)
C
C....... derivatives of the tensor elements with respect to mu .......
C
      x11(2)=-(1.+1./cmu)*x11(1)
     %       +fac*cy0/cmu*csum(1,2)
      x12(2)=-x12(1)
     %       -ci*fac*cy0*csum(2,2)
      x13(2)=-(1.+0.5/cmu)*x13(1)
     %       +sk*fac*dsqrt(2.d0)/scmu*cy0*csum(3,2)
      x22(2)= (1./cmu-1.)*x22(1)
     %       +fac*cmu*cy0*csum(4,2)
      x23(2)= (0.5/cmu-1.)*x23(1)
     %       +ci*sk*fac*dsqrt(2.d0)*scmu*cy0*csum(5,2)
      x33(2)=-x33(1)
     %       +2.*fac*cy0*csum(6,2)
C
C... omega * derivatives of tensor elements with respect to omega ....
C
      x11(3)=-x11(1)
     %       +fac*cy0**2/cmu*csum(1,3)
      x12(3)=-x12(1)
     %       -ci*fac*cy0**2*csum(2,3)
      x13(3)=-x13(1)
     %       +sk*fac*dsqrt(2.d0)/scmu*cy0**2*csum(3,3)
      x22(3)=-x22(1)
     %       +fac*cmu*cy0**2*csum(4,3)
      x23(3)=-x23(1)
     %       +ci*sk*fac*dsqrt(2.d0)*scmu*cy0**2*csum(5,3)
      x33(3)=-x33(1)
     %       +2.*fac*cy0**2*csum(6,3)
C
C.. k_para * derivatives of tensor elements with respect to k_para ...
C
      x11(4)=-x11(1)
     %       -fac*cy0/cmu*csum(1,4)
      x12(4)=-x12(1)
     %       +ci*fac*cy0*csum(2,4)
      x13(4)=-2.*x13(1)
     %       -sk*fac*dsqrt(2.d0)/scmu*cy0*csum(3,4)
      x22(4)=-x22(1)
     %       -fac*cmu*cy0*csum(4,4)
      x23(4)=-x23(1)
     %       -ci*sk*fac*dsqrt(2.d0)*scmu*cy0*csum(5,4)
      x33(4)=-3.*x33(1)
     %       -2.*fac*cy0*csum(6,4)
C
C.... evaluating the hermitian and anti-hermitian tensor elements ....
C
      do 3 i=1,4
        x11h(i)=dcmplx(dreal(x11(i)),0.d0)
        x11a(i)=dcmplx(0.d0,dimag(x11(i)))
        x12h(i)=dcmplx(0.d0,dimag(x12(i)))
        x12a(i)=dcmplx(dreal(x12(i)),0.d0)
        x13h(i)=dcmplx(dreal(x13(i)),0.d0)
        x13a(i)=dcmplx(0.d0,dimag(x13(i)))
        x22h(i)=dcmplx(dreal(x22(i)),0.d0)
        x22a(i)=dcmplx(0.d0,dimag(x22(i)))
        x23h(i)=dcmplx(0.d0,dimag(x23(i)))
        x23a(i)=dcmplx(dreal(x23(i)),0.d0)
        x33h(i)=dcmplx(dreal(x33(i)),0.d0)
        x33a(i)=dcmplx(0.d0,dimag(x33(i)))
    3 continue
C
C........ the dielectric tensor elements (satisfying D.E = 0) ........
C
      d11=1.-cnpa**2+x11(1)
      d12=x12(1)
      d13=cnpe*cnpa+x13(1)
      d22=1.-cnpe**2-cnpa**2+x22(1)
      d23=x23(1)
      d33=1.-cnpe**2+x33(1)
C
C...... dispersion tensor for the hermitian permittivity tensor ......
C
      d11h=1.-cnpa**2+dcmplx(dreal(x11(1)),0.d0)
      d12h=dcmplx(0.d0,dimag(x12(1)))
      d13h=cnpe*cnpa+dcmplx(dreal(x13(1)),0.d0)
      d22h=1.-cnpe**2-cnpa**2+dcmplx(dreal(x22(1)),0.d0)
      d23h=dcmplx(0.d0,dimag(x23(1)))
      d33h=1.-cnpe**2+dcmplx(dreal(x33(1)),0.d0)
C
C............. evaluating the electric field components ..............
C
      call wave_polar_pwr(cnpe,ex,ey,ez)
C
C.......................... speed of light ...........................
      c=2.99792458d10
C
C........... power flow in the x-direction (in cgs units) ............
C
      sx=0.5*c*dreal(cnpe*(cdabs(ey)**2+cdabs(ez)**2)-
     %               cnpa*dconjg(ex)*ez)-
     %   0.5*c*cmu/cnpe*(cdabs(ex)**2*x11h(2)+cdabs(ey)**2*x22h(2)+
     %                   cdabs(ez)**2*x33h(2)+
     %                   2.*(ci*dimag(dconjg(ex)*ey)*x12h(2)+
     %                          dreal(dconjg(ex)*ez)*x13h(2)+
     %                       ci*dimag(dconjg(ey)*ez)*x23h(2)))
C.............. converting the power flow to mks units ...............
C..... this gives the power flow density (in watts/meter**2) per .....
C.... unit electric field amplitude squared (in {volts/meter}**2) ....
C...... the conversion factor is = 1.e-11/(4*pi*2.99792458**2) .......
C
      fact=8.854187817620391d-14
      sxr=dreal(sx)
      sxi=dimag(sx)
      if (dabs(sxr).lt.1.d-20) sxr=0.d0
      if (dabs(sxi).lt.1.d-20) sxi=0.d0
      sx=dcmplx(sxr,sxi)
      sx=sx*fact
C
C......................... power disspiated ..........................
C
      pdis=-0.5*ci*w0*(x11a(1)*cdabs(ex)**2+x22a(1)*cdabs(ey)**2+
     %                 x33a(1)*cdabs(ez)**2+
     %                 2.*ci*x12a(1)*dimag(dconjg(ex)*ey)+
     %                 2.*x13a(1)*dreal(dconjg(ex)*ez)+
     %                 2.*ci*x23a(1)*dimag(dconjg(ey)*ez))
C...................... converting to mks units ......................
C.... this gives the power dissipated density (in watts/meter**3) ....
C.... per electric field amplitude squared (in {volts/meter}**2) .....
C........ the conversion factor = 1.e-9/(4.*pi*2.99792458**2) ........
C
      fact=8.854187817620391d-12
      pdisr=dreal(pdis)
      pdisi=dimag(pdis)
      if (dabs(pdisr).lt.1.d-20) pdisr=0.d0
      if (dabs(pdisi).lt.1.d-20) pdisi=0.d0
      pdis=dcmplx(pdisr,pdisi)
      pdis=fact*pdis
C
      write (11,101) data,cnpe,sx,pdis,ex,ey,ez
  101 format(13g18.10)
C
C
      return
      end
C
C---------------------------------------------------------------------
C
C...... Bessel functions and their first and second derivatives ......
C
      subroutine ebes2(n,carg,cbi,dcbi,dcbi2)
C
      implicit double precision (a-h, o-z)
C
      double complex cdexp
      double complex carg,factor
C
      double complex cbi(0:1000),dcbi(0:1000),dcbi2(0:1000)
C
      external dcbis
C
      xnu=0.
      numb=n+3
C
C............... evaluating the bessel function itself ...............
C
      call dcbis(xnu,carg,numb,cbi)
C
C......... calculating the derivates of the bessel functions .........
C
      dcbi(0)=cbi(1)
      do 1 i=1,numb-1
        dcbi(i)=0.5*(cbi(i-1)+cbi(i+1))
    1 continue
C
C..... calculating the second derivates of the bessel functions ......
C
      dcbi2(0)=dcbi(1)
      do 2 i=1,numb-2
        dcbi2(i)=0.5*(dcbi(i-1)+dcbi(i+1))
    2 continue
C
C.............. multiplying by exp(-mu_e) for the sums ...............
C
      factor=cdexp(-carg)
      do 3 i=0,numb-1
        cbi(i)=cbi(i)*factor
        dcbi(i)=dcbi(i)*factor
        dcbi2(i)=dcbi2(i)*factor
    3 continue
C
C
      return
      end
C
C---------------------------------------------------------------------
C
C....... the plasma dispersion functions and their derivatives .......
C
      subroutine pdisp2(nar,cargm,cargp,zm,zp,dzm,dzp)
C
      implicit double precision (a-h, o-z)
C
      double complex dcmplx
      double complex carg,csqpi,zerfe
C
      double complex cargm(0:1000),cargp(0:1000)
      double complex zm(0:1000),zp(0:1000)
      double complex dzm(0:1000),dzp(0:1000)
C
      external zerfe
C
      sqpi=1.772453850905516027298167d0
        pi=3.141592653589793238462643d0
C
      csqpi=dcmplx(0.d0,sqpi)
C     
      do 1 i=0,nar
        zm(i)=csqpi*zerfe(cargm(i))
        zp(i)=csqpi*zerfe(cargp(i))
    1 continue
C
C......... this is d/dy[Z(y)] for y being y_plus and y_minus .........
C
      do 2 i=0,nar
        dzm(i)=-2.*(1.+cargm(i)*zm(i))
        dzp(i)=-2.*(1.+cargp(i)*zp(i))
    2 continue
C
C
        return
        end
C
C---------------------------------------------------------------------
C
C........... calculating polarizations with respect to E_x ...........
C
      subroutine wave_polar_pwr(cnpe,ex,ey,ez)
C
      implicit double precision (a-h, o-z)
C
      double complex dcmplx,ci,cnpe,cdummy
      double complex d11,d12,d13,d22,d23,d33
      double complex ex,ey,ez
      double complex pol_p,pol_m,pol_z
C
      double complex det(3),pdum(3)
C
      common /wave0/ cnpa
      common /pwrdi/ d11,d12,d13,d22,d23,d33
C
      ci=dcmplx(0.d0,1.d0)
C
      det(1)=-d12*d23-d13*d22
      det(2)= d22*d33-d23*d23
      det(3)= d12*d33+d13*d23
C
      if (cdabs(det(1)).gt.cdabs(det(2))) then
        if (cdabs(det(1)).gt.cdabs(det(3))) then
          nn=1
        else
          nn=3
        end if
      else
        if (cdabs(det(2)).gt.cdabs(det(3))) then
          nn=2
        else
          nn=3
        end if
      end if
C
      if (nn.eq.1) then
        ey=(d11*d23-d13*d12)/det(1)
        ez=(d12*d12+d11*d22)/det(1)
      end if
      if (nn.eq.2) then
        ey=(d12*d33-d13*d23)/det(2) 
        ez=(d12*d23-d13*d22)/det(2)
      end if
      if (nn.eq.3) then
        ey= (d13*d13-d11*d33)/det(3)
        ez=-(d12*d13+d11*d23)/det(3)
      end if
C
C....... zeroing out the small components of the polarizations .......
C
      pdum(1)=(1.d0+ci*ey)/dsqrt(2.d0)
      pdum(2)=(1.d0-ci*ey)/dsqrt(2.d0)
      pdum(3)=ez
C
      do 1 i=1,3
        if (dabs(dreal(pdum(i))).lt.1.0d-15) 
     %      pdum(i)=dcmplx(0.d0,dimag(pdum(i)))
        if (dabs(dimag(pdum(i))).lt.1.0d-15) 
     %      pdum(i)=dcmplx(dreal(pdum(i)),0.d0)
    1 continue
C
      ex=dcmplx(1.0d0,0.d0)
      ey=ci*(dsqrt(2.d0)*pdum(2)-1.d0)
      ez=pdum(3)
C
C
      return
      end
C
C---------------------------------------------------------------------
C
C
C---------------------------------------------------------------------
C
    subroutine length_jd(string,l_string)

    character string*(*), c
    integer l_string

    l_string = 1
1003    continue
        c = string(l_string + 1:l_string + 1)
        if(c.eq.' ') then
            goto 1004
        end if
    l_string = l_string + 1
    goto 1003

1004    continue

    return
    end