/*******************************************************************************
Workfile:		main.c
Revision: 		1.00
Last Modtime: 	2012-6-16
Author: 		fangliang
Description:	

*******************************************************************************/
/********************           COMPILE FLAGS                ******************/

/********************           INCLUDE FILES                ******************/
#include <stdio.h>
#include <version.h>
#include <base/osa.h>
#include <base/osa_debug.h>
/********************              DEFINES                   ******************/

/********************               MACROS                   ******************/

/********************         TYPE DEFINITIONS               ******************/

/********************        FUNCTION PROTOTYPES             ******************/

/********************           LOCAL VARIABLES              ******************/

/********************          GLOBAL VARIABLES              ******************/
extern int OSA_tskTestMain(int argc, char **argv);
/********************              FUNCTIONS                 ******************/
int main(int argc,char **argv)
{
	OSA_DEBUG;
    printf("hello world\n");
    OSA_init();
    OSA_tskTestMain(argc,argv);
    OSA_exit();

    return 0;
}
