`timescale 1 ps / 1 ps
module encoder (clr, enable, u, tOut, tIn, clk, Xk, Zk);

input clr, enable, u, tOut, clk;
output Xk, Zk, tIn;

reg switchWire;

wire Q2, Q1, Q0;
wire xor3, xor2, xor1, xor0; 

always @(posedge clk)

//assuming the enable signal is the switch? 

if(~enable) begin
	switchWire <= tOut;
end else begin
	switchWire <= u;
end 

assign Xk = switchWire;

xor xorGate2(xor2,xor3,switchwire);

dffe_ref D2(.q(Q2), .d(xor2), .clk(clk), .en(enable), .clr(clr));

xor xorGate1(xor1,Q2,xor2);

dffe_ref D1(.q(Q1), .d(Q2), .clk(clk), .en(enable), .clr(clr));
dffe_ref D0(.q(Q0), .d(Q1), .clk(clk), .en(enable), .clr(clr));

xor xorGate0(Zk,xor1,Q0);
xor xorGate3(xor3,Q0,Q1);

assign tIn = xor3;

endmodule