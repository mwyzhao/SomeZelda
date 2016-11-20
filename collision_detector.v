/*** contains memory for a level graph of map
	 also does computation for character collision ***/

/* x,y coordinates of all characters are wired into this
 * module where it is then used to calculate if collision will occur
 * active when c_collision bit from control module is high */

/* whoever will be writing this in the future feel free to do whatever
   you want with this section as long as it works */

/* tentative module declaration */

/* 

module collision_detector(
	input clock,
	input reset,

	//enable signal from control
	input c_c_enable,

	//position for player character
	input		[8:0] x_char,
	input		[7:0] y_char,
	input 		[1:0] direction_char;
	input 		[1:0] facing_char;

	//position for enemies
	input		[8:0]x_enemy1,
	input		[7:0]y_enemy1,
	input 		[1:0] direction_enemy1;
	input 		[1:0] facing_enemy1;

	//input 		x_enemy2,
	//input		y_enemy2,

	/* output signals indicating if any collisions have occurred
	 * set to 1 if true, 0 if false */
	/* these signals are sent to the character and enemy logic modules
	 * which will adjust the path necessarily */
	/* c = player character, e1 = enemy1, e2 = enemy2 */
	output reg	c_map_collision,
	output reg	e1_map_collision,
	//output reg	e2_map_collision,
	output reg	c_e1_collision,
	//output reg	c_e2_collision,
	//output reg	e1_e2_collision,
	//output reg 	c_attack_e1,
	//output reg	c_attack_e2,
	//output reg 		done_check;

	output reg [1:0] facing_c_out;
	output reg [1:0] facing_e_out;
	);
	localparam 		UP 		= 2'b00,
					DOWN 	= 2'b01,
					LEFT 	= 2'b10,
					RIGHT 	= 2'b11,

					ON 		= 1'b1,
					OFF 	= 1'b0;
	reg [8:0] xin_c;
	reg [7:0] yin_c;
	reg [8:0] xin_e;
	reg [7:0] yin_e;
	reg col_c;
	reg col_e;
	wire [16:0] address_c;
	wire [16:0] address_e;

	initial xin_c = x_char;
	initial yin_c = y_char;
	initial xin_e = x_enemy1;
	initial yin_e = y_enemy1;

	vga_address_translator tc(.x(xin_c),
							  .y(yin_c),
							  .mem_address(address_c)
							  );
	vga_address_translator te(.x(xin_e),
							  .y(yin_e),
							  .mem_address(address_e)
							  );
	levelmap m1c(.address(address_c),
			     .clock(clock),
			     .q(col_c)
			     );
	levelmap m1e(.address(address_e),
			     .clock(clock),
			     .q(col_e)
			     );

	always@(*)begin
		if(direction_char == UP)
			yin_c = yin_c -16;
		else if(direction_char == DOWN)
			yin_c = yin_c +16;
		else if(direction_char == LEFT)
		 	xin_c = xin_c - 16;
		else if(direction_char == RIGHT)
			xin_c = xin_c + 16;

		if(direction_enemy1 == UP)
			yin_e = yin_e -16;
		else if(direction_enemy1 == DOWN)
			yin_e = yin_e +16;
		else if(direction_enemy1 == LEFT)
		 	xin_e = xin_e - 16;
		else if(direction_enemy1 == RIGHT)
			xin_e = xin_e + 16;
		
		if(!col_e || !col_c) begin
			if(col_e == 0) begin
				e1_map_collision = ON;
				facing_e_out = direction_enemy1;
			end
			if (col_c == 0) begin
				c_map_collision = ON;
				facing_c_out = direction_char;
			end

		end

		else if({xin_c,yin_c} == {xin_e,yin_e}) begin
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