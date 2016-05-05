/*
 * main.c
 *
 *  Created on: May 4, 2016
 *      Author: mgehrig2
 */




/****************************************************************************
 * Copyright (C) 2016 by Theo Kluter                                        *
 *                                                                          *
 * This file is part of TSM_EmbHardw (MSE) sobel exercise                   *
 *                                                                          *
 *   lab1 ex is free software: you can redistribute it and/or modify it     *
 *   under the terms of the GNU Lesser General Public License as published  *
 *   by the Free Software Foundation, either version 3 of the License, or   *
 *   (at your option) any later version.                                    *
 *                                                                          *
 *   SMS is distributed in the hope that it will be useful, to students     *
 *   following the course BTF1230 at Bern University but WITHOUT ANY        *
 *   WARRANTY. See the GNU Lesser General Public License for more details.  *
 *                                                                          *
 *   You should have received a copy of the GNU Lesser General Public       *
 *   License along with MSE-SE. If not, see <http://www.gnu.org/licenses/>. *
 ****************************************************************************/
/**
 * @file main.c
 * @author Theo KLUTER
 * @author Andreas HABEGGER
 * @date Apr 13, 2016
 * @brief Introduction to Embedded Hardwar System Engineering
 *
 * @copyright GNU Lesser General Public License
 * @see http://www.msengineering.ch/
 * @bug currently no bugs
 * @todo no open tasks
 */

#include <stdio.h>
#include <system.h>
#include <stdlib.h>
#include <io.h>

#include "altera_avalon_performance_counter.h"


#define PERFORMANCE_COUNTER_0_BASE 0x1001000

int main(void)
{
  printf("Hello from Nios II! 2\n");

  int average_total_global_time=0;

  int glob_i;
  for (glob_i = 0; glob_i < 1; glob_i++) {

	  // Reset the counters before every run
	  PERF_RESET (PERFORMANCE_COUNTER_0_BASE);				//Reset Performance Counters to 0
	  PERF_START_MEASURING (PERFORMANCE_COUNTER_0_BASE);	// Start the global Counter


	  //Measure Counter overhead
	  PERF_BEGIN (PERFORMANCE_COUNTER_0_BASE,1);		//Start overhead Counter
	  PERF_BEGIN (PERFORMANCE_COUNTER_0_BASE,7);		//Start Dummy measurement
	  PERF_END (PERFORMANCE_COUNTER_0_BASE,7);			//Stop Dummy measurement
	  PERF_END (PERFORMANCE_COUNTER_0_BASE,1);			//Stop overhead measurement


	  // original (slow) (loop1)
	  PERF_BEGIN (PERFORMANCE_COUNTER_0_BASE,2);		//Start Counter loop1
	  int i, w, x[1000], y[1000];
	  for (i = 0; i < 1000; i++) {
		  x[i] = x[i] + y[i];
		  if (w)
			  y[i] = 0;
	  }
	  PERF_END (PERFORMANCE_COUNTER_0_BASE,2);			//Stop Counter loop1



	  // unswitched (faster) (loop2)
	  PERF_BEGIN (PERFORMANCE_COUNTER_0_BASE,3);		//Start Counter loop2
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
	  PERF_END (PERFORMANCE_COUNTER_0_BASE,3);			//Stop Counter loop2

//	  // Performance test result
//	  printf("loop 1\t:%d\n", perf_get_total_time(PERFORMANCE_COUNTER_0_BASE));
//	  average_total_global_time += perf_get_total_time(PERFORMANCE_COUNTER_0_BASE);
//	  perf_print_formatted_report((void *)PERFORMANCE_COUNTER_0_BASE, ALT_CPU_FREQ, 7,
//	    "Overhead","Loop1","Loop2","Counter4","Counter5","Counter6","Dummy");

  }

  // Performance average test result
//  printf("Average global time\t:%d\n", average_total_global_time/(glob_i));
//  printf("number of Measurements\t:%d\n", glob_i);

  printf("The following report shows only the last measurement:\n");
  perf_print_formatted_report((void *)PERFORMANCE_COUNTER_0_BASE, ALT_CPU_FREQ, 7,
    "Overhead","Loop1","Loop2","Counter4","Counter5","Counter6","Dummy");

  return 0;
}
