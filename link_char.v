/*** implementation of character movement logic based on user inputs ***/

module link_char(
	input clock,
	input reset,
	//state signals from control
	input 				init,
	input 				idle,
	input 				apply_action,
	input 				draw_char,

	input 		  [2:0] user_input,

	input 		  [1:0] collision,

	output reg 	  [8:0] link_x_pos,
	output reg 	  [7:0] link_y_pos,
	output reg 	  [8:0] link_x_draw,
	output reg 	  [7:0] link_y_draw,

	output reg 	  [1:0] link_facing,

	output 	 	  [5:0] cout,

	//output finished signals
	output reg 			draw_done,

	//output write enable to VGA (do we need this?)
	output  			VGA_write
	);
	/** local parameters **/
	localparam 		NO_ACTION 	= 3'b000;
					ATTACK 		= 3'b001;
					UP 			= 3'b010;
					DOWN 		= 3'b011;
					LEFT 		= 3'b100;
					RIGHT 		= 3'b101;

					F_UP 	= 2'b00,
					F_DOWN 	= 2'b01,
					F_LEFT 	= 2'b10,
					F_RIGHT = 2'b11,

					ON 		= 1'b1,
					OFF 	= 1'b0,

					MAX_COUNT = 8'b11111111;

	/** ram for link character sprites which includes
		8 link walking sprites and 8 link attacking sprites **/

	link_sprite_mem m0(
		.address({spriteAddressY,spriteAddressX}),
		.clock(clock),
		.q(cout));
	defparam m0.altsyncram_component.init_file = "resources/sprite.mif",
	reg [5:0] spriteAddressX;
	reg [3:0] spriteAddressY;
	reg [5:0] intAddressX;
	reg [3:0] intAddressY;

	/** position registers for player character link **/
	//counter for when link is finished drawing
	reg 	[7:0] count;

	assign VGA_write = (draw_char)&&(cout!=6'b111111);

	//sequential logic
	always@(posedge clock)
	begin
		if(reset)
		begin
			//reset block, resets all registers to 0;
			link_x_draw <= 8'b0;
			link_y_draw <= 8'b0;
			link_x_pos 	<= 8'b0;
			link_y_pos 	<= 8'b0;
			count 	 	<= 6'b0;
			link_facing <= F_DOWN;
			draw_done 	<= OFF;
		end
		else if(init)
		begin
			//initialize first time character appears on map
			link_x_draw <= 8'b0;
			link_y_draw <= 8'b0;
			link_x_pos	<= 8'b0111_1111;
			link_y_pos	<= 8'b0101_1000;
			count  		<= 6'b0;
			link_facing <= F_DOWN;
			draw_done 	<= OFF;
		end
		
		else if(apply_action)
		begin
			/*
			else if(user_input == ATTACK)
			begin
				//pull from attack sprites
			end
			*/
			else if(user_input == UP)
			begin
				//pull from move up sprites
				y_pos 		<= y_pos - 1'b1;
				facing 		<= F_UP;
				intAddressX <= 32;
				intAddressY <= 0;
			end
			else if(user_input == DOWN)
			begin
				//pull from move down sprites
				y_pos 		<= y_pos + 1'b1;
				facing 		<= F_DOWN;
				intAddressX <= 0;
				intAddressY <= 0;
			end
			else if(user_input == LEFT)
			begin
				//pull from move left sprites
				x_pos 		<= x_pos - 1'b1;
				facing 		<= F_LEFT;
				intAddressX  <= 16;
				intAddressY <= 0;
			end
			else if(user_input == RIGHT)
			begin
				//pull from move right sprites
				x_pos 		<= x_pos + 1'b1;
				facing 		<= F_RIGHT;
				intAddressX  <= 48;
				intAddressY <= 0;
			end
		end

		else if(draw_char)
		begin
			//do not need to implement erase if redrawing entire map
			//set write enable to on
			
			spriteAddressX <= intAddressX +  count[3:0];
			spriteAddressY <= intAddressY +  count[7:4];
			//increment x and y positions
			link_x_draw <= x_pos +  count[3:0];
			link_y_draw <= y_pos +count[7:4];
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
