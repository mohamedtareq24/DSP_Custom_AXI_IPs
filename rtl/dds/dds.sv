module dds ( 
    input                                       clk             ,
    input                                       a_rst_n         ,
    // bus intreface
    input                   [31:0]              i_dds_addrs     ,           //THETAS,AMPLS or DELTAS 
    input   logic signed    [SIG_WIDTH-1:0]     i_dds_fifo_data ,       

    //register map
    input                   [31:0]              i_dds_ctrl_reg  ,
    input                   [31:0]              i_dds_data_reg  ,
    input                   [31:0]              i_dds_stat_reg  ,

    //sample timer 
    input                                       i_dds_sample_en ,           // updates the sample 


    // all registers are read,write  
    output  logic signed  [SIG_WIDTH-1:0]       o_dds_signal                // DDS output 
);

parameter 	SIG_WIDTH		=	16;

parameter   THETAS          =    0;
parameter   DELTAS          =    1;
parameter   AMPLS           =    2;

parameter   DDS_RST_BIT     =   0;
parameter   DDS_STRT_BIT    =   1;

logic                                   thetas_en ,     deltas_en   ,   ampls_en        ;
logic   signed      [SIG_WIDTH-1:0]     thetas_in ,     deltas_in   ,   ampls_in        ; 
logic   signed      [SIG_WIDTH-1:0]     thetas_out,     deltas_out  ,   ampls_out       ;
logic   signed      [SIG_WIDTH-1:0]     theta_reg ,     deltas_reg  ,   ampls_reg   ,   ampls_reg_dly   ;
logic   signed      [SIG_WIDTH-1:0]     sin_index ,     sin_out     ,   sin_index_temp  ;
logic   signed      [SIG_WIDTH-1:0]     mult_out  ,     accmltor    ;

logic                                       dds_rst       ,           // soft reset, reset before writing any data 
logic                                       dds_start     ,

assign  dds_rst         =   ctrl_reg [DDS_RST_BIT]  ;
assign  dds_start       =   ctrl_reg [DDS_STRT_BIT] ;


always_comb begin : fifo_addrs_decoder
    thetas_en   =   0;
    thetas_in   =   0;
    deltas_en   =   0;
    deltas_in   =   0;
    ampls_en    =   0;
    ampls_in    =   0;
    
    if (i_dds_start)    /// buffer circulats the data 
    begin
        thetas_en   =   1;
        deltas_en   =   1;
        ampls_en    =   1;
        thetas_in   =   sin_index_temp  ;
        deltas_in   =   deltas_out      ;
        ampls_in    =   ampls_out       ;
    end
    else
    begin
        case (i_dds_addrs)
            THETAS  :  
            begin
                thetas_en   =   1;
                thetas_in   =   i_dds_fifo_data;
            end 
            DELTAS  :  
            begin
                deltas_en   =   1;
                deltas_in   =   i_dds_fifo_data;
            end
            AMPLS  :  
            begin
                ampls_en   =   1;
                ampls_in   =   i_dds_fifo_data;
            end  
        endcase
    end
end


shift_reg thetas_fifo (
    .clk    (clk)           ,
    .rst    (dds_rst)     ,
    .en     (thetas_en)     ,
    .sr_in  (thetas_in)     ,
    .sr_out (thetas_out)    
);

shift_reg deltas_fifo (
    .clk    (clk)           ,
    .rst    (dds_rst)     ,
    .en     (deltas_en)     ,
    .sr_in  (deltas_in)     ,
    .sr_out (deltas_out)
);

always_ff @( posedge clk or negedge a_rst_n ) 
begin
    if (!a_rst_n)
    begin
        theta_reg       <=  0;
        deltas_reg      <=  0;
        ampls_reg       <=  0;
        ampls_reg_dly   <=  0;
    end
    else if (dds_rst)
    begin
        theta_reg       <=  0;
        deltas_reg      <=  0;
        ampls_reg       <=  0;
        ampls_reg_dly   <=  0;
    end
    else
    begin
        theta_reg       <=  thetas_out  ;
        deltas_reg      <=  deltas_out  ;      
        ampls_reg_dly   <=  ampls_reg   ;
        ampls_reg       <=  ampls_out   ;    
    end
end

assign  sin_index_temp  = theta_reg + deltas_reg  ; 
assign  sin_index       = sin_index_temp[SIG_WIDTH-1:SIG_WIDTH-8] ;

sin_lut  lut                
(
	.clk    (clk)           ,
    .addr   (sin_index)     , 
	.q      (sin_out)
);

shift_reg ampls_fifo (
    .clk    (clk)           ,
    .rst    (dds_rst)     ,
    .en     (ampls_en)      ,
    .sr_in  (ampls_in)      ,
    .sr_out (ampls_out)
);

assign  mult_out = $signed(ampls_reg_dly) * $signed(sin_out) ;

// accumulator  to superimpose the signals 
always_ff @(posedge clk or negedge a_rst_n)
begin
    if (!a_rst_n)
    begin
        accmltor        <=  0;
        o_dds_signal    <=  0;
    end
    else if (dds_rst)
    begin
        accmltor        <=  0;
        o_dds_signal    <=  0;
    end
    else if (i_dds_sample_en)     // After sampling reset the accumaltor and register it in o_dds_signal 
    begin
        accmltor        <=  0;
        o_dds_signal    <=  accmltor     ; 
    end
        
    else
        accmltor <= accmltor + mult_out ;   //accumlate 
end
endmodule
