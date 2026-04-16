## Function Permutation Test

Source input: `test/_funcperm_demo.ssa`

Checks:
- baseline vs `--diversify --div-funcperm`
- `--no-div-funcperm` must reproduce baseline
- same seed must reproduce identical assembly
- different seed must change function order
- 10 seeds must produce multiple unique outputs
- linked binaries must preserve exit status

