`timescale 1ns / 1ps

module FIR_transposed(clk , reset_n , noisy_signal , filtered_signal,coeff);

	parameter DATA_WIDTH = 16;																										// bit resolution
	parameter TAPS = 128;																									            // number of Taps

	input 					        									   clk ;
	input 					        								       reset_n;				  									//async active low reset
	input 	signed 			[DATA_WIDTH-1   :0] 		  			       noisy_signal;         						//input signal that to be filtered
	output 	signed 			[2*DATA_WIDTH-1 :0] 					        filtered_signal; 	  							//output signal of the fir 
    input   signed          [DATA_WIDTH-1   :0] 				            coeff 	[0:TAPS-1];                  // filter coefs from register file
	

	wire 		signed 			[2*DATA_WIDTH-1:0] 						summed_signal 		[0:TAPS-1];
	wire 		signed 			[2*DATA_WIDTH-1:0] 						to_register 			[0:TAPS-2];
    

	
	assign summed_signal[0] = noisy_signal * coeff[TAPS-1];

	
  genvar i;
  generate
    for (i = 0; i < TAPS-1; i = i + 1) begin : gen_block 
    transposed_block O_FIR (
        .clk(clk),
        .reset_n(reset_n),
        .normal_signal(noisy_signal),
        .coeff(coeff[TAPS-2-i]),
        .to_register(summed_signal[i]),   
        .summed_signal(summed_signal[i+1])  
      );
    end
  endgenerate
  
  assign filtered_signal = summed_signal[TAPS-1];
  
    
endmodule
