`timescale 1ns / 1ps

module CSRRegs(
    input clk, rst,
    input[11:0] raddr, waddr,
    input[31:0] wdata,
    input csr_w,
    input[1:0] csr_wsc_mode,
    output[31:0] rdata,
    output[31:0] mstatus
);

    reg[31:0] CSR [0:15];

    // Address mapping. The address is 12 bits, but only 4 bits are used in this module.
    wire raddr_valid = raddr[11:7] == 5'h6 && raddr[5:3] == 3'h0; // [11:7] == 2'b00110
    wire[3:0] raddr_map = (raddr[6] << 3) + raddr[2:0];
    wire waddr_valid = waddr[11:7] == 5'h6 && waddr[5:3] == 3'h0; // [11:7] == 2'b00110
    wire[3:0] waddr_map = (waddr[6] << 3) + waddr[2:0];

    assign mstatus = CSR[0];

    assign rdata = CSR[raddr_map];

    always@(posedge clk or posedge rst) begin
        if(rst) begin
            // addr[6] == 0
			CSR[0] <= 32'h88; // mstatus
			CSR[1] <= 0; // misa
			CSR[2] <= 0; // medeleg
			CSR[3] <= 0; // mideleg
			CSR[4] <= 32'hfff; // mie
			CSR[5] <= 0; // mtvec
			CSR[6] <= 0; // mcounteren
			CSR[7] <= 0; // 
            // addr[6] == 1
			CSR[8] <= 0; // mscratch
			CSR[9] <= 0; // mepc
			CSR[10] <= 0; // mcause
			CSR[11] <= 0; // mtval
			CSR[12] <= 0; // mip
			CSR[13] <= 0; // 
			CSR[14] <= 0; // 
			CSR[15] <= 0; // 
		end
        else if(csr_w) begin
            case(csr_wsc_mode)
                2'b01: CSR[waddr_map] = wdata; // csrrw, csrrwi
                2'b10: CSR[waddr_map] = CSR[waddr_map] | wdata; // csrrs, csrrsi
                2'b11: CSR[waddr_map] = CSR[waddr_map] & ~wdata; // csrrc, csrrci
                default: CSR[waddr_map] = wdata;
            endcase            
        end
    end
endmodule