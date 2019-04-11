// ---------- SAMPLE TEST BENCH ----------
`timescale 1 ns / 100 ps
module turbo_tb();

    reg clock, rst, length, data_valid, ck, ckp;
	 wire xk, zk, xkp, look_now, length_out;
	 wire[2:0] currstate;

	 turbo_encoder turbo(clock, rst, length, data_valid,ck, ckp, xk, zk, zkp, look_now, length_out, currstate);

    // setting the initial values of all the reg
    initial
    begin
        $display($time, " << Starting the Simulation >>");
        clock = 1'b0;    // at time 0
        rst = 1'b1;
		  length = 1'b0;
		  data_valid = 1'b0;

        @(negedge clock);    // wait until next negative edge of clock
        @(negedge clock);    // wait until next negative edge of clock

        rst = 1'b0;    // de-assert reset
        @(negedge clock);    // wait until next negative edge of clock

		  data_valid = 1'b1;
		  @(negedge clock);
		  data_valid = 1'b0;
		  ck = 1'b1;
		  @(negedge clock);
		  ckp = 1'b1;
		  @(negedge clock);
		  ck = 1'b0;
		  @(negedge clock);
		  ck = 1'b1;
		  ckp = 1'b0;
		  data_valid = 1'b1;
		  @(negedge clock);
		  length = 1'b1;
		  ckp = 1'b1;
		  ck = 1'b0;
		  data_valid = 1'b0;
		  @(negedge clock);
		  @(negedge clock);
		  ck = 1'b1;
		  ckp = 1'b0;
		  @(negedge clock);
		  ckp = 1'b1;
		  @(negedge clock);
		  ckp = 1'b0;
		  ck = 1'b0;
		  @(negedge clock);
		  @(negedge clock);
		  @(negedge clock);
		  @(negedge clock);
        // Begin testing... (loop over registers)
//        for(index = 0; index <= 31; index = index + 1) begin
//            writeRegister(index, 32'h0000DEAD + index);
//            checkRegister(index, 32'h0000DEAD + index);
//        end


        $stop;
    end



    // Clock generator
    always
         #10     clock = ~clock;    // toggle


//    // Task for reading
//    task checkRegister;
//
//        input [4:0] checkReg;
//        input [31:0] exp;
//
//        begin
//            @(negedge clock);    // wait for next negedge of clock
//
//            ctrl_readRegA = checkReg;    // test port A
//            ctrl_readRegB = checkReg;    // test port B
//
//            @(negedge clock); // wait for next negedge, read should be done
//
//            if(data_readRegA !== exp) begin
//                $display("**Error on port A: read %h but expected %h.", data_readRegA, exp);
//                errors = errors + 1;
//            end
//
//            if(data_readRegB !== exp) begin
//                $display("**Error on port B: read %h but expected %h.", data_readRegB, exp);
//                errors = errors + 1;
//            end
//        end
//    endtask
endmodule
