/*** map memory and map draw logic ***/

module map(
	input clock,
	input reset,

	//enable signal from control
	input				enable,

	/* to be implemented if and when we add more maps
	//input signal from control signifying which map to draw
	input 		  [1:0] map_s,
	*/

	//output x,y coord to manipulate VGA memory
	output reg	  [8:0] x_pos,
	output reg	  [7:0] y_pos,

	//data to load into VGA memory
	output 		  [5:0]	colour,

	//output finished signal
	output reg			draw_done,

	//output write enable to VGA
	output  			VGA_write
	);

	/** parameters **/
	parameter 		X_INITIAL	= 5'd31,
					Y_INITIAL	= 5'd31,
					MAX_X 		= 8'd255,			//255
					MAX_COUNT 	= 16'd45055, 		//number of pixels in 256x176 (map size)
					ON 			= 1'b1,
					OFF 		= 1'b0;

	wire [16:0] address;

	/** memory modules **/
	map_mem map1(
		.address		(count),
		.clock 			(clock),
		.q				(colour));

	/* maybe one day
	map_mem map2(
		.address 		(count),
		.clock 			(clock),
		.q 				(colour));
	*/

	/** register declaractions **/
	//counters to signify drawing is done
	reg 	[15:0] count;

	/** combinational logic **/
	assign VGA_write = enable;

	/** sequential logic **/
	always@(posedge clock)
	begin
		if(reset)
		begin
			x_pos <= X_INITIAL;
			y_pos <= Y_INITIAL;
			count <= 16'b0;
			draw_done <= OFF;
		end

		/* may not need if we have default clear it
		//state to reset draw_done bit
		else if(draw_ack)
		begin
			draw_done <= OFF;
		end
		*/

		//state to draw map
		else if(enable)
		begin 
			if(count == MAX_COUNT)
			begin
				x_pos <= X_INITIAL;
				y_pos <= Y_INITIAL;
				count <= 16'b0;
				draw_done <= ON;
			end
			//draw logic here
			else
			begin
				if(x_pos == MAX_X)
				begin
					x_pos <= X_INITIAL;
					y_pos <= y_pos + 1'b1;
				end
				else
				begin
					x_pos <= x_pos + 1'b1;
				end
				count <= count + 1'b1;
			end
		end

		//when disabled
		else
		begin
			//reset to prepare for next draw cycle
			draw_done <= OFF;
		end
	end

endmodule
