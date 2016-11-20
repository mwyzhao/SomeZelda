/* NOTE: THIS MODULE NEEDS A MAJOR OVERHAUL */

module datapath
	(
		input  					clock,				//CLOCK 						CLOCK_50
		input 					reset,				//RESET							SW[9]
		
		input					init,				//INITIALIZATION SIGNAL 		FROM CONTROL
		input					idle,				//IDLE SIGNAL					FROM CONTROL
		input					attack,				//ATTACK SIGNAL					FROM CONTROL
		input					up,					//MOVE UP SIGNAL				FROM CONTROL
		input					down,				//MOVE DOWN SIGNAL				FROM CONTROL
		input					left,				//MOVE LEFT SIGNAL				FROM CONTROL
		input					right,				//MOVE RIGHT SIGNAL				FROM CONTROL
		input					draw_map,			//DRAW MAP SIGNAL				FROM CONTROL 
		input 					draw_link, 			//DRAW LINK SIGNAL
		
		output 	reg		  [8:0] x_position,			//POSITION CORRDINATE X 		FOR VGA
		output  reg		  [7:0] y_position,			//POSITION COORDINATE Y			FOR VGA
		output 	reg				colour 				//DATA TO BE WRITTEN TO MEMORY 	FOR VGA
		output 	reg				VGA_enable			//WRITE ENABLE SIGNAL 			FOR VGA

		//probably don't need the commented out signals
		//output	  			init_done,			//INITIALIZATION DONE SIGNAL 	FOR CONTROL
		//output				idle_done,			//IDLE DONE SIGNAL				FOR CONTROL
		//output	  			attack_done,		//ATTACK DONE SIGNAL 			FOR CONTROL
		//output 	  			move_done,			//MOVE DONE SIGNAL 				FOR CONTROL
		output 		  			draw_map_done,		//DRAW DONE SIGNAL				FOR CONTROL
		output 					draw_link_done 		//DRAW DONE SIGNAL
	);
	
	/** parameters **/
	localparam 		ON 		= 1'b1;
					OFF 	= 1'b0;

	/** wire and register declarations go here **/
	//map signal wires
	wire map_x_pos;
	wire map_y_pos;
	wire map_colour;
	wire map_draw_done;
	wire map_write;

	//character signal wires
	wire link_x_pos;
	wire link_y_pos;
	wire link_colour;
	wire link_draw_done;
	wire link_write;

	/** module declarations go here **/
	map M(
		.clock 			(clock),
		.reset 			(reset),

		//enable signal
		.enable 		(draw_map),

		//map select
		//.map_s 		(map_s),

		//output x,y coord
		.x_pos 			(map_x_pos),
		.y_pos 			(map_y_pos),

		//data to load into VGA
		colour 			(map_colour),

		//map output finished signals
		.draw_done 		(map_draw_done),

		//VGA write enable
		.VGA_write 		(map_write));

	link_char p(
		.clock 			(clock),
		.reset 			(reset),

		//enable signal
		.init 			(init),
		.idle 			(idle),
		.attack 		(attack),
		.move_up 		(up),
		.move_down 		(down),
		.move_left 		(left),
		.move_right 	(right),
		.draw_char 		(draw),

		//collision signal
		/* how would this work?
		.collide 		(),
		*/

		//link position coord for VGA
		.link_x_draw 	(link_x_pos),
		.link_y_draw 	(link_y_pos),

		//data to load into VGA
		.cout 			(link_colour),

		//link output finished signal
		.draw_done 		(link_draw_done), 	//change this later

		//VGA write enable
		.VGA_write 		(link_write)); 	//change this as well

	/* not used for now
	enemy e1();

	enemy e2();

	enemy e3();
	*/

	/* NOTE: could potentially use one more basic module
	 * to make this more scalable.
	 * also need to look into exactly how this is
	 * going to work. */
	/*
	collision_detector cd(
		.clock 			(clock),
		.reset 			(reset),

		//enable signal for calculations
		.c_c_enable 	(),

		//input position coord for collision calculation
		.x_char 		(),
		.y_char 		(),

		.x_enemy1 		(),
		.y_enemy1 		(),

		.x_enemy2 		(),
		.y_enemy2 		(),

		//output collision true,false signals
		c_map_collision		(),
		e1_map_collision 	(),
		e2_map_collision 	(),
		c_e1_collision 		(),
		c_e2_collision 		(),
		e1_e2_collision 	(),
	 	c_attack_e1 		(),
		c_attack_e2 		());
	*/

	/** combinational logic **/
	always@(*)
	begin
		if((draw_map) && (!draw_map_done))
		begin
			x_position 	= map_x_pos;
			y_position 	= map_y_pos;
			colour 		= map_colour;
			VGA_enable 	= map_write;
		end

		else if((draw_char)&&(!draw_link_done))
		begin
			x_position 	= link_x_pos;
			y_position 	= link_y_pos;
			colour 		= link_colour;
			VGA_enable 	= link_write;
		end
	end

	//logic for multiplexing different outputs to vga and control
	/*
	always@(posedge clock)
	begin
		if(reset)
		begin
			x_position <= 8'b0;
			y_position <= 7'b0;
		end

		else if(init)
		begin
		//set all initial states here, ie. set character location to initial
		//basically does the same thing as reset but in very beginning doesnt need to reset
			x_position <= LINK_INITIAL_X;
			y_position <= LINK_INITIAL_Y;
		end
		
		else if(idle)
		begin
		//once animations or monsters are implemented in the game
		//this state lets character sit still while monsters move around
		//for now this state does nothing
		end
		
		else if(attack)
		begin
		//sets animation for attack
		//erases character and replaces it with sprite of character attacking
		end
		
		else if(up)
		begin
		//moves character one pixel up and redraws
		end
		
		else if(down)
		begin
		//moves character one pixel down and redraw
		end
		
		else if(left)
		begin
		//moves character one pixel left and redraw
		end
		
		else if(right)
		begin
		//moves character one pixel right and redraw
		end
		
		else if(draw)
		begin
		//draws entire background and then sprite
		end
	end
	*/

endmodule