## Data Randomization Test

Discovery result: no masking, layout randomization, or data relocation logic was found.

Checks:
- inspect CLI flags and global feature state
- inspect lowering / emission code for data transformations
- mark as `not evidenced` unless real data layout or masking changes are found

