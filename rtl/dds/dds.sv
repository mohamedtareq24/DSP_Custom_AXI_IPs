// add the feedback muxes controlled by start
module dds (
    input                               clk             ,
    input                               a_rst_n         ,

    input                               i_dds_rst       ,
    input                               i_dds_start     ,
    input           [8:0]               i_dds_addrs     ,

    input   signed  [SIG_WIDTH-1:0]     i_dds_fifo_data , 
    output  signed  [SIG_WIDTH-1:0]     o_signal        
);

parameter 	SIG_WIDTH		=	16	;
parameter   THETAS  =    0;
parameter   DELTAS  =    1;
parameter   AMPLS   =    2;

logic                                   thetas_en ,     deltas_en   ,   ampls_en        ;

logic   signed      [SIG_WIDTH-1:0]     thetas_in ,     deltas_in   ,   ampls_in        ; 
logic   signed      [SIG_WIDTH-1:0]     thetas_out,     deltas_out  ,   ampls_out       ;
logic   signed      [SIG_WIDTH-1:0]     theta_reg ,     deltas_reg  ,   ampls_reg   ,   ampls_reg_dly   ;
logic               [SIG_WIDTH-1:0]     sin_index ,     sin_out     ,   sin_index_temp  ;


always_comb begin : fifo_addrs_decoder
    thetas_en   =   0;
    thetas_in   =   0;
    deltas_en   =   0;
    deltas_in   =   0;
    ampls_en    =   0;
    ampls_in    =   0;
    
    if (i_dds_start)    
    begin
        thetas_en   =   1;
        deltas_en   =   1;
        ampls_en    =   1;
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
    .rst    (i_dds_rst)     ,
    .en     (thetas_en)     ,
    .sr_in  (thetas_in)     ,
    .sr_out (thetas_out)    
);

shift_reg deltas_fifo (
    .clk    (clk)           ,
    .rst    (i_dds_rst)     ,
    .en     (deltas_en)     ,
    .sr_in  (deltas_in)     ,
    .sr_out (deltas_out)
);

always_ff @( posedge clk or negedge a_rst_n ) 
begin
    if (!a_rst_n)
    begin
        theta_reg   <=  0;
        deltas_reg  <=  0;
        ampls_reg   <=  0;
    end
    else if (i_dds_rst)
    begin
        theta_reg   <=  0;
        deltas_reg  <=  0;
        ampls_reg   <=  0;
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
    .rst    (i_dds_rst)     ,
    .en     (ampls_en)      ,
    .sr_in  (ampls_in)      ,
    .sr_out (ampls_out)
);

assign  o_signal = $signed(ampls_reg_dly) * $signed(sin_out) ;


endmodule
