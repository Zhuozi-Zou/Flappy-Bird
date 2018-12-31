
module game_score(clk, resetn, 
						sp1, sp2, sp3, sp4, 
						eat1, eat2, eat3, eat4,
						score);
	input clk, resetn;
	input sp1, sp2, sp3, sp4;
	input eat1, eat2, eat3, eat4;
	output [11:0] score;
	
	reg [11:0] apple1, apple2, apple3, apple4;
	reg [11:0] pipe1, pipe2, pipe3, pipe4;
	
	assign score = apple1 + apple2 + apple3 + apple4 + pipe1 + pipe2 + pipe3 + pipe4;
	
	// score for apple 1
	always @(negedge resetn, posedge eat1)
	begin
		if (!resetn)
			apple1 <= 0;
		else if (eat1)
			apple1 <= apple1 + 1;
	end
	
	// score for apple 2
	always @(negedge resetn, posedge eat2)
	begin
		if (!resetn)
			apple2 <= 0;
		else if (eat2)
			apple2 <= apple2 + 1;
	end
	
	// score for apple 3
	always @(negedge resetn, posedge eat3)
	begin
		if (!resetn)
			apple3 <= 0;
		else if (eat3)
			apple3 <= apple3 + 1;
	end
	
	// score for apple 4
	always @(negedge resetn, posedge eat4)
	begin
		if (!resetn)
			apple4 <= 0;
		else if (eat4)
			apple4 <= apple4 + 1;
	end
	
	// score for pipe 1
	always @(negedge resetn, posedge sp1)
	begin
		if (!resetn)
			pipe1 <= 0;
		else if (sp1)
			pipe1 <= pipe1 + 1;
	end
	
	// score for pipe 2
	always @(negedge resetn, posedge sp2)
	begin
		if (!resetn)
			pipe2 <= 0;
		else if (sp2)
			pipe2 <= pipe2 + 1;
	end
	
	// score for pipe 3
	always @(negedge resetn, posedge sp3)
	begin
		if (!resetn)
			pipe3 <= 0;
		else if (sp3)
			pipe3 <= pipe3 + 1;
	end
	
	// score for pipe 4
	always @(negedge resetn, posedge sp4)
	begin
		if (!resetn)
			pipe4 <= 0;
		else if (sp4)
			pipe4 <= pipe4 + 1;
	end

endmodule 