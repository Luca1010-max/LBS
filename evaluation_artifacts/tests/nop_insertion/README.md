## NOP Insertion Test

Source input: `test/_nop_insert_demo.ssa`

Checks:
- baseline vs `--diversify --div-nop=35`
- `--no-div-nop` must reproduce baseline
- same seed must reproduce identical assembly
- different seed must change assembly
- 10 seeds must produce multiple unique outputs
- linked binaries must preserve program behavior

