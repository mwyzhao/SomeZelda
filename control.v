/*** control module to control fsm state logic ***/

module control(
	input			clock, 				//CLOCK 						CLOCK_50
	input			reset,				//RESET							SW[9]

	input			idle_done, 			//FRAME DONE SIGNAL				FROM DATAPATH
	//input 		gen_move_done, 		//MOVEMENT DONE SIGNAL 			FROM DATAPATH
	input 		check_collide_done, //COLLIDE DONE SIGNAL 			FROM DATAPATH
	input			gen_move_done,
	input			draw_map_done,		//DRAW DONE SIGNAL				FROM DATAPATH
	input 			draw_link_done, 	//DRAW DONE SIGNAL 				FROM DATAPATH
	input 			draw_enemies_done, 	//DRAW DONE SIGNAL 				FROM DATAPATH

	output 	[3:0] states,
	
	output reg 		init,				//INITIALIZATION SIGNAL			FOR DATAPATH
	output reg		idle,				//IDLE SIGNAL					FOR DATAPATH
	output reg 		gen_move, 			//MOVEMENT SIGNAL 				FOR DATAPATH
	output reg 		check_collide,		//CHECK COLLIDE SIGNAL 			FOR DATAPATH
	output reg 		apply_act_link,		//APPLY LINK ACTION 			FOR DATAPATH
	output reg 		move_enemies, 		//APPLY ENEMY MOVEMENT 			FOR DATAPATH
	output reg 		draw_map,			//DRAW MAP SIGNAL				FOR DATAPATH
	output reg 		draw_link, 			//DRAW LINK SIGNAL 				FOR DATAPATH
	output reg 		draw_enemies 		//DRAW ENEMY SIGNAL 			FOR DATAPATH
	);

	//State list and parameters
	localparam 		S_INIT 				= 4'b0000, 		//INITIALIZE ALL REGISTERS
					S_IDLE				= 4'b0001, 		//WAIT FOR USER INPUT UNTIL END OF TIMER
					S_GEN_MOVEMENT 		= 4'b0010, 		//TAKE USER INPUT AND GENERATE ENEMY MOVEMENT 
					S_CHECK_COLLIDE 	= 4'b0011, 		//CHECK FOR COLLISION USING GENERATED MOVEMENT
					S_LINK_ACTION		= 4'b0100, 		//APPLY USER INPUT ACTION
					S_MOVE_ENEMIES	 	= 4'b0101, 		//APPLY ENEMY MOVEMENT
					S_DRAW_MAP			= 4'b0110, 		//DRAW MAP
					S_DRAW_LINK 		= 4'b0111, 		//DRAW USER CHARACTER
					S_DRAW_ENEMIES 		= 4'b1000, 		//DRAW ENEMIES
					S_TEST 				= 4'b1001,
					ON 					= 1'b1,
					OFF 				= 1'b0;

	//State register declarations
	reg [3:0] current_state, next_state;
	assign states = current_state;

	//Next state logic
	always@(*)
	begin
		case(current_state)
			S_INIT: 				next_state = S_DRAW_MAP;
			S_IDLE:					next_state = idle_done ? S_GEN_MOVEMENT : S_IDLE;
			S_GEN_MOVEMENT: 		next_state = gen_move_done ? S_CHECK_COLLIDE : S_GEN_MOVEMENT;
			S_CHECK_COLLIDE:	 	next_state = check_collide_done? S_LINK_ACTION : S_CHECK_COLLIDE;
			S_LINK_ACTION:			next_state = S_MOVE_ENEMIES;
			S_MOVE_ENEMIES: 		next_state = S_DRAW_MAP;
			S_DRAW_MAP:				next_state = draw_map_done ? S_DRAW_LINK : S_DRAW_MAP;
			S_DRAW_LINK: 			next_state = draw_link_done ? S_DRAW_ENEMIES : S_DRAW_LINK;
			S_DRAW_ENEMIES:			next_state = draw_enemies_done ? S_IDLE : S_DRAW_ENEMIES;
			S_TEST: 					next_state = S_TEST;
			default:				next_state = S_IDLE;
		endcase
	end

	//Datapath control signals
	always@(*)
	begin
		//reset to default at beginning of every change
		init 			= OFF;
		idle			= OFF;
		gen_move		= OFF;
		check_collide 	= OFF;
		apply_act_link	= OFF;
		move_enemies	= OFF;
		draw_map 		= OFF;
		draw_link		= OFF;
		draw_enemies 	= OFF;

		case(current_state)
			S_INIT:
				init 			= ON;
			S_IDLE:
				idle			= ON;
			S_GEN_MOVEMENT:
				gen_move		= ON;
			S_CHECK_COLLIDE:
				check_collide	= ON;
			S_LINK_ACTION:
				apply_act_link	= ON;
			S_MOVE_ENEMIES:
				move_enemies	= ON;
			S_DRAW_MAP:
				draw_map		= ON;
			S_DRAW_LINK:
				draw_link 		= ON;
			S_DRAW_ENEMIES:
				draw_enemies 	= ON;
		endcase
	end

	//current_state register logic
	always@(posedge clock)
	begin
		if(reset)
			current_state <= S_INIT;
		else
			current_state <= next_state;
	end

endmodule