/*
 ============================================================================
 Name        : exercise9_on_x86_LinuxGCC.c
 Author      : 
 Version     :
 Copyright   : Your copyright notice
 Description : Hello World in C, Ansi-style
 ============================================================================
 */

#include <stdio.h>
#include <stdlib.h>

int main(void) {
	puts("!!!Hello World!!!"); /* prints !!!Hello World!!! */




	  int trace;
	  trace++;
	  trace++;
	  trace++;



	  // original (slow)
	  int i, w, x[1000], y[1000];
	  for (i = 0; i < 1000; i++) {
		  x[i] = x[i] + y[i];
		  if (w)
			  y[i] = 0;
	  }



	  trace++;
	  trace++;


	  // unswitched (faster)
	  int i2, w2, x2[1000], y2[1000];
	  if (w2) {
		  for (i2 = 0; i2 < 1000; i2++) {
			  x2[i2] = x2[i2] + y2[i2];
			  y2[i2] = 0;
		  }
	  } else {
		  for (i2 = 0; i2 < 1000; i2++) {
			  x2[i2] = x2[i2] + y2[i2];
		  }
	  }




	return EXIT_SUCCESS;
}
