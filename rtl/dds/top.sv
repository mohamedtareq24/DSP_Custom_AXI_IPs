module top (
    input                   clk,
    input                   a_rst_n,
    /// Bus interface
    input                   i_write,
    input                   i_read,
    input           [31:0]  i_addrs,
    input   logic   [31:0]  i_writedata,
    output  logic   [31:0]  o_readdata
);

    parameter SIG_WIDTH  = 	16 ;

    logic [SIG_WIDTH-1:0] signal;
    
    logic [31:0] ctrl_reg       ;
    logic [31:0] thetas_reg     ;
    logic [31:0] deltas_reg     ;
    logic [31:0] ampls_reg      ;
    logic [31:0] stat_reg       ;
    logic [31:0] lngth_reg      ;
    logic [31:0] clkdiv_reg     ;   
    logic        sample_en      ;

    // Instantiate the register_map module
    register_map u_regmap (
        .clk(clk),
        .a_rst_n(a_rst_n),

        .i_reg_map_write    (i_write),
        .i_reg_map_read     (i_read),
        .i_reg_map_addrs    (i_addrs),
        .i_reg_map_writedata(i_writedata),
        .o_reg_map_readdata (o_readdata),

        .i_reg_map_signal       (signal),
        .o_reg_map_ctrl_reg     (ctrl_reg),
        .o_reg_map_thetas_reg   (thetas_reg),
        .o_reg_map_delats_reg   (deltas_reg),
        .o_reg_map_ampls_reg    (ampls_reg),
        .o_reg_map_stat_reg     (stat_reg),
        .o_reg_map_lngth_reg    (lngth_reg),
        .o_reg_map_clk_div_reg   (clkdiv_reg)
    );


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
