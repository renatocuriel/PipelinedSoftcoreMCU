`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California Polytechnic University, San Luis Obispo
// Engineer: Diego Curiel
// Create Date: 01/31/2023 09:24:40 AM
// Module Name: REG_FILE
// Project Name: OTTER
//////////////////////////////////////////////////////////////////////////////////

module REG_FILE(
    input logic CLK,
    input logic EN,
    input logic [4:0] ADR1,
    input logic [4:0] ADR2,
    input logic [4:0] WA,
    input logic [31:0] WD,
    output logic [31:0] RS1,
    output logic [31:0] RS2
    );
    
    //Instantiate 32, 32-bit registers
    logic [31:0] ram[0:31];
    
    //Initialize all registers to 0. 
    initial begin
    static int i = 0;
        for (i = 0; i < 32; i++) begin
        ram[i] = 0;
        end
    end
    
    //Create asynchronous reads for RS1, RS2
    assign RS1 = ram[ADR1];
    assign RS2 = ram[ADR2];
   
   //Create register flip flop while ensuring that register
   //0 (x0) is never written to and remains 0.
    always_ff@(negedge CLK) begin
        if (EN == 1'b1 && !WA == 5'd0) begin
            ram[WA] <= WD;
        end
    end 
    
endmodule
