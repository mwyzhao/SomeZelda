/*** implementation of enemy movement logic ***/

/* not gonna worry about this for now */
/* shouldn't need to implement this until collision is done */

module enemy(
	input clock,
	input reset,

	//state signals from control
	input 				init,
	input 				idle,
	input 				gen_move,
	input 				move_enemies,
	input 				draw_enemies,

	//collision signal from collision_detector
	input 		  		collision,

	//enemy position for collision_detector and vga
	output reg 	[8:0] enemy_x_pos,
	output reg 	[7:0] enemy_y_pos,
	output reg 	[8:0] enemy_x_draw,
	output reg 	[7:0] enemy_y_draw,

	//enemy direction data for collision_detector
	output reg 	[2:0] enemy_direction,
	output reg 	[2:0] enemy_facing,

	//memory output data for vga
	output 	 	[5:0] colour,

	//output finished signals
	output reg 			draw_done,
	//output write enable to VGA (do we need this?)
	output  				VGA_write
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

	/** ram for enemy character sprites which includes 8 enemy walking sprites **/

	enemy_sprite_mem m0(
		.address({spriteAddressY,spriteAddressX}),
		.clock(clock),
		.q(colour));
	/** random number generator for movement **/

	random_number_generator enemy_move(
		.clock(clock),
		.reset(reset),
		.init(init),
		.out(movement_interrupt));
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

	assign VGA_write = (draw_enemies) && (colour != 6'b111111);

	//sequential logic
	always@(posedge clock)
	begin
		if(reset)
		begin
			//reset block, resets all registers to 0;
			enemy_x_draw	<= 9'b0;
			enemy_y_draw	<= 8'b0;
			enemy_x_pos		<= 9'd210;
			enemy_y_pos		<= 8'd96;
			count				<= 6'b0;
			enemy_facing	<= DOWN;
			draw_done		<= OFF;
		end
		else if(init)
		begin
			//initialize first time character appears on map
			enemy_x_draw	<= 8'b0;
			enemy_y_draw	<= 8'b0;
			enemy_x_pos		<= 9'd210;
			enemy_y_pos		<= 8'd96;
			count				<= 6'b0;
			enemy_facing	<= DOWN;
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
					enemy_direction <= UP;
				if(move_interrupt[3:2] == 2'b01)
					enemy_direction <= DOWN;
				if(move_interrupt[3:2] == 2'b10)
					enemy_direction <= LEFT;
				if(move_interrupt[3:2] == 2'b11)
					enemy_direction <= RIGHT;
			end
			//planning to add more so track user position, for now move left
			else
			begin
				if(link_y_pos < enemy_y_pos)
					enemy_direction	<= UP;
				else if(link_y_pos > enemy_y_pos)
					enemy_direction <= DOWN;
				else if(link_x_pos < enemy_y_pos)
					enemy_direction <= LEFT;
				else if(link_x_pos > enemy_y_pos)
					enemy_direction <= RIGHT;
			end
		end

		else if(move_enemies)
		begin
			if(enemy_direction == UP)
			begin
				//pull from move up sprites
				if(!collision)
				begin
					enemy_y_pos <= enemy_y_pos - 1'b1;
				end
				enemy_facing	<= UP;
				intAddress		<= 6'd32;
			end
			else if(enemy_direction == DOWN)
			begin
				//pull from move down sprites
				if(!collision)
				begin
					enemy_y_pos	<= enemy_y_pos + 1'b1;
				end
				enemy_facing	<= DOWN;
				intAddress		<= 6'd0;
			end
			else if(enemy_direction == LEFT)
			begin
				//pull from move left sprites
				if(!collision)
				begin
					enemy_x_pos	<= enemy_x_pos - 1'b1;
				end
				enemy_facing	<= LEFT;
				intAddress		<= 6'd16;
			end
			else if(enemy_direction == RIGHT)
			begin
				//pull from move right sprites
				if(!collision)
				begin
					enemy_x_pos	<= enemy_x_pos + 1'b1;
				end
				enemy_facing 	<= RIGHT;
				intAddress	 	<= 6'd48;
			end
		end

		else if(draw_enemies)
		begin
			spriteAddressX <= intAddress + count[3:0];
			spriteAddressY <= count[7:4];
			//increment x and y positions
			enemy_x_draw <= enemy_x_pos + count[3:0];
			enemy_y_draw <= enemy_y_pos + count[7:4];
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
