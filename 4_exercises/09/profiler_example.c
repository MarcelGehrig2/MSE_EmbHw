#include <stdio.h>
#include <string.h>
#include "system.h"
#include "nios2.h"
#include <unistd.h>
#include "altera_avalon_performance_counter.h"

int main()
{
  volatile int i,j,k; //i = row, j = column,
  int count;
  int M1[10][10]={0,0,0,0,0,0,0,0,0,0,
                    32,32,33,34,32,32,33,34,32,32,
                    32,32,33,34,32,32,33,34,32,32,
                    32,32,33,34,32,32,33,34,32,32,
                    32,32,33,34,32,32,33,34,32,32,
                    19,32,33,34,32,32,33,34,32,32,                    
                    32,32,33,34,32,32,33,34,32,32,
                    32,32,33,34,32,32,33,34,32,32,
                    32,32,33,34,32,32,33,34,32,32,
                    19,32,33,34,32,32,33,34,32,32};  

  int M2[10][10]={32,32,33,34,32,32,33,34,32,32,
                    32,32,33,34,32,32,33,34,32,32,
                    32,32,33,34,32,32,33,34,32,32,
                    32,32,33,34,32,32,33,34,32,32,
                    32,32,33,34,32,32,33,34,32,32,
                    19,32,33,34,32,32,33,34,32,32,                    
                    32,32,33,34,32,32,33,34,32,32,
                    32,32,33,34,32,32,33,34,32,32,
                    32,32,33,34,32,32,33,34,32,32,
                    19,32,33,34,32,32,33,34,32,32};
  int C[10][10]={0};

  PERF_RESET (PERFORMANCE_COUNTER_BASE);            //Reset Performance Counters to 0

  PERF_START_MEASURING (PERFORMANCE_COUNTER_BASE);  //Start the Counter

  PERF_BEGIN (PERFORMANCE_COUNTER_BASE,2);          //Start the overhead counter
    PERF_BEGIN (PERFORMANCE_COUNTER_BASE,1);        //Start the Matrix Multiplication Counter
  PERF_END (PERFORMANCE_COUNTER_BASE,2);            //Stop the overhead counter

  count = 0;
  while(count<100){
  count++;
    for (i=0;i<=9;i++){
      for (j=0;j<=9;j++){
        C[i][j] = 0;
        for (k=0;k<=9;k++){
          C[i][j]+=M1[i][k]*M2[k][j];
        }
        //printf("%f ", C[i][j]);
      }
    }
  }

  PERF_END (PERFORMANCE_COUNTER_BASE,1);            //Stop the Matrix Multiplication Counter
  PERF_STOP_MEASURING (PERFORMANCE_COUNTER_BASE);   //Stop all counters
  
  perf_print_formatted_report((void *)PERFORMANCE_COUNTER_BASE, ALT_CPU_FREQ, 2,
  "100 loops","PC overhead");  
    
  return 0;
}
