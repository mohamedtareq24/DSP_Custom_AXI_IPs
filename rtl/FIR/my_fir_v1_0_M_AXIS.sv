`timescale 1 ns / 1 ps

	module my_fir_v1_0_M_AXIS #
	(
		// Users to add parameters here
        parameter SIGNALWIDTH 	= 	16 	,
		parameter TAPS			=	53	,
		// User parameters ends
		// Do not modify the parameters beyond this line

		// Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
		parameter integer C_M_AXIS_TDATA_WIDTH	= 32
	)
	(
		// Users to add ports here
        input wire [2*SIGNALWIDTH-1:0]    	stream_data_in 	,
		input wire							en 				,
		input wire 							last			,
		// User ports ends
		// Do not modify the ports beyond this line

		// Global ports
		input wire  M_AXIS_ACLK,
		// 
		input wire  M_AXIS_ARESETN,
		// Master Stream Ports. TVALID indicates that the master is driving a en transfer, A transfer takes place when both TVALID and TREADY are asserted. 
		output wire  M_AXIS_TVALID,
		// TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
		output wire [C_M_AXIS_TDATA_WIDTH-1 : 0] M_AXIS_TDATA,
		// TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
		output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB,
		// TLAST indicates the boundary of a packet.
		output wire  M_AXIS_TLAST,
		// TREADY indicates that the slave can accept a transfer in the current cycle.
		input wire  M_AXIS_TREADY
	);
	//streaming data en
	wire  	axis_tvalid;
	//streaming data en delayed by one clock cycle
	reg  	axis_tvalid_delay;
	//Last of the streaming data 
	wire  	axis_tlast;
	//Last of the streaming data delayed by one clock cycle
	reg  	axis_tlast_delay;
	//FIFO implementation signals
	reg [C_M_AXIS_TDATA_WIDTH-1 : 0] 	stream_data_out;
	wire  	tx_en;
	reg valid_shift_reg 	[TAPS-1:0];
	reg last_shift_reg	 	[TAPS-1:0];


	// I/O Connections assignments

	assign M_AXIS_TVALID	= axis_tvalid_delay;
	assign M_AXIS_TDATA		= stream_data_out;
	assign M_AXIS_TLAST		= axis_tlast_delay;
	assign M_AXIS_TSTRB		= {(C_M_AXIS_TDATA_WIDTH/8){1'b1}};

	//tvalid generation
	always @(posedge M_AXIS_ACLK)
	begin
		if (!M_AXIS_ARESETN)                                                                         
		begin   
			for (int i = 0; i < TAPS; i = i + 1) 
			begin
				valid_shift_reg[i] <= 0;
			end
		end
		else
		begin
			for (int i = TAPS-1; i > 0; i = i - 1) 
			begin
				valid_shift_reg[i] <= valid_shift_reg[i-1];
			end
			valid_shift_reg[0] <= en;
		end
	end
	assign axis_tvalid = valid_shift_reg[TAPS-1] ;


	// AXI tlast generation  
		//tvalid generation
	always @(posedge M_AXIS_ACLK)
	begin
		if (!M_AXIS_ARESETN)                                                                         
		begin   
			for (int i = 0; i < TAPS; i = i + 1) 
			begin
				last_shift_reg[i] <= 0;
			end
		end
		else
		begin
			for (int i = TAPS-1; i > 0; i = i - 1) 
			begin
				last_shift_reg[i] <= last_shift_reg[i-1];
			end
			last_shift_reg[0] <= last;
		end
	end                                                                                                                            
	assign axis_tlast = last_shift_reg[TAPS-1]	;                             

	// Delay the axis_tvalid and axis_tlast signal by one clock cycle                              
	// to match the latency of M_AXIS_TDATA                                                        
	always @(posedge M_AXIS_ACLK)                                                                  
	begin                                                                                          
		if (!M_AXIS_ARESETN)                                                                         
			begin                                                                                      
				axis_tvalid_delay <= 1'b0;                                                               
				axis_tlast_delay <= 1'b0;                                                                
			end                                                                                        
		else                                                                                         
			begin                                                                                      
				axis_tvalid_delay <= axis_tvalid;                                                        
				axis_tlast_delay <= axis_tlast;                                                          
			end                                                                                        
	end                                                                                            



	assign tx_en = M_AXIS_TREADY && axis_tvalid;   
	    // Streaming output data is read from FIFO       
		always @( posedge M_AXIS_ACLK )                  
		begin                                            
			if(!M_AXIS_ARESETN)                            
			begin                                        
				stream_data_out <= 0;                      
			end                                          
			else if (tx_en)// && M_AXIS_TSTRB[byte_index]  
			begin                                        
				stream_data_out <= stream_data_in ;   
			end                                          
		end                                              

	endmodule