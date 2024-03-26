`timescale 1ns/1ps
module tb_fir();
parameter	  	    NUM_POINTS      =   1024    ;
parameter       	TAPS            =   53      ;
parameter 		    CLKPER		    =   10      ;

logic					                    clk             ;
logic					                    resetn          ;				        //async active low reset
logic	signed [15:0] 		                noisy_signal    ;         //input signal that to be filtered
logic 	signed [31:0] 		                filtered_signal ; 	    //output signal of the fir 
logic   signed [15:0]                       coeff [0:TAPS-1];



int		        coef_slv_reg_addrs  ;
int             tb_addr             ;
int             tb_data             ;


logic [15:0] fir_coeffs_rom                  [TAPS]     ;
logic [15:0] noisy_signal_rom           [NUM_POINTS]    ;
logic [15:0] filtered_noisy_signal      [NUM_POINTS]    ;



always  #(CLKPER/2) clk  = ~clk  ;



initial begin
    $readmemh("D:/Digital_Electronics/DSP/DSP_course/dv/FIR/noisy_signal.hex" , noisy_signal_rom);
    $readmemh("D:/Digital_Electronics/DSP/DSP_course/dv/FIR/fir_coefficients.hex" , fir_coeffs_rom);
    clk         =   0   ;
    resetn      =   1   ;   
    
    for ( int i=0 ; i < NUM_POINTS ; i=i+1 )
    begin
        coeff[i] = fir_coeffs_rom[i];
    end

    reset()      ;

    #(CLKPER * 10) 
    for ( int i=0 ; i < NUM_POINTS ; i=i+1 )
    begin
        @(posedge clk)
        noisy_signal <= noisy_signal_rom[i]             ;
        #CLKPER;
    end
    $stop();
end


FIR_transposed #(.TAPS(TAPS)) dut (.*);


task reset();
    int i ;
    @(posedge clk)
    begin
        resetn  = 1'b0; // Assert reset for AXI slave
        #(CLKPER*10);
        resetn  = 1'b1; // Release reset for AXI slave
    end
endtask

endmodule
