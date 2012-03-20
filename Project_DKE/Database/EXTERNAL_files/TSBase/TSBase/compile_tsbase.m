function compile_tsbase
mex -v tsbase.c tsignit.c tsparse.c -L../TSLib_Client_Linux64/ -lTS
