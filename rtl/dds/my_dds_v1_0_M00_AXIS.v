`timescale 1 ns / 1 ps

	module my_dds_v1_0_M00_AXIS #
	(
		// Users to add parameters here
        parameter SIGNALWIDTH = 16 ,
		// User parameters ends
		// Do not modify the parameters beyond this line

		// Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
		parameter integer C_M_AXIS_TDATA_WIDTH	= 32,
		// Start count is the number of clock cycles the master will wait before initiating/issuing any transaction.
		parameter integer C_M_START_COUNT	= 32
	)
	(
		// Users to add ports here
        input wire [SIGNALWIDTH-1:0]    stream_data ,
		input wire						valid 		,
		// User ports ends
		// Do not modify the ports beyond this line

		// Global ports
		input wire  M_AXIS_ACLK,
		// 
		input wire  M_AXIS_ARESETN,
		// Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
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
	//streaming data valid
	wire  	axis_tvalid;
	//streaming data valid delayed by one clock cycle
	reg  	axis_tvalid_delay;
	//Last of the streaming data 
	wire  	axis_tlast;
	//Last of the streaming data delayed by one clock cycle
	reg  	axis_tlast_delay;
	//FIFO implementation signals
	reg [C_M_AXIS_TDATA_WIDTH-1 : 0] 	stream_data_out;
	wire  	tx_en;
	//The master has issued all the streaming data stored in FIFO
	reg  	tx_done;


	// I/O Connections assignments

	assign M_AXIS_TVALID	= axis_tvalid_delay;
	assign M_AXIS_TDATA		= stream_data_out;
	assign M_AXIS_TLAST		= axis_tlast_delay;
	assign M_AXIS_TSTRB		= {(C_M_AXIS_TDATA_WIDTH/8){1'b1}};

	//tvalid generation
	assign axis_tvalid = valid ;

	// AXI tlast generation                                                                                                                                   
	assign axis_tlast = 1'b0	;                             

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
				stream_data_out <= 1;                      
			end                                          
			else if (tx_en)// && M_AXIS_TSTRB[byte_index]  
			begin                                        
				stream_data_out <= stream_data ;   
			end                                          
		end                                              

	endmodule
