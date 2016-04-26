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
 * @file grayscale.c
 * @author Theo KLUTER
 * @date Aug 21, 2015
 * @brief Introduction to Embedded Hardwar System Engineering
 *
 * @copyright GNU Lesser General Public License
 * @see http://www.msengineering.ch/
 * @bug currently no bugs
 * @todo no open tasks
 */

#include "grayscale.h"


unsigned char *grayscale_array;
int grayscale_width = 0;
int grayscape_height = 0;

void conv_grayscale(void *picture,
		            int width,
		            int height) {
	int x,y,gray;
	unsigned short *pixels = (unsigned short *)picture , rgb;
	grayscale_width = width;
	grayscape_height = height;
	if (grayscale_array != NULL)
		free(grayscale_array);
	grayscale_array = (unsigned char *) malloc(width*height);
	for (y = 0 ; y < height ; y++) {
		for (x = 0 ; x < width ; x++) {
			rgb = pixels[y*width+x];
			gray = (((rgb>>11)&0x1F)<<3)*21; // red part
			gray += (((rgb>>5)&0x3F)<<2)*72; // green part
			gray += (((rgb>>0)&0x1F)<<3)*7; // blue part
			gray /= 100;
			IOWR_8DIRECT(grayscale_array,y*width+x,gray);
		}
	}
}


int get_grayscale_width() {
	return grayscale_width;
}

int get_grayscale_height() {
	return grayscape_height;
}

unsigned char *get_grayscale_picture() {
	return grayscale_array;
}


