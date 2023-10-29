/*
This is register map for the DDS core 
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
    output  logic         [31:0]                o_reg_map_thetas_reg    ,
    output  logic         [31:0]                o_reg_map_delats_reg    ,
    output  logic         [31:0]                o_reg_map_ampls_reg     ,
    output  logic         [31:0]                o_reg_map_stat_reg      ,
    output  logic         [31:0]                o_reg_map_lngth_reg     ,
    output  logic         [31:0]                o_reg_map_clk_div_reg   
);

parameter   SIG_WIDTH   =   16  ;

// registers
parameter   CTRL        =   0   ; 
parameter   THETAS      =   1   ;
parameter   DELTAS      =   2   ;
parameter   AMPLS       =   3   ;
parameter   CLKDIV      =   4   ;
parameter   STAT        =   5   ;
parameter   LNGTH       =   6   ;

logic   [31:0]  registers [8] ;

// writable registers
always @(posedge clk or negedge a_rst_n)       
begin
    if (!a_rst_n)
    begin
        registers [CTRL]    <=  0   ;
        registers [CLKDIV]  <=  0   ;  
        registers [LNGTH]   <=  0   ;
        registers [THETAS]  <=  0   ;
        registers [DELTAS]  <=  0   ;
        registers [AMPLS]   <=  0   ;
    end
    else if (i_reg_map_write)
    begin
        case (i_reg_map_addrs)
            CTRL    :   registers [CTRL]    <=  i_reg_map_writedata         ;
            CLKDIV  :   registers [CLKDIV]  <=  i_reg_map_writedata         ;
            LNGTH   :   registers [LNGTH]   <=  i_reg_map_writedata         ;
            THETAS  :   registers [THETAS]  <=  i_reg_map_writedata         ;
            DELTAS  :   registers [DELTAS]  <=  i_reg_map_writedata         ;
            AMPLS   :   registers [AMPLS]   <=  i_reg_map_writedata         ;
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
        THETAS  :   o_reg_map_readdata  =   registers[THETAS]   ;
        DELTAS  :   o_reg_map_readdata  =   registers[DELTAS]   ;
        AMPLS   :   o_reg_map_readdata  =   registers[AMPLS]    ;
        CLKDIV  :   o_reg_map_readdata  =   registers[CLKDIV]   ;
        STAT    :   o_reg_map_readdata  =   registers[STAT]     ;
        LNGTH   :   o_reg_map_readdata  =   registers[LNGTH]    ;

        default :   o_reg_map_readdata  =   registers[STAT]     ;
    endcase
    else
        o_reg_map_readdata  =   32'b0   ;
end

always @(*) begin
o_reg_map_ctrl_reg      =   registers[CTRL]     ;
o_reg_map_thetas_reg    =   registers[THETAS]   ;
o_reg_map_delats_reg    =   registers[DELTAS]   ;
o_reg_map_ampls_reg     =   registers[AMPLS]    ;
o_reg_map_stat_reg      =   registers[STAT]     ;
o_reg_map_lngth_reg     =   registers[LNGTH]    ;
o_reg_map_clk_div_reg   =   registers[CLKDIV]   ;
end



endmodule //register_map