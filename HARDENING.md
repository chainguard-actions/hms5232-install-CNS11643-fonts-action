<!-- markdownlint-disable -->

# Hardening Report: hms5232--install-CNS11643-fonts-action/v1.2.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **hms5232--install-CNS11643-fonts-action/v1.2.0** was hardened automatically. 4 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple run: blocks in action.yml directly interpolate ${{ ... }} expressions into shell command strings (sub-rule a). This causes GitHub Actions to perform template substitution before the shell ever sees the value, allowing an attacker-controlled input to inject arbitrary shell commands.

1. Line 26: `run: ${{ github.action_path }}/init.sh` — github.action_path interpolated directly.
2. Line 37: `${{ github.action_path }}/download_kai.sh -f "${{ inputs.download-flag }}"` — both github.action_path and the user-controlled inputs.download-flag are interpolated directly into the shell command. A caller can supply a download-flag value like `; malicious-command #` to achieve command injection.
3. Line 54: `${{ github.action_path }}/download_sung.sh -f "${{ inputs.download-flag }}"` — same issue as above for the Sung font step.
4. Line 64: `${{ github.action_path }}/install.sh` — github.action_path interpolated directly.
5. Line 67: `run: ${{ github.action_path }}/clear.sh` — github.action_path interpolated directly.

Fix: replace all ${{ github.action_path }} references in run: blocks with the $GITHUB_ACTION_PATH environment variable, and route inputs.download-flag through an env: block with a quoted shell variable (e.g., env: DOWNLOAD_FLAG: ${{ inputs.download-flag }} then use "$DOWNLOAD_FLAG" in the script).

Locations:

- `action.yml:26`
- `action.yml:37`
- `action.yml:54`
- `action.yml:64`
- `action.yml:67`

### unpinned-uses (severity: high)

All 4 uses: references in action.yml are pinned to a mutable version tag (@v5) rather than an immutable 40-character commit SHA. If the upstream action is compromised or the tag is moved, the action will silently execute different code. Affected references:
- actions/cache/restore@v5 (lines 31 and 48)
- actions/cache/save@v5 (lines 41 and 58)

Fix: pin each reference to a full SHA, e.g. `uses: actions/cache/restore@1bd1e32a3bdc45362d1e726936510720a7c6158d # v5`.

Locations:

- `action.yml:31`
- `action.yml:41`
- `action.yml:48`
- `action.yml:58`

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
1. script-injection: Replaced all ${{ github.action_path }} references in run: blocks with $GITHUB_ACTION_PATH (the safe built-in environment variable). Moved ${{ inputs.download-flag }} to env: blocks as DOWNLOAD_FLAG and referenced it as "$DOWNLOAD_FLAG" in the shell scripts.
2. unpinned-uses: Pinned all 4 uses: references (actions/cache/restore@v5 x2 and actions/cache/save@v5 x2) to the full commit SHA caa296126883cff596d87d8935842f9db880ef25 with # v5 comment.
3. static-inline-injection: Both occurrences of ${{ inputs.download-flag }} in run: blocks (lines 39 and 59) moved to env: blocks, addressing the same root cause as the script-injection finding.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed unquoted `${flags}` expansion in both download_kai.sh (line 15) and download_sung.sh (line 15). Replaced the bare `${flags}` with a bash array populated via xargs-based quote-aware tokenization: an empty array `wget_flags=()` is initialized, then if `${flags}` is non-empty, it is tokenized using `printf '%s' "${flags}" | xargs printf '%s\0'` with a NUL-delimited read loop into the array, and finally expanded as `"${wget_flags[@]}"` in the wget command. This prevents word-splitting and glob expansion of user-controlled input while correctly handling multiple flags as separate arguments.

