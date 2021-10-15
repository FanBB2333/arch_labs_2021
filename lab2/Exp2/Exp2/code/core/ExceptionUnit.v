`timescale 1ns / 1ps

module ExceptionUnit(
    input clk, rst,
    input csr_rw_in, // if the inst is CSR inst, CSR_valid = CSRRW | CSRRS | CSRRC | CSRRWI | CSRRSI | CSRRCI
    input[1:0] csr_wsc_mode_in, // inst_MEM[13:12]
    input csr_w_imm_mux, // CSRRWI | CSRRSI | CSRRCI
    input[11:0] csr_rw_addr_in, // inst_MEM[31:20], represents the csr reg
    input[31:0] csr_w_data_reg, // rs1_data_MEM
    input[4:0] csr_w_data_imm, // rs1_MEM, namely zimm[4:0]
    output[31:0] csr_r_data_out, // to mux in MEM stage

    input interrupt,
    input illegal_inst,
    input l_access_fault,
    input s_access_fault,
    input ecall_m,

    input mret,

    input[31:0] epc_cur, // PC_WB
    input[31:0] epc_next, // MEM向前�??�?? 未被flush的最新PC
    output[31:0] PC_redirect,
    output reg redirect_mux,

    output reg_FD_flush, reg_DE_flush, reg_EM_flush, reg_MW_flush, 
    output RegWrite_cancel
);

    reg[11:0] csr_raddr, csr_waddr;
    reg[31:0] csr_wdata;
    reg csr_w;
    reg[1:0] csr_wsc;

    wire[31:0] mstatus;

    initial csr_raddr = 0;
    initial csr_waddr = 0;

    CSRRegs csr(
        .clk(clk),.rst(rst),.csr_w(csr_w),.raddr(csr_raddr),.waddr(csr_waddr),
        .wdata(csr_wdata),.csr_wsc_mode(csr_wsc),
        // output
        .rdata(csr_r_data_out),.mstatus(mstatus));




    // assign csr_raddr = csr_rw_in ? csr_rw_addr_in : 0;
    // assign csr_waddr = csr_rw_in ? csr_rw_addr_in : 0;
    // assign csr_wdata = csr_w_imm_mux ? csr_w_data_imm : csr_w_data_reg;
    // assign csr_wsc = csr_wsc_mode_in;

    // assign csr_w = csr_rw_in ;// not csrrs rd, csr, x0, namely csrr rd, csr
    // csrrw: write, csrrs: set 


    wire ls_fault = l_access_fault | s_access_fault;
    
    assign reg_FD_flush = redirect_mux;
    assign reg_DE_flush = redirect_mux;
    assign reg_EM_flush = redirect_mux;
    assign reg_MW_flush = redirect_mux;
    // assign redirect_mux = illegal_inst | l_access_fault | s_access_fault | ecall_m | mret; // TBD

    assign PC_redirect = csr_r_data_out;
    assign RegWrite_cancel = illegal_inst | l_access_fault | s_access_fault | ecall_m; // TBD
//    According to the diagram, design the Exception Unit
    initial redirect_mux = 0;
    always @(posedge clk) begin
        if(csr_rw_in) begin
            csr_raddr <= csr_rw_addr_in;
            csr_waddr <= csr_rw_addr_in;
            if (csr_w_imm_mux) begin
                csr_wdata <= csr_w_data_imm;
            
            end
            else begin
                csr_wdata <= csr_w_data_reg;
            end
            csr_wsc <= csr_wsc_mode_in;

            csr_w <= csr_rw_in; 
        end
        if (illegal_inst | l_access_fault | s_access_fault | ecall_m | mret) begin
            redirect_mux <= 1;
        end
        else begin
            redirect_mux <= 0;
        end



    end


endmodule