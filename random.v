
module random(resetn, enable, q);
	input resetn, enable;
	output [6:0] q;
	
	wire [3:0] ran4;
	wire [5:0] ran6;
	
	assign q = ran4 + ran6 + 20;
	
	random4 r4(enable, resetn, ran4);
	random6 r6(enable, resetn, ran6);

endmodule


module random4(clk, reset_n, q);
	input clk, reset_n;
	output [3:0] q;

	dff_1 r1(clk, reset_n, q[2]^q[3], q[0]);
	dff_2 r2(clk, reset_n, q[0], q[1]);
	dff_2 r3(clk, reset_n, q[1], q[2]);
	dff_2 r4(clk, reset_n, q[2], q[3]);

endmodule


module random6(clk, reset_n, q);
	input clk, reset_n;
	output [5:0] q;
	wire qq1;

	assign qq1 = q[5]^q[3];

	dff_1 r5(clk, reset_n, qq1^q[2], q[0]);
	dff_2 r6(clk, reset_n, q[0], q[1]);
	dff_2 r7(clk, reset_n, q[1], q[2]);
	dff_2 r8(clk, reset_n, q[2], q[3]);
	dff_2 r9(clk, reset_n, q[3], q[4]);
	dff_2 r10(clk, reset_n, q[4], q[5]);

endmodule


module dff_1(clk, reset_n, data_in, q);
	input clk, reset_n, data_in;
	output reg q;

	always @(posedge clk, negedge reset_n)
		begin
			if (reset_n == 0)
				q <= 1'b0;
			else 
				q <= data_in;
		end

endmodule


module dff_2(clk, reset_n, data_in, q);
	input clk, reset_n, data_in;
	output reg q;

	always @(posedge clk, negedge reset_n)
		begin
			if (reset_n == 0)
				q <= 1'b1;
			else
				q <= data_in;
		end

endmodule
