module fsm(
	data_valid, 
	reset, 
	clk,
	length,
	enable,
	clr);
	
	input data_valid, reset, clk;
	input[16:0] length;
	output reg enable, clr;
	
	reg[4:0] current_state, next_state;
	reg[16:0] length_counter;
	
	initial begin
		enable <= 0;
		clr <= 0;
		length_counter <= 0;
	end
	
	parameter INIT = 0;
	parameter WAIT = 1;
	parameter ENCODE = 2;
	parameter TERMINATE = 3;
	parameter BUFFER = 4;
	
	always @(reset) begin
		enable <= 0;
		clr <= 0;
		length_counter <= 0;
	end
	
	always @(posedge clk) begin
		case (current_state)
			INIT: begin
					clr <= 1;
					next_state <= WAIT;
					current_state <= BUFFER;
					end
			WAIT: begin
					clr <= 1;
					next_state <= WAIT;
					current_state <= BUFFER;
					end
			ENCODE: begin
					clr <= 0;
					enable <= 1;
					if (length_counter < length) begin
						length_counter <= length_counter + 1;
					end else begin
						length_counter <= 0;
						next_state <= TERMINATE;
						current_state <= BUFFER;
					end
					
					end
			TERMINATE: begin
					enable <= 0;
					clr <= 0;
					next_state <= INIT;
					current_state <= BUFFER;
					end
			BUFFER: begin
					current_state <= next_state;
					end
		endcase
	end
	
	
endmodule
