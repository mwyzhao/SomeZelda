/*** implementation of character movement logic based on user inputs ***/

/

/*

module link_char(
	input clock,
	input reset,

	//enable signal from control
	input 				move_char,

	//position of memory to be changed as link is updated into memory
	//8 and 7 bits as it will never exceed map bounds (256x176)
	output reg 	  [7:0] link_x_draw,
	output reg 	  [6:0] link_y_draw,

	//output finished signal
	output reg 			draw_done,

	//output write enable to VGA (do we need this?)
	output reg 			VGA_write
	);

	/** position registers for player character link **/
	
	//link_pos is the x,y coord of link's character sprite (top left corner of image)
	reg 	[7:0] x_pos;
	reg		[6:0] y_pos;
	
	//counter for when link is finised drawing
	reg 	[] link_count;

	always@(posedge clock)
	begin
		if(reset)
		begin
			//resets
		end
		else if(init)
		begin
			//initialize first time character appears on map
			x_pos <= 8'b********;
			y_pos <= 7'b*******;
			link_count <=  'b0;
		end
		else if(move_char)
			//do not need to implement erase if redrawing entire map
			//draw here
			...
			link_count <= link_count + 1'b1;

			if(link_count == #)
			begin
				link_count <=  'b0;
				draw_done <= 1'b1;
			end
		end
		else
		begin
			//default
		end
	end

endmodule

*/