/*
 * system.h - SOPC Builder system and BSP software package information
 *
 * Machine generated for CPU 'CPU' in SOPC Builder design 'base_system'
 * SOPC Builder design path: ../../base_system.sopcinfo
 *
 * Generated: Wed Apr 13 15:53:32 CEST 2016
 */

/*
 * DO NOT MODIFY THIS FILE
 *
 * Changing this file will have subtle consequences
 * which will almost certainly lead to a nonfunctioning
 * system. If you do modify this file, be aware that your
 * changes will be overwritten and lost when this file
 * is generated again.
 *
 * DO NOT MODIFY THIS FILE
 */

/*
 * License Agreement
 *
 * Copyright (c) 2008
 * Altera Corporation, San Jose, California, USA.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * This agreement shall be governed in all respects by the laws of the State
 * of California and by the laws of the United States of America.
 */

#ifndef __SYSTEM_H_
#define __SYSTEM_H_

/* Include definitions from linker script generator */
#include "linker.h"


/*
 * CPU configuration
 *
 */

#define ALT_CPU_ARCHITECTURE "altera_nios2_gen2"
#define ALT_CPU_BIG_ENDIAN 0
#define ALT_CPU_BREAK_ADDR 0x01000820
#define ALT_CPU_CPU_ARCH_NIOS2_R1
#define ALT_CPU_CPU_FREQ 50000000u
#define ALT_CPU_CPU_ID_SIZE 1
#define ALT_CPU_CPU_ID_VALUE 0x00000000
#define ALT_CPU_CPU_IMPLEMENTATION "fast"
#define ALT_CPU_DATA_ADDR_WIDTH 0x19
#define ALT_CPU_DCACHE_BYPASS_MASK 0x80000000
#define ALT_CPU_DCACHE_LINE_SIZE 32
#define ALT_CPU_DCACHE_LINE_SIZE_LOG2 5
#define ALT_CPU_DCACHE_SIZE 4096
#define ALT_CPU_EXCEPTION_ADDR 0x00000020
#define ALT_CPU_FLASH_ACCELERATOR_LINES 0
#define ALT_CPU_FLASH_ACCELERATOR_LINE_SIZE 0
#define ALT_CPU_FLUSHDA_SUPPORTED
#define ALT_CPU_FREQ 50000000
#define ALT_CPU_HARDWARE_DIVIDE_PRESENT 0
#define ALT_CPU_HARDWARE_MULTIPLY_PRESENT 1
#define ALT_CPU_HARDWARE_MULX_PRESENT 0
#define ALT_CPU_HAS_DEBUG_CORE 1
#define ALT_CPU_HAS_DEBUG_STUB
#define ALT_CPU_HAS_EXTRA_EXCEPTION_INFO
#define ALT_CPU_HAS_ILLEGAL_INSTRUCTION_EXCEPTION
#define ALT_CPU_HAS_JMPI_INSTRUCTION
#define ALT_CPU_ICACHE_LINE_SIZE 32
#define ALT_CPU_ICACHE_LINE_SIZE_LOG2 5
#define ALT_CPU_ICACHE_SIZE 4096
#define ALT_CPU_INITDA_SUPPORTED
#define ALT_CPU_INST_ADDR_WIDTH 0x19
#define ALT_CPU_NAME "CPU"
#define ALT_CPU_NUM_OF_SHADOW_REG_SETS 0
#define ALT_CPU_OCI_VERSION 1
#define ALT_CPU_RESET_ADDR 0x00000000


/*
 * CPU configuration (with legacy prefix - don't use these anymore)
 *
 */

#define NIOS2_BIG_ENDIAN 0
#define NIOS2_BREAK_ADDR 0x01000820
#define NIOS2_CPU_ARCH_NIOS2_R1
#define NIOS2_CPU_FREQ 50000000u
#define NIOS2_CPU_ID_SIZE 1
#define NIOS2_CPU_ID_VALUE 0x00000000
#define NIOS2_CPU_IMPLEMENTATION "fast"
#define NIOS2_DATA_ADDR_WIDTH 0x19
#define NIOS2_DCACHE_BYPASS_MASK 0x80000000
#define NIOS2_DCACHE_LINE_SIZE 32
#define NIOS2_DCACHE_LINE_SIZE_LOG2 5
#define NIOS2_DCACHE_SIZE 4096
#define NIOS2_EXCEPTION_ADDR 0x00000020
#define NIOS2_FLASH_ACCELERATOR_LINES 0
#define NIOS2_FLASH_ACCELERATOR_LINE_SIZE 0
#define NIOS2_FLUSHDA_SUPPORTED
#define NIOS2_HARDWARE_DIVIDE_PRESENT 0
#define NIOS2_HARDWARE_MULTIPLY_PRESENT 1
#define NIOS2_HARDWARE_MULX_PRESENT 0
#define NIOS2_HAS_DEBUG_CORE 1
#define NIOS2_HAS_DEBUG_STUB
#define NIOS2_HAS_EXTRA_EXCEPTION_INFO
#define NIOS2_HAS_ILLEGAL_INSTRUCTION_EXCEPTION
#define NIOS2_HAS_JMPI_INSTRUCTION
#define NIOS2_ICACHE_LINE_SIZE 32
#define NIOS2_ICACHE_LINE_SIZE_LOG2 5
#define NIOS2_ICACHE_SIZE 4096
#define NIOS2_INITDA_SUPPORTED
#define NIOS2_INST_ADDR_WIDTH 0x19
#define NIOS2_NUM_OF_SHADOW_REG_SETS 0
#define NIOS2_OCI_VERSION 1
#define NIOS2_RESET_ADDR 0x00000000


/*
 * Define for each module class mastered by the CPU
 *
 */

#define __ALTERA_AVALON_JTAG_UART
#define __ALTERA_AVALON_NEW_SDRAM_CONTROLLER
#define __ALTERA_AVALON_PIO
#define __ALTERA_AVALON_SYSID_QSYS
#define __ALTERA_AVALON_TIMER
#define __ALTERA_NIOS2_GEN2
#define __ALTPLL
#define __CAM_DMA
#define __I2C_MASTER
#define __LCD_DMA
#define __VGA_DMA


/*
 * PLL configuration
 *
 */

#define ALT_MODULE_CLASS_PLL altpll
#define PLL_BASE 0x10010b0
#define PLL_IRQ -1
#define PLL_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PLL_NAME "/dev/PLL"
#define PLL_SPAN 16
#define PLL_TYPE "altpll"


/*
 * ProfileTimer configuration
 *
 */

#define ALT_MODULE_CLASS_ProfileTimer altera_avalon_timer
#define PROFILETIMER_ALWAYS_RUN 0
#define PROFILETIMER_BASE 0x1001040
#define PROFILETIMER_COUNTER_SIZE 32
#define PROFILETIMER_FIXED_PERIOD 0
#define PROFILETIMER_FREQ 50000000
#define PROFILETIMER_IRQ 5
#define PROFILETIMER_IRQ_INTERRUPT_CONTROLLER_ID 0
#define PROFILETIMER_LOAD_VALUE 49999
#define PROFILETIMER_MULT 0.001
#define PROFILETIMER_NAME "/dev/ProfileTimer"
#define PROFILETIMER_PERIOD 1
#define PROFILETIMER_PERIOD_UNITS "ms"
#define PROFILETIMER_RESET_OUTPUT 0
#define PROFILETIMER_SNAPSHOT 1
#define PROFILETIMER_SPAN 32
#define PROFILETIMER_TICKS_PER_SEC 1000
#define PROFILETIMER_TIMEOUT_PULSE_OUTPUT 0
#define PROFILETIMER_TYPE "altera_avalon_timer"


/*
 * System configuration
 *
 */

#define ALT_DEVICE_FAMILY "Cyclone IV E"
#define ALT_ENHANCED_INTERRUPT_API_PRESENT
#define ALT_IRQ_BASE NULL
#define ALT_LOG_PORT "/dev/null"
#define ALT_LOG_PORT_BASE 0x0
#define ALT_LOG_PORT_DEV null
#define ALT_LOG_PORT_TYPE ""
#define ALT_NUM_EXTERNAL_INTERRUPT_CONTROLLERS 0
#define ALT_NUM_INTERNAL_INTERRUPT_CONTROLLERS 1
#define ALT_NUM_INTERRUPT_CONTROLLERS 1
#define ALT_STDERR "/dev/jtag_uart"
#define ALT_STDERR_BASE 0x10010e0
#define ALT_STDERR_DEV jtag_uart
#define ALT_STDERR_IS_JTAG_UART
#define ALT_STDERR_PRESENT
#define ALT_STDERR_TYPE "altera_avalon_jtag_uart"
#define ALT_STDIN "/dev/jtag_uart"
#define ALT_STDIN_BASE 0x10010e0
#define ALT_STDIN_DEV jtag_uart
#define ALT_STDIN_IS_JTAG_UART
#define ALT_STDIN_PRESENT
#define ALT_STDIN_TYPE "altera_avalon_jtag_uart"
#define ALT_STDOUT "/dev/jtag_uart"
#define ALT_STDOUT_BASE 0x10010e0
#define ALT_STDOUT_DEV jtag_uart
#define ALT_STDOUT_IS_JTAG_UART
#define ALT_STDOUT_PRESENT
#define ALT_STDOUT_TYPE "altera_avalon_jtag_uart"
#define ALT_SYSTEM_NAME "base_system"


/*
 * Systimer configuration
 *
 */

#define ALT_MODULE_CLASS_Systimer altera_avalon_timer
#define SYSTIMER_ALWAYS_RUN 0
#define SYSTIMER_BASE 0x1001060
#define SYSTIMER_COUNTER_SIZE 32
#define SYSTIMER_FIXED_PERIOD 0
#define SYSTIMER_FREQ 50000000
#define SYSTIMER_IRQ 4
#define SYSTIMER_IRQ_INTERRUPT_CONTROLLER_ID 0
#define SYSTIMER_LOAD_VALUE 49999
#define SYSTIMER_MULT 0.001
#define SYSTIMER_NAME "/dev/Systimer"
#define SYSTIMER_PERIOD 1
#define SYSTIMER_PERIOD_UNITS "ms"
#define SYSTIMER_RESET_OUTPUT 0
#define SYSTIMER_SNAPSHOT 1
#define SYSTIMER_SPAN 32
#define SYSTIMER_TICKS_PER_SEC 1000
#define SYSTIMER_TIMEOUT_PULSE_OUTPUT 0
#define SYSTIMER_TYPE "altera_avalon_timer"


/*
 * cam_ctrl configuration
 *
 */

#define ALT_MODULE_CLASS_cam_ctrl cam_dma
#define CAM_CTRL_BASE 0x1001000
#define CAM_CTRL_IRQ 3
#define CAM_CTRL_IRQ_INTERRUPT_CONTROLLER_ID 0
#define CAM_CTRL_NAME "/dev/cam_ctrl"
#define CAM_CTRL_SPAN 32
#define CAM_CTRL_TYPE "cam_dma"


/*
 * dipsw configuration
 *
 */

#define ALT_MODULE_CLASS_dipsw altera_avalon_pio
#define DIPSW_BASE 0x10010a0
#define DIPSW_BIT_CLEARING_EDGE_REGISTER 0
#define DIPSW_BIT_MODIFYING_OUTPUT_REGISTER 0
#define DIPSW_CAPTURE 0
#define DIPSW_DATA_WIDTH 8
#define DIPSW_DO_TEST_BENCH_WIRING 0
#define DIPSW_DRIVEN_SIM_VALUE 0
#define DIPSW_EDGE_TYPE "NONE"
#define DIPSW_FREQ 50000000
#define DIPSW_HAS_IN 1
#define DIPSW_HAS_OUT 0
#define DIPSW_HAS_TRI 0
#define DIPSW_IRQ -1
#define DIPSW_IRQ_INTERRUPT_CONTROLLER_ID -1
#define DIPSW_IRQ_TYPE "NONE"
#define DIPSW_NAME "/dev/dipsw"
#define DIPSW_RESET_VALUE 0
#define DIPSW_SPAN 16
#define DIPSW_TYPE "altera_avalon_pio"


/*
 * hal configuration
 *
 */

#define ALT_INCLUDE_INSTRUCTION_RELATED_EXCEPTION_API
#define ALT_MAX_FD 32
#define ALT_SYS_CLK PROFILETIMER
#define ALT_TIMESTAMP_CLK none


/*
 * i2c_ctrl configuration
 *
 */

#define ALT_MODULE_CLASS_i2c_ctrl i2c_master
#define I2C_CTRL_BASE 0x1001090
#define I2C_CTRL_IRQ 2
#define I2C_CTRL_IRQ_INTERRUPT_CONTROLLER_ID 0
#define I2C_CTRL_NAME "/dev/i2c_ctrl"
#define I2C_CTRL_SPAN 16
#define I2C_CTRL_TYPE "i2c_master"


/*
 * jtag_uart configuration
 *
 */

#define ALT_MODULE_CLASS_jtag_uart altera_avalon_jtag_uart
#define JTAG_UART_BASE 0x10010e0
#define JTAG_UART_IRQ 0
#define JTAG_UART_IRQ_INTERRUPT_CONTROLLER_ID 0
#define JTAG_UART_NAME "/dev/jtag_uart"
#define JTAG_UART_READ_DEPTH 64
#define JTAG_UART_READ_THRESHOLD 8
#define JTAG_UART_SPAN 8
#define JTAG_UART_TYPE "altera_avalon_jtag_uart"
#define JTAG_UART_WRITE_DEPTH 64
#define JTAG_UART_WRITE_THRESHOLD 8


/*
 * lcd_ctrl configuration
 *
 */

#define ALT_MODULE_CLASS_lcd_ctrl lcd_dma
#define LCD_CTRL_BASE 0x1001020
#define LCD_CTRL_IRQ 1
#define LCD_CTRL_IRQ_INTERRUPT_CONTROLLER_ID 0
#define LCD_CTRL_NAME "/dev/lcd_ctrl"
#define LCD_CTRL_SPAN 32
#define LCD_CTRL_TYPE "lcd_dma"


/*
 * sdram_ctrl configuration
 *
 */

#define ALT_MODULE_CLASS_sdram_ctrl altera_avalon_new_sdram_controller
#define SDRAM_CTRL_BASE 0x0
#define SDRAM_CTRL_CAS_LATENCY 3
#define SDRAM_CTRL_CONTENTS_INFO
#define SDRAM_CTRL_INIT_NOP_DELAY 0.0
#define SDRAM_CTRL_INIT_REFRESH_COMMANDS 2
#define SDRAM_CTRL_IRQ -1
#define SDRAM_CTRL_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SDRAM_CTRL_IS_INITIALIZED 1
#define SDRAM_CTRL_NAME "/dev/sdram_ctrl"
#define SDRAM_CTRL_POWERUP_DELAY 100.0
#define SDRAM_CTRL_REFRESH_PERIOD 15.625
#define SDRAM_CTRL_REGISTER_DATA_IN 1
#define SDRAM_CTRL_SDRAM_ADDR_WIDTH 0x17
#define SDRAM_CTRL_SDRAM_BANK_WIDTH 2
#define SDRAM_CTRL_SDRAM_COL_WIDTH 9
#define SDRAM_CTRL_SDRAM_DATA_WIDTH 16
#define SDRAM_CTRL_SDRAM_NUM_BANKS 4
#define SDRAM_CTRL_SDRAM_NUM_CHIPSELECTS 1
#define SDRAM_CTRL_SDRAM_ROW_WIDTH 12
#define SDRAM_CTRL_SHARED_DATA 0
#define SDRAM_CTRL_SIM_MODEL_BASE 0
#define SDRAM_CTRL_SPAN 16777216
#define SDRAM_CTRL_STARVATION_INDICATOR 0
#define SDRAM_CTRL_TRISTATE_BRIDGE_SLAVE ""
#define SDRAM_CTRL_TYPE "altera_avalon_new_sdram_controller"
#define SDRAM_CTRL_T_AC 5.5
#define SDRAM_CTRL_T_MRD 3
#define SDRAM_CTRL_T_RCD 20.0
#define SDRAM_CTRL_T_RFC 70.0
#define SDRAM_CTRL_T_RP 20.0
#define SDRAM_CTRL_T_WR 14.0


/*
 * sysid configuration
 *
 */

#define ALT_MODULE_CLASS_sysid altera_avalon_sysid_qsys
#define SYSID_BASE 0x10010d8
#define SYSID_ID 0
#define SYSID_IRQ -1
#define SYSID_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SYSID_NAME "/dev/sysid"
#define SYSID_SPAN 8
#define SYSID_TIMESTAMP 1460554680
#define SYSID_TYPE "altera_avalon_sysid_qsys"


/*
 * vga_dma configuration
 *
 */

#define ALT_MODULE_CLASS_vga_dma vga_dma
#define VGA_DMA_BASE 0x10010d0
#define VGA_DMA_IRQ -1
#define VGA_DMA_IRQ_INTERRUPT_CONTROLLER_ID -1
#define VGA_DMA_NAME "/dev/vga_dma"
#define VGA_DMA_SPAN 8
#define VGA_DMA_TYPE "vga_dma"

#endif /* __SYSTEM_H_ */
