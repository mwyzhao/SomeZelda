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
	input 		[3:0] collision,

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

	//output write enable to VGA
	output  			VGA_write,
	//output finished signals
	output reg 			draw_done,
	
	output reg [2:0]hp
	);
	
	initial hp = 3'b110;

	/** local parameters **/
	localparam 	NO_ACTION 	= 3'b000,
					ATTACK 		= 3'b001,
					UP 			= 3'b010,
					DOWN 			= 3'b011,
					LEFT 			= 3'b100,
					RIGHT 		= 3'b101,

					ON				= 1'b1,
					OFF			= 1'b0,

					MAX_COUNT	= 8'd255,
					MAX_ATK_COUNT = 9'd511;

	/** ram for link character sprites which includes
		8 link walking sprites and 8 link attacking sprites **/

	translateLinkSprite64x48 t0(.x(spriteAddressX),
							 .y(spriteAddressY),
							 .mem_address(spriteMemAddress)
							 );
	link_sprite_mem m0(
		.address(spriteMemAddress),
		.clock(clock),
		.q(colour));

	/** registers and wires **/
	reg [5:0] spriteAddressX;
	reg [5:0] spriteAddressY;
	reg [5:0] intAddressX;
	reg [5:0] intAddressY;
	wire [11:0]spriteMemAddress;
	
	reg [5:0] invincible;
	/** position registers for player character link **/
	//counter for when link is finished drawing
	reg 	[7:0] count;
	//counter for when link attack sprite is finished drawing
	reg 	[8:0] atkCount;
	
	//counter for lowering movement speed
	reg 	[3:0] apply_count;
	
	assign VGA_write = (draw) && (colour != 6'b111111);

	//sequential logic
	always@(posedge clock)
	begin
		if(collision[3:1] != 3'b000 && invincible==0)begin
			hp <= hp -1;
			invincible <= 6'b111111;
		end
		if(reset)
		begin
			//reset block, resets all registers to 0;
			x_draw <= 9'b0;
			y_draw <= 8'b0;
			x_pos 	<= 9'd1;
			y_pos 	<= 8'd96;
			count 	 	<= 8'b0;
			atkCount <= 9'b0;
			apply_count <= 4'b0;
			facing <= DOWN;
			direction <= NO_ACTION;
			draw_done 	<= OFF;
			hp <= 3'b110;
			invincible <= 4'b0000;
		end
		else if(init)
		begin
			//initialize first time character appears on map
			x_draw <= 8'b0;
			y_draw <= 8'b0;
			x_pos	<= 9'd1;
			y_pos	<= 8'd96;
			count  		<= 8'b0;
			atkCount <= 9'b0;
			apply_count <= 4'b0;
			facing <= DOWN;
			direction <= NO_ACTION;
			draw_done 	<= OFF;
			hp <= 3'b110;
			invincible <= 4'b0000;
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
			//increment apply_count here
			apply_count <= apply_count + 1'b1;
			
			if(apply_count == 4'b0000)
			begin
				if(invincible!=0)
					invincible <= invincible - 1'b1;

				if(direction == ATTACK)
				begin
					if(facing == UP)begin
						intAddressX <=48;
						intAddressY <=16;
					end
					else if(facing == DOWN)begin
						intAddressX <=0;
						intAddressY <=16;
					end
					else if(facing == LEFT)begin
						intAddressX <=16;
						intAddressY <=16;
					end
					else if(facing == RIGHT)begin
						intAddressX <=16;
						intAddressY <=32;
					end

				end
				else if (invincible == 0)begin
					if (facing == UP) begin
						intAddressX <= 32;
						intAddressY <= 0;
					end
					else if (facing == DOWN) begin
						intAddressX <= 0;
						intAddressY <= 0;
					end
					else if (facing == LEFT) begin
						intAddressX <= 16;
						intAddressY <= 0;
					end
					else if (facing == RIGHT) begin
						intAddressX <= 48;
						intAddressY <= 0;
					end
					
				end
				else begin
					if (facing == UP) begin
						intAddressX <= 32;
						intAddressY <= 48;
					end
					else if (facing == DOWN) begin
						intAddressX <= 0;
						intAddressY <= 48;
					end
					else if (facing == LEFT) begin
						intAddressX <= 16;
						intAddressY <= 48;
					end
					else if (facing == RIGHT) begin
						intAddressX <= 48;
						intAddressY <= 48;
					end
				end
				
				if(direction == UP)
				begin
					//pull from move up sprites
					if(!collision[0])
					begin
						y_pos 	<= y_pos - 1'b1;
					end
					facing <= UP;
					if(invincible == 0)begin
						intAddressX <= 32;
						intAddressY <= 0;
					end
					else begin
						intAddressX <= 32;
						intAddressY <= 48;
					end
					
				end
				else if(direction == DOWN)
				begin
					//pull from move down sprites
					if(!collision[0])
					begin
						y_pos 	<= y_pos + 1'b1;
					end
					facing	<= DOWN;
					if(invincible == 0)begin
						intAddressX <= 0;
						intAddressY <= 0;
					end
					else begin
						intAddressX <= 0;
						intAddressY <= 48;
					end
				end
				else if(direction == LEFT)
				begin
					//pull from move left sprites
					if(!collision[0])
					begin
						x_pos	<= x_pos - 1'b1;
					end
					facing <= LEFT;
					if(invincible == 0)begin
						intAddressX <= 16;
						intAddressY <= 0;
					end
					else begin
						intAddressX <= 16;
						intAddressY <= 48;
					end
				end
				else if(direction == RIGHT)
				begin
					//pull from move right sprites
					if(!collision[0])
					begin
						x_pos	<= x_pos + 1'b1;
					end
					facing <= RIGHT;
					if(invincible == 0)begin
						intAddressX <= 48;
						intAddressY <= 0;
					end
					else begin
						intAddressX <= 48;
						intAddressY <= 48;
					end
				end


			end
		end

		else if(draw && (direction != ATTACK))
		begin
			//do not need to implement erase if redrawing entire map
			//set write enable to on
			spriteAddressX <= intAddressX + count[3:0];
			spriteAddressY <= intAddressY + count[7:4];
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
		else if(draw && (direction == ATTACK))
		begin
			//do not need to implement erase if redrawing entire map
			//set write enable to on
			//spriteAddressX <= intAddressX + atkCount[3:0];
			//spriteAddressY <= intAddressY + atkCount[7:4];
			//increment x and y positions
			//x_draw <= x_pos + atkCount[3:0];
			//y_draw <= y_pos + atkCount[7:4];

			if(facing == DOWN)begin
				spriteAddressX <= intAddressX + atkCount[3:0];
				spriteAddressY <= intAddressY + atkCount[8:4];
				//increment x and y positions
				x_draw <= x_pos + atkCount[3:0];
				y_draw <= y_pos + atkCount[8:4];
			end
			else if(facing == UP)begin
				spriteAddressX <= intAddressX + atkCount[3:0];
				spriteAddressY <= intAddressY + atkCount[8:4];
				//increment x and y positions
				x_draw <= x_pos + atkCount[3:0];
				y_draw <= y_pos - 16 + atkCount[8:4];
			end
			else if (facing == LEFT) begin
				spriteAddressX <= intAddressX + atkCount[4:0];
				spriteAddressY <= intAddressY + atkCount[8:5];
				//increment x and y positions
				x_draw <= x_pos -16 + atkCount[4:0];
				y_draw <= y_pos + atkCount[8:5];
			end
			else if (facing == RIGHT) begin
				spriteAddressX <= intAddressX + atkCount[4:0];
				spriteAddressY <= intAddressY + atkCount[8:5];
				//increment x and y positions
				x_draw <= x_pos + atkCount[4:0];
				y_draw <= y_pos + atkCount[8:5];
			end

			//increment counter
			atkCount 		<= atkCount + 1'b1;

			//once counter reaches max, drawing done
			if(atkCount == MAX_ATK_COUNT)
			begin
				//set write enable to off and reset counter
				atkCount 		<= 9'b0;

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
