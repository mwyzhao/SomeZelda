module enemies(
	input clock,
	input reset,

	//state signals from control
	input init,
	input idle,
	input gen_move,
	input apply_move,
	input draw,

	//3 bit wire carrying collision information
	input collision,

	//link position for tracking movement
	input link_x_pos,
	input link_y_pos,

	//enemy position for collision_detector and vga
	output reg [8:0] enemy1_x_pos,
	output reg [7:0] enemy1_y_pos,
	output reg [8:0] enemy1_x_draw,
	output reg [7:0] enemy1_y_draw,
	output reg [8:0] enemy2_x_pos,
	output reg [7:0] enemy2_y_pos,
	output reg [8:0] enemy2_x_draw,
	output reg [7:0] enemy2_y_draw,
	output reg [8:0] enemy3_x_pos,
	output reg [7:0] enemy3_y_pos,
	output reg [8:0] enemy3_x_draw,
	output reg [7:0] enemy3_y_draw,

	//enemy direction data for collision_detector
	output reg [2:0] enemy1_direction,
	output reg [2:0] enemy1_facing,
	output reg [2:0] enemy2_direction,
	output reg [2:0] enemy2_facing,
	output reg [2:0] enemy3_direction,
	output reg [2:0] enemy3_facing,

	//memory output data for VGA
	output [5:0] colour,

	//output write enable to VGA
	output VGA_write,

	//output finished signals
	output reg draw_done,
	);


endmodule