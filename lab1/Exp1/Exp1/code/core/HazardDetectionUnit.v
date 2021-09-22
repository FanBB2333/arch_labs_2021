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
    
    reg fwd_A;
    reg fwd_B;

    always @ (posedge clk) begin
        if(hazard_optype_ID[1] && !hazard_optype_ID[0]) begin
             // 10: data hazard
             // A: 
            if (rs1use_ID && rs1_ID != 0 && rs1_ID == rd_EXE) begin
                // forward A from EX

            end

            if (rs1use_ID && rs1_ID != 0 && rs1_ID == rd_MEM) begin
                // forward A from MEM

            end

            if (rs2use_ID && rs2_ID != 0 && rs2_ID == rd_EXE) begin
                // forward B from EX

            end
            
            if (rs2use_ID && rs2_ID != 0 && rs2_ID == rd_MEM) begin
                // forward B from MEM

            end

        end

        else if (hazard_optype_ID[1] && hazard_optype_ID[0]) begin
            // 11: control hazard

        end

        else if (!hazard_optype_ID[1] && hazard_optype_ID[0]) begin
            // 01: structure hazard
            // stall


        end

    end

    wire Hazards = (EX_RegWrite && rd_EXE != 0 || MEM_RegWrite && rd_MEM != 0);

    assign Data_hazard = (rs1use_ID && rs1_ID != 0 && Hazards && 
                        (rs1_ID == rd_EXE || rs1_ID == rd_MEM)) 
                        || (rs2use_ID && rs2_ID != 0 && Hazards && 
                        (rs2_ID == rd_EXE || rs2_ID == rd_MEM));

endmodule