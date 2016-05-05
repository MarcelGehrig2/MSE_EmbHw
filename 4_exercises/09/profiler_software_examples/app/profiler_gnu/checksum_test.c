/*
 * Module:  Checksum_Test.c
 * Date:    August 10, 2005
 *
 * This test simply calculates a checksum and returns the result.  It is used 
 * by both the profiler_project and high_res_timer_performance_project 
 * applications.  
 */

/*
 * Common C Includes
 */
#include <stdio.h>
#include <time.h>
/*
 * Altera cache definitions
 */
#include "sys/alt_cache.h"

/*
 * Profiler checksum example header 
 */
#include "checksum_test.h"
 
alt_u32 checksum_test_routine(void){
  alt_u32 offset; /* index used to fill memory blocks and calculate checksum */
  alt_u32 sdram_memory_block[CHECKSUM_MEMORY_BLOCK_SIZE];
  alt_u32 *sdram_memory_ptr;
  alt_u32 *sdram_memory_end_ptr;
  volatile alt_u32 sdram_checksum;

  register alt_u32 checksum_calculation_bucket_A;
  register alt_u32 checksum_calculation_bucket_B;
  register alt_u32 checksum_calculation_bucket_C;
  register alt_u32 checksum_calculation_bucket_D;

  sdram_checksum = 0;

  /* Initialize pointer to the start addresses of the
   * memory block for which access speed will be measured.
   */
  sdram_memory_ptr = (alt_u32 *)sdram_memory_block;
  
  /* Initialize pointer to the end of memory block to measure */
  sdram_memory_end_ptr = (sdram_memory_ptr + CHECKSUM_MEMORY_BLOCK_SIZE);

  /* Fill memory block with values, then time how long the checksum 
   * calculation takes for the data block, thereby measuring
   * the performance of off-chip memory SDRAM. */  
  for (offset = 0; offset < CHECKSUM_MEMORY_BLOCK_SIZE; offset++) 
  {  
    *sdram_memory_ptr = (offset % 0xFF);
     sdram_memory_ptr += 1;        
  }
  /* Calculate checksums for sdram memory block. */ 
  /* The checksum calculation loop has been "unrolled" to maximize 
   * parallelization during data read latency periods.  Memory reads are
   * done 4 at a time.  Then a sum is performed. This ordering of 4 reads 
   * followed by 4 summations streamlines data reads on the Avalon bus 
   * The first data element will have some amount of read latency associated
   * with the data access, so the instructions are issued to start reading
   * the other 3 data elements, since the summation instruction cannot operate
   * on the first data element until the data value has been retrieved from
   * memory.  The other data element values are retreived from memory in 
   * parallel during the summation of the first data element values. */

  /* Loop many time to increase time for demonstration purposes.
   */
  for (offset = 0; offset < 300; offset++) 
  {  
    sdram_checksum = 0;

    /* Flush the Data Cache */
    alt_dcache_flush_all();

    checksum_calculation_bucket_A = 0;
    checksum_calculation_bucket_B = 0;
    checksum_calculation_bucket_C = 0;
    checksum_calculation_bucket_D = 0;
    
    /* Calculate the checksum */ 
    for (sdram_memory_ptr = (alt_u32 *)sdram_memory_block;
       sdram_memory_ptr < sdram_memory_end_ptr;
       sdram_memory_ptr+=4)
    {
      checksum_calculation_bucket_A += *sdram_memory_ptr;
      checksum_calculation_bucket_B += *(sdram_memory_ptr + 1);
      checksum_calculation_bucket_C += *(sdram_memory_ptr + 2);
      checksum_calculation_bucket_D += *(sdram_memory_ptr + 3);
    }  
    
    sdram_checksum += checksum_calculation_bucket_A;
    sdram_checksum += checksum_calculation_bucket_B;
    sdram_checksum += checksum_calculation_bucket_C;
    sdram_checksum += checksum_calculation_bucket_D; 
      
  }
  
  return (sdram_checksum);
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
