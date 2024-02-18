module shift_reg #(parameter   SIG_WIDTH       =   16  )(
    input                                   clk         ,
    input                                   rst         ,   //clear signal 
    input                                   en          ,

    input       [SIG_WIDTH-1:0]             sr_in       ,

    output      [SIG_WIDTH-1:0]             sr_1        ,
    output      [SIG_WIDTH-1:0]             sr_8        ,
    output      [SIG_WIDTH-1:0]             sr_16       ,
    output      [SIG_WIDTH-1:0]             sr_32       ,
    output      [SIG_WIDTH-1:0]             sr_64       ,
    output      [SIG_WIDTH-1:0]             sr_128      ,
    output      [SIG_WIDTH-1:0]             sr_256      ,
    output      [SIG_WIDTH-1:0]             sr_out
);


parameter   DEPTH           =   515 ;

reg [SIG_WIDTH-1:0] sr [DEPTH-1:0]  ;
integer             n               ;

always @ (posedge clk or posedge rst)
begin
    if (rst)
    begin
        for (n = DEPTH-1; n >= 0; n = n-1)
        begin
            sr[n] <= 0;
        end
    end
    else if (en)
    begin
        for (n = DEPTH-1; n > 0; n = n-1)
        begin
            sr[n] <= sr[n-1];
        end
        sr[0] <= sr_in;
    end

end
assign  sr_out  =   sr[DEPTH-1] ;
assign  sr_1    =   sr[0]       ;
assign  sr_8    =   sr[7]       ;
assign  sr_16   =   sr[15]      ;
assign  sr_32   =   sr[31]      ;
assign  sr_64   =   sr[63]      ;
assign  sr_128  =   sr[127]     ;
assign  sr_256  =   sr[255]     ;
endmodule



