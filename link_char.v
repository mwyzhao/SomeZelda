/*** implementation of character movement logic based on user inputs ***/

module link_char(
	input clock,
	input reset,

	//user commands from KEY,SW
	input 				c_attack,
	input 				c_up,
	input 				c_down,
	input 				c_left,
	input 				c_right,

	//state signals from control
	input 				init,
	input 				idle,
	input 				reg_action,
	input 				apply_action,
	input 				draw_char,

	//collision signal from collision_detector
	input 		[1:0] collision,

	//link position for collision_detector and vga
	output reg 	[8:0] link_x_pos,
	output reg 	[7:0] link_y_pos,
	output reg 	[8:0] link_x_draw,
	output reg 	[7:0] link_y_draw,

	//link direction data for collision_detector
	output reg 	[2:0] link_direction,
	output reg 	[2:0] link_facing,

	//memory output data for vga
	output 	 	[5:0] colour,

	//output finished signals
	output reg 			draw_done,

	//output write enable to VGA
	output  			VGA_write
	);

	/** local parameters **/
	localparam 	NO_ACTION 	= 3'b000,
					ATTACK 		= 3'b001,
					UP 			= 3'b010,
					DOWN 			= 3'b011,
					LEFT 			= 3'b100,
					RIGHT 		= 3'b101,

					ON				= 1'b1,
					OFF			= 1'b0,

					MAX_COUNT	= 8'd255;

	/** ram for link character sprites which includes
		8 link walking sprites and 8 link attacking sprites **/

	link_sprite_mem m0(
		.address({spriteAddressY,spriteAddressX}),
		.clock(clock),
		.q(colour));

	/** registers and wires **/
	reg [5:0] spriteAddressX;
	reg [3:0] spriteAddressY;
	reg [5:0] intAddressX;
	reg [3:0] intAddressY;

	/** position registers for player character link **/
	//counter for when link is finished drawing
	reg 	[7:0] count;

	assign VGA_write = (draw_char) && (colour != 6'b111111);

	//sequential logic
	always@(posedge clock)
	begin
		if(reset)
		begin
			//reset block, resets all registers to 0;
			link_x_draw <= 9'b0;
			link_y_draw <= 8'b0;
			link_x_pos 	<= 9'b0;
			link_y_pos 	<= 8'd96;
			count 	 	<= 6'b0;
			link_facing <= DOWN;
			link_direction <= NO_ACTION;
			draw_done 	<= OFF;
		end
		else if(init)
		begin
			//initialize first time character appears on map
			link_x_draw <= 8'b0;
			link_y_draw <= 8'b0;
			link_x_pos	<= 9'b0;
			link_y_pos	<= 8'd96;
			count  		<= 6'b0;
			link_facing <= DOWN;
			link_direction <= NO_ACTION;
			draw_done 	<= OFF;
		end
		
		else if(reg_action)
		begin
			if(c_attack)
				link_direction <= ATTACK;
			else if(c_up)
				link_direction <= UP;
			else if(c_down)
				link_direction <= DOWN;
			else if(c_left)
				link_direction <= LEFT;
			else if(c_right)
				link_direction <= RIGHT;
			else
				link_direction <= NO_ACTION;
		end

		else if(apply_action)
		begin
			/*
			else if(link_direction == ATTACK)
			begin
				//pull from attack sprites
			end
			*/
			if(link_direction == UP)
			begin
				//pull from move up sprites
				if(!collision[0])
				begin
					link_y_pos 	<= link_y_pos - 1'b1;
				end
				link_facing <= UP;
				intAddressX <= 32;
				intAddressY <= 0;
			end
			else if(link_direction == DOWN)
			begin
				//pull from move down sprites
				if(!collision[0])
				begin
					link_y_pos 	<= link_y_pos + 1'b1;
				end
				link_facing	<= DOWN;
				intAddressX <= 0;
				intAddressY <= 0;
			end
			else if(link_direction == LEFT)
			begin
				//pull from move left sprites
				if(!collision[0])
				begin
					link_x_pos	<= link_x_pos - 1'b1;
				end
				link_facing <= LEFT;
				intAddressX <= 16;
				intAddressY <= 0;
			end
			else if(link_direction == RIGHT)
			begin
				//pull from move right sprites
				if(!collision[0])
				begin
					link_x_pos	<= link_x_pos + 1'b1;
				end
				link_facing <= RIGHT;
				intAddressX <= 48;
				intAddressY <= 0;
			end
		end

		else if(draw_char)
		begin
			//do not need to implement erase if redrawing entire map
			//set write enable to on
			spriteAddressX <= intAddressX + count[3:0];
			spriteAddressY <= intAddressY + count[7:4];
			//increment x and y positions
			link_x_draw <= link_x_pos + count[3:0];
			link_y_draw <= link_y_pos + count[7:4];
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
			draw_done <= OFF;
		end
	end

endmodule
