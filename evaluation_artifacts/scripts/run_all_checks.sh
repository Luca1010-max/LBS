#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)
REPORT_DIR="$ROOT/evaluation_artifacts/reports"
RESULT_DIR="$ROOT/result"
TMPDIR="${TMPDIR:-/tmp}/qbe_eval.$$"

mkdir -p "$TMPDIR" "$REPORT_DIR" "$RESULT_DIR"
trap 'rm -rf "$TMPDIR"' EXIT HUP INT TERM

SUMMARY="$TMPDIR/summary.tsv"
: > "$SUMMARY"

pass_count=0
fail_count=0

record() {
	name=$1
	status=$2
	reason=$3
	printf "%s\t%s\t%s\n" "$name" "$status" "$reason" >> "$SUMMARY"
	printf "%-20s %s - %s\n" "$name" "$status" "$reason"
	if [ "$status" = "PASS" ]; then
		pass_count=$((pass_count + 1))
	else
		fail_count=$((fail_count + 1))
	fi
}

run_capture() {
	out=$1
	shift
	set +e
	"$@" >"$out" 2>&1
	code=$?
	set -e
	return "$code"
}

count_unique_shas() {
	pattern=$1
	# shellcheck disable=SC2086
	shasum -a 256 $pattern | awk '{print $1}' | sort -u | wc -l | tr -d ' '
}

printf "Workspace: %s\n" "$ROOT"
printf "Tool discovery:\n"
if [ -x "$ROOT/qbe" ]; then
	printf "  qbe target: %s\n" "$("$ROOT/qbe" -t \?)"
else
	printf "  qbe target: not built yet\n"
fi
printf "  cc: %s\n" "$(command -v cc)"
printf "  python3: %s\n" "$(command -v python3)"
if command -v cproc >/dev/null 2>&1; then
	printf "  cproc: %s\n" "$(command -v cproc)"
else
	printf "  cproc: not found\n"
fi
if command -v mimic >/dev/null 2>&1; then
	printf "  mimic: %s\n" "$(command -v mimic)"
else
	printf "  mimic: not found\n"
fi

cd "$ROOT"

make clean >/dev/null
make CANARY=1 qbe tools/genasm >/dev/null
cp -f qbe "$RESULT_DIR/qbe.canary"
make clean >/dev/null
make CANARY=0 qbe tools/genasm >/dev/null
cp -f qbe "$RESULT_DIR/qbe.no_canary"

"$RESULT_DIR/qbe.canary" -o "$TMPDIR/canary.s" demo/stack_canary_attack.ssa
"$RESULT_DIR/qbe.no_canary" -o "$TMPDIR/no_canary.s" demo/stack_canary_attack.ssa
cc "$TMPDIR/canary.s" -o "$TMPDIR/canary.bin"
cc "$TMPDIR/no_canary.s" -o "$TMPDIR/no_canary.bin"

if run_capture "$TMPDIR/canary.out" "$TMPDIR/canary.bin"; then
	canary_exit=0
else
	canary_exit=$?
fi
if run_capture "$TMPDIR/no_canary.out" "$TMPDIR/no_canary.bin"; then
	no_canary_exit=0
else
	no_canary_exit=$?
fi

if rg -q "__qbe_stack_canary_check" "$TMPDIR/canary.s" &&
	! rg -q "__qbe_stack_canary_check" "$TMPDIR/no_canary.s" &&
	grep -q "control flow hijacked" "$TMPDIR/no_canary.out" &&
	[ "$canary_exit" -ne 0 ]; then
	record "stack_canary" "PASS" "helper emission and runtime trap reproduced"
else
	record "stack_canary" "FAIL" "expected helper/runtime behavior was not reproduced"
fi

./qbe -o "$TMPDIR/nop.base.s" test/_nop_insert_demo.ssa
./qbe --diversify --div-nop=35 --div-seed=7 -o "$TMPDIR/nop.seed7.s" test/_nop_insert_demo.ssa
./qbe --diversify --div-nop=35 --no-div-nop -o "$TMPDIR/nop.off.s" test/_nop_insert_demo.ssa
./qbe --diversify --div-nop=35 --div-seed=7 -o "$TMPDIR/nop.seed7b.s" test/_nop_insert_demo.ssa
./qbe --diversify --div-nop=35 --div-seed=8 -o "$TMPDIR/nop.seed8.s" test/_nop_insert_demo.ssa
for s in 1 2 3 4 5 6 7 8 9 10; do
	./qbe --diversify --div-nop=35 --div-seed="$s" -o "$TMPDIR/nop.$s.s" test/_nop_insert_demo.ssa
done
cc "$TMPDIR/nop.base.s" -o "$TMPDIR/nop.base.bin"
cc "$TMPDIR/nop.seed7.s" -o "$TMPDIR/nop.seed7.bin"
if run_capture "$TMPDIR/nop.base.out" "$TMPDIR/nop.base.bin"; then
	nop_base_exit=0
else
	nop_base_exit=$?
fi
if run_capture "$TMPDIR/nop.seed7.out" "$TMPDIR/nop.seed7.bin"; then
	nop_div_exit=0
else
	nop_div_exit=$?
fi
nop_unique=$(count_unique_shas "$TMPDIR/nop.[1-9].s $TMPDIR/nop.10.s")

if rg -q '^\tnop$' "$TMPDIR/nop.seed7.s" &&
	cmp -s "$TMPDIR/nop.base.s" "$TMPDIR/nop.off.s" &&
	cmp -s "$TMPDIR/nop.seed7.s" "$TMPDIR/nop.seed7b.s" &&
	! cmp -s "$TMPDIR/nop.seed7.s" "$TMPDIR/nop.seed8.s" &&
	cmp -s "$TMPDIR/nop.base.out" "$TMPDIR/nop.seed7.out" &&
	[ "$nop_base_exit" -eq "$nop_div_exit" ] &&
	[ "$nop_unique" -ge 2 ]; then
	record "nop_insertion" "PASS" "assembly diversity and semantic equivalence reproduced"
else
	record "nop_insertion" "FAIL" "NOP checks were not jointly satisfied"
fi

./qbe -o "$TMPDIR/regrand.base.s" test/_regrand_demo.ssa
./qbe --diversify --div-regrand --div-seed=7 -o "$TMPDIR/regrand.seed7.s" test/_regrand_demo.ssa
./qbe --diversify --div-regrand --no-div-regrand -o "$TMPDIR/regrand.off.s" test/_regrand_demo.ssa
./qbe --diversify --div-regrand --div-seed=7 -o "$TMPDIR/regrand.seed7b.s" test/_regrand_demo.ssa
./qbe --diversify --div-regrand --div-seed=8 -o "$TMPDIR/regrand.seed8.s" test/_regrand_demo.ssa
for s in 1 2 3 4 5 6 7 8 9 10; do
	./qbe --diversify --div-regrand --div-seed="$s" -o "$TMPDIR/regrand.$s.s" test/_regrand_demo.ssa
done
cc "$TMPDIR/regrand.base.s" -o "$TMPDIR/regrand.base.bin"
cc "$TMPDIR/regrand.seed7.s" -o "$TMPDIR/regrand.seed7.bin"
if run_capture "$TMPDIR/regrand.base.out" "$TMPDIR/regrand.base.bin"; then
	regrand_base_exit=0
else
	regrand_base_exit=$?
fi
if run_capture "$TMPDIR/regrand.seed7.out" "$TMPDIR/regrand.seed7.bin"; then
	regrand_div_exit=0
else
	regrand_div_exit=$?
fi
regrand_unique=$(count_unique_shas "$TMPDIR/regrand.[1-9].s $TMPDIR/regrand.10.s")

if ! cmp -s "$TMPDIR/regrand.base.s" "$TMPDIR/regrand.seed7.s" &&
	cmp -s "$TMPDIR/regrand.base.s" "$TMPDIR/regrand.off.s" &&
	cmp -s "$TMPDIR/regrand.seed7.s" "$TMPDIR/regrand.seed7b.s" &&
	! cmp -s "$TMPDIR/regrand.seed7.s" "$TMPDIR/regrand.seed8.s" &&
	[ "$regrand_base_exit" -eq "$regrand_div_exit" ] &&
	[ "$regrand_unique" -ge 2 ]; then
	record "reg_randomization" "PASS" "register tie-break randomization reproduced"
else
	record "reg_randomization" "FAIL" "register randomization checks were not jointly satisfied"
fi

./qbe -o "$TMPDIR/funcperm.base.s" test/_funcperm_demo.ssa
./qbe --diversify --div-funcperm --div-seed=7 -o "$TMPDIR/funcperm.seed7.s" test/_funcperm_demo.ssa
./qbe --diversify --div-funcperm --no-div-funcperm -o "$TMPDIR/funcperm.off.s" test/_funcperm_demo.ssa
./qbe --diversify --div-funcperm --div-seed=7 -o "$TMPDIR/funcperm.seed7b.s" test/_funcperm_demo.ssa
./qbe --diversify --div-funcperm --div-seed=8 -o "$TMPDIR/funcperm.seed8.s" test/_funcperm_demo.ssa
for s in 1 2 3 4 5 6 7 8 9 10; do
	./qbe --diversify --div-funcperm --div-seed="$s" -o "$TMPDIR/funcperm.$s.s" test/_funcperm_demo.ssa
done
cc "$TMPDIR/funcperm.base.s" -o "$TMPDIR/funcperm.base.bin"
cc "$TMPDIR/funcperm.seed7.s" -o "$TMPDIR/funcperm.seed7.bin"
if run_capture "$TMPDIR/funcperm.base.out" "$TMPDIR/funcperm.base.bin"; then
	funcperm_base_exit=0
else
	funcperm_base_exit=$?
fi
if run_capture "$TMPDIR/funcperm.seed7.out" "$TMPDIR/funcperm.seed7.bin"; then
	funcperm_div_exit=0
else
	funcperm_div_exit=$?
fi
funcperm_unique=$(count_unique_shas "$TMPDIR/funcperm.[1-9].s $TMPDIR/funcperm.10.s")

if ! cmp -s "$TMPDIR/funcperm.base.s" "$TMPDIR/funcperm.seed7.s" &&
	cmp -s "$TMPDIR/funcperm.base.s" "$TMPDIR/funcperm.off.s" &&
	cmp -s "$TMPDIR/funcperm.seed7.s" "$TMPDIR/funcperm.seed7b.s" &&
	! cmp -s "$TMPDIR/funcperm.seed7.s" "$TMPDIR/funcperm.seed8.s" &&
	[ "$funcperm_base_exit" -eq "$funcperm_div_exit" ] &&
	[ "$funcperm_unique" -ge 2 ]; then
	record "func_permutation" "PASS" "function order changes while behavior stays stable"
else
	record "func_permutation" "FAIL" "function permutation checks were not jointly satisfied"
fi

record "insn_substitution" "FAIL" "no implementation evidence found in CLI or backend code"
record "bb_randomization" "FAIL" "no block-order randomization path found"
record "data_randomization" "FAIL" "no data masking/layout randomization path found"

./qbe -o "$TMPDIR/timing.base.s" test/_timing_sidechannel.ssa
./qbe --sc-ctstrcmp -o "$TMPDIR/timing.protected.s" test/_timing_sidechannel.ssa
./qbe --sc-ctstrcmp --no-sc-ctstrcmp -o "$TMPDIR/timing.off.s" test/_timing_sidechannel.ssa
cc "$TMPDIR/timing.base.s" timing_target_driver.c -o "$TMPDIR/timing.base.bin"
cc "$TMPDIR/timing.protected.s" timing_target_driver.c -o "$TMPDIR/timing.protected.bin"
TIMING_BIN_DIR=$TMPDIR
export TIMING_BIN_DIR
if python3 - <<'PY' >"$REPORT_DIR/timing_measurements.txt"
import os, statistics, subprocess, time
secret = "SECRETSX"
guesses = [
    "AAAAAAAA",
    "SAAAAAAA",
    "SEAAAAAA",
    "SECXXXXX",
    "SECRXXXX",
    "SECREXXX",
    "SECRETXX",
    "SECRETSX",
]
root = os.environ["TIMING_BIN_DIR"]
spreads = {}
for target in ["timing.base.bin", "timing.protected.bin"]:
    proc = subprocess.Popen(
        [os.path.join(root, target)],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        text=True,
        bufsize=1,
    )
    print("TARGET", target)
    meds = []
    try:
        for guess in guesses:
            vals = []
            for _ in range(31):
                t0 = time.perf_counter_ns()
                proc.stdin.write(guess + "\n")
                proc.stdin.flush()
                proc.stdout.readline()
                vals.append(time.perf_counter_ns() - t0)
            prefix = 0
            for a, b in zip(guess, secret):
                if a != b:
                    break
                prefix += 1
            print("prefix=%d guess=%s median_ns=%d mean_ns=%d" % (
                prefix,
                guess,
                int(statistics.median(vals)),
                int(statistics.mean(vals)),
            ))
            meds.append(int(statistics.median(vals)))
    finally:
        proc.stdin.close()
        proc.stdout.close()
        proc.wait()
    spreads[target] = max(meds) - min(meds)
    print("spread_ns=%d" % spreads[target])
print("baseline_spread_ns=%d" % spreads["timing.base.bin"])
print("protected_spread_ns=%d" % spreads["timing.protected.bin"])
raise SystemExit(0 if spreads["timing.protected.bin"] < spreads["timing.base.bin"] else 1)
PY
then
	timing_spread_ok=1
else
	timing_spread_ok=0
fi

sed 's/\$timing_check_secret/\$other_secret_check/' test/_timing_sidechannel.ssa >"$TMPDIR/timing_other_name.ssa"
./qbe --sc-ctstrcmp -o "$TMPDIR/timing_other_name.s" "$TMPDIR/timing_other_name.ssa"
cat >"$TMPDIR/timing_semantic_break.ssa" <<'EOF'
data $a = { b "A", b 0 }
data $b = { b "B", b 0 }

export function w $timing_check_secret() {
@start
	%r =w call $strcmp(l $a, l $b)
	ret %r
}

export function w $main() {
@start
	%r =w call $timing_check_secret()
	ret %r
}
EOF
./qbe -o "$TMPDIR/timing_semantic_break.base.s" "$TMPDIR/timing_semantic_break.ssa"
./qbe --sc-ctstrcmp -o "$TMPDIR/timing_semantic_break.protected.s" "$TMPDIR/timing_semantic_break.ssa"
cc "$TMPDIR/timing_semantic_break.base.s" -o "$TMPDIR/timing_semantic_break.base.bin"
cc "$TMPDIR/timing_semantic_break.protected.s" -o "$TMPDIR/timing_semantic_break.protected.bin"
if run_capture "$TMPDIR/timing_semantic_break.base.out" "$TMPDIR/timing_semantic_break.base.bin"; then
	timing_base_exit=0
else
	timing_base_exit=$?
fi
if run_capture "$TMPDIR/timing_semantic_break.protected.out" "$TMPDIR/timing_semantic_break.protected.bin"; then
	timing_protected_exit=0
else
	timing_protected_exit=$?
fi

if ! rg -q "__qbe_sc_ctstrcmp" "$TMPDIR/timing.base.s" &&
	rg -q "__qbe_sc_ctstrcmp" "$TMPDIR/timing.protected.s" &&
	cmp -s "$TMPDIR/timing.base.s" "$TMPDIR/timing.off.s" &&
	rg -q "__qbe_sc_ctstrcmp" "$TMPDIR/timing_other_name.s" &&
	[ "$timing_base_exit" -eq "$timing_protected_exit" ] &&
	[ "$timing_spread_ok" -eq 1 ]
then
	record "timing_defense" "PASS" "direct strcmp calls are rewritten semantically safely and prefix leakage is reduced on the native target"
else
	record "timing_defense" "FAIL" "timing defense did not satisfy semantic and leakage-reduction checks"
fi

record "assignment5" "FAIL" "no assignment 5 material or implementation mapping was found"

{
	printf '%s\n\n' '# Latest Automated Run'
	printf '%s\n' "- Workspace: \`$ROOT\`"
	printf '%s\n' "- Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
	printf '%s\n' "- PASS: $pass_count"
	printf '%s\n\n' "- FAIL: $fail_count"
	printf '%s\n\n' '## Technique Results'
	printf '%s\n' '| Technique | Status | Reason |'
	printf '%s\n' '| --- | --- | --- |'
	awk -F '\t' '{printf "| %s | %s | %s |\n", $1, $2, $3}' "$SUMMARY"
} >"$REPORT_DIR/latest_run.md"

printf "\nSummary written to %s\n" "$REPORT_DIR/latest_run.md"

if [ "$fail_count" -ne 0 ]; then
	exit 1
fi
