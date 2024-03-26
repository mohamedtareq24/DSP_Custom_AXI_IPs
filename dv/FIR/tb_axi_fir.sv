`timescale 1ns/1ps
module tb_axi_fir();
parameter           C_S_AXI_ADDR_WIDTH      = 32;
parameter	        C_S_AXI_DATA_WIDTH      = 32;
parameter           C_S_AXIS_TDATA_WIDTH	= 32;
parameter           C_M_AXIS_TDATA_WIDTH	= 32;

parameter  	    NUM_POINTS      =   1024;
parameter  	    MM_CLKPER       =   100 ;
parameter       STREAM_CLKPER   =   10  ;
parameter       CTRL            =   0   ;
parameter       TAPS            =   53  ;

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




int		        coef_slv_reg_addrs  ;
int             tb_addr             ;
int             tb_data             ;

logic [15:0] fir_coeffs             [1:TAPS];
logic [15:0] noisy_signal           [NUM_POINTS];
logic [15:0] filtered_noisy_signal  [NUM_POINTS];


always  #(MM_CLKPER/2) s_axi_aclk=~s_axi_aclk;

always  
begin
    #(STREAM_CLKPER/2)
    s_axis_aclk =~s_axis_aclk   ;
    m_axis_aclk =~m_axis_aclk   ;
end


initial begin
    //////////////// INITIALIZATION 
    $readmemh("D:/Digital_Electronics/DSP/DSP_course/dv/FIR/fir_coefficients.hex" , fir_coeffs);
    $readmemh("D:/Digital_Electronics/DSP/DSP_course/dv/FIR/noisy_signal.hex" , noisy_signal);
    $readmemh("D:/Digital_Electronics/DSP/DSP_course/dv/FIR/filtered_noisy_signal.hex" , filtered_noisy_signal);

    s_axi_aclk      =   0   ;
    s_axis_aclk     =   0   ;
    m_axis_aclk     =   0   ;

    s_axi_aresetn   =   1   ;
    m_axis_aresetn  =   1   ;
    s_axis_aresetn  =   1   ;
    m_axis_tready   =   0   ;
    
    ///////////////////////////////////////////////////// RESETTING 
    mm_reset()          ;
    stream_reset()      ;   


    $display("TESTING WRITING & READING ");

    /////// SWEEPING ALL SLAVE REGs
    for (coef_slv_reg_addrs = 1; coef_slv_reg_addrs <= TAPS+1 ; coef_slv_reg_addrs = coef_slv_reg_addrs + 1) 
    begin                                                                           /// addrs generation 
        tb_addr     =   coef_slv_reg_addrs              ;                
        tb_data     =   fir_coeffs[coef_slv_reg_addrs];     
        // Write data to address
        axi_write(tb_addr, tb_data);
        #MM_CLKPER;
        axi_read(tb_addr,tb_data);
    end

    axi_write   (CTRL,  0)          ;       
    #MM_CLKPER;      
    axi_read    (CTRL,  0)          ;

    #(MM_CLKPER * 10)  ;
    
    //START the filter 
    axi_write   (CTRL,  1)          ;            

    $display("MODELSIM vs MATLAB")  ;

    axi_stream_master(noisy_signal) ;

    $stop();

end


my_fir_v1_0 #(.TAPS(TAPS)) dut (.*);

task automatic axi_write;
input [C_S_AXI_ADDR_WIDTH - 1 : 0] addr;
input [C_S_AXI_DATA_WIDTH - 1 : 0] data;
int                                write_err ;
begin
    s_axi_wdata     = data;
    s_axi_awaddr    = addr;
    s_axi_awvalid   = 1;
    s_axi_wvalid    = 1;
    s_axi_bready    = 0;
    s_axi_awprot    = 0;
    s_axi_wstrb     = 'hf;

    wait(s_axi_awready && s_axi_wready);
        
    @(posedge s_axi_aclk) ;
    s_axi_awvalid   =   0;
    s_axi_wvalid    =   0;
    s_axi_bready    =   1;
    #MM_CLKPER;
    if (dut.my_fir_v1_0_S_AXI_inst.coef_slv_reg[tb_addr] !== tb_data)
    begin
        $display("Error: Mismatch in AXI4 write at %x: , Wrote Data = %x, Read Data = %x",
        tb_addr, tb_data, dut.my_fir_v1_0_S_AXI_inst.coef_slv_reg[tb_addr]);
        write_err = write_err   +  1;
    end
    else if (write_err  == 0)
        $display ("WRITE SUCCEEDED");    
end
endtask

task automatic axi_read;
input [C_S_AXI_ADDR_WIDTH - 1 : 0]  addr;
input [C_S_AXI_DATA_WIDTH - 1 : 0]  expected_data;
int                                 read_err;     
begin
    s_axi_araddr    = addr;
    s_axi_arvalid   = 1;
    s_axi_rready    = 1;
    s_axi_arprot    = 0;

    wait(s_axi_arready);
    wait(s_axi_rvalid);

    @(posedge s_axi_aclk) ;
    s_axi_arvalid = 0;
    s_axi_rready = 0;

    #MM_CLKPER;
    if (s_axi_rdata !== expected_data) 
    begin
        $display("Error: Mismatch in AXI4 read at %x: ", addr,
        "expected %x, received %x",expected_data, s_axi_rdata);
        read_err = read_err + 1 ;
    end
    else if (read_err  == 0)
        $display ("READ SUCCEEDED")  ;  
end
endtask

//// this task works as a driver taking the input stimulus from MATLAB 
task automatic  axi_stream_master (input logic [15:0] stream_data[NUM_POINTS]);
    m_axis_tready      =     1'b1     ;
    for ( int i=0 ; i < NUM_POINTS ; i=i+1 )
    begin
        @(posedge s_axis_aclk)
        s_axis_tdata     <=     noisy_signal[i]             ;
        s_axis_tstrb     <=     4'b1111                     ;
        s_axis_tlast     <=     1'b0                        ;
        s_axis_tvalid    <=     1'b1                        ;      // driving slave valid 
        wait(s_axis_tready)                                 ;                                   
        #STREAM_CLKPER                                      ;
    end
endtask

task automatic  axi_stream_slave_monitor (input logic [15:0] stream_data);
    for ( int i=0 ; i < NUM_POINTS ; i=i+1 )
    begin
        m_axis_tready      =     1'b1                         ;
        wait(m_axis_tvalid)   ; 
            if (stream_data !== filtered_noisy_signal[i] )
                $display("Point Doesn't Match MATLAB point : %d -> MODELSIM : %h || MATLAB : %h ", i , 
                stream_data , filtered_noisy_signal[i] );
        #STREAM_CLKPER;
    end
endtask

task   stream_reset();
    @(posedge s_axis_aclk)
    begin
        s_axis_aresetn      = 1'b0; // Assert reset for AXI slave
        m_axis_aresetn      = 1'b0;

        #(MM_CLKPER*10);
        s_axis_aresetn      = 1'b1; // Release reset for AXI slave
        m_axis_aresetn      = 1'b1;
    end
endtask

task mm_reset();
    int i ;
    @(posedge s_axi_aclk)
    begin
        s_axi_aresetn  = 1'b0; // Assert reset for AXI slave
        #(MM_CLKPER*10);
        s_axi_aresetn  = 1'b1; // Release reset for AXI slave
    end
    for (i = 1; i < TAPS; i = i + 1) 
    begin                                                                           /// addrs generation 
        if(dut.my_fir_v1_0_S_AXI_inst.coef_slv_reg[i] != 1 )
            $display("ERROR PRESETTING COEF_REG [%d]" , i);
    end
endtask

endmodule
