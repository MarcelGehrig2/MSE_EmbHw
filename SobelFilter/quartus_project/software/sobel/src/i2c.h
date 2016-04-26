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
 * @file i2c.h
 * @author Theo KLUTER
 * @author Andreas HABEGGER
 * @date Aug 21, 2015
 * @brief Introduction to Embedded Hardwar System Engineering
 *
 * @copyright GNU Lesser General Public License
 * @see http://www.msengineering.ch/
 * @bug currently no bugs
 * @todo no open tasks
 */

#ifndef I2C_H_
#define I2C_H_

#include <stdio.h>
#include <system.h>
#include <io.h>

#define I2C_DEVICE_ID_REG 0
#define I2C_ADDR_REG 4
#define I2C_DATA_REG 8
#define I2C_CONTROL_REG 12
#define I2C_PRESCALE_REG 13
#define I2C_IRQ_Enable_REG 14

#define I2C_2Byte_Transfer 1
#define I2C_3Byte_Transfer 0
#define I2C_Start 2
#define I2C_Autodetect 4
#define I2C_Clear_IRQ 8
#define I2C_IRQ_enable 1
#define I2C_4Byte_Read (1<<5)
#define I2C_Short_Transfer (1<<6)

#define I2C_Busy_Flag 1
#define I2C_Autodetect_Busy_Flag 2


void i2c_auto_detect(void);
unsigned int i2c_short_read(unsigned char device_id,
		                    unsigned short address);
void i2c_short_write(unsigned char device_id,
	  	             unsigned short address,
		             unsigned short data);

#endif /* I2C_H_ */
