`timescale 1ps/1ps

module HazardDetectionUnit(
    input clk,
    input Branch_ID, rs1use_ID, rs2use_ID,
    input[1:0] hazard_optype_ID,
    input[4:0] rd_EXE, rd_MEM, rs1_ID, rs2_ID, rs2_EXE,

    output PC_EN_IF, reg_FD_EN, reg_FD_stall, reg_FD_flush,
        reg_DE_EN, reg_DE_flush, reg_EM_EN, reg_EM_flush, reg_MW_EN,
    output forward_ctrl_ls,
    output[1:0] forward_ctrl_A, forward_ctrl_B
);
            //according to the diagram, design the Hazard Detection Unit
    

    always @ (posedge clk) begin
        // Default circumstance: there is no forward at all
        forward_ctrl_A <= 2'b00;
        forward_ctrl_B <= 2'b00;
        forward_ctrl_ls <= 1'b0;
        PC_EN_IF <= 1;
        reg_FD_EN <= 1;
        reg_DE_EN <= 1;
        reg_EM_EN <= 1;
        reg_MW_EN <= 1;
        reg_FD_stall <= 0;
        reg_FD_flush <= 0;
        reg_DE_flush <= 0;
        reg_EM_flush <= 0;
        
    // 01: ALU type with data hazard
    // 10: Load-use type with data hazard
    // 11: Branch type with control hazard


        // A: 
        if (rs1use_ID && rs1_ID != 0 && rs1_ID == rd_EXE) begin
            // forward A from EX
            forward_ctrl_A = 2'b01;
        end

        if (rs1use_ID && rs1_ID != 0 && rs1_ID == rd_MEM) begin
            // forward A from MEM
            forward_ctrl_A = 2'b10;

        end

        if (rs2use_ID && rs2_ID != 0 && rs2_ID == rd_EXE) begin
            // forward B from EX
            forward_ctrl_B = 2'b01;

        end
        
        if (rs2use_ID && rs2_ID != 0 && rs2_ID == rd_MEM) begin
            // forward B from MEM
            forward_ctrl_B = 2'b10;
        end
        // Forward from control signal 3 if this is a load-use hazard


        if(hazard_optype_ID[1] && !hazard_optype_ID[0]) begin
            // 10 load-use hazard

        end

        else if (hazard_optype_ID[1] && hazard_optype_ID[0]) begin
            // 11: branch type
            // predict the branch

        end

        else if (!hazard_optype_ID[1] && hazard_optype_ID[0]) begin
            // 01: ALU type


        end

    end



endmodule