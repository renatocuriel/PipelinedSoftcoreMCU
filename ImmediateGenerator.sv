`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly San Luis Obispo
// Engineer: Diego Curiel
// Create Date: 02/09/2023 11:02:37 AM
// Module Name: ImmediateGenerator
//////////////////////////////////////////////////////////////////////////////////

module ImmediateGenerator(
    input logic [24:0] IR,
    output logic [31:0] U_TYPE,
    output logic [31:0] I_TYPE,
    output logic [31:0] S_TYPE,
    output logic [31:0] B_TYPE,
    output logic [31:0] J_TYPE
    );
    
    //Assign each immediate value. 
    assign I_TYPE = {{21{IR[24]}}, IR[23:18], IR[17:13]};
    assign S_TYPE = {{21{IR[24]}}, IR[23:18], IR[4:0]};
    assign B_TYPE = {{20{IR[24]}}, IR[0], IR[23:18], IR[4:1], 1'b0};
    assign U_TYPE = {IR[24:5], 12'b0};
    assign J_TYPE = {{12{IR[24]}}, IR[12:5], IR[13], IR[23:14], 1'b0};
    
endmodule
