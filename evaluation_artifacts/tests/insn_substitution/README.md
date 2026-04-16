## Instruction Substitution Test

Discovery result: no CLI flag, config bit, or backend substitution path was found.

Checks:
- search `main.c`, `all.h`, and backend emitters for activation logic
- search for semantic opcode rewrites beyond NOP insertion and call redirection
- mark as `not evidenced` unless a real substitution path is found

