module hardware_test(clk, rst, start_test, correct, look_now, enc_out, check);
	input clk, rst, start_test;
	output correct, look_now;
	output [2:0] check;
	output [2:0] enc_out;
	
	wire [3:0] encoder_in;
	//wire [2:0] check;
	wire xk, zk, zkp;
	wire length_out;
	reg enable, enable_out;
	
	assign enc_out[0] = xk;
	assign enc_out[1] = zk;
	assign enc_out[2] = zkp;
	
	always @(posedge clk) begin
		if (rst) begin
			enable <= 0;
		end else if (start_test) begin
			enable <= ~enable;
		end
	end
	
	reg [12:0] count;
	reg [12:0] count_out;
	reg [4:0] stall;
	reg go;
	
	always @(posedge clk) begin
		if (rst) begin
			count <= 0;
		end else if (start_test) begin
			count <= 0;
		end else begin
			count <= count + 1;
		end
	end
	
	always @(posedge clk) begin
		if (rst) begin
			stall <= 0;
			go <= 0;
		end else if (start_test) begin
			stall <= 0;
			go <= 1;
		end else if (go) begin
			stall <= stall + 1;
		end
	end
	
	always @(posedge clk) begin
		if (rst) begin
			enable_out <= 0;
		end else if (stall==2) begin
			enable_out <= ~enable_out;
		end
	end
	
	always @(posedge clk) begin
		if (rst) begin
			count_out <= 0;
		end else if (stall==2) begin
			count_out <= 0;
		end else begin
			count_out <= count_out + 1;
		end
	end
	
	encoder_rom	c_k(count, clk, enable, encoder_in);
	correctness_rom check_rom(count_out, clk, enable_out, check);
	
	turbo_encoder	encoder(clk, rst, encoder_in[2], encoder_in[3], encoder_in[0], encoder_in[1], xk, zk, zkp, look_now, length_out); 
	
	reg correct_xk, correct_zk, correct_zkp;
	
	always @(posedge clk) begin
		if (xk == check[0]) begin
			correct_xk <= 1;
		end else begin
			correct_xk <= 0;
		end
	end
	
	always @(posedge clk) begin
		if (zk == check[1]) begin
			correct_zk <= 1;
		end else begin
			correct_zk <= 0;
		end
	end
	
	always @(posedge clk) begin
		if (zkp == check[2]) begin
			correct_zkp <= 1;
		end else begin
			correct_zkp <= 0;
		end
	end
	
	assign correct = correct_xk & correct_zk & correct_zkp;

endmodule
