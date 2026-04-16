## Basic Block Randomization Test

Discovery result: no block-order feature switch or CFG reordering logic was found.

Checks:
- inspect CLI flags
- inspect `main.c` function output path
- inspect CFG and emitter code for alternate block ordering
- mark as `not evidenced` unless block order changes independently of function order

