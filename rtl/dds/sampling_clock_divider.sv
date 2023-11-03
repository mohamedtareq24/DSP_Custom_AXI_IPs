module sampling_clock_divider (
    input                                       clk                         ,
    input                                       a_rst_n                     ,
    /// Bus interface
    input                   [31:0]              i_ckdivider_addrs           , 
    input                                       i_ckdivider_write           ,
    //registermap 
    input                   [31:0]              i_ckdivider_clk_div_reg     ,
    input                   [31:0]              i_ckdivider_ctrl_reg        ,
    //sampling signal 
    output    logic                             o_ckdivider_sample_en     
);
    /// counter with load 
parameter   CLKDIV              =       4 ; 
parameter   CTRL_RST_BIT        =       0 ;
parameter   CTRL_STRT_BIT       =       1 ;

logic [31:0]  counter ;

always @(posedge clk or negedge a_rst_n) 
begin
    if (!a_rst_n)
    begin
        counter <= 0;
    end
    else if (i_ckdivider_ctrl_reg[CTRL_RST_BIT])
        counter <=  0;
    else if (i_ckdivider_write & i_ckdivider_addrs == CLKDIV)
    begin
        counter <= (i_ckdivider_clk_div_reg >> 1) - 1 ;  // divide by even numbers
    end
    else if (i_ckdivider_ctrl_reg[CTRL_STRT_BIT])
    begin
        counter <=  counter - 1 ;
        if (counter == 0)
            begin
            counter <= (i_ckdivider_clk_div_reg >> 1) - 1 ;
            o_ckdivider_sample_en <= ~  o_ckdivider_sample_en   ;
        end
    end
end


endmodule