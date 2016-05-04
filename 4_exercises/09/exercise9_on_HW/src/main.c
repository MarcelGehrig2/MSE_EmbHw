/*
 * main.c
 *
 *  Created on: May 4, 2016
 *      Author: mgehrig2
 */




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
 * @file main.c
 * @author Theo KLUTER
 * @author Andreas HABEGGER
 * @date Apr 13, 2016
 * @brief Introduction to Embedded Hardwar System Engineering
 *
 * @copyright GNU Lesser General Public License
 * @see http://www.msengineering.ch/
 * @bug currently no bugs
 * @todo no open tasks
 */

#include <stdio.h>
#include <system.h>
#include <stdlib.h>
#include <io.h>

int main(void)
{

  printf("Hello from Nios II!\n");


  int trace;
  trace++;
  trace++;
  trace++;



  // original (slow)
  int i, w, x[1000], y[1000];
  for (i = 0; i < 1000; i++) {
	  x[i] = x[i] + y[i];
	  if (w)
		  y[i] = 0;
  }



  trace++;
  trace++;


  // unswitched (faster)
  int i2, w2, x2[1000], y2[1000];
  if (w2) {
	  for (i2 = 0; i2 < 1000; i2++) {
		  x2[i2] = x2[i2] + y2[i2];
		  y2[i2] = 0;
	  }
  } else {
	  for (i2 = 0; i2 < 1000; i2++) {
		  x2[i2] = x2[i2] + y2[i2];
	  }
  }


  return 0;
}
