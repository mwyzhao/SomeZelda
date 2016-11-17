module control(
	input				clock, 			//CLOCK 								CLOCK_50
	input				reset,			//RESET								SW[9]

	input				c_up,				//INPUT UP SIGNAL 				(KEY[3])
	input				c_down,			//INPUT DOWN SIGNAL 				(KEY[2])
	input				c_left,			//INPUT LEFT SIGNAL 				(KEY[1])
	input				c_right,			//INPUT RIGHT SIGNAL 			(KEY[0])
	
	input				init_done,		//INITIALIZATION DONE SIGNAL 	FROM DATAPATH
	input 			idle_done,
	input				attack_done,	//ATTACK DONE SIGNAL				FROM DATAPATH
	input				move_done,		//MOVE DONE SIGNAL 				FROM DATAPATH
	input				draw_done,		//DRAW DONE SIGNAL				FROM DATAPATH

	output reg 		init,				//INITIALIZATION SIGNAL			FOR DATAPATH
	output reg		idle,				//IDLE SIGNAL						FOR DATAPATH
	output reg		attack,			//ATTACK SIGNAL					FOR DATAPATH
	output reg		up,				//MOVE UP SIGNAL					FOR DATAPATH
	output reg		down,				//MOVE DOWN SIGNAL				FOR DATAPATH
	output reg		left,				//MOVE LEFT SIGNAL				FOR DATAPATH
	output reg		right,			//MOVE RIGHT SIGNAL				FOR DATAPATH
	output reg 		draw				//DRAW SIGNAL						FOR DATAPATH
	);

reg [4:0] current_state, next_state;

	//State list
	localparam 	S_INIT	 			= 3'b000,
					S_IDLE				= 3'b001,
					S_ATTACK	 			= 3'b010,
					S_MOVE_UP 			= 3'b011,
					S_MOVE_DOWN 		= 3'b100,
					S_MOVE_LEFT			= 3'b101,
					S_MOVE_RIGHT		= 3'b110,
					S_DRAW_UPDATE		= 3'b111;

	//Next state logic
	always@(*)
	begin
		case(current_state)
			S_INIT: 				next_state = init_done ? S_IDLE : S_INIT;
			S_IDLE:				begin
										if(c_up)
											next_state = S_MOVE_UP;
										else if(c_down)
											next_state = S_MOVE_DOWN;
										else if(c_left)
											next_state = S_MOVE_LEFT;
										else if(c_right)
											next_state = S_MOVE_RIGHT;
										else if(idle_done)
											next_state = S_DRAW_UPDATE;
									end
			S_ATTACK:			next_state = attack_done ? S_ATTACK : S_DRAW_UPDATE;
			S_MOVE_UP:			next_state = move_done ? S_MOVE_UP : S_DRAW_UPDATE;
			S_MOVE_DOWN: 		next_state = move_done ? S_MOVE_DOWN : S_DRAW_UPDATE;
			S_MOVE_LEFT:		next_state = move_done ? S_MOVE_LEFT : S_DRAW_UPDATE;
			S_MOVE_RIGHT:		next_state = move_done ? S_MOVE_RIGHT : S_DRAW_UPDATE;
			S_DRAW_UPDATE:		next_state = draw_done ? S_DRAW_UPDATE : S_IDLE;
			default:				next_state = S_IDLE;
		endcase
	end

	//Output logic
	always@(*)
	begin
		init 		= 1'b0;
		idle		= 1'b0;
		attack 	= 1'b0;
		up 		= 1'b0;
		down 		= 1'b0;
		left		= 1'b0;
		right		= 1'b0;
		attack 	= 1'b0;
		draw		= 1'b0;
		case(current_state)
			S_INIT:
				init 		= 1'b1;
			S_IDLE:
				idle		= 1'b1;
			S_ATTACK:
				attack 	= 1'b1;
			S_MOVE_UP:
				up 		= 1'b1;
			S_MOVE_DOWN:
				down 		= 1'b1;
			S_MOVE_LEFT:
				left 		= 1'b1;
			S_MOVE_RIGHT:
				right 	= 1'b1;
			S_DRAW_UPDATE:
				draw 		= 1'b1;
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