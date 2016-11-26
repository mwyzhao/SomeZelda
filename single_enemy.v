/*** implementation of enemy movement logic ***/

/* not gonna worry about this for now */
/* shouldn't need to implement this until collision is done */

module enemy(
	input clock,
	input reset,

	//state signals from control
	input 			init,
	input 			idle,
	input 			gen_move,
	input 			apply_move,
	input 			draw,

	//collision signal from collision_detector
	input 	  		collision,

	//link position for tracking movement
	input 			link_x_pos,
	input			link_y_pos,

	//enemy position for collision_detector and vga
	output reg 	[8:0] x_pos,
	output reg 	[7:0] y_pos,
	output reg 	[8:0] x_draw,
	output reg 	[7:0] y_draw,

	//enemy direction data for collision_detector
	output reg 	[2:0] direction,
	output reg 	[2:0] facing,

	//memory output data for VGA
	output 	 	[5:0] colour,

	//output write enable to VGA
	output  				VGA_write

	//output finished signals
	output reg 			draw_done,
	);

	/** local parameters **/
	parameter 	NO_ACTION 	= 3'b000,
					ATTACK 		= 3'b001,
					UP 			= 3'b010,
					DOWN 			= 3'b011,
					LEFT 			= 3'b100,
					RIGHT 		= 3'b101,

					ON 			= 1'b1,
					OFF		 	= 1'b0,

					MAX_COUNT 	= 8'd255;

	/** sprite memory moved to wrapper module enemies.v **/
	
	/** random number generator for movement **/
	random_number_generator enemy_move(
		.clock(clock),
		.reset(reset),
		.init(init),
		.out(move_interrupt));
	/* include defparam here in case you want to change internal seed value
	 * defparam SEED0 = 8'b1001010;
	 * defparam SEED1 = 8'b0100101;
	 * two examples of defparam above, available parameters: SEED0 - SEED3
	 */

	wire [3:0] movement_interrupt;

	reg [5:0] spriteAddressX;
	reg [3:0] spriteAddressY;
	reg [5:0] intAddress;
	/** position registers for enemies**/

	//counter for when link is finished drawing
	reg 	[7:0] count;

	//do not draw white sprite background colours
	assign VGA_write = (draw) && (colour != 6'b111111);

	//sequential logic
	always@(posedge clock)
	begin
		if(reset)
		begin
			//reset block, resets all registers to 0;
			x_draw		<= 9'b0;
			y_draw		<= 8'b0;
			x_pos		<= 9'd210;
			y_pos		<= 8'd96;
			count				<= 6'b0;
			facing		<= DOWN;
			draw_done		<= OFF;
		end
		else if(init)
		begin
			//initialize first time character appears on map
			x_draw		<= 8'b0;
			y_draw		<= 8'b0;
			x_pos		<= 9'd210;
			y_pos		<= 8'd96;
			count				<= 6'b0;
			facing		<= DOWN;
			draw_done		<= OFF;
		end
		
		else if(gen_move)
		begin
			/* will add more sophisticated enemies later */
			//this is for some added unpredictability in enemy movements
			//only triggers when random numbers match 11, EV 1/8
			if(move_interrupt[1:0] == 2'b11)
			begin
				if(move_interrupt[3:2] == 2'b00)
					direction <= UP;
				if(move_interrupt[3:2] == 2'b01)
					direction <= DOWN;
				if(move_interrupt[3:2] == 2'b10)
					direction <= LEFT;
				if(move_interrupt[3:2] == 2'b11)
					direction <= RIGHT;
			end
			//planning to add more so track user position, for now move left
			else
			begin
				if(link_y_pos < y_pos)
					direction	<= UP;
				else if(link_y_pos > y_pos)
					direction <= DOWN;
				else if(link_x_pos < x_pos)
					direction <= LEFT;
				else if(link_x_pos > x_pos)
					direction <= RIGHT;
			end
		end

		else if(apply_move)
		begin
			if(direction == UP)
			begin
				//pull from move up sprites
				if(!collision)
				begin
					y_pos <= y_pos - 1'b1;
				end
				facing	<= UP;
				intAddress		<= 6'd32;
			end
			else if(direction == DOWN)
			begin
				//pull from move down sprites
				if(!collision)
				begin
					y_pos	<= y_pos + 1'b1;
				end
				facing	<= DOWN;
				intAddress		<= 6'd0;
			end
			else if(direction == LEFT)
			begin
				//pull from move left sprites
				if(!collision)
				begin
					x_pos	<= x_pos - 1'b1;
				end
				facing	<= LEFT;
				intAddress		<= 6'd16;
			end
			else if(direction == RIGHT)
			begin
				//pull from move right sprites
				if(!collision)
				begin
					x_pos	<= x_pos + 1'b1;
				end
				facing 	<= RIGHT;
				intAddress	 	<= 6'd48;
			end
		end

		else if(draw)
		begin
			spriteAddressX <= intAddress + count[3:0];
			spriteAddressY <= count[7:4];
			//increment x and y positions
			x_draw <= x_pos + count[3:0];
			y_draw <= y_pos + count[7:4];
			//increment counter
			count 		<= count + 1'b1;

			//once counter reaches max, drawing done
			if(count == MAX_COUNT)
			begin
				//set write enable to off and reset counter
				count 		<= 8'b0;

				//send out draw done signal to move to next state
				draw_done 	<= ON;
			end
		end
		else
		begin
			draw_done <=OFF;
		end
	end

endmodule
