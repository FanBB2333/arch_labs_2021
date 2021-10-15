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
    input[31:0] epc_next, // MEM向前�?�? 未被flush的最新PC
    output[31:0] PC_redirect,
    output redirect_mux,

    output reg_FD_flush, reg_DE_flush, reg_EM_flush, reg_MW_flush, 
    output RegWrite_cancel
);

    wire[11:0] csr_raddr, csr_waddr;
    wire[31:0] csr_wdata;
    wire csr_w;
    wire[1:0] csr_wsc;

    wire[31:0] mstatus;

    CSRRegs csr(
        .clk(clk),.rst(rst),.csr_w(csr_w),.raddr(csr_raddr),.waddr(csr_waddr),
        .wdata(csr_wdata),.csr_wsc_mode(csr_wsc),
        // output
        .rdata(csr_r_data_out),.mstatus(mstatus));




    assign csr_raddr = csr_rw_in ? csr_rw_addr_in : 0;
    assign csr_waddr = csr_rw_in ? csr_rw_addr_in : 0;
    assign csr_wdata = csr_w_imm_mux ? csr_w_data_imm : csr_w_data_reg;
    assign csr_wsc = csr_wsc_mode_in;

    assign csr_w = csr_rw_in ;// not csrrs rd, csr, x0, namely csrr rd, csr
    // csrrw: write, csrrs: set 


    wire ls_fault = l_access_fault | s_access_fault;
    
    assign reg_FD_flush = redirect_mux;
    assign reg_DE_flush = redirect_mux;
    assign reg_EM_flush = redirect_mux;
    assign reg_MW_flush = redirect_mux;
    assign redirect_mux = illegal_inst | l_access_fault | s_access_fault | ecall_m | mret; // TBD

    assign PC_redirect = csr_r_data_out;
    assign RegWrite_cancel = illegal_inst | l_access_fault | s_access_fault | ecall_m; // TBD
//    According to the diagram, design the Exception Unit
    // always @(posedge clk) begin
    //     if(rst) begin
    //         csr_raddr <= 0;
    //         csr_waddr <= 0;
    //         csr_wdata <= 0;
    //         csr_wsc <= 0;
    //         csr_w <= 0;
    //     end
    //     else begin
    //         csr_raddr <= csr_rw_addr_in;
    //         csr_waddr <= csr_rw_addr_in;
    //         csr_wdata <= csr_w_data_reg;
    //         csr_wsc <= csr_wsc_mode_in;

    //         csr_w <= csr_rw_in;
    //         if (mret)begin
                
    //         end
    //     end
    // end


endmodule