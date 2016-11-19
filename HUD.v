/* may or may not hard code the HUD, maybe display on HEX */

module HUD(
	input clock,
	input reset,

	//enable signal from control
	input				enable,

	//signal to reset draw_done from control
	input 				draw_ack,

	//output x,y coord to manipulate VGA memory
	output reg	  [8:0] x_pos,
	output reg	  [7:0] y_pos,

	//output finished signal
	output reg			draw_done,

	//output write enable to VGA
	output reg 			VGA_write
	);

	/** parameters **/
	localparam		MAX_COUNT 	= 'b ; 					//number of pixels that must be drawn for HUD
					ON 			= 1'b1,
					OFF 		= 1'b0;

	//might not be needed if we hardcode
	HUD_mem(...);

	//counter to signify drawing is done
	reg 	[] count;

	always@(posedge clock)
	begin
		if(reset)
		begin
			x_pos <= 9'b0;
			y_pos <= 8'b0;
			count <=  'b0;
			VGA_write <= OFF;
		end

		//state to reset draw_done bit
		else if(draw_ack)
		begin
			draw_done <= OFF;
		end

		//state to draw HUD
		else if(enable)
		begin
			//check draw done here
			if(HUD_count == MAX_COUNT)
			begin
				x_pos <= 9'b0;
				y_pos <= 8'b0;
				count <=  'b0;
				VGA_write <= OFF;
				draw_done <= ON;
			end
			//draw logic here
			else
			begin
				count <= count + 1'b1;
				if(...)
					x_pos <= ...;
				if(...)
					y_pos <= ...;
			end
		end

		//when disabled
		else
		begin
			draw_done <= OFF;
		end
	end

endmodule
