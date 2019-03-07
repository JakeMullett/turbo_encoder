module turbo_encoder(clk, rst, length, data_valid,ck, ckp, xk, zk, zkp, look_now, length_out);
	input clk, rst, data_valid, ck, ckp, length;
	output xk, zk, zkp, look_now, length_out; 
	
	wire clear, enc_enable, trl_clr, trl_enable, switch;
	wire [2:0] dff_q, dff_p, currstate;
	wire xk_enc, zk_enc, zkp_enc, xkp_enc, xk_trl, zk_trl, zkp_trl;
	
	assign length_out = length;
	
	
	encoder	encoder1(.clr(clear), .enable(enc_enable), .u(ck), .clk(clk), .top(xk_enc), .bottom(zk_enc), .Q(dff_q));
	encoder 	encoder2(.clr(clear), .enable(enc_enable), .u(ckp), .clk(clk), .top(xkp_enc), .bottom(zkp_enc), .Q(dff_p));
	
	trellisterm  termination(.clk(clk), .rst(trl_clr), .enable(trl_enable), .q(dff_q), .p(dff_p), .d0(xk_trl), .d1(zk_trl), .d2(zkp_trl));
	
	fsm	control(.data_valid(data_valid), .reset(rst), .clk(clk), .length_flag(length), .enable(enc_enable), .trellis_enable(trl_enable), .current_state(currstate), .switch(switch), .clr(clear), .trl_clr(trl_clr));

	assign look_now = (currstate[1]&currstate[0]) | (currstate[1]&(~currstate[0]));
	
	assign xk = switch ? xk_trl : xk_enc;
	assign zk = switch ? zk_trl : zk_enc;
	assign zkp = switch ? zkp_trl : zkp_enc;
	
	
endmodule
