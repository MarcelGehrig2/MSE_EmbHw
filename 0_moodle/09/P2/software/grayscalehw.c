// This functions converts a rgb-encoded picture into a grayscale version of it
#include "grayscalehw.h"
#include <stdio.h>

#define CPU_FREQUENCY (50000000.0)

#define __ISE 1

void rgb_to_grayscale( int width,
		               int height,
		               const unsigned int *rgb_source,
		               unsigned int *grayscale_destination) {
	int loop;
	unsigned int temp;
	unsigned int grayscale;

#ifndef __ISE
	for (loop = 0 ; loop < width*height ; loop++) {
		  temp = rgb_source[loop]&0xFF; // red value
		  grayscale = (temp*30)/100;
		  temp = (rgb_source[loop]>>8)&0xFF; // green value
		  grayscale += (temp*59)/100;
		  temp = (rgb_source[loop]>>16)&0xFF; // blue value
		  grayscale += (temp*11)/100;
		  grayscale_destination[loop] = grayscale|(grayscale<<8)|(grayscale<<16);
	  }
#else
	unsigned int counter_value,orig_code_count;
	double nr_of_secs;
	unsigned int *source,*dest;
	/* profile original code */
	asm volatile("custom 0,c0,%[in1],c0"::[in1]"r"(1)); // start counter 1
	for (loop = 0 ; loop < width*height ; loop++) {
		  temp = rgb_source[loop]&0xFF; // red value
		  grayscale = (temp*30)/100;
		  temp = (rgb_source[loop]>>8)&0xFF; // green value
		  grayscale += (temp*59)/100;
		  temp = (rgb_source[loop]>>16)&0xFF; // blue value
		  grayscale += (temp*11)/100;
		  grayscale_destination[loop] = grayscale|(grayscale<<8)|(grayscale<<16);
	  }
	  asm volatile("custom 1,c0,%[in1],c0"::[in1]"r"(1)); // stop counter 1
	  asm volatile("custom 3,%[out1],%[in1],c0":[out1]"=r"(orig_code_count):[in1]"r"(0)); // read counter 1
	  printf("\n\nOriginal code:\n");
	  printf("Counter value = %u\n",orig_code_count);
	  printf("Cycles each pixel = %d\n",orig_code_count/(320*240));
	  nr_of_secs = (double) counter_value / CPU_FREQUENCY;
	  printf("Execution time = %1.5f sec\n", nr_of_secs);
	  /* profile removed div code */
		asm volatile("custom 0,c0,%[in1],c0"::[in1]"r"(1)); // start counter 1
		for (loop = 0 ; loop < width*height ; loop++) {
			  temp = rgb_source[loop]&0xFF; // red value
			  grayscale = temp*30;
			  temp = (rgb_source[loop]>>8)&0xFF; // green value
			  grayscale += temp*59;
			  temp = (rgb_source[loop]>>16)&0xFF; // blue value
			  grayscale += temp*11;
			  grayscale /= 100;
			  grayscale_destination[loop] = grayscale|(grayscale<<8)|(grayscale<<16);
		  }
		  asm volatile("custom 1,c0,%[in1],c0"::[in1]"r"(1)); // stop counter 1
		  asm volatile("custom 3,%[out1],%[in1],c0":[out1]"=r"(counter_value):[in1]"r"(0)); // read counter 1
		  printf("\n\nRemoved div code:\n");
		  printf("Counter value = %u\n",counter_value);
		  printf("Cycles each pixel = %d\n",counter_value/(320*240));
		  nr_of_secs = (double) counter_value / CPU_FREQUENCY;
		  printf("Execution time = %1.5f sec\n", nr_of_secs);
		  nr_of_secs = (double) orig_code_count/ (double)counter_value;
		  printf("Speed-up is : %1.1f x\n",nr_of_secs);
	/* profile 2^m code */
	asm volatile("custom 0,c0,%[in1],c0"::[in1]"r"(1)); // start counter 1
	for (loop = 0 ; loop < width*height ; loop++) {
		  temp = rgb_source[loop]&0xFF; // red value
		  grayscale = temp*77;
		  temp = (rgb_source[loop]>>8)&0xFF; // green value
		  grayscale += temp*151;
		  temp = (rgb_source[loop]>>16)&0xFF; // blue value
		  grayscale += temp*28;
		  grayscale >>= 8;
		  grayscale_destination[loop] = grayscale|(grayscale<<8)|(grayscale<<16);
	  }
	  asm volatile("custom 1,c0,%[in1],c0"::[in1]"r"(1)); // stop counter 1
	  asm volatile("custom 3,%[out1],%[in1],c0":[out1]"=r"(counter_value):[in1]"r"(0)); // read counter 1
	  printf("\n\n2^m code:\n");
	  printf("Counter value = %u\n",counter_value);
	  printf("Cycles each pixel = %d\n",counter_value/(320*240));
	  nr_of_secs = (double) counter_value / CPU_FREQUENCY;
	  printf("Execution time = %1.5f sec\n", nr_of_secs);
	  nr_of_secs = (double) orig_code_count/ (double)counter_value;
	  printf("Speed-up is : %1.1f x\n",nr_of_secs);

	/* profile custom instruction code */
	asm volatile("custom 0,c0,%[in1],c0"::[in1]"r"(1)); // start counter 1
	source = rgb_source;
	dest = grayscale_destination;
	for (loop = 0 ; loop < width*height ; loop++) {
		asm volatile ("custom 4,%[out1],%[in1],c0":[out1]"=r"(dest[0]):[in1]"r"(source[0]));
		dest++;
		source++;
	  }
	  asm volatile("custom 1,c0,%[in1],c0"::[in1]"r"(1)); // stop counter 1
	  asm volatile("custom 3,%[out1],%[in1],c0":[out1]"=r"(counter_value):[in1]"r"(0)); // read counter 1
	  printf("\n\ncustom instruction code:\n");
	  printf("Counter value = %u\n",counter_value);
	  printf("Cycles each pixel = %d\n",counter_value/(320*240));
	  nr_of_secs = (double) counter_value / CPU_FREQUENCY;
	  printf("Execution time = %1.5f sec\n", nr_of_secs);
	  nr_of_secs = (double) orig_code_count/ (double)counter_value;
	  printf("Speed-up is : %1.1f x\n",nr_of_secs);

	printf("\n\n");
#endif

}
