module priority_controller (
    input logic [6:0] p_signal, // From all functional units
    input logic [4:0] p_signal_start, // From pipelined functional units

    output logic [5:0] stall,
    output logic id_exe_reg_clr_priority, // to be ORed with id_exe_reg_clr
    output priority_t p_sel
);

    logic [2:0] p_signal_sum;
    logic collision;
    logic [4:0] copy_hazard; // Write-after-write (WAW) hazards 

    always_comb begin

        p_sel = p_signal[0] ? FDIVU : // FDIVU
                p_signal[1] ? FMULU : // FMULU
                p_signal[2] ? FADD_SUBU : // FADD_SUBU
                p_signal[3] ? DIVU : // DIVU
                p_signal[4] ? MULU : // MULU
                p_signal[5] ? FPU : // FPU
                p_signal[6] ? ALU : DEFAULT; // ALU

        // Perform bitwise addition
        p_signal_sum = p_signal[6] + p_signal[5] + p_signal[4] + p_signal[3] + p_signal[2] + p_signal[1] + p_signal[0];
        
        // Detect the possibility of collision (more than one unit writing into EXE/MEM reg simultaneously)
        collision = (p_signal_sum >= 2) ? 1 : 0; 

        // Stall pipelined units        
        stall[0] = collision & ~(p_sel == FDIVU); // stall FDIVU
        stall[1] = collision & ~(p_sel == FMULU); // stall FMULU
        stall[2] = collision & ~(p_sel == FADD_SUBU); // stall FADD_SUBU
        stall[3] = collision & ~(p_sel == DIVU); // stall DIVU
        stall[4] = collision & ~(p_sel == MULU); // stall MULU
        stall[5] = collision; // stall the system pipeline

        // Write-after-write (WAW) hazards 
        copy_hazard = p_signal_start & p_signal[4:0];

        id_exe_reg_clr_priority = collision & (((p_sel == FDIVU) & copy_hazard[0])
                                              |((p_sel == FMULU) & copy_hazard[1])
                                              |((p_sel == FADD_SUBU) & copy_hazard[2])
                                              |((p_sel == DIVU) & copy_hazard[3])
                                              |((p_sel == MULU) & copy_hazard[4]));
    end

endmodule
