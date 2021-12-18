`timescale 1ns / 1ps

module core_sim;
    reg clk, rst;

    RV32core core(
        .debug_en(1'b0),
        .debug_step(1'b0),
        .debug_addr(7'b0),
        .debug_data(),
        .clk(clk),
        .rst(rst),
        .interrupter(1'b0)
    );

	initial begin
		// Initialize Inputs
		clk = 0;
		rstn = 0;

		// Wait 100 ns for global reset to finish
		#95 rstn = 1;
        
		// Add stimulus here
	end
	
	initial forever #10 clk = ~clk;

endmodule