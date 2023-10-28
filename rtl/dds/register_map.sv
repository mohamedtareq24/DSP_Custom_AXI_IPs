/*
This is register map for the DDS core 
3 x 32 bit Registers are used CTRL , DATA and STAT
STAT register is saving the current sample of the DDS core
*/
module register_map (
    input                                       clk                     ,
    input                                       a_rst_n                 ,
// Bus 
    input                                       i_reg_map_write         ,
    input                                       i_reg_map_read          ,
    input                 [31:0]                i_reg_map_addrs         ,
    input   logic signed  [SIG_WIDTH-1:0]       i_reg_map_writedata     ,
    output  logic         [31:0]                o_reg_map_readdata      ,

// core 
    input   logic signed  [SIG_WIDTH-1:0]       i_reg_map_signal        ,
    output  logic         [31:0]                o_reg_map_ctrl_reg      ,
    output  logic         [31:0]                o_reg_map_data_reg      ,
    output  logic         [31:0]                o_reg_map_stat_reg      ,
    output  logic         [31:0]                o_reg_map_lngth_reg     ,
    output  logic         [31:0]                o_reg_map_clk_div_reg   
);

parameter   SIG_WIDTH   =   16  ;
parameter   CTRL        =   0   ; 
parameter   DATA        =   1   ;  
parameter   CLKDIV      =   2   ;
parameter   STAT        =   3   ;
parameter   LNGTH       =   4   ;

logic   [31:0]  registers [8] ;

// logic   [31:0]  ctrl_reg    ;
// logic   [31:0]  data_reg    ;
// logic   [31:0]  stat_reg    ;
// logic   [31:0]  clk_div_reg ;  

// writable registers
always @(posedge clk or negedge a_rst_n)       
begin
    if (!a_rst_n)
    begin
        registers [CTRL]    <=  0   ;
        registers [DATA]    <=  0   ;
        registers [CLKDIV]  <=  0   ;  
        registers [LNGTH]   <=  0   ;
    end
    else if (i_reg_map_write)
    begin
        case (i_reg_map_addrs)
            CTRL    :   registers [CTRL]    <=  i_reg_map_writedata      ;
            DATA    :   registers [DATA]    <=  i_reg_map_writedata      ;
            CLKDIV  :   registers [CLKDIV]  <=  i_reg_map_writedata      ;
            LNGTH   :   registers [LNGTH]   <=  i_reg_map_writedata      ;
        endcase
    end
end

// read only registers
always @(posedge clk or negedge a_rst_n)       
begin
    if (!a_rst_n)
    begin
        registers [STAT]    <=  0   ;
    end
    else
    begin
        registers [STAT]    <=  i_reg_map_signal   ;
    end
end

// 
always @(*)
begin
    if (i_reg_map_read)
    case (i_reg_map_addrs)
        CTRL    :   o_reg_map_readdata  =   registers[CTRL]     ;
        DATA    :   o_reg_map_readdata  =   registers[DATA]     ; 
        CLKDIV  :   o_reg_map_readdata  =   registers[CLKDIV]   ;
        STAT    :   o_reg_map_readdata  =   registers[STAT]     ;
        LNGTH   :   o_reg_map_readdata  =   registers[LNGTH]    ;
        
        default :   o_reg_map_readdata  =   registers[STAT]     ;
    endcase
    else
        o_reg_map_readdata  =   32'b0   ;
end

always @(*) begin
o_reg_map_ctrl_reg      =   registers[CTRL];
o_reg_map_data_reg      =   registers[DATA];
o_reg_map_stat_reg      =   registers[STAT];
o_reg_map_lngth_reg     =   registers[LNGTH];
o_reg_map_clk_div_reg   =   registers[CLKDIV];
end



endmodule //register_map