`timescale 1ns/1ps
module tb_fir();
parameter           C_S_AXI_ADDR_WIDTH    = 32;
parameter	        C_S_AXI_DATA_WIDTH    = 32;
parameter           C_S_AXIS_TDATA_WIDTH	= 32;
parameter           C_M_AXIS_TDATA_WIDTH	= 32;


logic                                           s_axi_aclk;
logic                                           s_axi_aresetn;
logic       [C_S_AXI_ADDR_WIDTH-1 : 0]          s_axi_awaddr;
logic       [2 : 0]                             s_axi_awprot;
logic                                           s_axi_awvalid;
logic                                           s_axi_awready;
logic       [C_S_AXI_DATA_WIDTH-1 : 0]          s_axi_wdata;
logic       [(C_S_AXI_DATA_WIDTH/8)-1 : 0]      s_axi_wstrb;
logic                                           s_axi_wready;
logic                                           s_axi_wvalid;
logic       [1 : 0]                             s_axi_bresp;
logic                                           s_axi_bvalid;
logic                                           s_axi_bready;
logic       [C_S_AXI_ADDR_WIDTH-1 : 0]          s_axi_araddr;
logic       [2 : 0]                             s_axi_arprot;
logic                                           s_axi_arvalid;
logic                                           s_axi_arready;
logic       [C_S_AXI_DATA_WIDTH-1 : 0]          s_axi_rdata;
logic       [1 : 0]                             s_axi_rresp;
logic                                           s_axi_rvalid;
logic                                           s_axi_rready;

// Ports of Axi Slave Bus Interface S_AXIS
logic                                           s_axis_aclk;
logic                                           s_axis_aresetn;
logic                                           s_axis_tready;
logic       [C_S_AXIS_TDATA_WIDTH-1 : 0]        s_axis_tdata;
logic       [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0]    s_axis_tstrb;
logic                                           s_axis_tlast;
logic                                           s_axis_tvalid;

// Ports of Axi Master Bus Interface M_AXIS
logic                                           m_axis_aclk;
logic                                           m_axis_aresetn;
logic                                           m_axis_tvalid;
logic       [C_M_AXIS_TDATA_WIDTH-1 : 0]        m_axis_tdata;
logic       [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0]    m_axis_tstrb;
logic                                           m_axis_tlast;
logic                                           m_axis_tready;


localparam  	NUM_POINTS  =   1024;
localparam  	CLKPER      =   10  ;

int		        coef_slv_reg_addrs  ;
int             tb_addr             ;
int             tb_data             ;

logic [15:0] fir_coeffs             [NUM_POINTS];
logic [15:0] noisy_siganl           [NUM_POINTS];
logic [15:0] filtered_noisy_signal  [NUM_POINTS];


always  #(CLKPER/2) s_axi_aclk=~s_axi_aclk;

initial begin
    $readmemh("./fir_coefficients.hex" , fir_coeffs);
    $readmemh("./noisy_siganl.hex" , noisy_siganl);
    $readmemh("./filtered_noisy_siganl.hex" , filtered_noisy_siganl);

    s_axi_aresetn = 1'b1; // Release reset for AXI slave
    #18
    s_axi_aresetn = 1'b0; // Assert reset for AXI slave
    #10; // Hold for some time
    s_axi_aresetn = 1'b1; // Release reset for AXI slave

    $display("TESTING WRITING & READING ");
    for (coef_slv_reg_addrs = 1; coef_slv_reg_addrs < 129; coef_slv_reg_addrs = coef_slv_reg_addrs + 1) 
    begin                                                                           /// addrs generation 
        tb_addr     =   coef_slv_reg_addrs ;                
        tb_data     =   fir_coeffs[coef_slv_reg_addrs];     
        // Write data to address
        axi_write(tb_addr, tb_data);
        #CLKPER ;
        $display("Write:Address = %d, Data = %h, Read Data = %h, Write Successful = %b",
        tb_addr, tb_data, dut.slv_reg[tb_addr], (dut.slv_reg[tb_addr] == tb_data));
        enforce_axi_read(tb_addr,tb_data);
        #CLKPER ;
    end
    axi_write(0, 0);             
    #CLKPER;
    $display("Write:Address = %d, Data = %h, Read Data = %h, Write Successful = %b",
    tb_addr, tb_data, dut.ctrl_reg, (dut.ctrl_reg == tb_data));
    enforce_axi_read(0,0);
    #CLKPER ;

    axi_write(0, 1);            //START the filter  
    #CLKPER;
    $display("Write:Address = %d, Data = %h, Read Data = %h, Write Successful = %b",
    tb_addr, tb_data, dut.ctrl_reg, (dut.ctrl_reg == tb_data));
    enforce_axi_read(tb_addr,tb_data);
    #CLKPER ;

    
    $display("MODELSIM vs MATLAB");

end


my_fir_v1_0 dut (.*);

task automatic axi_write;
input [C_S_AXI_ADDR_WIDTH - 1 : 0] addr;
input [C_S_AXI_DATA_WIDTH - 1 : 0] data;
begin
    s_axi_wdata = data;
    s_axi_awaddr = addr;
    s_axi_awvalid = 1;
    s_axi_wvalid = 1;

    wait(s_axi_awready && s_axi_wready);

    @(posedge s_axi_aclk) ;
    s_axi_awvalid = 0;
    s_axi_wvalid = 0;
end
endtask

task automatic enforce_axi_read;
input [C_S_AXI_ADDR_WIDTH - 1 : 0] addr;
input [C_S_AXI_DATA_WIDTH - 1 : 0] expected_data;
begin
    s_axi_araddr = addr;
    s_axi_arvalid = 1;
    s_axi_rready = 1;
    wait(s_axi_arready);
    wait(s_axi_rvalid);

    if (s_axi_rdata != expected_data) begin
    $display("Error: Mismatch in AXI4 read at %x: ", addr,
        "expected %x, received %x",
        expected_data, s_axi_rdata);
    end

    @(posedge s_axi_aclk) ;
    s_axi_arvalid = 0;
    s_axi_rready = 0;
end
endtask

task automatic  axi_stream_master (input logic [15:0] stream_data[NUM_POINTS]);
    for ( int i=0 ; i < NUM_POINTS ; i=i+1   )
    begin
        @(posedge s_axi_aclk)
        s_axis_tdata     <=   filtered_noisy_signal[i]        ;
        s_axis_tstrb     <=      4'b1111                      ;
        s_axis_tlast     <=      1'b0                         ;
        s_axis_tvalid    <=      1'b1                         ;

        wait(s_axis_tready)                                   ;       // don't change data until the slave is ready 
    end
endtask

endmodule
