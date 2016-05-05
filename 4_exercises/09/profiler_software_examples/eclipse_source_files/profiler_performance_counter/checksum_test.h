#ifndef __CHECKSUM_TEST_H__
#define __CHECKSUM_TEST_H__
/*
 * Module:  Checksum_Test.h
 * Date:    August 10, 2005
 *
 * This test simply calculates a checksum and returns the result.  It is used 
 * by both the profiler_project and high_res_timer_performance_project 
 * applications.  
 */
 
#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

/*
 * Altera types with bit width names
 */
#include "alt_types.h"
 
/* Define the size of the memory block which will be used for
 * measuring the performance of off-chip memory SDRAM. 
 */
#define CHECKSUM_MEMORY_BLOCK_SIZE 32000

/* The checksum_test function demonstrates the functionality of the
 * profiler by providing something to measure.  The test simply does a 
 * checksum calculation and prints the results.  
 */
 
alt_u32 checksum_test (void);

#ifdef __cplusplus
}
#endif

#endif /* __CHECKSUM_TEST_H__ */
