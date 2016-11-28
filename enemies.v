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
	input [2:0] collision,
	input [2:0] hit,
	//link position for tracking movement
	input	[8:0] link_x_pos,
	input [7:0] link_y_pos,
	
	output reg gen_move_done,

	//enemy position for collision_detector and vga
	output [8:0] enemy_1_x_pos,
	output [7:0] enemy_1_y_pos,

	output [8:0] enemy_2_x_pos,
	output [7:0] enemy_2_y_pos,

	output [8:0] enemy_3_x_pos,
	output [7:0] enemy_3_y_pos,

	output reg [8:0] x_draw,
	output reg [7:0] y_draw,

	//enemy direction data for collision_detector
	output [2:0] enemy_1_direction,
	output [2:0] enemy_2_direction,
	output [2:0] enemy_3_direction,
	
	output [11:0] score,
	
	//memory output data for VGA
	output reg [5:0] colour,

	//output write enable to VGA
	output reg VGA_write,

	//output finished signals
	output reg draw_done
	);

	/** local parameters **/
	parameter	ON 			= 1'b1,
					OFF		 	= 1'b0;

	/** wires and registers **/
	//gen move enable signals for each enemy module
	reg gen_move_1, gen_move_2, gen_move_3;
	
	//draw enable signals for each enemy module
	reg draw_1, draw_2, draw_3;
	
	reg [9:0] draw_count;

	//wires for each enemies
	wire [8:0] enemy_1_x_draw;
	wire [7:0] enemy_1_y_draw;
	wire [5:0] colour_1;
	wire VGA_write_1;
	wire draw_done_1;

	wire [8:0] enemy_2_x_draw;
	wire [7:0] enemy_2_y_draw;
	wire [5:0] colour_2;
	wire VGA_write_2;
	wire draw_done_2;

	wire [8:0] enemy_3_x_draw;
	wire [7:0] enemy_3_y_draw;
	wire [5:0] colour_3;
	wire VGA_write_3;
	wire draw_done_3;
	
	wire [11:0] score_1,score_2,score_3;
	
	assign score = score_1 + score_2 + score_3;

	/** enemy modules **/
	//enemy 1
	single_enemy enemy_1(
		.clock	(clock),
		.reset	(reset),
		
		.init					(init),
		.idle					(idle),
		.gen_move			(gen_move),
		.apply_move			(apply_move),
		.draw					(draw_1),

		.collision			(collision[0]),

		.link_x_pos			(link_x_pos),
		.link_y_pos			(link_y_pos),

		.x_pos				(enemy_1_x_pos),
		.y_pos				(enemy_1_y_pos),
		.x_draw				(enemy_1_x_draw),
		.y_draw				(enemy_1_y_draw),

		.direction			(enemy_1_direction),

		.colour				(colour_1),
		
		.score				(score_1),

		.VGA_write			(VGA_write_1),

		.draw_done			(draw_done_1),
		.hit				(hit[0]));
	//using default x, y values

	//enemy 2
	single_enemy enemy_2(
		.clock	(clock),
		.reset	(reset),
		
		.init					(init),
		.idle					(idle),
		.gen_move			(gen_move),
		.apply_move			(apply_move),
		.draw					(draw_2),

		.collision			(collision[1]),

		.link_x_pos			(link_x_pos),
		.link_y_pos			(link_y_pos),

		.x_pos				(enemy_2_x_pos),
		.y_pos				(enemy_2_y_pos),
		.x_draw				(enemy_2_x_draw),
		.y_draw				(enemy_2_y_draw),

		.direction			(enemy_2_direction),

		.colour				(colour_2),
		
		.score				(score_2),

		.VGA_write			(VGA_write_2),

		.draw_done			(draw_done_2),
		.hit				(hit[1]));
	//using default x position
	defparam enemy_2.Y_INITIAL = 8'd63,
				enemy_2.SEED0 = 9'b010100100,
				enemy_2.SEED2 = 9'b101101100;

	//enemy 3
	single_enemy enemy_3(
		.clock	(clock),
		.reset	(reset),
		
		.init					(init),
		.idle					(idle),
		.gen_move			(gen_move),
		.apply_move			(apply_move),
		.draw					(draw_3),

		.collision			(collision[2]),

		.link_x_pos			(link_x_pos),
		.link_y_pos			(link_y_pos),

		.x_pos				(enemy_3_x_pos),
		.y_pos				(enemy_3_y_pos),
		.x_draw				(enemy_3_x_draw),
		.y_draw				(enemy_3_y_draw),

		.direction			(enemy_3_direction),

		.colour				(colour_3),
		
		.score				(score_3),

		.VGA_write			(VGA_write_3),

		.draw_done			(draw_done_3),
		.hit				(hit[2]));
	defparam enemy_3.X_INITIAL = 8'd111,
				enemy_3.Y_INITIAL = 8'd143,
				enemy_3.SEED1 = 9'b010101011,
				enemy_3.SEED3 = 9'b010010101;

	/** sequential logic **/
	always@(posedge clock)
	begin
		if(reset)
		begin
			draw_count <= 10'b0;
			draw_1 <= OFF;
			draw_2 <= OFF;
			draw_3 <= OFF;
			x_draw = 9'b0;
			y_draw = 8'b0;
			colour = 6'b0;
			VGA_write = OFF;
		end
		
		else if(init)
		begin
			draw_count <= 10'b0;
			draw_1 <= OFF;
			draw_2 <= OFF;
			draw_3 <= OFF;
			x_draw = 9'b0;
			y_draw = 8'b0;
			colour = 6'b0;
			VGA_write = OFF;
		end
		
		if(draw)
		begin
			if(draw_count < 10'd256)
			begin
				draw_count <= draw_count + 1'b1;
				draw_1 <= ON;
				draw_2 <= OFF;
				draw_3 <= OFF;
				x_draw = enemy_1_x_draw;
				y_draw = enemy_1_y_draw;
				colour = colour_1;
				VGA_write = VGA_write_1;
			end
			
			else if(draw_count < 10'd513)
			begin
				draw_count <= draw_count + 1'b1;
				draw_1 <= OFF;
				draw_2 <= ON;
				draw_3 <= OFF;
				x_draw = enemy_2_x_draw;
				y_draw = enemy_2_y_draw;
				colour = colour_2;
				VGA_write = VGA_write_2;
			end
			
			else if(draw_count < 10'd770)
			begin
				draw_count <= draw_count + 1'b1;
				draw_1 <= OFF;
				draw_2 <= OFF;
				draw_3 <= ON;
				x_draw = enemy_3_x_draw;
				y_draw = enemy_3_y_draw;
				colour = colour_3;
				VGA_write = VGA_write_3;
			end
			
			else
			begin
				draw_done <= ON;
				draw_count <= 10'b0;
				draw_1 <= OFF;
				draw_2 <= OFF;
				draw_3 <= OFF;
				x_draw = 9'b0;
				y_draw = 8'b0;
				colour = 6'b0;
				VGA_write = OFF;
			end
		end
		
		else
			draw_done <= OFF;
	end

endmodule