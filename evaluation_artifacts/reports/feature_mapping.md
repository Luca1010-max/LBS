# Feature Mapping

## Workspace Discovery

- Project roots found: `qbe-1.2/`, `minic/`, `tools/`, `test/`, `demo/`, `result/`
- Build entry points: `Makefile`, `minic/Makefile`
- Runtime helpers found: `timing_attack.py`, `timing_target_driver.c`
- Toolchain discovery:
  - `cc`: present
  - `python3`: present
  - `cproc`: not found
  - `mimic`: not found
- Default target from `./qbe -t ?`: `arm64_apple`

## Command Slots

- `CMD_BUILD_BASELINE`: `make CANARY=0 qbe tools/genasm`
- `CMD_BUILD_FEATURE(stack_canary)`: `make CANARY=1 qbe tools/genasm`
- `CMD_BUILD_FEATURE(runtime_flags)`: `make qbe tools/genasm`
- `CMD_EMIT_ASM`: `./qbe [flags] -o <out.s> <input.ssa>`
- `CMD_RUN(binary,input)`: direct binary execution or persistent stdin driver, depending on the test
- `CMD_EMIT_IR`: not available in this workspace; QBE consumes SSA directly and no `cproc` frontend was found locally

## Technique Map

| Technique | Activation Logic | Implementation Sites | Security-Relevant Sites | Status |
| --- | --- | --- | --- | --- |
| Stack canary | build-time `CANARY` make variable mapped to `-DARM64_STACK_CANARY` | `Makefile`, `arm64/emit.c` | [arm64/emit.c](../../arm64/emit.c), lines around `fncanary`, helper emission, prologue, epilogue | belegt |
| NOP insertion | `--diversify --div-nop=N`, optional `--no-div-nop` | [main.c](../../main.c), [util.c](../../util.c), [amd64/emit.c](../../amd64/emit.c), [arm64/emit.c](../../arm64/emit.c), [rv64/emit.c](../../rv64/emit.c) | emitter loops before normal instruction emission | belegt |
| Instruction substitution | no flag, no state bit, no substitution pass found | none beyond normal emission tables | none | nicht belegt |
| Register randomization | `--diversify --div-regrand`, optional `--no-div-regrand` | [main.c](../../main.c), [util.c](../../util.c), [rega.c](../../rega.c) | `pickreg` tie-break path | belegt |
| Basic block randomization | no flag, no block-order pass found | none | none | nicht belegt |
| Function permutation | `--diversify --div-funcperm`, optional `--no-div-funcperm` | [main.c](../../main.c), [util.c](../../util.c), [all.h](../../all.h) | buffered function/raw segment permutation before final flush | belegt |
| Data randomization | no flag, no masking/layout transform found | none | none | nicht belegt |
| Timing defense | `--sc-ctstrcmp`, optional `--no-sc-ctstrcmp` | [main.c](../../main.c), [all.h](../../all.h), [arm64/emit.c](../../arm64/emit.c) | direct `strcmp` call redirection plus semantics-preserving helper on the native ARM64 target | belegt |
| Assignment 5 | no handout or dedicated feature found | none | none | offen / nicht belegt |

## Notes

- The only feature flags discovered in `main.c` are `div-nop`, `div-regrand`, `div-funcperm`, and `sc-ctstrcmp`.
- No semantic evidence was found for instruction substitution, basic block randomization, or data randomization.
- The timing defense is implemented in the ARM64 backend, which matches the native target discovered in this workspace (`arm64_apple`).
- The current helper preserves `strcmp` sign semantics and no longer depends on the source-level function name.
