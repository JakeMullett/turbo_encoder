module turbo_encoder(clk, rst, length, data_valid,ck, ckp, xk, zk, zkp, look_now, length_out,
	current_state, xk_enc, zk_enc, zkp_enc, xk_trl, zk_trl, zkp_trl, write_alt_enc, write_alt_trl,
	trl_enable);
	input clk, rst, data_valid, ck, ckp, length;
	output xk, zk, zkp, look_now, length_out;  
	output reg [2:0] current_state;
	output xk_enc, zk_enc, zkp_enc, xk_trl, zk_trl, zkp_trl, trl_enable;
	output reg write_alt_enc, write_alt_trl;

	
	
	wire clear, enc_enable, trl_clr, mod_clr, switch;
	wire [2:0] dff_q, dff_p, currstate;
	//wire xk_enc, zk_enc, zkp_enc, xkp_enc, xk_trl, zk_trl, zkp_trl;
	
	assign length_out = length_delay;
	
	
	encoder	encoder1(.clr(clear), .enable(enc_enable), .u(ck), .clk(clk), .top(xk_enc), .bottom(zk_enc), .Q(dff_q), .mod_clr(mod_clr));
	encoder 	encoder2(.clr(clear), .enable(enc_enable), .u(ckp), .clk(clk), .top(xkp_enc), .bottom(zkp_enc), .Q(dff_p), .mod_clr(mod_clr));
	
	trellisterm  termination(.clk(clk), .rst(trl_clr), .enable(trl_enable), .q(dff_q), .p(dff_p), .d0(xk_trl), .d1(zk_trl), .d2(zkp_trl));
	
	fsm	control(.data_valid(data_valid), .reset(rst), .clk(clk), .length_flag(length), .enable(enc_enable), .trellis_enable(trl_enable), .current_state(currstate), .switch(switch), .clr(clear), .trl_clr(trl_clr), .mod_clr(mod_clr));
	
	
	//parallel code
	
	//reg write_alt_enc, write_alt_trl;
	
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
	
	reg write_enc_0, write_enc_1, write_trl_0, write_trl_1, read_enc_0, read_enc_1, read_trl_0, read_trl_1;
	
	always @(posedge clk) begin
		if (rst) begin
			write_enc_0 <= 0;
			write_enc_1 <= 0;
		end else if (write_alt_enc & enc_enable) begin
			write_enc_1 <= 1;
			write_enc_0 <= 0;
		end else if (~write_alt_enc & enc_enable) begin
			write_enc_1 <= 0;
			write_enc_0 <= 0;
		end
		end
		
	always @(posedge clk) begin
		if (rst) begin
			write_trl_0 <= 0;
			write_trl_1 <= 0;
		end else if (write_alt_trl & switch) begin
			write_trl_1 <= 1;
			write_trl_0 <= 0;
		end else if (~write_alt_trl & switch) begin
			write_trl_0 <= 1;
			write_trl_1 <= 0;
		end
		end
	
	wire length_delay;
	reg write_deay;
		
	dffe_ref dff1(length_delay, length, clk, 1'b1, rst);
	dffe_ref dff2(write_delay, write_enc_1, clk, 1'b1, rst);
	dffe_ref dff3(switch_delay, switch, clk, 1'b1, rst);

		
	//reg current_state;
	reg[13:0] length_counter;
	
	parameter READENC0 = 0;
	parameter READTRL0 = 1;
	parameter READENC1 = 2;
	parameter READTRL1 = 3;
	parameter NOREAD = 4;
	
	wire[13:0] code_length;
	assign code_length = length_delay ? 13'd6 : 13'd4; //changed for testing purposes
	
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
					if (write_delay) begin
						current_state <= READENC1;
						read_enc_1 <= 1;
					end
					end
				READENC1: begin
					if (length_counter < code_length-1) begin
						length_counter <= length_counter + 1;
					end else begin
						current_state <= READTRL1;
						read_enc_1 <= 0;
						read_trl_1 <= 1;
						length_counter <= 0;
					end
					end
				READTRL1: begin
					if (length_counter < 3) begin
						length_counter <= length_counter + 1;
					end else begin
						current_state <= READENC0;
						read_trl_1 <= 0;
						read_enc_0 <= 0;
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
					end
					end
				READTRL0: begin
					if (length_counter < 3) begin
						length_counter <= length_counter + 1;
					end else begin
						current_state <= READENC1;
						read_trl_0 <= 0;
						read_enc_1 <= 1;
					end
					end
				endcase
			end
		end
		
	wire xk_encf0, zk_encf0, zkp_encf0, xkp_encf0, xk_trlf0, zk_trlf0, zkp_trlf0, xk_encf1, zk_encf1, zkp_encf1, xkp_encf1, xk_trlf1, zk_trlf1, zkp_trlf1;
	
	turbo_fifo fifo1_enc(.aclr(rst), .clock(clk), .data(xk_enc), .rdreq(read_enc_0), .wrreq(write_enc_0), .empty(), .full(), .q(xk_encf0), .usedw());
	turbo_fifo fifo2_enc(.aclr(rst), .clock(clk), .data(zk_enc), .rdreq(read_enc_0), .wrreq(write_enc_0), .empty(), .full(), .q(zk_encf0), .usedw());
	turbo_fifo fifo3_enc(.aclr(rst), .clock(clk), .data(zkp_enc), .rdreq(read_enc_0), .wrreq(write_enc_0), .empty(), .full(), .q(zkp_encf0), .usedw());
	turbo_fifo fifo1_trl(.aclr(rst), .clock(clk), .data(xk_trl), .rdreq(read_trl_0), .wrreq(write_trl_0), .empty(), .full(), .q(xk_trlf0), .usedw());
	turbo_fifo fifo2_trl(.aclr(rst), .clock(clk), .data(zk_trl), .rdreq(read_trl_0), .wrreq(write_trl_0), .empty(), .full(), .q(zk_trlf0), .usedw());
	turbo_fifo fifo3_trl(.aclr(rst), .clock(clk), .data(zkp_trl), .rdreq(read_trl_0), .wrreq(write_trl_0), .empty(), .full(), .q(zkp_trlf0), .usedw());
	
	turbo_fifo fifo1_enc_alt(.aclr(rst), .clock(clk), .data(xk_enc), .rdreq(read_enc_1), .wrreq(write_enc_1), .empty(), .full(), .q(xk_encf1), .usedw());
	turbo_fifo fifo2_enc_alt(.aclr(rst), .clock(clk), .data(zk_enc), .rdreq(read_enc_1), .wrreq(write_enc_1), .empty(), .full(), .q(zk_encf1), .usedw());
	turbo_fifo fifo3_enc_alt(.aclr(rst), .clock(clk), .data(zkp_enc), .rdreq(read_enc_1), .wrreq(write_enc_1), .empty(), .full(), .q(zkp_encf1), .usedw());
	turbo_fifo fifo1_trl_alt(.aclr(rst), .clock(clk), .data(xk_trl), .rdreq(read_trl_1), .wrreq(write_trl_1), .empty(), .full(), .q(xk_trlf1), .usedw());
	turbo_fifo fifo2_trl_alt(.aclr(rst), .clock(clk), .data(zk_trl), .rdreq(read_trl_1), .wrreq(write_trl_1), .empty(), .full(), .q(zk_trlf1), .usedw());
	turbo_fifo fifo3_trl_alt(.aclr(rst), .clock(clk), .data(zkp_trl), .rdreq(read_trl_1), .wrreq(write_trl_1), .empty(), .full(), .q(zkp_trlf1), .usedw());
	
	wire xk_encf, zk_encf, zkp_encf, xkp_encf, xk_trlf, zk_trlf, zkp_trlf;
	
	assign xk_encf = read_enc_1 ? xk_encf1 : xk_encf0;
	assign zk_encf = read_enc_1 ? zk_encf1 : zk_encf0;
	assign zkp_encf = read_enc_1 ? zkp_encf1 : zkp_encf0;
	assign xk_trlf = read_trl_1 ? xk_trlf1 : xk_trlf0;
	assign zk_trlf = read_trl_1 ? zk_trlf1 : zk_trlf0;
	assign zkp_trlf = read_trl_1 ? zkp_trlf1 : zkp_trlf0;
	
	assign xk = switch_delay ? xk_trlf : xk_encf;
	assign zk = switch_delay ? zk_trlf : zk_encf;
	assign zkp = switch_delay ? zkp_trlf : zkp_encf;
	
	assign look_now = read_enc_1 | read_enc_0 | read_trl_1 | read_trl_0;
endmodule
