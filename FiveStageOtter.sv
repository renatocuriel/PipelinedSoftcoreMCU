`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California Polytechnic University, San Luis Obispo
// Engineer: Diego Curiel
// Create Date: 05/29/2023 04:37:08 PM
// Module Name: FiveStageOtter
//////////////////////////////////////////////////////////////////////////////////
typedef enum logic [6:0] {
       LUI = 7'b0110111,
       AUIPC = 7'b0010111,
       JAL = 7'b1101111,
       JALR = 7'b1100111,
       BRANCH = 7'b1100011,
       LOAD = 7'b0000011,
       STORE = 7'b0100011,
       ITYPE = 7'b0010011,
       RTYPE = 7'b0110011
} opcode_t;
        
typedef struct packed{
    opcode_t opcode;
    logic [4:0] rs1_addr;
    logic [4:0] rs2_addr;
    logic [4:0] rd_addr;
    logic rs1_used;
    logic rs2_used;
    logic rd_used;
    logic alu_srcA;
    logic [1:0] alu_srcB;
    logic [3:0] alu_fun;
    logic memWrite;
    logic memRead2;
    logic regWrite;
    logic [1:0] rf_wr_sel;
    logic [2:0] mem_type;  //sign, size
    logic [31:0] pc;
    logic [31:0] ir;
} instr_t;

typedef struct packed{
    logic [31:0] utype;
    logic [31:0] jtype;
    logic [31:0] btype;
    logic [31:0] itype;
    logic [31:0] stype;
} immed_t;

module FiveStageOtter(
    input logic RST,
    input logic [31:0] IOBUS_IN,
    input logic CLK,
    output logic IOBUS_WR,
    output logic [31:0] IOBUS_OUT,
    output logic [31:0] IOBUS_ADDR
    );
    
    //------------------FETCH----------------//
    logic pcWrite, memRead1, err;
    logic [1:0] pcSource;
    logic [31:0] jalr_if, jal_if, branch_if, pc_if, pc_inc_if;
    
    PC ProgramCounter(.CLK(CLK),
    .RST(RST),
    .PC_WRITE(pcWrite),
    .PC_SOURCE(pcSource),
    .JALR(jalr_if),
    .BRANCH(branch_if),
    .JAL(jal_if),
    .PC_OUT(pc_if));
    
    logic [31:0] pc_de;
    logic ld_use_hz, flush, hold_flush;
    always_ff@(posedge CLK) begin
        if(!ld_use_hz)
            pc_de <= pc_if;
            
        hold_flush <= flush;
    end
    
    
    
    assign pcWrite = !ld_use_hz;
    assign memRead1 = !ld_use_hz;
    
    //------------------MEMORY1: INSTR----------------//
    instr_t decode_t;
    immed_t imm_de;
    logic [31:0] ir_de;
    assign decode_t.ir = ir_de;
    logic [24:0] ir_imgen_de;
    assign ir_imgen_de = ir_de[31:7];
    logic [1:0] size_de;
    logic sign_de;

    logic [31:0] mem_wd, mem_rs2, mem_dout2;
    
    OTTER_mem_byte Memory(.MEM_CLK(CLK), .MEM_ADDR1(pc_if), .MEM_ADDR2(mem_wd),
     .MEM_DIN2(mem_rs2), .MEM_WRITE2(mem_t.memWrite) , .MEM_READ1(memRead1), .MEM_READ2(mem_t.memRead2), .ERR(err),
     .MEM_DOUT1(ir_de), .MEM_DOUT2(mem_dout2), .IO_IN(IOBUS_IN), .IO_WR(IOBUS_WR), .MEM_SIZE(size_de), .MEM_SIGN(sign_de));
    
    //--------------DECODE-------------------//
    assign decode_t.pc = pc_de;
    assign decode_t.rs1_addr = ir_de[19:15];
    assign decode_t.rs2_addr = ir_de[24:20];
    assign decode_t.rd_addr = ir_de[11:7];
    assign decode_t.opcode = opcode_t'(ir_de[6:0]);
    assign decode_t.mem_type = ir_de[14:12];
    logic [31:0] rs1_de, rs2_de;
    
    CU_DCDR Decoder(.IR(ir_de),
    .ALU_FUN(decode_t.alu_fun),
    .ALU_SRCA(decode_t.alu_srcA),
    .ALU_SRCB(decode_t.alu_srcB),
    .RF_WR_SEL(decode_t.rf_wr_sel),
    .REG_WRITE(decode_t.regWrite),
    .MEM_WRITE(decode_t.memWrite),
    .MEM_READ2(decode_t.memRead2));

    assign decode_t.rs1_used =  decode_t.rs1_addr != 0
                                && decode_t.opcode != LUI
                                && decode_t.opcode != AUIPC
                                && decode_t.opcode != JAL;
                                
    assign decode_t.rs2_used = decode_t.rs2_addr != 0 && (decode_t.opcode == BRANCH 
                                                            || decode_t.opcode == STORE
                                                            || decode_t.opcode == RTYPE);
                                                            
    assign decode_t.rd_used = decode_t.rd_addr != 0 //regWrite
                              && decode_t.opcode != BRANCH 
                              && decode_t.opcode != STORE;
     
    ImmediateGenerator ImGen(.IR(ir_imgen_de),
    .U_TYPE(imm_de.utype),
    .I_TYPE(imm_de.itype),
    .S_TYPE(imm_de.stype),
    .B_TYPE(imm_de.btype),
    .J_TYPE(imm_de.jtype));
    
    //--------REGFILE1: RS1, RS2-----------//
    logic [31:0] wb_wd;
    REG_FILE RegisterFile(.CLK(CLK),
    .EN(wb_t.regWrite),
    .ADR1(decode_t.rs1_addr),
    .ADR2(decode_t.rs2_addr),
    .WA(wb_t.rd_addr),
    .WD(wb_wd),
    .RS1(rs1_de),
    .RS2(rs2_de));
    
    //-----------------EXECUTE--------------//
    instr_t execute_t;
    immed_t imm_ex;
    logic [31:0] rs1_ex, rs2_ex;
    
    always_ff@(posedge CLK) begin
        execute_t <= decode_t;
        imm_ex <= imm_de;
        rs1_ex <= rs1_de;
        rs2_ex <= rs2_de;
        if (flush || hold_flush || ld_use_hz) begin //Bubbles for hazard handling
            execute_t.regWrite <= 1'b0;
            execute_t.memWrite <= 1'b0;
            execute_t.ir <=32'd0;
        end
    end
    
    //---------HAZARD HANDLING, FORWARDING-------------//
    logic [1:0] fsel1, fsel2;
    logic [31:0] frs1_ex, frs2_ex;
    logic [6:0] ex_load_op;
    logic cntrl_haz;
    assign ex_load_op = execute_t.ir[6:0];
    
    HazardUnit HazardUnit(.opcode(ex_load_op),
    .de_adr1(decode_t.rs1_addr),
    .de_adr2(decode_t.rs2_addr),
    .ex_adr1(execute_t.rs1_addr),
    .ex_adr2(execute_t.rs2_addr),
    .ex_rd(execute_t.rd_addr),
    .mem_rd(mem_t.rd_addr),
    .wb_rd(wb_t.rd_addr),
    .pc_source(pcSource),
    .mem_regWrite(mem_t.regWrite),
    .wb_regWrite(wb_t.regWrite),
    .de_rs1_used(decode_t.rs1_used),
    .de_rs2_used(decode_t.rs2_used),
    .ex_rs1_used(execute_t.rs1_used),
    .ex_rs2_used(execute_t.rs2_used),
    .fsel1(fsel1),
    .fsel2(fsel2),
    .load_use_haz(ld_use_hz),
    .control_haz(cntrl_haz),
    .flush(flush));
    
//    assign fsel1 = 1'b0;
    
    FourMux FRS1(.SEL(fsel1),
    .ZERO(rs1_ex),
    .ONE(mem_wd),
    .TWO(wb_wd),
    .THREE(32'h00000000),
    .OUT(frs1_ex));
    
    FourMux FRS2(.SEL(fsel2),
    .ZERO(rs2_ex),
    .ONE(mem_wd),
    .TWO(wb_wd),
    .THREE(32'h00000000),
    .OUT(frs2_ex));
    
    //instantiate ALU Muxes and ALU with potentially forwarded values
    logic [31:0] srcA, srcB;
    TwoMux SRCA(.ALU_SRC_A(execute_t.alu_srcA),
    .RS1(frs1_ex),
    .U_TYPE(imm_ex.utype),
    .SRC_A(srcA));
    
    FourMux SRCB(.SEL(execute_t.alu_srcB),
    .ZERO(frs2_ex),
    .ONE(imm_ex.itype),
    .TWO(imm_ex.stype),
    .THREE(execute_t.pc),
    .OUT(srcB));
    
    logic [31:0] alu_res;
    ALU ArithmeticLogicUnit(.SRC_A(srcA),
    .SRC_B(srcB),
    .ALU_FUN(execute_t.alu_fun),
    .RESULT(alu_res));
    
    //----------BRANCH-----------//
    BranchUnit BranchUnit(.IR(execute_t.ir),
    .RS1(frs1_ex),
    .RS2(frs2_ex),
    .PC_SOURCE(pcSource));
    
    BAG BranchAddressGen(.RS1(frs1_ex),
    .I_TYPE(imm_ex.itype),
    .J_TYPE(imm_ex.jtype),
    .B_TYPE(imm_ex.btype),
    .FROM_PC(execute_t.pc),
    .JAL(jal_if),
    .JALR(jalr_if),
    .BRANCH(branch_if));
    
    //--------MEMORY2: WRITE-----------//
    instr_t mem_t;
    immed_t imm_mem;
    
    assign size_de = mem_t.ir[13:12];
    assign sign_de = mem_t.ir[14];
    
    always_ff@(posedge CLK) begin
        mem_t <= execute_t;
        imm_mem <= imm_ex;
        mem_wd <= alu_res;
        mem_rs2 <= frs2_ex;
    end
    
    assign IOBUS_ADDR = mem_wd;
    assign IOBUS_OUT = mem_rs2;
    
    //-------------WRITE BACK-----------//
    instr_t wb_t;
    logic [31:0] aluRes_wb, pcInc;
    always_ff@(posedge CLK) begin
        wb_t <= mem_t;
        aluRes_wb <= mem_wd;
    end
    
    assign pcInc = wb_t.pc + 4;
    
    //mux for wd at Reg File
    FourMux RegMux(.SEL(wb_t.rf_wr_sel),
    .ZERO(pcInc),
    .ONE(32'h00000000),
    .TWO(mem_dout2),
    .THREE(aluRes_wb),
    .OUT(wb_wd));
    
endmodule
