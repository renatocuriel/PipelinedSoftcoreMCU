`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////
// Company:   Cal Poly
// Engineer:  Paul Hummel
// 
// Create Date: 01/04/2020 01:00:34 AM
// Module Name: ProgRom
// Target Devices: OTTER MCU on Basys3
// Description:  Generic 16384x32 ROM device
// 
// Dependencies: prog_rom.mem file is a raw listing of 16384 32-bit hex values
//               prog_rom.mem file is automatically created by the OTTER
//               assembler / simulator from an assembly code program.
// 
// Revision:
// Revision 0.01 - File Created
// 
//////////////////////////////////////////////////////////////////////////////

module ProgRom(
    input PROG_CLK,
    input [31:0] PROG_ADDR,
    output logic [31:0] INSTRUCT
    );

    logic [13:0] wordAddr;

    // convert byte address to word address
    assign wordAddr = PROG_ADDR[15:2];
    
    (* rom_style="{distributed | block}" *) 
    (* ram_decomp = "power" *) logic [31:0] rom [0:16383];
    
    // initialize the ROM with the otter_memory.mem file
    initial begin
        $readmemh("otter_mem.mem", rom, 0, 16383);
    end 
    
    always_ff @(posedge PROG_CLK) begin
        INSTRUCT <= rom[wordAddr];
    end
              
endmodule