
module project
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
		  HEX0,
		  HEX1,
		  HEX2,
		  HEX3,
		  HEX4,
		  HEX5,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input	CLOCK_50;				//	50 MHz
	input [2:0] KEY;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour, color_in;
	wire [8:0] x;
	wire [6:0] y;
	wire [15:0] data_xy;
	wire [11:0] score;
	wire writeEn, write, enable, enable_bird, in_range, counter_draw_pipes, counter_draw_apples;
	wire counter_draw_bird, counter_over;
	wire en_bird, en_apples, en_pipes, en_over, en_blank, over, up, reset_all;
	wire over_y, over_x, display_apple;
	
	assign up = KEY[2];
	
	hex_decoder hd0(score[3:0], HEX0);
	hex_decoder hd1(score[7:4], HEX1);
	hex_decoder hd2(score[11:8], HEX2);
	assign HEX3 = 7'b100_0000;
	assign HEX4 = 7'b100_0000;
	assign HEX5 = 7'b100_0000;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(write),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
	assign x = data_xy[15:7];
	assign y = data_xy[6:0];
	assign in_range = (x >= 0) && (x <= 9'd159) && (y >= 0) && (y <= 7'd119);
	assign over_y = (y >= 7'd59 && y <= 7'd61);
	assign over_x = (x >= 9'd79 && x <= 9'd81);
	assign white = over_x || over_y;
	assign colour = (en_over && white) ? 3'b111 : color_in;
	assign write = writeEn && in_range && display_apple;
    
   // Instansiate datapath
	datapath d0(
				.clk(CLOCK_50), 
				.reset(resetn), 
				.enable(enable),
				.enable_bird(enable_bird),
				.en_bird(en_bird),
				.en_apples(en_apples),
				.en_pipes(en_pipes),
				.en_over(en_over),
				.en_blank(en_blank),
				.reset_all(reset_all),
				.updown(up),
				.over(over),
				.display_apple(display_apple),
				.score(score),
				.counter_draw_pipes(counter_draw_pipes),
				.counter_draw_apples(counter_draw_apples),
				.counter_draw_bird(counter_draw_bird),
				.counter_over(counter_over),
				.data_xy(data_xy)
	);

   // Instansiate FSM control
   control c0(
				.clk(CLOCK_50), 
				.resetn(resetn), 
				.paint(~KEY[1]), 
				.counter_draw_pipes(counter_draw_pipes),
				.counter_draw_apples(counter_draw_apples),
				.counter_draw_bird(counter_draw_bird),
				.over(over),
				.counter_over(counter_over),
				.en_bird(en_bird),
				.en_apples(en_apples),
				.en_pipes(en_pipes),
				.en_over(en_over),
				.en_blank(en_blank),
				.color_in(color_in),
				.enable(enable),
				.reset_all(reset_all),
				.enable_bird(enable_bird),
				.writeEn(writeEn)
	);
    
endmodule
                

module control(
    input clk,
    input resetn,
	 input paint,
	 input counter_draw_pipes,
	 input counter_draw_apples,
	 input counter_draw_bird,
	 input over,
	 input counter_over,

	 output reg en_bird, en_apples, en_pipes, en_over, en_blank,
	 output reg [2:0] color_in,
	 output reg enable, enable_bird, reset_all,
	 output reg writeEn
    );

    reg [4:0] current_state, next_state;
	 reg reset_counter;
	 wire [19:0] c0;
	 wire frame_enable;
	 wire [3:0] f_counter;
    
    localparam  S_WAIT            = 5'd0,
                S_NOTHING         = 5'd1,
                S_DRAW_APPLES     = 5'd2,
                S_RESET_COUNTER   = 5'd3,
                S_ERASE_PIPES     = 5'd4,
					 S_UPDATE	       = 5'd5,
					 S_COUNT_FRAMES    = 5'd6,
					 S_DRAW_PIPES      = 5'd7,
					 S_DRAW_BIRD       = 5'd8,
					 S_ERASE_APPLES    = 5'd9,
					 S_ERASE_BIRD      = 5'd10, 
					 S_UPDATE_BIRD     = 5'd11,
					 S_GAME_OVER       = 5'd12,
					 S_DRAW_BLANK      = 5'd13;
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_WAIT: next_state = paint ? S_DRAW_BLANK : S_WAIT;
					 
					 S_DRAW_BLANK: next_state = (counter_over) ? S_DRAW_BIRD : S_DRAW_BLANK; 
					 
					 S_DRAW_BIRD: next_state = (counter_draw_bird) ? S_DRAW_PIPES : S_DRAW_BIRD;
					 S_DRAW_PIPES: next_state = (counter_draw_pipes) ? S_DRAW_APPLES : S_DRAW_PIPES;
                S_DRAW_APPLES: next_state = (counter_draw_apples) ? S_RESET_COUNTER : S_DRAW_APPLES;
					 
					 S_RESET_COUNTER: next_state = S_COUNT_FRAMES;
					 S_COUNT_FRAMES: next_state = (f_counter == 3) ? S_ERASE_BIRD : S_COUNT_FRAMES;
					 
					 S_ERASE_BIRD: next_state = (counter_draw_bird) ? S_ERASE_PIPES : S_ERASE_BIRD;
                S_ERASE_PIPES: next_state = (counter_draw_pipes) ? S_ERASE_APPLES : S_ERASE_PIPES;
					 S_ERASE_APPLES: next_state = (counter_draw_apples) ? S_UPDATE_BIRD : S_ERASE_APPLES;
					 
					 S_UPDATE_BIRD: next_state = (over) ? S_GAME_OVER : S_UPDATE;
					 S_UPDATE: next_state = (over) ? S_GAME_OVER : S_NOTHING;
					 S_NOTHING: next_state = (over) ? S_GAME_OVER : S_DRAW_BIRD;
					
					 S_GAME_OVER: next_state = (counter_over) ? S_WAIT : S_GAME_OVER;
            default:	next_state = S_WAIT;
        endcase
    end
	 
	 delay_counter dc0(clk, reset_counter, c0);
	 assign frame_enable = (c0 == 0) ? 1 : 0;	 
	 frame_counter fc0(frame_enable, clk, reset_counter, f_counter);
	 	 
    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        en_bird = 1'b0;
		  en_apples = 1'b0;
		  en_pipes = 1'b0;
		  writeEn = 1'b0;
		  enable = 1'b0;
		  reset_counter = resetn;
		  color_in = 3'd0;
		  enable_bird = 1'b0;
		  en_over = 1'b0;
		  en_blank = 1'b0;
		  reset_all = 1'b0;

        case (current_state)
				S_WAIT: begin 
					 reset_all = 1'b1;
					 end
				S_DRAW_BLANK: begin 
					 writeEn = 1'b1;
					 en_blank = 1'b1;
					 end
            S_DRAW_BIRD: begin
                en_bird = 1'b1;
					 writeEn = 1'b1;
					 color_in = 3'b001;
                end
				S_DRAW_PIPES: begin
                en_pipes = 1'b1;
					 writeEn = 1'b1;
					 color_in = 3'b010;
                end
				S_DRAW_APPLES: begin
                en_apples = 1'b1;
					 writeEn = 1'b1;
					 color_in = 3'b100;
                end
			   S_RESET_COUNTER: begin
					 reset_counter = 1'b0;
                end
				S_ERASE_BIRD: begin 
					 en_bird = 1'b1;
					 writeEn = 1'b1;
					 end
            S_ERASE_PIPES: begin 
					 en_pipes = 1'b1;
					 writeEn = 1'b1;
					 end
				S_ERASE_APPLES: begin 
					 en_apples = 1'b1;
					 writeEn = 1'b1;
					 end
			   S_UPDATE_BIRD: begin 
					 enable_bird = 1'b1;
					 end
				S_UPDATE: begin 
					 enable = 1'b1;
					 end
				S_GAME_OVER: begin 
					 writeEn = 1'b1;
					 en_over = 1'b1;
					 end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_WAIT;
        else
            current_state <= next_state;
    end // state_FFS
endmodule


module datapath(
    input clk,
    input reset,
	 input enable, enable_bird,
	 input en_bird,
	 input en_apples,
	 input en_pipes,
	 input en_over,
	 input en_blank,
	 input updown,
	 input reset_all,
	 
	 output over,
	 output counter_over,
	 output reg display_apple,
	 output [11:0] score,
	 output reg counter_draw_bird,
	 output reg counter_draw_pipes,
	 output reg counter_draw_apples,
    output reg [15:0] data_xy
    );
    	 
	 wire [8:0] x_pipe1, x_pipe2, x_pipe3, x_pipe4, x_apple1, x_apple2, x_apple3, x_apple4, x_over;
	 wire [6:0] y_bird, y_apple1, y_apple2, y_apple3, y_apple4, y_over;
	 wire [4:0] counter_p5;
	 wire [3:0] counter_b4, counter_a4;
	 wire [1:0] counter_a2;
	 wire [6:0] y_c1, y_c2, y_c3, y_c4, random_y;
	 wire add_y1, add_y2, add_y3, add_y4, reset_yc4, eat1, eat2, eat3, eat4;
	 wire enabley1, enabley2, enabley3, sp1, sp2, sp3, sp4, score_pipe;
	 
	 reg [6:0] y_p1, y_p2, y_p3, y_p4, y_pipe1, y_pipe2, y_pipe3, y_pipe4;
	 reg [8:0] x_b, x_p1, x_p2, x_p3, x_p4;
	 reg [2:0] state;
	 reg [8:0] x_a1, x_a2, x_a3, x_a4;
	 reg [6:0] y_b, y_a1, y_a2, y_a3, y_a4;
	 reg apple2, apple3, apple4, pipe2, pipe3, pipe4;
	 reg new_yp1, new_yp2, new_yp3, new_yp4, reset_xp, reset_cb, reset_ca, enable_randomy, resetn;
	 
	// set resetn
	always @(posedge clk)
	begin
		resetn <= (reset_all) ? 0 : reset;
	end
	 
	// check whether the game is over
	game_over go0(x_pipe1, x_pipe2, x_pipe3, x_pipe4, y_pipe1, y_pipe2, y_pipe3, y_pipe4, y_bird, over);
	
	// draw the whole screen
	over_screen os0(clk, resetn, en_over || en_blank, x_over, y_over, counter_over);
							 
	// set the score
	assign sp1 = x_pipe1 == 46;
	assign sp2 = x_pipe2 == 46;
	assign sp3 = x_pipe3 == 46;
	assign sp4 = x_pipe4 == 46;
		
	game_score gs0(clk, resetn, 
					   sp1, sp2, sp3, sp4, 
						eat1, eat2, eat3, eat4, 
						score);
	
	// shift the bird
	y_counter_dir ycd0(clk, enable_bird, resetn, updown, y_bird);
	
	// left shift pipes and apples
	lest_shift_pipe1 lsp1(clk, enable, resetn, x_pipe1);
	lest_shift_pipe2 lsp2(clk, enable, resetn, x_pipe2);
	lest_shift_pipe3 lsp3(clk, enable, resetn, x_pipe3);
	lest_shift_pipe4 lsp4(clk, enable, resetn, x_pipe4);
	
	lest_shift_apple1 lsa1(clk, enable, resetn, x_apple1);
	lest_shift_apple2 lsa2(clk, enable, resetn, x_apple2);
	lest_shift_apple3 lsa3(clk, enable, resetn, x_apple3);
	lest_shift_apple4 lsa4(clk, enable, resetn, x_apple4);
	
	// set y for pipes and apples
	random r0(resetn, enable_randomy, random_y);
	
	always @(posedge clk)
	begin
		enable_randomy <= new_yp1 || new_yp2 || new_yp3 || new_yp4;
	end
	
	always @(*)
	begin
		new_yp1 = 1'b0;
		new_yp2 = 1'b0;
		new_yp3 = 1'b0;
		new_yp4 = 1'b0;
		
		if (x_pipe1 == 9'd199)
			new_yp1 = 1'b1;
		if (x_pipe2 == 9'd199)
			new_yp2 = 1'b1;
		if (x_pipe3 == 9'd199)
			new_yp3 = 1'b1;
		if (x_pipe4 == 9'd199)
			new_yp4 = 1'b1;
	end
	
	always @(*)
	begin
		if (!resetn)
			begin
				y_pipe1 = 100;
				y_pipe2 = 100;
				y_pipe3 = 100;
				y_pipe4 = 100;			
			end
		else
			begin
				y_pipe1 = (new_yp1) ? random_y : y_pipe1;
				y_pipe2 = (new_yp2) ? random_y : y_pipe2;
				y_pipe3 = (new_yp3) ? random_y : y_pipe3;
				y_pipe4 = (new_yp4) ? random_y : y_pipe4;
			end
	end
	
	assign y_apple1 = y_pipe1 - 8;
	assign y_apple2 = y_pipe2 - 8;
	assign y_apple3 = y_pipe3 - 8;
	assign y_apple4 = y_pipe4 - 8;
	
   // coordinates of the bird for drawing
	counter4 ct40(en_bird, reset_cb, clk, counter_b4);
		
	always @(posedge clk)
	begin
		x_b <= 9'd45 + counter_b4[1:0];
		y_b <= y_bird + counter_b4[3:2];
		counter_draw_bird <= (counter_b4 == 4'b1111) ? 1 : 0;
		reset_cb <= (counter_draw_bird) ? 0 : resetn;
	end
	
	// coordinates of pipes for drawing
	counter5 ct50(en_pipes, reset_xp, clk, counter_p5);
	
	y_counter yc1(enabley1, add_y1, clk, resetn, y_pipe1, y_c1);
	y_counter yc2(enabley2, add_y2, clk, resetn, y_pipe2, y_c2);
	y_counter yc3(enabley3, add_y3, clk, resetn, y_pipe3, y_c3);
	y_counter yc4(1'b1, add_y4, clk, reset_yc4, y_pipe4, y_c4);
	
	assign add_y1 = (counter_p5 == 5'd19) ? 1 : 0;
	
	assign reset_yc4 = (counter_draw_pipes) ? 0 : resetn;
	
	assign enabley1 = (pipe2) ? 0 : 1;
	assign enabley2 = (pipe3) ? 0 : 1;
	assign enabley3 = (pipe4) ? 0 : 1;
	
	assign add_y2 = add_y1 & pipe2;
	assign add_y3 = add_y1 & pipe3;
	assign add_y4 = add_y1 & pipe4;
	
	always @(posedge clk)
	begin
		x_p1 <= x_pipe1 - counter_p5;
		x_p2 <= x_pipe2 - counter_p5;
		x_p3 <= x_pipe3 - counter_p5;
		x_p4 <= x_pipe4 - counter_p5;
		
		y_p1 <= y_pipe1 + y_c1;
		y_p2 <= y_pipe2 + y_c2;
		y_p3 <= y_pipe3 + y_c3;
		y_p4 <= y_pipe4 + y_c4;
		
		pipe2 <= (state > 0) ? 1 : 0;
		pipe3 <= (state > 1) ? 1 : 0;
		pipe4 <= (state > 2) ? 1 : 0;
		
		reset_xp <= (counter_p5 == 5'd19) ? 0 : resetn;
		counter_draw_pipes <= ((y_p4 == 7'd119) && (counter_p5 == 5'd19)) ? 1 : 0;
	end
	
	always @(posedge clk)
	begin
		if (!resetn)
			state <= 0;
		else if (state == 4)
			state <= 0;
		else if ((state == 0) && (y_p1 == 7'd119) && (counter_p5 == 5'd19))
			state <= state + 1;
		else if ((state == 1) && (y_p2 == 7'd119) && (counter_p5 == 5'd19))
			state <= state + 1;
		else if ((state == 2) && (y_p3 == 7'd119) && (counter_p5 == 5'd19))
			state <= state + 1;
		else if ((state == 3) && (y_p4 == 7'd119) && (counter_p5 == 5'd19))
			state <= state + 1;
	end
		
	// coordinates of apples for drawing
	counter2 ct20(en_apples, reset_ca, clk, counter_a2);
	counter4 ct41(en_apples, reset_ca, clk, counter_a4);
	
	always @(posedge clk)
	begin
		x_a1 <= x_apple1 - counter_a2[0];
		y_a1 <= y_apple1 + counter_a2[1];
		x_a2 <= x_apple2 - counter_a2[0];
		y_a2 <= y_apple2 + counter_a2[1];
		x_a3 <= x_apple3 - counter_a2[0];
		y_a3 <= y_apple3 + counter_a2[1];
		x_a4 <= x_apple4 - counter_a2[0];
		y_a4 <= y_apple4 + counter_a2[1];
		
		apple2 <= (counter_a4 > 4'b0011) ? 1 : 0;
		apple3 <= (counter_a4 > 4'b0111) ? 1 : 0;
		apple4 <= (counter_a4 > 4'b1011) ? 1 : 0;
		
		counter_draw_apples <= (counter_a4 == 4'b1111) ? 1 : 0;
		reset_ca <= (counter_draw_apples) ? 0 : resetn;
	end
		 
	// coordinates to be drawn
	always @(*)
	begin
		display_apple = 1;
		
		if (en_bird)
			data_xy = {x_b, y_b};
		else if (en_pipes)
			begin
				if (pipe4)
					data_xy = {x_p4, y_p4};
				else if (pipe3)
					data_xy = {x_p3, y_p3};
				else if (pipe2)
					data_xy = {x_p2, y_p2};
				else
					data_xy = {x_p1, y_p1};
			end
		else if (en_apples)
			begin
				if (apple4)
					begin
						data_xy = {x_a4, y_a4};
						if (eat4)
							display_apple = 0;
					end
				else if (apple3)
					begin
						data_xy = {x_a3, y_a3};
						if (eat3)
							display_apple = 0;
					end
				else if (apple2)
					begin
						data_xy = {x_a2, y_a2};
						if (eat2)
							display_apple = 0;
					end
				else
					begin
						data_xy = {x_a1, y_a1};
						if (eat1)
							display_apple = 0;
					end
			end
		else if (en_over || en_blank)
			data_xy = {x_over, y_over};
		else
			data_xy = 0;
	end
	
	// draw the apple or not
	display_apples da0(clk, y_bird, 
						    y_apple1, y_apple2, y_apple3, y_apple4, 
							 x_apple1, x_apple2, x_apple3, x_apple4,
							 resetn,
							 eat1, eat2, eat3, eat4);

endmodule


module counter5(en, resetn, clk, out);
	input en, resetn, clk;
	output [4:0] out;
	wire w0, w1, w2, w3;
	
	assign w0 = en & out[0];
	assign w1 = w0 & out[1];
	assign w2 = w1 & out[2];
	assign w3 = w2 & out[3];
	
	my_tff t0(en, clk, resetn, out[0]);
	my_tff t1(w0, clk, resetn, out[1]);
	my_tff t2(w1, clk, resetn, out[2]);
	my_tff t3(w2, clk, resetn, out[3]);
	my_tff t4(w3, clk, resetn, out[4]);
	
endmodule 


module counter4(en, resetn, clk, out);
	input en, resetn, clk;
	output [3:0] out;
	wire w0, w1, w2;
	
	assign w0 = en & out[0];
	assign w1 = w0 & out[1];
	assign w2 = w1 & out[2];
	
	my_tff t0(en, clk, resetn, out[0]);
	my_tff t1(w0, clk, resetn, out[1]);
	my_tff t2(w1, clk, resetn, out[2]);
	my_tff t3(w2, clk, resetn, out[3]);
	
endmodule 


module counter2(en, resetn, clk, out);
	input en, resetn, clk;
	output [1:0] out;
	wire w0;
	
	assign w0 = en & out[0];
	
	my_tff t0(en, clk, resetn, out[0]);
	my_tff t1(w0, clk, resetn, out[1]);
	
endmodule 


module my_tff(t, clk, clear_b, q);
	input clk, clear_b, t;
	output q;
	
	reg q;
	
	always @(posedge clk, negedge clear_b)
	begin
		if (clear_b == 1'b0)
			q <= 0;
		else if (t == 1'b1)
			q <= ~q;
	end
	
endmodule 


module delay_counter(clk, reset_n, q);
	input clk, reset_n;
	output q;
	reg [19:0] q;
	
	always @(posedge clk)
	begin
		if (reset_n == 1'b0)
			q <= 20'd833333;
		else
			begin
				if (q == 0)
					q <= 20'd833333;
				else
					q <= q - 1'b1;
			end
	end

endmodule


module frame_counter(enable, clk, reset_n, q);
	input enable, clk, reset_n;
	output reg [3:0] q;
	
	always @(posedge clk)
	begin
		if (reset_n == 1'b0)
			q <= 4'd0;
		else if (enable == 1'b1)
			begin
				if (q == 4'b1111)
					q <= 4'd0;
				else
					q <= q + 1'b1;
			end
	end

endmodule 


module x_counter_dir(clk, enable, resetn, updown, q);
	input clk, enable, resetn, updown;
	output reg [7:0] q;

	always@(posedge clk)
	begin
		if(!resetn)
			q <= 8'd0;
		else if(enable)
			begin
				if(updown)
					q <= q + 1'b1;
				else
					q <= q - 1'b1;
			end
	end

endmodule


module lest_shift_pipe1(clk, enable, resetn, q);
	input clk, enable, resetn;
	output reg [8:0] q;

	always@(posedge clk)
	begin
		if(!resetn)
			q <= 9'd199;
		else if(enable)
			begin
				if(q == 0)
					q <= 9'd199;
				else
					q <= q - 1'b1;
			end
	end

endmodule


module lest_shift_pipe2(clk, enable, resetn, q);
	input clk, enable, resetn;
	output reg [8:0] q;

	always@(posedge clk)
	begin
		if(!resetn)
			q <= 9'd249;
		else if(enable)
			begin
				if(q == 0)
					q <= 9'd199;
				else
					q <= q - 1'b1;
			end
	end

endmodule


module lest_shift_pipe3(clk, enable, resetn, q);
	input clk, enable, resetn;
	output reg [8:0] q;

	always@(posedge clk)
	begin
		if(!resetn)
			q <= 9'd299;
		else if(enable)
			begin
				if(q == 0)
					q <= 9'd199;
				else
					q <= q - 1'b1;
			end
	end

endmodule


module lest_shift_pipe4(clk, enable, resetn, q);
	input clk, enable, resetn;
	output reg [8:0] q;

	always@(posedge clk)
	begin
		if(!resetn)
			q <= 9'd349;
		else if(enable)
			begin
				if(q == 0)
					q <= 9'd199;
				else
					q <= q - 1'b1;
			end
	end

endmodule


module lest_shift_apple1(clk, enable, resetn, q);
	input clk, enable, resetn;
	output reg [8:0] q;

	always@(posedge clk)
	begin
		if(!resetn)
			q <= 9'd190;
		else if(enable)
			begin
				if(q == 0)
					q <= 9'd199;
				else
					q <= q - 1'b1;
			end
	end

endmodule


module lest_shift_apple2(clk, enable, resetn, q);
	input clk, enable, resetn;
	output reg [8:0] q;

	always@(posedge clk)
	begin
		if(!resetn)
			q <= 9'd240;
		else if(enable)
			begin
				if(q == 0)
					q <= 9'd199;
				else
					q <= q - 1'b1;
			end
	end

endmodule


module lest_shift_apple3(clk, enable, resetn, q);
	input clk, enable, resetn;
	output reg [8:0] q;

	always@(posedge clk)
	begin
		if(!resetn)
			q <= 9'd290;
		else if(enable)
			begin
				if(q == 0)
					q <= 9'd199;
				else
					q <= q - 1'b1;
			end
	end

endmodule


module lest_shift_apple4(clk, enable, resetn, q);
	input clk, enable, resetn;
	output reg [8:0] q;

	always@(posedge clk)
	begin
		if(!resetn)
			q <= 9'd340;
		else if(enable)
			begin
				if(q == 0)
					q <= 9'd199;
				else
					q <= q - 1'b1;
			end
	end

endmodule


module y_counter_dir(clk, enable, resetn, updown, q);
	input clk, enable, resetn, updown;
	output reg [6:0] q;
	reg [5:0] up_y;

	always@(posedge clk)
	begin
		if(!resetn)
			begin
				q <= 7'd60;
				up_y <= 0;
		   end
		else
			begin
				if(!updown && up_y == 0)
					up_y <= up_y + 3;
				if (enable)
					begin
						q <= q - up_y + 1;
						up_y <= 0;
					end
			end
	end
	
endmodule


module y_counter(enabley, enable, clk, reset_n, value, q);
	input enabley, enable, clk, reset_n;
	input [6:0] value;
	
	output reg [6:0] q;
	
	wire [6:0] max;
	assign max = 7'd119 - value;
	
	always @(posedge clk)
	begin
		if (reset_n == 1'b0)
			q <= 0;
		else if (enabley)
			if(enable == 1'b1)
			begin
				if (q == max)
					q <= 0;
				else
					q <= q + 1'b1;
			end
	end

endmodule 


module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule


module combination(CLOCK_50, KEY);
	input	CLOCK_50;	
	input [2:0] KEY;
	
	wire resetn;
	assign resetn = KEY[0];
	
	wire [2:0] colour, color_in;
	wire [8:0] x;
	wire [6:0] y;
	wire writeEn, write, enable, enable_bird, in_range, counter_draw_pipes, counter_draw_apples;
	wire counter_draw_bird, counter_over;
	wire en_bird, en_apples, en_pipes, en_over, en_blank, over, up, reset_all;
	wire [15:0] data_xy;
	wire [11:0] score;
	wire over_y, over_x, erase_apple;
	
	assign up = KEY[2];

	
	assign x = data_xy[15:7];
	assign y = data_xy[6:0];
	assign in_range = (x >= 0) && (x <= 9'd159) && (y >= 0) && (y <= 7'd119);
	assign over_y = (y >= 7'd59 && y <= 7'd61);
	assign over_x = (x >= 9'd79 && x <= 9'd81);
	assign white = over_x || over_y;
	assign colour = (en_over && white) ? 3'b111 : color_in;
	assign write = writeEn && in_range && (~erase_apple);
    
   // Instansiate datapath
	datapath d0(
				.clk(CLOCK_50), 
				.reset(resetn), 
				.enable(enable),
				.enable_bird(enable_bird),
				.en_bird(en_bird),
				.en_apples(en_apples),
				.en_pipes(en_pipes),
				.en_over(en_over),
				.en_blank(en_blank),
				.reset_all(reset_all),
				.updown(up),
				.over(over),
				.score(score),
				.erase_apple(erase_apple),
				.counter_draw_pipes(counter_draw_pipes),
				.counter_draw_apples(counter_draw_apples),
				.counter_draw_bird(counter_draw_bird),
				.counter_over(counter_over),
				.data_xy(data_xy)
	);

   // Instansiate FSM control
   control c0(
				.clk(CLOCK_50), 
				.resetn(resetn), 
				.paint(~KEY[1]), 
				.counter_draw_pipes(counter_draw_pipes),
				.counter_draw_apples(counter_draw_apples),
				.counter_draw_bird(counter_draw_bird),
				.over(over),
				.counter_over(counter_over),
				.en_bird(en_bird),
				.en_apples(en_apples),
				.en_pipes(en_pipes),
				.en_over(en_over),
				.en_blank(en_blank),
				.color_in(color_in),
				.enable(enable),
				.reset_all(reset_all),
				.enable_bird(enable_bird),
				.writeEn(writeEn)
	);
	
endmodule 