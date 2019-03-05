module fsm(
	data_valid, 
	reset, 
	clk,
	length,
	enable,
	trellis_enable,
	current_state,
	clr);
	
	input data_valid, reset, clk;
	input[8:0] length;
	output reg enable, clr, trellis_enable;
	
	output reg[2:0] current_state;
	reg[2:0] next_state;
	reg[8:0] length_counter;
	
	parameter INIT = 1;
	parameter WAIT = 0;
	parameter ENCODE = 3;
	parameter TERMINATE = 2;
	parameter BUFFER = 7;
	
	initial begin
		length_counter <= 0;
		current_state <= WAIT;
		length_counter <= 0;
		enable <= 0;
	end
	
	always @(posedge clk) begin
		if (reset) begin
			length_counter <= 0;
			current_state <= WAIT;
			next_state <= WAIT;
			length_counter <= 0;
			enable <= 0;
		end else begin
			case (current_state)
//				INIT: begin
//						clr <= 1;
//						enable <= 0;
//						trellis_enable <= 0;
//						next_state <= WAIT;
//						current_state <= BUFFER;
//						end
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
							current_state <= TERMINATE;
						end
						end
				TERMINATE: begin
						if (length_counter < 4) begin
							length_counter <= length_counter + 1;
						end else begin
							length_counter <= 0;
							enable <= 0;
							trellis_enable <= 0;
							current_state <= WAIT;
							clr <= 1;
						end
						end
				BUFFER: begin
						current_state <= next_state;
						end
			endcase
		end
	end
//	
//	assign clr = current_state == WAIT;
//	and enand(enable, current_state[0], current_state[1]);
//	assign trellis_enable = current_state == TERMINATE;
	
endmodule
