/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include "alt_types.h"
#include "KatjaPapa.h"
#include "grayscalehw.h"

unsigned int *grayscale_array_custom;

int main()
{

	if (grayscale_array_custom != NULL)
		free(grayscale_array_custom);
	grayscale_array_custom = (unsigned char *) malloc(picture_width_KatjaPapa*picture_height_KatjaPapa);
	rgb_to_grayscale(picture_width_KatjaPapa,picture_height_KatjaPapa, (unsigned char *)picture_array_KatjaPapa, grayscale_array_custom);


  return 0;
}
