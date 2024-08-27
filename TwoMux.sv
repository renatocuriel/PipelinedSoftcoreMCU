`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California Polytechnic University, San Luis Obispo
// Engineer: Diego Renato Curiel
// Create Date: 02/25/2023 10:55:14 PM
// Module Name: TwoMux
//////////////////////////////////////////////////////////////////////////////////

module TwoMux(
    input logic ALU_SRC_A,
    input logic [31:0] RS1,
    input logic [31:0] U_TYPE,
    output logic [31:0] SRC_A
    );
    
    //Create a generic two-to-one MUX to be used for the ALU.
    always_comb begin
        case(ALU_SRC_A)
            1'b0: begin SRC_A = RS1; end
            1'b1: begin SRC_A = U_TYPE; end
        endcase
    end
    
endmodule
