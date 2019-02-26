`timescale 1 ps / 1 ps
module encoder (clr, enable, u, clk, Xk, Zk);

input clr, enable, u;
output [15:0] Xk, Zk, Zprimek;

wire Q2, Q1, Q0;
wire zkPrior;

dffe_ref D2(.q(Q2), .d(u), .clk(clk), .en(enable), .clr(clr));
dffe_ref D1(.q(Q1), .d(Q2), .clk(clk), .en(enable), .clr(clr));
dffe_ref D0(.q(Q0), .d(Q1), .clk(clk), .en(enable), .clr(clr));

xor xor0(zkPrior, u, Q2);
xor xor1(zk, zkPrior, Q0);