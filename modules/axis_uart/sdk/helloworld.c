/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                     от   |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xil_io.h"
#include "xparameters.h"
#include "sleep.h"

int main() {
	int cmd;
	int rev;

	init_platform();

	Xil_Out32(XPAR_BRAM_0_BASEADDR + 8, 0xc);    // control_reg
	Xil_Out32(XPAR_BRAM_0_BASEADDR + 0, 0x2);    // command_reg

	Xil_Out32(XPAR_BRAM_0_BASEADDR + 8, 0x2);    // control_reg
	Xil_Out32(XPAR_BRAM_0_BASEADDR + 4, 0x1b2);  // clk_divider_reg = 50e6/115200
	Xil_Out32(XPAR_BRAM_0_BASEADDR + 12, 0x41);  // tx_data_reg

	xil_printf("Write data in registers\n\r");

    for (cmd = 1; cmd <= 4; cmd++) {
        Xil_Out32(XPAR_BRAM_0_BASEADDR, cmd); // control_reg
        xil_printf("Control reg 0x%x data is 0x%x \n\r", XPAR_BRAM_0_BASEADDR, reg_addr);
        // usleep(100000);
    }

	while(1) {

        rev = Xil_In32(XPAR_BRAM_0_BASEADDR + 16); // rx_data_reg
        xil_printf("The data at 0x%x is 0x%x \n\r", XPAR_BRAM_0_BASEADDR + 16, rev);
        xil_printf("\n\r");

        usleep(100000);
	}

	cleanup_platform();

	return 0;
}
