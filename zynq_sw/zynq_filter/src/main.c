/*
 * Test software for my FIR filter
 *
 *
 *
 *
 */


#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "my_fir_filter.h"


int main()
{
	printf("Hello from Zynq FIR");

    init_platform();

    my_fir_filter_init();		// write the filter coeffs then start the filter
    //start_filter();

    cleanup_platform();
    return 0;
}
