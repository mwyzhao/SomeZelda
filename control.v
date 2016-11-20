/* NOTE: THIS MODULE NEEDS A MAJOR OVERHAUL */

module control(
	input			clock, 			//CLOCK 						CLOCK_50
	input			reset,			//RESET							SW[9]

	input			c_up,			//INPUT UP SIGNAL 				KEY[3]
	input			c_down,			//INPUT DOWN SIGNAL 			KEY[2]
	input			c_left,			//INPUT LEFT SIGNAL 			KEY[1]
	input			c_right,		//INPUT RIGHT SIGNAL 			KEY[0]
	
	//may or may not need any of this, leaning towards may not
	//input			init_done,		//INITIALIZATION DONE SIGNAL 	FROM DATAPATH
	//input			idle_done,
	//input			attack_done,	//ATTACK DONE SIGNAL			FROM DATAPATH
	//input			move_done,		//MOVE DONE SIGNAL 				FROM DATAPATH
	input			draw_map_done,	//DRAW DONE SIGNAL				FROM DATAPATH
	input 			draw_link_done, //DRAW DONE SIGNAL 				FROM DATAPATH

	output reg 		init,			//INITIALIZATION SIGNAL			FOR DATAPATH
	output reg		idle,			//IDLE SIGNAL					FOR DATAPATH
	output reg		attack,			//ATTACK SIGNAL					FOR DATAPATH
	output reg		up,				//MOVE UP SIGNAL				FOR DATAPATH
	output reg		down,			//MOVE DOWN SIGNAL				FOR DATAPATH
	output reg		left,			//MOVE LEFT SIGNAL				FOR DATAPATH
	output reg		right,			//MOVE RIGHT SIGNAL				FOR DATAPATH
	output reg 		draw_map,		//DRAW MAP SIGNAL				FOR DATAPATH
	output reg 		draw_link 		//DRAW LINK SIGNAL 				FOR DATAPATH
	);

	reg [4:0] current_state, next_state;

	//State list and parameters
	localparam 		S_INIT 				= 4'b0000,
					S_IDLE				= 4'b0001,
					S_ATTACK	 		= 4'b0010,
					S_MOVE_UP 			= 4'b0011,
					S_MOVE_DOWN 		= 4'b0100,
					S_MOVE_LEFT			= 4'b0101,
					S_MOVE_RIGHT		= 4'b0110,
					S_DRAW_MAP			= 4'b0111,
					S_DRAW_LINK 		= 4'b1000,
					//S_DRAW_ENEMY 		= 4'b1001,
					ON 					= 1'b1,
					OFF 				= 1'b0;


	//Next state logic
	always@(*)
	begin
		case(current_state)
			S_INIT: 			next_state = S_DRAW_MAP;				//init_done ? S_DRAW_UPDATE : S_INIT;
			S_IDLE:				begin
									if(attack)
										next_state = S_ATTACK;
									else if(c_up)
										next_state = S_MOVE_UP;
									else if(c_down)
										next_state = S_MOVE_DOWN;
									else if(c_left)
										next_state = S_MOVE_LEFT;
									else if(c_right)
										next_state = S_MOVE_RIGHT;
									else 								//if(idle_done)
										next_state = S_IDLE;			//S_DRAW_UPDATE;
								end
			//S_ATTACK:			next_state = attack_done ? S_ATTACK : S_DRAW_UPDATE;
			S_MOVE_UP:			next_state = S_DRAW_MAP;				//move_done ? S_MOVE_UP : S_DRAW_UPDATE;
			S_MOVE_DOWN: 		next_state = S_DRAW_MAP;				//move_done ? S_MOVE_DOWN : S_DRAW_UPDATE;
			S_MOVE_LEFT:		next_state = S_DRAW_MAP;				//move_done ? S_MOVE_LEFT : S_DRAW_UPDATE;
			S_MOVE_RIGHT:		next_state = S_DRAW_MAP;				//move_done ? S_MOVE_RIGHT : S_DRAW_UPDATE;
			S_DRAW_MAP:			next_state = draw_map_done ? S_DRAW_LINK : S_DRAW_MAP;
			S_DRAW_LINK: 		next_state = draw_link_done ? S_IDLE : S_DRAW_LINK;
			default:			next_state = S_IDLE;
		endcase
	end

	//Output logic
	always@(*)
	begin
		init 		= OFF;
		idle		= OFF;
		attack 		= OFF;
		up 			= OFF;
		down 		= OFF;
		left		= OFF;
		right		= OFF;
		attack 		= OFF;
		draw_map 	= OFF;
		draw_link	= OFF;
		case(current_state)
			S_INIT:
				init 		= ON;
			S_IDLE:
				idle		= ON;
			S_ATTACK:
				attack 		= ON;
			S_MOVE_UP:
				up 			= ON;
			S_MOVE_DOWN:
				down 		= ON;
			S_MOVE_LEFT:
				left 		= ON;
			S_MOVE_RIGHT:
				right 		= ON;
			S_DRAW_MAP:
				draw_map	= ON;
			S_DRAW_LINK:
				draw_link 	= ON;
		endcase
	end

	//current_state registers
	always@(posedge clock)
	begin
		if(reset)
			current_state <= S_INIT;
		else
			current_state <= next_state;
	end

endmodule