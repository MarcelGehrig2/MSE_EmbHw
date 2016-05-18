/*
 * main_10b2.c
 *
 *  Created on: May 6, 2016
 *      Author: mgehrig2
 */



/*
 * main.c
 *
 *  Created on: May 4, 2016
 *      Author: mgehrig2
 */


#include <stdio.h>
#include <system.h>
#include <stdlib.h>
#include <io.h>

#include <sys/alt_cache.h>	//for cache instruction

#include "altera_avalon_performance_counter.h"


#define PERFORMANCE_COUNTER_0_BASE 0x1001000

int main(void)
{
  printf("Hello from Nios II!\n");


  // Reset the counters before every run
  PERF_RESET (PERFORMANCE_COUNTER_0_BASE);				//Reset Performance Counters to 0
  PERF_START_MEASURING (PERFORMANCE_COUNTER_0_BASE);	// Start the global Counter


  //Measure Counter overhead
  PERF_BEGIN (PERFORMANCE_COUNTER_0_BASE,1);		//Start overhead Counter
  PERF_BEGIN (PERFORMANCE_COUNTER_0_BASE,7);		//Start Dummy measurement
  PERF_END (PERFORMANCE_COUNTER_0_BASE,7);			//Stop Dummy measurement
  PERF_END (PERFORMANCE_COUNTER_0_BASE,1);			//Stop overhead measurement


  // original
  int N = 1000;
  int i, ip, a[N], b[N];

  PERF_BEGIN (PERFORMANCE_COUNTER_0_BASE,2);		//Start loop without malloc

  for (i = 0; i < N-4; i+=4) {
	  ip =  ip + a[i]  *b[i];
	  ip =  ip + a[i+1]*b[i+1];
	  ip =  ip + a[i+2]*b[i+2];
	  ip =  ip + a[i+3]*b[i+3];
  }
  for ( ; i < N; i++)
	  ip = ip + a[i]*b[i];
  PERF_END (PERFORMANCE_COUNTER_0_BASE,2);			//Stop loop without malloc



  // optimized
  int i2, ip2, a2[N], b2[N];
  PERF_BEGIN (PERFORMANCE_COUNTER_0_BASE,3);		//Start with malloc
  malloc( &ip2);
  malloc( &a2[0]);
  malloc( &b2[0]);

  for (i2 = 0; i2 < N-4; i2+=4) {
	  malloc( &a2[0]);
	  malloc( &b2[0]);
	  ip2 =  ip2 + a2[i2]  *b2[i2];
	  ip2 =  ip2 + a2[i2+1]*b2[i2+1];
	  ip2 =  ip2 + a2[i2+2]*b2[i2+2];
	  ip2 =  ip2 + a2[i2+3]*b2[i2+3];
  }
  for ( ; i < N; i++)
	  ip2 = ip2 + a[i]*b2[i];

  PERF_END (PERFORMANCE_COUNTER_0_BASE,3);			//Stop with malloc


  perf_print_formatted_report((void *)PERFORMANCE_COUNTER_0_BASE, ALT_CPU_FREQ, 7,
    "Overhead","without malloc","with malloc","Counter4","Counter5","Counter6","Dummy");

  return 0;
}


