<!-- markdownlint-disable -->

# Hardening Report: hms5232--install-CNS11643-fonts-action/v1.2.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **hms5232--install-CNS11643-fonts-action/v1.2.0** was hardened automatically. 4 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in action.yml directly interpolate GitHub Actions expressions (`${{ ... }}`) inside shell command strings, violating sub-rule (a). This includes `${{ github.action_path }}` (used to construct the command path) and `${{ inputs.download-flag }}` (a user-controlled input injected as a shell argument). Even though `github.action_path` appears benign, any `${{ ... }}` expression interpolated directly into a `run:` block is a script-injection risk because the value flows through YAML template substitution before the shell parses it. The `inputs.download-flag` value is especially dangerous as it is caller-controlled and injected directly into the shell command line. Affected steps:
- Line 26: `run: ${{ github.action_path }}/init.sh`
- Line 37: `${{ github.action_path }}/download_kai.sh -f "${{ inputs.download-flag }}"`
- Line 55: `${{ github.action_path }}/download_sung.sh -f "${{ inputs.download-flag }}"`
- Line 64: `${{ github.action_path }}/install.sh`
- Line 69: `run: ${{ github.action_path }}/clear.sh`

Fix: Move `github.action_path` into an `env:` variable (e.g. `ACTION_PATH: ${{ github.action_path }}`) and reference it as `"$ACTION_PATH"` in the shell script. Similarly move `inputs.download-flag` into an env var and reference it as `"$DOWNLOAD_FLAG"`.


Locations:

- `action.yml:26`
- `action.yml:37`
- `action.yml:55`
- `action.yml:64`
- `action.yml:69`

### unpinned-uses (severity: high)

All four `uses:` references in action.yml pin to a mutable version tag (`@v5`) rather than an immutable 40-character commit SHA. If the upstream action is compromised or the tag is moved, the action will silently execute attacker-controlled code. Failing references:
- `actions/cache/restore@v5` (line 31)
- `actions/cache/save@v5` (line 43)
- `actions/cache/restore@v5` (line 49)
- `actions/cache/save@v5` (line 60)

Fix: Pin each reference to a full SHA, e.g. `actions/cache/restore@1bd1e32a3bdc45362d1e726936510720a7c6158d # v5`.

Locations:

- `action.yml:31`
- `action.yml:43`
- `action.yml:49`
- `action.yml:60`

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

**Fixes applied:** script-injection, unpinned-uses, static-inline-injection

**Notes:**

Fixed all findings in action.yml:
1. script-injection / static-inline-injection: Moved all ${{ github.action_path }} expressions into env: blocks as ACTION_PATH, and all ${{ inputs.download-flag }} expressions into env: blocks as DOWNLOAD_FLAG. Shell scripts now reference these as $ACTION_PATH and $DOWNLOAD_FLAG respectively.
2. unpinned-uses: Pinned all four uses: references (actions/cache/restore@v5 and actions/cache/save@v5) to their full commit SHA caa296126883cff596d87d8935842f9db880ef25, with the original tag preserved as a comment (# v5).

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed unquoted `${flags}` expansion in both download_kai.sh (line 14) and download_sung.sh (line 14). Replaced the bare `${flags}` in the wget command with a properly tokenized bash array. The fix: (1) initializes an empty `flags_array=()`, (2) uses an `if [ -n "$flags" ]` guard to avoid xargs running on empty input, (3) tokenizes the flags string using `printf '%s' "$flags" | xargs printf '%s\0'` with a NUL-delimited read loop into the array, and (4) expands the array as `"${flags_array[@]}"` in the wget command. This prevents shell metacharacters (`;`, `|`, `$(...)`, etc.) in `inputs.download-flag` from being interpreted as shell commands, while preserving support for multiple space-separated wget flags.

