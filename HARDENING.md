<!-- markdownlint-disable -->

# Hardening Report: hms5232--install-CNS11643-fonts-action/v1.2.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **hms5232--install-CNS11643-fonts-action/v1.2.0** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in action.yml directly interpolate `${{ ... }}` expressions inside shell command strings, violating rule (a). Most critically, `${{ inputs.download-flag }}` is an attacker-controlled input interpolated directly into the shell on lines 37 and 55 — a calling workflow can supply a value like `; malicious-command #` to achieve arbitrary command execution. Additionally, `${{ github.action_path }}` is interpolated directly in run: blocks on lines 26, 37, 55, 64, and 69. All `${{ ... }}` expressions in run: blocks are script-injection findings regardless of context. The fix is to pass these values through env: variables and reference them as quoted shell variables (e.g. `"$ACTION_PATH"`, `"$DOWNLOAD_FLAG"`) instead of using template interpolation inside the run: script.

Locations:

- `action.yml:26`
- `action.yml:37`
- `action.yml:55`
- `action.yml:64`
- `action.yml:69`

### unpinned-uses (severity: high)

All four `uses:` references in action.yml are pinned to the mutable version tag `@v5` rather than an immutable 40-character commit SHA. A supply-chain compromise of the `actions/cache` repository could silently replace the tag and execute malicious code. Failing references: `actions/cache/restore@v5` (lines 31 and 50), `actions/cache/save@v5` (lines 43 and 62). Each should be replaced with the full SHA digest, e.g. `actions/cache/restore@<40-hex-sha> # v5`.

Locations:

- `action.yml:31`
- `action.yml:43`
- `action.yml:50`
- `action.yml:62`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.download-flag }}" appears directly in run: block of step ""; move to env: map

Locations:

- `action.yml:39`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.download-flag }}" appears directly in run: block of step ""; move to env: map

Locations:

- `action.yml:59`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, static-inline-injection, unpinned-uses

**Notes:**

Fixed all findings in hardened/action/action.yml:
1. script-injection / static-inline-injection: Moved all ${{ github.action_path }} and ${{ inputs.download-flag }} expressions from run: blocks into env: maps. They are now referenced as quoted shell variables $ACTION_PATH and $DOWNLOAD_FLAG in the shell scripts, preventing script injection.
2. unpinned-uses: Pinned all four uses: references (actions/cache/restore@v5 and actions/cache/save@v5) to the full immutable commit SHA caa296126883cff596d87d8935842f9db880ef25 with # v5 comments for readability.

