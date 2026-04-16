## Timing Defense Test

Primary sources:
- `test/_timing_sidechannel.ssa`
- `timing_target_driver.c`
- `timing_attack.py`

Checks:
- baseline vs `--sc-ctstrcmp`
- verify direct `strcmp` calls are redirected to the helper on the native ARM64 target
- verify `--no-sc-ctstrcmp` reproduces baseline
- verify a renamed function still receives protection
- verify the transformation preserves `strcmp` return-value semantics
- measure prefix-dependent timing on both binaries and confirm the protected spread is lower
