/*** implementation of enemy movement logic ***/

/* not gonna worry about this for now */
/* shouldn't need to implement this until collision is done */

module single_enemy(
	input clock,
	input reset,

	//state signals from control
	input 		init,
	input 		idle,
	input 		gen_move,
	input 		apply_move,
	input 		draw,
	input  		hit,
	//collision signal from collision_detector
	input 	  	collision,

	//link position for tracking movement
	input 		[8:0] link_x_pos,
	input			[7:0] link_y_pos,

	//enemy position for collision_detector and vga
	output reg 	[8:0] x_pos,
	output reg 	[7:0] y_pos,
	output reg 	[8:0] x_draw,
	output reg 	[7:0] y_draw,

	//enemy direction data for collision_detector
	output reg 	[2:0] direction,

	//memory output data for VGA
	output 		[5:0] colour,

	//output write enable to VGA
	output  		VGA_write,

	//output finished signals
	output reg 	draw_done
	);

	/** local parameters **/
	parameter 	X_INITIAL	= 8'd207,
					Y_INITIAL	= 8'd95,
					NO_ACTION 	= 3'b000,
					ATTACK 		= 3'b001,
					UP 			= 3'b010,
					DOWN 			= 3'b011,
					LEFT 			= 3'b100,
					RIGHT 		= 3'b101,

					ON 			= 1'b1,
					OFF		 	= 1'b0,

					MAX_COUNT 	= 8'd255,
	
					SEED0 = 9'b010010110,
					SEED1 = 9'b001000001,
					SEED2 = 9'b000010110,
					SEED3 = 9'b010111001;				
	/* NOTE: MUST DEFINE CUSTOM INITIAL POSITION USING DEFPARAM 
	 * Default value x = 207, y = 95
	 */

	/** ram for enemy character sprites which includes 8 enemy walking sprites **/
	enemy_sprite_mem enemy_sprite(
		.address	({spriteAddressY,spriteAddressX}),
		.clock	(clock),
		.q			(colour));
	
	/** random number generator for movement **/
	random_number_generator enemy_move(
		.clock(clock),
		.reset(reset),
		.init(init),
		.seed0(SEED0),
		.seed1(SEED1),
		.seed2(SEED2),
		.seed3(SEED3),
		.out(move_interrupt));
	/* include defparam here in case you want to change internal seed value
	 * defparam SEED0 = 8'b1001010;
	 * defparam SEED1 = 8'b0100101;
	 * two examples of defparam above, available parameters: SEED0 - SEED3
	 */

	wire [3:0] move_interrupt;

	reg [5:0] spriteAddressX;
	reg [3:0] spriteAddressY;
	reg [5:0] intAddress;
	/** position registers for enemies**/

	//counter for when enemy is finished drawing
	reg 	[7:0] count;

	//counter for gridlocking enemy to 16 pixel wide movements
	reg	[3:0] move_count;
	
	//counter for lowering movement speed
	reg 	[3:0] apply_count;

	//enemy status register
	reg	ded;

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
			x_pos			<= X_INITIAL;
			y_pos			<= Y_INITIAL;
			count			<= 6'b0;
			move_count	<= 4'b0;
			apply_count	<= 4'b0;
			draw_done	<= OFF;
		end
		else if(init)
		begin
			//initialize first time character appears on map
			x_draw		<= 8'b0;
			y_draw		<= 8'b0;
			x_pos			<= X_INITIAL;
			y_pos			<= Y_INITIAL;
			count			<= 6'b0;
			move_count	<= 4'b0;
			apply_count	<= 4'b0;
			draw_done	<= OFF;
		end
		else if (hit)
		begin
			x_draw		<= 9'b0;
			y_draw		<= 8'b0;
			x_pos			<= X_INITIAL;
			y_pos			<= Y_INITIAL;
			count			<= 6'b0;
			move_count	<= 4'b0;
			apply_count	<= 4'b0;
			draw_done	<= OFF;
		end
		
		//will take in new move every 16 cycles
		//move_count can be incremented in any state that runs every cycle
		//will incrememnt move_count in apply_move
		else if(gen_move && (move_count == 4'b0000))
		begin
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
					direction <= UP;
				else if(link_x_pos > x_pos)
					direction <= RIGHT;
				else if(link_y_pos > y_pos)
					direction <= DOWN;
				else if(link_x_pos < x_pos)
					direction <= LEFT;
			end
		end

		else if(apply_move)
		begin
			//increment apply and only apply move every 16 cycles
			apply_count	<= apply_count + 1'b1;
			
			if(apply_count == 4'b0000)
			begin
				//increment direction change every 16 moves
				move_count <= move_count + 1'b1;
				
				//check directions
				if(direction == UP)
				begin
					//pull from move up sprites
					if(!collision)
					begin
						y_pos 	<= y_pos - 1'b1;
					end
					intAddress	<= 6'd32;
				end
				else if(direction == DOWN)
				begin
					//pull from move down sprites
					if(!collision)
					begin
						y_pos		<= y_pos + 1'b1;
					end
					intAddress	<= 6'd0;
				end
				else if(direction == LEFT)
				begin
					//pull from move left sprites
					if(!collision)
					begin
						x_pos		<= x_pos - 1'b1;
					end
					intAddress	<= 6'd16;
				end
				else if(direction == RIGHT)
				begin
					//pull from move right sprites
					if(!collision)
					begin
						x_pos		<= x_pos + 1'b1;
					end
					intAddress	<= 6'd48;
				end
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
			count <= count + 1'b1;

			//once counter reaches max, drawing done
			if(count == MAX_COUNT)
			begin
				//set write enable to off and reset counter
				count <= 8'b0;

				//send out draw done signal to move to next state
				draw_done <= ON;
			end
		end
		else
		begin
			draw_done <= OFF;
		end
	end

endmodule