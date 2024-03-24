`timescale 1ns / 100ps
module my_dds_v1_0_S00_AXI_tb;
    // Parameters
    localparam CTRL =   0;
    localparam THETAS = 1;
    localparam DELTAS = 2;
    localparam AMPLS =  3;
    localparam CLKDIV = 4;
    localparam STAT =   5;
    localparam LNGTH =  6;
    localparam RSRVD =  7;

    localparam C_S_AXI_DATA_WIDTH = 32  ;
    localparam C_S_AXI_ADDR_WIDTH = 5   ;

    // Signals
    logic                                   s_axi_aclk;
    logic                                   s_axi_aresetn;
    logic    [C_S_AXI_ADDR_WIDTH-1:0]       s_axi_awaddr;
    logic    [2:0]                          s_axi_awprot;
    logic                                   s_axi_awvalid;
    logic                                   s_axi_awready;
    logic    [C_S_AXI_DATA_WIDTH-1:0]       s_axi_wdata;
    logic    [(C_S_AXI_DATA_WIDTH/8)-1:0]   s_axi_wstrb;
    logic                                   s_axi_wvalid;
    logic                                   s_axi_wready;
    logic     [1:0]                         s_axi_bresp;
    logic                                   s_axi_bvalid;
    logic                                   s_axi_bready;
    logic    [C_S_AXI_ADDR_WIDTH-1:0]       s_axi_araddr;
    logic    [2:0]                          s_axi_arprot;
    logic                                   s_axi_arvalid;
    logic                                   s_axi_arready;
    logic     [C_S_AXI_DATA_WIDTH-1:0]      s_axi_rdata;
    logic     [1:0]                         s_axi_rresp;
    logic                                   s_axi_rvalid;
    logic                                   s_axi_rready;
    logic     [15:0]                        out_stream;
    logic                                   valid;
    
    // DUT instantiation
    my_dds_v1_0_S00_AXI #(
        .CTRL(CTRL),
        .THETAS(THETAS),
        .DELTAS(DELTAS),
        .AMPLS(AMPLS),
        .CLKDIV(CLKDIV),
        .STAT(STAT),
        .LNGTH(LNGTH),
        .RSRVD(RSRVD),
        .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH)
    ) dut (
        .S_AXI_ACLK     (s_axi_aclk)    ,
        .S_AXI_ARESETN  (s_axi_aresetn) ,

        .S_AXI_AWADDR   (s_axi_awaddr)  ,
        .S_AXI_AWPROT   (0)             ,
        .S_AXI_AWVALID  (s_axi_awvalid) ,
        .S_AXI_AWREADY  (s_axi_awready) ,

        .S_AXI_WDATA    (s_axi_wdata)   ,
        .S_AXI_WSTRB    (4'b1111)       ,
        .S_AXI_WVALID   (s_axi_wvalid)  ,
        .S_AXI_WREADY   (s_axi_wready)  ,

        .S_AXI_BRESP    (s_axi_bresp)   ,
        .S_AXI_BVALID   (s_axi_bvalid)  ,
        .S_AXI_BREADY   (1'b1)          ,

        .S_AXI_ARADDR   (s_axi_araddr)  ,
        .S_AXI_ARPROT   (0)  ,  
        .S_AXI_ARVALID  (s_axi_arvalid) ,
        .S_AXI_ARREADY  (s_axi_arready) ,

        .S_AXI_RDATA    (s_axi_rdata)   ,
        .S_AXI_RRESP    (s_axi_rresp)   ,
        .S_AXI_RVALID   (s_axi_rvalid)  ,
        .S_AXI_RREADY   (s_axi_rready)  ,

        .out_stream     (out_stream)    ,  
        .valid          (valid)
    );

    int CLKPER = 10 ;
    integer i;
    int tb_data;
    int tb_addr;
    int gap_clks;

    always #((CLKPER) / 2) s_axi_aclk = ~s_axi_aclk;
    always #((CLKPER) / 2) gap_clks    = $urandom_range(1,10);      /// randomizing some delay for the AXI transactions

    initial 
    begin 
        s_axi_aclk  =   0;
        // Reset sequence
        s_axi_aresetn = 1;
        #10;
        s_axi_aresetn = 0;
        #10;
        s_axi_aresetn = 1;
        #10;
        ///////////////////////////////// TESTING THE AXI LITE SLAVE
        $display("TESTING WRITING");
        for (i = 0; i < 100; i++) 
        begin 
            tb_addr     = $urandom_range(0, 6); // Generate random address between 0 and 6
            if (tb_addr == 5 )
                tb_addr = 6 ;
            tb_data = $urandom; // Generate random data
            // Write data to address
            axi_write(tb_addr, tb_data);
                // Check the write using the . operator
            #CLKPER;
            $display("Write:Address = %d, Data = %h, Read Data = %h, Write Successful = %b",
            tb_addr, tb_data, dut.slv_reg[tb_addr], (dut.slv_reg[tb_addr] == tb_data));
            #(CLKPER*gap_clks); 
        end
///////////////////////////////// DDS SINGLE SINUS
        $display("STARTING DDS");
        axi_write(CTRL, 2'b1); // soft reset 
        # (CLKPER * gap_clks);
        axi_write(CTRL, 2'b0); // soft reset 
        # (CLKPER * gap_clks);
        axi_write(LNGTH, 2);  // single sinus 
        # (CLKPER * gap_clks);
        axi_write(CLKDIV, 18); // you have 4 cycles / sample 
        # (CLKPER * gap_clks);
        axi_write(THETAS, 0); // Phase = 0 
        # (CLKPER * gap_clks);
        axi_write(DELTAS, 16'h0100); // 8 samples in a cycle  
        # (CLKPER * gap_clks);
        axi_write(AMPLS, 16'h4); // Ampl of 1   
        # (CLKPER * gap_clks);    
        axi_write(CTRL, 2'b10);

        $dumpfile("signal.vcd");
            $dumpvars(1,dut.dds_top_u.u_dds.o_dds_signal);
        #  20000 ;
            $dumpoff;
        /// single sinus
        // for (i = 0; i < 64; i = i + 1) begin
        //     // Generate random data
        //     data_to_write = $random;
        //     // Randomize the address (lay between 0 & 7)
        //     addr = $urandom_range(0,6);
        //     // Write the data to the address
        //     // Read the data again .
        //     //enforce_axi_read(addr, data_to_write);
        // end
        $stop();
    end

    task automatic axi_write;
    input [C_S_AXI_ADDR_WIDTH - 1 : 0] addr;
    input [C_S_AXI_DATA_WIDTH - 1 : 0] data;
    begin
        s_axi_wdata = data;
        s_axi_awaddr = addr;
        s_axi_awvalid = 1;
        s_axi_wvalid = 1;

        wait(s_axi_awready && s_axi_wready);
    
        @(posedge s_axi_aclk) #1;
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
    
        @(posedge s_axi_aclk) #1;
        s_axi_arvalid = 0;
        s_axi_rready = 0;
    end
    endtask
endmodule

