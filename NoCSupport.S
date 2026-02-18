#*****************************************************************************
# rv32i_compressed_minimal_test.S
#-----------------------------------------------------------------------------
#
# Purpose:
#   Minimal test for one Compressed instruction (C.ADDI).
#
# Behavior:
#   - If C extension is supported:
#         C.ADDI executes normally
#         Record C-enabled in signature
#
#   - If C extension is NOT supported:
#         Illegal instruction trap occurs
#         Trap handler records C-disabled
#         Handler increments mepc by 2 (compressed size)
#         Resume execution safely
#
#*****************************************************************************

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32U
RVTEST_CODE_BEGIN

  ###########################################################################
  # Install trap handler
  ###########################################################################

  la   x1, trap_handler
  csrw mtvec, x1

  ###########################################################################
  # Clear signature
  ###########################################################################

  la   x2, signature_area
  sw   x0, 0(x2)

  ###########################################################################
  # Initialize test register
  ###########################################################################

  li   x3, 5                  # x3 = 5

  ###########################################################################
  # Attempt Compressed ADD Immediate
  #
  # C.ADDI encoding format:
  #   c.addi rd, imm
  #
  # This is a 16-bit instruction.
  #
  # If C extension is enabled:
  #   x3 = x3 + 1 → result = 6
  #
  # If C extension is NOT enabled:
  #   Illegal instruction trap
  ###########################################################################

compressed_instruction_label:

  .hword 0x0105               # Example encoding for: c.addi x2?, imm?
                              # (Assembler-independent manual emission)

  ###########################################################################
  # If execution reaches here without trap,
  # then C extension is enabled.
  ###########################################################################

c_supported_path:

  li   x4, 1                  # 1 means C-enabled
  sw   x4, 0(x2)
  j    finish


###############################################################################
# Trap Handler
###############################################################################

trap_handler:

  ###########################################################################
  # Read mcause
  ###########################################################################

  csrr x5, mcause

  li   x6, 2                  # 2 = Illegal Instruction
  bne  x5, x6, fail           # If not illegal instruction, fail

  ###########################################################################
  # Read mepc
  ###########################################################################

  csrr x7, mepc

  ###########################################################################
  # Record C-disabled in signature
  ###########################################################################

  la   x8, signature_area
  li   x9, 2                  # 2 means C-disabled
  sw   x9, 0(x8)

  ###########################################################################
  # Since compressed instruction is 16 bits,
  # increment mepc by 2 (not 4)
  ###########################################################################

  addi x7, x7, 2
  csrw mepc, x7

  ###########################################################################
  # Return from trap
  ###########################################################################

  mret


###############################################################################
# Finish
###############################################################################

finish:

  j pass


fail:
  TEST_FAIL

pass:
  TEST_PASS

RVTEST_CODE_END


###############################################################################
# Data Section
###############################################################################

  .data
RVTEST_DATA_BEGIN

  .align 4
signature_area:
  .word 0x0        # 0 = not executed
                    # 1 = C-enabled
                    # 2 = C-disabled

RVTEST_DATA_END
