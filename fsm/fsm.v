module fsm(
	data_valid, 
	reset, 
	clk,
	length_flag,
	enable,
	trellis_enable,
	current_state,
	switch,
	clr,
	trl_clr,
	mod_clr);
	
	input data_valid, reset, clk, length_flag;
	output reg enable, clr, trellis_enable, switch, trl_clr, mod_clr;
	
	output reg[2:0] current_state;
	reg[13:0] length_counter;
	
	parameter WAIT = 0;
	parameter ENCODE = 3;
	parameter TERMINATE = 2;
	parameter ENCTERM = 1;
	parameter ENCMOD = 4;

	wire[13:0] length;

	assign length = length_flag ? 13'd6 : 13'd4; //changed for testing purposes
	
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
							trl_clr <= 0;
							enable <= 1;
							current_state <= ENCODE;
							length_counter <= 0; //because buffer state 1 clock
						end
						end
				ENCODE: begin
						if (length_counter < length-1) begin
							length_counter <= length_counter + 1;
							if (length_counter == length-2) begin
								trellis_enable <= 1;
							end
						end else begin
							if (data_valid) begin
								mod_clr <= 1;
								length_counter <= 0;
								enable <= 1;
								trellis_enable <= 0;
								current_state <= ENCTERM;
								switch <= 1;
							end else begin
								length_counter <= 0;
								enable <= 0;
								trellis_enable <= 0;
								clr <= 1;
								current_state <= TERMINATE;
								switch <= 1;
							end
						end
						end
				ENCTERM: begin
						if (length_counter < 3) begin
							mod_clr <= 0;
							length_counter <= length_counter + 1;
							if (length_counter == length - 2) begin
								trellis_enable <= 1;
							end
						end else if (trellis_enable) begin
							length_counter <= 0;
							enable <= 0;
							trellis_enable <= 0;
							clr <= 1;
							current_state <= TERMINATE;
							switch <= 1;
						end else begin
							switch <= 0;
							trellis_enable <= 0;
							trl_clr <= 1;
							current_state <= ENCMOD;
						end
						end
				ENCMOD: begin
						if (length_counter < length - 2) begin
							length_counter <= length_counter + 1;
							trl_clr <= 0;
							if (length_counter == length-3) begin
								trellis_enable <= 1;
							end
						end else begin
							if (data_valid) begin
								mod_clr <= 1;
								length_counter <= 0;
								enable <= 1;
								trellis_enable <= 0;
								current_state <= ENCTERM;
								switch <= 1;
							end else begin
								length_counter <= 0;
								enable <= 0;
								trellis_enable <= 0;
								clr <= 1;
								current_state <= TERMINATE;
								switch <= 1;
							end
						end
						end
				TERMINATE: begin
						if (length_counter < 3) begin
							length_counter <= length_counter + 1;
						end else begin
							clr <= 0;
							switch <= 0;
							length_counter <= 0;
							enable <= 0;
							trellis_enable <= 0;
							trl_clr <= 1;
							current_state <= WAIT;
						end
						end
			endcase
		end
	end
	
endmodule
