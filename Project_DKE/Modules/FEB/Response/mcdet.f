c     Simulation par la methode de Monte Carlo de la reponse d'un
c     scintillateur au rayonnement incident en fonction de sa
c     taille et de la position et de l'extension de la zone eclairee.
c
      real hnu0,alpha0,ctheta,stheta,cphi,sphi,hnu
      real tableau(10000000,8),x,y,z,r1,xmax,ymax,zmax,mhu
      real salpha0,calpha0,mhuph,mhuco,omegax,omegay,omegaz
      real dze,dzet,hnu1,cosdev,sindev,qui,omegax1,omegay1,omegaz1
      real mhuph1,mhuco1,mhu1,dze1,x1,y1,z1,ctheta1,stheta1
      real cphi1,sphi1,mec2,prof,nbtotcoll,nbmoycoll,distri(2,100)
      real nbtotlt,nbtotzm
      real nbmoylt,nbmoyzm
      real a,x0,y0,xr,yr,atom,xmhuph,xmhuco
c
      integer n,i,nphot,nbdet,w,reset0,reset,nbcoll,incidence
      integer nv,nbabs,choixdistri,iv,nbdiff,type
c
      common/etiq1/reset
c
c
c        hnu0 = energie des photons incidents
c        stheta= cos(theta) 
c        cphi= cos(azimuth)
c        hnu= energie du photon
c        x,y,z=position 
c        xr=position du centre du diaphragme / axe Ox
c        yr=position du centre du diaphragme / axe Oy
c        r1 = rayon du collimateur interieur (cm)
c        xmax = demi hauteur de la paroi
c        ymax = demi profondeur de la paroi
c        zmax = epaisseur de la paroi (valeur negative !)
c        n = nombre de photon envoyes
c        nphot = numero du photon traite
c        nbdet=nombre de photons detectes
c        w = survie
c        reset0 et reset = pour l'initialisation de ran2
c        nbcoll = nombre de collisions
c        mhu = coefficient d'absorption de la paroi
c        choixdistri = mode sortie complete ou distributions seules
c        incidence=1:normale au detecteur et 0 isotrope
c
      data mec2,pi,rad /511.0,3.1415926535,360/ 
c
      open(3,FILE='dmcdet.data',STATUS='UNKNOWN')

c
c     ************* entree donnees et ecriture ****************
c          
      read(3,*) incidence
      read(3,*) type
      read(3,*) r1
      read(3,*) xr
      read(3,*) yr
      read(3,*) xmax
      read(3,*) ymax
      read(3,*) zmax
      read(3,*) hnu0
      read(3,*) n
      read(3,*) reset0
      read(3,*) choixdistri
      read(3,*) nv
c
      close(3)
c    
c     --------------------CALCUL ATTENUATION LINEIQUE-------------------
c
      if (type.eq.1) then
         call xBGO(hnu0,mhuph,mhuco)
      elseif (type.eq.2) then
         call xNaI(hnu0,mhuph,mhuco)
      elseif (type.eq.3) then
         call xCsI(hnu0,mhuph,mhuco)
      elseif (type.eq.4) then
         call xgerma(hnu0,mhuph,mhuco)
      elseif (type.eq.5) then
         call xCdTe(hnu0,mhuph,mhuco)
      elseif (type.eq.6) then
         call xLYSO(hnu0,mhuph,mhuco)
      elseif (type.eq.7) then
         call xYAP_Ce(hnu0,mhuph,mhuco)
      endif
      mhu=mhuph+mhuco
c
c     ----------------------ECRITURE DES PARAMETRES---------------------
c
      open(2,FILE='rmcdet.data',STATUS='UNKNOWN')
c
      write(2,*) '----------------------------------------------------'
      write(2,*) 'Code MCdet : Interaction radiation-detector :'
      write(2,*) '----------------------------------------------------'
      write(2,*) ' ' 
      write(2,*) 'Photon direction (1:perp et 0: isotropic)--------->',
     *incidence
      write(2,*) '(1):BGO (2):NaI (3):CsI (4):Ge (5):CdTe (6):LYSO-->'
      write(2,*) '(7):YAP(Ce)--------------------------------------->',
     *type
      write(2,1) 'Collimateur radius N1 (detector side) (cm)-------->',
     *r1
      write(2,1) 'Impact location on the detector along Ox (cm)----->',
     *xr
      write(2,1) 'Impact location on the detector along Oy (cm)----->',
     *yr
      write(2,1) 'Half-height of the detector (cm)------------------>',
     *xmax
      write(2,1) 'Half-width of the detector (cm)------------------->',
     *ymax
      write(2,1) 'Thickness of the detector (cm)-------------------->',
     *zmax
      write(2,1) 'Energy of the incident photon (keV)--------------->',
     *hnu0
      write(2,1) 'Lineic attenuation  (cm-1)------------------------>',
     *mhu
      write(2,*) 'Number of incoming photons ----------------------->',
     *n
      write(2,*) 'Initialisation random variable generator (>0)----->',
     *reset0
      write(2,*) 'Number of histogram steps in energy (<100)------->',
     *nv
      write(2,*) ' ' 
      write(2,*) '----------------------------------------------------'
      write(2,*) ' ' 
c
c     ------------MISE AU FORMAT DES DONNEES ET INITIALISATION--------
c
c
      reset=-1*reset0
      nbdet=0
      nbdiff=0
      nbabs=0
      nphot=1
c
  30  nbcoll=1
      prof=0.0
      dzet=0.0
      if (incidence.eq.1) then
         alpha0=0.0
         cphi=1.0
         sphi=0.0
      elseif (incidence.eq.0) then
         alpha0=acos(ran2(reset))
         phi=2*pi*ran2(reset)
         cphi=cos(phi)
         sphi=sin(phi)
      endif
      salpha0=sin(alpha0*2*pi/rad)
      calpha0=cos(alpha0*2*pi/rad)
      ctheta=-1.0*calpha0
      stheta=-1.0*salpha0
      omegax=stheta*cphi
      omegay=stheta*sphi
      omegaz=ctheta
      call posi(r1,a)
      qui=tirazi(reset)
      x0=a*cos(qui)+xr
      y0=a*sin(qui)+yr
      x=x0
      y=y0
      z=0.0
      hnu=hnu0
      w=1
c
c     -----------------CALCUL DU PARCOURS DANS LA MATIERE--------------
c
      if (type.eq.1) then
         call xBGO(hnu,mhuph,mhuco)
      elseif (type.eq.2) then
         call xNaI(hnu,mhuph,mhuco)
      elseif (type.eq.3) then
         call xCsI(hnu,mhuph,mhuco)
      elseif (type.eq.4) then
         call xgerma(hnu,mhuph,mhuco)
      elseif (type.eq.5) then
         call xCdTe(hnu,mhuph,mhuco) 
      elseif (type.eq.6) then
         call xLYSO(hnu,mhuph,mhuco)
      elseif (type.eq.7) then
         call xYAP_Ce(hnu,mhuph,mhuco)      
      endif
      mhu=mhuph+mhuco
      call tirpos(mhu,dze)
      x=x+omegax*dze
      y=y+omegay*dze
      z=z+omegaz*dze
      dzet=dze
      prof=z
      if ((abs(x).gt.xmax).or.(abs(y).gt.ymax)) then
         if (nphot.ge.n) then
            goto 50
         else 
            nphot=nphot+1
            goto 30
         endif
      elseif (z.lt.(-1.0*zmax)) then
         if (nphot.ge.n) then
            goto 50
         else 
            nphot=nphot+1
            goto 30
         endif
      endif
c
  20  continue
      atom=ran2(reset)
      if (type.eq.1) then
         if ((atom.ge.0.0).and.(atom.le.(4.0/19.0))) then
            call xbismu(hnu,xmhuph,xmhuco)
         endif
         if ((atom.gt.(4.0/19.0)).and.(atom.le.(7.0/19.0))) then
            call xgerma(hnu,xmhuph,xmhuco)
         endif
         if ((atom.gt.(7.0/19.0)).and.(atom.le.1.0)) then
            call xoxy(hnu,xmhuph,xmhuco)
         endif
      elseif (type.eq.2) then
         if ((atom.ge.0.0).and.(atom.le.0.5)) then
            call xNa(hnu,xmhuph,xmhuco)
         endif
         if ((atom.gt.0.5).and.(atom.le.1.0)) then
            call xI(hnu,xmhuph,xmhuco)
         endif
      elseif (type.eq.3) then
         if ((atom.ge.0.0).and.(atom.le.0.5)) then
            call xCs(hnu,xmhuph,xmhuco)
         endif
         if ((atom.gt.0.5).and.(atom.le.1.0)) then
            call xI(hnu,xmhuph,xmhuco)
         endif
      elseif (type.eq.4) then
         call xgerma(hnu,xmhuph,xmhuco)
      elseif (type.eq.5) then
         if ((atom.ge.0.0).and.(atom.le.0.5)) then
            call xCd(hnu,xmhuph,xmhuco)
         endif
         if ((atom.gt.0.5).and.(atom.le.1.0)) then
            call xTe(hnu,xmhuph,xmhuco)
         endif
      elseif (type.eq.6) then
         if ((atom.ge.0.0).and.(atom.le.(1.8/8.0))) then
            call xlu(hnu,xmhuph,xmhuco)
         endif
         if ((atom.gt.(1.8/8.0)).and.(atom.le.(2.0/8.0))) then
            call xyt(hnu,xmhuph,xmhuco)
         endif
         if ((atom.gt.(2.0/8.0)).and.(atom.le.(3.0/8.0))) then
            call xsi(hnu,xmhuph,xmhuco)
         endif
         if ((atom.gt.(3.0/8.0)).and.(atom.le.1.0)) then
            call xoxy(hnu,xmhuph,xmhuco)
         endif
       elseif (type.eq.7) then
         if ((atom.ge.0.0).and.(atom.le.(0.198))) then
            call xyt(hnu,xmhuph,xmhuco)
         endif
         if ((atom.gt.(0.198)).and.(atom.le.(0.398))) then
            call xal(hnu,xmhuph,xmhuco)
         endif
         if ((atom.gt.(0.398)).and.(atom.le.(0.998))) then
            call xoxy(hnu,xmhuph,xmhuco)
         endif
         if ((atom.gt.(0.998)).and.(atom.le.1.0)) then
            call xce(hnu,xmhuph,xmhuco)
         endif
      endif
      call tirsur(w,xmhuph,xmhuco)
      if (w.eq.0)  then
        nbabs=nbabs+1
        nbdet=nbdet+1
        ibdet=nbdet
        tableau(ibdet,1)=hnu0
        tableau(ibdet,3)=float(nbcoll)
        tableau(ibdet,4)=dzet
        tableau(ibdet,5)=(-1.0)*prof
        tableau(ibdet,6)=x0
        tableau(ibdet,7)=hnu0+gasdev(type,hnu0)
        tableau(ibdet,8)=y0
        if (nphot.ge.n) then
           goto 50
        else 
           nphot=nphot+1
           goto 30
        endif
      else
         nbcoll=nbcoll+1
         hnu1=hnu*tircom(hnu)
         cosdev=1.0-(1.0/hnu1-1.0/hnu)*mec2
         sindev=sqrt(1.0-cosdev**2)
         qui=tirazi(reset)
         omegax1=sindev*cos(qui)*ctheta*cphi-sindev*sin(qui)*sphi
     *   +cosdev*stheta*cphi
         omegay1=sindev*cos(qui)*ctheta*sphi+sindev*sin(qui)*cphi
     *   +cosdev*stheta*sphi
         omegaz1=-sindev*cos(qui)*stheta+cosdev*ctheta
         if (hnu1.lt.3.99) hnu1=3.99
         if (type.eq.1) then
            call xBGO(hnu1,mhuph1,mhuco1)
         elseif (type.eq.2) then
            call xNaI(hnu1,mhuph1,mhuco1)
         elseif (type.eq.3) then
            call xCsI(hnu1,mhuph1,mhuco1)
         elseif (type.eq.4) then
            call xgerma(hnu1,mhuph1,mhuco1)
         elseif (type.eq.5) then
            call xCdTe(hnu1,mhuph1,mhuco1)
         elseif (type.eq.6) then
           call xLYSO(hnu1,mhuph1,mhuco1)
         elseif (type.eq.7) then
           call xYAP_Ce(hnu1,mhuph1,mhuco1)
         endif
         mhu1=mhuph1+mhuco1
         call tirpos(mhu1,dze1)
         x1=x+omegax1*dze1
         y1=y+omegay1*dze1
         z1=z+omegaz1*dze1
         ctheta1=omegaz1
         stheta1=sqrt(1.0-omegaz1**2)
         if (stheta1.eq.0.0) then
           cphi1=1.0
           sphi1=0.0
         else
           cphi1=omegax1/stheta1
           sphi1=omegay1/stheta1
         endif
         if ((abs(x1).gt.xmax).or.(abs(y1).gt.ymax)) then
            nbdiff=nbdiff+1
            nbdet=nbdet+1
            ibdet=nbdet
            tableau(ibdet,1)=hnu0-hnu1
            tableau(ibdet,3)=float(nbcoll)
            tableau(ibdet,4)=dzet
            tableau(ibdet,5)=(-1.0)*prof
            tableau(ibdet,6)=x0
            tableau(ibdet,7)=hnu0+gasdev(type,hnu0-hnu1)-hnu1
            tableau(ibdet,8)=y0
            if (nphot.ge.n) then
               goto 50
            else
               nphot=nphot+1
               goto 30
           endif
         elseif (z1.lt.(-1.0*zmax)) then
           nbdiff=nbdiff+1
           nbdet=nbdet+1
           ibdet=nbdet
           tableau(ibdet,1)=hnu0-hnu1
           tableau(ibdet,3)=float(nbcoll)
           tableau(ibdet,4)=dzet
           tableau(ibdet,5)=(-1.0)*prof
           tableau(ibdet,6)=x0
           tableau(ibdet,7)=hnu0+gasdev(type,hnu0-hnu1)-hnu1
           tableau(ibdet,8)=y0
           if (nphot.ge.n) then
              goto 50
           else
              nphot=nphot+1
              goto 30
           endif
        elseif (z1.ge.0.0) then
           nbdiff=nbdiff+1
           nbdet=nbdet+1
           ibdet=nbdet
           tableau(ibdet,1)=hnu0-hnu1
           tableau(ibdet,3)=float(nbcoll)
           tableau(ibdet,4)=dzet
           tableau(ibdet,5)=(-1.0)*prof
           tableau(ibdet,6)=x0
           tableau(ibdet,7)=hnu0+gasdev(type,hnu0-hnu1)-hnu1
           tableau(ibdet,8)=y0
           if (nphot.ge.n) then
              goto 50
           else
              nphot=nphot+1
           goto 30
           endif
        else
           dzet=dzet+dze1
           if (z1.lt.prof) prof=z1
           omegax=omegax1
           omegay=omegay1
           omegaz=omegaz1
           ctheta=ctheta1
           stheta=stheta1
           cphi=cphi1
           sphi=sphi1
           hnu=hnu1
           x=x1
           y=y1
           z=z1
           mhuph=mhuph1
           mhuco=mhuco1
        endif
        if (nphot.ge.n) then
          goto 50
        else
          goto 20
        endif
      endif
   50 continue
      nbtotcoll=0
      nbtotlt=0
      nbtotzm=0
      do 80 i=1,nbdet
         nbtotcoll=nbtotcoll+tableau(i,3)
         nbtotlt=nbtotlt+tableau(i,4)
         nbtotzm=nbtotzm+tableau(i,5)
   80 continue
c
      nbmoycoll=nbtotcoll/nbdet
      nbmoylt=nbtotlt/nbdet
      nbmoyzm=nbtotzm/nbdet
c
c     ----------------------AFFICHAGE DES RESULTATS--------------------
c
      write(2,110) 'Number of incoming photons   = ',nphot
      write(2,110) 'Number of detected photons   = ',nbdet
      write(2,110) 'Number of absorbed photons   = ',nbabs
      write(2,110) 'Number of scattered photons  = ',nbdiff
      write(2,120) 'Mean number of collisions per detected photon  =',
     *nbmoycoll
      write(2,120) 'Mean free path per detected photon (cm)        =',
     *nbmoylt
      write(2,120) 'Mean depth reached per detected photon (cm)    =',
     *nbmoyzm
      write(2,*) '-----------------------------------------------------'
c
      if (choixdistri.eq.1) then
      write(2,*) 'i,energie(i),nbcollision(i),Ltotal(i),Zmax(i),a(i),E(i
     *)'
      write(2,*) '-----------------------------------------------------'
      do 60 i=1,nbdet
   60 write(2,100) i,tableau(i,1),tableau(i,3),tableau(i,4),tableau(i,5)
     *,tableau(i,6),tableau(i,7)
      write(2,*) '-----------------------------------------------------'
      endif
c
      if (nbdet.ne.0) then
         iv=1
      write(2,*) '-----------------------------------------------------'
         write(2,*) 'Energy distribution of absorbed photons : k,f(k)'
      write(2,*) '-----------------------------------------------------'
         call histo(nv,iv,nbdet,tableau,distri)
         do 71 i=1,nv
            write(2,150) distri(1,i),distri(2,i)
   71    continue
         iv=7
      write(2,*) '-----------------------------------------------------'
         write(2,*) 'Scintillation energy distribution : E,f(E)'
      write(2,*) '-----------------------------------------------------'
         call histo(nv,iv,nbdet,tableau,distri)
         do 78 i=1,nv
            write(2,150) distri(1,i),distri(2,i)
   78    continue
         iv=6
      write(2,*) '-----------------------------------------------------'
         write(2,*) 'Impact distribution : x0,f(x0)'
      write(2,*) '-----------------------------------------------------'
         call histo(nv,iv,nbdet,tableau,distri)
         do 73 i=1,nv
            write(2,150) distri(1,i),distri(2,i)
   73    continue
         iv=8
      write(2,*) '-----------------------------------------------------'
         write(2,*) 'Impact distribution : y0,f(y0)'
      write(2,*) '-----------------------------------------------------'
         call histo(nv,iv,nbdet,tableau,distri)
         do 79 i=1,nv
            write(2,150) distri(1,i),distri(2,i)
   79    continue
         iv=3
      write(2,*) '-----------------------------------------------------'
         write(2,*) 'Number of collisions distribution : nc,f(nc)'
      write(2,*) '-----------------------------------------------------'
         call histo(nv,iv,nbdet,tableau,distri)
         do 75 i=1,nv
            write(2,150) distri(1,i),distri(2,i)
   75    continue
         iv=4
      write(2,*) '-----------------------------------------------------'
         write(2,*) 'Mean path distribution : lt,f(lt)'
      write(2,*) '-----------------------------------------------------'
         call histo(nv,iv,nbdet,tableau,distri)
         do 76 i=1,nv
            write(2,150) distri(1,i),distri(2,i)
   76    continue
         iv=5
      write(2,*) '-----------------------------------------------------'
         write(2,*) 'Depth distribution max : zm,f(zm)'
      write(2,*) '-----------------------------------------------------'
         call histo(nv,iv,nbdet,tableau,distri)
         do 77 i=1,nv
            write(2,150) distri(1,i),distri(2,i)
   77    continue
         write(2,*) '--------------------------------------------------'
         write(2,*) '--------------------------------------------------'
      else
         write(2,*) 'Ni photon detected'
      endif
      close(2)
c
c     -----------------------------FORMATS-----------------------------
c
    1 format(a51,f10.2)
  100 format(i6,1x,f5.1,1x,f6.2,1x,f6.2,1x,f6.2,1x,f6.2,1x,f6.2,1x,f6.
     *2,1x,f6.2,1x,f6.2)
  110 format(a30,i7)
  120 format(a48,f6.2)
  121 format(a47,e10.3)
  150 format(e10.3,e10.3)
  151 format(a43,f6.2)
  152 format(e10.3,e10.3,e10.3,e10.3)
  753 format(a51,i6)
  752 format(a51,f8.3)
  751 format(a51,e8.3)
  750 format(a59)
      end



      subroutine histo(nv,iv,nt,tab,distri)
      real vmin,vmax,vmin1,vmax1,tab(10000000,8)
      real dv,distri(2,100),cn,ntt
      integer nv,i,iv,ivm
c
c         Cette routine determine le spectre
c
      do 40 i=1,nt
         tab(i,2)=0.0
  40  continue
      do 41 i=1,nv
         distri(1,i)=0.0
         distri(2,i)=0.0
  41  continue
c
      if ((iv.eq.1).or.(iv.eq.7)) then
         ivm=7
      else
         ivm=iv
      endif
      vmin=+1.0e+30
      vmax=-1.0e+30
      do 42 i=1,nt
        if (tab(i,ivm).lt.vmin) vmin=tab(i,ivm)
        if (tab(i,ivm).gt.vmax) vmax=tab(i,ivm)
  42  continue
      if ((iv.eq.1).or.(iv.eq.7)) vmax=vmax+(vmax-vmin)/nv
c
      dv=(vmax-vmin)/nv
c      cn=1.0/(dv*nt)
      ntt=0.0
      do 20 j=0,nv-1
         distri(2,j+1)=0.0
         vmin1=vmin+j*dv
         vmax1=vmin+(j+1)*dv
         if (iv.ne.3) then
            distri(1,j+1)=(vmin1+vmax1)/2
         else
            distri(1,j+1)=vmin1
         endif
         do 10 i=1,nt
           if (tab(i,2).eq.0.0) then
             if ((tab(i,iv).ge.vmin1).and.(tab(i,iv).lt.vmax1)) then
c                distri(2,j+1)=distri(2,j+1)+1.0*cn
                distri(2,j+1)=distri(2,j+1)+1.0
                tab(i,2)=1.0
                ntt=ntt+1.0
                goto 10
              else
                goto 10
              endif
           else
              goto 10
           endif
   10    continue
   20 continue 
c
c      do 30 i=1,nv
c   30 distri(2,i)=distri(2,i)*nt/ntt
c      return
      end



      function ran2(idum)
      integer m,ia,ic,ir(97),iy,idum,j,iff
      real rm 
c
c     Variable aleatoire uniforme comprise entre 0 et 1
c     ATTENTION : periodicite m=714025 -> ne pas tirer plus de m fois
c
      m=714025
      ia=1366
      ic=150889
      iff=0
      idum=-idum
      rm=1./m
      if (idum.lt.0.or.iff.eq.0) then
         iff=1
         idum=mod(ic-idum,m)
         do 10 j=1,97
             idum=mod(ia*idum+ic,m)
             ir(j)=idum
   10        continue
         idum=mod(ia*idum+ic,m)
         iy=idum
      endif
      j=1+(97*iy)/m
      if(j.gt.97.or.j.lt.1) write(2,*) 'erreur random'
      iy=ir(j)
      ran2=iy*rm
      idum=mod(ia*idum+ic,m)
      ir(j)=idum
      return
      end






      function tirazi(idum)
      integer m,ia,ic,ir(97),iy,idum,j,iff
      real*4 rm,pi
      data pi/3.1415926535/
c
c     Variable aleatoire uniforme comprise entre 0 et 2*pi
c     ATTENTION : periodicite m=714025 -> ne pas tirer plus de m fois
c     (tirazi=2*pi*ran2 -> ran2 : variable aleatoire uniforme (0,1)
c
      m=714025
      ia=1366
      ic=150889
      iff=0
      idum=-idum
      rm=1./m
      if (idum.lt.0.or.iff.eq.0) then
         iff=1
         idum=mod(ic-idum,m)
         do 10 j=1,97
             idum=mod(ia*idum+ic,m)
             ir(j)=idum
   10        continue
         idum=mod(ia*idum+ic,m)
         iy=idum
      endif
      j=1+(97*iy)/m
      if(j.gt.97.or.j.lt.1) write(2,*) 'erreur random'
      iy=ir(j)
      tirazi=iy*rm*2.0*pi
      idum=mod(ia*idum+ic,m)
      ir(j)=idum
      return
      end





      subroutine tirpos(mhut,var)
      real var,mhut,aleat
      integer reset
c
      common/etiq1/reset
c
      aleat=ran2(reset)
      if (aleat.ne.0.0) then
         var=-log(aleat)/mhut
      else
         write(2,*) 'Erreur tirpos'
c         pause
      endif
      return
      end



      subroutine ener(hnu10,hnu0,hnu)
      real hnu10,hnu0,hnu,aleat
      integer reset
c
      common/etiq1/reset
c
      aleat=ran2(reset)
      if (aleat.ne.0.0) then
         hnu=hnu10-hnu0*log(1.0-aleat)
      else
         write(2,*) 'Erreur tirener'
c         pause
      endif
      return
      end


      subroutine posi(a,x)
      real a,x,aleat
      integer reset
c
      common/etiq1/reset
c
      aleat=ran2(reset)
      x=a*sqrt(aleat)
      return
      end


      subroutine tirsur(survie,mhuph,mhuco)
      real mhuco,mhuph,r,va
      integer reset,survie
c
      common/etiq1/reset
c
      r=mhuco/(mhuco+mhuph)
c
      va=ran2(reset)
c      write(1,*) va
      if (va.le.r) then
        survie=1
      else
        survie=0
      endif
      return
      end


      function tircom(hnu0)
      real q1,q2,q3,lambda,r,hnu0
      real test1,test2a,test2b
      integer reset
c
      common/etiq1/reset
c
      data mec2/511.0/
c
c     Variable aleatoire associee a l'effet Compton
c
   10 continue
      q1=ran2(reset)
      q2=ran2(reset)    
      q3=ran2(reset)
      lambda=mec2/hnu0
      test1=(1.0+2.0/lambda)/(9.0+2.0/lambda)
      if (q1.le.test1) then
          r=1.0+2.0*q2/lambda
          test2a=4.0*(1.0/r-1.0/r**2)
          if (q3.le.test2a) then
             tircom=1.0/r
          else 
             goto 10
          endif
      else 
          r=(1.0+2.0/lambda)/(1.0+2.0*q2/lambda)
          test2b=0.5*((lambda-r*lambda+1.0)**2+1.0/r)
          if (q3.le.test2b) then
             tircom=1.0/r
          else 
             goto10
          endif
      endif
      return
      end

      subroutine xYAP_Ce(Eph,mhuph,mhuco)
      real Eph,mhuph,mhuco
      real mhuphyt,mhuphal,mhuphoxy,mhuphce
      real mhucoyt,mhucoal,mhucooxy,mhucoce
      data dens,densyt,densal/5.37,4.405,2.702/
      data densoxy,densce/1.429e-3,6.670/
      data pyt,pal,poxy,pce/0.71,0.0403,0.0637,0.1815/
c      if ((Eph.ge.3.99).and.(Eph.le.1000.0)) then
      if (Eph.ge.3.99) then
        call xyt(Eph,mhuphyt,mhucoyt)
        call xal(Eph,mhuphal,mhucoal)
        call xoxy(Eph,mhuphoxy,mhucooxy)
        call xce(Eph,mhuphce,mhucoce)
        mhuph=mhuphyt*pyt*dens/densyt
        mhuph=mhuph+mhuphal*pal*dens/densal
        mhuph=mhuph+mhuphoxy*poxy*dens/densoxy
        mhuph=mhuph+mhuphce*pce*dens/densce
        mhuco=mhucoyt*pyt*dens/densyt
        mhuco=mhuco+mhucoal*pal*dens/densal
        mhuco=mhuco+mhucooxy*poxy*dens/densoxy
        mhuco=mhuco+mhucoce*pce*dens/densce
      else
        write(2,*) 'YAP:Ce (YAlO3:Ce): k<3.99 ou k>1000'
      endif
      return
      end      

      subroutine xLYSO(Eph,mhuph,mhuco)
      real Eph,mhuph,mhuco
      real mhuphlu,mhuphyt,mhuphsi,mhuphoxy
      real mhucolu,mhucoyt,mhucosi,mhucooxy
      data dens,denslu,densyt/7.1,9.842,4.405/
      data denssi,densoxy/2.33,1.43e-3/
      data plu,pyt,psi,poxy/0.71,0.0403,0.0637,0.1815/
c      if ((Eph.ge.3.99).and.(Eph.le.1000.0)) then
      if (Eph.ge.3.99) then
        call xlu(Eph,mhuphlu,mhucolu)
        call xyt(Eph,mhuphyt,mhucoyt)
        call xsi(Eph,mhuphsi,mhucosi)
        call xoxy(Eph,mhuphoxy,mhucooxy)
        mhuph=mhuphlu*plu*dens/denslu
        mhuph=mhuph+mhuphyt*pyt*dens/densyt
        mhuph=mhuph+mhuphsi*psi*dens/denssi
        mhuph=mhuph+mhuphoxy*poxy*dens/densoxy
        mhuco=mhucolu*plu*dens/denslu
        mhuco=mhuco+mhucoyt*pyt*dens/densyt
        mhuco=mhuco+mhucosi*psi*dens/denssi
        mhuco=mhuco+mhucooxy*poxy*dens/densoxy
      else
        write(2,*) 'LYSO (Lu2(1-x)Y2xSiO5,x = 0.1): k<3.99 ou k>1000'
      endif
      return
      end      

      subroutine xlu(Eph,mhup,mhuc)
      real Eph
      real mhu0,mhup,mhuc
      data dens,pa,avo,barn/9.842,174.99,6.023e+23,1.0e-24/
      data ap10,ap11,ap12,ap13/17.2638,-2.37189,-0.0495994,0.0/ 
      data ap20,ap21,ap22,ap23/16.2289,-2.67128,0.0,0.0/
      data ap30,ap31,ap32,ap33/13.9813,-2.40841,0.0,0.0/
      data ap40,ap41,ap42,ap43/12.6387,1.55476,-0.881094,0.0602036/
      data ac0,ac1,ac2,ac3/0.197176,0.150264,-0.192474,0.00385751/
      mhu0=dens*avo*barn/pa
      if (Eph.lt.63.314) then
        mhup=exp(ap10+ap11*log(Eph)+ap12*log(Eph)**2+ap13*log(Eph)**3)
      elseif (Eph.lt.10.8700) then
        mhup=exp(ap20+ap21*log(Eph)+ap22*log(Eph)**2+ap23*log(Eph)**3)
      elseif (Eph.lt.2.4920) then
        mhup=exp(ap30+ap31*log(Eph)+ap32*log(Eph)**2+ap33*log(Eph)**3)
      else
        mhup=exp(ap40+ap41*log(Eph)+ap42*log(Eph)**2+ap43*log(Eph)**3)
      endif
      mhuc=exp(ac0+ac1*log(Eph)+ac2*log(Eph)**2+ac3*log(Eph)**3)
      mhup=mhup*mhu0
      mhuc=mhuc*mhu0
      return
      end

      subroutine xyt(Eph,mhup,mhuc)
      real Eph
      real mhu0,mhup,mhuc
      data dens,pa,avo,barn/4.405,88.9050,6.023e+23,1.0e-24/
      data ap10,ap11,ap12,ap13/15.1822,-2.38946,-0.0881174,0.0/
      data ap20,ap21,ap22,ap23/13.4674,0.191023,-0.686616,0.0497356/
      data ac0,ac1,ac2,ac3/0.0629057,  1.41577, -0.199713,  0.00533312/
      mhu0=dens*avo*barn/pa
      if (Eph.lt.17.08) then
        mhup=exp(ap10+ap11*log(Eph)+ap12*log(Eph)**2+ap13*log(Eph)**3)
      else
        mhup=exp(ap20+ap21*log(Eph)+ap22*log(Eph)**2+ap23*log(Eph)**3)
      endif
      mhuc=exp(ac0+ac1*log(Eph)+ac2*log(Eph)**2+ac3*log(Eph)**3)
      mhup=mhup*mhu0
      mhuc=mhuc*mhu0
      return
      end


      subroutine xce(Eph,mhup,mhuc)
      real Eph
      real mhu0,mhup,mhuc
      data dens,pa,avo,barn/6.670,140.130,6.023e+23,1.0e-24/
      data ap10,ap11,ap12,ap13/16.5852,-2.36288,-6.54708,0 /
      data ap20,ap21,ap22,ap23/10.2725,2.74562,-1.14174,0.0774162/
      data ac0,ac1,ac2,ac3/0.439881, 1.30925, -0.164548, 0.00252641/
      mhu0=dens*avo*barn/pa
      if (Eph.lt.40.444) then
        mhup=exp(ap10+ap11*log(Eph)+ap12*log(Eph)**2+ap13*log(Eph)**3)
      else
        mhup=exp(ap20+ap21*log(Eph)+ap22*log(Eph)**2+ap23*log(Eph)**3)
      endif
      mhuc=exp(ac0+ac1*log(Eph)+ac2*log(Eph)**2+ac3*log(Eph)**3)
      mhup=mhup*mhu0
      mhuc=mhuc*mhu0
      return
      end

      subroutine xsi(Eph,mhup,mhuc)
      real Eph
      real mhu0,mhup,mhuc
      data dens,pa,avo,barn/2.33,28.086,6.023e+23,1.0e-24/
      data ap10,ap11,ap12,ap13/13.2682,-1.98174,-0.31695,0.0273928/
      data ac0,ac1,ac2,ac3/-0.414971,1.34868,-0.222315,0.00841959/
      mhu0=dens*avo*barn/pa
      mhup=exp(ap10+ap11*log(Eph)+ap12*log(Eph)**2+ap13*log(Eph)**3)
      mhuc=exp(ac0+ac1*log(Eph)+ac2*log(Eph)**2+ac3*log(Eph)**3)
      mhup=mhup*mhu0
      mhuc=mhuc*mhu0
      return
      end

      subroutine xal(Eph,mhup,mhuc)
      real Eph
      real mhu0,mhup,mhuc
      data dens,pa,avo,barn/2.702,26.97,6.023e+23,1.0e-24/
      data ap10,ap11,ap12,ap13/13.1738,-2.18203,-0.25895,0.02284/
      data ac0,ac1,ac2,ac3/-0.439322,1.30867,-0.211648,0.0075421/
      mhu0=dens*avo*barn/pa
      mhup=exp(ap10+ap11*log(Eph)+ap12*log(Eph)**2+ap13*log(Eph)**3)
      mhuc=exp(ac0+ac1*log(Eph)+ac2*log(Eph)**2+ac3*log(Eph)**3)
      mhup=mhup*mhu0
      mhuc=mhuc*mhu0
      return
      end

      subroutine xCdTe(Eph,mhuph,mhuco)
      real Eph,mhuph,mhuco
      real mhuphCd,mhuphTe
      real mhucoCd,mhucoTe
      data dens,densCd,densTe/5.856,8.65,6.24/
      data pCd,pTe/0.468,0.532/
c      if ((Eph.ge.3.99).and.(Eph.le.1000.0)) then
      if (Eph.ge.3.99) then
        call xCd(Eph,mhuphCd,mhucoCd)
        call xTe(Eph,mhuphTe,mhucoTe)
        mhuph=mhuphCd*pCd*dens/densCd
        mhuph=mhuph+mhuphTe*pTe*dens/densTe
        mhuco=mhucoCd*pCd*dens/densCd
        mhuco=mhuco+mhucoTe*pTe*dens/densTe
      else
        write(2,*) 'CdTe: k<3.99 ou k>1000'
      endif
      return
      end      
      
      
      subroutine xCd(Eph,mhup,mhuc)
      real Eph
      real mhu0,mhup,mhuc
      data dens,pa,avo,barn/8.65,112.41,6.023e+23,1.0e-24/
      data ap10,ap11,ap12,ap13/15.9668,-2.38363,-0.0801104,0.0/
      data ap20,ap21,ap22,ap23/11.5254,1.07714,-0.831424,0.0579120/
      data ac0,ac1,ac2,ac3/-0.0516701,1.57426,-0.227646,0.0070565/
      mhu0=dens*avo*barn/pa
      if (Eph.lt.26.711) then
        mhup=exp(ap10+ap11*log(Eph)+ap12*log(Eph)**2+ap13*log(Eph)**3)
      else
        mhup=exp(ap20+ap21*log(Eph)+ap22*log(Eph)**2+ap23*log(Eph)**3)
      endif
      mhuc=exp(ac0+ac1*log(Eph)+ac2*log(Eph)**2+ac3*log(Eph)**3)
      mhup=mhup*mhu0
      mhuc=mhuc*mhu0
      return
      end
      
      subroutine xTe(Eph,mhup,mhuc)
      real Eph
      real mhu0,mhup,mhuc
      data dens,pa,avo,barn/6.24,127.6,6.023e+23,1.0e-24/
      data ap10,ap11,ap12,ap13/16.1087,-2.27876,-0.0929405,0.0/
      data ap20,ap21,ap22,ap23/11.6656,1.71052,-0.948281,0.0653213/
      data ac0,ac1,ac2,ac3/-0.0407579,1.64267,-0.247897,0.00880567/
      mhu0=dens*avo*barn/pa
      if (Eph.lt.31.813) then
        mhup=exp(ap10+ap11*log(Eph)+ap12*log(Eph)**2+ap13*log(Eph)**3)
      else
        mhup=exp(ap20+ap21*log(Eph)+ap22*log(Eph)**2+ap23*log(Eph)**3)
      endif
      mhuc=exp(ac0+ac1*log(Eph)+ac2*log(Eph)**2+ac3*log(Eph)**3)
      mhup=mhup*mhu0
      mhuc=mhuc*mhu0
      return
      end

      subroutine xBGO(Eph,mhuph,mhuco)
      real Eph,mhuph,mhuco
      real mhuphbismu,mhuphgerma,mhuphoxy
      real mhucobismu,mhucogerma,mhucooxy
      data dens,densbismu,densgerma,densoxy/7.13,9.8,5.32,1.43e-3/
      data pbismu,pgerma,poxy/0.671,0.175,0.154/
c     if ((Eph.ge.3.99).and.(Eph.le.1000.0)) then
      if (Eph.ge.3.99) then
        call xbismu(Eph,mhuphbismu,mhucobismu)
        call xgerma(Eph,mhuphgerma,mhucogerma)
        call xoxy(Eph,mhuphoxy,mhucooxy)
        mhuph=mhuphbismu*pbismu*dens/densbismu
        mhuph=mhuph+mhuphgerma*pgerma*dens/densgerma
        mhuph=mhuph+mhuphoxy*poxy*dens/densoxy
        mhuco=mhucobismu*pbismu*dens/densbismu
        mhuco=mhuco+mhucogerma*pgerma*dens/densgerma
        mhuco=mhuco+mhucooxy*poxy*dens/densoxy
      else
        write(2,*) 'BGO: k<3.99 ou k>1000'
      endif
      return
      end


      subroutine xoxy(Eph,mhup,mhuc)
      real Eph
      real mhu0,mhup,mhuc
      data dens,pa,avo,barn/1.429e-3,16.00,6.023e+23,1.0e-24/
      data ap0,ap1,ap2,ap3/11.7130,-2.57229,-0.205893,0.0199244/
      data ac0,ac1,ac2,ac3/-1.73679,2.17686,-0.449050,0.0264733/
      mhu0=dens*avo*barn/pa
      mhup=exp(ap0+ap1*log(Eph)+ap2*log(Eph)**2+ap3*log(Eph)**3)
      mhuc=exp(ac0+ac1*log(Eph)+ac2*log(Eph)**2+ac3*log(Eph)**3)
      mhup=mhup*mhu0
      mhuc=mhuc*mhu0
      return
      end


      subroutine xbismu(Eph,mhup,mhuc)
      real Eph
      real mhu0,mhup,mhuc
      data dens,pa,avo,barn/9.8,209.00,6.023e+23,1.0e-24/
      data ap10,ap11,ap12,ap13/16.7078,-2.58648,0.0,0.0/
      data ap20,ap21,ap22,ap23/17.5348,-2.23353,-0.0596161,0.0/
      data ap30,ap31,ap32,ap33/9.44293,3.44965,-1.19886,0.0783484/
      data ac0,ac1,ac2,ac3/0.189860,1.56125,-0.200932,0.00436768/
      mhu0=dens*avo*barn/pa
      if (Eph.lt.16.39) then
        mhup=exp(ap10+ap11*log(Eph)+ap12*log(Eph)**2+ap13*log(Eph)**3)
      elseif ((Eph.ge.16.39).and.(Eph.lt.90.53)) then
        mhup=exp(ap20+ap21*log(Eph)+ap22*log(Eph)**2+ap23*log(Eph)**3)
      else
        mhup=exp(ap30+ap31*log(Eph)+ap32*log(Eph)**2+ap33*log(Eph)**3)
      endif
      mhuc=exp(ac0+ac1*log(Eph)+ac2*log(Eph)**2+ac3*log(Eph)**3)
      mhup=mhup*mhu0
      mhuc=mhuc*mhu0
      return
      end



      subroutine xgerma(Eph,mhup,mhuc)
      real Eph
      real mhu0,mhup,mhuc
      data dens,pa,avo,barn/5.32,72.6,6.023e+23,1.0e-24/
      data ap10,ap11,ap12,ap13/14.6813,-2.59285,-0.0208355,0.0/
      data ap20,ap21,ap22,ap23/13.9288,-0.479613,-0.572897,0.0431277/
      data ac0,ac1,ac2,ac3/ -0.334383,1.60237,-0.245555,0.00871239/
      mhu0=dens*avo*barn/pa
      if (Eph.lt.11.10) then
        mhup=exp(ap10+ap11*log(Eph)+ap12*log(Eph)**2+ap13*log(Eph)**3)
      else
        mhup=exp(ap20+ap21*log(Eph)+ap22*log(Eph)**2+ap23*log(Eph)**3)
      endif
      mhuc=exp(ac0+ac1*log(Eph)+ac2*log(Eph)**2+ac3*log(Eph)**3)
      mhup=mhup*mhu0
      mhuc=mhuc*mhu0
      return
      end

      function gasdev(type,k)
      real sigma,k
      integer reset,type
c
      common/etiq1/reset
c
      if (type.eq.1) then
         sigma=4.5338*k**0.48/(2.0*sqrt(2.0*log(2.0)))
      elseif (type.eq.2) then
         sigma=(2.315*sqrt(k)+0.01*k)/(2.0*sqrt(2.0*log(2.0)))
      elseif (type.eq.3) then
         sigma=13.12*k**0.2051/(2.0*sqrt(2.0*log(2.0)))
      elseif (type.eq.4) then
         sigma=0
      elseif (type.eq.5) then
         sigma = 0
      elseif (type.eq.6) then
         sigma = 0
      endif
c
    1 v1=2.0*ran2(reset)-1
      v2=2.0*ran2(reset)-1
      r=v1**2+v2**2
      if (r.ge.1.0) goto 1
      fac=sqrt(-2*log(r)/r)
      gasdev=v2*fac*sigma
      return
      end


      subroutine xNaI(Eph,mhuph,mhuco)
      real Eph,mhuph,mhuco
      real mhucoNa,mhuphNa,mhucoI,mhuphI
      data dens,densNa,densI/3.67,0.97,4.94/
      data pNa,pI/0.1534,0.8466/
c      if ((Eph.ge.5.198).and.(Eph.le.1000.0)) then
      if (Eph.ge.5.198) then
         call xNa(Eph,mhuphNa,mhucoNa)
         call xI(Eph,mhuphI,mhucoI)
         mhuph=mhuphNa*pNa*dens/densNa
         mhuph=mhuph+mhuphI*pI*dens/densI
         mhuco=mhucoNa*pNa*dens/densNa
         mhuco=mhuco+mhucoI*pI*dens/densI
      else
        write(2,*) 'NaI: k<5.198 ou k>1000'
      endif
      return
      end

      subroutine xCsI(Eph,mhuph,mhuco)
      real Eph,mhuph,mhuco
      real mhuphCs,mhucoCs,mhuphI,mhucoI
      data dens,densCs,densI/4.51,1.873,4.94/
      data pCs,pI/0.5115,0.4885/
c      if ((Eph.ge.5.713).and.(Eph.le.1000.0)) then
      if (Eph.ge.5.713) then
         call xCs(Eph,mhuphCs,mhucoCs)
         call xI(Eph,mhuphI,mhucoI)
         mhuph=mhuphCs*pCs*dens/densCs
         mhuph=mhuph+mhuphI*pI*dens/densI
         mhuco=mhucoCs*pCs*dens/densCs
         mhuco=mhuco+mhucoI*pI*dens/densI
      else
        write(2,*) 'CsI: k<5.713 ou k>1000'
      endif
      return
      end



      subroutine xCs(Eph,mhup,mhuc)
      real Eph
      real mhu0,mhup,mhuc
      data dens,pa,avo,barn/1.873,132.91,6.023e+23,1.0e-24/
      data ap10,ap11,ap12,ap13/16.5418,-2.46363,-0.0542849,0.0/
      data ap20,ap21,ap22,ap23/11.3757,1.94161,-0.983232,0.0671986/
      data ac0,ac1,ac2,ac3/0.184861,1.50030,-0.213333,0.00624264/
      mhu0=dens*avo*barn/pa
      if (Eph.lt.35.985) then
         mhup=exp(ap10+ap11*log(Eph)+ap12*log(Eph)**2+ap13*log(Eph)**3)
      else
         mhup=exp(ap20+ap21*log(Eph)+ap22*log(Eph)**2+ap23*log(Eph)**3)
      endif
      mhuc=exp(ac0+ac1*log(Eph)+ac2*log(Eph)**2+ac3*log(Eph)**3)
      mhup=mhu0*mhup
      mhuc=mhu0*mhuc
      return
      end


      subroutine xNa(Eph,mhup,mhuc)
      real Eph
      real mhu0,mhup,mhuc
      data dens,pa,avo,barn/0.97,22.997,6.023e+23,1.0e-24/
      data ap10,ap11,ap12,ap13/12.6777,-2.24521,-0.274873,0.02507/
      data ac0,ac1,ac2,ac3/-0.967717,1.61794,-0.287191,0.0131526/
      mhu0=dens*avo*barn/pa
      mhup=exp(ap10+ap11*log(Eph)+ap12*log(Eph)**2+ap13*log(Eph)**3)
      mhuc=exp(ac0+ac1*log(Eph)+ac2*log(Eph)**2+ac3*log(Eph)**3)
      mhup=mhu0*mhup
      mhuc=mhu0*mhuc
      return
      end



      subroutine xI(Eph,mhup,mhuc)
      real Eph
      real mhu0,mhup,mhuc
      data dens,pa,avo,barn/4.94,126.91,6.023e+23,1.0e-24/
      data ap10,ap11,ap12,ap13/16.4086,-2.48214,-0.0507179,0.0/
      data ap20,ap21,ap22,ap23/12.1075,1.43635,-0.882038,0.0603575/
      data ac0,ac1,ac2,ac3/-0.0404420,1.65596,-0.251067,0.00904874/
      mhu0=dens*avo*barn/pa
      if (Eph.lt.33.169) then
         mhup=exp(ap10+ap11*log(Eph)+ap12*log(Eph)**2+ap13*log(Eph)**3)
      else
         mhup=exp(ap20+ap21*log(Eph)+ap22*log(Eph)**2+ap23*log(Eph)**3)
      endif
      mhuc=exp(ac0+ac1*log(Eph)+ac2*log(Eph)**2+ac3*log(Eph)**3)
      mhuc=mhu0*mhuc
      mhup=mhu0*mhup
      return
      end
