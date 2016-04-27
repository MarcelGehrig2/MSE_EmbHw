/*
 * grayscalehw.h
 *
 *  Created on: Apr 22, 2015
 */

#ifndef GRAYSCALEHW_H_
#define GRAYSCALEHW_H_

void rgb_to_grayscale( int width,
		               int height,
		               const unsigned int *rgb_source,
		               unsigned int *grayscale_destination);

#endif /* GRAYSCALEHW_H_ */
