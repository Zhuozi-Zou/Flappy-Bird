
module game_over(x_pipe1, x_pipe2, x_pipe3, x_pipe4, 
					  y_pipe1, y_pipe2, y_pipe3, y_pipe4, 
					  y_bird, 
					  over);
	input [8:0] x_pipe1, x_pipe2, x_pipe3, x_pipe4;
	input [6:0] y_pipe1, y_pipe2, y_pipe3, y_pipe4, y_bird;
	output over;

	wire bound, p1a, p1l, p2a, p2l, p3a, p3l, p4a, p4l, boom;
	
	assign bound = y_bird <= 0 || y_bird >= 7'd116;
	
	assign p1a = ((y_bird + 5) > y_pipe1) && (44 < x_pipe1) && (68 > x_pipe1);
	assign p2a = ((y_bird + 5) > y_pipe2) && (44 < x_pipe2) && (68 > x_pipe2);
	assign p3a = ((y_bird + 5) > y_pipe3) && (44 < x_pipe3) && (68 > x_pipe3);
	assign p4a = ((y_bird + 5) > y_pipe4) && (44 < x_pipe4) && (68 > x_pipe4);
	
	assign p1l = ((y_bird + 5) > y_pipe1) && (x_pipe1 == 68);
	assign p2l = ((y_bird + 5) > y_pipe2) && (x_pipe2 == 68);
	assign p3l = ((y_bird + 5) > y_pipe3) && (x_pipe3 == 68);
	assign p4l = ((y_bird + 5) > y_pipe4) && (x_pipe4 == 68);
	
	assign boom = bound || p1a || p1l || p2a || p2l || p3a || p3l || p4a || p4l;
	
	assign over = (boom) ? 1 : 0;

endmodule 