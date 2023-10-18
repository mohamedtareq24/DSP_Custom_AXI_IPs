/*
This is register map for the DDS core 
3 x 32 bit Registers are used CTRL , DATA and STAT
*/
module register_map (
    input                                       clk                 ,
    input                                       a_rst_n             ,

    input                 [31:0]                i_reg_map_addrs     ,
    input   logic signed  [SIG_WIDTH-1:0]       i_reg_map_data      ,
    input   logic signed  [SIG_WIDTH-1:0]       i_reg_map_signal    ,

    output                                      o_reg_map_rst       ,
    output                                      o_reg_map_start     ,
    output  logic signed  [SIG_WIDTH-1:0]       o_reg_map_fifo_data ,
    
);

logic   [31:0]  ctrl_reg    ;
logic   [31:0]  data_reg    ;
logic   [31:0]  stat_reg    ;

always @(posedge clk or negedge a_rst_n)       
begin
    if (!a_rst_n)
    begin
        ctrl_reg    <=  0   ;
        data_reg    <=  0   ;
        stat_reg    <=  0   ;
    end
    else
    begin
        case (i_reg_map_addrs)
            CTRL    :   ctrl_reg    <=  i_reg_map_data      ;
            DATA    :   data_reg    <=  i_reg_map_data      ;
            STAT    :   stat_reg    <=  i_reg_map_signal    ;
            default: 
        endcase
    end
end




endmodule //register_map