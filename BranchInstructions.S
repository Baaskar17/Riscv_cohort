#*****************************************************************************
# rv32i_branch_test.S
#-----------------------------------------------------------------------------
#
# Self-checking test for RV32I Branch Instructions
#
# Tests:
#   - Branch if Equal
#   - Branch if Not Equal
#   - Branch if Less Than (signed)
#   - Branch if Greater or Equal (signed)
#   - Branch if Less Than (unsigned)
#   - Branch if Greater or Equal (unsigned)
#
# Each instruction:
#   - Taken case
#   - Not-taken case
#   - Forward branch
#   - Backward branch
#
# Optional:
#   - Jump and Link
#   - Jump and Link Register
#
#*****************************************************************************

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32U
RVTEST_CODE_BEGIN

  ###########################################################################
  # BRANCH IF EQUAL
  ###########################################################################

  li x1, 10
  li x2, 10

  # -------- Taken Case (Forward Branch) --------
  # If x1 == x2, branch should jump to label equal_taken

  beq x1, x2, equal_taken

  # If branch fails, test fails
  j fail

equal_taken:
  # Passed taken test

  # -------- Not Taken Case --------
  li x2, 20

  # x1 != x2 → branch should NOT be taken
  beq x1, x2, fail

  ###########################################################################
  # BRANCH IF NOT EQUAL
  ###########################################################################

  li x3, 5
  li x4, 6

  # -------- Taken Case --------
  # Since 5 != 6, branch should be taken

  bne x3, x4, not_equal_taken

  j fail

not_equal_taken:

  # -------- Not Taken Case --------
  li x4, 5

  # Since equal, branch must NOT be taken
  bne x3, x4, fail


  ###########################################################################
  # BRANCH IF LESS THAN (SIGNED COMPARISON)
  ###########################################################################

  li x5, -5
  li x6, 3

  # -------- Taken Case --------
  # -5 < 3 (signed comparison)
  blt x5, x6, less_taken

  j fail

less_taken:

  # -------- Not Taken Case --------
  # 3 < -5 (signed) → false
  blt x6, x5, fail


  ###########################################################################
  # BRANCH IF GREATER OR EQUAL (SIGNED)
  ###########################################################################

  li x7, 10
  li x8, 5

  # -------- Taken Case --------
  # 10 >= 5 (signed)
  bge x7, x8, greater_equal_taken

  j fail

greater_equal_taken:

  # -------- Not Taken Case --------
  # 5 >= 10 → false
  bge x8, x7, fail


  ###########################################################################
  # BRANCH IF LESS THAN (UNSIGNED)
  ###########################################################################

  li x9, 1
  li x10, -1          # 0xFFFFFFFF (unsigned = very large)

  # -------- Taken Case --------
  # 1 < 0xFFFFFFFF (unsigned true)
  bltu x9, x10, less_unsigned_taken

  j fail

less_unsigned_taken:

  # -------- Not Taken Case --------
  # 0xFFFFFFFF < 1 (unsigned false)
  bltu x10, x9, fail


  ###########################################################################
  # BRANCH IF GREATER OR EQUAL (UNSIGNED)
  ###########################################################################

  # -------- Taken Case --------
  # 0xFFFFFFFF >= 1 (unsigned true)
  bgeu x10, x9, greater_unsigned_taken

  j fail

greater_unsigned_taken:

  # -------- Not Taken Case --------
  # 1 >= 0xFFFFFFFF (unsigned false)
  bgeu x9, x10, fail


  ###########################################################################
  # BACKWARD BRANCH TEST (Loop)
  ###########################################################################

  li x11, 3

loop_test:
  addi x11, x11, -1

  # Branch backward while x11 != 0
  bne x11, x0, loop_test

  # If loop exits correctly, x11 must be 0
  bne x11, x0, fail


  ###########################################################################
  # JUMP AND LINK
  ###########################################################################

  # Jump forward and save return address
  jal x12, jal_target

  j fail   # Should never execute

jal_target:
  # x12 now contains return address
  addi x13, x12, 0
  beq  x13, x0, fail   # return address must not be zero


  ###########################################################################
  # JUMP AND LINK REGISTER
  ###########################################################################

  la  x14, jalr_target
  jalr x15, 0(x14)     # Jump via register

  j fail

jalr_target:
  addi x16, x15, 0
  beq  x16, x0, fail


  ###########################################################################
  # ALL TESTS PASSED
  ###########################################################################

  j pass


fail:
  TEST_FAIL

pass:
  TEST_PASS

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END
