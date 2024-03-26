module FIR_transposed(clk , resetn , noisy_signal , filtered_signal , coeff);

	parameter DATA_WIDTH = 16;								// bit resolution
	parameter TAPS = 53;								// number of Taps

	input 					              clk ;
	input 					              resetn;				        //async active low reset
	input 	signed [DATA_WIDTH-1:0] 		    noisy_signal;         //input signal that to be filtered
	output 	signed [2*DATA_WIDTH-1:0] 		  filtered_signal; 	    //output signal of the fir 
	//output 	signed [DATA_WIDTH-1:0] 		filtered_signal; 	      //output signal of the fir 
	
	input   signed  [DATA_WIDTH-1:0]          coeff           [0:TAPS-1];
	wire    signed  [2*DATA_WIDTH-1:0]        summed_signal   [0:TAPS-1];

	assign summed_signal[0] = $signed(noisy_signal * coeff[TAPS-1]);
	
  genvar i;
  generate
    for (i = 0; i < TAPS-1; i = i + 1) begin : gen_block // 0 , 1, 2, 3   //4 ,3,2,1 //3,2,1,0
        transposed_block O_FIR (
          .clk(clk),
          .resetn(resetn),
          .normal_signal(noisy_signal),
          .coeff(coeff[TAPS-2-i]),
          .to_register(summed_signal[i]),   // to_register [ 1 , 2 ,3 ]
          .summed_signal(summed_signal[i+1])  // summed_signal [ 1 , 2 , 3 , 4]
        );
    end
  endgenerate
  
  assign filtered_signal = summed_signal[TAPS-1];

    // initial 
    // begin 
    // $readmemh("D:/Digital_Electronics/DSP/DSP_course/dv/FIR/fir_coefficients.hex"  , coeff);
    // end 
  
endmodule