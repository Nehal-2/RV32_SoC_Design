// THIRD ATTEMPT
module rv32i_soc #(
    parameter DMEM_DEPTH = 128,
    parameter IMEM_DEPTH = 128
) (
    input logic clk, 
    input logic reset_n,

    // spi signals to the spi-flash

    // uart signals
    output o_uart_tx,
    input i_uart_rx,
    output uart_rts, // Request To Send
    input uart_cts, // Clear To Send
    
    // gpio signals
    inout wire [31:0]   io_data
);

    assign io_data[32:16] = 4'ha;

    // Memory bus signals
    logic [31:0] mem_addr_mem;
    logic [31:0] mem_wdata_mem; 
    logic        mem_write_mem;
    logic [2:0]  mem_op_mem;
    logic [31:0] mem_rdata_mem;
    logic        mem_read_mem;

    

    // ============================================
    //          Processor Core Instantiation
    // ============================================
    
    // Instantiate the processor core here 
    logic [31:0] current_pc;
    logic [31:0] inst;
    logic stall_pipl, if_id_reg_en;

    rv32i #(
      .DMEM_DEPTH(DMEM_DEPTH),
      .IMEM_DEPTH(IMEM_DEPTH)
    ) processor_core (
      .clk(clk),
      .reset_n(reset_n),

    // memory bus
    .mem_addr_mem(mem_addr_mem),
    .mem_wdata_mem(mem_wdata_mem),
    .mem_write_mem(mem_write_mem),
    .mem_op_mem(mem_op_mem),
    .mem_rdata_mem(mem_rdata_mem),
    .mem_read_mem(mem_read_mem),

    // inst mem access 
    .current_pc(current_pc),
    .inst(inst),

    // stall signal from wishbone 
    .stall_pipl(stall_pipl),
    .if_id_reg_en(if_id_reg_en)
);

    // ============================================
    //                 Wishbone Master 
    // ============================================

    // // Wishbone bus signals
    // reg  [31:0] wb_adr_o,      // Wishbone address output
    // reg  [31:0] wb_dat_o,      // Wishbone data output
    // reg  [3:0]  wb_sel_o,      // Wishbone byte enable
    // reg         wb_we_o,       // Wishbone write enable
    // reg         wb_cyc_o,      // Wishbone cycle valid
    // reg         wb_stb_o,      // Wishbone strobe
    // wire [31:0] wb_dat_i,      // Wishbone data input
    // wire        wb_ack_i       // Wishbone acknowledge
    // logic [ 2:0] wb_io_cti_i;  // from -->  wb_m2s_io_cti
    // logic [ 1:0] wb_io_bte_i;  // from -->  wb_m2s_io_bte
    // wishbone_controller wishbone_master (
    //     .clk        (clk),
    //     .rst        (~reset_n),
    //     .proc_addr  (mem_addr_mem),
    //     .proc_wdata (mem_wdata_mem),
    //     .proc_write (mem_write_mem),
    //     .proc_read  (mem_read_mem),
    //     .proc_op    (mem_op_mem),
    //     .proc_rdata (mem_rdata_mem),
    //     .proc_stall_pipl(stall_pipl), // Stall pipeline if needed
    //     // OUR CONNECTION
    //     .wb_adr_o   (wb_adr_o),     // Connect to the external Wishbone bus as required
    //     .wb_dat_o   (wb_dat_o),
    //     .wb_sel_o   (wb_sel_o),
    //     .wb_we_o    (wb_we_o),
    //     .wb_cyc_o   (wb_cyc_o),
    //     .wb_stb_o   (wb_stb_o),
    //     .wb_dat_i   (/*connect these signals*/), // For simplicity, no data input
    //     .wb_ack_i   (/*connect these signals*/)   // For simplicity, no acknowledgment signal
    // );

    // IO ( wb master signals )
    logic [31:0] wb_io_adr_i;
    logic [31:0] wb_io_dat_i;
    logic  [3:0] wb_io_sel_i;
    logic        wb_io_we_i;
    logic        wb_io_cyc_i;
    logic        wb_io_stb_i;
    logic  [2:0] wb_io_cti_i;
    logic  [1:0] wb_io_bte_i;
    logic [31:0] wb_io_dat_o;
    logic        wb_io_ack_o;
    logic        wb_io_err_o;
    logic        wb_io_rty_o;    
    
    wishbone_controller wishbone_master (
        .clk        (clk),
        .rst        (~reset_n),
        .proc_addr  (mem_addr_mem),
        .proc_wdata (mem_wdata_mem),
        .proc_write (mem_write_mem),
        .proc_read  (mem_read_mem),
        .proc_op    (mem_op_mem),
        .proc_rdata (mem_rdata_mem),
        .proc_stall_pipl(stall_pipl), // Stall pipeline if needed
        // OUR CONNECTIONS
        .wb_adr_o   (wb_io_adr_i),     // Connect to the external Wishbone bus as required
        .wb_dat_o   (wb_io_dat_i),
        .wb_sel_o   (wb_io_sel_i),
        .wb_we_o    (wb_io_we_i),
        .wb_cyc_o   (wb_io_cyc_i),
        .wb_stb_o   (wb_io_stb_i),
        .wb_dat_i   (wb_io_dat_o), // wb_io_dat_o changed it from 0
        .wb_ack_i   (wb_io_ack_o)   // For simplicity, no acknowledgment signal
    );

    logic [2:0] wb_m2s_io_cti;
    logic [1:0] wb_m2s_io_bte;

    assign wb_m2s_io_cti = 0;
    assign wb_m2s_io_bte  = 0;

    
    // ============================================
    //             Wishbone Interconnect 
    // ============================================
    
    // Instantiate the wishbone interconnect here
    assign wb_io_cti_i   = wb_m2s_io_cti;
    assign wb_io_bte_i   = wb_m2s_io_bte;

    // SPI FLASH SIGNALS 
    logic [31:0] wb_spi_flash_adr_o;
    logic [31:0] wb_spi_flash_dat_o;
    logic  [3:0] wb_spi_flash_sel_o;
    logic        wb_spi_flash_we_o;
    logic        wb_spi_flash_cyc_o;
    logic        wb_spi_flash_stb_o;
    logic  [2:0] wb_spi_flash_cti_o;
    logic  [1:0] wb_spi_flash_bte_o;
    logic [31:0] wb_spi_flash_dat_i;
    logic        wb_spi_flash_ack_i;
    logic        wb_spi_flash_err_i;
    logic        wb_spi_flash_rty_i;

    // DATA MEM
    logic [31:0] wb_dmem_adr_o;
    logic [31:0] wb_dmem_dat_o;
    logic  [3:0] wb_dmem_sel_o;
    logic        wb_dmem_we_o;
    logic        wb_dmem_cyc_o;
    logic        wb_dmem_stb_o;
    logic  [2:0] wb_dmem_cti_o;
    logic  [1:0] wb_dmem_bte_o;
    logic [31:0] wb_dmem_dat_i;
    logic        wb_dmem_ack_i;
    logic        wb_dmem_err_i;
    logic        wb_dmem_rty_i;

    
    // IMEM
    logic [31:0] wb_imem_adr_o;
    logic [31:0] wb_imem_dat_o;
    logic  [3:0] wb_imem_sel_o;
    logic        wb_imem_we_o;
    logic        wb_imem_cyc_o;
    logic        wb_imem_stb_o;
    logic  [2:0] wb_imem_cti_o;
    logic  [1:0] wb_imem_bte_o;
    logic [31:0] wb_imem_dat_i;
    logic        wb_imem_ack_i;
    logic        wb_imem_err_i;
    logic        wb_imem_rty_i;

    // UART 
    logic [31:0] wb_uart_adr_o;
    logic [31:0] wb_uart_dat_o;
    logic  [3:0] wb_uart_sel_o;
    logic        wb_uart_we_o;
    logic        wb_uart_cyc_o;
    logic        wb_uart_stb_o;
    logic  [2:0] wb_uart_cti_o;
    logic  [1:0] wb_uart_bte_o;
    logic [31:0] wb_uart_dat_i;
    logic        wb_uart_ack_i;
    logic        wb_uart_err_i;
    logic        wb_uart_rty_i;

    // GPIO
    logic [31:0] wb_gpio_adr_o;
    logic [31:0] wb_gpio_dat_o;
    logic  [3:0] wb_gpio_sel_o;
    logic        wb_gpio_we_o;
    logic        wb_gpio_cyc_o;
    logic        wb_gpio_stb_o;
    logic  [2:0] wb_gpio_cti_o;
    logic  [1:0] wb_gpio_bte_o;
    logic [31:0] wb_gpio_dat_i;
    logic        wb_gpio_ack_i;
    logic        wb_gpio_err_i;
    logic        wb_gpio_rty_i;
    logic        wb_inta_o; // ADDED

    wb_intercon interconnect_inst
   (.*,
   .wb_clk_i(clk),
    .wb_rst_i(reset_n),
    .wb_io_cti_i(0),  // use "wb_m2s_io_cti" --> but it's always 0
    .wb_io_bte_i(0)  // ue "wb_m2s_io_bte" --> but it's always 0
    );


    // ============================================
    //                   Peripherals 
    // ============================================
    // Instantate the peripherals here

    // Here is the tri state buffer logic for setting iopin as input or output based
    // on the bits stored in the en_gpio register
    wire [31:0] en_gpio;
    wire        gpio_irq;

    logic [31:0] i_gpio;
    wire [31:0] o_gpio;

    genvar i;
    generate
            for( i = 0; i<32; i = i+1) 
            begin:gpio_gen_loop
                bidirec gpio1  (.oe(en_gpio[i] ), .inp(o_gpio[i] ), .outp(i_gpio[i] ), .bidir(io_data[i] ));
            end    
    endgenerate

    // ============================================
    //                 GPIO Instantiation
    // ============================================

    // Instantiate the GPIO peripheral here 
    gpio_top gpio_inst(
	// WISHBONE Interface
	.wb_clk_i(clk), 
    .wb_rst_i(~reset_n), // active-high?
    .wb_cyc_i(wb_gpio_cyc_o), 
    .wb_adr_i(wb_gpio_adr_o[7:0]), // [9:2]?? 
    .wb_dat_i(wb_gpio_dat_o), 
    .wb_sel_i(wb_gpio_sel_o), 
    .wb_we_i(wb_gpio_we_o), 
    .wb_stb_i(wb_gpio_stb_o),
	.wb_dat_o(wb_gpio_dat_i), 
    .wb_ack_o(wb_gpio_ack_i), 
//    .wb_err_o(wb_gpio_err_i), // Not used currently
    .wb_inta_o(wb_inta_o),

    // 
    .i_gpio(i_gpio),
    .o_gpio(o_gpio),
    .en_gpio(en_gpio)
    );

    // // ============================================
    // //                 SPI Instantiation
    // // ============================================
    
    // // SPI FLASH External Connections 
    // logic sck_o;
    // logic [31:0] mosi_o, miso_i;
    // localparam SS_WIDTH = 1;
    // logic [SS_WIDTH-1:0] ss_o = 1'b0;

    // assign mosi_o = wb_io_dat_i;
    // assign miso_i = wb_io_dat_o;

    // simple_spi #(
    // .SS_WIDTH(SS_WIDTH)
    // ) spi_inst (
    // // 8bit WISHBONE bus slave interface
    // .clk_i(clk),         // clock
    // .rst_i(reset_n),         // reset (synchronous active high) // DOCUMENTATION SAYS OTHERWISE (Asynchronous active low reset)
    // .cyc_i(wb_spi_flash_cyc_o),         // cycle
    // .stb_i(wb_spi_flash_stb_o),         // strobe
    // .adr_i(wb_spi_flash_adr_o[2:0]),         // [2:0] address
    // .we_i(wb_spi_flash_we_o),          // write enable
    // .dat_i(wb_spi_flash_dat_o[7:0]),         // [7:0] data input 
    // .dat_o(wb_spi_flash_dat_i[7:0]),         // [7:0] data output
    // .ack_o(wb_spi_flash_ack_i),         // normal bus termination
    // // .inta_o,        // interrupt output

    // // SPI port
    // .sck_o(sck_o),         // serial clock output
    // .ss_o(ss_o),      // [SS_WIDTH-1:0] slave select (active low)
    // .mosi_o(mosi_o),        // MasterOut SlaveIN
    // .miso_i(miso_i)         // MasterIn SlaveOut
    // );

     // ============================================
     //                 UART Instantiation
     // ============================================

     // UART serial interface
//     logic uart_tx; // FPGA to PC
//     logic uart_rx; // PC to FPGA

     // Modem signals (Optional)
//     wire uart_rts = 1'b0; // Request To Send
//     wire uart_cts = 1'b0; // Clear To Send
//     wire uart_dtr = 1'b0; // Data Terminal Ready
//     wire uart_dsr = 1'b0; // Data Set Ready
//     wire uart_ri = 1'b0; // Ring Indicator
//     wire uart_dcd = 1'b0; // Data Carrier Detect


     logic uart_dtr; // Data Terminal Ready
     logic uart_dsr; // Data Set Ready
     logic uart_ri; // Ring Indicator
     logic uart_dcd; // Data Carrier Detect
     logic int_o;
     
     uart_top uart_inst (
         // ViDB0 is not defined
     // `ifdef ViDBo
     //     tf_push,
     // `endif

         .wb_clk_i(clk), 
        
         // Wishbone signals
         .wb_rst_i(~reset_n), // ACTIVE HIGH?
         .wb_adr_i(wb_uart_adr_o[2:0]), 
         .wb_dat_i(wb_uart_dat_o[7:0]), 
         .wb_dat_o(wb_uart_dat_i[7:0]), 
         .wb_we_i(wb_uart_we_o), 
         .wb_stb_i(wb_uart_stb_o), 
         .wb_cyc_i(wb_uart_cyc_o), 
         .wb_ack_o(wb_uart_ack_i), 
         .wb_sel_i(wb_uart_sel_o),
         .int_o(int_o), // interrupt request

         // UART	signals
         // serial input/output
//         .stx_pad_o(uart_tx),//should we make this into one signal? 
//         .srx_pad_i(uart_rx),//should we make this into one signal?
           .stx_pad_o(o_uart_tx),
           .srx_pad_i(i_uart_rx),
            
            
         // modem signals
         .rts_pad_o(uart_rts), 
         .cts_pad_i(uart_cts), 
         .dtr_pad_o(uart_dtr), 
         .dsr_pad_i(uart_dsr), 
         .ri_pad_i(uart_ri), 
         .dcd_pad_i(uart_dcd)

         // UART_HAS_BAUDRATE_OUTPUT is not defined
     // `ifdef UART_HAS_BAUDRATE_OUTPUT
     //     , baud_o
     // `endif
	 );
    
    // ============================================
    //             Data Memory Instance
    // ============================================

    // Instantiate data memory here 
    data_mem #(
    .DEPTH(DMEM_DEPTH)
    ) data_mem_inst (
    // 8bit WISHBONE bus slave interface
    .clk_i(clk),         // clock
    .rst_i(~reset_n),         // reset (synchronous active high)
    .cyc_i(wb_dmem_cyc_o),         // cycle
    .stb_i(wb_dmem_stb_o),         // strobe
    .adr_i(wb_dmem_adr_o),         // address
    .we_i(wb_dmem_we_o),          // write enable
    .sel_i(wb_dmem_sel_o),
    .dat_i(wb_dmem_dat_o),         // data input
    .dat_o(wb_dmem_dat_i),         // data output
    .ack_o(wb_dmem_ack_i)         // normal bus termination
    );

    // ============================================
    //          Instruction Memory Instance
    // ============================================

    logic [31:0] imem_inst;

    logic [31:0] imem_addr;

    logic sel_boot_rom, sel_boot_rom_ff;
    

    //assign imem_addr = sel_boot_rom ? wb_imem_adr_o: current_pc;
assign imem_addr = sel_boot_rom ? wb_dmem_adr_o: current_pc;
    data_mem #(
        .DEPTH(IMEM_DEPTH)
    ) inst_mem_inst (
        .clk_i       (clk            ),
        .rst_i       (~reset_n         ),
        .cyc_i       (wb_imem_cyc_o), 
        .stb_i       (wb_imem_stb_o),
        .adr_i       (imem_addr      ),
        .we_i        (wb_imem_we_o ),
        .sel_i       (wb_imem_sel_o),
        .dat_i       (wb_imem_dat_o),
        .dat_o       (wb_imem_dat_i),
        .ack_o       (wb_imem_ack_i)
    );
    
//    data_mem #(
//        .DEPTH(IMEM_DEPTH)
//    ) inst_mem_inst (
//        .clk_i       (clk            ),
//        .rst_i       (~reset_n         ),
//        .cyc_i       (wb_m2s_imem_cyc), 
//        .stb_i       (wb_m2s_imem_stb),
//        .adr_i       (imem_addr      ),
//        .we_i        (wb_m2s_imem_we ),
//        .sel_i       (wb_m2s_imem_sel),
//        .dat_i       (wb_m2s_imem_dat),
//        .dat_o       (wb_s2m_imem_dat),
//        .ack_o       (wb_s2m_imem_ack)
//    );
 assign imem_inst = wb_imem_dat_i; ///There could be an issue here
  //    assign imem_inst = wb_imem_adr_o;  
  //  assign imem_inst=wb_imem_adr_o;
    // BOOT ROM 
    logic [31:0] rom_inst, rom_inst_ff;
    rom rom_instance(
        .addr     (current_pc[11:0]),
        .inst     (rom_inst  )
    );

    // register after boot rom (to syncronize with the pipeline and inst mem)
    n_bit_reg #(
        .n(32)
    ) rom_inst_reg (
        .clk(clk),
        .reset_n(reset_n),
        .data_i(rom_inst),
        .data_o(rom_inst_ff),
        .wen(if_id_reg_en)
    );

    // Inst selection mux
    assign sel_boot_rom = &current_pc[31:12]; // 0xfffff000 - to - 0xffffffff 
    always @(posedge clk) sel_boot_rom_ff <= sel_boot_rom;
    mux2x1 #(
        .n(32)
    ) rom_imem_inst_sel_mux (
        .in0    (imem_inst      ),
        .in1    (rom_inst_ff    ),
        .sel    (sel_boot_rom_ff),
        .out    (inst           )
    );

    
endmodule : rv32i_soc