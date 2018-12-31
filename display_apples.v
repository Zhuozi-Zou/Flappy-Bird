
module display_apples(clk, y_bird, 
						    y_apple1, y_apple2, y_apple3, y_apple4, 
							 x_apple1, x_apple2, x_apple3, x_apple4,
							 resetn,
							 eat1, eat2, eat3, eat4);
							 
	input [8:0] x_apple1, x_apple2, x_apple3, x_apple4;
	input [6:0] y_apple1, y_apple2, y_apple3, y_apple4, y_bird;
	input resetn, clk;
	output reg eat1, eat2, eat3, eat4;
	
	wire a1, a2, a3, a4;
	wire w0, w1, w2, w3, w4, w5, w6, w7;
	
	assign w0 = (eat1 == 0) && ((y_bird + 5) > y_apple1) && ((y_bird - 3) < y_apple1);
	assign w1 = (44 < x_apple1) && (50 > x_apple1);
	assign w2 = (eat2 == 0) && ((y_bird + 5) > y_apple2) && ((y_bird - 3) < y_apple2);
	assign w3 = (44 < x_apple2) && (50 > x_apple2);
	assign w4 = (eat3 == 0) && ((y_bird + 5) > y_apple3) && ((y_bird - 3) < y_apple3);
	assign w5 = (44 < x_apple3) && (50 > x_apple3);
	assign w6 = (eat4 == 0) && ((y_bird + 5) > y_apple4) && ((y_bird - 3) < y_apple4);
	assign w7 = (44 < x_apple4) && (50 > x_apple4);

	assign a1 = w0 & w1;
	assign a2 = w2 & w3;
	assign a3 = w4 & w5;
	assign a4 = w6 & w7;
	
	always @(posedge clk)
	begin
		if (!resetn)
			begin
				eat1 <= 0;
				eat2 <= 0;
				eat3 <= 0;
				eat4 <= 0;
			end
		else
			begin
				if (a1)
					eat1 <= eat1 + 1;
				else if (a2)
					eat2 <= eat2 + 1;
				else if (a3)
					eat3 <= eat3 + 1;
				else if (a4)
					eat4 <= eat4 + 1;
					
				if (x_apple1 == 170)
					eat1 <= 0;
				if (x_apple2 == 170)
					eat2 <= 0;
				if (x_apple3 == 170)
					eat3 <= 0;
				if (x_apple4 == 170)
					eat4 <= 0;
			end
	end

endmodule 