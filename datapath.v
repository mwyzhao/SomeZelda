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
	
	output reg		[8:0] x_position,	//POSITION CORRDINATE X 		FOR VGA
	output reg		[7:0] y_position,	//POSITION COORDINATE Y			FOR VGA
	output reg		[5:0] colour, 		//DATA TO BE WRITTEN TO MEMORY 	FOR VGA
	output reg		VGA_enable,			//WRITE ENABLE SIGNAL 			FOR VGA

	//probably don't need the commented out signals
	output reg		idle_done,			//IDLE DONE SIGNAL				FOR CONTROL
	//output 		gen_move_done, 		//MOVEMENT DONE SIGNAL 			FOR CONTROL
	//output 		check_collide_done, //COLLIDE DONE SIGNAL 			FOR CONTROL
	output 		  	draw_map_done,		//DRAW DONE SIGNAL				FOR CONTROL
	output 			draw_link_done, 		//DRAW DONE SIGNAL 				FOR CONTROL
	output 			draw_enemies_done 	//DRAW DONE SIGNAL 				FOR CONTROL
	);
	
	/** parameters **/
	parameter 	MAX_FRAME_COUNT = 24'd1666666, 	//count for for 30 fps 50MHz/30
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
	wire map_draw_done;
	wire map_write;

	//character signal wires
	wire [8:0] link_x_pos;
	wire [7:0] link_y_pos;
	wire [8:0] link_x_draw;
	wire [7:0] link_y_draw;
	wire [2:0] link_direction;
	wire [2:0] link_facing;
	wire [5:0] link_colour;
	wire [1:0] link_collision;
	wire link_draw_done;
	wire link_write;

	//enemy signal wires
	wire [8:0] enemy_x_pos;
	wire [7:0] enemy_y_pos;
	wire [8:0] enemy_x_draw;
	wire [7:0] enemy_y_draw;
	wire [2:0] enemy_direction;
	wire [2:0] enemy_facing;
	wire [5:0] enemy_colour;
	wire enemy_collision;
	wire enemy_draw_done;
	wire enemy_write;

	//frame counter limits actions to 50Hz
	//21 bits for overflow safety
	reg  [23:0] frame_counter;

	/** module declarations go here **/
	map M(
		.clock 			(clock),
		.reset 			(reset),

		//enable signal
		.enable 		(draw_map),

		//map select
		//.map_s 		(map_s),

		//output x,y coord
		.x_pos 			(map_x_draw),
		.y_pos 			(map_y_draw),

		//data to load into VGA
		.colour 		(map_colour),

		//map output finished signals
		.draw_done 		(draw_map_done),

		//VGA write enable
		.VGA_write 		(map_write));

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

		//link output finished signal
		.draw_done 		(draw_link_done),

		//VGA write enable
		.VGA_write 		(link_write));

	single_enemy blob_things(
		.clock 			(clock),
		.reset 			(reset),

		//state signals
		.init 			(init),
		.idle 			(idle),
		.gen_move 		(gen_move),
		.apply_move		(move_enemies),
		.draw			(draw_enemies),

		//collision signal
		.collision 		(enemy_collision),

		//link position coordinates for movement
		.link_x_pos		(link_x_pos),
		.link_y_pos		(link_y_pos),

		//enemy position coordinates
		.x_pos 			(enemy_x_pos),
		.y_pos 			(enemy_y_pos),
		.x_draw 		(enemy_x_draw),
		.y_draw 		(enemy_y_draw),

		//enemy direction information
		.direction		(enemy_direction),
		.facing 		(enemy_facing),

		//data to load into VGA
		.colour	 		(enemy_colour),

		.draw_done 		(draw_enemies_done),

		.VGA_write 		(enemy_write));
	
	collision_detector cd(
		.clock 				(clock),
		.reset 				(reset),

		//enable signal for calculations
		.collision_enable 	(check_collide),

		//input position coord for collision calculation
		.char_x 				(link_x_pos),
		.char_y	 			(link_y_pos),
		.direction_char	(link_direction),
		.facing_char		(link_facing),

		.enemy1_x 			(enemy_x_pos),
		.enemy1_y 			(enemy_y_pos),
		.direction_enemy1	(enemy_direction),
		.facing_enemy1		(enemy_facing),

		//output collision true,false signals
		.c_map_collision		(link_collision[0]),
		.c_e1_collision 		(link_collision[1])
		.e1_map_collision 	(enemy_collision),);

	/** combinational logic **/
	always@(*)
	begin
		/* this combinational always block multiplexes the correct
		   outputs to the VGA for the draw states defined in control */
		if(reset)
		begin
			x_position 		<= 9'b0;
			y_position 		<= 8'b0;
			colour 			<= 6'b0;
			VGA_enable 		<= OFF;
		end
			
		//draw map state
		else if((draw_map) && (!draw_map_done))
		begin
			x_position 	= map_x_draw;
			y_position 	= map_y_draw;
			colour 		= map_colour;
			VGA_enable 	= map_write;
		end

		//draw link state
		else if((draw_link) && (!draw_link_done))
		begin
			x_position 	= link_x_draw;
			y_position 	= link_y_draw;
			colour 		= link_colour;
			VGA_enable 	= link_write;
		end

		//draw enemies state
		else if((draw_enemies) && (!draw_enemies_done))
		begin
			x_position 	= enemy_x_draw;
			y_position 	= enemy_y_draw;
			colour 		= enemy_colour;
			VGA_enable 	= enemy_write;			
		end

		//default
		else
		begin
			x_position 	= 9'b0;
			y_position 	= 8'b0;
			colour 		= 6'b0;
			VGA_enable 	= OFF;
		end
	end

	//sequential logic
	always@(posedge clock)
	begin
		//synchronous reset
		if(reset)
		begin
			idle_done 		<= OFF;
			frame_counter 	<= 24'b0;
		end

		//initialize registers
		else if(init)
		begin
			idle_done 		<= OFF;
			frame_counter 	<= 24'b0;
		end

		//once idle state is reached, 
		if(idle)
		begin
			//the '>' is safety in case draw takes too much time
			if(frame_counter > MAX_FRAME_COUNT)
			begin
				idle_done 		<= ON;
				frame_counter 	<= 24'b0;
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