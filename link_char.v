/*** implementation of character movement logic based on user inputs ***/

module link_char(
	input clock,
	input reset,

	//user commands from KEY,SW
	input 			c_attack,
	input 			c_up,
	input 			c_down,
	input 			c_left,
	input 			c_right,

	//state signals from control
	input 			init,
	input 			idle,
	input 			reg_action,
	input 			apply_action,
	input 			draw,

	//collision signal from collision_detector
	input 		[1:0] collision,

	//link position for collision_detector and vga
	output reg 	[8:0] x_pos,
	output reg 	[7:0] y_pos,
	output reg 	[8:0] x_draw,
	output reg 	[7:0] y_draw,

	//link direction data for collision_detector
	output reg 	[2:0] direction,
	output reg 	[2:0] facing,

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
	reg [5:0] intAddress;

	/** position registers for player character link **/
	//counter for when link is finished drawing
	reg 	[7:0] count;

	assign VGA_write = (draw) && (colour != 6'b111111);

	//sequential logic
	always@(posedge clock)
	begin
		if(reset)
		begin
			//reset block, resets all registers to 0;
			x_draw <= 9'b0;
			y_draw <= 8'b0;
			x_pos 	<= 9'd1;
			y_pos 	<= 8'd96;
			count 	 	<= 6'b0;
			facing <= DOWN;
			direction <= NO_ACTION;
			draw_done 	<= OFF;
		end
		else if(init)
		begin
			//initialize first time character appears on map
			x_draw <= 8'b0;
			y_draw <= 8'b0;
			x_pos	<= 9'd1;
			y_pos	<= 8'd96;
			count  		<= 6'b0;
			facing <= DOWN;
			direction <= NO_ACTION;
			draw_done 	<= OFF;
		end
		
		else if(reg_action)
		begin
			if(c_attack)
				direction <= ATTACK;
			else if(c_up)
				direction <= UP;
			else if(c_down)
				direction <= DOWN;
			else if(c_left)
				direction <= LEFT;
			else if(c_right)
				direction <= RIGHT;
			else
				direction <= NO_ACTION;
		end

		else if(apply_action)
		begin
			/*
			else if(direction == ATTACK)
			begin
				//pull from attack sprites
			end
			*/
			if(direction == UP)
			begin
				//pull from move up sprites
				if(!collision[0])
				begin
					y_pos 	<= y_pos - 1'b1;
				end
				facing <= UP;
				intAddress <= 32;
			end
			else if(direction == DOWN)
			begin
				//pull from move down sprites
				if(!collision[0])
				begin
					y_pos 	<= y_pos + 1'b1;
				end
				facing	<= DOWN;
				intAddress <= 0;
			end
			else if(direction == LEFT)
			begin
				//pull from move left sprites
				if(!collision[0])
				begin
					x_pos	<= x_pos - 1'b1;
				end
				facing <= LEFT;
				intAddress <= 16;
			end
			else if(direction == RIGHT)
			begin
				//pull from move right sprites
				if(!collision[0])
				begin
					x_pos	<= x_pos + 1'b1;
				end
				facing <= RIGHT;
				intAddress <= 48;
			end
		end

		else if(draw
)
		begin
			//do not need to implement erase if redrawing entire map
			//set write enable to on
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
			draw_done <= OFF;
		end
	end

endmodule
