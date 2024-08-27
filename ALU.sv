`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly San Luis Obispo
// Engineer: Diego Curiel
// Create Date: 02/07/2023 10:11:42 AM
// Module Name: ALU
//////////////////////////////////////////////////////////////////////////////////

module ALU(
    input logic [31:0] SRC_A,
    input logic [31:0] SRC_B,
    input logic [3:0] ALU_FUN,
    output logic [31:0] RESULT
    );
    
    //Design the ALU as a MUX to improve processing speed.
    //The MUX is dependent on the ALU_FUN.
    //ALU_FUN determines which operation is carried out with the operands A and B.
    always_comb begin
    case(ALU_FUN)
    4'b0000: begin RESULT = SRC_A + SRC_B; end //add; no signed designator needed
    4'b1000: begin RESULT = SRC_A - SRC_B; end //sub; no signed designator needed
    //logic
    4'b0110: begin RESULT = SRC_A | SRC_B; end //or
    4'b0111: begin RESULT = SRC_A & SRC_B; end //and
    4'b0100: begin RESULT = SRC_A ^ SRC_B; end //xor
    //shifting
    4'b0101: begin RESULT = SRC_A >> SRC_B[4:0]; end //srl
    4'b0001: begin RESULT = SRC_A << SRC_B[4:0]; end //sll
    4'b1101: begin RESULT = $signed(SRC_A) >>> SRC_B[4:0]; end //sra
    //setting
    4'b0010: begin RESULT = $signed(SRC_A) < $signed(SRC_B); end //slt
    4'b0011: begin RESULT = SRC_A < SRC_B; end //sltu
    //copy
    4'b1001: begin RESULT = SRC_A; end //lui-copy
    default: begin RESULT = 32'd0; end
    endcase
    end
    
endmodule
