
module over_screen(clk, resetn, enable, x, y, counter_over);
	input clk, resetn, enable;
	output reg [8:0]x;
	output reg [6:0]y;
	output counter_over;
	
	assign counter_over = ((y == 7'd119) && (x == 9'd159)) ? 1 : 0;
	
	always@(posedge clk)
	begin
		if (!resetn)
			begin
				y <= 0;
				x <= 0;
			end
		else if (x == 9'd159)
			begin
				x <= 0;
				y <= y + 1'b1;
			end
		else if (y == 7'd120)
			y <= 0;
		else if (enable)
			x <= x + 1'b1;
	end
	
endmodule 