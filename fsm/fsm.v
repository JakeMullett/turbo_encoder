module fsm(
	data_valid, 
	reset, 
	clk,
	length_flag,
	enable,
	trellis_enable,
	current_state,
	switch,
	clr);
	
	input data_valid, reset, clk, length_flag;
	output reg enable, clr, trellis_enable, switch;
	
	output reg[2:0] current_state;
	reg[13:0] length_counter;
	
	parameter WAIT = 0;
	parameter ENCODE = 3;
	parameter TERMINATE = 2;

	wire[13:0] length;

	assign length = length_flag ? 13'd6000 : 13'd1000;
	
	initial begin
		length_counter <= 0;
		current_state <= WAIT;
		enable <= 0;
		trellis_enable <= 0;
		switch <= 0;
	end
	
	always @(posedge clk) begin
		if (reset) begin
			length_counter <= 0;
			current_state <= WAIT;
			enable <= 0;
			trellis_enable <= 0;
			switch <= 0;
			clr <= 1;
		end else begin
			case (current_state)
				WAIT: begin
						if (data_valid) begin
							clr <= 0;
							enable <= 1;
							current_state <= ENCODE;
							length_counter <= 0; //because buffer state 1 clock
						end
						end
				ENCODE: begin
						if (length_counter < length) begin
							length_counter <= length_counter + 1;
						end else begin
							length_counter <= 0;
							enable <= 0;
							trellis_enable <= 1;
							clr <= 1;
							current_state <= TERMINATE;
							switch <= 1;
						end
						end
				TERMINATE: begin
						if (length_counter == 1) begin
							switch <= 0;
							clr <= 1;
						end
						if (length_counter < 4) begin
							length_counter <= length_counter + 1;
						end else begin
							length_counter <= 0;
							enable <= 0;
							trellis_enable <= 0;
							current_state <= WAIT;
						end
						end
			endcase
		end
	end
	
endmodule
