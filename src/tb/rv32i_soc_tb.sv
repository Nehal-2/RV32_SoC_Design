//module rv32i_soc_tb;
//    logic clk;
//    logic reset_n;
//    logic o_flash_sclk;
//    logic o_flash_cs_n;
//    logic o_flash_mosi;
//    logic i_flash_miso;

//    // uart signals
//   logic  o_uart_tx;
//   logic i_uart_rx;
//   logic  uart_rts; // Request To Send
//   logic uart_cts; // Clear To Send
//    wire [31:0] io_data;




//    // Dut instantiation
//    rv32i_soc DUT(
//        .*
//    );

//    // Clock generator 
//    initial clk = 0;
//    always #5 clk = ~clk;

//    // signal geneartion here
//    initial begin 
//        reset_n = 0;
//        repeat(2) @(negedge clk);
//        reset_n = 1; // dropping reset after two clk cycles
//    end


//   // initializing the instruction memory after every reset
//   initial begin
//       $readmemh("/home/it/Chip_Design/final_microprocessor_soc/RV32_SoC_Design/inst.mem", DUT.inst_mem_inst.dmem);
//   end // wait 

//   initial begin 
//    //    repeat(100000) @(posedge clk);
//    //    for(int i = 0; i<= 14'h0fff; i = i+1) begin 
//    //        $display("imem[%02d] = %8h", i, DUT.inst_mem_inst.memory[i]);
//    //    end
//       repeat(10000) @(posedge clk);
//       for(int i = 0; i < 100; i = i+1) begin 
//           $display("dmem[%02d] => %8h <=> %8h <= imem[%02d] ", i, DUT.data_mem_inst.dmem[i], DUT.inst_mem_inst.dmem[i], i);
//       end
//        for(int i = 0; i<32; i = i+1) begin 
//            $display("reg_file[%02d] = %03d", i, DUT.processor_core.data_path_inst.reg_file_inst.reg_file[i]);
//        end
//       $finish;
//   end
//initial begin
//  $dumpfile("waveform.vcd");
//  $dumpvars(0, DUT);
////   $dumpvars(0, DUT.data_mem_inst);
////   $dumpvars(0, DUT.inst_mem_inst);
//end

//    //assign DUT.uart_inst.srx_pad_i=DUT.uart_inst.stx_pad_o;
//    assign i_uart_rx= o_uart_tx;
//    initial begin
//        // Initialize signals
//        clk = 0;
//        reset_n = 0;
        
//        end
//// initial begin
////   // Enable VCD file dumping
////   $dumpfile("waveform.vcd");
  
////   // Force signals for data memory
////   $dumpvars(0, DUT.data_mem_inst);  // Force signals inside data_mem_inst
  
////   // Force signals for instruction memory
////   $dumpvars(0, DUT.inst_mem_inst);  // Force signals inside inst_mem_inst
  
////   // Optionally force other internal signals if needed
////   $dumpvars(0, DUT.wb_m2s_dmem_adr, DUT.wb_m2s_dmem_dat, DUT.wb_s2m_dmem_dat);
////   $dumpvars(0, DUT.wb_m2s_imem_adr, DUT.wb_m2s_imem_dat, DUT.wb_s2m_imem_dat);
//// end

//endmodule

module rv32i_soc_tb;
    logic clk;
    logic reset_n;
    logic o_flash_sclk;
    logic o_flash_cs_n;
    logic o_flash_mosi;
    logic i_flash_miso;

    // uart signals
   logic  o_uart_tx;
   logic i_uart_rx;
   logic  uart_rts; // Request To Send
   logic uart_cts; // Clear To Send
    wire [31:0] io_data;




    // Dut instantiation
    rv32i_soc DUT(
        .*
    );

    // Clock generator 
    initial clk = 0;
    always #5 clk = ~clk;

    // signal geneartion here
    initial begin 
        reset_n = 0;
        repeat(2) @(negedge clk);
        reset_n = 1; // dropping reset after two clk cycles
    end


   // initializing the instruction memory after every reset
   initial begin
       $readmemh("/home/it/Chip_Design/final_microprocessor_soc/RV32_SoC_Design/inst.mem", DUT.inst_mem_inst.dmem);
   end // wait 

   initial begin 
    //    repeat(100000) @(posedge clk);
    //    for(int i = 0; i<= 14'h0fff; i = i+1) begin 
    //        $display("imem[%02d] = %8h", i, DUT.inst_mem_inst.memory[i]);
    //    end
       repeat(10000) @(posedge clk);
       for(int i = 0; i < 100; i = i+1) begin 
           $display("dmem[%02d] => %8h <=> %8h <= imem[%02d] ", i, DUT.data_mem_inst.dmem[i], DUT.inst_mem_inst.dmem[i], i);
       end
        for(int i = 0; i<32; i = i+1) begin 
            $display("reg_file[%02d] = %03d", i, DUT.processor_core.data_path_inst.reg_file_inst.reg_file[i]);
        end
       $finish;
   end
initial begin
  $dumpfile("waveform.vcd");
  $dumpvars(0, DUT);
//   $dumpvars(0, DUT.data_mem_inst);
//   $dumpvars(0, DUT.inst_mem_inst);
end

    //assign DUT.uart_inst.srx_pad_i=DUT.uart_inst.stx_pad_o;
    assign i_uart_rx= o_uart_tx;
    initial begin
        // Initialize signals
        clk = 0;
        reset_n = 0;
        
        end
// initial begin
//   // Enable VCD file dumping
//   $dumpfile("waveform.vcd");
  
//   // Force signals for data memory
//   $dumpvars(0, DUT.data_mem_inst);  // Force signals inside data_mem_inst
  
//   // Force signals for instruction memory
//   $dumpvars(0, DUT.inst_mem_inst);  // Force signals inside inst_mem_inst
  
//   // Optionally force other internal signals if needed
//   $dumpvars(0, DUT.wb_m2s_dmem_adr, DUT.wb_m2s_dmem_dat, DUT.wb_s2m_dmem_dat);
//   $dumpvars(0, DUT.wb_m2s_imem_adr, DUT.wb_m2s_imem_dat, DUT.wb_s2m_imem_dat);
// end

endmodule