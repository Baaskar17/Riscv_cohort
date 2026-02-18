.section .text
.globl _start

_start:

    # ----------------------------------------------------------
    # Load UART Base Address
    # ----------------------------------------------------------
    li      x5, 0x10000000              # UART base

    # ----------------------------------------------------------
    # Setup Trap Handler
    # ----------------------------------------------------------
    la      t0, trap_handler            # Load trap handler
    csrw    mtvec, t0                   # Set mtvec

    # ----------------------------------------------------------
    # Enable Machine External Interrupt
    # ----------------------------------------------------------
    li      t1, (1 << 11)               # MEIE bit (Machine External Interrupt Enable)
    csrs    mie, t1                     # Enable in mie

    # ----------------------------------------------------------
    # Enable Global Machine Interrupt
    # ----------------------------------------------------------
    li      t1, (1 << 3)                # MIE bit in mstatus
    csrs    mstatus, t1                 # Enable global interrupt

# ==============================================================
# NORMAL BAUD TESTS
# ==============================================================

    li x6,62500
    call uart_rx_test

    li x6,41667
    call uart_rx_test

    li x6,28409
    call uart_rx_test

    li x6,23321
    call uart_rx_test

    li x6,20833
    call uart_rx_test

    li x6,15625
    call uart_rx_test

    li x6,10417
    call uart_rx_test

    li x6,5208
    call uart_rx_test

    li x6,2604
    call uart_rx_test

    li x6,1736
    call uart_rx_test

    li x6,1302
    call uart_rx_test

    li x6,651
    call uart_rx_test

    li x6,326
    call uart_rx_test

    li x6,163
    call uart_rx_test

    li x6,109
    call uart_rx_test

    li x6,81
    call uart_rx_test

    li x6,54
    call uart_rx_test

    li x6,41
    call uart_rx_test

    li x6,27
    call uart_rx_test

    li x6,14
    call uart_rx_test

    li x6,7
    call uart_rx_test

    li x6,5
    call uart_rx_test

    li x6,3
    call uart_rx_test

    call uart_abnormal_baud_tests

end:
    j end

# ==============================================================
# MAIN RX TEST ROUTINE
# ==============================================================

uart_rx_test:

    sh      x6,0(x5)                    # Set baud divisor
    fence                               # Ensure write completes

    call uart_enable_rx_interrupt       # Enable RX interrupt

    call uart_fifo_depth_test
    call uart_parity_validation
    call uart_frame_validation
    call uart_break_validation
    call uart_stop_bit_validation
    call uart_clock_drift_test
    call uart_csr_stress_test
    call uart_trap_during_rx
    call uart_timing_test
    call receive_f_values
    call receive_d_values
    call receive_q_values

    ret

# ==============================================================
# ENABLE RX INTERRUPT IN UART
# ==============================================================

uart_enable_rx_interrupt:

    li      t0,0x01                     # Assume bit0 enables RX interrupt
    sw      t0,0x10(x5)                 # Write to UART interrupt enable register
    ret

# ==============================================================
# INTERRUPT SERVICE ROUTINE
# ==============================================================

uart_rx_isr:

    # Read received byte
    lw      t2,0x04(x5)                 # Read RX data

    # Optional: store or verify data
    nop

    ret

# ==============================================================
# FIFO DEPTH VERIFICATION
# ==============================================================

uart_fifo_depth_test:

    li t0,0

fifo_read_loop:
    lw t1,0x08(x5)                      # Status
    andi t1,t1,0x01                     # RX ready bit
    beqz t1,fifo_done

    lw t2,0x04(x5)                      # Read byte
    addi t0,t0,1
    j fifo_read_loop

fifo_done:
    ret

# ==============================================================
# PARITY VALIDATION
# ==============================================================

uart_parity_validation:

    li t0,0x03
    sw t0,0x0C(x5)
    call uart_rx_byte

    li t0,0x0B
    sw t0,0x0C(x5)
    call uart_rx_byte

    li t0,0x1B
    sw t0,0x0C(x5)
    call uart_rx_byte

    ret

# ==============================================================
# FRAME VALIDATION
# ==============================================================

uart_frame_validation:

    call uart_rx_byte
    lw t1,0x08(x5)
    andi t1,t1,0x08
    beqz t1,frame_ok

frame_error_detected:
    nop

frame_ok:
    ret

# ==============================================================
# BREAK VALIDATION
# ==============================================================

uart_break_validation:

    lw t1,0x08(x5)
    andi t1,t1,0x10
    beqz t1,break_ok

break_detected:
    nop

break_ok:
    ret

# ==============================================================
# STOP BIT VALIDATION
# ==============================================================

uart_stop_bit_validation:

    li t0,0x03
    sw t0,0x0C(x5)
    call uart_rx_byte

    li t0,0x07
    sw t0,0x0C(x5)
    call uart_rx_byte

    ret

# ==============================================================
# CLOCK DRIFT STRESS
# ==============================================================

uart_clock_drift_test:

    addi x6,x6,1
    sh x6,0(x5)
    call uart_rx_byte

    addi x6,x6,-2
    sh x6,0(x5)
    call uart_rx_byte

    ret

# ==============================================================
# CSR STRESS TEST
# ==============================================================

uart_csr_stress_test:

    csrr t0,mstatus
    csrw mstatus,t0

    csrr t1,mie
    csrw mie,t1

    call uart_rx_byte

    ret

# ==============================================================
# FORCE TRAP DURING RX
# ==============================================================

uart_trap_during_rx:
    ecall
    ret

# ==============================================================
# RECEIVE FLOAT VALUES
# ==============================================================

receive_f_values:
    li t0,4
f_loop:
    call uart_rx_byte
    addi t0,t0,-1
    bnez t0,f_loop
    ret

receive_d_values:
    li t0,8
d_loop:
    call uart_rx_byte
    addi t0,t0,-1
    bnez t0,d_loop
    ret

receive_q_values:
    li t0,16
q_loop:
    call uart_rx_byte
    addi t0,t0,-1
    bnez t0,q_loop
    ret

# ==============================================================
# POLLING MODE RX
# ==============================================================

uart_rx_byte:

wait_rx:
    lw t1,0x08(x5)
    andi t1,t1,0x01
    beqz t1,wait_rx

    lw a1,0x04(x5)
    ret

# ==============================================================
# ABNORMAL BAUD TESTS
# ==============================================================

uart_abnormal_baud_tests:

    li x6,1
    call uart_rx_test

    li x6,100000
    call uart_rx_test

    li x6,0
    call uart_rx_test

    ret

# ==============================================================
# DELAY LOOP
# ==============================================================

delay_loop:
    addi a0,a0,-1
    bnez a0,delay_loop
    ret

# ==============================================================
# TRAP HANDLER (Handles Interrupt + Exception)
# ==============================================================

trap_handler:

    csrr t0,mcause                  # What went wrong?
    csrr t1,mepc                    # Where did it go wrong?
    csrr t2,mtval                   # Extra info

    # Check if interrupt (MSB of mcause set)
    srli t3,t0,31
    beqz t3,handle_exception

    # Interrupt path
    call uart_rx_isr
    mret

handle_exception:

    addi t1,t1,4
    csrw mepc,t1
    mret
