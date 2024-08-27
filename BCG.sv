`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly San Luis Obispo
// Engineer: Diego Curiel
// Create Date: 02/09/2023 11:30:51 AM
// Module Name: BCG
//////////////////////////////////////////////////////////////////////////////////

module BCG(
    input logic [31:0] RS1,
    input logic [31:0] RS2,
    output logic BR_EQ,
    output logic BR_LT,
    output logic BR_LTU
    );
    
    //Assign outputs using conditional logic operators.
    assign BR_LT = $signed(RS1) < $signed(RS2);
    assign BR_LTU = RS1 < RS2;
    assign BR_EQ = RS1 == RS2;
    
endmodule
