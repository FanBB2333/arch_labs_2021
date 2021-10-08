`timescale 1ns / 1ps


module    Latch2_2(
                    input rst,
                    input clk,
                    input [1:0] hazard_optype_ctrl,
                    input [1:0] hazard_optype_ctrl_before2_cycle,
                    output reg [1:0] hazard_optype_ctrl_before1,
                    output reg [1:0] hazard_optype_ctrl_before2
                );
    
    initial hazard_optype_ctrl_before1 = 2'b00;
    initial hazard_optype_ctrl_before2 = 2'b00;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
             hazard_optype_ctrl_before1 <= 2'b00;
             hazard_optype_ctrl_before2 <= 2'b00;
            end
        else begin
                hazard_optype_ctrl_before2 <= hazard_optype_ctrl_before2_cycle;
                hazard_optype_ctrl_before1 <= hazard_optype_ctrl;
            end
    end

endmodule