#
# mexopts.sh	Shell script for configuring MEX-file creation script,
#               mex.  These options were tested with the specified compiler.
#
# usage:        Do not call this file directly; it is sourced by the
#               mex shell script.  Modify only if you don't like the
#               defaults after running mex.  No spaces are allowed
#               around the '=' in the variable assignment.
#
# SELECTION_TAGs occur in template option files and are used by MATLAB
# tools, such as mex and mbuild, to determine the purpose of the contents
# of an option file. These tags are only interpreted when preceded by '#'
# and followed by ':'.
#
#SELECTION_TAG_MEX_OPT: Template Options file for building MEX-files via the system ANSI compiler
#
# Copyright 1984-2004 The MathWorks, Inc.
# $Revision$  $Date$
#----------------------------------------------------------------------------
#
    TMW_ROOT="$MATLAB"
    MFLAGS=''
    if [ "$ENTRYPOINT" = "mexLibrary" ]; then
        MLIBS="-L$TMW_ROOT/bin/$Arch -lmx -lmex -lmat -lmwservices -lut"
    else  
        MLIBS="-L$TMW_ROOT/bin/$Arch -lmx -lmex -lmat"
    fi
    case "$Arch" in
        Undetermined)
#----------------------------------------------------------------------------
# Change this line if you need to specify the location of the MATLAB
# root directory.  The script needs to know where to find utility
# routines so that it can determine the architecture; therefore, this
# assignment needs to be done while the architecture is still
# undetermined.
#----------------------------------------------------------------------------
            MATLAB="$MATLAB"
            ;;
        glnx86)
#----------------------------------------------------------------------------
            RPATH="-Wl,-rpath-link,$TMW_ROOT/bin/$Arch"
#           gcc -v
#           gcc version 3.2.3
            CC='gcc'
            CFLAGS='-fPIC -ansi -D_GNU_SOURCE -pthread -fexceptions -m32'
            CLIBS="$RPATH $MLIBS -lm -lstdc++"
            COPTIMFLAGS='-O -DNDEBUG'
            CDEBUGFLAGS='-g'
#           
#           g++ -v
#           gcc version 3.2.3
            CXX='g++'
            CXXFLAGS='-fPIC -ansi -D_GNU_SOURCE -pthread '
            CXXLIBS="$RPATH $MLIBS -lm"
            CXXOPTIMFLAGS='-O -DNDEBUG'
            CXXDEBUGFLAGS='-g'
#
#           g77 -fversion
#           GNU Fortran (GCC 3.2.3) 3.2.3 20030422 (release)
#           NOTE: g77 is not thread safe
            FC='g77'
            FFLAGS='-fPIC -fexceptions'
            FLIBS="$RPATH $MLIBS -lm -lstdc++"
            FOPTIMFLAGS='-O'
            FDEBUGFLAGS='-g'
#
            LD="$COMPILER"
            LDEXTENSION='.mexglx'
            LDFLAGS="-pthread -shared -m32 -Wl,--version-script,$TMW_ROOT/extern/lib/$Arch/$MAPFILE"
            LDOPTIMFLAGS='-O'
            LDDEBUGFLAGS='-g'
#
            POSTLINK_CMDS=':'
#----------------------------------------------------------------------------
            ;;
        glnxa64)
#----------------------------------------------------------------------------
            RPATH="-Wl,-rpath-link,$TMW_ROOT/bin/$Arch"
#           gcc -v
#           gcc version 3.2.3
            CC='gcc'
            CFLAGS='-fPIC -fno-omit-frame-pointer -ansi -D_GNU_SOURCE -pthread -fexceptions'
            CLIBS="$RPATH $MLIBS -lm -lstdc++"
            COPTIMFLAGS='-O -DNDEBUG'
            CDEBUGFLAGS='-g'
#           
#           g++ -v
#           gcc version 3.2.3
            CXX='g++'
            CXXFLAGS='-fPIC -fno-omit-frame-pointer -ansi -D_GNU_SOURCE -pthread '
            CXXLIBS="$RPATH $MLIBS -lm"
            CXXOPTIMFLAGS='-O -DNDEBUG'
            CXXDEBUGFLAGS='-g'
#
#           g77 -fversion
#           GNU Fortran (GCC 3.2.3) 3.2.3 20030422 (release)
#           NOTE: g77 is not thread safe
            FC='/usr/local/pgi/linux86-64/6.0/bin/pgf90'
#           FFLAGS='-fPIC -fno-omit-frame-pointer -fexceptions'
            FFLAGS='-fPIC -fastsse -r8'
#            FLIBS="$RPATH -L/usr/local/nag/fll6a20dpl/lib $MLIBS -lm -lstdc++ -lacml -lg2c"
            FLIBS="$RPATH -L/usr/local/nag/fll6a20dpl/lib $MLIBS"
            FOPTIMFLAGS=''
            FDEBUGFLAGS='-C -g'
#
            LD="$COMPILER"
            LDEXTENSION='.mexa64'
#            LDFLAGS="-pthread -shared -Wl,--version-script,$TMW_ROOT/extern/lib/$Arch/$MAPFILE"
            LDFLAGS="-shared -fPIC"
            LDOPTIMFLAGS=''
            LDDEBUGFLAGS='-C -g'
#
            POSTLINK_CMDS=':'
#----------------------------------------------------------------------------
            ;;
        mac)
#----------------------------------------------------------------------------
#           gcc-3.3 -v
#           gcc version 3.3 20030304 (Apple Computer, Inc. build 1435)
            CC='gcc-3.3'
            CFLAGS='-fno-common -no-cpp-precomp -fexceptions'
            CLIBS="$MLIBS -lstdc++"
            COPTIMFLAGS='-O3 -DNDEBUG'
            CDEBUGFLAGS='-g'
#
            CXX=g++-3.3
            CXXFLAGS='-fno-common -no-cpp-precomp -fexceptions'
            CXXLIBS="$MLIBS -lstdc++"
            CXXOPTIMFLAGS='-O3 -DNDEBUG'
            CXXDEBUGFLAGS='-g'
#
            FC='/Applications/Absoft/bin/f90'
            FFLAGS='-YEXT_NAMES=LCS -YEXT_SFX=_ -N11 -s -Q51'
            ABSOFTLIBDIR=`which $FC | sed -n -e '1s|bin/'$FC'|lib|p'`
#            FLIBS="-L$ABSOFTLIBDIR -lfio -lf77math"
#            ABSOFTLIBDIR=`which $FC | sed -n -e '1s|bin/'$FC'|lib|p'`
            FLIBS="-L/Applications/Absoft/lib/ -lfio -lf77math"
            FOPTIMFLAGS='-O -cpu:g4'
            FDEBUGFLAGS='-g'
#
            LD="$CC"
            LDEXTENSION='.mexmac'
            LDFLAGS="-bundle -Wl,-flat_namespace -undefined suppress -Wl,-exported_symbols_list,$TMW_ROOT/extern/lib/$Arch/$MAPFILE"
            LDOPTIMFLAGS='-O'
            LDDEBUGFLAGS='-g'
#
            POSTLINK_CMDS=':'
#----------------------------------------------------------------------------
            ;;
    esac
#############################################################################
#
# Architecture independent lines:
#
#     Set and uncomment any lines which will apply to all architectures.
#
#----------------------------------------------------------------------------
#           CC="$CC"
#           CFLAGS="$CFLAGS"
#           COPTIMFLAGS="$COPTIMFLAGS"
#           CDEBUGFLAGS="$CDEBUGFLAGS"
#           CLIBS="$CLIBS"
#
#           FC="$FC"
#           FFLAGS="$FFLAGS"
#           FOPTIMFLAGS="$FOPTIMFLAGS"
#           FDEBUGFLAGS="$FDEBUGFLAGS"
#           FLIBS="$FLIBS"
#
#           LD="$LD"
#           LDFLAGS="$LDFLAGS"
#           LDOPTIMFLAGS="$LDOPTIMFLAGS"
#           LDDEBUGFLAGS="$LDDEBUGFLAGS"
#----------------------------------------------------------------------------
#############################################################################
