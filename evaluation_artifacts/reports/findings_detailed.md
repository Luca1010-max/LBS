# Executive Summary

The compiler contains working implementations for stack canaries, NOP insertion, register tie-break randomization, function permutation, and a timing-defense mitigation for the native ARM64 target used in this workspace. The improved timing-defense path now preserves `strcmp` semantics, is no longer tied to the source-level function name, and measurably reduces the prefix-dependent timing spread on the reproduced attack.

Critical issues first:

1. The stack-canary value is deterministic and derived from static function metadata, not from runtime entropy. That is enough to catch the provided overflow demo, but it is materially weaker than modern canaries.
2. The timing defense is target-specific to the native ARM64 backend. That is acceptable for the reproduced assignment pipeline here, but it remains a portability limitation rather than a general cross-target mitigation.

# Validation Results

## Stack Canary

- Static evidence:
  - build flag in [Makefile](../../Makefile)
  - per-function canary generation in [arm64/emit.c](../../arm64/emit.c)
  - prologue/epilogue instrumentation in [arm64/emit.c](../../arm64/emit.c)
- Dynamic evidence:
  - `result/stack_canary_attack.no_canary` printed `control flow hijacked`
  - `result/stack_canary_attack.canary` trapped before return
- Assessment:
  - correct on the supplied demo
  - ARM64-only
  - predictable canary generation weakens the security goal

## NOP Insertion

- Static evidence:
  - activation and RNG state in [main.c](../../main.c) and [util.c](../../util.c)
  - insertion sites in all three backend emitter loops
- Dynamic evidence:
  - diversified assembly contained explicit `nop` instructions
  - `--no-div-nop` reproduced baseline byte-for-byte
  - same seed reproduced identical assembly; different seed changed assembly
  - 10 seeds produced 10 unique assembly hashes in the current test
- Assessment:
  - semantically conservative placement
  - cosmetic diversification only
  - moderate runtime/code-size overhead

## Instruction Substitution

- No activation logic, state bit, or backend substitution implementation was found.
- Status: not evidenced.

## Register Randomization

- Static evidence:
  - tie-break randomization in [rega.c](../../rega.c) through `divpick(n)`
- Dynamic evidence:
  - baseline and diversified assembly differ substantially
  - `--no-div-regrand` reproduces baseline
  - same seed is deterministic; different seeds diverge
  - 10 seeds produced 10 unique assembly hashes in the current test
- Assessment:
  - good insertion point: only among already valid candidates
  - correctness looked stable on the provided demo
  - performance cost is visible because different callee-saved registers can enlarge the frame substantially

## Basic Block Randomization

- No CLI flag and no block-order transformation were found.
- Status: not evidenced.

## Function Permutation

- Static evidence:
  - buffered raw/function segment model in [main.c](../../main.c)
  - permutation driven by `divpickfun`
- Dynamic evidence:
  - `.globl` order changes across seeds
  - `--no-div-funcperm` reproduces baseline
  - same seed is deterministic; different seeds diverge
  - 10 seeds produced multiple unique orderings
- Assessment:
  - semantically safe because whole-function emission blocks are permuted
  - data/raw segments keep their relative slots
  - robust for the provided QBE text output model

## Data Randomization

- No masking, layout randomization, or data relocation transformation was found.
- Status: not evidenced.

## Timing Defense

- Static evidence:
  - helper generation in [arm64/emit.c](../../arm64/emit.c)
  - direct-call redirection for `strcmp` when `--sc-ctstrcmp` is enabled
- Dynamic evidence:
  - baseline used `_strcmp`; protected assembly used `___qbe_sc_ctstrcmp`
  - a renamed copy of the demo still emitted `___qbe_sc_ctstrcmp`
  - the semantic counterexample now preserves behavior: baseline exit `255`, protected exit `255`
  - explicit timing measurements reduced the median spread from `514833 ns` to `83293 ns`
- Assessment:
  - works for the reproduced native attack pipeline in this workspace
  - preserves the observable `strcmp` contract on the tested counterexample
  - should be graded as implemented for the assignment scope, with a documented portability limitation

## Assignment 5

- No assignment-5-specific material was found in the workspace.
- Status: not evidenced.

# Security Analysis

- Real protection gain exists for the stack-overflow demo, but the canary design is predictable.
- NOP insertion and function permutation provide diversification, not strong standalone security.
- Register randomization can raise attack cost but does not change semantics of the generated machine code model by itself.
- The timing defense lowers the measured demo leak on the native ARM64 target without breaking the tested `strcmp` semantics.

# Performance Analysis

- Stack canaries add helper calls in prologue and epilogue of every ARM64 function in the protected build.
- NOP insertion inflates code size and branch-path length proportionally to the configured percentage.
- Register randomization can enlarge save/restore sets. In the reproduced demo, one function grew from a `16`-byte frame to `80` bytes.
- The timing helper is noticeably slower than direct `strcmp`, but the slowdown is traded for flatter prefix timing on the demo.

# Improvement Plan

1. Replace deterministic stack canaries with runtime-generated unpredictable values.
2. Keep the timing-defense regression tests for renamed functions and semantic preservation.
3. If portability is required later, add equivalent helper lowering for other backends.
4. Explicitly document assignment coverage gaps for instruction substitution, basic block randomization, data randomization, and assignment 5.
