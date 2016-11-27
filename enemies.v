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
	output reg [8:0] enemy_1_x_pos,
	output reg [7:0] enemy_1_y_pos,

	output reg [8:0] enemy_2_x_pos,
	output reg [7:0] enemy_2_y_pos,

	output reg [8:0] enemy_3_x_pos,
	output reg [7:0] enemy_3_y_pos,

	output reg [8:0] x_draw,
	output reg [7:0] y_draw,

	//enemy direction data for collision_detector
	output reg [2:0] enemy_1_direction,
	output reg [2:0] enemy_1_facing,

	output reg [2:0] enemy_2_direction,
	output reg [2:0] enemy_2_facing,

	output reg [2:0] enemy_3_direction,
	output reg [2:0] enemy_3_facing,

	//memory output data for VGA
	output [5:0] colour,

	//output write enable to VGA
	output VGA_write,

	//output finished signals
	output reg draw_done,
	);

	/** local parameters **/
	parameter		ON 			= 1'b1,
					OFF		 	= 1'b0,

	/** ram for enemy character sprites which includes 8 enemy walking sprites **/
	enemy_sprite_mem enemy_sprite(
		.address	(address),
		.clock		(clock),
		.q			(colour));

	/** wires and registers **/
	//draw enable signals for each enemy module
	reg draw_1, draw_2, draw_3;

	//wires for each enemies
	reg [8:0] enemy_1_x_draw;
	reg [7:0] enemy_1_y_draw;
	wire colour_1;
	wire VGA_write_1;
	wire draw_done_1;

	reg [8:0] enemy_2_x_draw;
	reg [7:0] enemy_2_y_draw;
	wire colour_2;
	wire VGA_write_2;
	wire draw_done_2;

	reg [8:0] enemy_3_x_draw;
	reg [7:0] enemy_3_y_draw;
	wire colour_3;
	wire VGA_write_3;
	wire draw_down_3;

	/** enemy modules **/
	//enemy 1
	single_enemy enemy_1(
		.clock		(clock),
		.reset		(reset),
		
		.init				(init),
		.idle				(idle),
		.gen_move			(gen_move),
		.apply_move			(apply_move),
		.draw				(draw),

		.collision			(collision[0]),

		.link_x_pos			(link_x_pos),
		.link_y_pos			(link_x_pos),

		.x_pos				(enemy_1_x_pos),
		.y_pos				(enemy_1_y_pos),
		.x_draw				(enemy_1_x_draw),
		.y_draw				(enemy_1_y_draw),

		.direction			(enemy_1_direction),
		.facing				(enemy_1_facing),

		.colour				(colour_1),

		.VGA_write			(VGA_write_1),

		.draw_done			(draw_done_1));

	//enemy 2
	single_enemy enemy_2(
		.clock		(clock),
		.reset		(reset),
		
		.init				(init),
		.idle				(idle),
		.gen_move			(gen_move),
		.apply_move			(apply_move),
		.draw				(draw),

		.collision			(collision[1]),

		.link_x_pos			(link_x_pos),
		.link_y_pos			(link_x_pos),

		.x_pos				(enemy_2_x_pos),
		.y_pos				(enemy_2_y_pos),
		.x_draw				(enemy_2_x_draw),
		.y_draw				(enemy_2_y_draw),

		.direction			(enemy_2_direction),
		.facing				(enemy_2_facing),

		.colour				(colour_2),

		.VGA_write			(VGA_write_2),

		.draw_done			(draw_done_2));

	//enemy 3
	single_enemy enemy_3(
		.clock		(clock),
		.reset		(reset),
		
		.init				(init),
		.idle				(idle),
		.gen_move			(gen_move),
		.apply_move			(apply_move),
		.draw				(draw),

		.collision			(collision[2]),

		.link_x_pos			(link_x_pos),
		.link_y_pos			(link_x_pos),

		.x_pos				(enemy_3_x_pos),
		.y_pos				(enemy_3_y_pos),
		.x_draw				(enemy_3_x_draw),
		.y_draw				(enemy_3_y_draw),

		.direction			(enemy_3_direction),
		.facing				(enemy_3_facing),

		.colour				(colour_3),

		.VGA_write			(VGA_write_3),

		.draw_done			(draw_done_3));

	/** combinational logic **/
	always@(*)
	begin
		else if(draw)
		begin
			//start drawing enemy 1 when draw signal is on
			draw_1 = ON;
			//connect colour and VGA_write to enemy 1 while drawing
			if(!draw_done_1)
			begin
				x_draw = enemy_1_x_draw;
				y_draw = enemy_1_y_draw;
				colour = colour_1;
				VGA_write = VGA_write_1;
			end

			//after enemy 1 is done start drawing draw enemy 2
			if(draw_1_done)
				draw_2 = ON;
				//connect colour and VGA_write to enemy 2 while drawing
				if(!draw_done_2)
				begin
					x_draw = enemy_1_x_draw;
					y_draw = enemy_1_y_draw;
					colour = colour_2;
					VGA_write = VGA_write_2;
				end

			//after enemy 2 is done start drawing draw enemy 3
			if(draw_2_done)
				draw_3 = ON;
				//connect colour and VGA_write to enemy 3 while drawing
				if(!draw_done_3)
				begin
					x_draw = enemy_1_x_draw;
					y_draw = enemy_1_y_draw;
					colour = colour_3;
					VGA_write = VGA_write_3;
				end

			//done drawing all, set draw_done to on
			if(draw_3_done)
				draw_done = ON;
		end

		else
			draw_done = OFF;
	end


endmodule