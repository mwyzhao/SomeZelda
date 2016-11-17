/*** contains memory for map and the HUD ***/

/* control module directs map_HUD module to clear map
 * and change HUD values when draw_map or draw_hud bit is high */

/* should we hardcode the HUD values? */
/* also consider separating map and HUD into separate modules */

/* tentative module declaration */

/* 

module map_HUD(
	input clock,
	input reset,

	//enable signals from control
	input				draw_map,
	input				draw_HUD,

	//input signal from control signifying which map to draw
	/* to be implemented if and when we add more maps
	input 		  [1:0] map_s,
	*/

	//output x,y coord to manipulate VGA memory
	output reg	  [8:0] map_HUD_x_pos,
	output reg	  [7:0] map_HUD_y_pos,

	//output finished signals
	output reg			draw_map_done,
	output reg			draw_HUD_done,

	//output write enable to VGA (do we need?)
	output reg 			VGA_write
	);

	//might not be needed if we hardcode
	HUD_mem(...);

	map1_mem(...);

	map2_mem(...);

	etc.

	//registers to signal position of memory to alter redrawing
	reg		[7:0] map_x_pos;
	reg 	[6:0] map_y_pos;

	reg		[8:0] HUD_x_pos;
	reg		[7:0] HUD_y_pos;

	//counters to signify drawing is done
	reg 	[] map_count;
	reg 	[] HUD_count;

	always@(posedge clock)
	begin
		if(reset)
		begin
			map_x_pos <= 8'b0;
			map_y_pos <= 7'b0;
			HUD_x_pos <= 9'b0;
			HUD_y_pos <= 8'b0;
			map_count <=  'b0;
			HUD_count <=  'b0;
			VGA_write <= 1'b0;
		end
		else if(draw_map)
		begin
			//logic to draw map here
			...
			map_count <= map_count + 1'b1;

			if(map_count == #)
			begin
				map_count <=  'b0;
				draw_map_done <= 1'b1;
			end
		end
		else if(draw_HUD)
		begin
			//logic to draw HUD here
			...
			HUD_count <= HUD_count + 1'b1;

			if(HUD_count == #)
			begin
				HUD_count <=  'b0;
				draw_HUD_done <= 1'b1;
			end
		end
		else
		begin
			//default
		end
	end

endmodule

*/