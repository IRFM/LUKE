function compile_tsbase
mex -v tsbase.c tsignit.c tsparse.c -L../TSLib/ -lTS
mex -v tsmat.c tsignit.c tsparse.c -L../TSLib/ -lTS
mex -v tsdernier_choc.c tsignit.c tsparse.c -L../TSLib/ -lTS
