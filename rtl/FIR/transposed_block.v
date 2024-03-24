module transposed_block(clk , reset_n ,normal_signal ,coeff,to_register, summed_signal);

	parameter N = 16;								// bit resolution


	input clk;
	input reset_n;
	input 	signed 		[N-1:0] 		normal_signal;
	input 	signed 		[N-1:0] 		coeff;
	input 	signed 		[2*N-1:0] 		to_register;
	output 	signed 		[2*N-1:0] 		summed_signal;
	
	wire 	signed 		[2*N-1:0] 		mul;
	reg 	signed 		[2*N-1:0] 		delayed_signal;
	
	always@(posedge clk) 
	begin 
	if(!reset_n)
		delayed_signal <= 0;
	else 
		delayed_signal <= to_register ;
	end 
	
	assign mul = coeff * normal_signal ;
	assign summed_signal = mul + delayed_signal ;
endmodule
