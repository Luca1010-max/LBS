## Register Randomization Test

Source input: `test/_regrand_demo.ssa`

Checks:
- baseline vs `--diversify --div-regrand`
- `--no-div-regrand` must reproduce baseline
- same seed must reproduce identical assembly
- different seed must change assembly
- 10 seeds must produce multiple unique outputs
- linked binaries must preserve observable behavior

