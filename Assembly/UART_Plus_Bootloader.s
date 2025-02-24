
########
######################################################################## start of configurations ###########################################################################
nop
nop
lui x10, 0x20000
addi x10, x10, 0x003 # Line Control Register Adress

# UART address: 0x2000_0000

# set UART config for devisor (baudrate config)
# modify-config mode = 1
li x11, 0x9b #0x9B = 1001 1011 (Binary)map it from right to left
sw x11, 0(x10)

# set value used to get right baudrate
# equation: value = sys_clk / (16 * baudrate
#           {D2, D1} = 50MHz / (16 * 9600Hz)
# set address D2
lui x10, 0x20000
addi x10, x10, 0x001

# store on MSB latch
addi x11,x0 , 0x01
sw x11, 0(x10)

# set address D1
lui x10, 0x20000
addi x10, x10, 0x000

# store on LSB latch
addi x11,x0 ,0x46
sw x11, 0(x10)


# rx - tx
# close modify-config mode of UART to start working based on that config set before
# modify-config mode = 0
lui x10, 0x20000
addi x10, x10, 0x003 # GO TO LCR (WE CAN JUST SAY li x10 0x20003 )
li x11, 0x1b #0x1B = 0001 1011 (Binary)map it from right to left
sw x11, 0(x10)
########################################################################### end of configurations ############################################################################
################################################################################ bootloader ##################################################################################
li x10,0x20000000
li x12,0x10000000 # inst mem address
#li x13,0x10000200 # last instruction that should be sent 512 bytes (0x200 = 512 in decimal)
#li x13,0x10000096 #for shorter time  I made it 150 byte
#li x13, 0x10000046  # Now storing 70 (0x46 decimal)
li x13,0x10000100 # to speed up thetesting we reduce it to 256
WaitForData:
    lw x11, 5(x10) #loads the Line Status Register (LSR) at 0x20000005
    andi x11, x11, 1 # Performs a bitwise AND operation between x11 and 1.
    beq x11, x0, WaitForData # if x11 is zero then keep listining
# here the data is recieved
lw x11,0(x10) # # Read received byte from UART Receiver Buffer
nop
nop
nop
# #ADDED: Wait for TX to be ready before sending back the received byte
# WaitForTX:
#     lw x12, 5(x10)  # Load UART Line Status Register (LSR)
#     andi x12, x12, 0x20  # Check if TX buffer is empty (Bit 5)
#     beqz x12, WaitForTX  # If TX not ready, keep waiting
# nop
# sb x11 0(x10)
# nop
# nop
# nop
 sw x11,0(x10) # send the same instruction back just to check
 nop
# # Delay loop at the end
# li t0, 25000  # Adjust for longer/shorter delay

# delay_loop:
#     addi t0, t0, -1  # Decrement counter
#     bnez t0, delay_loop  # Loop until t0 becomes zero
    nop
    nop
    
# nop
#  nop
#  nop
sb x11,0(x12) #  sb (Store Byte) stores the lowest 8 bits (1 byte) of x11 into memory.
nop
nop
nop
addi x12, x12, 1
#CHECK IF WE REACH MEMOMRY LIMIT (512 BYTE)
bge x12, x13, exit 
nop
nop
j WaitForData
nop
nop
nop
exit: #(go to 
li x10, 0x10000000
#li x10, 0x30000000

jalr x10
nop
nop
nop
nop

