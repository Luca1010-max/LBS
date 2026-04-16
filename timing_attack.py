#!/usr/bin/env python3
import argparse
import statistics
import subprocess
import time


def start_target(target):
    return subprocess.Popen(
        [target],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        bufsize=1,
    )


def measure(proc, guess, samples):
    vals = []
    for _ in range(samples):
        t0 = time.perf_counter_ns()
        proc.stdin.write(guess + "\n")
        proc.stdin.flush()
        proc.stdout.readline()
        vals.append(time.perf_counter_ns() - t0)
    return statistics.median(vals), statistics.mean(vals)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("target")
    ap.add_argument("--alphabet", default="ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    ap.add_argument("--length", type=int, default=8)
    ap.add_argument("--samples", type=int, default=17)
    ap.add_argument("--fill", default="A")
    ns = ap.parse_args()

    proc = start_target(ns.target)
    known = ""
    try:
        for pos in range(ns.length):
            scores = []
            for ch in ns.alphabet:
                guess = known + ch + ns.fill * (ns.length - pos - 1)
                med, mean = measure(proc, guess, ns.samples)
                scores.append((med, mean, ch, guess))
            scores.sort(reverse=True)
            med, mean, ch, guess = scores[0]
            known += ch
            print(f"pos={pos} best={ch} median_ns={med} mean_ns={int(mean)} secret_so_far={known}")
            top = ", ".join(f"{c}:{m}" for m, _, c, _ in scores[:3])
            print(f"top3={top}")
        print(f"recovered={known}")
    finally:
        proc.stdin.close()
        proc.stdout.close()
        proc.wait()


if __name__ == "__main__":
    main()
