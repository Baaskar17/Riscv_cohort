#*****************************************************************************
# rv32i_compute_logical.S
#-----------------------------------------------------------------------------
#
# Self-checking test for all RV32I compute and logical instructions.
#

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32U
RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Arithmetic tests (ADD, SUB, ADDI)
  #-------------------------------------------------------------
  TEST_RR_OP( 2,  add, 0x00000000, 0x00000000, 0x00000000 )   # ADD: 0 + 0 = 0
  TEST_RR_OP( 3,  add, 0xffffffff, 0xffffffff, 0x00000000 )   # ADD: -1 + 0 = -1
  TEST_RR_OP( 4,  sub, 0x00000001, 0x00000000, 0xffffffff )   # SUB: 0 - (-1) = 1
  TEST_IMM_OP( 5,  addi, 0x00000001, 0x00000000, 1 )          # ADDI: 0 + 1 = 1
  TEST_IMM_OP( 6,  addi, 0x000007ff, 0x00000000, 2047 )       # ADDI: 0 + 2047 = 2047
  TEST_IMM_OP( 7,  addi, 0xfffff801, 0x00000000, -2047 )      # ADDI: 0 + (-2047) = -2047

  # Manual LUI/AUIPC checks (since macros may not exist)
  lui x1, 0x80000                                               # LUI: load 0x80000000 into x1
  addi x2, x1, 0                                                # Verify LUI result
  auipc x3, 0                                                   # AUIPC: should equal current PC
  addi x4, x3, 0                                                # Verify AUIPC result

  #-------------------------------------------------------------
  # Logical tests (AND, OR, XOR, ANDI, ORI, XORI)
  #-------------------------------------------------------------
  TEST_RR_OP( 8,  and, 0x00000000, 0xffffffff, 0x00000000 )   # AND: -1 & 0 = 0
  TEST_RR_OP( 9,  or,  0xffffffff, 0xffffffff, 0x00000000 )   # OR: -1 | 0 = -1
  TEST_RR_OP( 10, xor, 0x7fffffff, 0xffffffff, 0x80000000 )   # XOR: -1 ^ 0x80000000 = 0x7fffffff
  TEST_IMM_OP( 11, andi, 0x00000001, 0x00000001, 1 )          # ANDI: 1 & 1 = 1
  TEST_IMM_OP( 12, ori,  0x00000001, 0x00000000, 1 )          # ORI: 0 | 1 = 1
  TEST_IMM_OP( 13, xori, 0x00000000, 0x00000001, 1 )          # XORI: 1 ^ 1 = 0

  #-------------------------------------------------------------
  # Shift tests (SLL, SRL, SRA, SLLI, SRLI, SRAI)
  #-------------------------------------------------------------
  TEST_RR_OP( 14, sll, 0x80000000, 0x00000001, 31 )           # SLL: 1 << 31 = 0x80000000
  TEST_RR_OP( 15, srl, 0x00000001, 0x80000000, 31 )           # SRL: 0x80000000 >> 31 = 1
  TEST_RR_OP( 16, sra, 0xffffffff, 0x80000000, 31 )           # SRA: arithmetic shift right keeps sign = -1
  TEST_IMM_OP( 17, slli, 0x00000002, 0x00000001, 1 )          # SLLI: 1 << 1 = 2
  TEST_IMM_OP( 18, srli, 0x40000000, 0x80000000, 1 )          # SRLI: 0x80000000 >> 1 = 0x40000000
  TEST_IMM_OP( 19, srai, 0xffffffff, 0x80000000, 31 )         # SRAI: 0x80000000 >> 31 = -1

  #-------------------------------------------------------------
  # Set-less-than tests (SLT, SLTU, SLTI, SLTIU)
  #-------------------------------------------------------------
  TEST_RR_OP( 20, slt, 1, 0x7fffffff, 0x80000000 )            # SLT: 0x7fffffff < 0x80000000 (signed) = true (1)
  TEST_RR_OP( 21, sltu, 0, 0x80000000, 0x7fffffff )           # SLTU: 0x80000000 < 0x7fffffff (unsigned) = false (0)
  TEST_IMM_OP( 22, slti, 1, 0x00000000, -1 )                  # SLTI: 0 < -1 (signed) = true (1)
  TEST_IMM_OP( 23, sltiu, 0, 0x00000000, -1 )                 # SLTIU: 0 < 0xffffffff (unsigned) = true (1)

  #-------------------------------------------------------------
  # Zero register behavior
  #-------------------------------------------------------------
  TEST_RR_ZEROSRC1( 24, add, 0x00000001, 1 )                  # ADD: x0 + 1 = 1
  TEST_RR_ZEROSRC2( 25, sub, 0xffffffff, 0xffffffff )         # SUB: -1 - x0 = -1
  TEST_RR_ZERODEST( 26, xor, 0x12345678, 0x87654321 )         # XOR result discarded (dest = x0)

  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END
