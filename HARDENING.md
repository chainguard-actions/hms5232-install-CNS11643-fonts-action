<!-- markdownlint-disable -->

# Hardening Report: hms5232--install-CNS11643-fonts-action/v1.2.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **hms5232--install-CNS11643-fonts-action/v1.2.0** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in action.yml directly interpolate `${{ }}` expressions inside shell command strings (sub-rule a). This applies to every step that uses `${{ github.action_path }}` or `${{ inputs.download-flag }}` directly in the run: script. Specifically:
- Line 26: `run: ${{ github.action_path }}/init.sh` — expression interpolated directly in run:
- Line 37: `${{ github.action_path }}/download_kai.sh -f "${{ inputs.download-flag }}"` — both github.action_path and the attacker-controlled inputs.download-flag are interpolated directly
- Line 53: `${{ github.action_path }}/download_sung.sh -f "${{ inputs.download-flag }}"` — same issue
- Line 65: `${{ github.action_path }}/install.sh` — expression in run:
- Line 70: `run: ${{ github.action_path }}/clear.sh` — expression in run:

Additionally (sub-rule b), the `inputs.download-flag` value is passed as a shell argument and then expanded **unquoted** as `${flags}` in the wget command inside download_kai.sh and download_sung.sh (e.g. `wget -O Fonts_Kai.zip ${flags} https://...`). An attacker-controlled input with shell metacharacters (`;`, `|`, `$(...)`, etc.) can cause command injection.

Locations:

- `action.yml:26`
- `action.yml:37`
- `action.yml:38`
- `action.yml:53`
- `action.yml:54`
- `action.yml:65`
- `action.yml:70`
- `download_kai.sh:14`
- `download_sung.sh:14`

### unpinned-uses (severity: high)

All four `uses:` references in action.yml use mutable version tags (`@v5`) instead of immutable full 40-character SHA commit digests. This exposes the action to supply-chain attacks if the referenced action's tag is moved or compromised. Failing references:
- `actions/cache/restore@v5` (Restore cached Kai fonts step)
- `actions/cache/save@v5` (Save cached Kai fonts step)
- `actions/cache/restore@v5` (Restore cached Sung fonts step)
- `actions/cache/save@v5` (Save cached Sung fonts step)

Locations:

- `action.yml:31`
- `action.yml:43`
- `action.yml:49`
- `action.yml:61`

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

Fixed all findings in action.yml, download_kai.sh, and download_sung.sh:

1. script-injection / static-inline-injection: Moved all ${{ github.action_path }} and ${{ inputs.download-flag }} expressions out of run: blocks into env: maps (ACTION_PATH and DOWNLOAD_FLAG respectively). Scripts now reference these as shell variables with proper double-quoting.

2. unpinned-uses: Pinned all four uses: references (actions/cache/restore@v5 and actions/cache/save@v5) to their full commit SHA caa296126883cff596d87d8935842f9db880ef25 with # v5 comment for readability.

3. Unquoted ${flags} injection in download_kai.sh and download_sung.sh: Replaced unquoted ${flags} in wget commands with xargs-based tokenization into bash arrays (wget_flags), guarded by an [ -n "$flags" ] check, then expanded as "${wget_flags[@]}". This safely handles multi-token flag lists while preventing shell metacharacter injection.

