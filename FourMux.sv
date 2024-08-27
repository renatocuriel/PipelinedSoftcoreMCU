`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California Polytechnic University, San Luis Obispo
// Engineer: Diego Renato Curiel
// Create Date: 02/25/2023 10:55:14 PM
// Module Name: FourMux
//////////////////////////////////////////////////////////////////////////////////

module FourMux(
    input logic [1:0] SEL,
    input logic [31:0] ZERO,
    input logic [31:0] ONE,
    input logic [31:0] TWO,
    input logic [31:0] THREE,
    output logic [31:0] OUT
    );
    
    //Create a generic, four-to-one MUX. To be used for the Reg File
    //and the ALU.
    always_comb begin
        case(SEL) //Case dependent on Select.
            2'b00: begin OUT = ZERO; end
            2'b01: begin OUT = ONE; end
            2'b10: begin OUT = TWO; end
            2'b11: begin OUT = THREE; end
            default: begin OUT = 32'b0; end
        endcase
    end
    
endmodule
