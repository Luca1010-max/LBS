# Scorecard

Scoring scale: `0 = not vorhanden`, `1 = rudimentaer/fehlerhaft`, `2 = teilweise korrekt`, `3 = solide Basis`, `4 = gut und belastbar`, `5 = sehr gut, modern, robust`

| Technique | Syntactic Integration | Semantic Correctness | Best Practices | Security | Performance | Robustness | Verdict |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Stack canary | 4 | 3 | 2 | 2 | 3 | 3 | teilweise bestanden |
| NOP insertion | 4 | 4 | 3 | 2 | 3 | 3 | bestanden |
| Instruction substitution | 0 | 0 | 0 | 0 | 0 | 0 | nicht bestanden |
| Register randomization | 4 | 4 | 3 | 3 | 2 | 3 | bestanden |
| Basic block randomization | 0 | 0 | 0 | 0 | 0 | 0 | nicht bestanden |
| Function permutation | 4 | 4 | 3 | 2 | 3 | 4 | bestanden |
| Data randomization | 0 | 0 | 0 | 0 | 0 | 0 | nicht bestanden |
| Timing defense | 4 | 4 | 3 | 3 | 2 | 3 | bestanden fuer den nativen Angriffspfad |
| Assignment 5 | 0 | 0 | 0 | 0 | 0 | 0 | nicht bestanden |

## Minimum Acceptance Check

| Technique | Activation/Deactivation | Baseline Semantics Validated | Security Goal Reached | No Critical Codegen Error | Edge Cases Covered | In `SCHWACHSTELLEN.md` | Result |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Stack canary | yes | yes | partially | yes | partially | yes | partially |
| NOP insertion | yes | yes | partially | yes | partially | yes | pass |
| Register randomization | yes | yes | partially | yes | partially | yes | pass |
| Function permutation | yes | yes | partially | yes | partially | yes | pass |
| Timing defense | yes | yes | yes | yes | partially | yes | pass |
