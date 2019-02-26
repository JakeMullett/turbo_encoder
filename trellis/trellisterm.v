module trellisterm(clk, rst, enable, q, p, d0, d1, d2);
	input clk, rst, enable;
	input [2:0] q,p;
	output d0, d1, d2;
	
	wire [3:0] u0,u1,u2;
	wire [3:0] alt;
	
	assign alt[3] = 1'b0;
	assign alt[2:0] = 3'bz;
	
	assign u0[0] = q[0]^q[1];
	assign u0[1] = 1'b0;
	assign u0[2] = p[0]^p[1];
	assign u0[3] = 1'b0;
	
	assign u1[0] = q[0]^q[2];
	assign u1[1] = q[2];
	assign u1[2] = p[0]^p[2];
	assign u1[3] = p[2];
	
	assign u2[0] = q[1]^q[2];
	assign u2[1] = 1'b0;
	assign u2[2] = p[1]^p[2];
	assign u2[3] = 1'b0;
	
	wire [3:0] out0,out1,out2;
	
	trellshift shiftd0(rst, clk, u0, enable, out0);
	trellshift shiftd1(rst, clk, u1, enable, out1);
	trellshift shiftd2(rst, clk, u2, enable, out2);
	
	assign d0 = out0[0];
	assign d1 = out1[0];
	assign d2 = out2[0];
	

endmodule
