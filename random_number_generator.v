module random_number_generator(
	input clock,
	input reset,
	input init,
	output [3:0] out
	);

	parameter	SEED0 = 8'b10010110,
				SEED1 = 8'b01000001,
				SEED2 = 8'b00010110,
				SEED3 = 8'b10111001;

	fibonacci_lfsr rng0(
		.clk	(clock),
		.rst	(reset),
		.init	(init),
		.seed	(SEED0),
		.rn		(out[0]));
	
	fibonacci_lfsr rng1(
		.clk	(clock),
		.rst	(reset),
		.init	(init),
		.seed	(SEED1),
		.rn		(out[1]));

	fibonacci_lfsr rng2(
		.clk	(clock),
		.rst	(reset),
		.init	(init),
		.seed	(SEED2),
		.rn		(out[2]));

	fibonacci_lfsr rng3(
		.clk	(clock),
		.rst	(reset),
		.init	(init),
		.seed	(SEED3),
		.rn		(out[3]));

endmodule

module fibonacci_lfsr(
	input  clk,
	input  rst,
	input  init,
	input  [8:0]seed,
	output rn
	);

	reg [8:0] data;
	assign rn = data[8];
	wire feedback = data[8] ^ data[4] ^ data[1] ;

	always @(posedge clk)
  	if (rst) 
    	data <= seed;
  	else if(init)
  		data <= seed;
  	else
    	data <= {data[7:0], feedback} ;

endmodule