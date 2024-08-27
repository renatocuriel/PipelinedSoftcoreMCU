`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California Polytechnic University, San Luis Obispo
// Engineer: Diego Renato Curiel
// Create Date: 01/24/2023 09:30:07 AM
// Module Name: PC_REG
//////////////////////////////////////////////////////////////////////////////////

module PC_REG(
    input logic CLK,
    input logic RST,
    input logic D,
    input logic [31:0] IN,
    output logic [31:0] OUT
    );
    
    //Create PC Register!
    always_ff@(posedge CLK) begin
        if (RST == 1'b1) begin //If reset is high, set PC output to 0
            OUT <= 32'h00000000;
        end
        else if (D == 1'b1) begin //if Reset is low and D is high,
            OUT <= IN;              //set PC output to the input!
        end
    end
    
endmodule
