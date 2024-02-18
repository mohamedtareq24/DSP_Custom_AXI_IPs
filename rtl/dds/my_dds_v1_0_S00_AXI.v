
`timescale 1 ns / 1 ps

	module my_dds_v1_0_S00_AXI #
	(
		// Users to add parameters here
        parameter	DEPTH 		= 	8	,
		parameter 	SIG_WIDTH  	= 	16 	,
        
		parameter   CTRL        =   0   , //! register index
		parameter   THETAS      =   1   ,
		parameter   DELTAS      =   2   ,
		parameter   AMPLS       =   3   ,
		parameter   CLKDIV      =   4   ,
		parameter   STAT        =   5   ,
		parameter   LNGTH       =   6   ,
        parameter 	RSRVD 		= 	7	,
		// User parameters ends
		// Do not modify the parameters beyond this line

		// Width of S_AXI data bus
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		// Width of S_AXI address bus
		parameter integer C_S_AXI_ADDR_WIDTH	= 5
	)
	(
		// Users to add ports here
		output	wire [SIG_WIDTH-1:0]	out_stream	   ,	/// to axi stream
		output  wire                    valid         , 
		// User ports ends
		// Do not modify the ports beyond this line

		// Global Clock Signal
		input wire  S_AXI_ACLK,
		// Global Reset Signal. This Signal is Active LOW
		input wire  S_AXI_ARESETN,
		// Write address (issued by master, acceped by Slave)

		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		// Write channel Protection type. This signal indicates the
    		// privilege and security level of the transaction, and whether
    		// the transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_AWPROT,
		// Write address valid. This signal indicates that the master signaling
    		// valid write address and control information.
		input wire  S_AXI_AWVALID,
		// Write address ready. This signal indicates that the slave is ready
    		// to accept an address and associated control signals.
		output wire  S_AXI_AWREADY,
		// Write data (issued by master, acceped by Slave) 
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		// Write strobes. This signal indicates which byte lanes hold
    		// valid data. There is one write strobe bit for each eight
    		// bits of the write data bus.    
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		// Write valid. This signal indicates that valid write
    		// data and strobes are available.
		input wire  S_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    		// can accept the write data.
		output wire  S_AXI_WREADY,
		// Write response. This signal indicates the status
    		// of the write transaction.
		output wire [1 : 0] S_AXI_BRESP,
		// Write response valid. This signal indicates that the channel
    		// is signaling a valid write response.
		output wire  S_AXI_BVALID,
		// Response ready. This signal indicates that the master
    		// can accept a write response.
		input wire  S_AXI_BREADY,
		// Read address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		// Protection type. This signal indicates the privilege
    		// and security level of the transaction, and whether the
    		// transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_ARPROT,
		// Read address valid. This signal indicates that the channel
    		// is signaling valid read address and control information.
		input wire  S_AXI_ARVALID,
		// Read address ready. This signal indicates that the slave is
    		// ready to accept an address and associated control signals.
		output wire  S_AXI_ARREADY,
		// Read data (issued by slave)
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		// Read response. This signal indicates the status of the
    		// read transfer.
		output wire [1 : 0] S_AXI_RRESP,
		// Read valid. This signal indicates that the channel is
    		// signaling the required read data.
		output wire  S_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    		// accept the read data and response information.
		input wire  S_AXI_RREADY
	);

	// AXI4LITE signals
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr , axi_awaddr_d;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rvalid;

	// Example-specific design signals
	// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	// ADDR_LSB is used for addressing 32/64 bit registers/memories
	// ADDR_LSB = 2 for 32 bits (n downto 2)
	// ADDR_LSB = 3 for 64 bits (n downto 3)
	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 0;
	//----------------------------------------------
	//-- Signals for user logic register space example
	//------------------------------------------------
	//-- Number of Slave Registers 8
	reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg [DEPTH-1:0];
	wire	 	slv_reg_rden;
	wire	 	slv_reg_wren;
	reg			slv_reg_wren_d , slv_reg_wren_dd;
	reg [C_S_AXI_DATA_WIDTH-1:0]	 reg_data_out;
	integer	 byte_index;
	reg	 aw_en;

	// I/O Connections assignments

	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY		= axi_wready;
	assign S_AXI_BRESP		= axi_bresp;
	assign S_AXI_BVALID		= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RDATA		= axi_rdata;
	assign S_AXI_RRESP		= axi_rresp;
	assign S_AXI_RVALID		= axi_rvalid;
	// Implement axi_awready generation
	// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	// de-asserted when reset is low.

	always @( posedge S_AXI_ACLK )
	begin
	if ( S_AXI_ARESETN == 1'b0 )
		begin
			axi_awready <= 1'b0;
			aw_en <= 1'b1;
		end 
	else
		begin    
	    	if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
	        begin
	          // slave is ready to accept write address when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
				axi_awready <= 1'b1;
				aw_en <= 1'b0;
	        end
	        else if (S_AXI_BREADY && axi_bvalid)
	            begin
					aw_en <= 1'b1;
					axi_awready <= 1'b0;
	            end
	      else           
	        begin
	          axi_awready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_awaddr latching
	// This process is used to latch the address when both 
	// S_AXI_AWVALID and S_AXI_WVALID are valid. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
	        begin
	          // Write Address latching 
	          axi_awaddr <= S_AXI_AWADDR;
	        end
	    end 
	end       

	// Implement axi_wready generation
	// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	// de-asserted when reset is low. 

	always @( posedge S_AXI_ACLK )
	begin
		if ( S_AXI_ARESETN == 1'b0 )
		begin
			axi_wready <= 1'b0;
		end 
		else
		begin    
			if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en )
			begin
				// slave is ready to accept write data when 
				// there is a valid write address and write data
				// on the write address and data bus. This design 
				// expects no outstanding transactions. 
				axi_wready <= 1'b1;
			end
			else
			begin
				axi_wready <= 1'b0;
			end
		end 
	end       

	// Implement memory mapped register select and write logic generation
	// The write data is accepted and written to memory mapped registers when
	// axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	// select byte enables of slave registers while writing.
	// These registers are cleared when reset (active low) is applied.
	// Slave register write enable is asserted when valid address and data are available
	// and the slave is ready to accept the write address and write data.
	assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

	always @( posedge S_AXI_ACLK )
	begin
	if ( S_AXI_ARESETN == 1'b0 )
	begin
		slv_reg[CTRL]    	<= 0;
		slv_reg[THETAS]  	<= 0;
		slv_reg[DELTAS]  	<= 0;
		slv_reg[AMPLS]   	<= 0;
		slv_reg[STAT]    	<= 0;
		slv_reg[LNGTH]   	<= 0;
		slv_reg[CLKDIV]  	<= 0;
		slv_reg[RSRVD]   	<= 0;
		slv_reg_wren_d		<= 0;	
		axi_awaddr_d		<= 0;
		slv_reg_wren_dd		<= 0;
	end 
	else begin
		slv_reg_wren_d	<=	slv_reg_wren 	;			/// this will be used to trigger a write
		slv_reg_wren_dd	<= 	slv_reg_wren_d	;
		axi_awaddr_d	<=	axi_awaddr		;
		
		
		if (slv_reg_wren)
		begin
			case (axi_awaddr)
				CTRL:
					slv_reg[CTRL] <= S_AXI_WDATA	; 
				THETAS:
					slv_reg[THETAS] <= S_AXI_WDATA	;
				DELTAS:
					slv_reg[DELTAS] <= S_AXI_WDATA	;
				AMPLS:
					slv_reg[AMPLS] <= S_AXI_WDATA	; 
				LNGTH:
					slv_reg[LNGTH] <= S_AXI_WDATA	;
				CLKDIV:
					slv_reg[CLKDIV] <= S_AXI_WDATA	;
				RSRVD:
					slv_reg[RSRVD] <= S_AXI_WDATA	;
				default: 
				begin
					slv_reg[CTRL] 	<= slv_reg[CTRL]	;
					slv_reg[THETAS]	<= slv_reg[THETAS]	;
					slv_reg[DELTAS] <= slv_reg[DELTAS]	;
					slv_reg[AMPLS] 	<= slv_reg[AMPLS]	;
					slv_reg[CLKDIV] <= slv_reg[CLKDIV]	;
					slv_reg[LNGTH] 	<= slv_reg[LNGTH]	;
					slv_reg[RSRVD] 	<= slv_reg[RSRVD]	;
				end
				endcase
			end
		end
	end    

	// Implement write response logic generation
	// The write response and response valid signals are asserted by the slave 
	// when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	// This marks the acceptance of address and indicates the status of 
	// write transaction.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid  <= 0;
	      axi_bresp   <= 2'b0;
	    end 
	  else
	    begin    
	      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
	        begin
	          // indicates a valid write response is available
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; // 'OKAY' response 
	        end                   // work error responses in future
	      else
	        begin
	          if (S_AXI_BREADY && axi_bvalid) 
	            //check if bready is asserted while bvalid is high) 
	            //(there is a possibility that bready is always asserted high)   
	            begin
	              axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	end   

	// Implement axi_arready generation
	// axi_arready is asserted for one S_AXI_ACLK clock cycle when
	// S_AXI_ARVALID is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read address is also latched when S_AXI_ARVALID is 
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_araddr  <= 32'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID)
	        begin
	          // indicates that the slave has acceped the valid read address
	          axi_arready <= 1'b1;
	          // Read address latching
	          axi_araddr  <= S_AXI_ARADDR;
	        end
	      else
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_arvalid generation
	// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	// S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	// data are available on the axi_rdata bus at this instance. The 
	// assertion of axi_rvalid marks the validity of read data on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rdata are 
	// cleared to zero on reset (active low).  
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
	        begin
	          // Valid read data is available at the read data bus
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= 2'b0; // 'OKAY' response
	        end   
	      else if (axi_rvalid && S_AXI_RREADY)
	        begin
	          // Read data is accepted by the master
	          axi_rvalid <= 1'b0;
	        end                
	    end
	end    

	// Implement memory mapped register select and read logic generation
	// Slave register read enable is asserted when valid address is available
	// and the slave is ready to accept the read address.
	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
	always @(*)
	begin
		case ( axi_araddr )
			3'h0   : reg_data_out <= slv_reg[DELTAS];
			3'h1   : reg_data_out <= slv_reg[THETAS];
			3'h2   : reg_data_out <= slv_reg[DELTAS];
			3'h3   : reg_data_out <= slv_reg[AMPLS];
			3'h4   : reg_data_out <= slv_reg[CLKDIV];
			3'h5   : reg_data_out <= slv_reg[STAT];
			3'h6   : reg_data_out <= slv_reg[LNGTH];
			3'h7   : reg_data_out <= slv_reg[RSRVD];
			default : reg_data_out <= 0;
		endcase
	end

	// Output register or memory read data
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rdata  <= 0;
	    end 
	  else
	    begin    
	      // When there is a valid read address (S_AXI_ARVALID) with 
	      // acceptance of read address by the slave (axi_arready), 
	      // output the read dada 
	      if (slv_reg_rden)
	        begin
	          axi_rdata <= reg_data_out;     // register read data
	        end   
	    end
	end    

	// Add user logic here
top #(.SIG_WIDTH (SIG_WIDTH)) dds_top_u (

        .clk(S_AXI_ACLK),
        .a_rst_n( S_AXI_ARESETN),

		.ctrl_reg(slv_reg[CTRL]),
		.thetas_reg(slv_reg[THETAS]),
		.deltas_reg(slv_reg[DELTAS]),
		.ampls_reg(slv_reg[AMPLS]),
		.stat_reg(slv_reg[STAT]),
		.lngth_reg(slv_reg[LNGTH]),
		.clkdiv_reg(slv_reg[CLKDIV]),
		
		.signal(out_stream),
		.valid(valid),

        .i_write( slv_reg_wren_dd ),
        .i_addrs(axi_awaddr_d)
);

	// User logic ends

	endmodule
