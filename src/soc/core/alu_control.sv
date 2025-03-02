
module alu_control (
    input logic [2:0] fun3,
    input logic [5:0]fun7,
    input logic [2:0] alu_op,
    output alu_t alu_ctrl
);

// alu_op 00 for load/store
// alu_op 10 r-type
// alu_op 11 i-type 
// alu_op 01 for branches
parameter LOAD_STORE = 3'b000, R_TYPE = 3'b011, I_TYPE = 3'b001, B_TYPE = 3'b010, R_float=3'b100, R4_float=3'b101, I_float=3'b110, S_float=3'b111;

always_comb begin 
    case(alu_op)
    
        R_TYPE: begin 
        
                  case({fun7,fun3})
        
                      10'b0000000000:
                            alu_ctrl = ADD; 
                       
                      10'b0100000000: 
                            alu_ctrl = SUB;
                            
                      10'b0000000001:
                            alu_ctrl =SLL;  
                            
                      10'b0000000010:
                            alu_ctrl = SLT;
                      
                      10'b0000000011:
                            alu_ctrl = SLTU;           
                       
                      10'b0000000100:
                            alu_ctrl = XOR;          
                    
                      10'b0000000101:
                            alu_ctrl = SRL;
                            
                      10'b0100000101:
                            alu_ctrl = SRA;     

                      10'b0000000110:
                            alu_ctrl = OR;
                            
                      10'b0000000111:
                            alu_ctrl = AND; 
                                
                      10'b0000001000:
                            alu_ctrl = MUL;  
                            
                      10'b0000001001:
                            alu_ctrl = MULH;
  
                      10'b0000001010:
                            alu_ctrl = MULHSU;                          

                      10'b0000001011:
                            alu_ctrl = MULHU;   
                            
                      10'b0000001100:
                            alu_ctrl = DIV;  
                            
                      10'b0000001101:
                            alu_ctrl = DIVU;  
                           
                      10'b0000001110:
                            alu_ctrl = REM; 
                            
                      10'b0000001111:
                            alu_ctrl = REMU;       

//                      default:
//                            alu_ctrl=5'bxxxxx;   
            endcase
         end   

        I_TYPE: begin 
         
         
               case(fun3)
        
                       3'b000:
                            alu_ctrl = ADD; 
                            
                       3'b010:
                            alu_ctrl = SLT; 
                            
                       3'b011:
                            alu_ctrl = SLTU; 
                            
                       3'b100:
                            alu_ctrl = XOR;                 
         
                       3'b110:
                            alu_ctrl = OR; 
                            
                       3'b111:
                            alu_ctrl = AND; 
                            
                            
                       3'b001:
                            alu_ctrl = SLL; 
                            
                            
                       3'b101:
                            alu_ctrl = SRA; 
                 
//                        default:
//                             alu_ctrl = 5'bxxxxx;
         
           endcase
        end

        LOAD_STORE: begin
            alu_ctrl = ADD; 
        end

        B_TYPE: begin 
            case(fun3[2:1])
                2'b00: alu_ctrl = SUB;
                2'b01: alu_ctrl = SUB;
                2'b10: alu_ctrl = SLT;
                2'b11: alu_ctrl = SLTU;
            endcase
        end
        
         R_float: begin 
         
         case ({fun7, fun3})
          
                10'b000000_000: alu_ctrl = FADD;  
                10'b000100_000: alu_ctrl = FSUB;  
                10'b000010_000: alu_ctrl = FMUL;  
                10'b000110_000: alu_ctrl = FDIV;  
                10'b010110_xxx: alu_ctrl = FSQRT;  
                10'b001000_000: alu_ctrl = FSGNJ;  
                10'b001000_001: alu_ctrl = FSGNJN;  
                10'b001000_010: alu_ctrl = FSGNJX;  
                10'b001010_000: alu_ctrl = FMIN;  
                10'b001010_001: alu_ctrl = FMAX;  
                10'b110000_xxx: alu_ctrl = FCVTW;  
                10'b110000_xxx: alu_ctrl = FCVTWU;  
                10'b111000_000: alu_ctrl = FMVXW;  
                10'b101000_010: alu_ctrl = FEQ;  
                10'b101000_001: alu_ctrl = FLT;  
                10'b101000_000: alu_ctrl = FLE;  
                10'b111000_001: alu_ctrl = FCLASS;  
                10'b110100_xxx: alu_ctrl = FCVTSW;  
                10'b110100_xxx: alu_ctrl = FCVTSWU;  
                10'b111100_000: alu_ctrl = FMVWX;  
//                default: alu_ctrl = 5'bxxxxx;  
           endcase
        end
        
         R4_float: begin 
            case ({2'b00, fun3})  
                5'b00_xxx: alu_ctrl = FMADD;  
                5'b00_xxx: alu_ctrl = FMSUB;  
                5'b00_xxx: alu_ctrl = FNMSUB;  
                5'b00_xxx: alu_ctrl = FNMADD;  
//                default: alu_ctrl = 5'bxxxxx;  
             endcase
          end
        
        
        
        
         I_float: begin 
            alu_ctrl = FLW; 
           end
        
        
         S_float: begin 
            alu_ctrl = FSW;
        end
        
    endcase
end

endmodule : alu_control
