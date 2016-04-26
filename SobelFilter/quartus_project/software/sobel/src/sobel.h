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
 * @file sobel.h
 * @author Theo KLUTER
 * @author Andreas HABEGGER
 * @date Sep 12, 2015
 * @brief Introduction to Embedded Hardwar System Engineering
 *
 * @copyright GNU Lesser General Public License
 * @see http://www.msengineering.ch/
 * @bug currently no bugs
 * @todo no open tasks
 */

#ifndef SOBEL_H_
#define SOBEL_H_

#include <stdlib.h>
#include <stdio.h>
#include "io.h"


void init_sobel_arrays(int width , int height);

void sobel_x( unsigned char *source );

void sobel_x_with_rgb( unsigned char *source );

void sobel_y( unsigned char *source );

void sobel_y_with_rgb( unsigned char *source );

void sobel_threshold(short threshold);

unsigned short *GetSobel_rgb(void);

unsigned char *GetSobelResult(void);


#endif /* SOBEL_H_ */
