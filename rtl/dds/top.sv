module top (
    input                   clk             ,
    input                   a_rst_n         ,
    
    input [31:0]            ctrl_reg        ,
    input [31:0]            thetas_reg      ,
    input [31:0]            deltas_reg      ,
    input [31:0]            ampls_reg       ,
    input [31:0]            stat_reg        ,
    input [31:0]            lngth_reg       ,
    input [31:0]            clkdiv_reg      ,   

    output [SIG_WIDTH-1:0]  signal          ,   //! streaming_source.
    output                  valid           ,   //when a valid signal exsistes this is asserted  
    /// Bus interface
    input                   i_write         ,
    input [31:0]            i_addrs
);

    parameter SIG_WIDTH  = 	16 ;

    logic [SIG_WIDTH-1:0] signal;
    logic        sample_en      ;

    assign  valid = sample_en    ;

    // Instantiate the dds module
    dds u_dds (
        .clk(clk),
        .a_rst_n(a_rst_n),

        .i_dds_addrs(i_addrs),
        .i_dds_write(i_write),

        .i_dds_ctrl_reg     (ctrl_reg)  ,
        .i_dds_thetas_reg   (thetas_reg)    ,
        .i_dds_deltas_reg   (deltas_reg)    ,
        .i_dds_ampls_reg    (ampls_reg)     ,
        .i_dds_lngth_reg    (lngth_reg)     ,
        .i_dds_sample_en    (sample_en) ,
        .o_dds_signal       (signal)
    );

    // Instantiate the sampling_clock_divider module
    sampling_clock_divider u_clkdiv (
        .clk(clk),
        .a_rst_n(a_rst_n),
        
        .i_ckdivider_addrs(i_addrs),
        .i_ckdivider_write(i_write),
        
        .i_ckdivider_clk_div_reg   (clkdiv_reg),
        .i_ckdivider_ctrl_reg     (ctrl_reg),
        .o_ckdivider_sample_en    (sample_en)
    );

endmodule
