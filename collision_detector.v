/*** contains memory for a level graph of map
	 also does computation for character collision ***/

/* x,y coordinates of all characters are wired into this
 * module where it is then used to calculate if collision will occur
 * active when c_collision bit from control module is high */

/* whoever will be writing this in the future feel free to do whatever
   you want with this section as long as it works */

/* tentative module declaration */

 

module collision_detector(
	input clock,
	input reset,

	//enable signal from control
	input collision_enable;

	//position for player character
	input		[8:0] char_x,
	input		[7:0] char_y,
	input 		[2:0] direction_char;
	input 		[2:0] facing_char;

	//position for enemies
	input		[8:0] enemy1_x,
	input		[7:0] enemy1_y,
	input 		[2:0] direction_enemy1;
	input 		[2:0] facing_enemy1;

	/* output signals indicating if any collisions have occurred
	 * set to 1 if true, 0 if false */
	/* these signals are sent to the character and enemy logic modules
	 * which will adjust the path necessarily */
	/* c = player character, e1 = enemy1, e2 = enemy2 */
	output reg	c_map_collision,
	output reg	e1_map_collision,
	output reg	c_e1_collision,

	//output reg [1:0] facing_c_out;
	//output reg [1:0] facing_e_out;
	);

	localparam 		NO_ACTION 		= 3'b000,
					ATTACK 			= 3'b001,
					UP 				= 3'b010,
					DOWN 			= 3'b011,
					LEFT 			= 3'b100,
					RIGHT 			= 3'b101,


					ON 		= 1'b1,
					OFF 	= 1'b0,
					MOVE_PRECISION_PX = 1'b1;

	// 4 corners method of map collision
	reg [8:0] xin_c;
	reg [7:0] yin_c;
	reg [8:0] xin_c_tr;
	reg [7:0] yin_c_tr;
	reg [8:0] xin_c_bl;
	reg [7:0] yin_c_bl;
	reg [8:0] xin_c_br;
	reg [7:0] yin_c_br;


	reg [8:0] xin_e;
	reg [7:0] yin_e;
	reg [8:0] xin_e_tr;
	reg [7:0] yin_e_tr;
	reg [8:0] xin_e_bl;
	reg [7:0] yin_e_bl;
	reg [8:0] xin_e_br;
	reg [7:0] yin_e_br;


	reg col_c;
	reg col_c_tr;
	reg col_c_bl;
	reg col_c_br;

	reg col_e;
	reg col_e_tr;
	reg col_e_bl;
	reg col_e_br;

	reg [8:0] diff_x;
	reg [7:0] diff_y;

	wire [16:0] address_c;
	wire [16:0] address_c_tr;
	wire [16:0] address_c_bl;
	wire [16:0] address_c_br;

	wire [16:0] address_e;
	wire [16:0] address_e_tr;
	wire [16:0] address_e_bl;
	wire [16:0] address_e_br;

	vga_address_translator tc(.x(xin_c),
							  .y(yin_c),
							  .mem_address(address_c)
							  );

	vga_address_translator tctr(.x(xin_c_tr),
							  	.y(yin_c_tr),
							  	.mem_address(address_c_tr)
							  	);
	vga_address_translator tcbl(.x(xin_c_bl),
							  	.y(yin_c_bl),
							  	.mem_address(address_c_bl)
							  	);

	vga_address_translator tcbr(.x(xin_c_br),
							  	.y(yin_c_br),
							  	.mem_address(address_c_br)
							  	);


	vga_address_translator te(.x(xin_e),
							  .y(yin_e),
							  .mem_address(address_e)
							  );

	vga_address_translator tetr(.x(xin_e_tr),
							  	.y(yin_e_tr),
							  	.mem_address(address_e_tr)
							  	);
	vga_address_translator tebl(.x(xin_e_bl),
							  	.y(yin_e_bl),
							  	.mem_address(address_e_bl)
							  	);

	vga_address_translator tebr(.x(xin_e_br),
							  	.y(yin_e_br),
							  	.mem_address(address_e_br)
							  	);


	levelmap m1c(.address(address_c),
			     .clock(clock),
			     .q(col_c)
			     );
	levelmap m1ctr(.address(address_c_tr),
			     .clock(clock),
			     .q(col_c_tr)
			     );
	levelmap m1cbl(.address(address_c_bl),
			     .clock(clock),
			     .q(col_c_bl)
			     );
	levelmap m1cbr(.address(address_c_br),
			     .clock(clock),
			     .q(col_c_br)
			     );

	levelmap m1e(.address(address_e),
			     .clock(clock),
			     .q(col_e)
			     );
	levelmap m1etr(.address(address_e_tr),
			     .clock(clock),
			     .q(col_e_tr)
			     );
	levelmap m1ebl(.address(address_e_bl),
			     .clock(clock),
			     .q(col_e_bl)
			     );
	levelmap m1ebr(.address(address_e_br),
			     .clock(clock),
			     .q(col_e_br)
			     );


	always@(*)begin
		
		//LINK!!!!!!!! woahhh
		diff_x = (char_x > enemy1_x)?(char_x - enemy1_x):(enemy_x-char_x);
		diff_y = (char_y > enemy1_y)?(char_y - enemy1_y):(enemy_y-char_y);
		if(direction_char == UP)begin
			xin_c = char_x;
			xin_c_tr = char_x + 16;
			xin_c_bl = char_x;
			xin_c_br = char_x + 16;

			yin_c = char_y -MOVE_PRECISION_PX;
			yin_c_tr = char_y -MOVE_PRECISION_PX;
			yin_c_bl = char_y -MOVE_PRECISION_PX + 16;
			yin_c_br = char_y -MOVE_PRECISION_PX + 16;
			
			end
		else if(direction_char == DOWN)begin
			xin_c = char_x;
			xin_c_tr = char_x + 16;
			xin_c_bl = char_x;
			xin_c_br = char_x + 16;

			yin_c = char_y +MOVE_PRECISION_PX;
			yin_c_tr = char_y +MOVE_PRECISION_PX;
			yin_c_bl = char_y +MOVE_PRECISION_PX + 16;
			yin_c_br = char_y +MOVE_PRECISION_PX + 16;
			
			end
		else if(direction_char == LEFT)begin
			xin_c = char_x -MOVE_PRECISION_PX;
			xin_c_tr = char_x -MOVE_PRECISION_PX+ 16;
			xin_c_bl = char_x -MOVE_PRECISION_PX;
			xin_c_br = char_x -MOVE_PRECISION_PX + 16;

			yin_c = char_y;
			yin_c_tr = char_y;
			yin_c_bl = char_y  + 16;
			yin_c_br = char_y  + 16;
			
			end
		else if(direction_char == RIGHT)begin
			xin_c = char_x+MOVE_PRECISION_PX;
			xin_c_tr = char_x +MOVE_PRECISION_PX+ 16;
			xin_c_bl = char_x;
			xin_c_br = char_x +MOVE_PRECISION_PX+ 16;

			yin_c = char_y ;
			yin_c_tr = char_y ;
			yin_c_bl = char_y  + 16;
			yin_c_br = char_y  + 16;
			
			end


		//enemy!!!!!!!!!!!!!!!!!


		if(direction_enemy1 == UP)begin
			xin_e = enemy1_x;
			xin_e_tr = enemy1_x + 16;
			xin_e_bl = enemy1_x;
			xin_e_br = enemy1_x + 16;

			yin_e = enemy1_y -MOVE_PRECISION_PX;
			yin_e_tr = enemy1_y -MOVE_PRECISION_PX;
			yin_e_bl = enemy1_y -MOVE_PRECISION_PX + 16;
			yin_e_br = enemy1_y -MOVE_PRECISION_PX + 16;
			
			end
		else if(direction_enemy1 == DOWN)begin
			xin_e = enemy1_x;
			xin_e_tr = enemy1_x + 16;
			xin_e_bl = enemy1_x;
			xin_e_br = enemy1_x + 16;

			yin_e = enemy1_y +MOVE_PRECISION_PX;
			yin_e_tr = enemy1_y +MOVE_PRECISION_PX;
			yin_e_bl = enemy1_y +MOVE_PRECISION_PX + 16;
			yin_e_br = enemy1_y +MOVE_PRECISION_PX + 16;
			
			end
		else if(direction_enemy1 == LEFT)begin
			xin_e = enemy1_x -MOVE_PRECISION_PX;
			xin_e_tr = enemy1_x -MOVE_PRECISION_PX+ 16;
			xin_e_bl = enemy1_x -MOVE_PRECISION_PX;
			xin_e_br = enemy1_x -MOVE_PRECISION_PX + 16;

			yin_e = enemy1_y;
			yin_e_tr = enemy1_y;
			yin_e_bl = enemy1_y  + 16;
			yin_e_br = enemy1_y  + 16;
			
			end
		else if(direction_enemy1 == RIGHT)begin
			xin_e = enemy1_x+MOVE_PRECISION_PX;
			xin_e_tr = enemy1_x +MOVE_PRECISION_PX+ 16;
			xin_e_bl = enemy1_x;
			xin_e_br = enemy1_x +MOVE_PRECISION_PX+ 16;

			yin_e = enemy1_y ;
			yin_e_tr = enemy1_y ;
			yin_e_bl = enemy1_y  + 16;
			yin_e_br = enemy1_y  + 16;
			
			end

		
		if(collision_enable&& (!(&{col_e,col_e_tr, col_e_bl, col_e_br})||!(&{col_c,col_c_tr, col_c_bl, col_c_br})) begin
			if(!(&{col_e,col_e_tr, col_e_bl, col_e_br})) begin
				e1_map_collision = ON;
				//facing_e_out = direction_enemy1;
			end
			if (!(&{col_c,col_c_tr, col_c_bl, col_c_br})) begin
				c_map_collision = ON;
				//facing_c_out = direction_char;
			end

		end

		else if(collision_enable && diff_x <16&& diff_y < 16) begin
			c_e1_collision = ON;
		end
		else begin
			c_e1_collision = OFF;
			e1_map_collision = OFF;
			c_map_collision = OFF;
		end

	end
	
	
	

	

endmodule

*/