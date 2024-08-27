`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California Polytechnic University, San Luis Obispo
// Engineer: Diego Renato Curiel
// Create Date: 06/04/2023 07:47:28 PM
// Design Name: Pipelined Otter, Five-Stage
// Module Name: BranchUnit
//////////////////////////////////////////////////////////////////////////////////
module BranchUnit(
    input logic [31:0] IR,
    input logic [31:0] RS1,
    input logic [31:0] RS2,
    output logic [1:0] PC_SOURCE
    );
    
    logic [6:0] OPCODE;
    logic [2:0] IR_FUNCT;
    logic IR_30;
    assign OPCODE = IR[6:0];
    assign IR_FUNCT = IR[14:12];
    assign IR_30 = IR[30];
    
    logic BR_EQ, BR_LT, BR_LTU;
    BCG BranchCondition(.RS1(RS1),
    .RS2(RS2),
    .BR_EQ(BR_EQ),
    .BR_LT(BR_LT),
    .BR_LTU(BR_LTU));
    
    always_comb begin
        PC_SOURCE = 2'b00;
        case(OPCODE)
            7'b1101111: begin // JAL
                    PC_SOURCE = 2'b11;
            end
            7'b1100111: begin // JALR
                    PC_SOURCE = 2'b01;
            end
            7'b1100011: begin // B-Type
                    //nested case statement dependent on the
                    //function three bits.
                    //Because there are six real branch instructions, there
                    //are six pairs of if-else statements in each of six cases
                    //for the branch instructions.
                    case(IR_FUNCT)
                        3'b000: begin
                            if (BR_EQ == 1'b1)
                                PC_SOURCE = 2'b10;
                            else
                                PC_SOURCE = 2'b00; 
                        end
                        3'b001: begin 
                            if (BR_EQ == 1'b0)
                                PC_SOURCE = 2'b10;
                            else
                                PC_SOURCE = 2'b00; 
                        end
                        3'b100: begin 
                            if (BR_LT == 1'b1)
                                PC_SOURCE = 2'b10;
                            else
                                PC_SOURCE = 2'b00;
                        end
                        3'b101: begin 
                            if (BR_LT == 1'b0)
                                PC_SOURCE = 2'b10;
                            else
                                PC_SOURCE = 2'b00;
                        end
                        3'b110: begin 
                            if (BR_LTU == 1'b1)
                                PC_SOURCE = 2'b10;
                            else
                                PC_SOURCE = 2'b00;
                        end
                        3'b111: begin 
                            if (BR_LTU == 1'b0)
                                PC_SOURCE = 2'b10;
                            else
                                PC_SOURCE = 2'b00;
                        end
                        default: begin
                            PC_SOURCE = 2'b00;
                        end
                    endcase
                end
                default: begin
                    PC_SOURCE = 2'b00;
                end
            endcase
        end
endmodule
