# TEST SOFTWARE
A unit test software was developed to fully test the FPGA implementation of the filter using direct register read/write for the 2 FIFOs and the Filter. The software includes `my_fir_filter.h`, which has `u32 fir_init()` that 
* Writes the FIR coefficients to the filter
* Starts the filter 
* Reads the coefficients back
thus testing the AXI Lite filter interface. 

The `fir_test.c` file 
* Initializes the Tx and Rx FIFOs
* Sends a MATLAB-generated noisy sin signal
* Reads the Rx FIFO output and compares it to the MATLAB-generated output, reporting any mismatches.

# Test Results 
![alt text](../docs/FIR/image-16.png)
### No Mismacthes between MATLAB and the FIR filter output read by the ARM A53