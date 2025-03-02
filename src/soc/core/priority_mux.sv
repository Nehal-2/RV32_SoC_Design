module priority_mux #(
    parameter PIPELINE_WIDTH = 128
)(
    input priority_t p_sel,

    // ARITHMITIC UNITS SIGNALS
    // ALU
    input logic [31:0] alu_result,
    // input logic zero,
    input logic [31:0] alu_pipeline_signals, // ADJUST SIZE

    // FPU
    input logic [31:0] fpu_result,
    input logic [31:0] fpu_pipeline_signals, // ADJUST SIZE

    // MULTIPLICATION UNIT
    input logic [31:0] mul_result,
    input logic [31:0] mul_pipeline_signals, // mul_pipeline_control

    // DIVISION UNIT
    input logic [31:0] div_result,
    // ADD DIV UNIT FLAGS
    input logic [31:0] div_pipeline_signals, // ADJUST SIZE

    // FLOATING POINT MULTIPLICATION
    input logic [31:0] fmul_result,
    input logic [31:0] fmul_pipeline_signals, // ADJUST SIZE

    // FLOATING POINT DIVISION 
    input logic [31:0] fdiv_result,
    input logic [31:0] fdiv_pipeline_signals, // ADJUST SIZE

    // FLOATING POINT ADDITION/SUBTRACTION
    input logic [31:0] fadd_sub_result,
    input logic [31:0] fadd_sub_pipeline_signals, // ADJUST SIZE

    // PIPELINED SIGNALS
    input logic [31:0] current_pc, 
    input logic [31:0] pc_plus_4,
    input logic [31:0] imm,
    // ADD PIPELINED CONTROL SIGNALS

    output logic [31:0] p_result,
    output logic [PIPELINE_WIDTH-1:0] p_pipeline_signals
    // ADD SPECIAL OUTPUTS (EX: DIV FLAGS & PIPLINED CONTROL SIGNALS)
);
    
    always_comb begin
        case(p_sel) // ADD OTHER SPECIAL OUTPUTS
            ALU: begin
                p_result = alu_result;
                p_pipeline_signals = {current_pc, pc_plus_4, imm, alu_pipeline_signals};
            end
            FPU: begin
                p_result = fpu_result;
                p_pipeline_signals = {current_pc, pc_plus_4, imm, fpu_pipeline_signals};
            end
            MULU: begin
                p_result = mul_result;
                p_pipeline_signals = {current_pc, pc_plus_4, imm, mul_pipeline_signals};
            end
            DIVU: begin
                p_result = div_result;
                p_pipeline_signals = {current_pc, pc_plus_4, imm, div_pipeline_signals};
            end
            FMULU: begin
                p_result = fmul_result;
                p_pipeline_signals = {current_pc, pc_plus_4, imm, fmul_pipeline_signals};
            end
            FDIVU: begin
                p_result = fdiv_result;
                p_pipeline_signals = {current_pc, pc_plus_4, imm, fdiv_pipeline_signals};
            end
            FADD_SUBU: begin
                p_result = fadd_sub_result;
                p_pipeline_signals = {current_pc, pc_plus_4, imm, fadd_sub_pipeline_signals};
            end
            default: begin
                p_result = alu_result;
                p_pipeline_signals = {current_pc, pc_plus_4, imm, alu_pipeline_signals};
            end
        endcase
    end
endmodule
