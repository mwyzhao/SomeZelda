module translateLinkSprite64x48(input [5:0]x, input [5:0] y, output reg[11:0]mem_address);
	always@(*)begin
		mem_address = ({1'b0, y, 6'd0} + x);
	end
endmodule