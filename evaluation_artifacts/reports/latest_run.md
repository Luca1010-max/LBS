# Latest Automated Run

- Workspace: `/Users/lucadoll/Desktop/LBS-Compiler/qbe-1.2`
- Timestamp: 2026-04-16T15:51:32Z
- PASS: 5
- FAIL: 4

## Technique Results

| Technique | Status | Reason |
| --- | --- | --- |
| stack_canary | PASS | helper emission and runtime trap reproduced |
| nop_insertion | PASS | assembly diversity and semantic equivalence reproduced |
| reg_randomization | PASS | register tie-break randomization reproduced |
| func_permutation | PASS | function order changes while behavior stays stable |
| insn_substitution | FAIL | no implementation evidence found in CLI or backend code |
| bb_randomization | FAIL | no block-order randomization path found |
| data_randomization | FAIL | no data masking/layout randomization path found |
| timing_defense | PASS | direct strcmp calls are rewritten semantically safely and prefix leakage is reduced on the native target |
| assignment5 | FAIL | no assignment 5 material or implementation mapping was found |
