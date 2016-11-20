/*** contains memory for map and the HUD ***/

/* control module directs map_HUD module to clear map
 * and change HUD values when draw_map or draw_hud bit is high */

/* should we hardcode the HUD values? */
/* also consider separating map and HUD into separate modules */

/* tentative module declaration */

module map(
	input clock,
	input reset,

	//enable signal from control
	input				enable,

	/* to be implemented if and when we add more maps
	//input signal from control signifying which map to draw
	input 		  [1:0] map_s,
	*/

	/* may not need if we have default clear it
	//signal to reset draw_done from control
	input 				draw_ack;
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
	localparam 		MAX_COUNT 	= 17'b10010110000000000, 		//number of pixels in 320*240
					MAX_X 		= 9'b100111111,					//319
					ON 			= 1'b1,
					OFF 		= 1'b0;

	wire address;

	/** memory modules **/
	map_mem map1(
		.address		(address),
		.clock 			(clock),
		.q				(colour));

	/* maybe one day
	map_mem map2(
		.address 		(count),
		.clock 			(clock),
		.q 				(colour));
	*/

	vga_address_translator map_address_translator(
		x 				(x_pos),
		y 				(y_pos),
		mem_address 	(address));

	/** register declaractions **/
	//counters to signify drawing is done
	reg 	[16:0] count;

	/** combinational logic **/
	assign VGA_write = enable;

	/** sequential logic **/
	always@(posedge clock)
	begin
		if(reset)
		begin
			x_pos <= 9'b0;
			y_pos <= 8'b0;
			count <= 17'b0;
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
				/* extra layer of safety */
				x_pos <= 9'b0;
				y_pos <= 8'b0;
				count <= 17'b0;
				draw_done <= ON;
			end
			//draw logic here
			else
			begin
				if(x_pos == MAX_X)
				begin
					x_pos <= 9'b0;
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
			/*
			x_pos <= 9'b0;
			y_pos <= 8'b0;
			count <= 16'b0;
			*/
			draw_done <= OFF;
		end
	end

endmodule
