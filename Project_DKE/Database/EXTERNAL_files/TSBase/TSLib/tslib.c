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


