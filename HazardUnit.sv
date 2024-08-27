`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California Polytechnic University, San Luis Obispo
// Engineer: Diego Curiel
// Create Date: 05/29/2023 04:37:08 PM
// Module Name: HazardUnit
//////////////////////////////////////////////////////////////////////////////////
module HazardUnit(
    input logic [6:0] opcode,
    input logic [4:0] de_adr1,
    input logic [4:0] de_adr2,
    input logic [4:0] ex_adr1,
    input logic [4:0] ex_adr2,
    input logic [4:0] ex_rd,
    input logic [4:0] mem_rd,
    input logic [4:0] wb_rd,
    input logic [1:0] pc_source,
    input logic mem_regWrite,
    input logic wb_regWrite,
    input logic de_rs1_used,
    input logic de_rs2_used,
    input logic ex_rs1_used,
    input logic ex_rs2_used,
    output logic [1:0] fsel1,
    output logic [1:0] fsel2,
    output logic load_use_haz,
    output logic control_haz,
    output logic flush
);

always_comb begin
    fsel1 = 2'b00;
    fsel2 = 2'b00;
    load_use_haz = 1'b0;
    control_haz = 1'b0;
    flush = 1'b0;

    //Selects for forwarding muxes
    if (mem_rd == ex_adr1 && ex_rs1_used && mem_regWrite)
        fsel1 = 2'b01;
    else if (wb_rd == ex_adr1 && ex_rs1_used && wb_regWrite)
        fsel1 = 2'b10;
    else
        fsel1 = 2'b00;
        
    if (mem_rd == ex_adr2 && ex_rs2_used && mem_regWrite)
        fsel2 = 2'b01;
    else if (wb_rd == ex_adr2 && ex_rs2_used && wb_regWrite)
        fsel2 = 2'b10;
    else
        fsel2 = 2'b00;
        
    //Load-use data hazard
    if ((opcode == 7'b0000011) && ((de_adr1 == ex_rd && de_rs1_used) || (de_adr2 == ex_rd && de_rs2_used)))
        load_use_haz = 1'b1;
    else
        load_use_haz = 1'b0;
    
    //Control hazards--jal,jalr,branchh
    if (pc_source != 2'b00) begin
        control_haz = 1'b1;
        flush = 1'b1;
    end
    else begin
        control_haz = 1'b0;
        flush = 1'b0;
    end
end

endmodule
