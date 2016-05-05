/*
 * Module:  high_res_timestamp_performance_project.c.
 * Date:    August 10, 2005
 *
 * This example is used to demonstrate the Performance Counter and Timestamp 
 * interval timer peripherals to measure code and compare 
 * the results to those obtained by the Profiler Tool 'gprof' in the 
 * Profiler_Project application.
 * 
 * Details for executing and comparing these applications can be found in 
 * the Profiling Nios II Systems Application Note.
 */

/*
 *  Common C Includes
 */
#include <stdio.h>
#include <unistd.h>

/*
 *  Altera types with bit width names
 */
#include "alt_types.h"

/*
 * Definitions for the Timestamp interval timer peripheral
 */
#include "sys/alt_timestamp.h"

/*
 *  Definition for the Performance Counter Peripheral
 */
#include "altera_avalon_performance_counter.h"

/*
 *  Description of the SOPC Builder configured Nios II system
 */
#include  "system.h"

/*
 * Profiler checksum example header 
 */
#include "checksum_test.h"

/* Declare names for section counters #1 - #3 of the performance 
 * counter peripheral.  Use section counter #1 to measure the checksum_test() 
 * function, section counter #2 to measure the minimal overhead of invoking
 * the PERF_BEGIN macro itself, and section counter #3 to measure the overhead 
 * of using alt_timestamp() to do performance measurements as oppossed to the 
 * performance counter.  
 */

/*
 *  Section Counter #1
 */
#define CHECKSUM_TEST_SECTION 1

/*
 *  Section Counter #2
 */
#define MEASURE_OVERHEAD_CHECKSUM_TEST_SECTION 2

/*
 *  Section Counter #3
 */
#define MEASURE_OVERHEAD_TIMESTAMP_SECTION 3

/*
 *  NOTE: PERF_END macro takes the same amount of overhead in cpu cycles 
 *        as PERF_BEGIN.
 */

/*
 *  NOTE: Counter #0 is reserved for the global section counter,
 *        which keeps track of the total elapsed time for things
 *        measured with PERFORMANCE_COUNTER.
 *        Stopping the global setion counter stops all section counters 
 *        associated with that particular performance counter.  
 */
 
/*
 *  NOTE: User section counter-numbers range from #1 to
 *        the maximum performance counters as configured for a particular 
 *        performance counter peripheral in SOPC Builder 
 *        (SOPC Builder Default: 3, SOPC Builder Maximum: 7).
 *        The variable in system.h which holds the maximum number
 *        of section counters for a particular performance counter is 
 *        PERFORMANCE_COUNTER_HOW_MANY_SECTIONS, where
 *        PERFORMANCE_COUNTER is the name assigned in SOPC Builder
 *        for a particular performance counter peripheral.
 */


/*
 *  C main 
 */
int main(void)
{

  /* 
   * Hold the value the the function whose performance we are measuring. 
   */
  alt_u32 checksum_value;
 
  /* 
   * Sample value of the Timestamp timer at the start of checksum_test. 
   */
  alt_u32 checksum_start_time; 
   
  /* 
   * Sample value of the Timestamp timer at the end of checksum_test. 
   */
  alt_u32 checksum_end_time;
   
  /* 
   * Sample value of the Timestamp timer immediately following a previous 
   * sampling of the Timestamp timer for the purpose of determining the 
   * time elapsed during the measurement itself.
   */
  alt_u32 timestamp_overhead_time;

  /* Sample value of the Timestamp timer which is discarded.  It holds
   * the return value of alt_timestamp() when we measure the time elapsed 
   * during the call to alt_timestamp() with a performance counter. 
   */  
  alt_u32 timestamp_discard_time;
   
  /* 
   * Reset (initialize to zero) all section counters and the global 
   * counter of the performance_counter peripheral.
   */
  PERF_RESET (PERIPHERAL_SUBSYSTEM_PERFORMANCE_COUNTER_BASE);

  /*
   *  First, do things that we don't want to measure:        
   */
  printf("Hello from Nios II Performance Checksum Test!\n");
 
  /*
   * Now our program starts in earnest.  Begin measuring.
   */
 
  /*
   * Start the performance counter peripheral's global counter, thereby
   * enabling all of the section counters of performance_counter.
   */
  PERF_START_MEASURING (PERIPHERAL_SUBSYSTEM_PERFORMANCE_COUNTER_BASE);
   
  PERF_BEGIN (PERIPHERAL_SUBSYSTEM_PERFORMANCE_COUNTER_BASE, 
              MEASURE_OVERHEAD_CHECKSUM_TEST_SECTION);

  /*
   *  Performance Counter macro to begin timing of CHECKSUM_TEST_SECTION.
   */
  PERF_BEGIN (PERIPHERAL_SUBSYSTEM_PERFORMANCE_COUNTER_BASE, CHECKSUM_TEST_SECTION);
   
  /* Each performance counter measurement macro is minimally intrusive, 
   * consisting of only a few assembly instructions each. 
   * Measure the overhead of the PERF_BEGIN macro.
   */
  PERF_END (PERIPHERAL_SUBSYSTEM_PERFORMANCE_COUNTER_BASE,        
            MEASURE_OVERHEAD_CHECKSUM_TEST_SECTION);
                 
  /*
   * Perform the checksum_test for the sole purpose of providing
   * something to be measured. This first invocation is the one reported in the 
   * Performance Counter report.   
   */
  checksum_value = checksum_test();

  PERF_END (PERIPHERAL_SUBSYSTEM_PERFORMANCE_COUNTER_BASE, CHECKSUM_TEST_SECTION);

  /*
   * Run the same test again, but this time measure with Timestamp timer 
   * named high_res_timer interval timer peripheral, marked on the Nios II IDE 
   * System Properties page as the Timestamp timer.
   * 
   * Configure high_res_timer as a 1 microsecond interval timer (changed
   * from the default value of 1 millisecond in the Standard Nios II design
   * by editing the properties for high_res_timer in SOPC Builder).
   *
   * Verify that a Timestamp timer has been configured for this Nios II
   * system before we try to measure with it. 
   */  
  if (alt_timestamp_start() < 0)
  {
    printf ("No timestamp device is available.\n");
  }
  else
  {
    /*
     * Sample the timestamp timer value just before the checksum_test.
     */
    checksum_start_time = alt_timestamp();
      
    /* Perform the second checksum_test for the sole purpose of providing
     * something to be measured. This second invocation is measured by the 
     * timestamp.  
     */ 
    checksum_value = checksum_test();

    /* Sample the timestamp timer value just after the checksum_test.  The
     * difference between checksum_start_time and checksum_end_time will give 
     * us the number of ticks elapsed during the call to checksum_test.      
     */
    checksum_end_time = alt_timestamp();
      
    /*
     * Measure the time overhead to read the timestamp timer by subsequently
     * calling alt_timestamp() back to back.
     */
    timestamp_overhead_time = alt_timestamp();
      
    /* Measure the overhead of alt_timestamp() again, this time using the 
     * faster, less intrusive method of employing a performance counter to 
     * measure the alt_timestamp().
     */
    PERF_BEGIN (PERIPHERAL_SUBSYSTEM_PERFORMANCE_COUNTER_BASE, 
                MEASURE_OVERHEAD_TIMESTAMP_SECTION);
               
    /* Invoke alt_timestamp() to measure how long the call takes, 
     * discarding the result.
     */
    timestamp_discard_time = alt_timestamp();
      
    PERF_END (PERIPHERAL_SUBSYSTEM_PERFORMANCE_COUNTER_BASE, 
              MEASURE_OVERHEAD_TIMESTAMP_SECTION);

    /*
     * Print-out the Timestamp interval timer peripheral measurements.       
     */
    printf("timestamp measurement for checksum_test = %u ticks\n", 
           (unsigned int) (checksum_end_time - checksum_start_time));              
    printf("timestamp measurement overhead = %u ticks\n", 
           (unsigned int) (timestamp_overhead_time - checksum_end_time)); 
    printf("Actual time in checksum_test = %u ticks\n",
           (unsigned int) ((checksum_end_time - checksum_start_time) - 
           (timestamp_overhead_time - checksum_end_time)));       
    printf("Timestamp timer frequency = %u\n", 
           (unsigned int)alt_timestamp_freq());
  }
      
  /*
   * Stop all performance_counter activity via its global_counter.
   */
   PERF_STOP_MEASURING (PERIPHERAL_SUBSYSTEM_PERFORMANCE_COUNTER_BASE);
   
   /*
    * Print-out the performance counter peripheral measurement
    * results for all section counters of performance_counter,
    * so we can visually analyze and compare the performance counter
    * measurement results with the timestamp interval timer results.  
    * The performance counter report goes to STDOUT 
    * (Nios2-console window in the IDE by default).
    * perf_print_formatted_report() is a Performance Counter Peripheral 
    * function.
    */

  perf_print_formatted_report( 
     (void *)PERIPHERAL_SUBSYSTEM_PERFORMANCE_COUNTER_BASE, // Peripheral's HW base address            
      ALT_CPU_FREQ,             // defined in "system.h"
      3,                        // How many sections to print
      "1st checksum_test",         // Display-names of sections
      "pc_overhead",
      "ts_overhead");  
       

  printf("Goodbye from Nios II - returning from main()!\n");   
  return 0;
}

/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2005 Altera Corporation, San Jose, California, USA.           *
* All rights reserved.                                                        *
*                                                                             *
* Permission is hereby granted, free of charge, to any person obtaining a     *
* copy of this software and associated documentation files (the "Software"),  *
* to deal in the Software without restriction, including without limitation   *
* the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
* and/or sell copies of the Software, and to permit persons to whom the       *
* Software is furnished to do so, subject to the following conditions:        *
*                                                                             *
* The above copyright notice and this permission notice shall be included in  *
* all copies or substantial portions of the Software.                         *
*                                                                             *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
* DEALINGS IN THE SOFTWARE.                                                   *
*                                                                             *
* This agreement shall be governed in all respects by the laws of the State   *
* of California and by the laws of the United States of America.              *
*                                                                             *
******************************************************************************/
