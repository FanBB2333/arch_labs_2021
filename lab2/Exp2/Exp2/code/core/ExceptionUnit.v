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
    input[31:0] epc_next, // MEM向前�???�??? 未被flush的最新PC
    output[31:0] PC_redirect,
    output reg redirect_mux,

    output reg_FD_flush, reg_DE_flush, reg_EM_flush, reg_MW_flush, 
    output RegWrite_cancel
);

    reg[11:0] csr_raddr, csr_waddr;
    reg[31:0] csr_wdata;
    reg csr_w;
    reg[1:0] csr_wsc;
    reg[1:0] state;

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
    wire flush_signal = illegal_inst | l_access_fault | s_access_fault | ecall_m;
    reg flush_signal_latch;
    reg[31:0] mcause_next;

    assign reg_FD_flush = RegWrite_cancel | redirect_mux;
    assign reg_DE_flush = RegWrite_cancel | redirect_mux;
    assign reg_EM_flush = RegWrite_cancel | redirect_mux;
    assign reg_MW_flush = RegWrite_cancel | redirect_mux; 
    // assign redirect_mux = illegal_inst | l_access_fault | s_access_fault | ecall_m | mret; // TBD

    assign PC_redirect = csr_r_data_out;
    assign RegWrite_cancel = interrupt | illegal_inst | l_access_fault | s_access_fault | ecall_m; // TBD
//    According to the diagram, design the Exception Unit
    initial redirect_mux = 0;
    initial state = 0;
    always @(posedge clk or posedge rst) begin
        if(RegWrite_cancel) begin
            redirect_mux <= 1'b1;
        end
        else begin
            redirect_mux <= 1'b0;
        end

        case(state)
        // STATE_IDLE
        2'b00: begin
            if(RegWrite_cancel) begin 
                // If the exception or interruption or ecall is called, we just change the state
                // read in mepc
                if(csr_rw_in) begin
                    csr_raddr <= csr_rw_addr_in;
                end

                //2. write the mstatus register
                csr_waddr <= 12'h300; // the number of mstatus register
                // mstatus[7] == MPIE, mstatus[3] == MIE
                csr_wdata <= {mstatus[31:8], mstatus[3], mstatus[6:4], 1'b0, mstatus[2:0]};
                csr_w <= 1'b1; // write enable
                csr_wsc <= 2'b01; // write immediately
                state <= 2'b01; // change the state to STATE_MEPC

            end
            else if(mret) begin
                // mret cycle
                // mepc: 0x341
                csr_raddr <= 12'h341; 
                csr_waddr <= 12'h300;
                csr_wdata <= {mstatus[31:8], 1'b1, mstatus[6:4], mstatus[3], mstatus[2:0]}; // return the interrupt mode
                // csr_w <= 1'b1; // write enable
                // csr_wsc <= 2'b01; // write immediately
                state <= 2'b00; // stall the state
            
            end
            else if(csr_rw_in) begin
                // CSR inst, then just execute it 
                csr_raddr <= csr_rw_addr_in;
                csr_waddr <= csr_rw_addr_in;
                if (csr_w_imm_mux) begin
                    csr_wdata <= {27'b0, csr_w_data_imm};
                end
                else begin
                    csr_wdata <= csr_w_data_reg;
                end
                csr_wsc <= csr_wsc_mode_in;
                csr_w <= csr_rw_in; 
                state <= 2'b00; // stall the state
            end

        end

        // STATE_MEPC
        2'b01: begin
            // 1. read mtvec(0x305)
            csr_raddr <= 12'h305;
            // 2. write mepc(0x341)
            csr_waddr <= 12'h341;
            csr_wdata <= epc_cur - 4; // TODO: check if this is epc_next
            csr_wsc <= 2'b01; // write immediately
            csr_w <= 1'b1; // write enable
            state <= 2'b10; // change the state to STATE_MCAUSE

        end


        // STATE_MCAUSE
        2'b10: begin
            if(csr_rw_in) begin
                csr_raddr = csr_rw_addr_in;
            end
            // 1. write mcause(0x342)
            csr_waddr <= 12'h342; // the number of mstatus register
            csr_wdata <= {mstatus[31:8], mstatus[3], mstatus[6:4], 1'b0, mstatus[2:0]};
            csr_w <= 1'b1; // write enable
            csr_wsc <= 2'b01; // write immediately
            state <= 2'b00; // change the state to STATE_IDLE

        end

        // 2'b11: begin
        //     if(csr_rw_in) begin
        //         csr_raddr = csr_rw_addr_in;
        //     end
        //     csr_w <= 1'b0; // write enable
        //     csr_wsc <= 2'b01; // write immediately
        //     state <= 2'b00; // change the state to STATE_IDLE

        // end
    endcase
    end


endmodule