/*** top level module for remake of the Legend of Zelda (1986) by Michael Zhao and Paul Wang (2016) ***/

module zelda_game
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		SW,
		KEY,
		LEDR,
		HEX0,
		HEX1,
		HEX2,
		HEX3,
		HEX4,
		HEX5,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,					//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   							//	VGA Blue[9:0]
	);

	input			CLOCK_50;			//	50 MHz
	// Declare your inputs and outputs here
	input 	[9:0] SW;
	input 	[3:0] KEY;
	output 	[3:0] LEDR;
	output 	[6:0] HEX0;
	output	[6:0] HEX1;
	output 	[6:0] HEX2;
	output	[6:0] HEX3;
	output 	[6:0] HEX4;
	output	[6:0] HEX5;
	// Do not change the following outputs
	output			VGA_CLK;   		//	VGA Clock
	output			VGA_HS;			//	VGA H_SYNC
	output			VGA_VS;			//	VGA V_SYNC
	output			VGA_BLANK_N;	//	VGA BLANK
	output			VGA_SYNC_N;		//	VGA SYNC
	output	[9:0]	VGA_R;   		//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 		//	VGA Green[9:0]
	output	[9:0]	VGA_B;   		//	VGA Blue[9:0]
	
	wire 			reset;
	wire 			c_attack;
	wire 			c_up;
	wire 			c_down;
	wire 			c_left;
	wire 			c_right;
	
	assign 			reset 			= SW[9];
	assign 			c_attack 		= SW[0];
	assign 			c_up 			= ~KEY[3];
	assign 			c_down 			= ~KEY[2];
	assign 			c_left 			= ~KEY[1];
	assign 			c_right 		= ~KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	wire 		[5:0] colour;
	wire 		[8:0] x;
	wire 		[7:0] y;
	wire 		writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn		(~reset),
			.clock 		(CLOCK_50),
			.colour		(colour),
			.x 			(x),
			.y 			(y),
			.plot 		(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R 		(VGA_R),
			.VGA_G  	(VGA_G),
			.VGA_B 		(VGA_B),
			.VGA_HS 	(VGA_HS),
			.VGA_VS 	(VGA_VS),
			.VGA_BLANK 	(VGA_BLANK_N),
			.VGA_SYNC 	(VGA_SYNC_N),
			.VGA_CLK 	(VGA_CLK));
		defparam VGA.RESOLUTION 				= "320x240";
		defparam VGA.MONOCHROME 				= "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL 	= 2;
		defparam VGA.BACKGROUND_IMAGE 			= "resource/bmp1.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	
	wire init, idle, gen_move, check_collide;
	wire apply_act_link, move_enemies;
	wire draw_map, draw_link, draw_enemies;
	
	wire idle_done, check_collide_done, draw_map_done, draw_link_done, draw_enemies_done;

	control C(
		//inputs
		.clock 				(CLOCK_50),
		.reset 				(reset),
		
		.idle_done			(idle_done),
		//.gen_move_done		(gen_move_done),
		.check_collide_done	(check_collide_done),
		.draw_map_done		(draw_map_done),
		.draw_link_done 	(draw_link_done),
		.draw_enemies_done(draw_enemies_done),
		
		//outputs
		.states 				(LEDR),
		
		.init					(init),
		.idle 				(idle),
		.gen_move			(gen_move),
		.check_collide		(check_collide),
		.apply_act_link	(apply_act_link),
		.move_enemies		(move_enemies),
		.draw_map			(draw_map),
		.draw_link			(draw_link),
		.draw_enemies		(draw_enemies));
	
//	hexDecoder Hx1(
//		.bin(link_x_pos[7:4]),
//		.hout(HEX5));
//	
//	hexDecoder Hx2(
//		.bin(link_x_pos[3:0]),
//		.hout(HEX4));
//	
//	hexDecoder Hy1(
//		.bin(link_y_pos[7:4]),
//		.hout(HEX3));
//		
//	hexDecoder Hy2(
//		.bin(link_y_pos[3:0]),
//		.hout(HEX2));
	
	// hex_decoder h1(
	// 	.data(enemy_c),
	// 	.hex(HEX1));
		
	// hex_decoder h0(
	// 	.data(link_c),
	// 	.hex(HEX0));
		
	datapath D(
		//inputs
		.clock				(CLOCK_50),
		.reset				(reset),

		.c_attack			(c_attack),
		.c_up					(c_up),
		.c_down				(c_down),
		.c_left				(c_left),
		.c_right				(c_right),
		
		.init					(init),
		.idle					(idle),
		.gen_move			(gen_move),
		.check_collide		(check_collide),
		.apply_act_link	(apply_act_link),
		.move_enemies		(move_enemies),
		.draw_map			(draw_map),
		.draw_link			(draw_link),
		.draw_enemies		(draw_enemies),

		//outputs
		.x_position			(x),
		.y_position			(y),
		.colour 				(colour),
		.VGA_enable 		(writeEn),

		.idle_done			(idle_done),
		.check_collide_done(check_collide_done),
		.draw_map_done		(draw_map_done),
		.draw_link_done	(draw_link_done),
		.draw_enemies_done(draw_enemies_done));
		
		//remember to remove later
	//	.testRom				({enemy_c,link_c}));

endmodule

module hex_decoder(
	input [3:0] data,
	output reg [6:0] hex
	);
	
	always@(*)
	begin
		case(data)
			4'b0000: hex = 7'b1111111;
			4'b0001: hex = 7'b1101111;
			4'b0010: hex = 7'b1111011;
			4'b0011: hex = 7'b1101011;
			4'b0100: hex = 7'b1011111;
			4'b0101: hex = 7'b1001111;
			4'b0110: hex = 7'b1011011;
			4'b0111: hex = 7'b1001011;
			4'b1000: hex = 7'b1111101;
			4'b1001: hex = 7'b1101101;
			4'b1010: hex = 7'b1111001;
			4'b1011: hex = 7'b1101001;
			4'b1100: hex = 7'b1011101;
			4'b1101: hex = 7'b1001101;
			4'b1110: hex = 7'b1011001;
			4'b1111:	hex = 7'b1001001;
			default: hex = 7'b0000000;
		endcase
	end
endmodule

module hexDecoder(bin,hout);
	input [3:0]bin;
	output reg [6:0]hout;

	always@(*)
	begin
		case(bin)
			4'b0000: hout = 7'b1000000;
			4'b0001: hout = 7'b1111001;
			4'b0010: hout = 7'b0100100;
			4'b0011: hout = 7'b0110000;
			4'b0100: hout = 7'b0011001;
			4'b0101: hout = 7'b0010010;
			4'b0110: hout = 7'b0000010;
			4'b0111: hout = 7'b1111000;
			4'b1000: hout = 7'b0000000;
			4'b1001: hout = 7'b0010000;
			4'b1010: hout = 7'b0001000;
			4'b1011: hout = 7'b0000011;
			4'b1100: hout = 7'b1000110;
			4'b1101: hout = 7'b0100001;
			4'b1110: hout = 7'b0000110;
			4'b1111: hout = 7'b0001110;
			default: hout = 7'b1111111;
		endcase
	end

endmodule 