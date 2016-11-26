module translate256x176(input [7:0]x, input [7:0] y, output reg[15:0] mem_address);
	always@(*)begin
		mem_address = ({1'b0, y, 8'd0} + x);
	end
endmodule