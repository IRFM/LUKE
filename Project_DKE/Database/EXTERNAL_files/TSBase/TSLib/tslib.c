// /////////////////////////////////////////
//
// Software name : LUKE
//
// Authors : Yves Savoye-Peysson and Joan Decker
//
// Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
//
// CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
//
// The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
//
// /////////////////////////////////////////
//
/* ---------------------------------------------------------- 

        point d'entree du module TSLib.dll

-------------------------------------------------------------*/

#include <windows.h>


int FAR PASCAL LibMain( HANDLE hInstance, WORD wDataSeg,
                        WORD wHeapSize, LPSTR lpszCmdLine )
{
        if ( wHeapSize>0 )
                UnlockData( 0 );
        return 1 ;
}



int FAR PASCAL WEP( int nParameter )
{
    if ( nParameter == WEP_SYSTEM_EXIT )
       return 1; 
    else
       if ( nParameter == WEP_FREE_DLL ) 
          return 1 ;
       else
          return 1; 
} 


