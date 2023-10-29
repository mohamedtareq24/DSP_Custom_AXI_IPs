module dds ( 
    input                                       clk                 ,
    input                                       a_rst_n             ,
    // bus intreface
    input                   [31:0]              i_dds_addrs         ,      //THETAS,AMPLS or DELTAS
    input                                       i_dds_write         ,              
    //register map
    input                   [31:0]              i_dds_ctrl_reg      ,
    input                   [31:0]              i_dds_thetas_reg    ,
    input                   [31:0]              i_dds_deltas_reg    ,
    input                   [31:0]              i_dds_ampls_reg     ,
    input                   [31:0]              i_dds_lngth_reg     ,
    input                   [31:0]              i_dds_clk_div_reg   ,
    //sample timer 
    input                                       i_dds_sample_en    ,        // updates the sample 
    // DDS output 
    output  logic signed    [SIG_WIDTH-1:0]     o_dds_signal       
);

parameter 	SIG_WIDTH		=	16;

parameter   THETAS          =    0;
parameter   DELTAS          =    1;
parameter   AMPLS           =    2;

parameter   DDS_RST_BIT     =    0;
parameter   DDS_STRT_BIT    =    1;

logic                                   thetas_en ,     deltas_en   ,   ampls_en        ;
logic   signed      [SIG_WIDTH-1:0]     thetas_in ,     deltas_in   ,   ampls_in        ; 
logic   signed      [SIG_WIDTH-1:0]     thetas_out,     deltas_out  ,   ampls_out       ;
logic   signed      [SIG_WIDTH-1:0]     theta_reg ,     deltas_reg  ,   ampls_reg   ,   ampls_reg_dly   ;
logic   signed      [SIG_WIDTH-1:0]     sin_index ,     sin_out     ,   sin_index_temp  ;
logic   signed      [SIG_WIDTH-1:0]     mult_out  ,     accmltor    ;

logic                   dds_rst       ;           // soft reset, reset before writing any data 
logic                   dds_start     ;

logic   [SIG_WIDTH-1:0] deltas_feedback_tap ;
logic   [SIG_WIDTH-1:0] ampls_feedback_tap  ;
logic   [SIG_WIDTH-1:0] thetas_feedback_tap ;

logic   [SIG_WIDTH-1:0] thetas_tap1         ;
logic   [SIG_WIDTH-1:0] thetas_tap8         ;
logic   [SIG_WIDTH-1:0] thetas_tap16        ;
logic   [SIG_WIDTH-1:0] thetas_tap32        ;
logic   [SIG_WIDTH-1:0] thetas_tap64        ;
logic   [SIG_WIDTH-1:0] thetas_tap128       ;
logic   [SIG_WIDTH-1:0] thetas_tap256       ;
logic   [SIG_WIDTH-1:0] thetas_tap512       ;

logic   [SIG_WIDTH-1:0] deltas_tap1         ;
logic   [SIG_WIDTH-1:0] deltas_tap8         ;
logic   [SIG_WIDTH-1:0] deltas_tap16        ;
logic   [SIG_WIDTH-1:0] deltas_tap32        ;
logic   [SIG_WIDTH-1:0] deltas_tap64        ;
logic   [SIG_WIDTH-1:0] deltas_tap128       ;
logic   [SIG_WIDTH-1:0] deltas_tap256       ;
logic   [SIG_WIDTH-1:0] deltas_tap512       ;

logic   [SIG_WIDTH-1:0] ampls_tap1          ;
logic   [SIG_WIDTH-1:0] ampls_tap8          ;
logic   [SIG_WIDTH-1:0] ampls_tap16         ;
logic   [SIG_WIDTH-1:0] ampls_tap32         ;
logic   [SIG_WIDTH-1:0] ampls_tap64         ;
logic   [SIG_WIDTH-1:0] ampls_tap128        ;
logic   [SIG_WIDTH-1:0] ampls_tap256        ;
logic   [SIG_WIDTH-1:0] ampls_tap512        ;

assign  dds_rst         =   i_dds_ctrl_reg [DDS_RST_BIT]  ;
assign  dds_start       =   i_dds_ctrl_reg [DDS_STRT_BIT] ;

//// tap mux 
always @ (*) 
begin
    case (i_dds_lngth_reg)
        1 : begin 
            deltas_feedback_tap     =   deltas_tap1 ;
            ampls_feedback_tap      =   ampls_tap1  ;
            thetas_feedback_tap     =   thetas_tap1 ;
        end
        8 : begin
            deltas_feedback_tap     =   deltas_tap8 ;
            ampls_feedback_tap      =   ampls_tap8  ;
            thetas_feedback_tap     =   thetas_tap8 ;
        end
        16:begin
            deltas_feedback_tap     =   deltas_tap16 ;
            ampls_feedback_tap      =   ampls_tap16  ;
            thetas_feedback_tap     =   thetas_tap16 ;
        end
        32:begin
            deltas_feedback_tap     =   deltas_tap32 ;
            ampls_feedback_tap      =   ampls_tap32  ;
            thetas_feedback_tap     =   thetas_tap32 ;
        end
        64:begin
            deltas_feedback_tap     =   deltas_tap64    ;
            ampls_feedback_tap      =   ampls_tap64     ;
            thetas_feedback_tap     =   thetas_tap64    ;
        end
        128:begin
            deltas_feedback_tap     =   deltas_tap128   ;
            ampls_feedback_tap      =   ampls_tap128    ;
            thetas_feedback_tap     =   thetas_tap128   ;
        end
        256:begin
            deltas_feedback_tap     =   deltas_tap256   ;
            ampls_feedback_tap      =   ampls_tap256    ;
            thetas_feedback_tap     =   thetas_tap256   ;
        end
        default:begin
            deltas_feedback_tap     =   deltas_tap512   ;
            ampls_feedback_tap      =   ampls_tap512    ; 
            thetas_feedback_tap     =   thetas_tap512   ;
        end 
    endcase
end

always_comb 
begin 
    thetas_en   =   0;
    thetas_in   =   0;
    deltas_en   =   0;
    deltas_in   =   0;
    ampls_en    =   0;
    ampls_in    =   0;
    
    if (dds_start)                      /// buffer circulats the data 
    begin                               /// taps to be added here
        thetas_en   =   1;
        deltas_en   =   1;
        ampls_en    =   1;
        thetas_in   =   thetas_feedback_tap         ;
        deltas_in   =   deltas_feedback_tap         ;
        ampls_in    =   ampls_feedback_tap          ;
    end
    else
    begin
        if (i_dds_write)
        begin
            case (i_dds_addrs)
                THETAS  :  
                begin
                    thetas_en   =   1;
                    thetas_in   =   i_dds_thetas_reg;
                end 
                DELTAS  :  
                begin
                    deltas_en   =   1;
                    deltas_in   =   i_dds_deltas_reg;
                end
                AMPLS  :  
                begin
                    ampls_en   =   1;
                    ampls_in   =   i_dds_ampls_reg;
                end  
            endcase
        end
    end
end


shift_reg thetas_fifo (
    .clk    (clk)           ,
    .rst    (dds_rst)       ,
    .en     (thetas_en)     ,
    .sr_in  (thetas_in)     ,
    .sr_1   (thetas_tap1)   ,
    .sr_8   (thetas_tap8)   ,
    .sr_16  (thetas_tap16)  ,
    .sr_32  (thetas_tap32)  ,
    .sr_64  (thetas_tap64)  ,
    .sr_128 (thetas_tap128) ,
    .sr_256 (thetas_tap256) ,
    .sr_out (thetas_tap512)    
);

shift_reg deltas_fifo (
    .clk    (clk)           ,
    .rst    (dds_rst)       ,
    .en     (deltas_en)     ,
    .sr_in  (deltas_in)     ,
    .sr_1   (deltas_tap1)   ,
    .sr_8   (deltas_tap8)   ,
    .sr_16  (deltas_tap16)  ,
    .sr_32  (deltas_tap32)  ,
    .sr_64  (deltas_tap64)  ,
    .sr_128 (deltas_tap128) ,
    .sr_256 (deltas_tap256) ,
    .sr_out (deltas_tap512)
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
        theta_reg       <=  thetas_feedback_tap  ;
        deltas_reg      <=  deltas_feedback_tap  ;      
        ampls_reg_dly   <=  ampls_reg            ;
        ampls_reg       <=  ampls_feedback_tap   ;    
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
    .rst    (dds_rst)       ,
    .en     (ampls_en)      ,
    .sr_in  (ampls_in)      ,
    .sr_1   (ampls_tap1)    ,
    .sr_8   (ampls_tap8)    ,
    .sr_16  (ampls_tap16)   ,
    .sr_32  (ampls_tap32)   ,
    .sr_64  (ampls_tap64)   ,
    .sr_128 (ampls_tap128)  ,
    .sr_256 (ampls_tap256)  ,
    .sr_out (ampls_tap512)
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
