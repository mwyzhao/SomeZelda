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
	input init,

	//enable signal from control
	input collision_enable,

	//position for player character
	input		[8:0] char_x,
	input		[7:0] char_y,
	input 		[2:0] direction_char,
	input 		[2:0] facing_char,
	input 		attack,
	//position for enemies
	input		[8:0] enemy_x,
	input		[7:0] enemy_y,
	input 		[2:0] direction_enemy,

	/* output signals indicating if any collisions have occurred
	 * set to 1 if true, 0 if false */
	/* these signals are sent to the character and enemy logic modules
	 * which will adjust the path necessarily */
	/* c = player character, e = enemy, e2 = enemy2 */
	output reg	c_map_collision,
	output reg	e_map_collision,
	output reg	c_e_collision,
	output reg  e_hit,
	output reg	done
	//output reg [7:0] testRom
	);

	localparam 		NO_ACTION 		= 3'b000,
					ATTACK 			= 3'b001,
					UP 				= 3'b010,
					DOWN 			= 3'b011,
					LEFT 			= 3'b100,
					RIGHT 			= 3'b101,


					ON 		= 1'b1,
					OFF 	= 1'b0,
					MOVE_PRECISION_PX = 1'b1,
					ATTACK_RANGE = 5'd16;

	// 4 corners method of map collision
	reg [7:0] xin_c;
	reg [7:0] yin_c;
	reg [7:0] xin_c_tr;
	reg [7:0] yin_c_tr;
	reg [7:0] xin_c_bl;
	reg [7:0] yin_c_bl;
	reg [7:0] xin_c_br;
	reg [7:0] yin_c_br;


	reg [7:0] xin_e;
	reg [7:0] yin_e;
	reg [7:0] xin_e_tr;
	reg [7:0] yin_e_tr;
	reg [7:0] xin_e_bl;
	reg [7:0] yin_e_bl;
	reg [7:0] xin_e_br;
	reg [7:0] yin_e_br;


	wire col_c;
	wire col_c_tr;
	wire col_c_bl;
	wire col_c_br;

	wire col_e;
	wire col_e_tr;
	wire col_e_bl;
	wire col_e_br;

	reg [7:0] diff_x;
	reg [7:0] diff_y;
	
	reg exception_c;
	reg exception_e;
	wire [15:0] address_c;
	wire [15:0] address_c_tr;
	wire [15:0] address_c_bl;
	wire [15:0] address_c_br;

	wire [15:0] address_e;
	wire [15:0] address_e_tr;
	wire [15:0] address_e_bl;
	wire [15:0] address_e_br;
	
	reg [3:0] count;

	translate256x176 tc(.x(xin_c),
							  .y(yin_c),
							  .mem_address(address_c)
							  );

	translate256x176 tctr(.x(xin_c_tr),
							  	.y(yin_c_tr),
							  	.mem_address(address_c_tr)
							  	);
	translate256x176 tcbl(.x(xin_c_bl),
							  	.y(yin_c_bl),
							  	.mem_address(address_c_bl)
							  	);

	translate256x176 tcbr(.x(xin_c_br),
							  	.y(yin_c_br),
							  	.mem_address(address_c_br)
							  	);


	translate256x176 te(.x(xin_e),
							  .y(yin_e),
							  .mem_address(address_e)
							  );

	translate256x176 tetr(.x(xin_e_tr),
							  	.y(yin_e_tr),
							  	.mem_address(address_e_tr)
							  	);
	translate256x176 tebl(.x(xin_e_bl),
							  	.y(yin_e_bl),
							  	.mem_address(address_e_bl)
							  	);

	translate256x176 tebr(.x(xin_e_br),
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
		diff_x = (char_x > enemy_x)?(char_x - enemy_x):(enemy_x-char_x);
		diff_y = (char_y > enemy_y)?(char_y - enemy_y):(enemy_y-char_y);
		if(direction_char == UP)begin
			xin_c = char_x;
			xin_c_tr = char_x + 5'd16;
			xin_c_bl = char_x;
			xin_c_br = char_x + 5'd16;

			yin_c = char_y -MOVE_PRECISION_PX;
			yin_c_tr = char_y -MOVE_PRECISION_PX;
			yin_c_bl = char_y -MOVE_PRECISION_PX + 5'd16;
			yin_c_br = char_y -MOVE_PRECISION_PX + 5'd16;
			
			
			
			end
		else if(direction_char == DOWN)begin
			xin_c = char_x;
			xin_c_tr = char_x + 5'd16;
			xin_c_bl = char_x;
			xin_c_br = char_x + 5'd16;

			yin_c = char_y +MOVE_PRECISION_PX;
			yin_c_tr = char_y +MOVE_PRECISION_PX;
			yin_c_bl = char_y +MOVE_PRECISION_PX + 5'd16;
			yin_c_br = char_y +MOVE_PRECISION_PX + 5'd16;
			
			end
		else if(direction_char == LEFT)begin
			xin_c = char_x -MOVE_PRECISION_PX;
			xin_c_tr = char_x -MOVE_PRECISION_PX+ 5'd16;
			xin_c_bl = char_x -MOVE_PRECISION_PX;
			xin_c_br = char_x -MOVE_PRECISION_PX + 5'd16;

			yin_c = char_y;
			yin_c_tr = char_y;
			yin_c_bl = char_y  + 5'd16;
			yin_c_br = char_y  + 5'd16;
			
			end
		else if(direction_char == RIGHT)begin
			xin_c = char_x+MOVE_PRECISION_PX;
			xin_c_tr = char_x +MOVE_PRECISION_PX+ 5'd16;
			xin_c_bl = char_x;
			xin_c_br = char_x +MOVE_PRECISION_PX+ 5'd16;

			yin_c = char_y ;
			yin_c_tr = char_y ;
			yin_c_bl = char_y  + 5'd16;
			yin_c_br = char_y  + 5'd16;
			
			end
	

		//enemy!!!!!!!!!!!!!!!!!


		if(direction_enemy == UP)begin
			xin_e = enemy_x;
			xin_e_tr = enemy_x + 5'd16;
			xin_e_bl = enemy_x;
			xin_e_br = enemy_x + 5'd16;

			yin_e = enemy_y -MOVE_PRECISION_PX;
			yin_e_tr = enemy_y -MOVE_PRECISION_PX;
			yin_e_bl = enemy_y -MOVE_PRECISION_PX + 5'd16;
			yin_e_br = enemy_y -MOVE_PRECISION_PX + 5'd16;
			
			end
		else if(direction_enemy == DOWN)begin
			xin_e = enemy_x;
			xin_e_tr = enemy_x + 5'd16;
			xin_e_bl = enemy_x;
			xin_e_br = enemy_x + 5'd16;

			yin_e = enemy_y +MOVE_PRECISION_PX;
			yin_e_tr = enemy_y +MOVE_PRECISION_PX;
			yin_e_bl = enemy_y +MOVE_PRECISION_PX + 5'd16;
			yin_e_br = enemy_y +MOVE_PRECISION_PX + 5'd16;
			
			end
		else if(direction_enemy == LEFT)begin
			xin_e = enemy_x -MOVE_PRECISION_PX;
			xin_e_tr = enemy_x -MOVE_PRECISION_PX+ 5'd16;
			xin_e_bl = enemy_x -MOVE_PRECISION_PX;
			xin_e_br = enemy_x -MOVE_PRECISION_PX + 5'd16;
			
			yin_e = enemy_y;
			yin_e_tr = enemy_y;
			yin_e_bl = enemy_y  + 5'd16;
			yin_e_br = enemy_y  + 5'd16;
			
			end
		else if(direction_enemy == RIGHT)begin
			xin_e = enemy_x+MOVE_PRECISION_PX;
			xin_e_tr = enemy_x +MOVE_PRECISION_PX+ 5'd16;
			xin_e_bl = enemy_x;
			xin_e_br = enemy_x +MOVE_PRECISION_PX+ 5'd16;

			yin_e = enemy_y ;
			yin_e_tr = enemy_y ;
			yin_e_bl = enemy_y  + 5'd16;
			yin_e_br = enemy_y  + 5'd16;
			
			end

		if(attack)begin
			if(facing_char == UP)begin
				if((diff_x < 5'd16) &&(enemy_y+5'd16 - char_y < ATTACK_RANGE) &&(enemy_y<char_y))
					e_hit = ON;
				else 
					e_hit = OFF;
			end
			else if (facing_char == DOWN)begin
				if((diff_x < 5'd16) &&(char_y+5'd16 -enemy_y < ATTACK_RANGE)&& (enemy_y>char_y))
					e_hit = ON;
				else 
					e_hit = OFF;
			end
			else if (facing_char == LEFT)begin
				if((diff_y < 5'd16) &&((char_x-(enemy_x+5'd16))  < ATTACK_RANGE) && (enemy_x<char_x))
					e_hit = ON;
				else 
					e_hit = OFF;
			end
			else if (facing_char == RIGHT)begin
				if((diff_y < 5'd16) &&((enemy_x- (char_x+5'd16))  < ATTACK_RANGE) && (enemy_x>char_x))
					e_hit = ON;
				else 
					e_hit = OFF;
			end
			else
				e_hit = OFF;

		end
		else
			e_hit = OFF;

		if( ((char_y ==0) && (direction_char == UP))||((char_x == 0) && (direction_char == LEFT)) || (((char_x+5'd16) == 255) &&(direction_char == RIGHT)) || (((char_y+5'd16) == 175) &&(direction_char == DOWN))  )
			exception_c = ON;
		else 
			exception_c = OFF;
			
		if(((enemy_y ==0) && (direction_enemy == UP))||((enemy_x == 0) && (direction_enemy == LEFT))|| (((enemy_x+5'd16) == 255) &&(direction_enemy == RIGHT)) || (((enemy_y+5'd16) == 175) &&(direction_enemy == DOWN)) )
			exception_e = ON;
		else 
			exception_e = OFF;
		//if(collision_enable&& ((diff_x <5'd16&& diff_y < 5'd16) || !(&{col_e,col_e_tr, col_e_bl, col_e_br}) || !(&{col_c,col_c_tr, col_c_bl, col_c_br})) ) begin
		if(collision_enable && (({col_e,col_e_tr, col_e_bl, col_e_br} != 4'b1111) || ({col_c,col_c_tr, col_c_bl, col_c_br}!= 4'b1111) || (exception_c) || ((diff_x <=16)&& (diff_y <=16))||(exception_e)))begin
				
				c_e_collision = OFF;
				e_map_collision = OFF;
				c_map_collision = OFF;
			//if(!(&{col_e,col_e_tr, col_e_bl, col_e_br})) begin
			if(({col_e,col_e_tr, col_e_bl, col_e_br} != 4'b1111) || exception_e)begin
				e_map_collision = ON;
				//facing_e_out = direction_enemy;
			end
			//if (!(&{col_c,col_c_tr, col_c_bl, col_c_br})) begin
			if(({col_c,col_c_tr, col_c_bl, col_c_br}!= 4'b1111) || exception_c)begin
				c_map_collision = ON;
				//facing_c_out = direction_char;
			end
			if((diff_x <=16)&& (diff_y <=16)) begin
				c_e_collision = ON;
			end

		end

		else if (collision_enable)begin
			c_e_collision = OFF;
			e_map_collision = OFF;
			c_map_collision = OFF;
		end
		// testRom = {col_e, col_e_tr, col_e_bl, col_e_br, col_c,col_c_tr, col_c_bl, col_c_br};

	end
	
	always@(posedge clock)
	begin
		count <= count + 1'b1;
		if(reset)
		begin
			count <= 4'b0;
			done <= 1'b0;
		end
		else if(init)
		begin
			count <= 4'b0;
			done <= 1'b0;
		end
		else if(count == 4'b1111)
			done <= 1'b1;
		else
			done <= 1'b0;
	end
	
endmodule