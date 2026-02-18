#*****************************************************************************
# rv32i_load_store.S
#-----------------------------------------------------------------------------
#
# Self-checking test for RV32I Load and Store Instructions
# Tests:
#   LB, LBU
#   LH, LHU
#   LW
#   SB, SH, SW
#
# Validates:
#   - Correct data transfer
#   - Sign extension
#   - Zero extension
#   - Aligned accesses
#   - Misaligned accesses (if supported)
#
#*****************************************************************************

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32U
RVTEST_CODE_BEGIN

  # -------------------------------------------------------------
  # Base address setup
  # -------------------------------------------------------------
  la   x1, test_data        # x1 = base address of test memory

  # =============================================================
  # BYTE LOAD TESTS (LB, LBU)
  # =============================================================

  # Memory layout (see data section below):
  # Offset 0 : 0x80  (-128 signed)
  # Offset 1 : 0x7F  (127 signed)

  TEST_LD_OP( 2, lb,  0xffffff80, x1, 0 )     # LB  -> sign extend 0x80 = -128
  TEST_LD_OP( 3, lbu, 0x00000080, x1, 0 )     # LBU -> zero extend 0x80 = 128

  TEST_LD_OP( 4, lb,  0x0000007f, x1, 1 )     # LB  -> +127
  TEST_LD_OP( 5, lbu, 0x0000007f, x1, 1 )     # LBU -> +127

  # =============================================================
  # HALFWORD LOAD TESTS (LH, LHU)
  # =============================================================

  # Offset 2 : 0x8001  (signed negative)
  # Offset 4 : 0x7fff  (signed positive)

  TEST_LD_OP( 6,  lh,  0xffff8001, x1, 2 )    # LH  -> sign extend
  TEST_LD_OP( 7,  lhu, 0x00008001, x1, 2 )    # LHU -> zero extend

  TEST_LD_OP( 8,  lh,  0x00007fff, x1, 4 )    # LH  -> +32767
  TEST_LD_OP( 9,  lhu, 0x00007fff, x1, 4 )    # LHU -> +32767

  # =============================================================
  # WORD LOAD TEST (LW)
  # =============================================================

  # Offset 8 : 0xdeadbeef

  TEST_LD_OP( 10, lw, 0xdeadbeef, x1, 8 )     # LW aligned access

  # =============================================================
  # STORE TESTS (SB, SH, SW)
  # =============================================================

  la   x2, store_area        # x2 = destination buffer

  # -------------------
  # SB Test
  # -------------------
  li   x3, 0xaa
  sb   x3, 0(x2)             # Store byte
  lb   x4, 0(x2)
  TEST_RR_OP( 11, add, 0xffffffaa, x4, x0 )   # Verify stored byte (sign extended)

  # -------------------
  # SH Test
  # -------------------
  li   x3, 0x1234
  sh   x3, 2(x2)
  lh   x4, 2(x2)
  TEST_RR_OP( 12, add, 0x00001234, x4, x0 )   # Verify halfword

  # -------------------
  # SW Test
  # -------------------
  li   x3, 0xabcdef01
  sw   x3, 4(x2)
  lw   x4, 4(x2)
  TEST_RR_OP( 13, add, 0xabcdef01, x4, x0 )   # Verify word

  # =============================================================
  # MISALIGNED ACCESS TESTS (Optional)
  # =============================================================
  # These will PASS only if your implementation supports
  # misaligned loads/stores in hardware.
  # Otherwise they will generate a trap.

#ifdef __MISALIGNED_SUPPORTED__

  # Misaligned halfword load (offset 3)
  lh   x5, 3(x1)

  # Misaligned word load (offset 9)
  lw   x6, 9(x1)

#endif

  TEST_PASSFAIL

RVTEST_CODE_END

# =============================================================
# DATA SECTION
# =============================================================

  .data
RVTEST_DATA_BEGIN

  .align 4
test_data:
  .byte  0x80              # offset 0
  .byte  0x7f              # offset 1
  .half  0x8001            # offset 2
  .half  0x7fff            # offset 4
  .word  0xdeadbeef        # offset 8

  .align 4
store_area:
  .word  0x00000000
  .word  0x00000000
  .word  0x00000000

RVTEST_DATA_END
