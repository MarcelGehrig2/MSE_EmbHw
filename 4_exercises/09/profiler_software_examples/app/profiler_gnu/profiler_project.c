/*
 * Module:  Profiler_Project.c.
 * Date:    August 10, 2005
 *
 * This example is used to demonstrate the Profiler Tool 'gprof' and compare 
 * the results to those obtained by the Performance Counter and Timestamp 
 * interval timer peripherals to measure code in the 
 * high_res_timestamp_performance_project application.
 * 
 * Details for executing and comparing these applications can be found in 
 * the Profiling Nios II Systems Application Note.
 */

/*
 * Common C Include
 */

#include <stdio.h>

/*
 * Define for exit()
 */
#include <stdlib.h>

/*
 * Prototype for usleep()
 */
#include <unistd.h>

/*
 * Profiler checksum example header 
 */
#include "checksum_test.h"

int main()
{
  alt_u32 checksum_value;
  
  printf("Hello from Nios II Profiler Checksum Test!\n");

  /* Perform the checksum_test for the sole purpose of providing
   * something to be measured.
   */    
  checksum_value = checksum_test_routine();
       
  printf("Checksum value:              %10ld total.\n", 
         (unsigned long)checksum_value);

  /* If the Profiler Tool, nios2-elf-gprof, will be used, the function main() 
   * must return or the program must call exit to generate the gmon.out 
   * profile data file upon program completion. 
   * This is different from a deployed embedded system, which is typically 
   * designed to run forever, never returning from main().  Production of
   * gmon.out also requires the System Library Property page checkbox to 
   * "Link with profiling library".  Another requirement for correct gmon.out 
   * generation is that the hardware design must contain a timer which is set 
   * as the system clock timer on the system properties page.
   */

  /* Try to leave some time for the I/O to make it out the JTAG UART. 
   * This is necessary when using the profiler, because as soon as the BREAK 2 
   * instruction is executed during the exit(), the application halts and the 
   * debug core takes over and transfers the gmon.out data back to the host.
   */
  usleep (500000);
  exit(0);
}
