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
 * @file i2c.c
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
#include "i2c.h"

void i2c_busy_wait(void)
{
	int busy;
	do{
		busy = IORD_32DIRECT(I2C_CTRL_BASE,I2C_CONTROL_REG);
	}while ((busy&(I2C_Busy_Flag|I2C_Autodetect_Busy_Flag))!=0);
}

void i2c_auto_detect()
{
    int nrdef,loop,value;
    i2c_busy_wait();
    IOWR_32DIRECT(I2C_CTRL_BASE,I2C_CONTROL_REG,I2C_Autodetect);
    i2c_busy_wait();
    nrdef = IORD_32DIRECT(I2C_CTRL_BASE,I2C_ADDR_REG);
    printf("Number of I2C devices detected: %d\n",nrdef);
    for (loop = 0 ; loop < nrdef ; loop++) {
    	IOWR_32DIRECT(I2C_CTRL_BASE,I2C_DEVICE_ID_REG,loop);
    	value = IORD_32DIRECT(I2C_CTRL_BASE,I2C_DEVICE_ID_REG);
    	printf("Device nr. %d has Address: 0x%02X\n",loop,value);
    }
}

unsigned int i2c_short_read(unsigned char device_id,
		                    unsigned short address)
{
	i2c_busy_wait();
	IOWR_8DIRECT(I2C_CTRL_BASE,I2C_DEVICE_ID_REG,device_id);
	IOWR_16DIRECT(I2C_CTRL_BASE,I2C_ADDR_REG,address);
	IOWR_8DIRECT(I2C_CTRL_BASE,I2C_CONTROL_REG,
			     I2C_2Byte_Transfer|I2C_Start|I2C_Short_Transfer);
	i2c_busy_wait();
	IOWR_8DIRECT(I2C_CTRL_BASE,I2C_DEVICE_ID_REG,device_id+1);
	IOWR_8DIRECT(I2C_CTRL_BASE,I2C_CONTROL_REG,
			     I2C_Start|I2C_4Byte_Read);
	i2c_busy_wait();
	return IORD_32DIRECT(I2C_CTRL_BASE,I2C_DATA_REG);
}

void i2c_short_write(unsigned char device_id,
		             unsigned short address,
		             unsigned short data)
{
	i2c_busy_wait();
	IOWR_8DIRECT(I2C_CTRL_BASE,I2C_DEVICE_ID_REG,device_id);
	IOWR_16DIRECT(I2C_CTRL_BASE,I2C_ADDR_REG,address);
	IOWR_16DIRECT(I2C_CTRL_BASE,I2C_DATA_REG,data);
	IOWR_8DIRECT(I2C_CTRL_BASE,I2C_CONTROL_REG,
			     I2C_Start|I2C_Short_Transfer);
	i2c_busy_wait();
}
