/*** datapath to run computations ***/

module datapath(
	input  			clock,				//CLOCK 						CLOCK_50
	input 			reset,				//RESET							SW[9]

	input 			c_attack, 			//INPUT ATTACK SIGNAL 			SW[0]
	input			c_up,				//INPUT UP SIGNAL 				KEY[3]
	input			c_down,				//INPUT DOWN SIGNAL 			KEY[2]
	input			c_left,				//INPUT LEFT SIGNAL 			KEY[1]
	input			c_right,			//INPUT RIGHT SIGNAL 			KEY[0]
		
	input			init,				//INITIALIZATION SIGNAL 		FROM CONTROL
	input			idle,				//IDLE SIGNAL					FROM CONTROL
	input 			gen_move, 			//MOVEMENT SIGNAL 				FROM CONTROL
	input 			check_collide, 		//CHECK COLLIDE SIGNAL 			FROM CONTROL
	input 			apply_act_link,		//APPLY LINK ACTION 			FROM CONTROL
	input 			move_enemies, 		//APPLU ENEMY MOVEMENT 			FROM CONTROL
	input			draw_map,			//DRAW MAP SIGNAL				FROM CONTROL 
	input 			draw_link, 			//DRAW LINK SIGNAL 				FROM CONTROL
	input 			draw_enemies, 		//DRAW ENEMY SIGNAL 			FROM CONTROL
	input 			draw_to_vga,

	output [8:0] enemy_1_x_pos,
	output [7:0] enemy_1_y_pos,
	output [8:0] enemy_2_x_pos,
	output [7:0] enemy_2_y_pos,
	output [8:0] enemy_3_x_pos,
	output [7:0] enemy_3_y_pos,
	
	output [3:0] c_e_test,
	
	output reg		[8:0] x_position,	//POSITION CORRDINATE X 		FOR VGA
	output reg		[7:0] y_position,	//POSITION COORDINATE Y			FOR VGA
	output		[5:0] colour, 		//DATA TO BE WRITTEN TO MEMORY 	FOR VGA
	output reg		VGA_enable,			//WRITE ENABLE SIGNAL 			FOR VGA

	//probably don't need the commented out signals
	output reg		idle_done,			//IDLE DONE SIGNAL				FOR CONTROL
	output			gen_move_done,
	output 			check_collide_done, //COLLIDE DONE SIGNAL 			FOR CONTROL
	output 		  	draw_map_done,		//DRAW DONE SIGNAL				FOR CONTROL
	output 			draw_link_done, 		//DRAW DONE SIGNAL 				FOR CONTROL
	output 			draw_enemies_done, 	//DRAW DONE SIGNAL 				FOR CONTROL
	output reg 		draw_vga_done
	);
	
	/** parameters **/
	parameter 	MAX_FRAME_COUNT = 28'd1, 	//count for for 30 fps 50MHz/30
				COUNT_INITIAL = 16'd65535,
				MAX_COUNT = 16'd45055,
				MAX_X_POSITION = 8'd255,
					//action parameters
					NO_ACTION 		= 3'b000,
					ATTACK 			= 3'b001,
					UP 				= 3'b010,
					DOWN 				= 3'b011,
					LEFT 				= 3'b100,
					RIGHT 			= 3'b101,
					//on-off
					ON 				= 1'b1,
					OFF 				= 1'b0;

	/** wire and register declarations go here **/
	//map signal wires
	wire [8:0] map_x_draw;
	wire [7:0] map_y_draw;
	wire [5:0] map_colour;
	wire map_write;

	//character signal wires
	wire [8:0] link_x_pos;
	wire [7:0] link_y_pos;
	wire [8:0] link_x_draw;
	wire [7:0] link_y_draw;
	wire [2:0] link_direction;
	wire [2:0] link_facing;
	wire [3:0] link_collision;
	wire [5:0] link_colour;
	wire link_write;
	assign c_e_test = {e3_hit,e2_hit,e1_hit,1'b0};
	//enemy signal wires
//	wire [8:0] enemy_1_x_pos;
//	wire [7:0] enemy_1_y_pos;
//	wire [8:0] enemy_2_x_pos;
//	wire [7:0] enemy_2_y_pos;
//	wire [8:0] enemy_3_x_pos;
//	wire [7:0] enemy_3_y_pos;
	wire [8:0] enemy_x_draw;
	wire [7:0] enemy_y_draw;
	wire [2:0] enemy_1_direction;
	wire [2:0] enemy_1_facing;
	wire [2:0] enemy_2_direction;
	wire [2:0] enemy_2_facing;
	wire [2:0] enemy_3_direction;
	wire [2:0] enemy_3_facing;
	wire enemy1_collision;
	wire enemy2_collision;
	wire enemy3_collision;
	wire [2:0] enemy_collision;
	wire e1_hit;
	wire e2_hit;
	wire e3_hit;
	wire [2:0] e_hit;
	wire [5:0] enemy_colour;
	wire enemy_write;

	assign enemy_collision = {enemy3_collision,enemy2_collision,enemy1_collision};
	assign e_hit = {e3_hit,e2_hit,e1_hit};

	//frame counter limits actions to 50Hz
	//24	bits for overflow safety
	reg  [27:0] frame_counter;

	reg [5:0] fb_colour;	
	wire [15:0] fb_address;
	reg fb_wren;

	reg [15:0] buffer_count;

	translate256x176 fb_translator(
		.x 			(x_position),
		.y 			(y_position),
		.mem_address (fb_address));
	
	frame_buffer frame_buff(
		.address		(fb_address),
		.clock			(clock),
		.data 			(fb_colour),
		.wren			(fb_wren),
		.q				(colour));

	/** module declarations go here **/
	map M(
		.clock 			(clock),
		.reset 			(reset),

		//enable signal
		.enable 		(draw_map),

		//output x,y coord
		.x_pos 			(map_x_draw),
		.y_pos 			(map_y_draw),

		//data to load into VGA
		.colour 		(map_colour),

		//map output finished signals
		.draw_done 		(draw_map_done),

		//VGA write enable
		.VGA_write 		(map_write));
	defparam
		M.X_INITIAL = 5'b0,
		M.Y_INITIAL = 5'b0;
	

	link_char p(
		.clock 			(clock),
		.reset 			(reset),

		//user commands
		.c_attack 		(c_attack),
		.c_up 			(c_up),
		.c_down			(c_down),
		.c_left 			(c_left),
		.c_right 		(c_right),

		//state signals
		.init 			(init),
		.idle 			(idle),
		.reg_action 	(gen_move),
		.apply_action	(apply_act_link),
		.draw			(draw_link),

		//collision signal , 2bit wire
		.collision		(link_collision),

		//link position coordinates
		.x_pos 			(link_x_pos),
		.y_pos 			(link_y_pos),
		.x_draw 		(link_x_draw),
		.y_draw 		(link_y_draw),

		//link facing information
		.direction		(link_direction),
		.facing			(link_facing),

		//data to load into VGA
		.colour			(link_colour),

		//VGA write enable
		.VGA_write 		(link_write),

		//link output finished signal
		.draw_done 		(draw_link_done));
		
	enemies blob_things(
		.clock 			(clock),
		.reset 			(reset),

		//state signals
		.init 			(init),
		.idle 			(idle),
		.gen_move 		(gen_move),
		.apply_move		(move_enemies),
		.draw				(draw_enemies),

		//collision signal
		.collision 		(enemy_collision),
		.hit 			(e_hit),

		//link position coordinates for movement
		.link_x_pos		(link_x_pos),
		.link_y_pos		(link_y_pos),
		
		.gen_move_done	(gen_move_done),

		//enemy position coordinates
		.enemy_1_x_pos 			(enemy_1_x_pos),
		.enemy_1_y_pos 			(enemy_1_y_pos),

		.enemy_2_x_pos 			(enemy_2_x_pos),
		.enemy_2_y_pos 			(enemy_2_y_pos),

		.enemy_3_x_pos 			(enemy_3_x_pos),
		.enemy_3_y_pos 			(enemy_3_y_pos),
		
		.x_draw 						(enemy_x_draw),
		.y_draw 						(enemy_y_draw),

		//enemy direction information
		.enemy_1_direction		(enemy_1_direction),
		.enemy_2_direction		(enemy_2_direction),
		.enemy_3_direction		(enemy_3_direction),

		//data to load into VGA
		.colour	 					(enemy_colour),

		.VGA_write 					(enemy_write),

		.draw_done 					(draw_enemies_done));
	
	multiple_collision_detector multi_cd(
		.clock 					(clock),
		.reset 					(reset),
		.init 					(init),

		//enable signal for calculations
		.collision_enable 	(check_collide),

		//input position coord for collision calculation
		.char_x 					(link_x_pos),
		.char_y	 				(link_y_pos),
		.direction_char		(link_direction),
		.facing_char			(link_facing),
		.attack 					(c_attack),

		.enemy1_x 				(enemy_1_x_pos),
		.enemy1_y 				(enemy_1_y_pos),
		.direction_enemy1		(enemy_1_direction),
			
		.enemy2_x 				(enemy_2_x_pos),
		.enemy2_y 				(enemy_2_y_pos),
		.direction_enemy2		(enemy_2_direction),
		

		.enemy3_x 				(enemy_3_x_pos),
		.enemy3_y 				(enemy_3_y_pos),
		.direction_enemy3		(enemy_3_direction),

		//output collision true,false signals
		.c_map_collision		(link_collision[0]),
		.c_e1_collision 		(link_collision[1]),
		.c_e2_collision 		(link_collision[2]),
		.c_e3_collision 		(link_collision[3]),

		.e1_map_collision 	(enemy1_collision),
		.e2_map_collision 	(enemy2_collision),
		.e3_map_collision 	(enemy3_collision),

		.e1_hit					(e1_hit),
		.e2_hit					(e2_hit),
		.e3_hit					(e3_hit),
		
		.done 					(check_collide_done));

	//sequential logic :'(
	always@(posedge clock)
	begin
		//synchronous reset
		if(reset)
		begin
			fb_wren			<= OFF;
			idle_done 		<= OFF;
			frame_counter 	<= 28'b0;
			buffer_count	<= COUNT_INITIAL;
			x_position		<= 9'b0;
			y_position 		<= 8'b0;
			fb_colour 			<= 6'b0;
			VGA_enable 		<= OFF;
			draw_vga_done	<= OFF;
		end

		//initialize registers
		else if(init)
		begin
			fb_wren			<= OFF;
			idle_done 		<= OFF;
			frame_counter 	<= 28'b0;
			buffer_count	<= COUNT_INITIAL;
			x_position		<= 9'b0;
			y_position 		<= 8'b0;
			fb_colour 			<= 6'b0;
			VGA_enable 		<= OFF;
			draw_vga_done	<= OFF;
		end

		else if((draw_map) && (!draw_map_done))
		begin
			VGA_enable 	<= OFF;
			x_position 	<= map_x_draw;
			y_position 	<= map_y_draw;
			fb_colour 		<= map_colour;
			fb_wren 	<= map_write;
		end

		//draw link state
		else if((draw_link) && (!draw_link_done))
		begin
			VGA_enable 	<= OFF;
			x_position 	<= link_x_draw;
			y_position 	<= link_y_draw;
			fb_colour 		<= link_colour;
			fb_wren 	<= link_write;
		end

		//draw enemies state
		else if((draw_enemies) && (!draw_enemies_done))
		begin
			VGA_enable 	<= OFF;
			x_position 	<= enemy_x_draw;
			y_position 	<= enemy_y_draw;
			fb_colour 		<= enemy_colour;
			fb_wren 	<= enemy_write;			
		end

		else if(draw_to_vga) 
		begin
			if(buffer_count == COUNT_INITIAL)
			begin
				buffer_count 	<= 16'b0;
				x_position		<= 9'b0;
				y_position 		<= 8'b0;
				VGA_enable 		<= OFF;
				draw_vga_done	<= OFF;
			end

			else if(buffer_count == MAX_COUNT)
			begin
				buffer_count 	<= COUNT_INITIAL;
				x_position		<= 9'b0;
				y_position 		<= 8'b0;
				VGA_enable 		<= OFF;
				draw_vga_done	<= ON;
			end

			//buffer_count is a number from 0 to MAX_COUNT
			else 
			begin
				//turn on VGA_ENABLE and set colour to fb_colour
				VGA_enable <= ON;
				//increment buffer count
				buffer_count <= buffer_count +1'b1;
				if(x_position == MAX_X_POSITION)
				begin
					x_position <= 9'b0;
					y_position <= y_position + 1'b1;
				end
				else
				begin
					x_position <= x_position + 1'b1;	
				end
			end
		end

		//once idle state is reached, 
		else if(idle)
		begin
			//reset registers in idle for next cycle
			fb_wren			<= OFF;
			buffer_count	<= COUNT_INITIAL;
			x_position		<= 9'b0;
			y_position 		<= 8'b0;
			fb_colour 			<= 6'b0;
			VGA_enable 		<= OFF;
			draw_vga_done	<= OFF;
			VGA_enable <= OFF;
			
			//the '>' is safety in case draw takes too much time
			if(frame_counter > MAX_FRAME_COUNT)
			begin
				idle_done 		<= ON;
				frame_counter 	<= 28'b0;
			end
		end
		//if out of idle state reset idle_done
		else
		begin
			idle_done 		<= OFF;

		end

		//always increment counter
		frame_counter 	<= frame_counter + 1'b1;
	end

endmodule