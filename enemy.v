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
	output reg 	  [8:0] enemy_x_pos,
	output reg 	  [7:0] enemy_y_pos,
	output reg 	  [8:0] enemy_x_draw,
	output reg 	  [7:0] enemy_y_draw,

	//enemy direction data for collision_detector
	output reg 	  [2:0] enemy_direction,
	output reg 	  [1:0] enemy_facing,

	//memory output data for vga
	output 	 	  [5:0] colour,

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

					MAX_COUNT = 8'b255;

	/** ram for enemy character sprites which includes 8 enemy walking sprites **/

	enemy_sprite_mem m0(
		.address({spriteAddressY,spriteAddressX}),
		.clock(clock),
		.q(colour));

	reg [5:0] spriteAddressX;
	reg [3:0] spriteAddressY;
	reg [5:0] intAddressX;
	reg [3:0] intAddressY;
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
			enemy_x_pos		<= 9'b0;
			enemy_y_pos		<= 8'b0;
			count			<= 6'b0;
			enemy_facing	<= F_DOWN;
			draw_done		<= OFF;
		end
		else if(init)
		begin
			//initialize first time character appears on map
			enemy_x_draw	<= 8'b0;
			enemy_y_draw	<= 8'b0;
			enemy_x_pos		<= 8'b0111_1111;
			enemy_y_pos		<= 8'b0101_1000;
			count			<= 6'b0;
			enemy_facing	<= F_DOWN;
			draw_done		<= OFF;
		end
		
		else if(gen_move)
		begin
			//logic to generate moves, for now move left
			enemy_direction		<= LEFT;
		end

		else if(move_enemies)
		begin
			else if(enemy_direction == UP)
			begin
				//pull from move up sprites
				if(!collision)
				begin
					enemy_y_pos <= enemy_y_pos - 1'b1;
				end
				enemy_facing	<= F_UP;
				intAddressX		<= 32;
				intAddressY		<= 0;
			end
			else if(enemy_direction == DOWN)
			begin
				//pull from move down sprites
				if(!collision)
				begin
					enemy_y_pos	<= enemy_y_pos + 1'b1;
				end
				enemy_facing	<= F_DOWN;
				intAddressX		<= 0;
				intAddressY		<= 0;
			end
			else if(enemy_direction == LEFT)
			begin
				//pull from move left sprites
				if(!collision)
				begin
					enemy_x_pos	<= enemy_x_pos - 1'b1;
				end
				enemy_facing	<= F_LEFT;
				intAddressX		<= 16;
				intAddressY		<= 0;
			end
			else if(enemy_direction == RIGHT)
			begin
				//pull from move right sprites
				if(!collision)
				begin
					enemy_x_pos	<= enemy_x_pos + 1'b1;
				end
				enemy_facing 	<= F_RIGHT;
				intAddressX 	<= 48;
				intAddressY 	<= 0;
			end
		end

		else if(draw_enemies)
		begin
			//do not need to implement erase if redrawing entire map
			//set write enable to on
			spriteAddressX <= intAddressX + count[3:0];
			spriteAddressY <= intAddressY + count[7:4];
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
