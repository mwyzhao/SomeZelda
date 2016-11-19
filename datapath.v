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
		input					draw,				//DRAW SIGNAL					FROM CONTROL 
		
		output 			  [8:0] x_position,			//POSITION CORRDINATE X 		FOR VGA
		output  		  [7:0] y_position,			//POSITION COORDINATE Y			FOR VGA
		output 					VGA_enable			//WRITE ENABLE SIGNAL 			FOR VGA

		//probably don't need the commented out signals
		//output	  			init_done,			//INITIALIZATION DONE SIGNAL 	FOR CONTROL
		//output				idle_done,			//IDLE DONE SIGNAL				FOR CONTROL
		//output	  			attack_done,		//ATTACK DONE SIGNAL 			FOR CONTROL
		//output 	  			move_done,			//MOVE DONE SIGNAL 				FOR CONTROL
		output 		  			draw_done,			//DRAW DONE SIGNAL				FOR CONTROL
	);
	
	/*** from now on this is going to be our main datapath module that links all
		 the smaller logic and interaction modules such as
		 link_char, enemy, map_HUD, collision_detector ***/
	
	/* initializing registers might not work
	 * so resetting in init block would be
	 * better just to be sure */
	/* I'm removing all the initilizations */

	/** wire and register delcarations go here **/
	//vga enable
	wire enable;

	//character signal wires
	wire link_x_pos;
	wire link_y_pos;
	wire link_d_done;
	wire link_draw;

	assign x_position = {0,link_x_pos};
	assign y_position = {0,link_y_pos};

	/** parameters **/

	/** module declarations go here **/

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

		//link output finished signal
		.draw_done 		(draw_done), 	//change this later

		//VGA write enable
		.VGA_write 		(VGA_enable)); 	//change this as well

	/* not used for now
	enemy e1();

	enemy e2();

	enemy e3();
	*/

	/*
	map_HUD mH(
		.clock 			(clock),
		.reset 			(reset),

		//enable signals
		.draw_map 		(),
		.draw_HUD 		(),

		//map select
		//.map_s 		(),

		//map/HUD position coord for VGA
		.map_HUD_x_pos 	(),
		.map_HUD_y_pos 	(),

		//map/HUD output finished signals
		.draw_map_done 	(),
		.draw_HUD_done 	(),

		//VGA write enable
		.VGA_write 		());
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