`timescale 1 ps / 1 ps
module encoder (clr, enable, u, clk, top, bottom, Q);

input clr, enable, u, clk;
output top, bottom;
output [2:0] Q;

wire switch, D2in, xorQ1Q0, xorD2Q2; 

// the enable signal is the switch 

assign switch = enable ? u : xorQ1Q0;

assign top = switch;

xor xorGate2(D2in,switch,xorQ1Q0);

dffe_ref D2(.q(Q[2]), .d(D2in), .clk(clk), .en(enable), .clr(clr));

xor xorGate1(xorD2Q2,D2in,Q[2]);

dffe_ref D1(.q(Q[1]), .d(Q[2]), .clk(clk), .en(enable), .clr(clr));
dffe_ref D0(.q(Q[0]), .d(Q[1]), .clk(clk), .en(enable), .clr(clr));

xor xorGate0(bottom,xorD2Q2,Q[0]);
xor xorGate3(xorQ1Q0,Q[0],Q[1]);

endmodule
