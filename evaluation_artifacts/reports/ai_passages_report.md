# Possible AI Passages

This section reports only heuristic suspicion indicators. It does **not** claim proof of authorship and should not trigger automatic score deductions.

## 1. Walkthrough documents as a group

- Fundstellen:
  - `01stack_canaries_walkthrough.txt`
  - `02software_diversity_walkthrough.txt`
  - `03function_permutation_walkthrough.txt`
  - `04side_channels_walkthrough.txt`
- Why suspicious:
  - very uniform tutorial-like structure across unrelated assignments
  - repeated rhetorical framing such as explicit justification of design choices, recap sections, and highly polished explanatory cadence
  - unusually consistent sentence rhythm and vocabulary despite different technical topics
- Confidence: medium
- Potential influence on grading:
  - documentation quality may overstate implementation maturity compared with the actual code
- Recommended manual follow-up:
  - ask the student to explain the design decisions without notes, especially the scope limits and trade-offs stated in the texts

## 2. Repository `README` additions

- Fundstelle:
  - `README`
- Why suspicious:
  - abrupt style shift from the original upstream English README into a German command cookbook
  - the inserted sections mirror the same polished walkthrough style as the assignment documents
- Confidence: medium
- Potential influence on grading:
  - low for technical correctness; moderate for authorship questions around the written explanation
- Recommended manual follow-up:
  - compare the README edits to the student's normal prose and ask for a live reproduction of one command flow

## 3. No strong code-level AI indicator

- Fundstellen:
  - compiler source files and demo/test files reviewed in this evaluation
- Why suspicious:
  - no high-confidence AI marker was found in the code itself; the code has normal local quirks and targeted hacks rather than generic polished synthesis
- Confidence: low
- Potential influence on grading:
  - none by itself
- Recommended manual follow-up:
  - focus grading on the technical evidence rather than authorship speculation

