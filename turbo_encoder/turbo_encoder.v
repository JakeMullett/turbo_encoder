module turbo_encoder(clk, rst, length, data_valid,ck, ckp, xk, zk, zkp, look_now, length_out, currstate);
	input clk, rst, data_valid, ck, ckp, length;
	output xk, zk, zkp, look_now, length_out;
	output [2:0] currstate;

	wire clear, trl_clr, switch, trl_enable, enc_enable, mod_clr;
	wire [2:0] dff_q, dff_p, currstate;

	wire xk_enc, zk_enc, zkp_enc, xkp_enc, xk_trl, zk_trl, zkp_trl;
	wire length_delay;
	assign length_out = length_delay;
	
	
	encoder	encoder1(.clr(clear), .enable(enc_enable), .u(ck), .clk(clk), .top(xk_enc), .bottom(zk_enc), .Q(dff_q), .mod_clr(mod_clr));
	encoder 	encoder2(.clr(clear), .enable(enc_enable), .u(ckp), .clk(clk), .top(xkp_enc), .bottom(zkp_enc), .Q(dff_p), .mod_clr(mod_clr));
	
	trellisterm  termination(.clk(clk), .rst(trl_clr), .enable(trl_enable), .q(dff_q), .p(dff_p), .d0(xk_trl), .d1(zk_trl), .d2(zkp_trl));
	
	fsm	control(.data_valid(data_valid), .reset(rst), .clk(clk), .length_flag(length), .enable(enc_enable), .trellis_enable(trl_enable), .current_state(currstate), .switch(switch), .clr(clear), .trl_clr(trl_clr), .mod_clr(mod_clr));
	
	
	//parallel code
	
	reg write_alt_enc, write_alt_trl;
	
	always @(posedge clk) begin
		if (rst) begin
			write_alt_enc <= 0;
			write_alt_trl <= 0;
		end else if (data_valid) begin
			write_alt_enc <= ~write_alt_enc;
			if (trl_enable) begin
				write_alt_trl <= ~write_alt_trl;
			end
		end else if (trl_enable) begin
			write_alt_trl <= ~write_alt_trl;
		end
	end
	
	wire write_enc_0, write_enc_1, write_trl_0, write_trl_1; 
	reg read_enc_0, read_enc_1, read_trl_0, read_trl_1;
		
	assign write_enc_0 = ~write_alt_enc & enc_enable;
	assign write_enc_1 = write_alt_enc & enc_enable;
	assign write_trl_0 = ~write_alt_trl & switch;
	assign write_trl_1 = write_alt_trl & switch;
	
	wire em, fl;
	wire [12:0] usedw;
	reg read_length;
	
	turbo_fifo lengthfifo(rst, clk, length, read_length, (enc_enable|data_valid), em, fl, length_delay, usedw);
	
	
		
	reg [2:0] current_state;
	reg[13:0] length_counter;
	
	parameter READENC0 = 0;
	parameter READTRL0 = 1;
	parameter READENC1 = 2;
	parameter READTRL1 = 3;
	parameter NOREAD = 4;
	parameter WAIT = 5;
	
	wire[13:0] code_length;
	assign code_length = length_delay ? 13'd6144 : 13'd1056; //changed for testing purposes
	
	//FIFO Read FSM
	
	initial begin
		read_enc_0 <= 0;
		read_trl_0 <= 0;
		read_enc_1 <= 0;
		read_trl_1 <= 0;
		length_counter <= 0;
		current_state <= NOREAD;
	end
	
	always @(posedge clk) begin
		if (rst) begin
			current_state <= NOREAD;
			length_counter <= 0;
		end else begin
			case (current_state)
				NOREAD: begin
					if (write_enc_1) begin
						current_state <= WAIT;
						read_enc_1 <= 0;
						read_length <= 0;
					end
					end
				WAIT : begin
					current_state <= READENC1;
					read_enc_1 <= 1;
					read_length <= 1;
				end
				READENC1: begin
					if (length_counter < code_length-1) begin
						length_counter <= length_counter + 1;
					end else begin
						current_state <= READTRL1;
						read_enc_1 <= 0;
						read_trl_1 <= 1;
						length_counter <= 0;
						read_length <= 0;
					end
					end
				READTRL1: begin
					if (length_counter < 3) begin
						length_counter <= length_counter + 1;
					end else begin
						current_state <= READENC0;
						read_trl_1 <= 0;
						read_enc_0 <= 1;
						length_counter <= 0;
						read_length <= 1;
						if (empty) begin
							current_state <= NOREAD;
							read_trl_1 <= 0;
							read_enc_0 <= 0;
							length_counter <= 0;
						end
					end
					end
				READENC0: begin
					if (length_counter < code_length - 1) begin
						length_counter <= length_counter + 1;
					end else begin
						current_state <= READTRL0;
						read_enc_0 <= 0;
						read_trl_0 <= 1;
						length_counter <= 0;
						read_length <= 0;
					end
					end
				READTRL0: begin
					if (length_counter < 3) begin
						length_counter <= length_counter + 1;
					end else begin
						current_state <= READENC1;
						read_trl_0 <= 0;
						read_enc_1 <= 1;
						length_counter <= 0;
						read_length <= 1;
						if (empty_alt) begin
							current_state <= NOREAD;
							read_trl_0 <= 0;
							read_enc_1 <= 0;
							length_counter <= 0;
						end
					end
					end
				endcase
			end
		end
		
	wire xk_encf0, zk_encf0, zkp_encf0, xkp_encf0, xk_trlf0, zk_trlf0, zkp_trlf0, xk_encf1, zk_encf1, zkp_encf1, xkp_encf1, xk_trlf1, zk_trlf1, zkp_trlf1;
	
	//output FIFOs
	
	wire empty, empty_alt;
	
	turbo_fifo fifo1_enc(rst, clk, xk_enc, read_enc_0, write_enc_0, empty, , xk_encf0,);
	turbo_fifo fifo2_enc(rst, clk, zk_enc, read_enc_0, write_enc_0, , , zk_encf0, );
	turbo_fifo fifo3_enc(rst, clk, zkp_enc, read_enc_0, write_enc_0, , , zkp_encf0, );
	turbo_fifo fifo1_trl(rst, clk, xk_trl, read_trl_0, write_trl_0, , , xk_trlf0, );
	turbo_fifo fifo2_trl(rst, clk, zk_trl, read_trl_0, write_trl_0, , , zk_trlf0, );
	turbo_fifo fifo3_trl(rst, clk, zkp_trl, read_trl_0, write_trl_0, , , zkp_trlf0, );
	
	turbo_fifo fifo1_enc_alt(rst, clk, xk_enc, read_enc_1, write_enc_1, empty_alt, , xk_encf1,);
	turbo_fifo fifo2_enc_alt(rst, clk, zk_enc, read_enc_1, write_enc_1, , , zk_encf1, );
	turbo_fifo fifo3_enc_alt(rst, clk, zkp_enc, read_enc_1, write_enc_1, , , zkp_encf1, );
	turbo_fifo fifo1_trl_alt(rst, clk, xk_trl, read_trl_1, write_trl_1, , , xk_trlf1, );
	turbo_fifo fifo2_trl_alt(rst, clk, zk_trl, read_trl_1, write_trl_1, , , zk_trlf1, );
	turbo_fifo fifo3_trl_alt(rst, clk, zkp_trl, read_trl_1, write_trl_1, , , zkp_trlf1, );
	
	wire xk_encf, zk_encf, zkp_encf, xkp_encf, xk_trlf, zk_trlf, zkp_trlf;
	
	assign xk_encf = read_enc_1 ? xk_encf1 : xk_encf0;
	assign zk_encf = read_enc_1 ? zk_encf1 : zk_encf0;
	assign zkp_encf = read_enc_1 ? zkp_encf1 : zkp_encf0;
	assign xk_trlf = read_trl_1 ? xk_trlf1 : xk_trlf0;
	assign zk_trlf = read_trl_1 ? zk_trlf1 : zk_trlf0;
	assign zkp_trlf = read_trl_1 ? zkp_trlf1 : zkp_trlf0;
	
	assign xk = (read_trl_0 | read_trl_1) ? xk_trlf : xk_encf;
	assign zk = (read_trl_0 | read_trl_1) ? zk_trlf : zk_encf;
	assign zkp = (read_trl_0 | read_trl_1) ? zkp_trlf : zkp_encf;
	
	assign look_now = read_enc_1 | read_enc_0 | read_trl_1 | read_trl_0;
endmodule
