  TSBASE	Acces aux donnees traitees de la base de donnees TS.

 	[x1,t1,c1,x2,t2,r2,c2,...] = tsbase(choc,s1,s2,...,,'+')
 ==========================================================================
  --------------------
 | NOUVEAU au 18/6/99 |
  ---------------------

   ==> Possibilite de lire une occurrence particuliere pour un signal traite
       [a,z,e,r] = tsbase(num_choc.occurrence, 'signal');
       [a,z,e,r] = tsbase(22750.2,'simag');
         ou
       [a,z,e,r] = tsbase(num_choc, 'signal#occurrence');
       [a,z,e,r] = tsbase(num_choc, 'signal#2');

                      ===================================

  Nouveaux arguments possibles en plus du '+' que l'on met aujourd'hui en
  dernier argument, == il faut les separer par des blancs ==.

        ==>  Nx,y  (Nx"virgule"y)       ou     Nx:y (Nx"deux points"y)
             x est l'indice du debut des donnees et y l'indice de fin souhaite

             Le separateur : (deux points) permet de specifier le premier(x)
             et le dernier (y) point souhaites.
             Le separateur , (virgule) permet de specifier le premier(x)
             et le nombre de points souhaites apres ce premier point.

        ==>  Tx,y  (Tx"virgule"y)       ou     Tx:y (Tx"deux points"y)
             x est le temps(s) de debut et y le temps (s) de fin souhaite

             Le separateur : (deux points) permet de specifier le temps de
             debut(x) et le temps de fin(y) souhaites.
             Le separateur , (virgule) permet de specifier le temps de debut(x)
             et l'intervalle de temps souhaite(y) apres le temps de debut.

    Bien evidement les arguments T et N sont incompatibles sur une meme commande

 Exemples
 =========
        [a,b,c,d]=tsbase(15655,'gxrv','N1,4095');
        Retourne les points 1 a 4096 pour le groupe GXRV

        [a,b,c]=tsbase(16000,'sipmes','+ TI,2');
        Retourne 2 secondes de signal de Sipmes apres le temps ignitron

        [a,b]=tsbase(16222,'sipmes','+ N10:20');
        Retourne en temps absolu les points 10 a 20 de Sipmes

       [a,b,c]=tsbase(16000,'sipmes','+ TI:42');
        Retourne le signal de Sipmes entre le temps ignitron et 42 secondes


  ==> le nom des signaux et/ou traitements peuvent etre en majuscules ou
      en minuscules (ou melange des deux).

  ==> tsbase rend toujours les temps en secondes :
      par defaut en relatif (t - tignitron),
      en absolu si le dernier argument de tsbase = '+'
      Ex: [v,tp]=tsbase(10551,'SIMAG') => tp est en secondes en relatif
      Ex: [v1,tp1]=tsbase(10551,'simag','+') => tp1 est en secondes en absolu

  ==> il est possible d'extraire un signal d'un groupe avec la syntaxe
      d'appel suivante :
      [a,b]=tsbase(choc,'nom-du-groupe%Indice1.Indice2');
      .Indice2 : uniquement pour les groupes a 4 coordonnees.
      Ex:[v,t]=tsbase(10385,'GNL%3'); extrait le 3eme signal de GNL et
                                      rend les temps en relatif
      Ex:[v,t]=tsbase(10385,'Gt1%3.2','+'); extrait le signal(3,2) de GT1 et
                                            rend les temps en absolu

 ==========================================================================
  choc =  numero du choc.
  avec n=1,2,3....
  sn,... nom du signal traite (chaine de caractere).
  xn,... signal (coordonnee1 : mesures).
  tn,... temps du signal (coordonee 2).
  rn,... si elle existe,3eme coordonee du signal (pour un groupe).
  cn,... certification, version, unites, date de creation du signal:
         (faire help tsbase_cert).
  ex:>>[ip,tip,cip,te,tte,rte,nl,tnl,cnl]=tsbase(700,'Simag','GTETHOM','Rimag')

 -La fonction retourne un vecteur vide en cas de mauvais traitement.
 -Le nombre de sortie est limite a 26.

 En faisant un appel sans argument on obtient la liste des traitements de la
   base disponibles et les comentaires associes.
  ex:  [traitListe,Comment]=tsbase;

 En faisant un appel dont le seul argument est un nom de traitement, on obtient
   la liste des signaux et commentaires associes.
  ex:  [sigListe,Comment]=tsbase('TEMPETE');

 En cas de transfert important,utilisez tsbase(choc,signal)

  signal   tableau de caracteres, liste des signaux (un par ligne).
  ex:      sig=['simag ';'SPAROI';'GNL%3 ';'SZFBRM'];
 	   [ip,tip,cip,vt,tvt,cvt,nl3,tnl3,cnl3,ne,te,ce]=tsbase(10385,sig);

    Folders named tsbase

    There are no folders named tsbase.
>> [traitListe,Comment]=tsbase

traitListe =

  64x11 char array

    'INTERFNE   '
    'INTERFNL   '
    'NEUTRES    '
    'TBARO      '
    'TBOOTSTRAP '
    'TBRAGG     '
    'TCALOR     '
    'TCALOR2    '
    'TCAMIR     '
    'TCCCRYO    '
    'TCCFCE     '
    'TCC_GAMMA  '
    'TCCHYB     '
    'TCCLANG    '
    'TCCREF     '
    'TCCTORO    '
    'TCCVIDE    '
    'TCHOCRED   '
    'TCOUPOL    '
    'TCRONOS    '
    'TDESIR     '
    'TDUO       '
    'TEFIT      '
    'TEFITCRONOS'
    'TEMPETE    '
    'TENEPROB   '
    'TENERE     '
    'TEQUAL     '
    'TEQUILA    '
    'TFCE       '
    'TFCI       '
    'TFINIR     '
    'THXRPROF   '
    'THYB       '
    'THYBCOR    '
    'TICXS      '
    'TIGNI      '
    'TIGV       '
    'TMAG       '
    'TMAGCOR    '
    'TNPAR      '
    'TPAROI     '
    'TPRISME    '
    'TPROF      '
    'TRAX       '
    'TREFLEC    '
    'TREFLEX    '
    'TREFLUCNE  '
    'TRIDENT    '
    'TSBOLO     '
    'TSFAB      '
    'TSHETERO   '
    'TSLF       '
    'TSLM1      '
    'TSLM2      '
    'TSLP       '
    'TSMASSE    '
    'TSMASSE2   '
    'TSMIC      '
    'TSMIC2     '
    'TSPOLAR    '
    'TTOMOX     '
    'ZEBRE      '
    'ZEBRETAN   '


Comment =

  64x80 char array

    'Evolution temporelle des 10 NL.                                                 '
    'Evolution temporellution, temperature ionique et rapport isotopique.            '
    'Fonction de distribs totales et partielles He/D2 dans le LPT                    '
    'Calcul des pression courant de bootstrap et d'autres grandeurs associees a une t'
    'Calcul du profil deees du spectro X a cristal                                   '
    'Traitement des donn                                                             '
    'Calorimetrie.      omposants face au plasma �� partir des mesures des r��seaux d'
    'Calorimetrie  des ctrage de DCAMIR                                              '
    'Archivage du parame                                                             '
    '                                                                                '
    '                                                                                '
    '                                                                                '
    '                                                                                '
    '                                                                                '
    '                                                                                '
    '                                                                                '
    '                   ��es r��duites                                               '
    'Production des donn courant et autres grandeurs associees.                      '
    'Calcul du profil deue du code CRONOS  : calcul de la diffusion du courant et du '
    'Execution automatiqe du rayonnement ��mis par un ion  O, C, Cu, Fe, Ni, He .    '
    'Evolution temporell photons detectes emis par les ions issus des elements (Ne, N'
    'Calcul du nombre deuilibre plasma par le code EFIT                              '
    'Reconstruction d'eqquilibre plasma par le code Efit �� partir des donn��es de CR'
    'Reconstruction d'��                                                             '
    '                   re et densite electroniques par diffusion Thomson des 12 spec'
    'Calcul de temperatuature et de la densite eletronique par diffusion THOMSON     '
    'Calcul de la temperl'equilibre du plasma par le code EQUAL...'
    'Recconstruction de s de courant et de decalage SHAFRANOV.                       '
    'Elements des profilau chauffage FCE                                             '
    'Traitement associe ees de FCI.                                                  '
    'Traitement des donnures de surface dans le proche Infrarouge                    '
    'Calcul des temperatl d'emission X-durs                                          '
    'Traitement du profi                                                             '
    'Chauffage Hybride  ction des puissances Hybride et des coefficients de reflexion'
    'Traitement de corremperature ionique par spectroscopie d'echange de charge.     '
    'Traitement de la teITRON et de la duree du plasma.                              '
    'Calcul du temps IGNs.                                                           '
    'Injection de glaconees magnetiques                                              '
    'Traitement des donnees magnetiques temps reel                                   '
    'Correction des donn Parallele des coupleurs Hybride                             '
    'Calcul du spectre Nees de la paroi et des limiteurs (R,Z)                       '
    'Calcul des coordonnes spectrales et des temperatures de surface des aiguilles N1'
    'Calcul  des radiancl de temperature et de densite et Bilan energetique.         '
    'Generation de profient X haute energie (50 keV - 800 keV).                      '
    'Analyse du rayonnem                                                             '
    '                   �flectrom��trie micro-ondes selon l'axe horizontal du plasma '
    'Traitement de la ré mesur��s par le diagnostic de r��flectometrie de centre (DRE'
    'Profils de densit�uilibre plasma par le code IDENT-D                            '
    'Traitement de l'eqance rayonnee et des profils d'emissivite par bolometrie      '
    'Calcul de la puissle de Te calibree sur Michelson pour 6 rayons.                '
    'Evolution temporeladiometrie SuperHeterodyne.                                   '
    'Calcul de Te par Rdes de Langmuir fixes (SLF) �� l'entr��e des gorges sous le li'
    'Traitement des sonremiere sonde de Langmuir mobile (SLM1) avec tete standard en '
    'Traitement de la peuxieme sonde de Langmuir mobile (SLM2) avec tete standard en '
    'Traitement de la ddes de Langmuir pop-up (SLP) sur le limiteur pomp�� toro��dal '
    'Traitement des sonnees du spectrometre de masse (Pompage principal).            '
    'Traitement des donquantification des gaz pompes par le LPT en Q6A et Q6B par spe'
    'Identification et rferometrie Michelson.                                        '
    'Calcul Te par inte                                                              '
    '                  Faraday par polarimetrie.                                     '
    'Calcul des angles l'��missivit�� locale du plasma �� partir des mesures de brill'
    'Reconstruction de rahlung et Camera 2D.                                         '
    'Calcul Zeff Bremstoyenne du plasma �� partir de la ligne de vis��e tangentielle '
    'Calcul de charge me du Ne moyen et piquage.