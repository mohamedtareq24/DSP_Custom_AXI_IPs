/*
 * my_fir_filter.h
 *
 *  Created on: Mar 26, 2024
 *      Author: Mohamed tareq
 */

#ifndef MY_FIR_FILTER_H_
#define MY_FIR_FILTER_H_
#include <stdint.h>
#include "xstatus.h"
#include "xil_printf.h"

// Function to initialize the FIR filter
int my_fir_filter_init();

int compare_coeffs();
// Function to write filter coefficients to memory
void my_fir_filter_write_coeffs();

/// write to control register
void start_filter();

#endif /* MY_FIR_FILTER_H_ */
