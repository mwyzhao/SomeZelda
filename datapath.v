module datapath(
	input  					clock,				//CLOCK 								CLOCK_50
	input 					reset,				//RESET								SW[9]
	
	input						init,					//INITIALIZATION SIGNAL 		FROM CONTROL
	input						idle,					//IDLE SIGNAL						FROM CONTROL
	input						attack,				//ATTACK SIGNAL					FROM CONTROL
	input						up,					//MOVE UP SIGNAL					FROM CONTROL
	input						down,					//MOVE DOWN SIGNAL				FROM CONTROL
	input						left,					//MOVE LEFT SIGNAL				FROM CONTROL
	input						right,				//MOVE RIGHT SIGNAL				FROM CONTROL
	input						draw,					//DRAW SIGNAL						FROM CONTROL 
	
	output reg		[7:0] x_position,			//POSITION CORRDINATE X 		FOR VGA
	output reg 		[6:0] y_position,			//POSITION COORDINATE Y			FOR VGA

	output reg  			init_done,			//INITIALIZATION DONE SIGNAL 	FOR CONTROL
	output reg				idle_done,			//IDLE DONE SIGNAL				FOR CONTROL
	output reg  			attack_done,		//ATTACK DONE SIGNAL 			FOR CONTROL
	output reg  			move_done,			//MOVE DONE SIGNAL 				FOR CONTROL
	output reg  			draw_done			//DRAW DONE SIGNAL				FOr CONTROL
	);
	
//	reg		[]	init_count;
//	reg		[]	attack_count;
//	reg		[] move_count;
//	reg 		[] draw_count;
	
	
	//initialize all registers
	initial x_position	= 8'b0;
	initial y_position	= 7'b0;
	
	initial init_done 	= 1'b0;
	initial attack_done 	= 1'b0;
	initial move_done 	= 1'b0;
	initial draw_done 	= 1'b0;
	
//	initial init_count 	= 'b0;
//	initial attack_count = 'b0;
//	initial move_count 	= 'b0;
//	initial draw_count 	= 'b0;

	//always block for init
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

endmodule