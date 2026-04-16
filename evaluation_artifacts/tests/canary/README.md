## Stack Canary Test

Source input: `demo/stack_canary_attack.ssa`

Checks:
- build `qbe` with `CANARY=1` and `CANARY=0`
- emit ARM64 assembly for both variants
- verify prologue/epilogue helper calls only exist in the canary build
- link both binaries with `cc`
- confirm the unprotected binary prints `control flow hijacked`
- confirm the protected binary traps before returning

