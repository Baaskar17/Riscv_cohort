#*****************************************************************************
# rv32i_illegal_instruction_test.S
#-----------------------------------------------------------------------------
#
# Purpose:
#   Verify Illegal Instruction Exception handling in Machine Mode.
#
# Test Flow:
#   - Install custom trap handler into mtvec.
#   - Execute an illegal instruction encoding (.word 0xFFFFFFFF).
#   - Trap handler captures:
#         mcause  (should be 2)
#         mepc    (should point to illegal instruction)
#         mtval   (should contain 0xFFFFFFFF)
#   - Trap handler increments mepc by 4 to skip instruction.
#   - Resume execution.
#   - Store captured values in signature region.
#
#*****************************************************************************

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32U
RVTEST_CODE_BEGIN

  ###########################################################################
  # Install Trap Handler
  ###########################################################################

  la   x1, trap_handler        # Load address of trap handler
  csrw mtvec, x1               # Set Machine Trap-Vector Base Address

  ###########################################################################
  # Clear signature storage
  ###########################################################################

  la   x2, signature_area
  sw   x0, 0(x2)
  sw   x0, 4(x2)
  sw   x0, 8(x2)

  ###########################################################################
  # Emit Illegal Instruction
  ###########################################################################

illegal_instruction_label:

  .word 0xFFFFFFFF             # This is not a valid RV32I encoding
                                # Must generate:
                                # mcause = 2 (Illegal Instruction)

  ###########################################################################
  # Execution resumes here after trap handler increments mepc
  ###########################################################################

resume_execution:

  # If we reach here, trap handler worked correctly
  j check_results


###############################################################################
# Trap Handler
###############################################################################

trap_handler:

  ###########################################################################
  # Read machine cause register
  ###########################################################################

  csrr x3, mcause              # x3 = mcause

  ###########################################################################
  # Read machine exception program counter
  ###########################################################################

  csrr x4, mepc                # x4 = address of faulting instruction

  ###########################################################################
  # Read machine trap value
  ###########################################################################

  csrr x5, mtval               # x5 = illegal instruction encoding

  ###########################################################################
  # Store captured values in signature area
  ###########################################################################

  la   x6, signature_area
  sw   x3, 0(x6)               # signature[0] = mcause
  sw   x4, 4(x6)               # signature[1] = mepc
  sw   x5, 8(x6)               # signature[2] = mtval

  ###########################################################################
  # Verify mcause == 2 (Illegal Instruction)
  ###########################################################################

  li   x7, 2
  bne  x3, x7, fail            # If not 2, test fails

  ###########################################################################
  # Increment mepc to skip illegal instruction
  #
  # The illegal instruction is 4 bytes long.
  # mepc currently points to that instruction.
  # We advance mepc by 4 to resume at next instruction.
  ###########################################################################

  addi x4, x4, 4
  csrw mepc, x4

  ###########################################################################
  # Return from trap
  ###########################################################################

  mret                         # Resume execution at updated mepc


###############################################################################
# Result Checking After Resume
###############################################################################

check_results:

  la   x10, signature_area

  lw   x11, 0(x10)             # mcause
  lw   x12, 4(x10)             # mepc
  lw   x13, 8(x10)             # mtval

  ###########################################################################
  # Check mcause == 2
  ###########################################################################

  li   x14, 2
  bne  x11, x14, fail

  ###########################################################################
  # Check mtval == 0xFFFFFFFF
  ###########################################################################

  li   x15, 0xFFFFFFFF
  bne  x13, x15, fail

  ###########################################################################
  # Check mepc equals address of illegal instruction
  ###########################################################################

  la   x16, illegal_instruction_label
  bne  x12, x16, fail

  ###########################################################################
  # All checks passed
  ###########################################################################

  j pass


fail:
  TEST_FAIL

pass:
  TEST_PASS

RVTEST_CODE_END


###############################################################################
# DATA SECTION
###############################################################################

  .data
RVTEST_DATA_BEGIN

  .align 4
signature_area:
  .word 0x0        # signature[0] = mcause
  .word 0x0        # signature[1] = mepc
  .word 0x0        # signature[2] = mtval

RVTEST_DATA_END
