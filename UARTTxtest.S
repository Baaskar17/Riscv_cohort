# ==============================================================
# COMPLETE UART TRANSMITTER VALIDATION FIRMWARE
# ==============================================================

.section .text
.globl _start

_start:

    # Load UART base address
    li      x5, 0x10000000

    # Setup trap handler
    la      t0, trap_handler
    csrw    mtvec, t0

# --------------------------------------------------------------
# NORMAL BAUD SWEEP (Assuming 50 MHz UART clock)
# --------------------------------------------------------------

    li x6,62500 ; 50
    call uart_tx_test
    li x6,41667 ; 75
    call uart_tx_test
    li x6,28409 ; 110
    call uart_tx_test
    li x6,23321 ; 134
    call uart_tx_test
    li x6,20833 ; 150
    call uart_tx_test
    li x6,15625 ; 200
    call uart_tx_test
    li x6,10417 ; 300
    call uart_tx_test
    li x6,5208  ; 600
    call uart_tx_test
    li x6,2604  ; 1200
    call uart_tx_test
    li x6,1736  ; 1800
    call uart_tx_test
    li x6,1302  ; 2400
    call uart_tx_test
    li x6,651   ; 4800
    call uart_tx_test
    li x6,326   ; 9600
    call uart_tx_test
    li x6,163   ; 19200
    call uart_tx_test
    li x6,109   ; 28800
    call uart_tx_test
    li x6,81    ; 38400
    call uart_tx_test
    li x6,54    ; 57600
    call uart_tx_test
    li x6,41    ; 76800
    call uart_tx_test
    li x6,27    ; 115200
    call uart_tx_test
    li x6,14    ; 230400
    call uart_tx_test
    li x6,7     ; 460800
    call uart_tx_test
    li x6,5     ; 576000
    call uart_tx_test
    li x6,3     ; 921600
    call uart_tx_test

    call uart_abnormal_baud_tests

end:
    j end


# --------------------------------------------------------------
# Main transmitter validation routine
# --------------------------------------------------------------

uart_tx_test:

    sh x6,0(x5)
    fence

    call uart_fifo_depth_test
    call uart_stop_bit_sweep
    call uart_break_test
    call uart_clock_drift_test
    call uart_csr_stress_test
    call uart_trap_during_tx

    call uart_parity_sweep
    call uart_frame_sweep
    call uart_pattern_test
    call uart_burst_test
    call uart_dynamic_baud_test
    call uart_timing_test

    call transmit_f_values
    call transmit_d_values
    call transmit_q_values

    ret


# --------------------------------------------------------------
# FIFO depth verification
# --------------------------------------------------------------

uart_fifo_depth_test:

    li t0,0

fifo_loop:
    lw t1,0x08(x5)
    andi t1,t1,0x02
    bnez t1,fifo_done

    li a1,0xAA
    sw a1,0x04(x5)
    addi t0,t0,1
    j fifo_loop

fifo_done:
    la t2,begin_signature
    sd t0,40(t2)
    ret


# --------------------------------------------------------------
# Stop bit sweep
# --------------------------------------------------------------

uart_stop_bit_sweep:

    li t0,0x03
    sw t0,0x0C(x5)
    li a1,0x11
    call uart_tx_byte

    li t0,0x07
    sw t0,0x0C(x5)
    li a1,0x22
    call uart_tx_byte

    ret


# --------------------------------------------------------------
# Break condition test
# --------------------------------------------------------------

uart_break_test:

    li t0,0x43
    sw t0,0x0C(x5)

    li a0,100000
    call delay_loop

    li t0,0x03
    sw t0,0x0C(x5)

    li a1,0x55
    call uart_tx_byte

    ret


# --------------------------------------------------------------
# Clock drift stress
# --------------------------------------------------------------

uart_clock_drift_test:

    li x6,326
    sh x6,0(x5)
    li a1,0x10
    call uart_tx_byte

    li x6,327
    sh x6,0(x5)
    li a1,0x11
    call uart_tx_byte

    li x6,325
    sh x6,0(x5)
    li a1,0x12
    call uart_tx_byte

    ret


# --------------------------------------------------------------
# CSR stress interaction
# --------------------------------------------------------------

uart_csr_stress_test:

    csrr t0,mstatus
    ori  t0,t0,0x8
    csrw mstatus,t0

    li a1,0x33
    call uart_tx_byte

    csrr t0,mstatus
    andi t0,t0,~0x8
    csrw mstatus,t0

    ret


# --------------------------------------------------------------
# Trap during transmission
# --------------------------------------------------------------

uart_trap_during_tx:

    li a1,0x44
    call uart_tx_byte

    .word 0xFFFFFFFF    # Illegal instruction to force trap

    li a1,0x45
    call uart_tx_byte

    ret


# --------------------------------------------------------------
# Parity sweep
# --------------------------------------------------------------

uart_parity_sweep:

    li t0,0x03
    sw t0,0x0C(x5)
    li a1,0xA5
    call uart_tx_byte

    li t0,0x1B
    sw t0,0x0C(x5)
    call uart_tx_byte

    li t0,0x0B
    sw t0,0x0C(x5)
    call uart_tx_byte

    ret


# --------------------------------------------------------------
# Frame sweep
# --------------------------------------------------------------

uart_frame_sweep:

    li t0,0x00
    sw t0,0x0C(x5)
    li a1,0x55
    call uart_tx_byte

    li t0,0x01
    sw t0,0x0C(x5)
    call uart_tx_byte

    li t0,0x02
    sw t0,0x0C(x5)
    call uart_tx_byte

    li t0,0x03
    sw t0,0x0C(x5)
    call uart_tx_byte

    ret


# --------------------------------------------------------------
# Pattern stress
# --------------------------------------------------------------

uart_pattern_test:

    li a1,0x00 ; call uart_tx_byte
    call uart_tx_byte
    li a1,0xFF
    call uart_tx_byte
    li a1,0xAA
    call uart_tx_byte
    li a1,0x55
    call uart_tx_byte
    li a1,0x7F
    call uart_tx_byte
    li a1,0x80
    call uart_tx_byte
    li a1,0x01
    call uart_tx_byte
    li a1,0xFE
    call uart_tx_byte

    ret


# --------------------------------------------------------------
# Burst test
# --------------------------------------------------------------

uart_burst_test:

    li t0,128
burst_loop:
    li a1,0x5A
    call uart_tx_byte
    addi t0,t0,-1
    bnez t0,burst_loop
    ret


# --------------------------------------------------------------
# Dynamic baud switching
# --------------------------------------------------------------

uart_dynamic_baud_test:

    li x6,326
    sh x6,0(x5)
    li a1,0x11
    call uart_tx_byte

    li x6,27
    sh x6,0(x5)
    li a1,0x22
    call uart_tx_byte

    li x6,3
    sh x6,0(x5)
    li a1,0x33
    call uart_tx_byte

    ret


# --------------------------------------------------------------
# TX timing measurement
# --------------------------------------------------------------

uart_timing_test:

    csrr t0,mcycle
    li a1,0x55
    call uart_tx_byte
    csrr t1,mcycle
    sub t2,t1,t0

    la t3,begin_signature
    sd t2,32(t3)

    ret


# --------------------------------------------------------------
# Single byte transmit (polling)
# --------------------------------------------------------------

uart_tx_byte:

wait_tx:
    lw t1,0x08(x5)
    andi t1,t1,1
    beqz t1,wait_tx

    sw a1,0x04(x5)

    la t2,begin_signature
    sd a1,0(t2)

    ret


# --------------------------------------------------------------
# Floating point transmissions
# --------------------------------------------------------------

transmit_f_values:
    li t0,0
    fsrm t0
    flw ft0,float_val
    fmv.x.w a1,ft0
    call uart_tx_byte
    ret

transmit_d_values:
    li t0,0
    fsrm t0
    fld ft1,double_val
    fmv.x.d a1,ft1
    call uart_tx_byte
    ret

transmit_q_values:
    li t0,0
    fsrm t0
    flq ft2,quad_val
    fmv.x.q a1,ft2
    call uart_tx_byte
    ret


# --------------------------------------------------------------
# Delay loop
# --------------------------------------------------------------

delay_loop:
    addi a0,a0,-1
    bnez a0,delay_loop
    ret


# --------------------------------------------------------------
# Trap handler
# --------------------------------------------------------------

trap_handler:

    csrr t0,mcause
    csrr t1,mepc
    csrr t2,mtval

    la t3,begin_signature
    sd t0,8(t3)
    sd t1,16(t3)
    sd t2,24(t3)

    addi t1,t1,4
    csrw mepc,t1

    mret


.section .data

float_val:
    .float 3.14

double_val:
    .double 6.28

quad_val:
    .quad 12.56

begin_signature:
    .space 256
