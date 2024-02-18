// Quartus Prime Verilog Template
// Single Port ROM

module sin_lut
#(parameter SIG_WIDTH = 16 )
(
	input [7:0] addr,
	input clk, 
	output reg [(SIG_WIDTH-1):0] q
);

	// Declare the ROM variable
	reg [SIG_WIDTH-1:0] rom[255:0];

	// Initialize the ROM with $readmemb.  Put the memory contents
	// in the file single_port_rom_init.txt.  Without this file,
	// this design will not compile.

	// See Verilog LRM 1364-2001 Section 17.2.8 for details on the
	// format of this file, or see the "Using $readmemb and $readmemh"
	// template later in this section.

	initial
	begin
		$readmemb("D:\\Digital_Electronics\\DSP\\DSP_course\\rtl\\dds\\sin_lut_init_file.txt", rom);
	end

	always @ (posedge clk)
	begin
		q <= rom[addr];
	end

endmodule
