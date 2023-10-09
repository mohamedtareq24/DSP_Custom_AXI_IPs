module shift_reg (
    input                                   clk         ,
    input                                   rst         ,   //clear signal 
    input                                   en          ,

    input       [SIG_WIDTH-1:0]             sr_in       ,
    output      [SIG_WIDTH-1:0]             sr_out
);

parameter   SIG_WIDTH       =   16  ;
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
assign sr_out = sr[DEPTH-1];

endmodule



