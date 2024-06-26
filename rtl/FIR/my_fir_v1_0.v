`timescale 1 ns / 1 ps

	module my_fir_v1_0 #
	(
		// Users to add parameters here
		parameter           TAPS	               	= 	53, 	//! FIlter Order+1
		parameter			FILTER_DATA_WIDTH		=	16,		//! Fixed point data width of the filter 
		// User parameters ends
		
		// Do not modify the parameters beyond this line

		// Parameters of Axi Slave Bus Interface S_AXI
		parameter integer C_S_AXI_DATA_WIDTH		= 32,	//! AXI lite data width 
		parameter integer C_S_AXI_ADDR_WIDTH		= 32,	//! AXI lite address width 

		// Parameters of Axi Slave Bus Interface S_AXIS
		parameter integer C_S_AXIS_TDATA_WIDTH	= 32,		//! AXI stream sink data width 

		// Parameters of Axi Master Bus Interface M_AXIS
		parameter integer C_M_AXIS_TDATA_WIDTH	= 32,		//! AXI stream source data width 
		parameter integer BASE_ADDR				= 32'hA0000000 //! AXI lite Base Address
	)
	(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S_AXI
		input wire  s_axi_aclk,
		input wire  s_axi_aresetn,
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_awaddr,
		input wire [2 : 0] s_axi_awprot,
		input wire  s_axi_awvalid,
		output wire  s_axi_awready,
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_wdata,
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] s_axi_wstrb,
		input wire  s_axi_wvalid,
		output wire  s_axi_wready,
		output wire [1 : 0] s_axi_bresp,
		output wire  s_axi_bvalid,
		input wire  s_axi_bready,
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_araddr,
		input wire [2 : 0] s_axi_arprot,
		input wire  s_axi_arvalid,
		output wire  s_axi_arready,
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_rdata,
		output wire [1 : 0] s_axi_rresp,
		output wire  s_axi_rvalid,
		input 	wire  s_axi_rready,

		// Ports of Axi Slave Bus Interface S_AXIS
		input 	wire  s_axis_aclk,
		input 	wire  s_axis_aresetn,
		output 	wire  s_axis_tready,
		input 	wire [C_S_AXIS_TDATA_WIDTH-1 : 0] s_axis_tdata,
		input 	wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] s_axis_tstrb,
		input 	wire  s_axis_tlast,
		input 	wire  s_axis_tvalid,

		// Ports of Axi Master Bus Interface M_AXIS
		input 	wire  m_axis_aclk,
		input 	wire  m_axis_aresetn,
		output	wire  m_axis_tvalid,
		output 	wire [C_M_AXIS_TDATA_WIDTH-1 : 0] 		m_axis_tdata,
		output 	wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] 	m_axis_tstrb,
		output 	wire  m_axis_tlast,
		input 	wire  m_axis_tready
	);
// Instantiation of Axi Bus Interface S_AXI

	wire 	en	;
	wire	[C_M_AXIS_TDATA_WIDTH-1:0]	filter_in , filter_out	;

	my_fir_v1_0_S_AXI # ( 
		.C_S_AXI_DATA_WIDTH		(C_S_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH		(C_S_AXI_ADDR_WIDTH),
		.C_M_AXIS_TDATA_WIDTH	(C_S_AXIS_TDATA_WIDTH),
		.TAPS					(TAPS),
		.FILTER_DATA_WIDTH		(FILTER_DATA_WIDTH),
		.BASE_ADDR				(BASE_ADDR)
	) my_fir_v1_0_S_AXI_inst (
		.S_AXI_ACLK		(s_axi_aclk),
		.S_AXI_ARESETN	(s_axi_aresetn),
		.S_AXI_AWADDR	(s_axi_awaddr),
		.S_AXI_AWPROT	(s_axi_awprot),
		.S_AXI_AWVALID	(s_axi_awvalid),
		.S_AXI_AWREADY	(s_axi_awready),
		.S_AXI_WDATA	(s_axi_wdata),
		.S_AXI_WSTRB	(s_axi_wstrb),
		.S_AXI_WVALID	(s_axi_wvalid),
		.S_AXI_WREADY	(s_axi_wready),
		.S_AXI_BRESP	(s_axi_bresp),
		.S_AXI_BVALID	(s_axi_bvalid),
		.S_AXI_BREADY	(s_axi_bready),
		.S_AXI_ARADDR	(s_axi_araddr),
		.S_AXI_ARPROT	(s_axi_arprot),
		.S_AXI_ARVALID	(s_axi_arvalid),
		.S_AXI_ARREADY	(s_axi_arready),
		.S_AXI_RDATA	(s_axi_rdata),
		.S_AXI_RRESP	(s_axi_rresp),
		.S_AXI_RVALID	(s_axi_rvalid),
		.S_AXI_RREADY	(s_axi_rready),

		//streaming 
		.S_AXIS_ACLK	(s_axis_aclk),
		.S_AXIS_ARESETN	(s_axis_aresetn),
		.S_AXIS_TDATA	(filter_in),
		.M_AXIS_TDATA	(filter_out),
		.en				(en)
	);


// Instantiation of Axi Bus Interface S_AXIS
	my_fir_v1_0_S_AXIS # ( 
		.C_S_AXIS_TDATA_WIDTH(C_S_AXIS_TDATA_WIDTH)
	) my_fir_v1_0_S_AXIS_inst (
		.S_AXIS_ACLK(s_axis_aclk),
		.S_AXIS_ARESETN(s_axis_aresetn),
		.S_AXIS_TREADY(s_axis_tready),
		.S_AXIS_TDATA(s_axis_tdata),
		.S_AXIS_TSTRB(s_axis_tstrb),
		.S_AXIS_TLAST(s_axis_tlast),
		.S_AXIS_TVALID(s_axis_tvalid),
		.stream_data_out(filter_in),
		.en(en)
	);

// Instantiation of Axi Bus Interface M_AXIS
	my_fir_v1_0_M_AXIS # ( 
		.C_M_AXIS_TDATA_WIDTH(C_M_AXIS_TDATA_WIDTH),
		.TAPS(TAPS)
	) my_fir_v1_0_M_AXIS_inst (
		.M_AXIS_ACLK(m_axis_aclk),
		.M_AXIS_ARESETN(m_axis_aresetn),
		.M_AXIS_TVALID(m_axis_tvalid),
		.M_AXIS_TDATA(m_axis_tdata),
		.M_AXIS_TSTRB(m_axis_tstrb),
		.M_AXIS_TLAST(m_axis_tlast),
		.M_AXIS_TREADY(m_axis_tready),
		.stream_data_in(filter_out),
		.en(s_axis_tvalid & s_axis_tready),
		.last(s_axis_tlast)
	);

	// Add user logic here

	// User logic ends

	endmodule
