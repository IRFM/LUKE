Le dossier Packages rassemble les programmes libres pour le calcul matriciel séquentiel, en mémoire partagée ou distribuée. Il contient également les environnements MPI (Message Passing Interface) pour le calcul parallèle: MPICH, et OPENMPI, ce dernier rassemblant LAM/MPI et OPENMP, ce qui permet d'intégrer à la fois le calcul en mémoire partagée ou distribuée en un seul environnement. 
L'organistaion du dossier est la suivante:

~/Packages/Bench: programmes de tests de performances et de comparaison des méthodes
~/Packages/Bin: les outils compilés
~/Packages/Source: les sources sous forme compressées.
~/Packages/Doc: la documentation en vrac, qui a permis de progresser

Pour installer un nouveau package:
	1) créer un sous-dossier dans ~/Packages/Source/NOMPACKAGE dont le nom (en majuscule) correspond à la fonctionnalité générale de l'objet
	2) placer le source sous forme compressée, en n'omettant pas de mettre la version dans le nom de l'archive, genre package-1.2.3b.tar.gz
	3) décompresser celle-ci
	4) déplacer le dossier décompressé package-1.2.3b dans un sous-dossier ~/Packages/Bin/NOMPACKAGE et le renommer sous la forme  package-1.2.3b-S-<compilateur> lorsque le programme fonctionne en séquentiel, ou package-1.2.3b-P-<mpienv+compilateur>, s'il est compilé pour fonctionner en calcul parallèle. A noter qu'il peut y avoir plusieurs versions du même package, en mode séquentiel, ou en mode parallèle. Dans ce cas créer autant de dossier package-1.2.3b-X-Y qu'il faut, pour que l'on puisse les utiliser de façon indépendante.
	5) dans le dossier ~/Packages/Bin/NOMPACKAGE, créer un fichier readme_NOMPACKAGE.txt qui contient l'intégralité des recettes pour compiler les différentes formes de ce package et le rendre ainsi opérationnel

Pour installer une nouvelle version d'un package:
	1) la télécharger depuis internet
	2) placer l'archive dans le dossier source ~/Packages/Source/NOMPACKAGE correspondant. Bien veiller à faire apparaître le numéro de version. 
	3) suivre les instructions comme pour l'installation d'un nouveau package, 3), 4) et 5)

Les procédures pour compiler les packages étant dépendantes des systèmes ainsi que des processeurs, il est indispensable de placer celles-ci sous contrôle CVS. A ce titre, afin de préserver au maximum l'intégrité du package, on ne sauvegarde qu'un fichier de configuration (Makefile.in, Bmake.inc, SLmake.in,...) sous la forme (Makefile.arch, Bmake.arch, SLmake.arch,...) où l'architecture est caractérisée par *.arch, sous la forme *.OSXPPCG4 par exemple, signifiant que le script de compilation n'est valable que pour le système OS X d'Apple, avec processeur PowerPC (PPC) de type G4. On peut ainsi faire cohabiter des scripts d'autres architectures (Windows, linux, avec processeurs Intel ou AMD par exemple). Dans chaque sous dossier ~/Packages/Bin/NOMPACKAGE, il existe un script make_NOMPACKAGE. Pour exécuter la fonction make du package, il faut taper la commande ./make_NOMPACKAGE <arch> <liste des options>. Le passage de paramètres <liste des options> à make_NOMPACKAGE est alors le même qu'un make, et il ne reste plus qu'à modifier le fichier Makefile.arch qui est le seul sous contrôle CVS. 

ATTENTION: il est indispensable de mettre sous contrôle CVS tout fichier du package qui aurait été modifié pour une raison quelconque (bug, etc...)

                                                 ------------------------

