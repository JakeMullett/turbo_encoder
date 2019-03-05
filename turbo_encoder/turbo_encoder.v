module turbo_encoder(clk, rst, length, data_valid,ck, ckp, xk, zk, zkp, look_now, currstate);
	input clk, rst, data_valid, ck, ckp;
	input [8:0] length;
	output xk, zk, zkp, look_now;
	output currstate;
	
	wire clear, enc_enable, trl_enable, switch;
	wire [2:0] dff_q, dff_p;
	wire xk_enc, zk_enc, zkp_enc, xkp_enc, xk_trl, zk_trl, zkp_trl;
	
	
	encoder	encoder1(.clr(clear), .enable(enc_enable), .u(ck), .clk(clk), .top(xk_enc), .bottom(zk_enc), .Q(dff_q));
	encoder 	encoder2(.clr(clear), .enable(enc_enable), .u(ckp), .clk(clk), .top(xkp_enc), .bottom(zkp_enc), .Q(dff_p));
	
	trellisterm  termination(.clk(clk), .rst(clear), .enable(trl_enable), .q(dff_q), .p(dff_p), .d0(xk_trl), .d1(zk_trl), .d2(zkp_trl));
	
	fsm	control(.data_valid(data_valid), .reset(rst), .clk(clk), .length(length), .enable(enc_enable), .trellis_enable(trl_enable), .current_state(currstate), .clr(clear));

	assign look_now = enc_enable;
	
	assign xk = switch ? xk_enc : xk_trl;
	assign zk = switch ? zk_enc : zk_trl;
	assign zkp = switch ? zkp_enc : zkp_trl;
	
	
endmodule
