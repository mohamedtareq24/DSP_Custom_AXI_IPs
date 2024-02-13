module reg_file #(parameter WIDTH = 32, DEPTH = 16)(

    input   logic                       clk,
    input   logic                       arst_n,  //! Active-low asynchronous reset

    //! bus interface 
    input   logic                       i_wr_en,    //! write enable.
    input   logic [$clog2(DEPTH)-1:0]   i_addr, //! write/read address.
    input   logic [WIDTH-1:0]           i_write_data,   
    output  logic [WIDTH-1:0]           o_read_data ,

    output logic [WIDTH-1:0]  o_coef [DEPTH-1:0]    //! filter coefficients .
);

    logic [WIDTH-1:0] mem [DEPTH-1:0];
	integer j = 0;

    always @(posedge clk or negedge arst_n )
    begin
			if (!arst_n)
            begin
				for (j = 0; j < DEPTH; j=j+1)
					mem[j] <= 0 ;
            end
			else if (i_wr_en)
            begin
                mem[i_addr] <= i_write_data;  // Write operation
            end
    end

    
    assign o_read_data =  mem[i_addr];
    
    genvar i;
	generate
        for (i = 0; i < DEPTH; i=i+1) begin : gen_coef_assign
            assign o_coef[i] = mem[i];
        end
    endgenerate

endmodule
