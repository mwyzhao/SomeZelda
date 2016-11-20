/*** implementation of character movement logic based on user inputs ***/

/** FOR NOW LINK WILL BE A SQUARE

module link_char(
	input clock,
	input reset,

	//state signals from control
	input 				init,
	input 				idle,
	input 				attack,
	input 				move_up,
	input 				move_down,
	input 				move_left,
	input 				move_right,
	input 				draw_char,

	//position of memory to be changed as character is updated into memory
	//8 and 7 bits as it will never exceed map bounds (256x176)
	output reg 	  [7:0] link_x_draw,
	output reg 	  [7:0] link_y_draw,
	output reg 	  [2:0] cout;
	//output finished signals
	output reg 			draw_done,

	//output write enable to VGA (do we need this?)
	output  			VGA_write
	);

	/** local parameters **/
	localparam 		UP 		= 2'b00,
					DOWN 	= 2'b01,
					LEFT 	= 2'b10,
					RIGHT 	= 2'b11,

					ON 		= 1'b1,
					OFF 	= 1'b0,

					MAX_COUNT = 6'b111111;

	/** ram for link character sprites which includes
		8 link walking sprites and 8 link attacking sprites **/

	/*
	link_sprite_mem m0(...);
	*/
	reg [5:0] spriteAddressX;
	reg [3:0] spriteAddressY;
	reg [5:0] intAddressX;
	reg [3:0] intAddressY;
	wire [5:0] spriteColor;
	/** position registers for player character link **/
	
	//link_pos is the x,y coord of link's character sprite (top left corner of image)
	reg 	[7:0] x_pos;
	reg		[7:0] y_pos;
	
	//direction register as defined by localparam
	//this is to be used by attack state
	reg 	[1:0] direction;

	//counter for when link is finished drawing
	reg 	[5:0] count;
	reg [1:0] facing;
	assign VGA_write = (draw_char)&&(spriteColor!=6'b111111);
	always@(posedge clock)
	begin
		if(reset)
		begin
			//reset block, resets all registers to 0;
			link_x_draw <= 8'b0;
			link_y_draw <= 8'b0;
			x_pos 		<= 8'b0;
			y_pos 		<= 8'b0;
			direction 	<= DOWN;
			count 	 	<= 6'b0;
			draw_done 	<= OFF;
			VGA_write  	<= OFF;
		end
		else if(init)
		begin
			//initialize first time character appears on map
			link_x_draw <= 8'b0;
			link_y_draw <= 8'b0;
			x_pos 		<= 8'b0111_1111;
			y_pos 		<= 8'b0101_1000;
			direction 	<= DOWN;
			count  		<= 6'b0;
			facing 		<= DOWN;
		end
		/*
		else if(idle)
		begin
			//we probably don't even need this
		end
		else if(attack)
		begin
			//pull from attack sprites
		end
		*/
		else if(move_up)
		begin
			//pull from move up sprites
			direction 	<= UP;
			y_pos 		<= y_pos - 1'b1;
			facing 		<= UP;
			intAddressX <= 32;
			intAddressY <= 0;
		end
		else if(move_down)
		begin
			//pull from move down sprites
			direction 	<= DOWN;
			y_pos 		<= y_pos + 1'b1;
			facing 		<= DOWN;
			intAddressX  <= 0;
			intAddressY <= 0;
		end
		else if(move_left)
		begin
			//pull from move left sprites
			direction 	<= LEFT;
			x_pos 		<= x_pos - 1'b1;
			facing 		<= LEFT;
			intAddressX  <= 16;
			intAddressY <= 0;
		end
		else if(move_right)
		begin
			//pull from move right sprites
			direction 	<= RIGHT;
			x_pos 		<= x_pos + 1'b1;
			facing 		<= RIGHT;
			intAddressX  <= 48;
			intAddressY <= 0;
		end
		else if(draw_char)
			//do not need to implement erase if redrawing entire map
			//set write enable to on
			
			
				
			spriteAddressX <= intAddressX + [3:0] count;
			spriteAddressY <= intAddressY + [7:4] count;
			//increment x and y positions
			link_x_draw <= x_pos + [3:0] count;
			link_y_draw <= y_pos + [7:4] count;
			cout <= spriteColor;
			//increment counter
			count 		<= count + 1'b1;

			//once counter reaches max, drawing done
			if(count == MAX_COUNT)
			begin
				//set write enable to off and reset counter
				VGA_write 	<= OFF;
				count 		<= 6'b0;

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